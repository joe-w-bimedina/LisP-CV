/*
* =====================================================================================
*
* Filename: excluded_functions.hpp
*
* Description: Functions that the generator outputs incorrectly, either by them entirely
* or by outputting them with incorrectly specified types.
*
* Version: 1.0
* Created: 04/13/2014 12:00:46 AM
* Revision: none
* Compiler: g++
*
* Author: Arjun Comar
*
* =====================================================================================
*/

#include <opencv2/c/opencv_generated.hpp>
#include <vector>
#include <opencv2/opencv.h>

using namespace std;


#define ADD_VEC_FUNC_HEADERS_0_0(t) \
    Vec2##t * cv_create_0_Vec2##t(); \
    Vec3##t * cv_create_0_Vec3##t(); \
    Vec4##t * cv_create_0_Vec4##t(); \

#define ADD_VEC_FUNC_HEADERS_0_1(t) \
    Vec6##t * cv_create_0_Vec6##t(); \

#define ADD_VEC_FUNC_HEADERS_0_2(t) \
    Vec8##t * cv_create_0_Vec8##t(); \

#define ADD_VEC_FUNC_HEADERS_1(t, tn) \
    Vec2##t * cv_create_Vec2##t(tn v0, tn v1); \
    Vec3##t * cv_create_Vec3##t(tn v0, tn v1, tn v2); \
    Vec4##t * cv_create_Vec4##t(tn v0, tn v1, tn v2, tn v3); \

#define ADD_VEC_FUNC_HEADERS_2(t, tn) \
    Vec6##t * cv_create_Vec6##t(tn v0,  tn v1, tn v2, tn v3. tn v4, tn v5); \

#define ADD_VEC_FUNC_HEADERS_3(t, tn) \
    Vec8##t * cv_create_Vec8##t(tn v0, tn v1, tn v2, tn v3, tn v4, tn v5, tn v6, tn v7); \

#define ADD_WRITE_FUNC_HEADERS_0(t, tn) \
typedef vector< tn > vector_##tn; \
    void cv_FileNode_write_number_##t(FileStorage* fs, String* name,  tn value); \

#define ADD_WRITE_FUNC_HEADERS_1(t, tn) \
    void cv_FileNode_write_pointer_##t(FileStorage* fs, String* name,  tn* value); \

#define ADD_READ_FUNC_HEADERS_0(t, tn) \
    void cv_FileNode_read_number_##t (FileNode* fs, tn value,  tn default_value); \

#define ADD_READ_FUNC_HEADERS_1(t, tn) \
    void cv_FileNode_read_pointer_##t(FileNode* fs, tn* value,  tn* default_value); \

#define ADD_READ_FUNC_HEADERS_2(t, tn) \
    void cv_FileNode_read_pointer_vkp(FileNode* node, tn* keypoints); \


extern "C" {
ADD_VEC_FUNC_HEADER_0_0(b);
ADD_VEC_FUNC_HEADER_0_0(d);
ADD_VEC_FUNC_HEADER_0_0(f);
ADD_VEC_FUNC_HEADER_0_0(i);
ADD_VEC_FUNC_HEADER_0_0(s);
ADD_VEC_FUNC_HEADER_0_0(w);
ADD_VEC_FUNC_HEADER_0_1(d);
ADD_VEC_FUNC_HEADER_0_1(f);
ADD_VEC_FUNC_HEADER_0_1(i);
ADD_VEC_FUNC_HEADER_0_2(i);
ADD_VEC_FUNC_HEADER_1(b, uchar);
ADD_VEC_FUNC_HEADER_1(d, double);
ADD_VEC_FUNC_HEADER_1(f, float);
ADD_VEC_FUNC_HEADER_1(i, int);
ADD_VEC_FUNC_HEADER_1(s, short);
ADD_VEC_FUNC_HEADER_1(w, ushort);
ADD_VEC_FUNC_HEADER_2(d, double);
ADD_VEC_FUNC_HEADER_2(f, float);
ADD_VEC_FUNC_HEADER_2(i, int);
ADD_VEC_FUNC_HEADER_3(i, int);
ADD_WRITE_FUNC_HEADERS_0(i, int);
ADD_WRITE_FUNC_HEADERS_0(f, float);
ADD_WRITE_FUNC_HEADERS_0(d, double);
ADD_WRITE_FUNC_HEADERS_1(s, String);
ADD_WRITE_FUNC_HEADERS_1(m, Mat);
ADD_WRITE_FUNC_HEADERS_1(vkp, vector_KeyPoint);
ADD_READ_FUNC_HEADERS_0(i, int);
ADD_READ_FUNC_HEADERS_0(f, float);
ADD_READ_FUNC_HEADERS_0(d, double);
ADD_READ_FUNC_HEADERS_1(s, String);
ADD_READ_FUNC_HEADERS_1(m, Mat);
int cv_Mat_set_rows(Mat* self, int val); 
int cv_Mat_set_cols(Mat* self, int val);
FlannBasedMatcher* cv_create_FlannBasedMatcher0();
int cv_Mat_set_Type(Mat* self, int val);
Mat* cv_PCA_get_eigenvectors(PCA* self);
Mat* cv_PCA_set_Eigenvectors(PCA* self, Mat* val);
Mat* cv_PCA_get_eigenvalues(PCA* self);
Mat* cv_PCA_set_Eigenvalues(PCA* self, Mat* val);
Mat* cv_PCA_get_Mean(PCA* self);
Mat* cv_PCA_set_Mean(PCA* self, Mat* val);
Mat* cv_PCA_BackProject1(PCA* self, Mat* vec);
void cv_PCA_BackProject2(PCA* self, Mat* vec, Mat* result);
Mat* cv_PCA_Project1(PCA* self, Mat* vec);
void cv_PCA_Project2(PCA* self, Mat* vec, Mat* result);
PCA* cv_create_PCA();
PCA* cv_create_PCA4(Mat* data, Mat* mean, int flags, double retainedVariance);
int cv_TermCriteria_getType(TermCriteria* self);
int cv_TermCriteria_set_Type(TermCriteria* self, int val);
int cv_TermCriteria_getMaxCount(TermCriteria* self);
int cv_TermCriteria_set_MaxCount(TermCriteria* self, int val);
double cv_TermCriteria_getEpsilon(TermCriteria* self);
double cv_TermCriteria_set_Epsilon(TermCriteria* self, double val);
void cv_circle_2(Mat* img, Point2f* center, int radius, Scalar* color, int thickness, int lineType, int shift);
void cv_RNG_fill(RNG* self, Mat* mat, int distType, Scalar* a, Scalar* b, bool saturateRange);
Mat* test(uchar* a, size_t len );
vector_Mat* std_carrayTovectorm2(Mat** a, size_t len);
vector_Mat1* std_carrayTovectorm1(Mat** a, size_t len);
Mat** std_vectorm_to_carray1( vector_Mat1* v );
int cv_Mat_checkVector(Mat* self, int elemChannels, int depth, bool requireContinuous);
double cv_Size_set_width(Size* self, double val);    
double cv_Size_set_height(Size* self, double val);
void cv_BackgroundSubtractorMOG2_getBackgroundImage(BackgroundSubtractorMOG2* self, Mat* backgroundImage);
void cv_Mat_create_typed(Mat* self, int rows, int cols, int type);
void cv_RotatedRect_setCenter(RotatedRect* self, Point* val);
void cv_RotatedRect_setSize(RotatedRect* self, Size* val);
float cv_RotatedRect_setAngle(RotatedRect* self, float val);
int cv_Rect_setWidth(Rect* self, int val);
int cv_Rect_setHeight(Rect* self, int val);
int cv_Rect_setX(Rect* self, int val);
int cv_Rect_setY(Rect* self, int val);
int cv_Point2i_setX(Point* self, int val);
int cv_Point2i_setY(Point* self, int val);
double cv_Point2d_setX(Point2d* self, double val);
double cv_Point2d_setY(Point2d* self, double val);
float cv_Point2f_setX(Point2f* self, float val);
float cv_Point2f_setY(Point2f* self, float val);
int cv_Point3i_setX(Point3i* self, int val);
int cv_Point3i_setY(Point3i* self, int val);
int cv_Point3i_setZ(Point3i* self, int val);
double cv_Point3d_setX(Point3d* self, double val);
double cv_Point3d_setY(Point3d* self, double val);
double cv_Point3d_setZ(Point3d* self, double val);
float cv_Point3f_setX(Point3f* self, float val);
float cv_Point3f_setY(Point3f* self, float val);
float cv_Point3f_setZ(Point3f* self, float val);
int cv_DMatch_getQueryIdx(DMatch* self);
int cv_DMatch_setQueryIdx(DMatch* self, int val);
int cv_DMatch_getTrainIdx(DMatch* self);
int cv_DMatch_setTrainIdx(DMatch* self, int val);
int cv_DMatch_getImgIdx(DMatch* self);
int cv_DMatch_setImgIdx(DMatch* self, int val);
float cv_DMatch_getDistance(DMatch* self); 
float cv_DMatch_setDistance(DMatch* self, float val);
Point2f* cv_KeyPoint_getPt(KeyPoint* self); 
void cv_KeyPoint_setPt(KeyPoint* self, Point2f* val);
float cv_KeyPoint_getSize(KeyPoint* self);
float cv_KeyPoint_setSize(KeyPoint* self, float val);
float cv_KeyPoint_getAngle(KeyPoint* self);
float cv_KeyPoint_setAngle(KeyPoint* self, float val);
float cv_KeyPoint_getResponse(KeyPoint* self);
float cv_KeyPoint_setResponse(KeyPoint* self, float val);
int cv_KeyPoint_getOctave(KeyPoint* self);
int cv_KeyPoint_setOctave(KeyPoint* self, int val);
int cv_KeyPoint_getClass_id(KeyPoint* self);
int cv_KeyPoint_setClass_id(KeyPoint* self, int val);
void cv_Mat_push_back(Mat* self, Mat* m);
Point* cv_Mat_at_Point_1(Mat* self, int i);
Point* cv_Mat_at_Point_2(Mat* self, int i, int j);
void cv_Mat_at_Point_set_Val_1(Mat* self, int i, Point* val);
void cv_Mat_at_Point_set_Val_2(Mat* self, int i, int j, Point* val);
Point2d* cv_Mat_at_Point2d_1(Mat* self, int i);
Point2d* cv_Mat_at_Point2d_2(Mat* self, int i, int j);
void cv_Mat_at_Point2d_set_Val_1(Mat* self, int i, Point2d* val);
void cv_Mat_at_Point2d_set_Val_2(Mat* self, int i, int j, Point2d* val);
Point2f* cv_Mat_at_Point2f_1(Mat* self, int i);
Point2f* cv_Mat_at_Point2f_2(Mat* self, int i, int j);
void cv_Mat_at_Point2f_set_Val_1(Mat* self, int i, Point2f* val);
void cv_Mat_at_Point2f_set_Val_2(Mat* self, int i, int j, Point2f* val);
Point3d* cv_Mat_at_Point3d_1(Mat* self, int i);
Point3d* cv_Mat_at_Point3d_2(Mat* self, int i, int j);
void cv_Mat_at_Point3d_set_Val_1(Mat* self, int i, Point3d* val);
void cv_Mat_at_Point3d_set_Val_2(Mat* self, int i, int j, Point3d* val);
Point3f* cv_Mat_at_Point3f_1(Mat* self, int i);
Point3f* cv_Mat_at_Point3f_2(Mat* self, int i, int j);
void cv_Mat_at_Point3f_set_Val_1(Mat* self, int i, Point3f* val);
void cv_Mat_at_Point3f_set_Val_2(Mat* self, int i, int j, Point3f* val);
Point3i* cv_Mat_at_Point3i_1(Mat* self, int i);
Point3i* cv_Mat_at_Point3i_2(Mat* self, int i, int j);
void cv_Mat_at_Point3i_set_Val_1(Mat* self, int i, Point3i* val);
void cv_Mat_at_Point3i_set_Val_2(Mat* self, int i, int j, Point3i* val);
char &cv_Mat_at_char_1(Mat* self, int i);
double &cv_Mat_at_double_1(Mat* self, int i);
float &cv_Mat_at_float_1(Mat* self, int i);
int &cv_Mat_at_int_1(Mat* self, int i);
short &cv_Mat_at_short_1(Mat* self, int i);
uchar &cv_Mat_at_uchar_1(Mat* self, int i);
uint &cv_Mat_at_uint_1(Mat* self, int i);
ushort &cv_Mat_at_ushort_1(Mat* self, int i);
char &cv_Mat_at_char_2(Mat* self, int i, int j);
double &cv_Mat_at_double_2(Mat* self, int i, int j);
float &cv_Mat_at_float_2(Mat* self, int i, int j);
int &cv_Mat_at_int_2(Mat* self, int i, int j);
short &cv_Mat_at_short_2(Mat* self, int i, int j);
uchar &cv_Mat_at_uchar_2(Mat* self, int i, int j);
uint &cv_Mat_at_uint_2(Mat* self, int i, int j);
ushort &cv_Mat_at_ushort_2(Mat* self, int i, int j);
char &cv_Mat_at_char_3(Mat* self, int i, int j, int k);
double &cv_Mat_at_double_3(Mat* self, int i, int j, int k);
float &cv_Mat_at_float_3(Mat* self, int i, int j, int k);
int &cv_Mat_at_int_3(Mat* self, int i, int j, int k);
short &cv_Mat_at_short_3(Mat* self, int i, int j, int k);
uchar &cv_Mat_at_uchar_3(Mat* self, int i, int j, int k);
uint &cv_Mat_at_uint_3(Mat* self, int i, int j, int k);
ushort &cv_Mat_at_ushort_3(Mat* self, int i, int j, int k);
Vec2b* cv_Mat_at_Vec2b_1(Mat* self, int i);
void cv_Mat_at_Vec2b_set_Val_1(Mat* self, int i, Vec2b* val);
Vec2b* cv_Mat_at_Vec2b_2(Mat* self, int i, int j);
void cv_Mat_at_Vec2b_set_Val_2(Mat* self, int i, int j, Vec2b* val);
Vec2d* cv_Mat_at_Vec2d_1(Mat* self, int i);
void cv_Mat_at_Vec2d_set_Val_1(Mat* self, int i, Vec2d* val);
Vec2d* cv_Mat_at_Vec2d_2(Mat* self, int i, int j);
void cv_Mat_at_Vec2d_set_Val_2(Mat* self, int i, int j, Vec2d* val);
Vec2f* cv_Mat_at_Vec2f_1(Mat* self, int i);
void cv_Mat_at_Vec2f_set_Val_1(Mat* self, int i, Vec2f* val);
Vec2f* cv_Mat_at_Vec2f_2(Mat* self, int i, int j);
void cv_Mat_at_Vec2f_set_Val_2(Mat* self, int i, int j, Vec2f* val);
Vec2i* cv_Mat_at_Vec2i_1(Mat* self, int i);
void cv_Mat_at_Vec2i_set_Val_1(Mat* self, int i, Vec2i* val);
Vec2i* cv_Mat_at_Vec2i_2(Mat* self, int i, int j);
void cv_Mat_at_Vec2i_set_Val_2(Mat* self, int i, int j, Vec2i* val);
Vec2s* cv_Mat_at_Vec2s_1(Mat* self, int i);
void cv_Mat_at_Vec2s_set_Val_1(Mat* self, int i, Vec2s* val);
Vec2s* cv_Mat_at_Vec2s_2(Mat* self, int i, int j);
void cv_Mat_at_Vec2s_set_Val_2(Mat* self, int i, int j, Vec2s* val);
Vec2w* cv_Mat_at_Vec2w_1(Mat* self, int i);
void cv_Mat_at_Vec2w_set_Val_1(Mat* self, int i, Vec2w* val);
Vec2w* cv_Mat_at_Vec2w_2(Mat* self, int i, int j);
void cv_Mat_at_Vec2w_set_Val_2(Mat* self, int i, int j, Vec2w* val);
Vec3b* cv_Mat_at_Vec3b_1(Mat* self, int i);
void cv_Mat_at_Vec3b_set_Val_1(Mat* self, int i, Vec3b* val);
Vec3b* cv_Mat_at_Vec3b_2(Mat* self, int i, int j); 
void cv_Mat_at_Vec3b_set_Val_2(Mat* self, int i, int j, Vec3b* val);
Vec3d* cv_Mat_at_Vec3d_1(Mat* self, int i);
void cv_Mat_at_Vec3d_set_Val_1(Mat* self, int i, Vec3d* val);
Vec3d* cv_Mat_at_Vec3d_2(Mat* self, int i, int j);
void cv_Mat_at_Vec3d_set_Val_2(Mat* self, int i, int j, Vec3d* val);
Vec3f* cv_Mat_at_Vec3f_1(Mat* self, int i);
void cv_Mat_at_Vec3f_set_Val_1(Mat* self, int i, Vec3f* val);
Vec3f* cv_Mat_at_Vec3f_2(Mat* self, int i, int j);
void cv_Mat_at_Vec3f_set_Val_2(Mat* self, int i, int j, Vec3f* val);
Vec3i* cv_Mat_at_Vec3i_1(Mat* self, int i);
void cv_Mat_at_Vec3i_set_Val_1(Mat* self, int i, Vec3i* val);
Vec3i* cv_Mat_at_Vec3i_2(Mat* self, int i, int j);
void cv_Mat_at_Vec3i_set_Val_2(Mat* self, int i, int j, Vec3i* val);
Vec3s* cv_Mat_at_Vec3s_1(Mat* self, int i);
void cv_Mat_at_Vec3s_set_Val_1(Mat* self, int i, Vec3s* val);
Vec3s* cv_Mat_at_Vec3s_2(Mat* self, int i, int j);
void cv_Mat_at_Vec3s_set_Val_2(Mat* self, int i, int j, Vec3s* val);
Vec3w* cv_Mat_at_Vec3w_1(Mat* self, int i);
void cv_Mat_at_Vec3w_set_Val_1(Mat* self, int i, Vec3w* val);
Vec3w* cv_Mat_at_Vec3w_2(Mat* self, int i, int j);
void cv_Mat_at_Vec3w_set_Val_2(Mat* self, int i, int j, Vec3w* val);
Vec4b* cv_Mat_at_Vec4b_1(Mat* self, int i);
void cv_Mat_at_Vec4b_set_Val_1(Mat* self, int i, Vec4b* val);
Vec4b* cv_Mat_at_Vec4b_2(Mat* self, int i, int j);
void cv_Mat_at_Vec4b_set_Val_2(Mat* self, int i, int j, Vec4b* val);
Vec4d* cv_Mat_at_Vec4d_1(Mat* self, int i);
void cv_Mat_at_Vec4d_set_Val_1(Mat* self, int i, Vec4d* val);
Vec4d* cv_Mat_at_Vec4d_2(Mat* self, int i, int j);
void cv_Mat_at_Vec4d_set_Val_2(Mat* self, int i, int j, Vec4d* val);
Vec4f* cv_Mat_at_Vec4f_1(Mat* self, int i);
void cv_Mat_at_Vec4f_set_Val_1(Mat* self, int i, Vec4f* val);
Vec4f* cv_Mat_at_Vec4f_2(Mat* self, int i, int j);
Vec4i* cv_Mat_at_Vec4i_1(Mat* self, int i);
void cv_Mat_at_Vec4i_set_Val_1(Mat* self, int i, Vec4i* val);
Vec4i* cv_Mat_at_Vec4i_2(Mat* self, int i, int j);
void cv_Mat_at_Vec4i_set_Val_2(Mat* self, int i, int j, Vec4i* val);
Vec4s* cv_Mat_at_Vec4s_1(Mat* self, int i);
void cv_Mat_at_Vec4s_set_Val_1(Mat* self, int i, Vec4s* val);
Vec4s* cv_Mat_at_Vec4s_2(Mat* self, int i, int j);
void cv_Mat_at_Vec4s_set_Val_2(Mat* self, int i, int j, Vec4s* val);
Vec4w* cv_Mat_at_Vec4w_1(Mat* self, int i);
void cv_Mat_at_Vec4w_set_Val_1(Mat* self, int i, Vec4w* val);
Vec4w* cv_Mat_at_Vec4w_2(Mat* self, int i, int j);
void cv_Mat_at_Vec4w_set_Val_2(Mat* self, int i, int j, Vec4w* val)
const float* cv_CvSVM_get_support_vector(SVM* self, int i);
CvMat* cv_Mat_to_CvMat(Mat* self);
CvTermCriteria cv_TermCriteria_to_CvTermCriteria(TermCriteria* self);
Mat* cv_imdecode_2(vector_uchar* buf, int flags);
bool cv_imencode_2(const char* ext, Mat* img, vector_uchar* buf, vector_int* params);
int CV_FOURCC(char c1, char c2, char c3, char c4);
void cv_groupRectangles_3(vector_Rect* rectList, int groupThreshold, double eps);
void cv_FileNode_read_pointer_vkp (FileNode* fs, vector_KeyPoint* keypoints):
FileNode * cv_FileNode_assignVal(FileStorage * fs, string * nodename);
FileStorage* cv_FileStorage_write_String(FileStorage* fs, String* value);
Scalar* cv_create_Scalar0();
Scalar* cv_create_Scalar4(double val0, double val1, double val2, double val3);
CvDTreeParams* cv_create_CvDTreeParams();
CvDTreeParams* cv_create_CvDTreeParams9(int max_depth, int min_sample_count, float regression_accuracy, bool use_surrogates, int max_categories, int cv_folds, bool use_1se_rule, bool truncate_pruned_tree, const float* priors);
Mat* cv_Mat_with_Range(Mat* self, Range* rowRange, Range* colRange);
Range* cv_create_Range(int _start, int _end);
Range* cv_create_RangeAll();
bool cv_Range_empty(Range* self);
int cv_Range_size(Range* self);
int cv_Range_getstart(Range* self);
int cv_Range_getend(Range* self);
void cv_HOGDescriptor_detectMultiScale9_2(HOGDescriptor* self, Mat* img, vector_Rect* foundLocations, double hitThreshold, Size* winStride, Size* padding, double scale, double finalThreshold, bool useMeanshiftGrouping);
void cv_HOGDescriptor_setSVMDetector2(HOGDescriptor* self, vector_float* _svmdetector);
CvSVMParams* cv_create_CvSVMParams(); 
CvSVMParams* cv_create_CvSVMParams10(int svm_type, int kernel_type, double degree, double gamma, double coef0, double Cvalue, double nu, double p, CvMat* class_weights, CvTermCriteria term_crit);
void cv_displayOverlay(String* winname, String* text, int delayms);
MatExpr* cv_abs(Mat* m);
float cv_RotatedRect_angle(RotatedRect* self);
Rect* cv_RotatedRect_boundingRect(RotatedRect* self);
MatExpr* cv_Mat_div(Mat* m1, Mat* m2);
FeatureDetector* cv_FeatureDetector_create2(FeatureDetector* self, const char* detectorType);
Scalar* cv_create_morphologyDefaultBorderValue();
bool cv_findChessboardCorners2(Mat* image, Size* patternSize, vector_Point2f* corners, int flags);
void cv_cornerSubPix2(Mat* image, vector_Point2f* corners, Size* winSize, Size* zeroZone, TermCriteria* criteria);
void cv_drawChessboardCorners2(Mat* image, Size* patternSize, vector_Point2f* corners, bool patternWasFound);
TermCriteria* cv_create_TermCriteria();
TermCriteria* cv_create_TermCriteria3(int type, int maxCount, double epsilon);
MatExpr* cv_Mat_sub(Mat* m1, Mat* m2);
RNG* cv_create_RNG();
RNG* cv_create_RNG_state(uint64 state);
double cv_RNG_uniform_double(RNG* self, double a, double b);
float cv_RNG_uniform_float(RNG* self, float a, float b);
int cv_RNG_uniform_int(RNG* self, int a, int b);
uchar* cv_Mat_get_Data(Mat* self);
Mat* cv_Mat_get_ROI(Mat* self, Rect* roi);
Mat* cv_imread2(const char* filename, int flags);
bool cv_imwrite2(const char* filename, Mat* img, vector_int* params);
FeatureDetector* cv_FeatureDetector_create2(FeatureDetector* self, const char* detectorType);
Size2f* cv_create_Size2f();
Size2f* cv_create_Size2f2(float width, float height);
Size2f* cv_Size_assignTo(Size2f* self, Size2f* other);
Size2f* cv_Size2f_fromPoint2f(Point2f* p);
float cv_Size2f_area(Size2f* self);
float cv_Size2f_width(Size2f* self);
float cv_Size2f_height(Size2f* self);
void cv_delete_CvMat(CvMat* self);
void cv_delete_BFMatcher(BFMatcher* self);
void cv_delete_BRISK(BRISK* self);
void cv_delete_CascadeClassifier(CascadeClassifier* self);
void cv_delete_CvANN_MLP(CvANN_MLP* self);
void cv_delete_CvANN_MLP_TrainParams(CvANN_MLP_TrainParams* self);
void cv_delete_CvNat(CvMat* self);
void cv_delete_DescriptorExtractor(DescriptorExtractor* self);
void cv_delete_DescriptorMatcher(DescriptorMatcher* self);
void cv_delete_DMatch(DMatch* ptr);
void cv_delete_CvDTree(CvDTree* self);
void cv_delete_CvDTreeParams(CvDTreeParams* self);
void cv_delete_FastFeatureDetector(FastFeatureDetector* self);
void cv_delete_FileNode(FileNode* self);
void cv_delete_FileStorage(FileStorage* self);
void cv_delete_FlannBasedMatcher(FlannBasedMatcher* self); 
void cv_delete_HOGDescriptor(HOGDescriptor* self);
void cv_delete_KeyPoint(KeyPoint* self);
void cv_delete_CvKNearest(CvKNearest* self);
void cv_delete_CvNormalBayesClassifier(CvNormalBayesClassifier* self);
void cv_delete_PCA(PCA* self); 
void cv_delete_Point(Point* self);
void cv_delete_Point2d(Point2d* self);
void cv_delete_Point2f(Point2f* self);
void cv_delete_Point3d(Point3d* self);
void cv_delete_Point3f(Point3f* self);
void cv_delete_Point3i(Point3i* self);
void cv_delete_Range(Range* self);
void cv_delete_Rect(Rect* self);
void cv_delete_RNG(RNG* self);
void cv_delete_RotatedRect(RotatedRect* self);
void cv_delete_Scalar(Scalar* self);
void cv_delete_Size(Size* self);
void cv_delete_Size2f(Size2f* self);
void cv_delete_SURF(SURF* self);
void cv_delete_CvSVM(CvSVM* self);
void cv_delete_CvSVMParams(CvSVMParams* self);
void cv_delete_TermCriteria(TermCriteria* self);
void cv_delete_Vec2b(Vec2b* self); 
void cv_delete_Vec3b(Vec3b* self);
void cv_delete_Vec4b(Vec4b* self); 
void cv_delete_Vec2d(Vec2d* self);
void cv_delete_Vec3d(Vec3d* self);
void cv_delete_Vec4d(Vec4d* self);
void cv_delete_Vec6d(Vec6d* self);
void cv_delete_Vec2f(Vec2f* self);
void cv_delete_Vec3f(Vec3f* self);
void cv_delete_Vec4f(Vec4f* self); 
void cv_delete_Vec6f(Vec6f* self);
void cv_delete_Vec2i(Vec2i* self);
void cv_delete_Vec3i(Vec3i* self);
void cv_delete_Vec4i(Vec4i* self);
void cv_delete_Vec6i(Vec6i* self);
void cv_delete_Vec8i(Vec8i* self); 
void cv_delete_Vec2s(Vec2s* self);
void cv_delete_Vec3s(Vec3s* self);
void cv_delete_Vec4s(Vec4s* self);
void cv_delete_Vec2w(Vec2w* self); 
void cv_delete_Vec3w(Vec3w* self);
void cv_delete_Vec4w(Vec4w* self);
void cv_delete_VideoCapture(VideoCapture* self);
void cv_delete_VideoWriter(VideoWriter* self);
}
