(defpackage cl-bayesian-filter/tests/main
  (:use :cl
        :cl-bayesian-filter
        :rove))
(in-package :cl-bayesian-filter/tests/main)

;; NOTE: To run this test file, execute `(asdf:test-system :cl-bayesian-filter)' in your Lisp.

(deftest test-target-1
  (testing "should (= 1 1) to be true"
    (ok (= 1 1))))
