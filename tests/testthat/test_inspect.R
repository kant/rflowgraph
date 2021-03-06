# Copyright 2018 IBM Corp.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

context("inspect")

ExampleClass = setClass("ExampleClass", representation(name="character"))
ExampleRefClass = setRefClass("ExampleRefClass", methods=list(
  method = function() TRUE
))

test_that("get class system of object", {
  expect_equal(class_system(1), "S3")
  expect_equal(class_system(NULL), "S3")
  expect_equal(class_system(data.frame(x=1, y=2)), "S3")
  
  expect_equal(class_system(ExampleClass()), "S4")
  expect_equal(class_system(ExampleRefClass$new()), "R5")
  
  expect_equal(class_system(dict()), "S3")
  expect_equal(class_system(ordered_dict()), "R6")
})

test_that("get class system of function", {
  expect_equal(class_system(is.function), NULL) # primitive
  expect_equal(class_system(is.primitive), NULL) # not primitive
  
  expect_equal(class_system(graphics::plot), "S3")
  expect_equal(class_system(stats4::plot), "S4")
  x = ExampleRefClass()
  expect_equal(class_system(x$method), "R5")
  d = ordered_dict()
  expect_equal(class_system(d$length), "R6")
})

test_that("get arguments of function", {
  expect_equal(names(fun_args(is.function)), "x") # primitive
  expect_equal(names(fun_args(is.primitive)), "x") # not primitive
  expect_equal(names(fun_args(`[`)), "...")
  expect_equal(names(fun_args(sum)), c("...", "na.rm"))
})

test_that("get package of function", {
  expect_equal(fun_package(is.function), "base") # primitive
  expect_equal(fun_package(is.primitive), "base") # not primitive
  expect_equal(fun_package(lm), "stats")
  
  pkg = packageName()
  expect_equal(fun_package(ordered_dict), pkg)
  expect_equal(fun_package(ordered_dict_class$new), pkg)
  expect_equal(fun_package(ordered_dict_class$new()$clone), pkg)
  expect_equal(fun_package(ExampleClass), pkg)
  expect_equal(fun_package(ExampleRefClass$new), pkg)
})

test_that("match arguments", {
  expect_equal(match_call(quote(lm(y~x, df))), c("formula", "data"))
  expect_equal(match_call(quote(lm(y~x, df, method="qr"))),
               c("formula", "data", "method"))
  expect_equal(match_call(quote(lm(y~x, method="qr", df))),
               c("formula", "method", "data"))
  expect_equal(match_call(quote(lm(data=df, method="qr", y~x))),
               c("data", "method", "formula"))
})

test_that("match arguments with ellipsis", {
  expect_equal(match_call(quote(data(iris))), "")
  expect_equal(match_call(quote(data(iris, iris3))), c("", ""))
  expect_equal(match_call(quote(data(list=c("iris", "iris3")))), "list")
})

test_that("match arguments of primitive function", {
  expect_equal(match_call(quote(x+y)), c("e1","e2"))
})

test_that("match arguments of primitive function with ellipsis", {
  expect_equal(match_call(quote(sum(x,y,z))), c("","",""))
  expect_equal(match_call(quote(df[,names(df)!="foo"])), c("","",""))
})

test_that("inspect function call", {
  lm_info = list(name="lm", package="stats")
  expect_equal(inspect_call(quote(lm(y~x, df))), lm_info)
  expect_equal(inspect_call(quote(stats::lm(y~x, df))), lm_info)
  
  plot_info = list(name="plot", package="graphics", system="S3")
  expect_equal(inspect_call(quote(plot(x,y))), plot_info)
})

test_that("inspect objects",{
  expect_equal(inspect_obj(1), list(class="numeric", system="S3"))
  expect_equal(inspect_obj(dict()), list(class="dict", system="S3"))
  expect_equal(inspect_obj(ordered_dict()),
               list(class=c("ordered_dict","dict","R6"), system="R6"))
})