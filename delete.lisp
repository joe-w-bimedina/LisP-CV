;;;; -*- mode: lisp; indent-tabs: nil -*-
;;;; delete.lisp
;;;; C++ bindings
;;;; Delete functions for GC'ed types


(in-package :lisp-cv)


;; void operator delete  ( void* ptr )
;; void cv_delete(char* ptr)
(defcfun ("cv_delete" del) :void
  "Calls delete object."
  (self :pointer))


;; void operator delete  ( void* ptr )
;; void cv_delete_CvANN_MLP(CvANN_MLP* ptr)
(defcfun ("cv_delete_CvANN_MLP" del-ann-mlp) :void
  "Calls delete on a ANN-MLP object."
  (self ann-mlp))


;; void operator delete  ( void* ptr )
;; void cv_delete_CvANN_MLP_TrainParams(CvANN_MLP_TrainParams* self)
(defcfun ("cv_delete_CvANN_MLP_TrainParams" del-ann-mlp-train-params) :void
  "Calls delete on a ANN-MLP-TRAIN-PARAMS object."
  (self ann-mlp-train-params))


;; void operator delete  ( void* ptr )
;; void cv_delete_BFMatcher(BFMatcher* self)
(defcfun ("cv_delete_BFMatcher" del-bf-matcher) :void
  "Calls delete on a BF-MATCHER object."
  (self bf-matcher))


;; void operator delete  ( void* ptr )
;; void cv_delete_BRISK(BRISK* self)
(defcfun ("cv_delete_BRISK" del-brisk) :void
  "Calls delete on a BRISK object."
  (self brisk))


;; void operator delete  ( void* ptr )
;; void cv_delete_CascadeClassifier(CascadeClassifier* ptr) 
(defcfun ("cv_delete_CascadeClassifier" del-cascade-classifier) :void
  "Calls delete on a CASCADE-CLASSIFIER object."
  (self cascade-classifier))


;; void operator delete  ( void* ptr )
;; void cv_delete_CvNat(CvMat* self) 
(defcfun ("cv_delete_CvMat" del-cv-mat) :void
  "Calls delete on a CV-MAT object."
  (self mat-struct))


;; void operator delete  ( void* ptr )
;; void cv_delete_DMatch(DMatch* self)
(defcfun ("cv_delete_DMatch" del-dmatch) :void
  "Calls delete on a DMATCH object."
  (self dmatch))


;; void operator delete  ( void* ptr )
;; void cv_delete_CvDTree(CvDTree* self)
(defcfun ("cv_delete_CvDTree" del-d-tree) :void
  "Calls delete on a D-TREE object."
  (self d-tree))

;
;; void operator delete  ( void* ptr )
;; void cv_delete_CvDTreeParams(CvDTreeParam* self)
(defcfun ("cv_delete_CvDTreeParams" del-d-tree-params) :void
  "Calls delete on a D-TREE-PARAMS object."
  (self d-tree-params))


;; void operator delete  ( void* ptr )
;; void cv_delete_FastFeatureDetector(FastFeatureDetector* self)
(defcfun ("cv_delete_FastFeatureDetector" del-fast-feature-detector) :void
  "Calls delete on a FAST-FEATURE-DETECTOR object."
  (self fast-feature-detector))


;; void operator delete  ( void* ptr )
;; void cv_delete_FileNode(FileNode* self)
(defcfun ("cv_delete_FileNode" del-file-node) :void
  "Calls delete on a FILE-NODE object."
  (self file-node))


;; void operator delete  ( void* ptr )
;; void cv_delete_FileStorage(FileStorage* self)
(defcfun ("cv_delete_FileStorage" del-file-storage) :void
  "Calls delete on a FILE-STORAGE object."
  (self file-storage))


;; void operator delete  ( void* ptr )
;; void cv_delete_FlannBasedMatcher(FlannBasedMatcher* self)
(defcfun ("cv_delete_FlannBasedMatcher" del-flann-based-matcher) :void
  "Calls delete on a FLANN-BASED-MATCHER object."
  (self flann-based-matcher))


;; void operator delete  ( void* ptr )
;; void cv_delete_HOGDescriptor(HOGDescriptor* self)
(defcfun ("cv_delete_HOGDescriptor" del-hog-descriptor) :void
  "Calls delete on a HOG-DESCRIPTOR object."
  (self hog-descriptor))


;; void operator delete  ( void* ptr )
;; void cv_delete_CvKNearest(CvKNearest* self)
(defcfun ("cv_delete_CvKNearest" del-k-nearest) :void
  "Calls delete on a K-NEAREST object."
  (self k-nearest))


;; void operator delete  ( void* ptr )
;; void cv_delete_KeyPoint(KeyPoint* self)
(defcfun ("cv_delete_KeyPoint" del-key-point) :void
  "Calls delete on a KEY-POINT object."
  (self key-point))


;; void operator delete  ( void* ptr )
;; void cv_delete_Mat(Mat* self)
(defcfun ("cv_delete_Mat" del-mat) :void
  "Calls delete on a MAT object."
  (self mat))


;; void operator delete  ( void* ptr )
;; void cv_delete_(MatExpr* self)
(defcfun ("cv_delete_MatExpr" del-mat-expr) :void
  "Calls delete on a MAT-EXPR object."
  (self mat-expr))


;; void operator delete  ( void* ptr )
;; void cv_delete_CvNormalBayesClassifier(CvNormalBayesClassifier* self)
(defcfun ("cv_delete_CvNormalBayesClassifier" del-normal-bayes-classifier) :void
  "Calls delete on a NORMAL-BAYES-CLASSIFIER object."
  (self normal-bayes-classifier))


;; void operator delete  ( void* ptr )
;; void cv_delete_PCA(PCA* self)
(defcfun ("cv_delete_PCA" del-pca) :void
  "Calls delete on a PCA object."
  (self pca))


;; void operator delete  ( void* ptr )
;; void cv_delete_Point(Point* self)
(defcfun ("cv_delete_Point" del-point) :void
  "Calls delete on a POINT object."
  (self point))


;; void operator delete  ( void* ptr )
;; void cv_delete_Point2d(Point2d* self)
(defcfun ("cv_delete_Point2d" del-point-2d) :void
  "Calls delete on a POINT-2D object."
  (self point-2d))


;; void operator delete  ( void* ptr )
;; void cv_delete_Point2f(Point2f* self)
(defcfun ("cv_delete_Point2f" del-point-2f) :void
  "Calls delete on a POINT-2F object."
  (self point-2f))


;; void operator delete  ( void* ptr )
;; void cv_delete_Point3d(Point3d* self)
(defcfun ("cv_delete_Point3d" del-point-3d) :void
  "Calls delete on a POINT-3D object."
  (self point-3d))


;; void operator delete  ( void* ptr )
;; void cv_delete_Point3f(Point3f* self)
(defcfun ("cv_delete_Point3f" del-point-3f) :void
  "Calls delete on a POINT-3F object."
  (self point-3f))


;; void operator delete  ( void* ptr )
;; void cv_delete_Point3i(Point3i* self)
(defcfun ("cv_delete_Point3i" del-point-3i) :void
  "Calls delete on a POINT-3I object."
  (self point-3i))


;; void operator delete  ( void* ptr )
;; void cv_delete_Rect(Rect* self)
(defcfun ("cv_delete_Rect" del-rect) :void
  "Calls delete on a RECT object."
  (self rect))


;; void operator delete  ( void* ptr )
;; void cv_delete_Range(Rect* self)
(defcfun ("cv_delete_Range" del-range) :void
  "Calls delete on a RANGE object."
  (self range))


;; void operator delete  ( void* ptr )
;; void cv_delete_RNG(RNG* self)
(defcfun ("cv_delete_RNG" del-rng) :void
  "Calls delete on a RNG object."
  (self rng))


;; void operator delete  ( void* ptr )
;; void cv_delete_RotatedRect(RotatedRect* self)
(defcfun ("cv_delete_RotatedRect" del-rot-rect) :void
  "Calls delete on a ROTATED-RECT object."
  (self rotated-rect))


;; void operator delete  ( void* ptr )
;; void cv_delete_Scalar(Scalar* self)
(defcfun ("cv_delete_Scalar" del-scalar) :void
  "Calls delete on a SCALAR object."
  (self scalar))


;; void operator delete  ( void* ptr )
;; void cv_delete_Size(Size* self)
(defcfun ("cv_delete_Size" del-size) :void
  "Calls delete on a SIZE object."
  (self size))


;; void operator delete  ( void* ptr )
;; void cv_delete_std_string(string* self)
(defcfun ("cv_delete_std_string" del-std-string) :void
  "Calls delete on a STRING* object."
  (self string*))


;; void operator delete  ( void* ptr )
;; void cv_delete_SURF(SURF* self)
(defcfun ("cv_delete_SURF" del-surf) :void
  "Calls delete on a SURF object."
  (self surf))


;; void operator delete  ( void* ptr )
;; void cv_delete_CvSVM(CvSVM* self)
(defcfun ("cv_delete_CvSVM" del-svm) :void
  "Calls delete on a SVM object."
  (self svm))


;; void operator delete  ( void* ptr )
;; void cv_delete_CvSVMParams(CvSVMParams* self)
(defcfun ("cv_delete_CvSVMParams" del-svm-params) :void
  "Calls delete on a SVM-PARAMS object."
  (self svm-params))


;; void operator delete  ( void* ptr )
;; void cv_delete_TermCriteria(TermCriteria* self)
(defcfun ("cv_delete_TermCriteria" del-term-crit) :void
  "Calls delete on a TERM-CRITERIA object."
  (self term-criteria))


;; void operator delete  ( void* ptr )
;; void cv_delete_Vec2b(Vec2b* self)
(defcfun ("cv_delete_Vec2b" del-vec-2b) :void
  "Calls delete on a VEC-2B object."
  (self vec-2b))


;; void operator delete  ( void* ptr )
;; void cv_delete_Vec3b(Vec3b* self)
(defcfun ("cv_delete_Vec3b" del-vec-3b) :void
  "Calls delete on a VEC-3B object."
  (self vec-3b))


;; void operator delete  ( void* ptr )
;; void cv_delete_Vec4b(Vec4b* self)
(defcfun ("cv_delete_Vec4b" del-vec-4b) :void
  "Calls delete on a VEC-4B object."
  (self vec-4b))


;; void operator delete  ( void* ptr )
;; void cv_delete_Vec2d(Vec2d* self)
(defcfun ("cv_delete_Vec2d" del-vec-2d) :void
  "Calls delete on a VEC-2d object."
  (self vec-2d))


;; void operator delete  ( void* ptr )
;; void cv_delete_Vec3d(Vec3d* self)
(defcfun ("cv_delete_Vec3d" del-vec-3d) :void
  "Calls delete on a VEC-3D object."
  (self vec-3d))


;; void operator delete  ( void* ptr )
;; void cv_delete_Vec4d(Vec4d* self)
(defcfun ("cv_delete_Vec4d" del-vec-4d) :void
  "Calls delete on a VEC-4D object."
  (self vec-4d))

;; void operator delete  ( void* ptr )
;; void cv_delete_Vec6d(Vec6d* self)
(defcfun ("cv_delete_Vec6d" del-vec-6d) :void
  "Calls delete on a VEC-6D object."
  (self vec-6d))

;; void operator delete  ( void* ptr )
;; void cv_delete_Vec2f(Vec2f* self)
(defcfun ("cv_delete_Vec2f" del-vec-2f) :void
  "Calls delete on a VEC-2F object."
  (self vec-2f))


;; void operator delete  ( void* ptr )
;; void cv_delete_Vec3f(Vec3f* self)
(defcfun ("cv_delete_Vec3f" del-vec-3f) :void
  "Calls delete on a VEC-3F object."
  (self vec-3f))


;; void operator delete  ( void* ptr )
;; void cv_delete_Vec4f(Vec4f* self)
(defcfun ("cv_delete_Vec4f" del-vec-4f) :void
  "Calls delete on a VEC-4F object."
  (self vec-4f))


;; void operator delete  ( void* ptr )
;; void cv_delete_Vec6f(Vec6f* self)
(defcfun ("cv_delete_Vec6f" del-vec-6f) :void
  "Calls delete on a VEC-6F object."
  (self vec-6f))


;; void operator delete  ( void* ptr )
;; void cv_delete_Vec2i(Vec2i* self)
(defcfun ("cv_delete_Vec2i" del-vec-2i) :void
  "Calls delete on a VEC-2I object."
  (self vec-2i))


;; void operator delete  ( void* ptr )
;; void cv_delete_Vec3i(Vec3i* self)
(defcfun ("cv_delete_Vec3i" del-vec-3i) :void
  "Calls delete on a VEC-3I object."
  (self vec-3i))


;; void operator delete  ( void* ptr )
;; void cv_delete_Vec4i(Vec4i* self)
(defcfun ("cv_delete_Vec4i" del-vec-4i) :void
  "Calls delete on a VEC-4I object."
  (self vec-4i))


;; void operator delete  ( void* ptr )
;; void cv_delete_Vec6i(Vec6i* self)
(defcfun ("cv_delete_Vec6i" del-vec-6i) :void
  "Calls delete on a VEC-6I object."
  (self vec-6i))


;; void operator delete  ( void* ptr )
;; void cv_delete_Vec8i(Vec8i* self)
(defcfun ("cv_delete_Vec8i" del-vec-8i) :void
  "Calls delete on a VEC-8I object."
  (self vec-8i))


;; void operator delete  ( void* ptr )
;; void cv_delete_Vec2s(Vec2s* self)
(defcfun ("cv_delete_Vec2s" del-vec-2s) :void
  "Calls delete on a VEC-2S object."
  (self vec-2s))


;; void operator delete  ( void* ptr )
;; void cv_delete_Vec3s(Vec3s* self)
(defcfun ("cv_delete_Vec3s" del-vec-3s) :void
  "Calls delete on a VEC-3S object."
  (self vec-3s))


;; void operator delete  ( void* ptr )
;; void cv_delete_Vec4s(Vec4s* self)
(defcfun ("cv_delete_Vec4s" del-vec-4s) :void
  "Calls delete on a VEC-4S object."
  (self vec-4s))


;; void operator delete  ( void* ptr )
;; void cv_delete_Vec2w(Vec2w* self)
(defcfun ("cv_delete_Vec2w" del-vec-2w) :void
  "Calls delete on a VEC-2W object."
  (self vec-2w))


;; void operator delete  ( void* ptr )
;; void cv_delete_Vec3w(Vec3w* self)
(defcfun ("cv_delete_Vec3w" del-vec-3w) :void
  "Calls delete on a VEC-3W object."
  (self vec-3w))


;; void operator delete  ( void* ptr )
;; void cv_delete_Vec4w(Vec4w* self)
(defcfun ("cv_delete_Vec4w" del-vec-4w) :void
  "Calls delete on a VEC-4W object."
  (self vec-4w))


;; void operator delete  ( void* ptr )
;; void delete_std_vector##tn( vector_##t * v)
(defcfun ("delete_std_vectorc" del-vector-char) :void
  "Calls delete on a VECTOR-CHAR object."
  (self vector-char))


;; void operator delete  ( void* ptr )
;; void delete_std_vector##tn( vector_##t * v)
(defcfun ("delete_std_vectord" del-vector-double) :void
  "Calls delete on a VECTOR-DOUBLE object."
  (self vector-double))


;; void operator delete  ( void* ptr )
;; void delete_std_vector##tn( vector_##t * v)
(defcfun ("delete_std_vectordm" del-vector-dmatch) :void
  "Calls delete on a VECTOR-DMATCH object."
  (self vector-dmatch))


;; void operator delete  ( void* ptr )
;; void delete_std_vector##tn( vector_##t * v)
(defcfun ("delete_std_vectorf" del-vector-float) :void
  "Calls delete on a VECTOR-FLOAT object."
  (self vector-float))


;; void operator delete  ( void* ptr )
;; void delete_std_vector##tn( vector_##t * v)
(defcfun ("delete_std_vectori" del-vector-int) :void
  "Calls delete on a VECTOR-INT object."
  (self vector-int))


;; void operator delete  ( void* ptr )
;; void delete_std_vector##tn( vector_##t * v)
(defcfun ("delete_std_vectorkp" del-vector-key-point) :void
  "Calls delete on a VECTOR-KEY-POINT object."
  (self vector-key-point))


;; void operator delete  ( void* ptr )
;; void delete_std_vector##tn( vector_##t * v)
(defcfun ("delete_std_vectorm" del-vector-mat) :void
  "Calls delete on a VECTOR-MAT object."
  (self vector-mat))


;; void operator delete  ( void* ptr )
;; void delete_std_vector##tn( vector_##t * v)
(defcfun ("delete_std_vectorp" del-vector-point) :void
  "Calls delete on a VECTOR-POINT object."
  (self vector-point))


;; void operator delete  ( void* ptr )
;; void delete_std_vector##tn( vector_##t * v)
(defcfun ("delete_std_vectorp2f" del-vector-point-2f) :void
  "Calls delete on a VECTOR-POINT-2F object."
  (self vector-point-2f))


;; void operator delete  ( void* ptr )
;; void delete_std_vector##tn( vector_##t * v)
(defcfun ("delete_std_vectorr" del-vector-rect) :void
  "Calls delete on a VECTOR-RECT object."
  (self vector-rect))


;; void operator delete  ( void* ptr )
;; void delete_std_vector##tn( vector_##t * v)
(defcfun ("delete_std_vectoru" del-vector-uchar) :void
  "Calls delete on a VECTOR-UCHAR object."
  (self vector-uchar))


;; void operator delete  ( void* ptr )
;; void delete_std_vector##tn( vector_##t * v)
(defcfun ("delete_std_vectorv2b" del-vector-vec-2b) :void
  "Calls delete on a VECTOR-VEC-2B object."
  (self vector-vec-2b))


;; void operator delete  ( void* ptr )
;; void delete_std_vector##tn( vector_##t * v)
(defcfun ("delete_std_vectorv3b" del-vector-vec-3b) :void
  "Calls delete on a VECTOR-VEC-3B object."
  (self vector-vec-3b))


;; void operator delete  ( void* ptr )
;; void delete_std_vector##tn( vector_##t * v)
(defcfun ("delete_std_vectorv4b" del-vector-vec-4b) :void
  "Calls delete on a VECTOR-VEC-4B object."
  (self vector-vec-4b))


;; void operator delete  ( void* ptr )
;; void delete_std_vector##tn( vector_##t * v)
(defcfun ("delete_std_vectorv2d" del-vector-vec-2d) :void
  "Calls delete on a VECTOR-VEC-2d object."
  (self vector-vec-2d))


;; void operator delete  ( void* ptr )
;; void delete_std_vector##tn( vector_##t * v)
(defcfun ("delete_std_vectorv3d" del-vector-vec-3d) :void
  "Calls delete on a VECTOR-VEC-3D object."
  (self vector-vec-3d))


;; void operator delete  ( void* ptr )
;; void delete_std_vector##tn( vector_##t * v)
(defcfun ("delete_std_vectorv4d" del-vector-vec-4d) :void
  "Calls delete on a VECTOR-VEC-4D object."
  (self vector-vec-4d))


;; void operator delete  ( void* ptr )
;; void delete_std_vector##tn( vector_##t * v)
(defcfun ("delete_std_vectorv6d" del-vector-vec-6d) :void
  "Calls delete on a VECTOR-VEC-6D object."
  (self vector-vec-6d))


;; void operator delete  ( void* ptr )
;; void delete_std_vector##tn( vector_##t * v)
(defcfun ("delete_std_vectorv2f" del-vector-vec-2f) :void
  "Calls delete on a VECTOR-VEC-2F object."
  (self vector-vec-2f))


;; void operator delete  ( void* ptr )
;; void delete_std_vector##tn( vector_##t * v)
(defcfun ("delete_std_vectorv3f" del-vector-vec-3f) :void
  "Calls delete on a VECTOR-VEC-3F object."
  (self vector-vec-3f))


;; void operator delete  ( void* ptr )
;; void delete_std_vector##tn( vector_##t * v)
(defcfun ("delete_std_vectorv4f" del-vector-vec-4f) :void
  "Calls delete on a VECTOR-VEC-4F object."
  (self vector-vec-4f))


;; void operator delete  ( void* ptr )
;; void delete_std_vector##tn( vector_##t * v)
(defcfun ("delete_std_vectorv6f" del-vector-vec-6f) :void
  "Calls delete on a VECTOR-VEC-6F object."
  (self vector-vec-6f))


;; void operator delete  ( void* ptr )
;; void delete_std_vector##tn( vector_##t * v)
(defcfun ("delete_std_vectorv2i" del-vector-vec-2i) :void
  "Calls delete on a VECTOR-VEC-2I object."
  (self vector-vec-2i))


;; void operator delete  ( void* ptr )
;; void delete_std_vector##tn( vector_##t * v)
(defcfun ("delete_std_vectorv3i" del-vector-vec-3i) :void
  "Calls delete on a VECTOR-VEC-3I object."
  (self vector-vec-3i))


;; void operator delete  ( void* ptr )
;; void delete_std_vector##tn( vector_##t * v)
(defcfun ("delete_std_vectorv4i" del-vector-vec-4i) :void
  "Calls delete on a VECTOR-VEC-4I object."
  (self vector-vec-4i))


;; void operator delete  ( void* ptr )
;; void delete_std_vector##tn( vector_##t * v)
(defcfun ("delete_std_vectorv6i" del-vector-vec-6i) :void
  "Calls delete on a VECTOR-VEC-6I object."
  (self vector-vec-6i))


;; void operator delete  ( void* ptr )
;; void delete_std_vector##tn( vector_##t * v)
(defcfun ("delete_std_vectorv8i" del-vector-vec-8i) :void
  "Calls delete on a VECTOR-VEC-8I object."
  (self vector-vec-8i))


;; void operator delete  ( void* ptr )
;; void delete_std_vector##tn( vector_##t * v)
(defcfun ("delete_std_vectorv2s" del-vector-vec-2s) :void
  "Calls delete on a VECTOR-VEC-2S object."
  (self vector-vec-2s))


;; void operator delete  ( void* ptr )
;; void delete_std_vector##tn( vector_##t * v)
(defcfun ("delete_std_vectorv3s" del-vector-vec-3s) :void
  "Calls delete on a VECTOR-VEC-3S object."
  (self vector-vec-3s))


;; void operator delete  ( void* ptr )
;; void delete_std_vector##tn( vector_##t * v)
(defcfun ("delete_std_vectorv4s" del-vector-vec-4s) :void
  "Calls delete on a VECTOR-VEC-4S object."
  (self vector-vec-4s))


;; void operator delete  ( void* ptr )
;; void delete_std_vector##tn( vector_##t * v)
(defcfun ("delete_std_vectorv2w" del-vector-vec-2w) :void
  "Calls delete on a VECTOR-VEC-2W object."
  (self vector-vec-2w))


;; void operator delete  ( void* ptr )
;; void delete_std_vector##tn( vector_##t * v)
(defcfun ("delete_std_vectorv3w" del-vector-vec-3w) :void
  "Calls delete on a VECTOR-VEC-3W object."
  (self vector-vec-3w))


;; void operator delete  ( void* ptr )
;; void delete_std_vector##tn( vector_##t * v)
(defcfun ("delete_std_vectorv4w" del-vector-vec-4w) :void
  "Calls delete on a VECTOR-VEC-4W object."
  (self vector-vec-4w))


;; void operator delete  ( void* ptr )
;; void cv_delete_VideoCapture(VideoCapture* self)
(defcfun ("cv_delete_VideoCapture" del-video-capture) :void
  "Calls delete on a VIDEO-CAPTURE object."
  (self video-capture))


;; void operator delete  ( void* ptr )
;; void delete_VideoWriter(VideoWriter* self)
(defcfun ("cv_delete_VideoWriter" del-video-writer) :void
  "Calls delete on a VIDEO-WRITER object."
  (self video-writer))
