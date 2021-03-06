;;;; -*- mode: lisp; indent-tabs: nil -*-
;;;; ml.lisp
;;;; OpenCV bindings
;;;; Machine Learning.

(in-package :lisp-cv)


;;; LISP-CV specific


(declaim (ftype (function (string symbol cv-size &optional boolean)
                          cv-mat) make-training-matrix))

(defun make-training-matrix (directory directory-contents dsize &optional (test nil))

  (let* ((pathname-list (make-pathname-list :directory directory 
					    :directory-contents directory-contents))
	 (num-of-files (length pathname-list))
	 (img-height (round (size-height dsize)))
	 (img-width (round (size-width dsize)))
	 (img-area (* img-height img-width))
         (training-data (mat 0 img-area +32f+))
         (i 0))

    (dotimes (n num-of-files)
      (with-mat ((img (imread (nth n pathname-list) +load-image-grayscale+)))
	(convert-to img img +32f+)
	(%resize img img dsize 0d0 0d0 +inter-linear+)
	(with-mat ((reshaped-img (reshape-rows img 0 1)))
	  (push-back training-data reshaped-img) 
	  (princ #\NewLine) 
	  (princ "Pushing image ")
	  (princ (+ n 1))
	  (princ " into training matrix.")
	  (princ #\NewLine))))
    (if (null test)
	(return-from make-training-matrix training-data)
	(let ((window-name "Testing..."))
	  (with-named-window (window-name +window-normal+)
	    (move-window window-name 759 175)
	    (loop
	       (let* ((row (row training-data i))
		      (reshaped-img (reshape-rows row 0 img-height)))
		 (imshow window-name reshaped-img)
		 (del-mat reshaped-img)
		 (del-mat row))
	       (if (< i (- num-of-files 1)) (incf i))
	       (let ((c (wait-key 1)))
		 (when (or (= c 27) (= i (- num-of-files 1)))
		   (return-from make-training-matrix 
		     training-data)
		   (return)))))))))



;;; Statistical Models



;; void CvStatModel::load( const char* filename, const char* name=0 )
;; void cv_CvStatModel_load2(CvStatModel* self, c_string filename, c_string name) 
(defcfun ("cv_CvStatModel_load2" stat-model-load-svm) :void
  (self svm)
  (filename :string)
  (name :string))


(defun stat-model-load (self filename &optional (name (null-pointer)))
   (stat-model-load-svm self filename name))


;; void CvStatModel::save( const char* filename, const char* name=0 ) const;
;; void cv_CvStatModel_save2(CvStatModel* self, c_string filename, c_string name) 
(defcfun ("cv_CvStatModel_save2" stat-model-save-svm) :void
  (self svm)
  (filename :string)
  (name :string))


(defun stat-model-save (self filename &optional (name (null-pointer)))
   (stat-model-save-svm self filename name))



;;; Normal Bayes Classifier



;; CvNormalBayesClassifier::CvNormalBayesClassifier()
;; CvNormalBayesClassifier* cv_create_CvNormalBayesClassifier()
(defcfun ("cv_create_CvNormalBayesClassifier" normal-bayes-classifier-0) normal-bayes-classifier)

;; CvNormalBayesClassifier::CvNormalBayesClassifier(const Mat& trainData, const Mat& responses, const Mat& varIdx=Mat(), 
;;                                                  const Mat& sampleIdx=Mat() )
;; CvNormalBayesClassifier* cv_create_CvNormalBayesClassifier4(Mat* trainData, Mat* responses, Mat* varIdx, Mat* sampleIdx) 
(defcfun ("cv_create_CvNormalBayesClassifier4" normal-bayes-classifier-4) normal-bayes-classifier
  (train-data mat)
  (responses mat)
  (var-idx mat)
  (sample-idx mat))

(defun normal-bayes-classifier (&optional train-data responses (var-idx (%mat) given-var-idx) (sample-idx (%mat) given-sample-idx))
  (let ((return (if train-data
		    (normal-bayes-classifier-4 train-data responses  var-idx sample-idx)
		    (normal-bayes-classifier-0))))
    (if given-var-idx nil (del-mat var-idx))
    (if given-sample-idx nil (del-mat sample-idx)) 
    return))

(defun make-normal-bayes-classifier (&optional train-data responses  (var-idx (%mat) given-var-idx) (sample-idx (%mat) given-sample-idx))
  (let ((return (if train-data
		    (normal-bayes-classifier-4 train-data responses  var-idx sample-idx)
		    (normal-bayes-classifier-0))))
    (if given-var-idx nil (del-mat var-idx))
    (if given-sample-idx nil (del-mat sample-idx)) 
    return))


;; float CvNormalBayesClassifier::predict(const Mat& samples, Mat* results=0, Mat* results_prob=0 ) const
;; float cv_CvNormalBayesClassifier_predict3(CvNormalBayesClassifier* self, Mat* samples, Mat* results, Mat* results_prob) 
(defcfun ("cv_CvNormalBayesClassifier_predict3" %normal-bayes-classifier-predict) :float
  (self normal-bayes-classifier)
  (samples mat)
  (results mat)
  (results-prob mat))

(defun normal-bayes-classifier-predict (self samples &optional (results (null-pointer)) (results-prob (null-pointer)))
  (%normal-bayes-classifier-predict self samples results results-prob))



;;; K-nearest Neighbors



;; CvKNearest::CvKNearest()
;; CvKNearest* cv_create_CvKNearest() 
(defcfun ("cv_create_CvKNearest" k-nearest-0) k-nearest)

;; CvKNearest::CvKNearest(const CvMat* trainData, const CvMat* responses, const CvMat* sampleIdx=0, bool isRegression=false, 
;;                        int max_k=32 )
;; CvKNearest* cv_create_CvKNearest5(Mat* trainData, Mat* responses, Mat* sampleIdx, bool isRegression, int max_k) 
(defcfun ("cv_create_CvKNearest5" k-nearest-5) k-nearest
  (train-data mat)
  (responses mat)
  (sample-idx mat)
  (is-regression :boolean)
  (max-k :int))

(defun k-nearest (&optional train-data responses (sample-idx (null-pointer)) (is-regression nil) (max-k 32))
  (if train-data
      (k-nearest-5 train-data responses sample-idx is-regression max-k)
      (k-nearest-0)))

(defun make-k-nearest (&optional train-data responses (sample-idx (null-pointer)) (is-regression nil) (max-k 32))
  (if train-data
      (k-nearest-5 train-data responses sample-idx is-regression max-k)
      (k-nearest-0)))


;; float CvKNearest::find_nearest(const Mat& samples, int k, Mat& results, Mat& neighborResponses, Mat& dists) const
;; float cv_CvKNearest_find_nearest(CvKNearest* self, Mat* samples, int k, Mat* results, Mat* neighborResponses, Mat* dists) 
(defcfun ("cv_CvKNearest_find_nearest" %k-nearest-find-nearest) :float
  (self k-nearest)
  (samples mat)
  (k :int)
  (results mat)
  (neighbor-responses mat)
  (dists mat))

(defun k-nearest-find-nearest (self samples k &optional (results (null-pointer)) (neighbor-responses (null-pointer)) 
                              (dists (null-pointer)))
  (%k-nearest-find-nearest self samples k results neighbor-responses dists))



;;; Support Vector Machines


(defun c (self)
  (if (typep self 'cv-svm-params)
      (mem-ref (c-pointer self) :double 32)))


(defun (setf c) (val self)
  (if (typep self 'cv-svm-params)
      (setf (mem-ref (c-pointer self) :double 32) val)))


(defun class-weights (self)
  (if (typep self 'cv-svm-params)
      (mem-ref (c-pointer self) 'mat-struct 56)))


(defun (setf class-weights) (val self)
  (if (typep self 'cv-svm-params)
      (setf (mem-ref (c-pointer self) 'mat-struct 56) val)))


(defun coef-0 (self)
  (if (typep self 'cv-svm-params)
      (mem-ref (c-pointer self) :double 24)))


(defun (setf coef-0) (val self)
  (if (typep self 'cv-svm-params)
      (setf (mem-ref (c-pointer self) :double 24) val)))


(defun degree (self)
  (if (typep self 'cv-svm-params)
      (mem-ref (c-pointer self) :double 8)))


(defun (setf degree) (val self)
  (if (typep self 'cv-svm-params)
      (setf (mem-ref (c-pointer self) :double 8) val)))


(defun gamma (self)
  (if (typep self 'cv-svm-params)
      (mem-ref (c-pointer self) :double 16)))


(defun (setf gamma) (val self)
  (if (typep self 'cv-svm-params)
      (setf (mem-ref (c-pointer self) :double 16) val)))


;; const float* CvSVM::get_support_vector(int i) const
;; const float* cv_CvSVM_get_support_vector(SVM* self, int i);
(defcfun ("cv_CvSVM_get_support_vector" get-support-vector) :pointer
  (self svm)
  (i :int))


;; int CvSVM::get_support_vector_count() const
;; int cv_CvSVM_get_support_vector_count(CvSVM* self)
(defcfun ("cv_CvSVM_get_support_vector_count" get-support-vector-count) :int
  (self svm))


(defun kernel-type (self)
  (if (typep self 'cv-svm-params)
      (mem-ref (c-pointer self) :int 4)))


(defun (setf kernel-type) (val self)
  (if (typep self 'cv-svm-params)
      (setf (mem-ref (c-pointer self) :int 4) val)))


(defun nu (self)
  (if (typep self 'cv-svm-params)
      (mem-ref (c-pointer self) :double 40)))


(defun (setf nu) (val self)
  (if (typep self 'cv-svm-params)
      (setf (mem-ref (c-pointer self) :double 40) val)))


(defun p (self)
  (if (typep self 'cv-svm-params)
      (mem-ref (c-pointer self) :double 48)))


(defun (setf p) (val self)
  (if (typep self 'cv-svm-params)
      (setf (mem-ref (c-pointer self) :double 48) val)))


;; CvSVM::CvSVM()
;; CvSVM* cv_create_CvSVM() 
(defcfun ("cv_create_CvSVM" svm-0) svm)


;; CvSVM::CvSVM(const Mat& trainData, const Mat& responses, const Mat& varIdx=Mat(), const Mat& sampleIdx=Mat(), 
;; CvSVMParams params=CvSVMParams() )
;; CvSVM* cv_create_CvSVM5(Mat* trainData, Mat* responses, Mat* varIdx, Mat* sampleIdx, CvSVMParams* params)
(defcfun ("cv_create_CvSVM5" svm-5) svm
  (train-data mat)
  (responses mat)
  (var-idx mat)
  (sample-idx mat)
  (params svm-params))


(defun svm (&optional train-data responses (var-idx (%mat) given-var-idx) (sample-idx (%mat) given-sample-idx)
	      (params (svm-params-0) given-params))
  (let ((return (if train-data 
		    (svm-5 train-data responses var-idx sample-idx params)
		    (svm-0))))
    (if given-var-idx nil (del-mat var-idx))
    (if given-sample-idx nil (del-mat sample-idx))
    (if given-params nil (del-svm-params params))
    return))


(defun make-svm (&optional train-data responses (var-idx (%mat) given-var-idx) (sample-idx (%mat) given-sample-idx)
	      (params (svm-params-0) given-params))
  (let ((return (if train-data 
		    (svm-5 train-data responses var-idx sample-idx params)
		    (svm-0))))
    (if given-var-idx nil (del-mat var-idx))
    (if given-sample-idx nil (del-mat sample-idx))
    (if given-params nil (del-svm-params params))
    return))


;; CvSVMParams::CvSVMParams()
;; CvSVMParams* cv_create_CvSVMParams() 
(defcfun ("cv_create_CvSVMParams" svm-params-0) svm-params)


;;  CvSVMParams::CvSVMParams(int svm_type, int kernel_type, double degree, double gamma, double coef0, double Cvalue, double nu, double p, CvMat* class_weights, CvTermCriteria term_crit)
;; CvSVMParams* cv_create_CvSVMParams10(int svm_type, int kernel_type, double degree, double gamma, double coef0, double Cvalue, double nu, double p, CvMat* class_weights, CvTermCriteria term_crit)
(defcfun ("cv_create_CvSVMParams10" svm-params-10) svm-params
  (svm-type :int)
  (kernel-type :int)
  (degree :double)
  (gamma :double)
  (coef-0 :double)
  (c-value :double)
  (nu :double)
  (p :double)
  (class-weights mat-struct)
  (term-crit (:pointer (:struct term-criteria-struct))))


(defun svm-params (&optional svm-type kernel-type degree gamma coef-0 c-value nu p class-weights term-crit)
  (cond ((null svm-type)
	 (svm-params-0))
	(svm-type
	 (svm-params-10 svm-type kernel-type degree gamma coef-0 c-value nu p class-weights term-crit))
	(t nil)))


(defun make-svm-params (&optional svm-type kernel-type degree gamma coef-0 c-value nu p class-weights term-crit)
  (cond ((null svm-type)
	 (svm-params-0))
	(svm-type
	 (svm-params-10 svm-type kernel-type degree gamma coef-0 c-value nu p class-weights term-crit))
	(t nil)))


;; float CvSVM::predict( const cv::Mat& sample, bool returnDFVal=false ) const
;; float cv_CvSVM_predict2(CvSVM* self, Mat* sample, bool returnDFVal) 

;; void CvSVM::predict( cv::InputArray samples, cv::OutputArray results ) const
;; void cv_CvSVM_predict2_0(CvSVM* self, Mat* samples, Mat* results) 

(defun svm-predict (self arg1 &optional (arg2 nil given-arg2))
  "Predicts response(s) for the provided sample(s)"
  (if given-arg2
      (cond ((typep arg2 'cv-mat)
	     (foreign-funcall "cv_CvSVM_predict2_0" :pointer (c-pointer self) 
			      :pointer (c-pointer arg1) 
			      :pointer (c-pointer arg2)
                              :float))
	    ((typep arg2 'boolean)
	     (foreign-funcall "cv_CvSVM_predict2" :pointer (c-pointer self) 
			      :pointer (c-pointer arg1) 
			      :boolean arg2
                              :float)))
      (foreign-funcall "cv_CvSVM_predict2" :pointer (c-pointer self) 
		       :pointer (c-pointer arg1) 
		       :boolean arg2
                       :float)))


;; bool CvSVM::train(const Mat& trainData, const Mat& responses, const Mat& varIdx=Mat(), const Mat& sampleIdx=Mat(), 
;;                   CvSVMParams params=CvSVMParams() )
;; bool cv_CvSVM_train5(CvSVM* self, Mat* trainData, Mat* responses, Mat* varIdx, Mat* sampleIdx, CvSVMParams* params)
(defcfun ("cv_CvSVM_train5" %svm-train) :boolean
  (self svm)
  (train-data mat)
  (responses mat)
  (var-idx mat)
  (sample-idx mat)
  (params svm-params))


(defun svm-train (self train-data responses &optional (var-idx (%mat) given-var-idx) (sample-idx (%mat) given-sample-idx)
					      (params (svm-params-0) given-params))
  (let ((return (%svm-train self train-data responses var-idx sample-idx params)))
    (if given-var-idx nil (del-mat var-idx))
    (if given-sample-idx nil (del-mat sample-idx))
    (if given-params nil (del-svm-params params))
    return))


(defun svm-type (self)
  (if (typep self 'cv-svm-params)
      (mem-ref (c-pointer self) :int)))


(defun (setf svm-type) (val self)
  (if (typep self 'cv-svm-params)
      (setf (mem-ref (c-pointer self) :int) val)))


(defun term-crit (self)
  (if (typep self 'cv-svm-params)
      (mem-ref (c-pointer self) '(:pointer (:struct term-criteria-struct))  64)))


(defun (setf term-crit) (val self)
  (if (typep self 'cv-svm-params)
      (setf (mem-ref (c-pointer self) '(:pointer (:struct term-criteria-struct)) 64) val)))


;;; Decision Trees


;; CvDTree:CvDTree()
;; CvDTree* cv_create_CvDTree() 
(defcfun ("cv_create_CvDTree" d-tree) d-tree)

;; CvDTree:CvDTree()
;; CvDTree* cv_create_CvDTree() 
(defcfun ("cv_create_CvDTree" make-d-tree) d-tree)


;; CvDTreeParams::CvDTreeParams()
;; CvDTreeParams* cv_create_CvDTreeParams()
(defcfun ("cv_create_CvDTreeParams" d-tree-params-0) d-tree-params)

;; CvDTreeParams::CvDTreeParams(int max_depth, int min_sample_count, float regression_accuracy, bool use_surrogates, 
;;                              int max_categories, int cv_folds, bool use_1se_rule, bool truncate_pruned_tree, const float* priors)
;; CvDTreeParams* cv_create_CvDTreeParams9(int max_depth, int min_sample_count, float regression_accuracy, bool use_surrogates, 
;;                                         int max_categories, int cv_folds, bool use_1se_rule, bool truncate_pruned_tree, 
;;                                         const float* priors)
(defcfun ("cv_create_CvDTreeParams9" d-tree-params-9) d-tree-params
  (max-depth :int)
  (min-sample-count :int)
  (regression-accuracy :float)
  (use-surrogates :boolean)
  (max-categories :int)
  (folds :int)
  (use-1se-rule :boolean)
  (truncate-pruned-tree :boolean)
  (priors :pointer))

(defun d-tree-params (&optional max-depth min-sample-count regression-accuracy use-surrogates max-categories folds use-1se-rule
			truncate-pruned-tree priors)
  (if max-depth
      (d-tree-params-9 max-depth min-sample-count regression-accuracy use-surrogates max-categories folds use-1se-rule
                      truncate-pruned-tree priors)
      (d-tree-params-0)))

(defun make-d-tree-params (&optional max-depth min-sample-count regression-accuracy use-surrogates max-categories folds use-1se-rule
			truncate-pruned-tree priors)
  (if max-depth
      (d-tree-params-9 max-depth min-sample-count regression-accuracy use-surrogates max-categories folds use-1se-rule
                      truncate-pruned-tree priors)
      (d-tree-params-0)))


;; CvDTreeNode* CvDTree::predict(const Mat& sample, const Mat& missingDataMask=Mat(), bool preprocessedInput=false ) const
;; CvDTreeNode* cv_CvDTree_predict3_0(CvDTree* self, Mat* sample, Mat* missingDataMask, bool preprocessedInput) 
(defcfun ("cv_CvDTree_predict3_0" %d-tree-predict) (:pointer (:struct d-tree-node))
  (self d-tree)
  (sample mat)
  (missing-data-mask mat)
  (preprocessed-input :boolean))

(defun d-tree-predict (self sample &optional (missing-data-mask (%mat) given-missing-data-mask) (preprocessed-input nil))
  (let ((return 
	  (%d-tree-predict self sample missing-data-mask preprocessed-input)))
    (if given-missing-data-mask nil (del-mat missing-data-mask))
    return))


;; bool CvDTree::train(const Mat& trainData, int tflag, const Mat& responses, const Mat& varIdx=Mat(), const Mat& sampleIdx=Mat(), 
;;                     const Mat& varType=Mat(), const Mat& missingDataMask=Mat(), CvDTreeParams params=CvDTreeParams() )
;; bool cv_CvDTree_train8(CvDTree* self, Mat* trainData, int tflag, Mat* responses, Mat* varIdx, Mat* sampleIdx, Mat* varType,
;;                        Mat* missingDataMask, CvDTreeParams* params)
(defcfun ("cv_CvDTree_train8" %d-tree-train) :boolean
  (self d-tree)
  (train-data mat)
  (tflag :int)
  (responses mat)
  (var-idx mat)
  (sample-idx mat)
  (var-type mat)
  (missing-data-mask mat)
  (params d-tree-params))

(defun d-tree-train (self train-data tflag responses &optional (var-idx (%mat) given-var-idx) (sample-idx (%mat) given-sample-idx) 
						       (var-type (%mat) given-var-type) (missing-data-mask (%mat) given-missing-data-mask) 
						       (params (d-tree-params) given-params))
  (let ((return 
	  (%d-tree-train self train-data tflag responses var-idx sample-idx var-type missing-data-mask params)))
    (if given-var-idx nil (del-mat var-idx))
    (if given-sample-idx nil (del-mat sample-idx))
    (if given-var-type nil (del-mat var-type))
    (if given-missing-data-mask nil (del-mat missing-data-mask))
    (if given-params nil (del-d-tree-params params))
    return))


;;; Neural Networks


;; CvANN_MLP::CvANN_MLP()
;; CvANN_MLP* cv_create_CvANN_MLP()
(defcfun ("cv_create_CvANN_MLP" ann-mlp-0) ann-mlp)

;; CvANN_MLP::CvANN_MLP(const CvMat* layerSizes, int activateFunc=CvANN_MLP::SIGMOID_SYM, double fparam1=0, double fparam2=0 )
;; CvANN_MLP* cv_create_CvANN_MLP4(Mat* layerSizes, int activateFunc, double fparam1, double fparam2) 
(defcfun ("cv_create_CvANN_MLP4" ann-mlp-4) ann-mlp
  (layer-sizes mat)
  (activate-func :int)
  (fparam1 :double)
  (fparam2 :double))

(defun ann-mlp (&optional layer-sizes (activate-func +ann-mlp-sigmoid-sym+) (fparam1 0d0) (fparam2 0d0))
  (if layer-sizes
      (ann-mlp-4 layer-sizes activate-func fparam1 fparam2)
      (ann-mlp-0)))

(defun make-ann-mlp (&optional layer-sizes (activate-func +ann-mlp-sigmoid-sym+) (fparam1 0d0) (fparam2 0d0))
  (if layer-sizes
      (ann-mlp-4 layer-sizes activate-func fparam1 fparam2)
      (ann-mlp-0)))

;; void CvANN_MLP::create(const Mat& layerSizes, int activateFunc=CvANN_MLP::SIGMOID_SYM, double fparam1=0, double fparam2=0 )
;; void cv_CvANN_MLP_create(CvANN_MLP* self, Mat* layerSizes, int activateFunc, double fparam1, double fparam2)
(defcfun ("cv_CvANN_MLP_create" %ann-mlp-create) ann-mlp
  (self ann-mlp)
  (layer-sizes mat)
  (activate-func :int)
  (fparam1 :double)
  (fparam2 :double))

(defun ann-mlp-create (self layer-sizes &optional (activate-func +ann-mlp-sigmoid-sym+) (fparam1 0d0) (fparam2 0d0))
  "Constructs MLP with the specified topology."
  (%ann-mlp-create self layer-sizes activate-func fparam1 fparam2))


;; float CvANN_MLP::predict(const Mat& inputs, Mat& outputs) const
;; float cv_CvANN_MLP_predict2_3(CvANN_MLP* self, Mat* inputs, Mat* outputs) 
(defun ann-mlp-predict (self arg1 arg2)
  "Predicts response(s) for the provided sample(s)"
  (foreign-funcall "cv_CvANN_MLP_predict2_3" :pointer (c-pointer self) 
		   :pointer (c-pointer arg1) 
		   :pointer (c-pointer arg2)
                   :float))


;; int CvANN_MLP::train(const Mat& inputs, const Mat& outputs, const Mat& sampleWeights, const Mat& sampleIdx=Mat(), 
;;                      CvANN_MLP_TrainParams params=CvANN_MLP_TrainParams(), int flags=0 )
;; int cv_CvANN_MLP_train6_0(CvANN_MLP* self, Mat* inputs, Mat* outputs, Mat* sampleWeights, Mat* sampleIdx, 
;;                           CvANN_MLP_TrainParams* params, int flags)
(defcfun ("cv_CvANN_MLP_train6_0" %ann-mlp-train) :int
  (self ann-mlp)
  (inputs mat)
  (ouputs mat)
  (sample-weights mat)
  (sample-idx mat)
  (params ann-mlp-train-params)
  (flags :int))

(defun ann-mlp-train (self inputs outputs sample-weights &optional (sample-idx (%mat) given-sample-idx) 
							   (params (ann-mlp-train-params) given-params) (flags 0))
  "Trains/updates MLP."
  (let ((return (%ann-mlp-train self inputs outputs sample-weights sample-idx params flags)))
    (if given-sample-idx nil (del-mat sample-idx))
    (if given-params nil (del-ann-mlp-train-params params))
    return))


;; CvANN_MLP_TrainParams::CvANN_MLP_TrainParams()
;; CvANN_MLP_TrainParams* cv_create_CvANN_MLP_TrainParams()
(defcfun ("cv_create_CvANN_MLP_TrainParams" ann-mlp-train-params-0) ann-mlp-train-params)

;; CvANN_MLP_TrainParams::CvANN_MLP_TrainParams(CvTermCriteria term_crit, int train_method, double param1, double param2=0 )
;; CvANN_MLP_TrainParams* cv_create_CvANN_MLP_TrainParams4(TermCriteria* term_crit, int train_method, double param1, double param2)
(defcfun ("cv_create_CvANN_MLP_TrainParams" ann-mlp-train-params-4) ann-mlp-train-params
  (term-crit term-criteria)
  (train-method :int)
  (param1 :double)
  (param2 :double))

(defun ann-mlp-train-params (&optional term-crit train-method param1 (param2 0))
       (if term-crit
	   (ann-mlp-train-params-4 term-crit train-method param1 param2)
	   (ann-mlp-train-params-0)))

(defun make-ann-mlp-train-params (&optional term-crit train-method param1 (param2 0))
       (if term-crit
	   (ann-mlp-train-params-4 term-crit train-method param1 param2)
	   (ann-mlp-train-params-0)))
