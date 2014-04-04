;;;; -*- mode: lisp; indent-tabs: nil -*-
;;;; nonfree.lisp
;;;; OpenCV bindings
;;;; Non-free functionality

(in-package :lisp-cv)


;;; Feature Detection and Description


;; SURF::SURF()
;; SURF* cv_create_SURF() 
(defcfun ("cv_create_SURF" surf0) (:pointer surf))


;; SURF::SURF(double hessianThreshold, int nOctaves=4, int nOctaveLayers=2, bool extended=true, bool upright=false )
;; SURF* cv_create_SURF5(double hessianThreshold, int nOctaves, int nOctaveLayers, bool extended, bool upright)
(defcfun ("cv_create_SURF5" %surf5) (:pointer surf)
  (hessian-threshold :double)
  (n-octaves :int)
  (n-octave-layers :int)
  (extended :boolean)
  (upright :boolean))

(defun surf5 (hessian-threshold &optional (n-octaves 4) (n-octave-layers 2) (extended t) (upright nil))
  (%surf5 hessian-threshold n-octaves n-octave-layers extended upright))