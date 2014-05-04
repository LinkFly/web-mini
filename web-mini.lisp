(restas:define-module :restas.web-mini 
  (:use :cl :restas :cl-fad :anaphora)
  #-lispworks (error "Not implemented for none Lispworks")
  #+lispworks (:import-from :lispworks #:lisp-image-name)
  #+lispworks (:import-from :system #:parse-command-line)
  )

(in-package :restas.web-mini)

(defparameter *port* 8080)
(defparameter *root-dir* "www")
(defparameter *as-site* nil)
(defparameter *start-www-file* "index.html")
;(defparameter *start-www-file* "lounge.html") 


(defun get-this-dir ()
  (make-pathname :defaults (pathname (lisp-image-name)) :name nil :type nil))
;(get-this-dir)

(defun get-conf-file ()
  (make-pathname :defaults (lisp-image-name) :type "conf"))
;(get-conf-file)

(defun read-file (file)
  (with-open-file (s file)
    (read s)))

(defun start-tws (&key conf-file port root-dir as-site &aux config port-cfg root-dir-cfg as-site-cfg args fst-arg snd-arg trd-arg)
  (unless conf-file (setf conf-file (get-conf-file)))
  ;; Getting root-dir-cfg and port-cfg
  (if (probe-file conf-file)
      (progn
        (setf config (read-file conf-file))
        (setf port-cfg (getf config :port))
        (setf root-dir-cfg (getf config :root-dir))
        (setf as-site-cfg (getf config :as-site)))
    (progn 
      (setf args (parse-command-line))
      (setf fst-arg (second args))
      (setf snd-arg (third args))
      (setf trd-arg (fourth args))
      (setf port-cfg (aif fst-arg it *port*))
      (setf root-dir-cfg (aif snd-arg it *root-dir*))
      (setf as-site-cfg (aif trd-arg (string-equal "as-site" it) *as-site*))))
  
  ;; Replace with keyword argumets
  (when port (setf port-cfg port))
  (when root-dir (setf root-dir-cfg root-dir))
  (when as-site (setf as-site-cfg as-site))
    

  ;; Maybe absolutized root-dir-cfg
  (when (pathname-relative-p root-dir-cfg)
    (setf root-dir-cfg (merge-pathnames root-dir-cfg (get-this-dir))))

  ;; Checking directory 
  (unless (probe-file root-dir-cfg) (error "Bad directory"))

  ;; Mounting
  (restas:mount-module -wwwdir- (#:restas.directory-publisher)
    (:url "/")
    (restas.directory-publisher:*directory* root-dir-cfg)
    (restas.directory-publisher:*autoindex* t))

  ;; As site - "/" translate to *start-www-file* ("index.html")
  (when as-site-cfg 
    (define-route main ("/")
      (merge-pathnames *start-www-file* root-dir-cfg))
    (define-route main ("")
      (merge-pathnames *start-www-file* root-dir-cfg)))

  ;;Starting web-server
  (start :restas.web-mini :port port-cfg))

;(start-tws :conf-file "d:/linkfly-win-files/learn/lisp-web/web-mini/web-mini.conf.example")
;(stop-all)
;(restas:debug-mode-on)
