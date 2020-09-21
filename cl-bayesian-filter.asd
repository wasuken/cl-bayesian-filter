(defsystem "cl-bayesian-filter"
  :version "0.1.0"
  :author ""
  :license ""
  :depends-on ("cl-ppcre" "trivial-hashtable-serialize")
  :components ((:module "src"
                :components
                ((:file "main"))))
  :description ""
  :in-order-to ((test-op (test-op "cl-bayesian-filter/tests"))))

(defsystem "cl-bayesian-filter/tests"
  :author ""
  :license ""
  :depends-on ("cl-bayesian-filter"
               "rove")
  :components ((:module "tests"
                :components
                ((:file "main"))))
  :description "Test system for cl-bayesian-filter"
  :perform (test-op (op c) (symbol-call :rove :run c)))
