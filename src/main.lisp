(defpackage cl-bayesian-filter
  (:use :cl)
  (:export :learning :scoreing))
(in-package :cl-bayesian-filter)

;; str ops
(defun n-gram (text n)
  (cond ((<= n (length text))
		 (cons (subseq text 0 n)
			   (n-gram (subseq text 1) n)))
		(t '())))

;;; table ops
(defun read-table (ham-filepath spam-filepath)
  (let ((ham-table (if (probe-file ham-filepath)
					   (trivial-hashtable-serialize:load-hashtable ham-filepath)
					   (make-hash-table :test #'equal)))
		(spam-table (if (probe-file spam-filepath)
						(trivial-hashtable-serialize:load-hashtable spam-filepath)
						(make-hash-table :test #'equal))))
	(values ham-table
			spam-table)))

(defun save-table (ham-table ham-filepath spam-table spam-filepath)
  (trivial-hashtable-serialize:save-hashtable ham-table ham-filepath)
  (trivial-hashtable-serialize:save-hashtable spam-table spam-filepath))

(defun insert-table (table text)
  (let ((ng (n-gram text 3)))
	(loop for gram in ng
	 do (cond ((null (gethash x table))
			   (setf (gethash x table) 1))
			  (t (setf (gethash x table) (1+ (gethash x table))))))
	table))

(defun scoring (ham-filepath spam-filepath filepath)
  (multiple-value-bind (ham-table spam-table)
	  (read-table ham-filepath spam-filepath)
	(let* ((ham-score 0)
		   (spam-score 0)
		   (text (format nil "~{~A~%~}" (mylib:read-file-to-list filepath)))
		   (ng (n-gram text 3)))
	  (loop for gram in ng
		 do (progn
			  (setf ham-score (+ ham-score
								 (if (gethash gram ham-table)
									 (sqrt (gethash gram ham-table))
									 0)))
			  (setf spam-score (+ spam-score
								  (if (gethash gram ham-table)
									  (sqrt (gethash gram spam-table))
									  0)))))
	  (values (- ham-score spam-score)
			  ham-score
			  spam-score))
	))

(defun learning (type ham-filepath spam-filepath &rest filepath-lst)
  (multiple-value-bind (ham-table spam-table)
	  (read-table ham-filepath spam-filepath)
	(let ((lst-count (length filepath-lst))
		  (count 1))
	  (loop for filepath in filepath-lst
		 do (let ((text (format nil "~{~A~%~}" (mylib:read-file-to-list filepath))))
			  (format t "~A ~A/~A~%" filepath count lst-count)
			  ;; ここ縷ーぷごとに判定してるからかなり遅くなると思う。
			  (cond ((string= type "ham")
					 (insert-table ham-table text))
					((string= type "spam")
					 (insert-table spam-table text))
					(t (error (format nil "Type Not Found (~A)" type))))
			  (incf count))))
	(save-table ham-table ham-filepath spam-table spam-filepath)))
