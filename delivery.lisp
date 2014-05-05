;(load "E:/LinkFly/libs/quicklisp/setup.lisp")
;(push "E:/LinkFly/libs/web-mini/" asdf:*central-registry*)
;(ql:quickload :web-mini)

;(deliver 'restas.web-mini::start-tws "E:/LinkFly/libs/apps/web-mini.exe" 4 :console t)

(defun f () (print 'ok))
(deliver 'f "E:/LinkFly/libs/apps/web-mini.exe" 4 :console t)