(defpackage :cl-nix-project
  (:use :common-lisp)
  (:import-from :cl-project :make-project)
  (:import-from :split-sequence :split-sequence))

(in-package :cl-nix-project)

(defvar *nix-skeleton* "https://github.com/Teu5us/cl-nix-project-skeleton.git")

(defun in (arg keys)
  (member arg keys :test #'equal))

(defun e (message)
  (format *error-output* message))

(defun help ()
  "Does what it says on the tin."
  (format *error-output* "Usage:
    ~A [ARGUMENTS ...] <target-dir>

ARGUMENTS:
    -n/--name        Project name
    -a/--author      Author name to use
    -d/--desc        Project description
    -D/--depends-on  A string containing systems to put in ASDF's :depends-on
    -e/--email       Author's email
    -l/--license     Project license
    -h/--help        Print usage and exit

    <target-dir>     Target directory to store project
" (uiop:argv0))
  (uiop:quit 2))

(defun main ()
  (let ((argv (uiop:command-line-arguments))
        target-directory
        name
        author
        description
        email
        license
        depends-on)
    (unless argv
      (help))
    (loop :while argv :for arg = (pop argv) :do
      (cond
        ((in arg (list "-n" "--name"))
         (unless argv
           (e "-n/--name requires an argument")
           (help))
         (setf name (pop argv)))

        ((in arg (list "-a" "--author"))
         (unless argv
           (e "-a/--author requires an argument")
           (help))
         (setf author (pop argv)))

        ((in arg (list "-d" "--desc"))
         (unless argv
           (e "-d/--desc requires an argument")
           (help))
         (setf description (pop argv)))

        ((in arg (list "-e" "--email"))
         (unless argv
           (e "-e/--email requires an argument")
           (help))
         (setf email (pop argv)))

        ((in arg (list "-l" "--license"))
         (unless argv
           (e "-l/--license requires an argument")
           (help))
         (setf license (pop argv)))

        ((in arg (list "-D" "--depends-on"))
         (unless argv
           (e "-D/--depends-on requires an argument")
           (help))
         (setf depends-on (pop argv)))

        ((in arg (list "-h" "--help"))
         (help))

        (t
         (when argv
           (format *error-output* "Only one positional argument allowed~%")
           (help))
         (setf target-directory arg))))

    (multiple-value-bind (output error code)
        (uiop:run-program
         (list (uiop:getenv "SHELL")
               "-c"
               (format nil "git clone ~A ~S" *nix-skeleton* target-directory))
         :ignore-error-status t
         :error-output :string)
      (unless (= code 0)
        (e error)
        (uiop:quit 1))
      (let ((dotgit (uiop:directory-exists-p (format nil "~A/.git/" target-directory))))
        (when dotgit (uiop:delete-directory-tree dotgit :validate t)))
      (format t "Nix skeleton cloned.~%~%"))

    (make-project (pathname target-directory)
                  :name name
                  :author author
                  :description description
                  :email email
                  :license license
                  :depends-on (split-sequence #\Space depends-on :remove-empty-subseqs t))))

(defun dump-image ()
  "Make an executable"
  (setf uiop:*image-entry-point* #'main)
  (setf uiop:*lisp-interaction* nil)
  (setf *loaded-from* nil) ;; Break the link to our source
  (uiop:dump-image "cl-nix-project" :executable t))
