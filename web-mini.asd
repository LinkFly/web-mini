(asdf:defsystem :web-mini
  :depends-on (:restas :restas-directory-publisher :cl-fad :anaphora)
  :components ((:file "web-mini")))