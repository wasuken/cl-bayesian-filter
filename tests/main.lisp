(defpackage cl-bayesian-filter/tests/main
  (:use :cl
        :cl-bayesian-filter
        :rove))
(in-package :cl-bayesian-filter/tests/main)

;; NOTE: To run this test file, execute `(asdf:test-system :cl-bayesian-filter)' in your Lisp.

(setup
 (cl-bayesian-filter:train "Python（パイソン）は，オランダ人のグイド・ヴァンロッサムが作ったオープンソースのプログラミング言語。
                オブジェクト指向スクリプト言語の一種であり，Perlとともに欧米で広く普及している。イギリスのテレビ局 BBC が製作したコメディ番組『空飛ぶモンティパイソン』にちなんで名付けられた。
                Python は英語で爬虫類のニシキヘビの意味で，Python言語のマスコットやアイコンとして使われることがある。Pythonは汎用の高水準言語である。プログラマの生産性とコードの信頼性を重視して設計されており，核となるシンタックスおよびセマンティクスは必要最小限に抑えられている反面，利便性の高い大規模な標準ライブラリを備えている。
                Unicode による文字列操作をサポートしており，日本語処理も標準で可能である。多くのプラットフォームをサポートしており（動作するプラットフォーム），また，豊富なドキュメント，豊富なライブラリがあることから，産業界でも利用が増えつつある。" "Python")
 (cl-bayesian-filter:train "ヘビ（蛇）は、爬虫綱有鱗目ヘビ亜目（Serpentes）に分類される爬虫類の総称。
                体が細長く、四肢がないのが特徴。ただし、同様の形の動物は他群にも存在する。" "Snake")
 (cl-bayesian-filter:train "Ruby（ルビー）は，まつもとゆきひろ（通称Matz）により開発されたオブジェクト指向スクリプト言語であり，
                従来 Perlなどのスクリプト言語が用いられてきた領域でのオブジェクト指向プログラミングを実現する。
                Rubyは当初1993年2月24日に生まれ， 1995年12月にfj上で発表された。
                名称のRubyは，プログラミング言語Perlが6月の誕生石であるPearl（真珠）と同じ発音をすることから，
                まつもとの同僚の誕生石（7月）のルビーを取って名付けられた。" "Ruby")
 (cl-bayesian-filter:train "ルビー（英: Ruby、紅玉）は、コランダム（鋼玉）の変種である。赤色が特徴的な宝石である。
                天然ルビーは産地がアジアに偏っていて欧米では採れないうえに、
                産地においても宝石にできる美しい石が採れる場所は極めて限定されており、
                3カラットを超える大きな石は産出量も少ない。" "Gem"))

(deftest test-base
	(testing "should [exmaple-text] to be Python"
			 (ok (string= (cl-bayesian-filter:classify "グイド・ヴァンロッサムが作ったオープンソース" t)
						  "Python"))
			 )
  (testing "should [exmaple-text] to be Ruby"
		   (ok (string= (cl-bayesian-filter:classify
						 "プログラミング言語のRubyは純粋なオブジェクト指向言語です." t)
						"Ruby")))
  (testing "should [exmaple-text] to be Gem"
		   (ok (string= (cl-bayesian-filter:classify
						 "コランダム" t)
						"Gem"))))
