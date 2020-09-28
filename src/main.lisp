(defpackage cl-bayesian-filter
  (:use :cl :cl-json)
  (:export :train :score :classify))
(in-package :cl-bayesian-filter)

;;; https://qiita.com/katryo/items/6a2266ffafb7efa9a46c
;;; これをCLに劣化変換してるだけ。

(defparameter *vocabularies* '())
(defparameter *cat-tbl* (make-hash-table :test #'equal))

;; (defun load-table (tbl-path)
;;   ())

;; (defun save-table (tbl-path)
;;   (with-open-file (s tbl-path :direction :output :if-exists)
;; 	(format s "~A" (json:encode-json-to-string *cat-tbl*))))

(defun voc-add (item)
  (setf *vocabularies*
		(remove-duplicates (append *vocabularies* `(,item))
						   :test #'string=)))

(defstruct category
  (count 0 :type integer)
  (word-table (make-hash-table :test #'equal) :type hash-table))

;;; memo
;;; Category count table => {cat => count}
;;; words set
;;; words count => {cat => {word => count}}

(defparameter *n* 5)

;; str ops
(defun n-gram (text &optional (n *n*))
  (cond ((<= n (length text))
		 (cons (subseq text 0 n)
			   (n-gram (subseq text 1) n)))
		(t '())))

(defun word-count-up (word cat)
  (cond ((null (gethash cat *cat-tbl*))
		 (let ((cat-obj (make-category)))
		   (setf (gethash word (slot-value cat-obj 'word-table)) 0)
		   (setf (gethash cat *cat-tbl*) cat-obj)))
		((null (gethash word (slot-value (gethash cat *cat-tbl*) 'word-table)))
		 (setf (gethash word (slot-value (gethash cat *cat-tbl*) 'word-table)) 0)))
  (incf (gethash word (slot-value (gethash cat *cat-tbl*) 'word-table)))
  (voc-add word))

(defun category-count-up (cat)
  (cond ((null (gethash cat *cat-tbl*))
		 (let ((cat-obj (make-category)))
		   (setf (gethash cat *cat-tbl*) cat-obj))))
  (incf (slot-value (gethash cat *cat-tbl*) 'count)))

(defun train (text category)
  (let ((grams (n-gram text *n*)))
	(loop for word in grams
	   do (word-count-up word category))
	(category-count-up category)))

(defun prior-prob (cat)
  (let ((total-of-cat 0)
		(total-of-words-in-cat 0))
	(maphash #'(lambda (k v)
				 (setf total-of-cat
					   (+ total-of-cat (slot-value v 'count)))
				 (setf total-of-words-in-cat
					   (+ total-of-words-in-cat
						  (slot-value (gethash cat *cat-tbl*) 'count))))
			 *cat-tbl*)
	(/ total-of-words-in-cat total-of-cat)))

(defun num-of-appearance (word cat)
  (if (and (gethash cat *cat-tbl*)
		   (gethash word (slot-value (gethash cat *cat-tbl*) 'word-table)))
	  (gethash word (slot-value (gethash cat *cat-tbl*) 'word-table))
	  0))

(defun tbl-v-sum (tbl)
  (let ((cnt 0))
	(maphash #'(lambda (k v) (setf cnt (+ cnt v))) tbl)
	cnt))

(defun word-prob (word cat)
  (let ((numer (1+ (num-of-appearance word cat)))
		(deno (+ (tbl-v-sum (slot-value (gethash cat *cat-tbl*) 'word-table))
				 (length *vocabularies*))))
	(/ numer deno)))

(defun score (words cat &optional (f #'identity))
  (let ((score (funcall f (prior-prob cat))))
	(loop for word in words
	   do (setf score (+ score (funcall f (word-prob word cat)))))
	score))

(defun classify (doc &optional (debug? nil))
  (let ((guess-cat nil)
		(max-prob most-negative-fixnum)
		(words (n-gram doc)))
	(maphash #'(lambda (cat v)
				 (let ((prob (score words cat)))
				   ;; 最悪な作り。作者は一体誰だ。
				   (when debug?
					 (format t "~A => ~A~%" cat (float prob)))
				   (cond ((> prob max-prob)
						  (setf max-prob prob)
						  (setf guess-cat cat)))))
			 *cat-tbl*)
	(values guess-cat max-prob)))
