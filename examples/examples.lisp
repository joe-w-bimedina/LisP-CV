========================================================================================================================================
========================================================================================================================================
========================================================================================================================================
========================================================================================================================================
========================================================================================================================================
========================================================================================================================================
========================================================================================================================================
========================================================================================================================================
========================================================================================================================================
========================================================================================================================================
========================================================================================================================================

EXAMPLES.LISP

Documentation and Examples(In process). For now, if you want to know if a Lisp binding exists 
for a specified OpenCV C++ function search this file for the OpenCV C++ function name to find 
its Lisp name, documentation and an example program. All examples written inside a DEFUN are 
named by the Lisp function name followed by "-EXAMPLE", e.g. MAT-EXAMPLE for the function MAT, 
to make finding them easier in this file. If an example is not written inside a DEFUN, e.g. if 
the MAT example was not written inside a DEFUN, the title MAT-EXAMPLE, would still be typed above 
it to make locating the example in this file easier. Note: Implementing this is still in process.


There are 3 major types of memory management, manual, with-* macros and Trivial Garbage finalizers
Most examples so far use manual memory management, which is unsafe, but long-lived and fast. I'll 
be adding some examples from now on, using the new with-* macro syntax as well as examples that use 
Trivial Garbage finalizers. Trivial Garbage finalizers automatically free memory without having to 
use with-* macros or manual memory management, but, though they are long-lived and safe, are a little 
slower than with-* macros or manual MM. I'll be offering all three forms of memory management in this 
library as well as provide many, many examples of each type. For reference, here is an example that 
shows the camera output in a window using the with-* macro syntax(See MAT-EXAMPLE in this file for 
an example that uses TG finalizers):


(defun with-macro-example (&optional 
			     (cam *camera-index*) 
			     (width *default-width*)
			     (height *default-height*))

  (with-captured-camera (cap cam :width width :height height)
    (if (not (is-opened cap)) 
	(return-from with-macro-example 
	  (format t "Cannot open the video camera")))      
    (let ((window-name "WITH-MACRO Example"))
      (format t "~%Frame Size : ~ax~a~%~%" 
	      (get* cap +cap-prop-frame-width+)
	      (get* cap +cap-prop-frame-height+))
      (with-named-window (window-name +window-normal+)
	(move-window window-name 759 175)
	(with-mat ((frame (mat)))
	  (loop
	     (read cap frame)
	     (imshow window-name frame)
	     (let ((c (wait-key 33)))
	       (when (= c 27)
		 (return)))))))))

========================================================================================================================================
#CORE - #BASIC STRUCTURES:
========================================================================================================================================

========================================================================================================================================
#ADD
========================================================================================================================================

Adds two matrices.

C++: MatExpr + operator

LISP-CV: (ADD (M1 MAT) (M2 MAT)) => MAT-EXPR


    Parameters:	

        M1 - A matrix.

        M2 - A matrix.


The function ADD adds the elements of matrix M1 to the elements of matrix M2 in order. Both 
matrices must have the same number of rows and columns. You may need to coerce the result of 
ADD, the return value, back to type MAT with the function (FORCE), (or the shorthand version 
(>>)) to use in other functions. 


(defun add-example ()

  "Matrix M1 and M2 are added together with the 
   function ADD. Matrix M1, M2 and RESULT are t-
   hen printed."

  (with-object ((data (alloc :uint '(1 2 3 4 5 6 7 8 9))))
    (with-mat ((m1 (mat 3 3 +32s+ data))
	       (m2 (mat 3 3 +32s+ data)))
      (with-mat-expr ((result (add m1 m2)))
	(format t "~%M1:~%~%")
	(print-mat m1)
	(format t "~%M2:~%~%")
	(print-mat m2)
	(format t "~%RESULT~%~%")
	(with-mat ((forced-result (>> result)))
	  (print-mat forced-result)
	  (format t "~%"))))))


========================================================================================================================================
#ADJUST-ROI
========================================================================================================================================

Adjusts a submatrix size and position within the parent matrix.

C++: Mat& Mat::adjustROI(int dtop, int dbottom, int dleft, int dright)

LISP-CV: (ADJUST-ROI (SELF MAT) (DTOP :INT) (DBOTTOM :INT) (DLEFT :INT) (DRIGHT :INT)) => MAT

    Parameters:	

        SELF - A Matrix

        DTOP - Shift of the top submatrix boundary upwards.

        DBOTTOM - Shift of the bottom submatrix boundary downwards.

        DLEFT - Shift of the left submatrix boundary to the left.

        DRIGHT - Shift of the right submatrix boundary to the right.

The method is complimentary to the function (LOCATE-ROI). The typical use of these functions is to 
determine the submatrix position within the parent matrix and then shift the position. Typically, it 
can be required for filtering operations when pixels outside of the ROI should be taken into account. 
When all the method parameters are positive, the ROI needs to grow in all directions by the specified 
amount, for example:

(ADJUST-ROI A 2 2 2 2)

In this example, the matrix size is increased by 2 elements in each direction. The matrix is shifted 
by 2 elements to the left and 2 elements up, which brings in all the necessary pixels for filtering 
with the 5x5 kernel.

ADJUST-ROI forces the adjusted ROI to be inside of the parent matrix that is in the boundaries of the 
adjusted ROI are constrained by boundaries of the parent matrix. For example, if the submatrix A is 
located in the first row of a parent matrix and you called (ADJUST-ROI A 2 2 2 2) then A will not be 
increased in the upward direction.

The function is used internally by the OpenCV filtering functions, like (FILTER-2D) , morphological 
operations, and so on.

See also:

(COPY-MAKE-BORDER)


(defun adjust-roi-example (&optional 
			     (cam *camera-index*) 
			     (width *default-width*)
			     (height *default-height*))
  ;;Set camera feed to CAP and set its width and height
  (with-captured-camera (cap cam :width width :height height)
    (let ((window-name-1 "Original FRAME - ADJUST-ROI Example")
	  (window-name-2 "Region of interest - ADJUST-ROI Example")
	  (window-name-3 "FRAME readjusted to original dimensions - ADJUST-ROI Example"))
      (if (not (is-opened cap)) 
	  (return-from adjust-roi-example 
	    (format t "Cannot open the video camera")))
      ;;Print width and height of CAP
      (format t "~%Frame Size : ~ax~a~%~%" 
	      (get* cap +cap-prop-frame-width+)
	      (get* cap +cap-prop-frame-height+))
      (with-named-window (window-name-1 +window-normal+)
	(with-named-window (window-name-2 +window-normal+)
	  (with-named-window (window-name-3 +window-normal+)
	    (move-window window-name-1 310 175)
	    (move-window window-name-2 760 175)
	    (move-window window-name-3 1210 175)
	    (with-mat ((frame (mat)))
	      ;;Create rectangle RECT
	      (with-rect ((rect (rect (round (/ width 4)) 
				      (round (/ height 4))  
				      (round (/ width 2)) 
				      (round (/ height 2)))))
		(loop

		   ;;Set camera feed to FRAME
		   (read cap frame)
		   ;;Show original FRAME in window
		   (imshow window-name-1 frame)
		   ;;Set FRAME region of interest to RECT, half 
		   ;;the size of FRAME, positioned in the middle 
		   ;;of FRAME
		   (with-mat ((frame (roi frame rect)))
		     ;;Show adjusted FRAME in window
		     (imshow window-name-2 frame)
		     ;;Readjust frame back to original dimensions
		     (with-mat ((adjusted-roi (adjust-roi frame 120 120 160 160)))
		       ;;Show readjusted FRAME in a window
		       (imshow window-name-3 frame)))	    
		       (let ((c (wait-key 33)))
			 (when (= c 27)
			   (return))))))))))))

========================================================================================================================================
#MAT-AT-<type-name>
========================================================================================================================================

Returns a reference to the specified array element.

Note: The name MAT-AT is used in the documentation to refer to the binding for the "at" members of 
the OpenCV Mat class because it is more descriptive and it is easier to search for in this file. The 
AT-<type-name> functions and the @ or AT macros(below) may also be used to call these bindings.


C++: template<typename T> T& Mat::at(int i) const

C++: template<typename T> T& Mat::at(int i, int j)

C++: template<typename T> T& Mat::at(int i, int j, int k)


Note: The 12 macros, @ and AT, directly below, have the same functionality. They provide the same 
functionality as the lowest 12 AT-<type-name> and MAT-AT-<typename> functions as well as the ability 
to set and retrieve the elements of vectors and to mimic the behavior of CFFI's MEM-AREF (with some 
exceptions). Search <hashtag>@ in this file for more details on the @ macro.


LISP-CV: (@ (TYPE KEYWORD) (SELF MAT) &OPTIONAL ((I :INT) 0)) => <type-name>

LISP-CV: (@ (TYPE KEYWORD) (SELF MAT) &OPTIONAL ((I :INT) 0) (J :INT)) => <type-name>

LISP-CV: (@ (TYPE KEYWORD) (SELF MAT) &OPTIONAL ((I :INT) 0) (J :INT) (K :INT)) => <type-name>


LISP-CV: (SETF (@ (TYPE KEYWORD) (SELF MAT) &OPTIONAL ((I :INT) 0)) NEW-VALUE) => <type-name>

LISP-CV: (SETF (@ (TYPE KEYWORD) (SELF MAT) &OPTIONAL ((I :INT) 0) (J :INT)) NEW-VALUE) => <type-name>

LISP-CV: (SETF (@ (TYPE KEYWORD) (SELF MAT) &OPTIONAL ((I :INT) 0) (J :INT) (K :INT)) NEW-VALUE) => <type-name>


LISP-CV: (AT (TYPE KEYWORD) (SELF MAT) &OPTIONAL ((I :INT) 0)) => <type-name>

LISP-CV: (AT (TYPE KEYWORD) (SELF MAT) &OPTIONAL ((I :INT) 0) (J :INT)) => <type-name>

LISP-CV: (AT (TYPE KEYWORD) (SELF MAT) &OPTIONAL ((I :INT) 0) (J :INT) (K :INT)) => <type-name>


LISP-CV: (SETF (AT (TYPE KEYWORD) (SELF MAT) &OPTIONAL ((I :INT) 0)) NEW-VALUE) => <type-name>

LISP-CV: (SETF (AT (TYPE KEYWORD) (SELF MAT) &OPTIONAL ((I :INT) 0) (J :INT)) NEW-VALUE) => <type-name>

LISP-CV: (SETF (AT (TYPE KEYWORD) (SELF MAT) &OPTIONAL ((I :INT) 0) (J :INT) (K :INT)) NEW-VALUE) => <type-name>


LISP-CV: (AT-<type-name> (SELF MAT) &OPTIONAL ((I :INT) 0)) => <type-name>

LISP-CV: (AT-<type-name> (SELF MAT) &OPTIONAL ((I :INT) 0) (J :INT)) => <type-name>

LISP-CV: (AT-<type-name> (SELF MAT) &OPTIONAL ((I :INT) 0) (J :INT) (K :INT)) => <type-name>


LISP-CV: (SETF (AT-<type-name> (SELF MAT) &OPTIONAL ((I :INT) 0)) NEW-VALUE) => <type-name>

LISP-CV: (SETF (AT-<type-name> (SELF MAT) &OPTIONAL ((I :INT) 0) (J :INT)) NEW-VALUE) => <type-name>

LISP-CV: (SETF (AT-<type-name> (SELF MAT) &OPTIONAL ((I :INT) 0) (J :INT) (K :INT)) NEW-VALUE) => <type-name>


LISP-CV: (MAT-AT-<type-name> (SELF MAT) &OPTIONAL ((I :INT) 0)) => <type-name>

LISP-CV: (MAT-AT-<type-name> (SELF MAT) &OPTIONAL ((I :INT) 0) (J :INT)) => <type-name>

LISP-CV: (MAT-AT-<type-name> (SELF MAT) &OPTIONAL ((I :INT) 0) (J :INT) (K :INT)) => <type-name>


LISP-CV: (SETF (MAT-AT-<type-name> (SELF MAT) &OPTIONAL ((I :INT) 0)) NEW-VALUE) => <type-name>

LISP-CV: (SETF (MAT-AT-<type-name> (SELF MAT) &OPTIONAL ((I :INT) 0) (J :INT)) NEW-VALUE) => <type-name>

LISP-CV: (SETF (MAT-<type-name> (SELF MAT) &OPTIONAL ((I :INT) 0) (J :INT) (K :INT)) NEW-VALUE) => <type-name>


   The typenames associated with AT include:
 
      uchar    point     vec2b   scalar
      char     point2d   vec2d
      ushort   point2f   vec2f
      short    point3d   vec2i
      int      point3f   vec2s
      float              vec2w
      double             vec3b
                         vec3d
                         vec3f
                         vec3i
                         vec3s
                         vec3w
                         vec4b
                         vec4d
                         vec4f
                         vec4i
                         vec4s 
                         vec4w  

Note: More typenames are available when you are using the MEM-AREF functionality 
of the @ and AT macros. Search <hashtag>@ in this file for more information.

    Parameters:     
 
        I - Index along the dimension 0
 
        J - Index along the dimension 1

        k - Index along the dimension 2

 
Returns a specified array element. 
 
Note that the variants with a single index (I) can be used to access elements of single-row or
single-column 2-dimensional arrays. That is, if, for example, A is a 1 x N floating-point matrix 
and B is an M x 1 int matrix, you can simply write (@ :FLOAT A (+ K 4)) and (@ :INT B (+ (* 2 I) 1)) 
instead of (@ :FLOAT A 0 (+ K 4)) and (@ :INT B (+ (* 2 I) 1) 0), respectively. 

Note: When using the @ macro, instead of writing (AT-<type-name> A 0 0) to access the element at 
position 0x0 of matrix A, you would enter the <type-name> as a keyword as so: (@ :<type-name> A 0 0) 
Also note, when using the @ macro, it's a bit slower than using the AT-<type-name> or MAT-AT-<type-name> 
functions. Try using the $ macro to time the functions to get an idea of where you want to use which. I'll 
be speeding up the @ macro very soon when I redesign the low-level functions of this library to be generated 
by the CLASP compiler, instead of CFFI. You can find some more information on the CLASP compiler, invented by 
Dr. Chris Shafmeister here:

http://drmeister.wordpress.com/2014/07/06/why-did-i-write-the-clasp-compiler/


The example below initializes a Hilbert matrix:
 
(defun mat-at-example ()
  (with-mat ((h (mat 5 5 +64f+)))
    (dotimes (i (rows h))
      (dotimes (j (cols h))
	(setf (@ :double h i j) (/ 1d0 (+ i j 1)))))
    (print-mat h))) 

========================================================================================================================================
#CHANNELS
========================================================================================================================================

Returns the number of matrix channels.

C++: int Mat::channels() const

LISP-CV: (CHANNELS (SELF MAT)) => :INT

    Parameters:	

        SELF - A matrix.  

This function returns the number of matrix channels.


(defun channels-example (filename)

  "All BRG images are 3 channel,(BLUE, GREEN, RED). When 
   you convert an image to grayscale you also convert it 
   to a 1 channel image. This example shows that with th-
   e function CVT-COLOR and the function CHANNELS."

  ;; Read image
  (with-mat ((img (imread filename 1)))
    (if (eq 1 (channels img)) 
	(return-from channels-example 
	  (format t "Must load full color image")))
    (let ((window-name-1 "Original image - CHANNELS Example")
	  (window-name-2 "Grayscale image - CHANNELS Example"))
      (with-named-window (window-name-1 +window-normal+)
	(with-named-window (window-name-2 +window-normal+)	
	  (move-window window-name-1 514 175)
	  (move-window window-name-2 966 175)
	  ;;Print the original number of channels of IMG
	  (format t "~%The original number of channels of IMG = ~a~%~%" 
		  (channels img))
	  (imshow window-name-1 img)
	  ;;Convert IMG to a grayscale image
	  (cvt-color img img +bgr2gray+)
	  ;;Print the number of channels of a grayscale IMG
	  (format t "Grayscale IMG number of channels = ~a~%~%" 
		  (channels img)) 
	  (imshow window-name-2 img)
	  (loop
	     (let ((c (wait-key 33)))
	       (when (= c 27)
		 (return)))))))))


========================================================================================================================================
#CLONE
========================================================================================================================================

Creates a full copy of a matrix and the underlying data or a full copy of a RECT object. 

C++: Mat Mat::clone() const

LISP-CV: (CLONE (SELF MAT)) => MAT

C: Rect* cv_Rect_clone(Rect* self) 

LISP-CV: (CLONE (SELF RECT)) => RECT


    Parameters:	

        SELF - Pointer to a matrix or a rectangle.

MAT:

This method creates a full copy of array. The original (STEP*), is not taken into account. So, 
the array copy is a continuous array occupying (* (TOTAL) (ELEM-SIZE)) bytes.

Note (STEP*) is a binding for the OpenCV Mat class 'step[]' member.

RECT:

This method creates a full copy of a RECT object. It is a convenience function for creating a clone 
of a RECT object created in C and bound in Lisp.

Note: See RECT-EXAMPLE in this file for an example that uses this CLONE method on a RECT object.


(defun clone-example ()

  ;Create data
  (with-object ((m1-data (alloc :float '(53.0f0 62.0f0 85.0f0 64.0f0 23.0f0 
					 97.0f0 52.0f0 16.0f0 12.0f0))))
    ;Create matrix M1 and fill it with data
    (with-mat ((m1 (mat 3 3 +32f+ m1-data))
	       ;Create a clone of matrix M1
	       (m2 (clone m1)))
      (format t "~%M2 = ~%~%")
      ;Print the elements of natrix M2 in a loop
      (dotimes (i (rows m2))
	(dotimes (j (cols m2))
	  ;AT retrieves elements of M2, FORMAT 
	  ;prints the elements to the screen 
	  (format t "~a" (@ :float m2 i j))
	  (princ #\Space))
	(princ #\Newline))
      (format t "~%"))))

========================================================================================================================================
#COL-RANGE
========================================================================================================================================

Creates a matrix header for the specified column span.

C++: Mat Mat::colRange(int startcol, int endcol) const

LISP-CV: (COL-RANGE (SELF MAT) (STARTCOL :INT) (ENDCOL :INT)) => MAT


    Parameters:	

        SELF - A matrix

        STARTCOL - An inclusive 0-based start index of the column span.

        ENDCOL - An exclusive 0-based ending index of the column span.

    
The method makes a new header for the specified column span of the matrix. Similarly to (ROW) and 
(COL) functions, this is an O(1) operation.


(defun col-range-example ()
  ;;Create matrix data
  (with-object ((data (alloc :uchar '(1 2 3 4 5 6 7 8 9))))
    ;;Create matrix
    (with-mat ((mat (mat 3 3 +8u+ data)))
      (princ #\Newline)
      ;;Print matrix normally by 
      ;;accessing entire matrix
      (dotimes (i (rows mat))
	(dotimes (j (cols mat))
	  (format t "~a" (@ :uchar mat i j))
	  (princ #\Space))
	(princ #\Newline))
      (format t "~%~%")
      ;;Retrieve all 3 columns of MAT 
      ;;with COL-RANGE to print matrix
      ;;Note: The 't:' prefix enables 
      ;;automatic finalization.
      (dotimes (i (rows mat))
	(dotimes (j (cols mat))
	  (format t "~a" (@ :uchar
			    (t:col-range mat 0 (cols mat)) 
			    i j))
	  (princ #\Space))
	(princ #\Newline))
      (format t "~%"))))

========================================================================================================================================
#COLS
========================================================================================================================================

Returns number or cols in MAT.

C++: int rows, cols

LISP-CV:  (COLS (SELF MAT)) => :INT


    Parameters:	

        SELF - A matrix(MAT).


The function COLS finds the number of columns in a matrix or -1 when the array has more than 2 dime-
nsions. 


(defun cols-example ()

  "Uses COLS to find the number of columns in the matrix MAT"

  (with-mat ((mat (mat 3 4 +64f+ (t:scalar 5))))
    (format t "~%The number of columns in MAT = ~a~%~%" (cols mat))))


========================================================================================================================================
#COPY-TO
========================================================================================================================================

Copies the matrix to another one.

C++: void Mat::copyTo(OutputArray m) const

LISP-CV: (COPY-TO (SELF MAT) (M MAT)) => :VOID

C++: void Mat::copyTo(OutputArray m, InputArray mask) const

LISP-CV: (COPY-TO (SELF MAT) (M MAT) (MASK MAT)) => :VOID


    Parameters:	

        SELF - A matrix.         

        M - Destination matrix. If it does not have a proper size or type before the operation, it 
            is reallocated.

        MASK - Operation mask. Its non-zero elements - which matrix elements need to be copied.


The method copies the matrix data to another matrix. Before copying the data, the method invokes:

m.create(this->size(), this->type()); (On the C++ side)

So that the destination matrix is reallocated if needed. While (COPY-TO M M) works flawlessly, the 
function does not handle the case of a partial overlap between the source and destination matrices. 
When the operation mask is specified, and the (CREATE) call shown above reallocated the matrix, the 
newly allocated matrix is initialized with all zeros before copying the data.


Example 1:

(defun copy-to-example-1 ()
  ;; initialize data for matrices
  (with-object ((data (alloc :int '(10 20 30 40))))
    ;; initialize MAT-1 with DATA.
    (with-mat ((mat-1 (mat 2 2 +32s+ data))
	       ;; initialize MAT-2, a second, 
	       ;; identical matrix with DATA
	       (mat-2 (mat 2 2 +32s+ data))
	       ;; create empty matrices M-1 and M-2
	       (m-1 (mat))
	       (m-2 (mat))
	       ;; create a mask for MAT-2 COPY-TO 
	       ;; operation, an identity matrix. 
	       ;; its non-zero elements indicate 
	       ;; which matrix elements to copy
	       (mask (mat-eye 2 2 +8u+)))
      ;; print contents of MAT-1.
      (format t "~%MAT-1:~%~%")
      (print-mat mat-1)
      (format t "~%")
      ;; copy data from MAT-1 to M-1.
      (copy-to mat-1 m-1)
      ;; print contents of of M-1.
      (format t "M-1:~%~%")
      (print-mat m-1)
      (format t "~%")
      ;; print contents of MAT-2.
      (format t "MAT-2:~%~%")
      (print-mat mat-2)
      (format t "~%")
      ;; print contents of MASK.
      (format t "MASK:~%~%")
      (print-mat mask)
      (format t "~%")
      ;; copy data from MAT-2 
      ;; to M-2 using mask.
      (copy-to mat-2 m-2 mask)
      ;; print final contents of M-2.
      (format t "M-2~%~%")
      (print-mat m-2)
      (format t "~%"))))


Example 2:

(defun copy-to-example-2 (&optional (cam 0) 
			    (width *default-width*)
			    (height *default-height*))

  "In this COPY-TO example, we use the output of CANNY, 
  a binary image, as the MASK parameter of COPY-TO."

  ;;Set cameraa feed to CAP. Set its, width/height to default
  (with-captured-camera (cap cam :width width :height height)
    (let ((window-name "COPY-TO Example 2"))
      (with-named-window (window-name +window-normal+)
	(set-window-property window-name +wnd-prop-fullscreen+ 
			     +window-fullscreen+)
	(set-window-property window-name +wnd-prop-aspectratio+ 
			     +window-freeratio+)
	(with-object ((threshold1 (alloc :int 0))
		      (threshold2 (alloc :int 0)))
	  ;;Adjusting the trackbars changes the THRESHOLD1 
	  ;;and THRESHOLD2 parameters of the function CANNY
	  (create-trackbar "THRESHOLD1" window-name threshold1 500)
	  (create-trackbar "THRESHOLD2" window-name threshold2 500)
	  (loop  
	     ;;Create matrices to 
	     ;;hold all the data
	     (with-mat ((frame (mat))
			(src (mat height width +8u+))
			(dst (mat height width +8u+))
			;;Create matrix filled with zeros(all black)
			(black-mat (mat-zeros (rows frame) (cols frame) 0)))
               ;;Set the camera 
               ;;feed to FRAME
	       (read cap frame)
               ;;Convert FRAME to grayscale
	       (cvt-color frame src +bgr2gray+)
               ;;Set CANNY output to DST
	       (canny src dst (coerce (@ threshold1 :int) 'double-float) 
		      (coerce (@ threshold2 :int) 'double-float))
               ;;Copy FRAME to BLACK-MAT, masked		
	       (copy-to frame black-mat dst)
               ;;Show BLACK-MAT then delete all matrices
	       (imshow window-name black-mat))
	     (let ((c (wait-key 33)))
	       (when (= c 27)
		 (return)))))))))


========================================================================================================================================
#CROSS
========================================================================================================================================

Computes a cross-product of two 3-element vectors.

C++: Mat Mat::cross(InputArray m) const

LISP-CV: (CROSS (SELF MAT) (M MAT)) => MAT


    Parameters:	

        SELF - A 3-element vector

        m - Another cross-product operand.


The function CROSS computes a cross-product of two 3-element vectors. The vectors must be 3-element 
floating-point vectors of the same shape and size. The result is another 3-element vector of the same 
shape and type as operands.


(defun cross-example ()

  (with-object ((data1 (alloc :double '(7d0 3d0 -4d0)))
		(data2 (alloc :double '(1d0 0d0 6d0))))
    (with-mat ((vec1 (mat 1 3 +64f+ data1))
	       (vec2 (mat 1 3 +64f+ data2)))
      ;;Print VEC1
      (format t "~%VEC1 = ~%~%")
      (dotimes (j (cols vec1))
	(format t "~a" (@ :double vec1 0 j))
	(princ #\Space))
      ;;Print VEC2
      (format t "~%~%VEC2 = ~%~%")
      (dotimes (j (cols vec2))
	(format t "~a" (@ :double vec2 0 j))
	(princ #\Space))
      ;;Find and print cross product 
      ;;of VEC1 and VEC2
      (with-mat ((cp (cross vec1 vec2)))
	(format t "~%~%The cross product is: ~%~%")
	(dotimes (j (cols cp))
	  (format t "~a" (@ :double cp 0 j))
	  (princ #\Space))
	(format t "~%~%")))))

========================================================================================================================================
#DATA
========================================================================================================================================

Pointer to MAT data.

C++: uchar* data

LISP-CV: (DATA (SELF MAT) ) => :POINTER


    Parameters:	

        SELF - A MAT object.


Once a matrix is created, it will be automatically managed by using a reference-counting mechanism
(unless the matrix header is built on top of user-allocated data, in which case you should handle t-
he data by yourself). The matrix data will be deallocated when no one points to it; if you want to 
release the data pointed by a matrix header before the matrix destructor is called, use the functio-
n (RELEASE).

The next important thing to learn about the matrix class is element access. Here is how the matrix 
is stored. The elements are stored in row-major order (row by row). The (DATA) function points to 
the first element of the first row, the (ROWS) function contains the number of matrix rows, (COLS) - 
the number of matrix columns. There is yet another function, (STEP), that is used to actually compu-
te the address of a matrix element. (COLS) is needed because the matrix can be part of another matr-
ix or because there can be some padding space in the end of each row for a proper alignment.


(defun data-example (filename)

  ;;Read image
  (with-mat ((img (imread filename 1))) 
    (if (empty img) 
	(return-from data-example 
	  (format t "Image not loaded")))

    (let ((window-name "DATA Example")
	  ;;Variables used to hold the 
	  ;;BGR image pixel values
	  (b 0)
	  (g 0)
	  (r 0)
	  ;;INPUT is a pointer 
	  ;;to the IMG data
	  (input (data img))) 
      (with-named-window (window-name +window-normal+)
	(move-window window-name 759 175)
	;;In a loop access IMG pixel data using the STEP* 
	;;function and print to a file, instead of the co-
	;;nsole, so your implementation doesn't freeze.
	(with-open-file (str (cat *lisp-cv-src-dir* 
				  "/data/pixel-values.txt")
			     :direction :output
			     :if-exists :supersede
			     :if-does-not-exist :create)
	  (dotimes (i (rows img))
	    (dotimes (j (cols img))
	      (setf b (mem-aref input :uchar 
				(+  (* (step* img) i) (* 3 j) )))
	      (setf g (mem-aref input :uchar 
				(+ (+  (* (step* img) i) (* 3 j) ) 1)))
	      (setf r (mem-aref input :uchar 
				(+ (+  (* (step* img) i) (* 3 j) ) 2)))
	      (format str "(~a,~a,~a)~%" b g r))))
	(imshow window-name img)
	(loop
	   (let ((c (wait-key 33)))
	     (when (= c 27)
	       (return))))))))


========================================================================================================================================
#DEPTH
========================================================================================================================================

Returns the depth of a matrix element.

C++: int Mat::depth() const

LISP-CV: (DEPTH (SELF MAT)) => :INT

The method returns the identifier of the matrix element depth (the type of each individual channel). 
For example, for a 16-bit signed element array, the method returns +16S+ . A complete list of matrix 
types contains the following values:

    +8U+ - 8-bit unsigned integers ( 0..255 )

    +8S+ - 8-bit signed integers ( -128..127 )

    +16U+ - 16-bit unsigned integers ( 0..65535 )

    +16S+ - 16-bit signed integers ( -32768..32767 )

    +32S+ - 32-bit signed integers ( -2147483648..2147483647 )

    +32F+ - 32-bit floating-point numbers ((* +FLT-MAX+ -1)..+FLT-MAX+, INF, NAN) 

    +64F+ - 64-bit floating-point numbers ((* +DBL-MAX+ 1)..+DBL-MAX+, INF, NAN)

;; INF and NAN C++ constants and are not currently implimented in LISP-CV


Example:


CV> (DEFPARAMETER A (MAT 3 3 +8SC1+)) ;Initialize 1 channel matrix of 8-bit signed integer type

A

CV> (MAT-TYPE A) 

1   ;The type of the matrix is 1(+8SC1+) - 1 channel matrix with 8-bit signed integer elements

CV> (DEPTH A)

1   ;The type of the matrix elements are 1(+8S+) - 8-bit signed integer


CV> (DEFPARAMETER A (MAT 3 3 +8SC3+)) ;Initialize 3 channel matrix of 8-bit signed integer type

A

CV> (MAT-TYPE A)  

17   ;The type of the matrix is 17(+8SC1+) - 3 channel matrix with 8-bit signed integer elements

CV> (DEPTH A)

1   ;The type of the matrix elements are 1(+8S+) - 8-bit signed integer


========================================================================================================================================
#DIV
========================================================================================================================================

Divides matrix M1 by matrix M2.

C++: MatExpr / operator

LISP-CV: (DIV (M1 MAT) (M2 MAT)) => MAT-EXPR


    Parameters:	

        M1 - A matrix.

        M2 - A matrix.


The function DIV divides the elements of matrix M1 by the elements of matrix M2 in order. Both matrices 
must be the same size. You may need to coerce the result of DIV, the return value, back to type MAT with 
the function (FORCE), (or the shorthand version (>>)) to use in other functions. 


(defun div-example ()

  "Matrix M1 is divided by M2 with the function DIV.
   Matrix M1, M2 and the result(RESULT) are then pri-
   nted."

  (with-object ((m1-data (alloc :float '(53.0f0 62.0f0 85.0f0 64.0f0 23.0f0 
					 97.0f0 52.0f0 16.0f0 12.0f0)))
		(m2-data (alloc :float '(64.0f0 22.0f0 64.0f0 15.0f0 11.0f0 
					 17.0f0 42.0f0 16.0f0 88.0f0))))
    (with-mat ((m1 (mat 3 3 +32f+ m1-data))
	       (m2 (mat 3 3 +32f+ m2-data)))
      (with-mat-expr ((result (div m1 m2)))
	(format t "~%M1:~%~%" )
	(print-mat m1)
	(format t "~%M2:~%~%" )
	(print-mat m2)
	(format t "~%RESULT:~%~%" )
	(print-mat (t:>> result))
	(format t "~%" )))))

========================================================================================================================================
#DMATCH
========================================================================================================================================

DMATCH constructor.

Note: Both DMATCH and MAKE-DMATCH are provided in this library. The first, to match OpenCV's naming 
conventions, the second, to adhere to Common Lisp naming conventions. Except for the name, they are 
the same function. I use the DMATCH function in the examples in this file because it will make them 
easier to compare with OpenCV examples you find online, thus making this library easier to learn.


C++: DMatch() : queryIdx(-1), trainIdx(-1), imgIdx(-1),
                distance(std::numeric_limits<float>::max()) {}

LISP-CV: (DMATCH) => DMATCH

LISP-CV: (MAKE-DMATCH) => DMATCH

C++: DMatch( int _queryIdx, int _trainIdx, float _distance ) :
             queryIdx(_queryIdx), trainIdx(_trainIdx), imgIdx(-1),
             distance(_distance) {}

LISP-CV: (DMATCH (QUERY-IDX :INT) (TRAIN-IDX :INT) (DISTANCE :FLOAT)) => DMATCH

LISP-CV: (MAKE-DMATCH (QUERY-IDX :INT) (TRAIN-IDX :INT) (DISTANCE :FLOAT)) => DMATCH

C++: DMatch( int _queryIdx, int _trainIdx, int _imgIdx, float _distance ) :
             queryIdx(_queryIdx), trainIdx(_trainIdx), imgIdx(_imgIdx),
             distance(_distance) {}


LISP-CV: (DMATCH (QUERY-IDX :INT) (TRAIN-IDX :INT) (IMG-IDX :INT) (DISTANCE :FLOAT)) => DMATCH

LISP-CV: (MAKE-DMATCH (QUERY-IDX :INT) (TRAIN-IDX :INT) (IMG-IDX :INT) (DISTANCE :FLOAT)) => DMATCH


C++: int DMatch::queryIdx

LISP-CV: (QUERY-IDX (SELF DMATCH)) => :INT  

C++: int DMatch::trainIdx 

LISP-CV: (TRAIN-IDX (SELF DMATCH)) => :INT 

C++: int DMatch::imgIdx   

LISP-CV: (IMG-IDX (SELF DMATCH)) => :INT 

C++: float DMatch::distance

LISP-CV: (DISTANCE (SELF DMATCH)) => :FLOAT


    Parameters:	

        QUERY-IDX - Query descriptor index

        TRAIN-IDX - Train descriptor index
       
        IMG-IDX - Train descriptor index
    
        DISTANCE - Distance between descriptors. The lower, the better it is.


Used for matching keypoint descriptors: query descriptor index, train descriptor index, train image 
index, and distance between descriptors. If you are using the 3 element version of the function and 
using the function CFFI:MEM-AREF(or the LISP-CV macro for it "@") to access a specific element of the 
DMATCH object it returns, the value you entered as the 3rd parameter will be accessible at the 4th 
index(This is just a workaround until I come up with a better solution).


Example:

TODO (Write an example showing how to create DMatch manually, add to vector and send to DRAW-MATCHES)


========================================================================================================================================
#DOT
========================================================================================================================================

Note: This is a overloaded method that computes the dot product of elements in both MAT and POINT-* 
objects. The documentation is revealed pertaining to both.


MAT

C++: double Mat::dot(InputArray m) const

LISP-CV: (DOT (SELF MAT) (OTHER MAT)) => :DOUBLE


POINT-2*

C++:  _Tp dot(const Point_& pt) const;

LISP-CV: (DOT (SELF POINT) (OTHER POINT)) => :INT

LISP-CV: (DOT (SELF POINT-2D) (OTHER POINT-2D)) => :DOUBLE

LISP-CV: (DOT (SELF POINT-2F) (OTHER POINT-2F)) => :FLOAT


POINT-3*

C++"  _Tp dot(const Point3_& pt) const;

LISP-CV: (DOT (SELF POINT-3D) (OTHER POINT-3D)) => :DOUBLE

LISP-CV: (DOT (SELF POINT-3F) (OTHER POINT-3F)) => :FLOAT

LISP-CV: (DOT (SELF POINT-3I) (OTHER POINT-3I)) => :INT


    Parameters:	

        SELF - A POINT-* or a MAT object.

        OTHER - Another dot-product operand(MAT or POINT-* object).


Descriptions:


POINT-*

Operates as to the normal rules of mathematics.

MAT

The method computes a dot-product of two matrices. If the matrices are not single-column or single-row 
vectors, the top-to-bottom left-to-right scan ordering is used to treat them as 1D vectors. The vectors 
must have the same size and type. If the matrices have more than one channel, the dot products from all 
the channels are summed together.


Examples: 


POINT-*

(defun dot-example-1 ()

  "This example uses the function DOT to 
   find The dot product of all the POINT
   type objects in this library."

  (with-point ((point-1 (point 1 2))
	       (point-2 (point 3 4)))
    (format t "~%The dot product of POINT-1 and POINT-2 = ~a~%~%"  
	    (dot point-1 point-2)))
  (with-point-2d ((point-2d-1 (point-2d 1.0d0 2.0d0))
		  (point-2d-2 (point-2d 3.0d0 4.0d0)))
    (format t "~%The dot product of POINT-2D-1 and POINT-2D-2 = ~a~%~%"  
	    (dot point-2d-1 point-2d-2)))
  (with-point-2f ((point-2f-1 (point-2f 1.0f0 2.0f0))
		  (point-2f-2 (point-2f 3.0f0 4.0f0)))
    (format t "~%The dot product of POINT-2F-1 and POINT-2F-2 = ~a~%~%"  
	    (dot point-2f-1 point-2f-2)))
  (with-point-3d ((point-3d-1 (point-3d 13.0d0 14.0d0 15.0d0))
		  (point-3d-2 (point-3d 16.0d0 17.0d0 18.0d0)))
    (format t "~%The dot product of POINT-3D-1 and POINT-3D-2 = ~a~%~%"  
	    (dot point-3d-1 point-3d-2)))
  (with-point-3f ((point-3f-1 (point-3f 7.0f0 8.0f0 9.0f0))
		  (point-3f-2 (point-3f 10.0f0 11.0f0 12.0f0)))
    (format t "~%The dot product of POINT-3F-1 and POINT-3F-2 = ~a~%~%"  
	    (dot point-3f-1 point-3f-2)))
  (with-point-3i ((point-3i-1 (point-3i 1 2 3))
		  (point-3i-2 (point-3i 4 5 6)))
    (format t "~%The dot product of POINT-3I-1 and POINT-3I-2 = ~a~%~%"  
	    (dot point-3i-1 point-3i-2))))


MAT

(defun dot-example-2 () 
  ;; Create data
  (with-object ((data (alloc :uchar '(1 2 3 4 5 6 7 8))))
    ;; Create matrices A and B
    (with-mat ((a (mat 2 4 +8u+ data))
	       (b (mat 2 4 +8u+ data)))

      ;; In this case the dot product is simply:

      ;; (+ (* 1 1) (* 2 2) (* 3 3) (* 4 4) (* 5 5) (* 6 6) (* 7 7) (* 8 8))

      ;; The 2-row, 4-column matrix is treated as 1D vectors like this: 

      ;; 1,2,3,4,5,6,7,8

      (format t "~%The dot product of A and B = ~a~%~%" (dot a b)))))


========================================================================================================================================
#ELEM-SIZE
========================================================================================================================================


Returns the matrix element size in bytes.


C++: size_t Mat::elemSize() const

LISP-CV: (ELEM-SIZE (SELF MAT)) => :UNSIGNED-INT


    Parameters: 

        SELF - A matrix.


The method returns the matrix element size in bytes. For example, if the matrix type is +16SC3+,
the method returns 3*sizeof(short) or 6.


Example:

CV> (ELEM-SIZE (MAT 3 3 +16SC1+))

2

CV> (ELEM-SIZE (MAT 3 3 +16SC3+))

6

========================================================================================================================================
#ELEM-SIZE1
========================================================================================================================================


Returns the size of each matrix element channel in bytes.


C++: size_t Mat::elemSize1() const

LISP-CV: (ELEM-SIZE1 (SELF MAT)) => :UNSIGNED-INT


    Parameters:

        SELF - A matrix


The method returns the matrix element channel size in bytes, that is, it ignores the number of channels. 
For example, if the matrix type is +16SC3+ , the method returns (SIZE-OF :SHORT) or 2.


Example:

CV> (ELEM-SIZE1 (MAT 3 3 +16SC1+))

2

CV> (ELEM-SIZE1 (MAT 3 3 +16SC3+))

2

========================================================================================================================================
#EMPTY
========================================================================================================================================

Returns true if a MAT or RANGE object is empty.

C++: bool Mat::empty() const

LISP-CV: (EMPTY (SELF MAT)) => :BOOLEAN

C++: bool Range::empty() const

LISP-CV: (EMPTY (SELF RANGE)) => :BOOLEAN


    Parameters:

        SELF - A MAT or a RANGE object.


Example for matrices(The GC: prefix signals a finalizer is being used):


CV> (DEFPARAMETER A (GC:IMREAD "/HOME/USER/THIS-IS-A-REAL-IMAGE.JPG" 1))

A

CV> (EMPTY A)

NIL

CV> (DEFPARAMETER A (GC:IMREAD "/HOME/USER/THIS-IS-NOT-A-REAL-IMAGE.JPG" 1))

A

CV> (EMPTY A)

T


Example for RANGE objects(The GC: prefix signals a finalizer is being used):


CV> (DEFPARAMETER B (GC:RANGE 1 10))

B

CV> (EMPTY B)

NIL

CV> (DEFPARAMETER C (GC:RANGE-ALL))

C

CV> (EMPTY C)

T

========================================================================================================================================
#FORCE
========================================================================================================================================

Coverts a MAT-EXPR to MAT

LISP-CV: (FORCE (SELF MAT-EXPR)) => MAT

LISP-CV: (>> (SELF MAT-EXPR)) => MAT


  Parameters:	

        SELF - A Matrix Expression.


The function FORCE converts a functions output from MAT-EXPR to MAT.  This is useful if you have just 
done mathematical computation with a Matrix Expressions(MAT-EXPR) function and would like to use the 
result in a function that only accepts a MAT as input i.e. IMSHOW. The function >> is an identical 
shorthand version of the FORCE function supplied for ease of use. 


(defun force-example ()

  "In this example, matrix M1 is filled with 122, 
   and matrix M2 is filled with 122. Matrix M1 is 
   multiplied by M2 and the result is stored in R-
   ESULT. Before being shown in a window, the ret-
   urn value of the MUL function, which is of typ-
   e MAT-EXPR, must be coerced back to type MAT s-
   o the IMSHOW function can read it.  The functi-
   on FORCE(actually the shorthand version >>) is
   used to do this."

  (let ((window-name "RESULT - FORCE Example"))
    (with-mat ((m1 (mat 3 3 +8u+ 1))
	       (m2 (mat 3 3 +8u+ 255)))
      (with-mat-expr ((result (add m1 m2)))
	(with-named-window (window-name +window-normal+)
	  (move-window window-name 759 175)
	  (loop
	     (imshow window-name (t:>> result))
	     (let ((c (wait-key 33)))
	       (when (= c 27)
		 (return)))))))))

========================================================================================================================================
#INV
========================================================================================================================================

Inverses a matrix.

C++: MatExpr Mat::inv(int method=DECOMP_LU) const

LISP-CV: (INV (SELF MAT) (METHOD :INT)) => MAT-EXPR 

    Parameters:	

        SELF - A matrix.

        METHOD -

        Matrix inversion method. Possible values are the following:

            +DECOMP-LU+ is the LU decomposition. The matrix must be non-singular.

            +DECOMP-CHOLESKY+ is the Cholesky decomposition for symmetrical positively 
                              defined matrices only. This type is about twice faster than 
                              +DECOMP-LU+ on big matrices.

            +DECOMP-SVD+ is the SVD decomposition. If the matrix is singular or even 
                         non-square, the pseudo inversion is computed.


The method performs a matrix inversion by means of Matrix Expressions. This means that a temporary 
matrix inversion object is returned by the method and can be used further as a part of more complex 
Matrix Expressions or can be assigned to a matrix. You may need to coerce the return value of INV 
back to type MAT with the function (FORCE), (or the shorthand version (>>)) to use in other functions.


(defun inv-example ()

  "Matrix division, which is undefined in vector mathematics, 
   is simulated here by finding the inverse of a matrix, DIV-
   ISOR, and then multiplying another matrix, MAT, by it. I
   use some finalizers for GC here(denoted by the gc: prefix 
   to the function name), so the code doesn't get too long."


  ;;Create matrix data
  (with-object ((data-1 (alloc :float '(1f0 2f0 3f0 3f0 2f0 1f0 2f0 1f0 3f0)))
		(data-2 (alloc :float '(4f0 5f0 6f0 6f0 5f0 4f0 4f0 6f0 5f0))))
    ;;Create numerator matrix
    (with-mat ((numerator (mat 3 3 +32f+ data-1))
	       ;;Create divisor matrix
	       (divisor (mat 3 3 +32f+ data-2)))
      ;;Find determinant of divisor     
      (let ((determinant (det divisor))
	    (divisor-inv 0)
	    (identity-mat 0)
	    (quotient 0))
	;;Print NUMERATOR
	(format t "~%NUMERATOR:~%~%")
	(print-mat numerator)
	;;Print DIVISOR
	(format t "~%DIVISOR:~%~%")
	(print-mat divisor)
	;;Check if the determinant of divisor is 0. If not, 
	;;an inverse cannot be determined, so exit program
	(if (= 0.0d0 determinant) 
	    (return-from inv-example 
	      (progn (format t "The determinant of DIVISOR is 0.0d0.~%")
		     (format t "Cannot find its inverse.~%")))
	    (format t "~%The determinant of DIVISOR: ~a~%~%" determinant))
	;;Find inverse of DIVISOR and print it
	(setf divisor-inv (gc:>> (gc:inv divisor +decomp-lu+)))
	(format t "The inverse of DIVISOR:~%~%")
	(print-mat divisor-inv)
	;;Multiply DIVISOR by the inverse of divisor
	;;Output is a float identity matrix
	(setf identity-mat (gc:>> (gc:mul divisor divisor-inv)))
	;;Print the identity matrix
	(format t "~%Product of DIVISOR and its inverse:~%~%")
	(print-mat identity-mat)
	(setf quotient (gc:>> (gc:mul numerator 
				      (gc:>> (gc:inv divisor +decomp-lu+)))))
	(format t "~%Simulated quotient of NUMERATOR and DIVISOR:~%~%")
	(print-mat quotient)
        (format t "~%")))))

========================================================================================================================================
#IS-CONTINOUS
========================================================================================================================================

Reports whether the matrix is continuous or not.

C++: bool Mat::isContinuous() const

LISP-CV: (IS-CONTINUOUS (SELF MAT)) => :BOOLEAN

The method returns true if the matrix elements are stored continuously without gaps at the end of 
each row. Otherwise, it returns false. Obviously, 1x1 or 1xN matrices are always continuous. Matrices 
created with (CREATE) are always continuous. But if you extract a part of the matrix using (COL),
(DIAG) , and so on, or constructed a matrix header for externally allocated data, such matrices may 
no longer have this property.


(defun is-continuous-example (filename)

  ;;Allocate matrix data
  (with-object ((data (alloc :uchar '(1 2 3 4 5 6 7 8 
				      9 10 11 12 13 14 15 16))))
    ;;Create initialized matrix
    (with-mat ((mat (mat 4 4 +8u+ data))
	       ;;Extract a 2x2 roi of MAT. 
               ;;Note: I use a finalizer 
               ;;for RECT
	       (mat-roi (roi mat (gc:rect 1 1 2 2)))
	       ;;Read in image
	       (img (imread filename 1)))
      (let* ((window-name-1 "3x3 Matrix - IS-CONTINUOUS Example")
	     (window-name-2 "2x2 roi of MAT - IS-CONTINUOUS Example")
	     (window-name-3 "Original image - IS-CONTINUOUS Example")
	     (window-name-4 "Centered 100x100 roi of IMG - IS-CONTINUOUS Example")
	     (roi-size 100)
	     (x (- (/ (cols img) 2) (/ roi-size 2)))
	     (y (- (/ (rows img) 2) (/ roi-size 2)))) 
        ;;Extract a 100x100 centered roi of IMG
	(with-rect ((roi (rect x y roi-size roi-size)))
	  (with-mat ((img-roi (roi img roi)))     
	    (with-named-window (window-name-1 +window-normal+)
	      (with-named-window (window-name-2 +window-normal+)
		(with-named-window (window-name-3 +window-normal+)
		  (with-named-window (window-name-4 +window-normal+)
		    (move-window window-name-1 485 98)
		    (move-window window-name-2 894 98)
		    (move-window window-name-3 485 444)
		    (move-window window-name-4 894 444)
		    ;;Show original 3x3 matrix
		    (imshow window-name-1 mat)
		    ;;Show 2x2 roi of MAT
		    (imshow window-name-2 mat-roi)
		    ;;Show original image
		    (imshow window-name-3 img)
		    ;;Show a centered 100x100 roi of image
		    (imshow window-name-4 img-roi)
		    (format t "~%~%")
		    ;;This shows that submats(roi) are intrinsically non-continuous
		    (format t "Are MAT matrix elements stored continuously: ~a~%~%" 
			    (is-continuous mat))
		    (format t "Are MAT-ROI matrix elements stored continuously: ~a~%~%" 
			    (is-continuous mat-roi))
		    (format t "Are IMG matrix elements stored continuously: ~a~%~%" 
			    (is-continuous img))
		    (format t "Are IMG-ROI matrix elements stored continuously: ~a~%~%" 
			    (is-continuous img-roi))
		    (loop
		       (let ((c (wait-key 33)))
			 (when (= c 27)
			   (return))))))))))))))


========================================================================================================================================
#KEY-POINT
========================================================================================================================================

KEYPOINT constructor.

Note: Both KEY-POINT and MAKE-KEY-POINT are provided in this library. The first, to match OpenCV's 
naming conventions, the second, to adhere to Common Lisp naming conventions. Except for the name, 
they are the same function. I use the KEY-POINT function in the examples in this file because it 
will make them easier to compare with OpenCV examples you find online, thus making this library 
easier to learn.

C++: KeyPoint::KeyPoint()

LISP-CV: (KEY-POINT) => KEY-POINT

LISP-CV: (MAKE-KEY-POINT) => KEY-POINT

C++: KeyPoint::KeyPoint(float x, float y, float _size, float _angle=-1, float _response=0, int _octave=0, int _class_id=-1)

LISP-CV: (KEY-POINT (X :FLOAT) (Y :FLOAT) (SIZE :FLOAT) &OPTIONAL ((ANGLE :FLOAT) -1) ((RESPONSE :FLOAT) 0) ((OCTAVE :INT) 0) 
        ((CLASS-ID :INT) -1)) => KEY-POINT

LISP-CV: (MAKE-KEY-POINT (X :FLOAT) (Y :FLOAT) (SIZE :FLOAT) &OPTIONAL ((ANGLE :FLOAT) -1) ((RESPONSE :FLOAT) 0) ((OCTAVE :INT) 0) 
        ((CLASS-ID :INT) -1)) => KEY-POINT


    Parameters:	

        X - X-coordinate of the keypoint

        Y - Y-coordinate of the keypoint

        SIZE - Keypoint diameter

        ANGLE - Keypoint orientation

        RESPONSE - Keypoint detector response on the keypoint (that is, strength of the keypoint)

        OCTAVE - Pyramid octave in which the keypoint has been detected

        CLASS-ID - Object id


Used for matching keypoint descriptors: query descriptor index, train descriptor index, train image 
index, and distance between descriptors.


Example:

TODO(Write example using DRAW KEYPOINTS to draw random keypoints)


========================================================================================================================================
#LOCATE-ROI
========================================================================================================================================

Locates the matrix header within a parent matrix.

C++: void Mat::locateROI(Size& wholeSize, Point& ofs) const

LISP-CV: (LOCATE-ROI (SELF MAT) (WHOLE-SIZE SIZE) (OFS POINT)) => :VOID


    Parameters:	

        SELF - A matrix

        WHOLE-SIZE - Output parameter that contains the size of the whole matrix containing *this as a part.

        OFS - Output parameter that contains an offset of *this inside the whole matrix.


After you have extracted a submatrix from a matrix MAT using (ROWS MAT), (COLS MAT), (ROW-RANGE MAT) 
,(COL-RANGE MAT), and others, the resultant submatrix points just to the part of the original parent 
matrix. However, each submatrix contains information (represented by the OpenCv Mat class DATASTART 
and DATAEND members) that helps reconstruct the original matrix size and the position of the extracted 
submatrix within the original matrix. The function LOCATE-ROI does exactly that.


(defun locate-roi-example (&optional 
			     (cam *camera-index*) 
			     (width *default-width*)
			     (height *default-height*))
  ;;Set camera feed to CAP and set its width and height
  (with-captured-camera (cap cam :width width :height height)
    (let ((window-name-1 "Original FRAME - LOCATE-ROI Example")
	  (window-name-2 "Submatrix - LOCATE-ROI Example"))
      (if (not (is-opened cap)) 
	  (return-from locate-roi-example 
	    (format t "Cannot open the video camera")))
      (format t "~%Frame Size : ~ax~a~%~%" 
	      (get* cap +cap-prop-frame-width+)
	      (get* cap +cap-prop-frame-height+))
      ;;Create windows and move to specified positions
      (with-named-window (window-name-1 +window-normal+)
	(with-named-window (window-name-2 +window-normal+)
	  (move-window window-name-1 514 175)
	  (move-window window-name-2 966 175)
	  (with-mat ((frame (mat)))
	    ;;Create rectangle RECT
	    (with-rect ((rect (rect (round (/ width 4)) 
				    (round (/ height 4))  
				    (round (/ width 2)) 
				    (round (/ height 2)))))
	      ;;Create variables to hold the size and location 
	      ;;information derived by LOCATE-ROI
	      (with-size ((roi-size (size 0 0)))
		(with-point ((roi-loc (point 0 0)))
		  (loop
		     ;;Set camera feed to frame   
		     (read cap frame)
		     ;;Show original FRAME in window
		     (imshow window-name-1 frame)
		     ;;Extract submatrix(roi) from FRAME
		     (with-mat ((frame (roi frame rect)))
		       ;;Locate the position of the submatrix 
		       ;;inside FRAME we just extracted as well 
		       ;;as the size of its parent matrix which 
		       ;;is, in this case FRAME 
		       (locate-roi frame roi-size roi-loc)
		       ;;Print location of submatrix
		       (format t "Location of FRAME region of interest (~a, ~a)~%~%" 
			       (x roi-loc) (y roi-loc))
		       ;;Print size of parent matrix
		       (format t "Size of FRAME (~a, ~a)~%~%" 
			       (width roi-size) (height roi-size))
		       ;;Show submatrix in window
		       (imshow window-name-2 frame))
		     (let ((c (wait-key 33)))
		       (when (= c 27)
			 (return)))))))))))))


========================================================================================================================================
#MAT
========================================================================================================================================

Creates a matrix

Note: Both MAKE-MAT and MAT are provided in this library. The first to adhere to Common Lisp 
standards and the second to match OpenCV's. Except for the name, they are the same function.
I use the MAT function in the examples in this file because it will make them easier to compare 
with OpenCV examples you find online, thus making this library easier to learn.


C++: Mat::Mat()

LISP-CV: (MAT) => MAT

LISP-CV: (MAKE-MAT) => MAT


C++: Mat::Mat(int rows, int cols, int type)

LISP-CV: (MAT (ROWS :INT) (COLS :INT) (TYPE :INT)) => MAT

LISP-CV: (MAKE-MAT (ROWS :INT) (COLS :INT) (TYPE :INT)) => MAT


C++: Mat::Mat(int rows, int cols, int type, const Scalar& s)

LISP-CV: (MAT (ROWS :INT) (COLS :INT) (TYPE :INT) (S SCALAR)) => MAT

LISP-CV: (MAT (ROWS :INT) (COLS :INT) (TYPE :INT) (VALUES LIST)) => MAT

LISP-CV: (MAKE-MAT (ROWS :INT) (COLS :INT) (TYPE :INT) (S SCALAR)) => MAT

LISP-CV: (MAKE-MAT (ROWS :INT) (COLS :INT) (TYPE :INT) (VALUES LIST)) => MAT


C++: Mat::Mat(int rows, int cols, int type, void* data, size_t step=AUTO_STEP)

LISP-CV: (MAT (ROWS :INT) (COLS :INT) (TYPE :INT) (DATA :POINTER)) => MAT

LISP-CV: (MAKE-MAT (ROWS :INT) (COLS :INT) (TYPE :INT) (DATA :POINTER)) => MAT


C++: Mat::Mat(const Mat& m, const Range& rowRange, const Range& colRange=Range::all() )

LISP-CV: (MAT (SELF MAT) (ROW-RANGE RANGE) (COL-RANGE RANGE)) => MAT

LISP-CV: (MAKE-MAT (SELF MAT) (ROW-RANGE RANGE) (COL-RANGE RANGE)) => MAT


LISP-CV SPECIFIC:

LISP-CV: (MAT (SELF MAT)) => ARRAY

LISP-CV: (MAT (SELF ARRAY) &OPTIONAL (MAT-TYPE INTEGER)) => MAT


    Parameters:	

        SELF - A MAT object or an ARRAY.

        ROWS - The number of rows.
    
        COLS - The number of columns.

        TYPE - The type of the matrix.

        S - A scalar.

        DATA - A pointer to an array of numbers. This pointer can be created with the ALLOC macro.
               Search #ALLOC in this file for the ALLOC documentation.

        ROW-RANGE - A RANGE object.

        COL-RANGE - Another RANGE object.

        MAT-TYPE - The type of the output matrix, e.g. +8U+, 16SC2, +32FC3+(See below).


Concerning converting MAT objects to Lisp ARRAYS:

The (MAT (SELF MAT)) version of this function will convert a MAT object into a Lisp ARRAY and the 
(MAT (SELF ARRAY) &OPTIONAL (MAT-TYPE INTEGER)) version of this function will convert a Lisp ARRAY 
to a MAT object. You may want to be mindful of how you use these functions because the conversions 
are done by iterations done in a loop. This causes the functions to take longer to run, and though 
you can get quite a speed increase if you convert your matrices to Lisp arrays at the head of your 
program and do whatever operations you need to with Lisp code in your loop, if you are constantly 
converting back and forth between Mat objects and Lisp arrays in your loop, you may notice decrease 
in performance, when using larger matrices or arrays, over what you would get by just doing all the
operations inside the underlying C++ code. The MAT-EXAMPLE-2 function below will convert both a MAT 
object to a Lisp ARRAY and back and time the operations in the process. You can enter any MAT object 
you like to that function to get an idea of the time, the conversions to and from an ARRAY, will take.

Note: When using this version: (MAT (SELF ARRAY) &OPTIONAL (MAT-TYPE INTEGER)), you only need to supply 
the MAT-TYPE parameter if converting a SIMPLE-ARRAY of type T. Otherwise the function will convert the
MAT object to a Lisp ARRAY of equal dimensions and type. If the ARRAY is not type of T, and you supply 
the MAT-TYPE parameter, the output ARRAY will be sized and typed according to the MAT-TYPE value.

Speed notes:

The speed of the function will improve as I fine tune it's operation. I time how long 2,592,000 runs
of (T:MAT) takes in the example below. 2,592,000 is the number of matrices that would be created, if 
you created 1 matrix for every 30fps video frame in a 24 hour period. (T:MAT) is the finalized version 
of (MAT) and finalizers are the slowest of the three forms of MM in this library. You can get a 33% speed 
increase in this library by compiling your programs to an executable before you run them(See the RUN macro 
in <lisp-cv-source-dir>/macros.lisp for details on that. Also, try looking into Paralella boards, a cheaper 
solution for mind blowing processing speed(I know, sounds like a commercial...but trust me:) ). A CUDA module
will be coming to this library as well.


Example 1:

(defun mat-example-1 ()

  "In this example, I show how all the different MAT 
   types are used. I use some finalizer versions of 
   the MAT functions here. Their memory is automatic-
   ally managed so you don't need WITH-* macros or m-
   anual memory management to clean up. They are slo-
   wer though. The GC: prefix, signals automatic mem-
   ory management is activated. I prove it is activa-
   ted by creating millions of MAT objects at the en-
   d of the example. You should notice your RAM fluc-
   tuate, but not rise to any dangerous level. You c-
   an also use the shorter T: prefix(finalizer true) 
   to enable automatic GC in functions that support 
   it. All functions in this library that need to be 
   memory managed have a finalized version.

   Note: Automatic memory management is the slowest, 
         WITH-* macros are second, and manual MM is 
         the quickest for the MAT functions."

  (with-object ((data (alloc :double '(1d0 2d0 3d0 4d0 5d0 
				       6d0 7d0 8d0 9d0))))
    ;;Create matrices
    (let* ((mat (gc:mat))
	   (mat-typed (gc:mat 4 4 +32s+))
	   (mat-value-1 (gc:mat 3 3 +32f+ (t:scalar 255)))
	   (mat-value-2 (gc:mat 3 3 +32f+ (t:scalar 255)))
	   (mat-data-1 (gc:mat 3 3 +64f+ data))
	   (mat-data-2 (gc:mat 3 3 +64f+ data))
	   (mat-data-2-row-1 (gc:mat mat-data-2 (range 0 1) (range-all)))
           (manual 0))
      ;;Print matrices
      (format t "~%MAT:~%~%")
      (print-mat mat)
      (format t "~%~%MAT-TYPED:~%~%")
      (print-mat mat-typed)
      (format t "~%MAT-VALUE-1:~%~%")
      (print-mat mat-value-1)
      (format t "~%MAT-VALUE-2:~%~%")
      (print-mat mat-value-2)
      (format t "~%MAT-DATA-1:~%~%")
      (print-mat mat-data-1)
      (format t "~%MAT-DATA-2:~%~%")
      (print-mat mat-data-2)
      (format t "~%MAT-DATA-2-ROW-1:~%~%")
      (print-mat mat-data-2-row-1)
      ;;Time how long it takes to create 2,592,000
      ;;finalized MAT objects using the CL:TIME ma-
      ;;cro $. I use the t: prefix here to enable 
      ;;finalization. 
      (format t "~%Create 2,592,000 finalized MAT objects:~%~%")
      ($ (t:mat) 2592000)
      ;;Time how long it takes to create 2,592,000
      ;;matrices GC'ed by a with-* macro.
      (format t "Create 2,592,000 MAT objects GC'ed by WITH-* macro:~%~%")
      ($ (with-mat ((with (mat)))) 2592000)
      ;;Time how long it takes to create 2,592,000
      ;;matrices manuallly GC'ed.
      (format t "Create 2,592,000 MAT objects GC'ed manually:~%~%")
      ($ (progn (setf manual (mat)) (del-mat manual)) 2592000))))


Example 2:

(defun mat-example-2 (filename)

  (let ((window-name "MAT Example 2")
	;;Define variables for the
	;;MAT object and the ARRAY.
	(mat 0)
	(arr 0))
    (with-named-window (window-name +window-normal+)
      (move-window window-name 759 175)
      ;;Load image specified by the FILENAME parameter.
      (with-mat ((img (imread filename +load-image-color+)))
        
	(if (empty img) 
	    (return-from mat-example-2 
	      (format t "Image was not loaded!")))

        ;;Convert the MAT created 
        ;;by IMREAD to an ARRAY.
        ;;Note: $ is a TIME macro.
        (format t "~%Timing MAT to array conversion...~%~%")
	($ (setf arr (mat img)) 1)
        ;;Convert ARRAY back a MAT.
        (format t "Timing array to MAT conversion...~%~%")
	($ (setf mat (mat arr)) 1)
        ;;Show the reconstituted MAT
        ;;in window as evidence that
        ;;the two conversions were a
        ;;success. 
	(imshow window-name mat)
	(loop
	   (let ((c (wait-key 33)))
	     (when (= c 27)
	       (return))))))))

========================================================================================================================================
#MAT-ASSIGN
========================================================================================================================================

Assign a matrices data to another matrix.

Note: The name MAT-ASSIGN is used in the documentation to refer the binding for the OpenCV 
Mat class assignment operator(Mat version) because it is more descriptive and it is easier to 
search for in this file. The ASSIGN method may also be used to call this binding.

C++: Mat& Mat::operator=(const Mat& m)

LISP-CV: (ASSIGN (SELF MAT) (M MAT)) => MAT

LISP-CV: (MAT-ASSIGN (SELF MAT) (M MAT)) => MAT


    Parameters:	

        SELF - A matrix

        M - The assigned, right-hand-side matrix. Matrix assignment is O(1) operation, that is, no 
            data is copied. Instead, the data is shared and the reference counter, if any, is incremented. 
            Before assigning new data, the old data is dereferenced via Mat::release in the underlying C++ 
            interface.


Example: 


CV> (DEFPARAMETER A (MAT-ZEROS 7 7 +64f+))

A

CV> (PRINT-MAT A)

#((0.0d0 0.0d0 0.0d0 0.0d0 0.0d0 0.0d0 0.0d0)
  (0.0d0 0.0d0 0.0d0 0.0d0 0.0d0 0.0d0 0.0d0)
  (0.0d0 0.0d0 0.0d0 0.0d0 0.0d0 0.0d0 0.0d0)
  (0.0d0 0.0d0 0.0d0 0.0d0 0.0d0 0.0d0 0.0d0)
  (0.0d0 0.0d0 0.0d0 0.0d0 0.0d0 0.0d0 0.0d0)
  (0.0d0 0.0d0 0.0d0 0.0d0 0.0d0 0.0d0 0.0d0)
  (0.0d0 0.0d0 0.0d0 0.0d0 0.0d0 0.0d0 0.0d0))

CV> (DEFPARAMETER B (MAT))

B

CV> (PRINT-MAT B)
Matrix is empty.

CV> (DEFPARAMETER C (ASSIGN B A))

C

CV> (PRINT-MAT C)

#((0.0d0 0.0d0 0.0d0 0.0d0 0.0d0 0.0d0 0.0d0)
  (0.0d0 0.0d0 0.0d0 0.0d0 0.0d0 0.0d0 0.0d0)
  (0.0d0 0.0d0 0.0d0 0.0d0 0.0d0 0.0d0 0.0d0)
  (0.0d0 0.0d0 0.0d0 0.0d0 0.0d0 0.0d0 0.0d0)
  (0.0d0 0.0d0 0.0d0 0.0d0 0.0d0 0.0d0 0.0d0)
  (0.0d0 0.0d0 0.0d0 0.0d0 0.0d0 0.0d0 0.0d0)
  (0.0d0 0.0d0 0.0d0 0.0d0 0.0d0 0.0d0 0.0d0))

CV> (PRINT-MAT B)

#((0.0d0 0.0d0 0.0d0 0.0d0 0.0d0 0.0d0 0.0d0)
  (0.0d0 0.0d0 0.0d0 0.0d0 0.0d0 0.0d0 0.0d0)
  (0.0d0 0.0d0 0.0d0 0.0d0 0.0d0 0.0d0 0.0d0)
  (0.0d0 0.0d0 0.0d0 0.0d0 0.0d0 0.0d0 0.0d0)
  (0.0d0 0.0d0 0.0d0 0.0d0 0.0d0 0.0d0 0.0d0)
  (0.0d0 0.0d0 0.0d0 0.0d0 0.0d0 0.0d0 0.0d0)
  (0.0d0 0.0d0 0.0d0 0.0d0 0.0d0 0.0d0 0.0d0))

========================================================================================================================================
#MAT-ASSIGN-VAL
========================================================================================================================================

Assign a scalar value to a matrix.

Note: The name MAT-ASSIGN-VAL is used in the documentation to refer the binding for the OpenCV 
Mat class assignment operator(Scalar version) because it is more descriptive and it is easier 
to search for in this file. The ASSIGN method may also be used to call this binding.

C++: Mat& Mat::operator=(const Scalar& s)

LISP-CV: (ASSIGN (SELF MAT) (S SCALAR)) => MAT

LISP-CV: (MAT-ASSIGN-VAL (SELF MAT) (S SCALAR)) => MAT


    Parameters:	

        SELF - A matrix

        S - Scalar assigned to each matrix element. The matrix size or type is not changed.


Use the function SCALAR-ALL, as the S parameter value, to set each matrix element to the same value
for example: (SCALAR-ALL -1) will assign -1 to every element of the matrix. Use the function SCALAR 
to assign a specific color value to each element of the matrix i.e. (SCALAR 0 255 0) will set every 
matrix element to fgreen. This is useful when you need to add/subtract a certain color value from an 
image. The matrix you assign the scalar value to will be overwritten by the operation, there is no 
need to access the return value of ASSIGN-VAL to complete the operation,


(defun mat-assign-val-example (filename)

  (let* ((window-name-1 "IMAGE - MAT-ASSIGN-VAL Example")
         (window-name-2 "MAT - MAT-ASSIGN-VAL Example")
         (b (alloc :int 0))
         (g (alloc :int 0))
	 (r (alloc :int 0)))
    ;; Load an image
    (with-mat ((image (imread filename 1))
	       ;; Create a matrix to fill with a 
               ;; scalar value defined below
	       (mat (mat (rows image) (cols image) +8uc3+)))
      ;; Print IMAGE type. It is important to know this
      ;; Before subtracting a matrix from an image. You 
      ;; must set the matrix size and type to be the sa-
      ;; me as the image
      (format t "~%IMAGE type = ~a(+8UC3+)~%~%" (mat-type image))
      (with-named-window (window-name-1 +window-normal+)
	(with-named-window (window-name-2 +window-normal+)	
	  (move-window window-name-1 533 175)
	  (move-window window-name-2 984 175)
          ;; Create trackbars to change the BGR 
          ;; values we will later subtract from 
          ;; IMAGE
	  (create-trackbar  "B" window-name-2 b 255)
	  (create-trackbar  "G" window-name-2 g 255)
	  (create-trackbar  "R" window-name-2 r 255)
	  (loop
	     ;; Set all elements of MAT to SCALAR.
	     (with-scalar ((scalar (scalar (@ b :int) 
					   (@ g :int) 
					   (@ r :int))))
	       (assign mat scalar))
	     ;; Subtract MAT from IMAGE
	     (with-mat-expr ((result (sub image mat)))
	       ;; Show results
	       (imshow window-name-1 image)
               ;; Coerce RESULT to a MAT 
               ;; before showing in window
	       (with-mat ((forced-result (>> result)))
		 (imshow window-name-2 forced-result)
		 (let ((c (wait-key 33)))
		   (when (= c 27)
		     (return)))))))))))

========================================================================================================================================
#MAT-EXPR-T
========================================================================================================================================

Transposes a matrix.

C++: MatExpr Mat::t() const

LISP-CV: (MAT-EXPR-T (SELF MAT)) => MAT-EXPR

The method performs matrix transposition by means of matrix expressions. It does not perform the 
actual transposition but returns a temporary matrix transposition object that can be further used 
as a part of more complex matrix expressions or can be assigned to a matrix.


  Parameters:	

        SELF - Input matrix


MAT-EXPR-T-EXAMPLE:

CV> (DEFPARAMETER A (T:MAT 3 3 +8U+ :UCHAR '(1 2 3 4 5 6 7 8 9)))

A

CV> (PRINT-MAT A)

#((1 2 3)
  (4 5 6)
  (7 8 9))

CV> (PRINT-MAT (T:>> (T:MAT-EXPR-T A))) ;;;coerce the return value, back to MAT 
                                        ;;;with the (>>) function before printing.
#((1 4 7)                               ;;;Note: 'T:' enables auto finalization.                             
  (2 5 8)                               
  (3 6 9))

========================================================================================================================================
#MAT-EYE
========================================================================================================================================

Returns an identity matrix of the specified size and type.

C++: static MatExpr Mat::eye(int rows, int cols, int type)

LISP-CV: (MAT-EYE (ROWS :INT) (COLS :INT) (TYPE :INT)) => MAT


    Parameters:	

        ROWS - Number of rows.

        COLS - Number of columns.

        TYPE - Created matrix type.


The method returns a Matlab-style identity matrix initializer, similarly to (MAT-ZEROS). Similarly 
to (MAT-ONES), you can use a scale operation to create a scaled identity matrix efficiently:


Example:

Note: I supply a t: prefix to some functions in this example, 
      this enables automatic finalization on those functions."

(defun mat-eye-example ()

  ;;Create a UCHAR and SINGLE FLOAT identity matrix.
  (with-mat ((identity-mat-1 (mat-eye 3 3 +8u+))
	     (identity-mat-2 (mat-eye 4 4 +32f+)))
    ;;Coerce IDENTITY-MAT-2 from MAT type to a MAT-EXPR 
    ;;type with the <<(PROMOTE function) so the function 
    ;;SCALE can accept it as a parameter and then scale it 
    ;;by 0.1.
    (with-mat-expr ((scaled-identity-mat (scale (t:<< identity-mat-2) 0.1d0)))
      (let ((window-name-1 "IDENTITY-MAT-1 - MAT-EYE Example")
	    (window-name-2 "IDENTITY-MAT-2 - MAT-EYE Example")
	    (window-name-3 "SCALED-IDENTITY-MAT - MAT-EYE Example"))
	(with-named-window (window-name-1 +window-normal+)
	  (with-named-window (window-name-2 +window-normal+)
	    (with-named-window (window-name-3 +window-normal+)
	      (move-window window-name-1 310 175)
	      (move-window window-name-2 760 175)
	      (move-window window-name-3 1210 175)
	      ;;Show the identity matrices in windows.
              ;;Notice SCALED-IDENTITY-MAT is darker as
              ;;a reult of the scale operation.
	      (imshow window-name-1 identity-mat-1)
	      (imshow window-name-2 identity-mat-2)
	      (imshow window-name-3  (t:>> scaled-identity-mat))
	      (loop
		 (let ((c (wait-key 33)))
		   (when (= c 27)
		     (return)))))))))))

========================================================================================================================================
#MAT-ZEROS
========================================================================================================================================

Returns a zero array of the specified size and type.

Note: Both MAT-ZEROS and MAKE-MAT-ZEROS are provided in this library. The first, to match OpenCV's 
naming conventions, the second, to adhere to Common Lisp naming conventions. Except for the name, 
they are the same function. I use the MAT-ZEROS function in the examples in this file because it 
will make them easier to compare with OpenCV examples you find online, thus making this library 
easier to learn.

C++: static MatExpr Mat::zeros(int rows, int cols, int type)

LISP-CV: (MAT-ZEROS (ROWS :INT) (COLS :INT) (TYPE :INT)) => MAT

LISP-CV: (MAKE-MAT-ZEROS (ROWS :INT) (COLS :INT) (TYPE :INT)) => MAT


    Parameters:	

        ROWS - Number of rows.

        COLS - Number of columns.

        TYPE - Created matrix type.


The method returns a Matlab-style zero array initializer. It can be used to quickly form a constant
array as a function parameter, part of a matrix expression, or as a matrix initializer.


Examples:

(defun mat-zeros-example ()

  "In this example the function MAT-ZEROS 
   is used to create a matrix(MAT) filled 
   with zeros. MAT is then shown in a win-
   dow for verification."

  (with-mat ((mat (mat-zeros 3 3 +8u+)))
    (let ((window-name "MAT-ZEROS Example"))
      (with-named-window (window-name +window-normal+)
	(move-window window-name 759 175)
	(imshow window-name mat)
	(loop 
	   (let ((c (wait-key 33)))
	     (when (= c 27)
	       (return))))))))

========================================================================================================================================
#MUL
========================================================================================================================================

Finds the product of two matrices.

C++: MatExpr * operator

LISP-CV: (MUL (M1 MAT) (M2 MAT)) => MAT-EXPR


    Parameters:	

        M1 - A single float or double float matrix.

        M2 - A single float or double float matrix.


To perform matrix multiplication on two Matrices, the number of columns in the first matrix must be 
the same as the number of rows in the second Matrix. The matrices to be multiplied must also be of 
type Single Float(+32F+) or Double Float(+64f+). You may need to coerce the result of MUL, the return 
value, back to type MAT with the function (FORCE), (or the shorthand version (>>)) to use in other 
functions. 


(defun mul-example ()

  "In this example, MUL is used to find 
   the product of matrix, M1 and M2."

  (with-object ((data (alloc :float '(1.0f0 2.0f0 3.0f0 
				      4.0f0 5.0f0 6.0f0 
				      7.0f0 8.0f0 9.0f0))))
    (with-mat ((m1 (mat 3 3 +32f+ data))
	       (m2 (mat 3 3 +32f+ data)))
      (with-mat-expr ((result (mul m1 m2)))
	(format t "~%M1:~%~%")
	(print-mat m1)
	(format t "~%M2:~%~%")
	(print-mat m2)
	(format t "~%RESULT:~%~%")
	(with-mat ((forced-result (>> result)))
	  (print-mat forced-result)
	  (format t "~%"))))))

========================================================================================================================================
#POINT, #X, #Y, #POINT-X, #POINT-Y
========================================================================================================================================

POINT constructor.

Note: Both POINT and MAKE-POINT are provided in this library. The first, to match OpenCV's naming 
conventions, the second, to adhere to Common Lisp naming conventions. Except for the name, they are 
the same function. I use the POINT function in the examples in this file because it will make them 
easier to compare with OpenCV examples you find online, thus making this library easier to learn.

C++: Point()

LISP-CV: (POINT) => POINT

LISP-CV: (MAKE-POINT) => POINT

C++: Point(int x, int y)

LISP-CV:  (POINT (X :INT) (Y :INT)) => POINT

LISP-CV:  (MAKE-POINT (X :INT) (Y :INT)) => POINT

SETF-able member accessors. 

C++: Point::x, Point::y

LISP-CV: (X (SELF POINT)) => :INT

LISP-CV: (SETF (X (SELF POINT)) (VAL :INT)) => :INT

LISP-CV: (Y (SELF POINT)) => :INT

LISP-CV: (SETF (Y (SELF POINT)) (VAL :INT)) => :INT

LISP-CV: (POINT-X (SELF POINT)) => :INT ;Alias for X

LISP-CV: (SETF (POINT-X (SELF POINT)) (VAL :INT)) => :INT ;Alias for (SETF X)

LISP-CV: (POINT-Y (SELF POINT)) => :INT ;Alias for Y

LISP-CV: (SETF (POINT-Y (SELF POINT)) (VAL :INT)) => :INT ;Alias for (SETF Y)


    Parameters:	

        SELF - A POINT object.

        X - X-coordinate of the point.

        Y - Y-coordinate of the point.

        VAL - A new integer value.


POINT creates a 2D point with integer coordinates (usually zero-based). The methods X and Y are used 
to extract the x,y coordinates of a point.


(defun point-example (x y)

  "In this example we create an uninitialized 
   and an initialized integer point with the 
   function POINT and then print their values."

  (with-point ((initialized-point (point))
	       (point (point x y)))
    (format t "~%Pointer to initialized point: ~a~%~%" 
	    initialized-point)
    (format t "POINT (x, y) = (~a, ~a)~%~%" 
	    (x point)
	    (y point))))


========================================================================================================================================
#POINT-2D, #X, #Y, #POINT-2D-X, #POINT-2D-Y
========================================================================================================================================

POINT-2D constructor.

Note: Both POINT-2D and MAKE-POINT-2D are provided in this library. The first, to match OpenCV's naming 
conventions, the second, to adhere to Common Lisp naming conventions. Except for the name, they are 
the same function. I use the POINT-2D function in the examples in this file because it will make them 
easier to compare with OpenCV examples you find online, thus making this library easier to learn.

C++: typedef Point_<double> Point2d

LISP-CV: (POINT-2D) => POINT-2D

LISP-CV: (MAKE-POINT-2D) => POINT-2D

LISP-CV: (POINT-2D (X :INT) (Y :INT)) => POINT-2D

LISP-CV: (MAKE-POINT-2D (X :INT) (Y :INT)) => POINT-2D

SETF-able member accessors. 

C++: Point2d::x, Point2d::y

LISP-CV: (X (SELF POINT-2D)) => :DOUBLE

LISP-CV: (SETF (X (SELF POINT-2D)) (VAL :DOUBLE)) => :DOUBLE

LISP-CV: (Y (SELF POINT-2D)) => :DOUBLE

LISP-CV: (SETF (Y (SELF POINT-2D)) (VAL :DOUBLE)) => :DOUBLE

LISP-CV: (POINT-2D-X (SELF POINT-2D)) => :DOUBLE ;Alias for X

LISP-CV: (SETF (POINT-2D-X (SELF POINT-2D)) (VAL :DOUBLE)) => :DOUBLE ;Alias for (SETF X)

LISP-CV: (POINT-2D-Y (SELF POINT-2D)) => :DOUBLE ;Alias for Y

LISP-CV: (SETF (POINT-2D-Y (SELF POINT-2D)) (VAL :DOUBLE)) => :DOUBLE ;Alias for (SETF Y)


    Parameters:	

        SELF - A POINT-2D object.

        X - X-coordinate of the point.

        Y - Y-coordinate of the point.

        VAL - A new double float value.


POINT-2D creates a 2D point with double-float coordinates (usually zero-based). Methods X and Y are 
used to extract the x,y coordinates of the double float point.


(defun point-2d-example (x y)

  "In this example we create an uninitialized 
   and an initialized double float point with 
   the function POINT-2D and then print their 
   values."

  (let* ((point-2d-un-init (point-2d))
	 (point-2d (point-2d x y)))
    (format t "~%Pointer to POINT-2D: ~a~%~%" 
	    point-2d-un-init)
    (format t "POINT-2D (x, y) = (~a, ~a)~%~%" 
	    (x point-2d)
	    (y point-2d))))


========================================================================================================================================
#POINT-2F, #X, #Y, #POINT-2F-X, #POINT-2F-Y
========================================================================================================================================

POINT-2F constructor.

Note: Both POINT-2F and MAKE-POINT-2F are provided in this library. The first, to match OpenCV's naming 
conventions, the second, to adhere to Common Lisp naming conventions. Except for the name, they are 
the same function. I use the POINT-2F function in the examples in this file because it will make them 
easier to compare with OpenCV examples you find online, thus making this library easier to learn.

C++: typedef Point_<float> Point2f

LISP-CV:  (POINT-2F) => POINT-2F

LISP-CV:  (MAKE-POINT-2F) => POINT-2F

LISP-CV:  (POINT-2F (X :FLOAT) (Y :FLOAT)) => POINT-2F

LISP-CV:  (MAKE-POINT-2F (X :FLOAT) (Y :FLOAT)) => POINT-2F

SETF-able member accessors. 

C++: Point2f::x, Point2f::y

LISP-CV: (X (SELF POINT-2F)) => :FLOAT

LISP-CV: (SETF (X (SELF POINT-2F)) (VAL :FLOAT)) => :FLOAT

LISP-CV: (Y (SELF POINT-2F)) => :FLOAT

LISP-CV: (SETF (Y (SELF POINT-2F)) (VAL :FLOAT)) => :FLOAT

LISP-CV: (POINT-2F-X (SELF POINT-2F)) => :FLOAT ;Alias for X

LISP-CV: (SETF (POINT-2F-X (SELF POINT-2F)) (VAL :FLOAT)) => :FLOAT ;Alias for (SETF X)

LISP-CV: (POINT-2F-Y (SELF POINT-2F)) => :FLOAT ;Alias for Y

LISP-CV: (SETF (POINT-2F-Y (SELF POINT-2F)) (VAL :FLOAT)) => :FLOAT ;Alias for (SETF Y)


    Parameters:	

        SELF - A POINT-2F object.

        X - X-coordinate of the point.

        Y - Y-coordinate of the point.

        VAL - A new single float value.


POINT-2F creates a 2D point with single float coordinates (usually zero-based). Methods X and Y are 
used to extract the x,y coordinates the single float point.


(defun point-2f-example (x y)

  "In this example we create an uninitialized 
   and an initialized single float point with 
   the function POINT-2F and then print their 
   values."

  (let* ((point-2f-un-init (point-2f))
	 (point-2f (point-2f x y)))
    (format t "~%Pointer to POINT-2F: ~a~%~%" 
	    point-2f-un-init)
    (format t "POINT-2F (x, y) = (~a, ~a)~%~%" 
	    (x point-2f)
	    (y point-2f))))


========================================================================================================================================
#POINT-3D, #X, #Y, #Z, #POINT-3D-X, #POINT-3D-Y, #POINT-3D-Z
========================================================================================================================================

POINT-3D constructor.

Note: Both POINT-3D and MAKE-POINT-3D are provided in this library. The first, to match OpenCV's naming 
conventions, the second, to adhere to Common Lisp naming conventions. Except for the name, they are 
the same function. I use the POINT-3D function in the examples in this file because it will make them 
easier to compare with OpenCV examples you find online, thus making this library easier to learn.

C++: typedef Point3_<double> Point3d

LISP-CV:  (POINT-3D) => POINT-3D

LISP-CV:  (MAKE-POINT-3D) => POINT-3D

LISP-CV:  (POINT-3D (X :DOUBLE) (Y :DOUBLE) (Z :DOUBLE)) => POINT-3D

LISP-CV:  (MAKE-POINT-3D (X :DOUBLE) (Y :DOUBLE) (Z :DOUBLE)) => POINT-3D

SETF-able member accessors. 

C++: Point3d::x, Point3d::y

LISP-CV: (X (SELF POINT-3D)) => :DOUBLE

LISP-CV: (SETF (X (SELF POINT-3D)) (VAL :DOUBLE)) => :DOUBLE

LISP-CV: (Y (SELF POINT-3D)) => :DOUBLE

LISP-CV: (SETF (Y (SELF POINT-3D)) (VAL :DOUBLE)) => :DOUBLE

LISP-CV: (Z (SELF POINT-3D)) => :DOUBLE

LISP-CV: (SETF (Z (SELF POINT-3D)) (VAL :DOUBLE)) => :DOUBLE

LISP-CV: (POINT-3D-X (SELF POINT-3D)) => :DOUBLE ;Alias for X

LISP-CV: (SETF (POINT-3D-X (SELF POINT-3D)) (VAL :DOUBLE)) => :DOUBLE ;Alias for (SETF X)

LISP-CV: (POINT-3D-Y (SELF POINT-3D)) => :DOUBLE ;Alias for Y

LISP-CV: (SETF (POINT-3D-Y (SELF POINT-3D)) (VAL :DOUBLE)) => :DOUBLE ;Alias for (SETF Y)

LISP-CV: (POINT-3D-Z (SELF POINT-3D)) => :DOUBLE ;Alias for Z

LISP-CV: (SETF (POINT-3D-Z (SELF POINT-3D)) (VAL :DOUBLE)) => :DOUBLE ;Alias for (SETF Z)


    Parameters:	

        SELF - A POINT-3D object.

        X - X-coordinate of the point.

        Y - Y-coordinate of the point.
        
        Z - Z-coordinate of the point.

        VAL - A new double float value.


POINT-3D creates a 3D point with double float coordinates (usually zero-based). methods X, Y and Z 
are used to extract the x,y,Z coordinates the double float point.


(defun point-3d-example (x y z)

  "In this example we create an uninitialized 
   and an initialized double float point with 
   the function POINT-3D and then print their 
   values."

  (let* ((point-3d-un-init (point-3d))
	 (point-3d (point-3d x y z)))
    (format t "~%Pointer to POINT-3D: ~a~%~%" 
	    point-3d-un-init)
    (format t "POINT-3D (x, y, z) = (~a, ~a, ~a)~%~%" 
	    (x point-3d)
	    (y point-3d)
            (z point-3d))))


========================================================================================================================================
#POINT-3F, #X, #Y, #Z, #POINT-3F-X, #POINT-3F-Y, #POINT-3F-Z
========================================================================================================================================

POINT-3F constructor.

Note: Both POINT-3F and MAKE-POINT-3F are provided in this library. The first, to match OpenCV's naming 
conventions, the second, to adhere to Common Lisp naming conventions. Except for the name, they are 
the same function. I use the POINT-3F function in the examples in this file because it will make them 
easier to compare with OpenCV examples you find online, thus making this library easier to learn.

C++: typedef Point3_<float> Point3f

LISP-CV:  (POINT-3F) => POINT-3F

LISP-CV:  (MAKE-POINT-3F) => POINT-3F

LISP-CV:  (POINT-3F (X :FLOAT) (Y :FLOAT) (Z :FLOAT)) => POINT-3F

LISP-CV:  (MAKE-POINT-3F (X :FLOAT) (Y :FLOAT) (Z :FLOAT)) => POINT-3F

SETF-able member accessors. 

C++: Point3f::x, Point3f::y

LISP-CV: (X (SELF POINT-3F)) => :FLOAT

LISP-CV: (SETF (X (SELF POINT-3F)) (VAL :FLOAT)) => :FLOAT

LISP-CV: (Y (SELF POINT-3F)) => :FLOAT

LISP-CV: (SETF (Y (SELF POINT-3F)) (VAL :FLOAT)) => :FLOAT

LISP-CV: (Z (SELF POINT-3F)) => :FLOAT

LISP-CV: (SETF (Z (SELF POINT-3F)) (VAL :FLOAT)) => :FLOAT

LISP-CV: (POINT-3F-X (SELF POINT-3F)) => :FLOAT ;Alias for X

LISP-CV: (SETF (POINT-3F-X (SELF POINT-3F)) (VAL :FLOAT)) => :FLOAT ;Alias for (SETF X)

LISP-CV: (POINT-3F-Y (SELF POINT-3F)) => :FLOAT ;Alias for Y

LISP-CV: (SETF (POINT-3F-Y (SELF POINT-3F)) (VAL :FLOAT)) => :FLOAT ;Alias for (SETF Y)

LISP-CV: (POINT-3F-Z (SELF POINT-3F)) => :FLOAT ;Alias for Z

LISP-CV: (SETF (POINT-3F-Z (SELF POINT-3F)) (VAL :FLOAT)) => :FLOAT ;Alias for (SETF Z)


    Parameters:	

        SELF - A POINT-3F object.

        X - X-coordinate of the point.

        Y - Y-coordinate of the point.
        
        Z - Z-coordinate of the point.

        VAL - A new single float value.


POINT-3F creates a 3D point with single float coordinates (usually zero-based). Methods X, Y and Z 
are used to extract the x,y,Z coordinates the single float point.


(defun point-3f-example (x y z)

  "In this example we create an uninitialized 
   and an initialized single float point with 
   the function POINT-3F and then print their 
   values."

  (let* ((point-3f-un-init (point-3f))
	 (point-3f (point-3f x y z)))
    (format t "~%Pointer to POINT-3F: ~a~%~%" 
	    point-3f-un-init)
    (format t "POINT-3F (x, y, z) = (~a, ~a, ~a)~%~%" 
	    (x point-3f)
	    (y point-3f)
            (z point-3f))))


========================================================================================================================================
#POINT-3I, #X, #Y, #Z, #POINT-3I-X, #POINT-3I-Y, #POINT-3I-Z
========================================================================================================================================

POINT-3I constructor.

Note: Both POINT-3I and MAKE-POINT-3I are provided in this library. The first, to match OpenCV's naming 
conventions, the second, to adhere to Common Lisp naming conventions. Except for the name, they are 
the same function. I use the POINT-3I function in the examples in this file because it will make them 
easier to compare with OpenCV examples you find online, thus making this library easier to learn.

C++: typedef Point3_<int> Point3i;

LISP-CV:  (POINT-3I) => POINT-3I

LISP-CV:  (MAKE-POINT-3I) => POINT-3I

LISP-CV:  (POINT-3I (X :INT) (Y :INT) (Z :INT)) => POINT-3I

LISP-CV:  (MAKE-POINT-3I (X :INT) (Y :INT) (Z :INT)) => POINT-3I

SETF-able member accessors. 

C++: Point3i::x, Point3i::y

LISP-CV: (X (SELF POINT-3I)) => :INT

LISP-CV: (SETF (X (SELF POINT-3I)) (VAL :INT)) => :INT

LISP-CV: (Y (SELF POINT-3I)) => :INT

LISP-CV: (SETF (Y (SELF POINT-3I)) (VAL :INT)) => :INT

LISP-CV: (Z (SELF POINT-3I)) => :INT

LISP-CV: (SETF (Z (SELF POINT-3I)) (VAL :INT)) => :INT

LISP-CV: (POINT-3I-X (SELF POINT-3I)) => :INT ;Alias for X

LISP-CV: (SETF (POINT-3I-X (SELF POINT-3I)) (VAL :INT)) => :INT ;Alias for (SETF X)

LISP-CV: (POINT-3I-Y (SELF POINT-3I)) => :INT ;Alias for Y

LISP-CV: (SETF (POINT-3I-Y (SELF POINT-3I)) (VAL :INT)) => :INT ;Alias for (SETF Y)

LISP-CV: (POINT-3I-Z (SELF POINT-3I)) => :INT ;Alias for Z

LISP-CV: (SETF (POINT-3I-Z (SELF POINT-3I)) (VAL :INT)) => :INT ;Alias for (SETF Z)


    Parameters:	

        SELF - A POINT-3I object.

        X - X-coordinate of the point.

        Y - Y-coordinate of the point.
        
        Z - Z-coordinate of the point.

        VAL - A new integer value.


POINT-3I creates a 3D point with integer coordinates (usually zero-based). Methods X, Y and Z are 
used to extract the x,y,Z coordinates of the type integer point.


(defun point-3i-example (x y z)

  "In this example we create an uninitialized 
   and an initialized integer point with the 
   function POINT-3I and print their values."

  (let* ((point-3i-un-init (point-3i))
	 (point-3i (point-3i x y z)))
    (format t "~%Pointer to POINT-3I: ~a~%~%" 
	    point-3i-un-init)
    (format t "POINT-3I (x, y, z) = (~a, ~a, ~a)~%~%" 
	    (x point-3i)
	    (y point-3i)
            (z point-3i))))


========================================================================================================================================
#PRINT-MAT
========================================================================================================================================

Prints a matrix.

LISP-CV: (PRINT-MAT (MAT MAT)) => RESULT


    Parameters:	

        MAT - A matrix.


This function will print 1, 2, 3 and 4 channel matrices(MAT objects). When 2, 3 and 4 channel matrices
are printed, they are printed length-wise, to make it easier to view specific pixels without having to  
resize your output buffer.


Example:

CV> (DEFPARAMETER A (MAT-ONES 3 3 +8U+)) ;Create a 3x3 matrix filled with ones.

A

CV> (PRINT-MAT A)

#2M((1 1 1)
    (1 1 1)
    (1 1 1))

CV> (DEFPARAMETER A (MAT 3 3 +8UC3+ (T:SCALAR 1 1 1))) ;Create a 3x3x3 matrix filled with ones.

A

CV> (PRINT-MAT A)

#3M(((1 1 1)
     (1 1 1)
     (1 1 1))
    ((1 1 1)
     (1 1 1)
     (1 1 1))
    ((1 1 1)
     (1 1 1)
     (1 1 1)))

========================================================================================================================================
#PROMOTE
========================================================================================================================================

Coverts a MAT to MAT-EXPR

LISP-CV: (PROMOTE (SELF MAT)) => MAT-EXPR

LISP-CV: (<< (SELF MAT)) => MAT-EXPR


    Parameters

       Self - A matrix.

The function PROMOTE converts a functions return from MAT to MAT-EXPR. This is useful if you would 
like to do math computation on a matrix with a MAT type using a fast Matrix Expressions(MAT-EXPR) 
function. Some Matrix Expressions functions will only accept a MAT-EXPR type as input and that is 
what makes this function necessary.  You can then convert back to MAT with the function FORCE to use
the result in a function that only accepts a MAT as input i.e. IMSHOW. The function << is an identical 
shorthand version of the PROMOTE function supplied for ease of use. 

   Parameters:	

        SELF - A MAT pointer.


Example:


(defun promote-example ()

  "In this example a matrix filled with ones(MAT) is 
   created. PROMOTE or actually the shorthand versio-
   n of the function PROMOTE << is then used to coer-
   ce MAT to a MAT-EXPR type so it can then be multi-
   plied by the scalar S with the function SCALE. Th-
   is is necessary since SCALE only accepts the MAT-
   EXPR types as it's input. The output of SCALE is 
   then coerced back to MAT type, with the function 
   FORCE, for the opposite reason, so it can then be 
   shown in a window with IMSHOW."

  (let* ((mat (mat-ones 3 3 +8u+))
         (s 255.0d0)
         (out (scale (<< mat) s))
	 (window-name "PROMOTE Example"))
    (named-window window-name +window-normal+)
    (move-window window-name 759 175)
    (imshow window-name  (>> out))
    (loop while (not (= (wait-key 0) 27)))
    (destroy-window window-name)))


(<<-example)

========================================================================================================================================
#PTR
========================================================================================================================================

Returns a pointer to the specified matrix row.

C++: uchar* Mat::ptr(int i0=0)

LISP-CV: (PTR (SELF MAT) &OPTIONAL ((I0 :INT) 0)) => :POINTER

    Parameters:	

        SELF - A matrix.

        i0 - A 0-based row index.


This function returns a pointer to the specified matrix row.



;;The file the image's pixel value will be written 
;;in this example, will be saved to:

;;<LISP-CV-SOURCE-DIR>/DATA.


(defun ptr-example (filename)

  (let ((window-name-1 "Original image - PTR Example")
	(window-name-2 "All white image - PTR Example")
	;;Variables used to hold the 
	;;BGR image pixel values.
	(b 0)
	(g 0)
	(r 0)
	(p 0))
    ;;Read in image
    (with-mat ((img (imread filename 1)))
      (if (empty img) 
	  (return-from ptr-example 
	    (format t "Image not loaded")))
      (with-named-window (window-name-1 +window-normal+)
	(with-named-window (window-name-2 +window-normal+)
	  (move-window window-name-1 514 175)
	  (move-window window-name-2 966 175)
	  ;;Access the first BGR pixel value 
	  ;;with the function PTR and print it.
	  ;;Note: the '@' is a CFFI:MEM-AREF
	  ;;macro.
	  (setf b (@ (ptr img 0) :uchar))
	  (setf g (@ (ptr img 0) :uchar 1))
	  (setf r (@ (ptr img 0) :uchar 2))
	  (format t "~%First BGR pixel value = (~a,~a,~a)
~%~%" b g r)
	  ;;Access the second BGR pixel value 
	  ;;with the function PTR and print it.
	  (setf b (@ (ptr img 0) :uchar 3))
	  (setf g (@ (ptr img 0) :uchar 4))
	  (setf r (@ (ptr img 0) :uchar 5))
	  (format t "Second BGR pixel value = (~a,~a,~a)
 ~%~%" b g r)
	  ;;Access the third BGR pixel value 
	  ;;with the function PTR and print it.
	  (setf b (@ (ptr img 0) :uchar 6))
	  (setf g (@ (ptr img 0) :uchar 7))
	  (setf r (@ (ptr img 0) :uchar 8))
	  (format t "Third BGR pixel value = (~a,~a,~a)
 ~%" b g r)
	  ;;Access all BGR pixel values with the function PTR 
	  ;;and print them to a file so you can verify the fi-
	  ;;rst 3 BGR values in the file will match the 3 pri-
	  ;;nted here.
	  (with-open-file (str (cat *lisp-cv-data-dir* "pixel-values.txt")
			       :direction :output
			       :if-exists :supersede
			       :if-does-not-exist :create)
	    (dotimes (row (rows img))  
	      (dotimes (col (* (cols img) 3))
		(setf p (@ (ptr img row) :uchar col))
		(format str "~a~%" p))))
	  ;;Show original image in a window.
	  (imshow window-name-1 img)
	  ;;Here we set every pixel of IMG to white, the same
	  ;;way we saved every pixel to a file so you can ver-
	  ;;if every pixel was included.
	  (dotimes (row (rows img))  
	    (dotimes (col (* (cols img) 3))
	      (setf (@ (ptr img row) :uchar col) 255)))
	  ;;Show the all white image in a window.
	  (imshow window-name-2 img)
	  (loop
    	     (let ((c (wait-key 33)))
	       (when (= c 27)
		 (return)))))))))

========================================================================================================================================
PUSH-BACK
========================================================================================================================================

Appends a matrix to another one.

C++: void Mat::push_back(const Mat& m)

LISP-CV: (PUSH-BACK (SELF MAT) (M MAT)) => MAT

    Parameters:	

        SELF - A MAT object.

        M - Added line(s).

This function pushes matrix M to the bottom of initial SELF matrix. It emulate the corresponding 
method of the C++ STL vector class. The type and the number of columns must be the same as in the 
container matrix.


Example:

(defun push-back-example ()

  (with-mat ((matrix (mat 0 3 +32f+)))
    (push-back matrix (mat-zeros 2 3 +32f+))
    (push-back matrix (mat-ones 2 3 +32f+))
    (print-mat matrix)))

========================================================================================================================================
#RANGE
========================================================================================================================================

Range constructor.

Note: RANGE and RANGE-ALL and MAKE-RANGE and MAKE-RANGE-ALL are provided in this library. The first 
two, to match OpenCV's naming conventions, the second two, to adhere to Common Lisp naming conventions. 
Except for the name, they are the same function. I use the DMATCH function in the examples in this 
file because it will make them easier to compare with OpenCV examples you find online, thus making 
this library easier to learn.

C++: Range::Range(int _start, int _end)

LISP-CV: (RANGE (START :INT) (END :INT)) => RANGE

LISP-CV: (MAKE-RANGE (START :INT) (END :INT)) => RANGE

C++: Range* cv_create_RangeAll()

LISP-CV:  (RANGE-ALL) => RANGE

LISP-CV:  (MAKE-RANGE-ALL) => RANGE

C++: int Range::start

LISP-CV: (RANGE-START (SELF RANGE)) => :INT

C++: int Range::end

LISP-CV: (RANGE-END (SELF RANGE)) => :INT


    Parameters:	

        START - Inclusive left boundary of the range.

        END - Exclusive right boundary of the range.
       

These functions are used to specify a row or a column span in a matrix (MAT) and for many other 
purposes. (RANGE A B) is basically the same as a:b in Matlab or a..b in Python. As in Python, 
START is an inclusive left boundary of the range and END is an exclusive right boundary of the 
range. Such a half-opened interval is usually denoted as [START,END).

The function (RANGE-ALL) returns a special variable that means “the whole sequence” or “the whole 
range”, just like ” : ” in Matlab or ” ... ” in Python. All the functions in LISP-CV that take RANGE, 
support this special (RANGE-ALL)  value. But, of course, in case of your own custom processing, you 
will probably have to check and handle it explicitly:


(defun range-example (... r ....)

    (if (eq r (range-all)) 

        ;; Process all the data
   
        ;; (else)Process [ (range-start r), (range-end r) )
)


Note:

To retrieve the size of the matrix row or column span held in a RANGE object or to determine whether 
or not a RANGE object is empty, use the functions SIZE and EMPTY. Documentation and examples for SIZE
and EMPTY are in this file.

========================================================================================================================================
#RECT
========================================================================================================================================

RECT constructor.

Note: Both RECT and MAKE-RECT are provided in this library. The first, to match OpenCV's naming 
conventions, the second, to adhere to Common Lisp naming conventions. Except for the name, they are 
the same function. I use the RECT function in the examples in this file because it will make them 
easier to compare with OpenCV examples you find online, thus making this library easier to learn.

C++: Rect::Rect()

LISP-CV:  (RECT) => RECT

LISP-CV:  (MAKE-RECT) => RECT

C++: Rect::Rect(int x, int y, int width, int height)

LISP-CV:  (RECT (X :INT) (Y :INT) (:WIDTH :INT) (HEIGHT :INT)) => RECT

LISP-CV:  (MAKE-RECT (X :INT) (Y :INT) (:WIDTH :INT) (HEIGHT :INT)) => RECT

C++: int x, y, width, height

LISP-CV: (X (SELF RECT)) => :INT

LISP-CV: (Y (SELF RECT)) => :INT

LISP-CV: (WIDTH (SELF RECT)) => :INT

LISP-CV: (HEIGHT (SELF RECT)) => :INT

C++: Rect::size() const;

LISP-CV: (SIZE (SELF RECT)) => SIZE

C++: Rect::tl() const;

LISP-CV: (TL (SELF RECT)) => POINT

C++: Rect::br() const;

LISP-CV: (BR (SELF RECT)) => POINT

C: Rect* cv_Rect_clone(Rect* self) 

LISP-CV: (CLONE (SELF RECT)) => RECT 


    Parameters:	

        SELF - A rectangle.

        X - X-coordinate of the rectangle.

        Y - Y-coordinate of the rectangle.

        WIDTH - Width of the rectangle.

        HEIGHT - Height of the rectangle.


The functions RECT and MAKE-RECT store coordinates of a rectangle.

The method X retrieves the x coordinate of the rectangle.

The method Y retrieves the y coordinate of the rectangle.

The method WIDTH retrieves the width of the rectangle.

The method HEIGHT retrieves the height of the rectangle.

The method SIZE retrieves the size (width, height) of the rectangle. You can also use the 
SIZE method in this library to access the size of a RECT object. See SIZE-EXAMPLE in this file.

The function TL retrieves the top-left corner of the rectangle.

The function BR retrieves the bottom-right corner of the rectangle.

The method CLONE creates a full copy of the rectangle. It is a convenience function for creating 
a clone of a RECT object. It was created from scratch in C and then bound in Lisp.


(defun rect-example (x y width height)

  ;Create a rectangle and find its size(width, height), 
  ;location and size(x, y, width, height) and its top-
  ;left and bottom-right corner

  ;WITH-RECT calls DEL-RECT automatically when RECTAN-
  ;GLE goes out of scope. DEL-RECT frees the memory a-
  ;llocated by RECT
  
  (format t "~%RECTANGLE:~%")
  (with-rect ((rectangle (rect x y width height)))
    (let* ((x (x rectangle))
	   (y (y rectangle))
	   (width (width rectangle))
	   (height (height rectangle))
           (size (size rectangle))
	   (tl-corner (tl rectangle))
	   (br-corner (br rectangle)))
      (format t "~%The (x, y, width, height) of RECTANGLE = (~a, ~a, ~a, ~a)~%" 
	      x y width height)
      (format t "~%The size(width, height) of RECTANGLE = (~a, ~a)~%" 
	      (width size)
	      (height size))
      (format t "~%The top-left corner of RECTANGLE = (~a, ~a)~%" 
	      (x tl-corner)
	      (y tl-corner))
      (format t "~%The bottom-right corner of RECTANGLE = (~a, ~a)~%" 
	      (x br-corner)
	      (y br-corner)))

  ;Create a clone of RECTANGLE and find its size(width, 
  ;height), location and size(x, y, width, height) and 
  ;its top-left and bottom-right corner

    (format t "~%~%RECTANGLE-CLONE:~%")
    (with-rect ((rectangle-clone (clone rectangle))) 
      (let* ((clone-x (x rectangle-clone))
	     (clone-y (y rectangle-clone))
	     (clone-width (width rectangle-clone))
	     (clone-height (height rectangle-clone))
             (clone-size (size rectangle-clone))
	     (clone-tl-corner (tl rectangle-clone))
	     (clone-br-corner (br rectangle-clone)))
	(format t "~%The (x, y, width, height) of RECTANGLE-CLONE = (~a, ~a, ~a, ~a)~%" 
		clone-x clone-y clone-width clone-height)
	(format t "~%The size(width, height) of RECTANGLE-CLONE = (~a, ~a)~%" 
		(width clone-size)
		(height clone-size))
	(format t "~%The top-left corner of RECTANGLE-CLONE = (~a, ~a)~%" 
		(x clone-tl-corner)
		(y clone-tl-corner))
	(format t "~%The bottom-right corner of RECTANGLE-CLONE = (~a, ~a)~%~%" 
		(x clone-br-corner)
		(y clone-br-corner))))))


========================================================================================================================================
#RESHAPE
========================================================================================================================================

Changes the shape and/or the number of channels of a 2D matrix without copying the data.

C++: Mat Mat::reshape(int cn, int rows=0) const

LISP-CV: (RESHAPE (SELF MAT) (CN :INT) &OPTIONAL ((ROWS :INT) 0)) => MAT


    Parameters:	

        SELF - A matrix.       

        CN - New number of channels. If the parameter is 0, the number of channels remains the same.

        ROWS - New number of rows. If the parameter is 0, the number of rows remains the same.


The method makes a new matrix header for *this elements. The new matrix may have a different size 
and/or different number of channels. Any combination is possible if:


    No extra elements are included into the new matrix and no elements are excluded. Consequently, 
    the product (* (ROWS) (COLS) (CHANNELS)) must stay the same after the transformation.

    No data is copied. That is, this is an O(1) operation. Consequently, if you change the number of 
    rows, or the operation changes the indices of elements row in some other way, the matrix must be 
    continuous. See (IS-CONTINUOUS).


(defun reshape-example (filename)
  ;;Read in image
  (let* ((img (imread filename 1))
         ;;Allocate matrix data
         (data (alloc :uchar '(1 2 3 4 5 6 7 8 9)))
         ;;Create initialized matrix
         (mat (mat 3 3 +8u+ data))
         (window-name-1 "3x3 Matrix - RESHAPE Example")
         (window-name-2 "1x9 Vector - RESHAPE Example")
	 (window-name-3 "Original image - RESHAPE Example")
         (window-name-4 "1 channel image - RESHAPE Example"))      
    (named-window window-name-1 +window-normal+)
    (named-window window-name-2 +window-normal+)
    (named-window window-name-3 +window-normal+)
    (named-window window-name-4 +window-normal+)
    (move-window window-name-1 485 98)
    (move-window window-name-2 894 98)
    (move-window window-name-3 485 444)
    (move-window window-name-4 894 444)
    ;;Show original 3x3 matrix
    (imshow window-name-1 mat)
    ;;Show 3x3 matrix reshaped to 1x9 
    (imshow window-name-2 (reshape mat 1 9))
    ;;Show original image
    (imshow window-name-3 img)
    ;;Show 3 channel image reshaped to 1 channel
    (imshow window-name-4 (reshape img 1))
    (loop while (not (= (wait-key 0) 27)))
    (destroy-all-windows)))

========================================================================================================================================
#ROI
========================================================================================================================================

Returns matrix header corresponding to the rectangular sub-array of an input matrix.

C++: Mat::Mat(const Mat& m, const Rect& roi)

LISP-CV: (ROI (SELF MAT) (ROI RECT)) => MAT


    Parameters:	

        SELF - Pointer to a matrix

        ROI -  Zero-based coordinates of the rectangle of interest


The function returns a header, corresponding to a specified rectangle of the input array. In other 
words, it allows the user to treat a rectangular part of input array as a stand-alone array. ROI is
taken into account by the function so the sub-array of ROI is actually extracted. The function ROI 
returns a pointer to the resultant sub-array header.


Example:

(defparameter x 100)
(defparameter y 100)
(defparameter region-of-interest 0)
(defparameter the-right-wall 540)
(defparameter the-left-wall 100)
(defparameter the-ceiling 100)
(defparameter the-floor 380)
(defparameter rate 10)
(defparameter right-wall-switch 0)
(defparameter left-wall-switch 0)
(defparameter ceiling-switch 0)
(defparameter floor-switch 0)

(defun report ()
  (format t "x = ~a~%" x)
  (format t "y = ~a~%" y)
  (format t "right-wall-switch = ~a~%" right-wall-switch)
  (format t "left-wall-switch = ~a~%" left-wall-switch)
  (format t "ceiling-switch = ~a~%" ceiling-switch)
  (format t "floor-switch = ~a~%" floor-switch))


(defun roi-example (&optional (cam *camera-index*) 
		      (width *default-width*)
		      (height *default-height*))

  "A slight variation on my circle-example. here I use a bit of 
   logic to make the camera region of interest bounce around th-
   room. Have a look through the code, I named the variables in 
   a way to make it easy to understand."

  (with-captured-camera (cap cam :width width :height height)
    (let* ((window-name "ROI Example"))
      (if (not (is-opened cap)) 
	  (return-from roi-example 
	    (format t "Cannot open the video camera")))
      (format t "~%Frame Size : ~ax~a~%~%" 
	      (get* cap +cap-prop-frame-width+)
	      (get* cap +cap-prop-frame-height+))
      (with-named-window (window-name +window-normal+)
	(move-window window-name 759 175)
	(with-mat ((frame (mat)))
	  (loop
	     (read cap frame)
	     (with-rect ((region-of-interest (rect x y 40 40)))
	       (with-mat ((frame (roi frame region-of-interest)))
		 (imshow window-name frame)
		 (if (= x the-right-wall) (progn 
					    (format t "right wall has been touc-hed~%") 
					    (setf right-wall-switch 1)))    
		 (if (= x the-left-wall) (progn
					   (format t "left wall has been touched~%") 
					   (setf left-wall-switch 1)))	
		 (if (= y the-floor) (progn 
				       (format t "floor has been touched~%") 
				       (setf floor-switch 1))) 
		 (if (= y the-ceiling) (progn 
					 (format t "ceiling has been touched~%") 
					 (setf ceiling-switch 1))) 
		 (if (and (< x the-right-wall) (= right-wall-switch 0)) (incf x rate) (decf x rate))
		 (if (and (< y the-floor) (= floor-switch 0)) (incf y rate) (decf y rate))
		 (if (< x (+ 100 rate)) (setf right-wall-switch 0))
		 (if (< y (+ 100 rate)) (setf floor-switch 0))
		 (report)
		 (let ((c (wait-key 33)))
		   (when (= c 27)
		     (return)))))))))))

========================================================================================================================================
#ROTATED-RECT
========================================================================================================================================

Functions representing rotated (i.e. not up-right) rectangles on a plane and the associated functions 
used to retrieve their values.

Note: Both ROTATED-RECT and MAKE-ROTATED-RECT are provided in this library. The first, to match OpenCV's naming 
conventions, the second, to adhere to Common Lisp naming conventions. Except for the name, they are 
the same function. I use the ROTATED-RECT function in the examples in this file because it will make them 
easier to compare with OpenCV examples you find online, thus making this library easier to learn.

C++: RotatedRect::RotatedRect(const Point2f& center, const Size2f& size, float angle)

LISP-CV: (ROTATED-RECT (CENTER POINT) (SIZE SIZE) (ANGLE :FLOAT)) => ROTATED-RECT

LISP-CV: (MAKE-ROTATED-RECT (CENTER POINT) (SIZE SIZE) (ANGLE :FLOAT)) => ROTATED-RECT

C++: float RotatedRect::angle const

LISP-CV: (ANGLE (SELF ROTATED-RECT)) => :FLOAT

C++: Rect RotatedRect::boundingRect() const

LISP-CV: (BOUNDING-RECT (SELF ROTATED-RECT)) => RECT

C++: Point2f RotatedRect::center() 

LISP-CV: (CENTER (SELF ROTATED-RECT)) => POINT

C++: Size2f RotatedRect::size() 

LISP-CV: (SIZE (SELF ROTATED-RECT)) => SIZE


        Parameters:	

            SELF - A ROTATED-RECT object.

            CENTER - The rectangle mass center.

            SIZE - Width and height of the rectangle.

            ANGLE - The rotation angle in a clockwise direction. When the angle is 0, 90, 180, 270 
                    etc., the rectangle becomes an up-right rectangle.


(defun rotated-rect-example ()

  ;;Set the ROTATED-RECT center
  (let* ((box-loc (point 0 0))
	 ;;Set the ROTATED-RECT size
	 (box-size (size 100 100))
	 ;;Set the ROTATED-RECT angle
	 (box-angle 360f0)
         ;;Create the ROTATED-RECT object
	 (box (rotated-rect box-loc box-size box-angle))
         ;;Access the ROTATED-RECT BOUNDING-RECT member
         (bounding-rect (bounding-rect box)))
    (format t "~%The location of the ROTATED-RECT = (~a, ~a)~%" 
	    (x (center box)) (y (center box)))
    (format t "~%The (width, height) of the ROTATED-RECT = (~a, ~a)~%" 
	    (width (size box)) (height (size box)))
    (format t "~%The angle of the ROTATED-RECT = ~a~%~%" (angle box))
(format t "Bounding rectangle of the ROTATED-RECT = ~a~%~%" bounding-rect)
    (format t "(x, y, width, height) of BOUNDING-RECT = (~a, ~a, ~a, ~a)~%~%" 
	  (x bounding-rect) (y bounding-rect) (width bounding-rect) (height bounding-rect))))


========================================================================================================================================
#ROW-RANGE
========================================================================================================================================

Creates a matrix header for the specified row span.

C++: Mat Mat::rowRange(int startrow, int endrow) const

LISP-CV: (ROW-RANGE (SELF MAT) (STARTROW :INT) (ENDROW :INT)) => MAT


    Parameters:	

        SELF - A matrix.

        STARTROW - An inclusive 0-based start index of the row span.

        ENDROW - An exclusive 0-based ending index of the row span.


The method makes a new header for the specified row span of the matrix. Similarly to (ROW) and (COL) 
functions, this is an O(1) operation.


(defun row-range-example ()
  ;;Create matrix data.
  (with-object ((data (alloc :uchar '(1 2 3 4 5 6 7 8 9))))
    ;;Create matrix.
    (with-mat ((mat (mat 3 3 +8u+ data)))
      (princ #\Newline)
      ;;Print matrix normally by 
      ;;accessing entire matrix.
      (dotimes (i (rows mat))
	(dotimes (j (cols mat))
	  (format t "~a" (@ :uchar mat i j))
	  (princ #\Space))
	(princ #\Newline))
      (format t "~%~%")
      ;;Retrieve all 3 rows of MAT with 
      ;;ROW-RANGE to print matrix.
      ;;Note: The 't:' prefix enables 
      ;;automatic finalization.
      (dotimes (i (rows mat))
	(dotimes (j (cols mat))
	  (format t "~a" (@ :uchar
			    (row-range mat 0 (rows mat)) 
			    i j))
	  (princ #\Space))
	(princ #\Newline))
      (format t "~%"))))

========================================================================================================================================
#ROWS
========================================================================================================================================

Returns number or rows in MAT.

C++: int rows, cols

LISP-CV: (ROWS (SELF MAT)) => :INT


    Parameters:	

        SELF - A MAT object.


The function ROWS finds the number of rows in a matrix or -1 when the array has more than 2 dimensi-
ons. 


(defun rows-example ()

  "Uses ROWS to find the number of rows in the matrix MAT"

  (let* ((mat (mat 3 4 +64f+ (t:scalar 100)) ))
          (format t "The number of rows in MAT = ~a" (rows mat))))

========================================================================================================================================
#SCALE
========================================================================================================================================

Finds the product of a matrix and a scalar..

C++: MatExpr * operator

LISP-CV: (SCALE (SELF MAT-EXPR) (ALPHA :DOUBLE)) => MAT-EXPR


    Parameters:	

        SELF - A single float or double float matrix.

        ALPHA - A scalar of type double-float. 


This is the primary function used in this library for multiplication by and division by scalar. See 
SCALE-EXAMPLE for an example of division by scalar. You may need to coerce the return value of SCALE, 
a scaled matrix, back to type MAT with the function (FORCE), (or the shorthand version (>>)) to use in 
other functions. Also matrices of MAT type must be coerced to MAT-EXPR, with the function PROMOTE(<<), 
before passing to SCALE.


(defun scale-example ()

  "In this example a +32F+(single-float) matrix 
   is created and filled with data. Then, using 
   SCALE, each element of the matrix is divided 
   by the scalar 10. Finally, the matrix is pri-
   nted.

   Note: The t: prefix before the functions >> 
   and << signify that automatic GC is enabled."

  (with-object ((data (alloc :float '(1.0f0 2.0f0 3.0f0 4.0f0 5.0f0 
				      6.0f0 7.0f0 8.0f0 9.0f0))))
    (with-mat ((mat (mat 3 3 +32f+ data)))
      (with-mat-expr ((scaled-mat (scale (t:<< mat) (/ 1d0 10d0))))
	(format t "~%")
	(dotimes (i 3)
	  (dotimes (j 3)
	    (format t "~a" (@ :float (t:>> scaled-mat) i j))
	    (princ #\Space))
	  (princ #\Newline))
	(format t "~%")))))

========================================================================================================================================
#SIZE
========================================================================================================================================

The SIZE method is multifaceted in that it is a binding for the OpenCV class Size and able to create 
a SIZE(Lisp-CV designation) object, plus, it is a tool used to retrieve the value of any size member 
belonging to any class bound in this library. The SIZE method documentation is split into 2 parts one 
for the SIZE constructor methods and one for the size member accessor methods. 

========================================================================================================================================
#SIZE CONSTRUCTOR
========================================================================================================================================

Note: The MAKE-SIZE function is supplied because its name adheres to Common-Lisps naming conventions. 
The MAKE-SIZE function, has the ability to create a uninitialized and an initialized SIZE object, whereas 
the SIZE method too has this ability, except for the fact that when creating an uninitialized SIZE object 
with it, NIL must be supplied as the only parameter(See example). Due to the fact that the SIZE method is 
an overloaded method meant also to be a tool used to retrieve the size values held by the size member in 
any OpenCV class bound in this library(e.g. Mat, Rect), the SIZE method is restricted in this way for now 
due to limitations in Lisp method overloading. A workaround for this limitation is in the works and the 
documentation will be updated as soon as it is implemented. Note that I will use the SIZE method in the 
examples in this file because its name is similar to the OpenCV Size class and that will make the examples 
easier to compare with OpenCV examples you find online. Also note that use the low-level function SIZE-0 
to create a SIZE object to give to any function that requires one for the default parameter(its faster), 
so you may see the function name SIZE-0 floating around in some or the function definitions in this file.

C++: Size_(_Tp _width, _Tp _height);
     typedef Size_<int> Size2i;
     typedef Size2i Size;

LISP-CV: (SIZE (ARG NULL)) => SIZE

LISP-CV: (MAKE-SIZE) => SIZE

LISP-CV: (SIZE (WIDTH :INT) (HEIGHT :INT)) => SIZE

LISP-CV: (MAKE-SIZE (WIDTH :INT) (HEIGHT :INT)) => SIZE

C++: _Tp width, height

LISP-CV: (WIDTH (SELF SIZE)) => :INT

LISP-CV: (HEIGHT (SELF SIZE)) => :INT


    Parameters:	

        SELF - A SIZE object.

        WIDTH - The width of the SIZE object.
        
        HEIGHT - The height of the SIZE oject.


The function SIZE and MAKE-SIZE create a SIZE object

The function WIDTH Finds the width of a SIZE object.

The function HEIGHT Finds the height of a SIZE object.


(defun size-example-1 ()
  
  "An uninitialized and an initialized SIZE 
   object are created and their values are 
   printed."
  
  (with-size ((un-init-size (size nil))
	      (size (size 640d0 480d0)))
    (format t "~%Return of SIZE-UN-INIT: ~a
               ~%" un-init-size) 
    (format t "Width of SIZE = ~a~%~%" (width size))
    (format t "Height of SIZE = ~a~%~%" (height size))))


========================================================================================================================================
#SIZE ACCESSOR
========================================================================================================================================

The method SIZE can access the size member of any OpenCV class.

Note: The method is in process, but all definitions supplied here will work as expected.

C++: Size Mat::size() const

LISP-CV: (SIZE (SELF MAT)) => SIZE

C++: int Range::size() const;

LISP-CV: (SIZE (SELF RANGE)) => :INT

C++: Size_<_Tp> size() const;

LISP-CV: (SIZE (SELF RECT)) => SIZE


    Parameters:	

        SELF - A MAT, RANGE or RECT object.


The function SIZE creates and also retrieves MAT, RANGE and RECT size values.


The function SIZE contains the functionality of the OpenCV MAT class member size, the OpenCV Range 
class member size and the the OpenCV Rect class member size. It can determine the size value of any 
MAT object passed to it, determine the size of any RANGE object passed to it and determine the size 
of any RECT object passed to it. When returning a MAT size,  columns are listed first and rows are 
listed second(COLS, ROWS). When the matrix is more than 2-dimensional, the returned size is (-1 -1). 


(defun size-example-2 ()
  
  "In the code below, the (COLS, ROWS) values of MAT 
   and the (WIDTH, HEIGHT) values of RECT are access-
   ed and stored in a SIZE object. The MAT and RECT 
   size values are then accessed with the WIDTH and 
   HEIGHT functions and printed. Finally, the RANGE 
   object, RANGE, is created and its value printed."
  
  (with-mat ((mat (mat 5 5 +8u+ (t:scalar 100 100 100))))
    (with-rect ((rect (rect 0 0 640 480)))
      (with-size ((mat-size (size mat)))
	(with-size ((rect-size (size rect)))
	  (with-range ((range (range 1 10)))
	    (format t "~%MAT (COLS,ROWS) = (~a ~a)~%~%" 
		    (width mat-size)
		    (height mat-size))
	    (format t "RECT (WIDTH, HEIGHT) = (~a ~a)~%~%" 
		    (width rect-size)
		    (height rect-size))
	    (format t "The size of RANGE = ~a~%~%" 
		    (size range))))))))




========================================================================================================================================
#SIZE-2F(function in process)
========================================================================================================================================

Note: Both SIZE-2F and MAKE-SIZE-2F are provided in this library. The first, to match OpenCV's naming 
conventions, the second, to adhere to Common Lisp naming conventions. Except for the name, they are 
the same function. I use the SIZE-2F function in the examples in this file because it will make them 
easier to compare with OpenCV examples you find online, thus making this library easier to learn.

C++: typedef Size_<float> Size2f;

LISP-CV: (SIZE-2F) => SIZE

LISP-CV: (MAKE-SIZE-2F) => SIZE

LISP-CV: (SIZE-2F (WIDTH :FLOAT) (HEIGHT :FLOAT)) => SIZE

LISP-CV: (MAKE-SIZE-2F (WIDTH :FLOAT) (HEIGHT :FLOAT)) => SIZE

C++: _Tp width, height

LISP-CV: (WIDTH (SELF SIZE-2F)) => :INT

LISP-CV: (HEIGHT (SELF SIZE-2F)) => :INT


    Parameters:	

        SELF - A SIZE-2F object.

        WIDTH - The width of the SIZE-2F object.
        
        HEIGHT - The height of the SIZE-2F object.


The function SIZE-2F and MAKE-SIZE-2F create a SIZE-2F object

The function WIDTH-2F Finds the width of a SIZE-2F object.

The function HEIGHT-2F Finds the height of a SIZE-2F object.

========================================================================================================================================
#SIZE-ASSIGN-TO
========================================================================================================================================

Assign data from one SIZE object to another.

Note: The name SIZE-ASSIGN-TO is used in the documentation to refer to the binding for the OpenCV
Size class assignment operator because it is more descriptive and it is easier to search for in this 
file. The ASSIGN method may also be used to call this binding.

C: Size* cv_Size_assignTo(Size* self, Size* other)

LISP-CV: (ASSIGN (SELF SIZE) (OTHER SIZE)) => SIZE

LISP-CV: (SIZE-ASSIGN-TO (SELF SIZE) (OTHER SIZE)) => SIZE


    Parameters: 

        SELF - A SIZE object

        OTHER - A SIZE object


Size data is assigned OTHER to SELF.


Example:

CV> (DEFPARAMETER A (SIZE 1 2))

A

CV> (PRINT-SIZE A)

#(1 2)

CV> (DEFPARAMETER B (SIZE 1 2))

B

CV> (PRINT-SIZE B)

#(3 4)

CV> (DEFPARAMETER C (ASSIGN A B))

C

CV> (PRINT-SIZE A)

#(3 4)

CV> (PRINT-SIZE B)

#(3 4)

CV> (PRINT-SIZE C)

#(3 4)

========================================================================================================================================
#SIZE-FROM-POINT
========================================================================================================================================

Create a SIZE object from POINT data.

C: Size* cv_Size_fromPoint(Point* p)

LISP-CV: (SIZE-FROM-POINT (P POINT)) => SIZE


    Parameters: 

        P - A POINT object


Example:


CV> (DEFPARAMETER A (POINT 1 2))

A

CV> (DEFPARAMETER B (SIZE-FROM-POINT A))

B

CV> (PRINT-SIZE B)

#(1 2)


========================================================================================================================================
STEP*
========================================================================================================================================

Used to compute address of a matrix element

C++: Mat::step

LISP-CV: (STEP (SELF MAT)) => :UNSIGNED-INT

    Parameters:	

        SELF  a pointer to matrix(MAT) object

This function is used to compute the address of a matrix element. The image step gives you the dist-
ance in bytes between the first element of one row and the first element of the next row. This func-
tion is named STEP*, because the name STEP conflicts with a Lisp Macro.


Example:


(defun step*-example (filename)
  ;Load image
  (with-mat ((img (imread filename 1)))   
    ;Variables used to access the pixel data.
    ;BGR(Blue,Green,Red) is the default color
    ;format in OpenCV and therefore LisP-CV.
    (let ((b 0)
	  (g 0)
	  (r 0)
	  (input (data img))
	  (window-name "STEP* Example"))
      (if (empty img) 
	  (return-from step*-example 
	    (format t "Image not loaded")))
      (with-named-window (window-name +window-normal+)
	(move-window window-name 759 175)
	;Get pixel value at element 0,0 of IMG
	(setf b (mem-aref input :uchar 
			  (+  (* (step* img) 0) 0)))
	(setf g (mem-aref input :uchar 
			  (+ (+  (* (step* img) 0) 0) 1)))
	(setf r (mem-aref input :uchar 
			  (+ (+  (* (step* img) 0) 0) 2)))
	;Print the 0,0 pixel value
	(format t "~%The pixel value at 0,0 is: (~a,~a,~a)~%" b g r)
	(imshow window-name img)
	(loop 
	   (let ((c (wait-key 33)))
	     (when (= c 27)
	       (return))))))))

========================================================================================================================================
#STEP1
========================================================================================================================================

Returns a normalized step.

C++: size_t Mat::step1(int i=0 ) const

LISP-CV: (STEP1 (SELF MAT)) => :UNSIGNED-INT

The method returns a matrix step divided by (ELEM-SIZE1) . It can be useful to quickly access an 
arbitrary matrix element.

Note: I use the internal MAT-INFO function here for supplying the type to the CFFI:MEM-AREF functions 
that are used in this example. I did this so you could see just how the CFFI types map onto the Lisp-CV 
types, and also because learning how to use these CFFI functions with this library will give you alot 
more programming options.


Example:

(defun mat-info (mat)
  (let ((mat-rows (rows mat))
	(mat-cols (cols mat))
	(mat-type (mat-type mat)))

    (case  mat-type  
      (#.+8uc1+  (list mat-rows mat-cols mat-type :uchar 1 3)) 
      (#.+8sc1+  (list mat-rows mat-cols mat-type :char 1 3))
      (#.+16uc1+ (list mat-rows mat-cols mat-type :ushort 1 3)) 
      (#.+16sc1+ (list mat-rows mat-cols mat-type :short 1 3))
      (#.+32sc1+ (list mat-rows mat-cols mat-type :int 1 3)) 
      (#.+32fc1+ (list mat-rows mat-cols mat-type :float 1 3))
      (#.+64fc1+ (list mat-rows mat-cols mat-type :double 1 3))
      (#.+8uc2+  (list mat-rows mat-cols mat-type :uchar 2 6))
      (#.+8sc2+  (list mat-rows mat-cols mat-type :char 2 6))
      (#.+16uc2+ (list mat-rows mat-cols mat-type :ushort 2 6))
      (#.+16sc2+ (list mat-rows mat-cols mat-type :short 2 6))
      (#.+32sc2+ (list mat-rows mat-cols mat-type :int 2 6))
      (#.+32fc2+ (list mat-rows mat-cols mat-type :float 2 6))
      (#.+64fc2+ (list mat-rows mat-cols mat-type :double 2 6))
      (#.+8uc3+  (list mat-rows mat-cols mat-type :uchar 3 9))
      (#.+8sc3+  (list mat-rows mat-cols mat-type :char 3 9))
      (#.+16uc3+ (list mat-rows mat-cols mat-type :ushort 3 9))
      (#.+16sc3+ (list mat-rows mat-cols mat-type :short 3 9))
      (#.+32sc3+ (list mat-rows mat-cols mat-type :int 3 9))
      (#.+32fc3+ (list mat-rows mat-cols mat-type :float 3 9))
      (#.+64fc3+ (list mat-rows mat-cols mat-type :double 3 9))
      (#.+8uc4+  (list mat-rows mat-cols mat-type :uchar 4 12))
      (#.+8sc4+  (list mat-rows mat-cols mat-type :char 4 12))
      (#.+16uc4+ (list mat-rows mat-cols mat-type :ushort 4 12))
      (#.+16sc4+ (list mat-rows mat-cols mat-type :short 4 12))
      (#.+32sc4+ (list mat-rows mat-cols mat-type :int 4 12))
      (#.+32fc4+ (list mat-rows mat-cols mat-type :float 4 12))
      (#.+64fc4+ (list mat-rows mat-cols mat-type :double 4 12)))))


(defun step1-example (mat)

  "In OpenCv/Lisp-CV there are 1, 2, 3, and 4 channel matrices 
   or Mat/MAT objects. In this example I show you how to print 
   the contents of a MAT object, with 1 through 4 channels, by 
   using the STEP1 function to locate the proper element. Also, 
   to make the output look nicer, I format it the same type of  
   way CL:MAKE-ARRAY does."

  (let* ((window-name "MAT - STEP1-EXAMPLE")
         (mat-info (mat-info mat))
	 (channels (fifth mat-info))
         (cffi-type (fourth mat-info))
	 (data (data mat))
	 (mat-rows (rows mat))
         (mat-cols (cols mat))
         (mat-area (* mat-rows mat-cols))
         (mat-step (step1 mat))
         (a 0)
	 (b 0)
	 (g 0)
	 (r 0)
         (x 0))

    ;; Create a window to show the matrix in.
    (with-named-window (window-name +window-normal+)
      (move-window window-name 759 175)

      ;; Here, I create a tag and the initial
      ;; parentheses for the formatted output.

      (format t "~%#MAT(")
      (dotimes (i mat-rows)
	(format t "(")
	(dotimes (j mat-cols)

	  ;; In a loop, access the values of the elements at 
	  ;; channels 1-4 and get them ready for printing.

	  (setf b (mem-aref data cffi-type
			    (+ (* mat-step i) (* channels j) )))
	  (setf g (mem-aref data cffi-type
			    (+ (+ (* mat-step i) (* channels j) ) 1)))
	  (setf r (mem-aref data cffi-type
			    (+ (+ (* mat-step i) (* channels j) ) 2)))
	  (setf a (mem-aref data cffi-type
			    (+ (+ (* mat-step i) (* channels j) ) 3)))

          ;; Print a 1-4 channel element
          ;; based on number of channels

	  (cond ((eq 1 channels)
		 (format t "~a" b))
		((eq 2 channels)
		 (format t "(~a ~a)" b g))
		((eq 3 channels)
		 (format t "(~a ~a ~a)" b g r))
		((eq 4 channels)
		 (format t "(~a ~a ~a ~a)" b g r a)))

	  ;; Do additional formatting.
	  (incf  x)
	  (if (not (or (= x (+ (* mat-rows i) mat-rows)) (= x mat-area))) 
	      (format t " ") nil))
	(format t ")")
	(if (= x mat-area) (format t ")~%") (format t "~%     ")))

      (if (= channels 2) 
	  (return-from step1-example 
	    (format t "~%~%A 2 channel MAT cannot be shown in a window.~%~%"))
	  
          ;; Show the matrix in a window, because 
          ;; the window output can be interesting
          ;; and provide useful information.

	  (imshow window-name mat))

      (loop
	 
	 (let ((c (wait-key 33)))
	   (when (= c 27)
	     (return)))))))

========================================================================================================================================
#SUB
========================================================================================================================================

Subtracts matrix M2 from matrix M1

C++: MatExpr - operator

LISP-CV: (SUB (M1 MAT) (M2 MAT)) => MAT-EXPR


    Parameters:	

        M1 - A matrix.

        M2 - A matrix.


The function SUB subtracts the elements of matrix M2 from the elements of matrix M1 in order. Both 
matrices must be the same size.  You may need to coerce the result of SUB, the return value, back 
to type MAT with the function (FORCE), (or the shorthand version (>>)) to use in other functions. 


(defun sub-example ()

  "Matrix M2 is subtracted from matrix M1 with the 
   function SUB. Matrix M1, matrix M2 and the resu-
   lt(RESULT) are then printed."

  (with-object ((m1-data (alloc :uint '(53 62 85 64 23 97 52 16 12)))
		(m2-data (alloc :uint '(64 22 64 15 11 17 42 16 88))))
    (with-mat ((m1 (mat 3 3 +32s+ m1-data))
	       (m2 (mat 3 3 +32s+ m2-data)))
      (with-mat-expr ((result (sub m1 m2)))
	(format t "~%M1:~%~%")
	(print-mat m1)
	(format t "~%M2:~%~%")
	(print-mat m2)
	(format t "~%RESULT:~%~%")
        ;; The ':t' prefix enables automatic 
        ;; finalization in the (>>) function
	(print-mat (t:>> result))
	(format t "~%")))))

========================================================================================================================================
#TERM-CRITERIA
========================================================================================================================================

TERM-CRITERIA constructors.

Note: Both TERM-CRITERIA and MAKE-TERM-CRITERIA are provided in this library. The first, to match 
OpenCV's naming conventions, the second, to adhere to Common Lisp naming conventions. Except for the 
name, they are the same function. I use the TERM-CRITERIA function in the examples in this file because 
it will make them easier to compare with OpenCV examples you find online, thus making this library easier 
to learn.

C++: TermCriteria::TermCriteria()

LISP-CV: (TERM-CRITERIA) => TERM-CRITERIA

LISP-CV: (MAKE-TERM-CRITERIA) => TERM-CRITERIA

C++: TermCriteria::TermCriteria(int type, int maxCount, double epsilon)

LISP-CV: (TERM-CRITERIA (TYPE :INT) (MAX-COUNT :INT) (EPSILON :INT)) => TERM-CRITERIA

LISP-CV: (MAKE-TERM-CRITERIA (TYPE :INT) (MAX-COUNT :INT) (EPSILON :INT)) => TERM-CRITERIA

LISP-CV: (TERM-CRIT-TO-CV-TERM-CRIT (SELF TERM-CRITERIA)) => (:POINTER (:STRUCT TERM-CRITERIA-STRUCT))


    Parameters:	

        SELF - A TERM-CRITERIA object.

        TYPE - The type of termination criteria: +TERM-CRITERIA-COUNT+, +TERM-CRITERIA-EPS+ or 
               (+ +TERM-CRITERIA-COUNT+ +TERM-CRITERIA-EPS+).  

               Note: The above constants are part of the TermCriteria class in C++. 
               In the OpenCV documentation the above constants are as follows:

               TermCriteria::COUNT, TermCriteria::EPS or TermCriteria::COUNT + TermCriteria::EPS

        MAX-COUNT - The maximum number of iterations or elements to compute.

        EPSILON - The desired accuracy or change in parameters at which the iterative algorithm stops.


Note: The TERM-CRIT-TO-CV-TERM-CRIT function converts a TERM-CRITERIA object into a TERM-CRITERIA-STRUCT 
struct so it can be given to functions like SVM-PARAMS that still take the struct as a parameter. 

Note: TERM-CRITERIA and MAKE-TERM-CRITERIA are bindings for the OpenCV TermCriteria class constructor.

See: 

http://docs.opencv.org/trunk/modules/core/doc/basic_structures.html?highlight=termcriteria#termcriteria-termcriteria

for more details, and TERM-CRITERIA-STRUCT is a binding for OpenCV's CvTermCriteria struct, 

See:

http://docs.opencv.org/trunk/modules/core/doc/old_basic_structures.html?highlight=cvter#CvTermCriteria


Example:

See ANN-MLP-EXAMPLE for an example of TERM-CRITERIA in use.

========================================================================================================================================
#TOTAL
========================================================================================================================================

Returns the total number of array elements.

C++: size_t Mat::total() const

LISP-CV: (TOTAL (SELF MAT)) => :UNSIGNED-INT


    Parameters:	

        SELF - Pointer to a matrix


The method returns the number of array elements (a number of pixels if the array represents an image).


(defun total-example ()

  (with-object ((data (alloc :int '(1 2 3 4))))
    (with-mat ((mat-1 (mat 2 2 +32s+ data))
	       (mat-2 (mat 100 100 +32s+)))
      (let  ((total-1 (total mat-1))
	     (total-2 (total mat-2)))
	(format t "~%Total mumber of elements in MAT-1 = ~a~%" total-1)
	(format t "~%Total mumber of elements in MAT-2 = ~a~%~%" total-2)))))

========================================================================================================================================
#VEC-*
========================================================================================================================================


Note: The functions VEC-*, and MAKE-VEC-* are provided in this library. The VEC-* functions are 
provided to match OpenCV's naming conventions, the MAKE-VEC* functions, to adhere to Common Lisp 
naming conventions. Except for the difference in the names, all the VEC-* functions have the same 
functionality as their MAKE-VEC* counterparts. I will be using the VEC-* versions in the examples 
in this file because it makes them a easier to compare with OpenCV examples you find online, thus 
making this library easier to learn.


typedef Vec<uchar, 2> Vec2b;

LISP-CV: (VEC-2B) => VEC-2B

LISP-CV: (MAKE-VEC-2B) => VEC-2B

LISP-CV: (VEC-2B (V0 :UCHAR) (V1 :UCHAR)) => VEC-2B

LISP-CV: (MAKE-VEC-2B (V0 :UCHAR) (V1 :UCHAR)) => VEC-2B

typedef Vec<uchar, 3> Vec3b;

LISP-CV: (VEC-3B) => VEC-3B

LISP-CV: (MAKE-VEC-3B) => VEC-3B

LISP-CV: (VEC-3B (V0 :UCHAR) (V1 :UCHAR) (V2 :UCHAR)) => VEC-3B

LISP-CV: (MAKE-VEC-3B (V0 :UCHAR) (V1 :UCHAR) (V2 :UCHAR)) => VEC-3B

typedef Vec<uchar, 4> Vec4b;

LISP-CV: (VEC-4B) => VEC-4B

LISP-CV: (MAKE-VEC-4B) => VEC-4B

LISP-CV: (VEC-4B (V0 :UCHAR) (V1 :UCHAR) (V2 :UCHAR) (V3 :UCHAR)) => VEC-4B

LISP-CV: (MAKE-VEC-4B (V0 :UCHAR) (V1 :UCHAR) (V2 :UCHAR) (V3 :UCHAR)) => VEC-4B

typedef Vec<double, 2> Vec2d;

LISP-CV: (VEC-2D) => VEC-2D

LISP-CV: (MAKE-VEC-2D) => VEC-2D

LISP-CV: (VEC-2D (V0 :DOUBLE) (V1 :DOUBLE) (V2 :DOUBLE)) => VEC-2D

LISP-CV: (MAKE-VEC-2D (V0 :DOUBLE) (V1 :DOUBLE) (V2 :DOUBLE)) => VEC-2D

typedef Vec<double, 3> Vec3d;

LISP-CV: (VEC-3D) => VEC-3D

LISP-CV: (MAKE-VEC-3D) => VEC-3D

LISP-CV: (VEC-3D (V0 :DOUBLE) (V1 :DOUBLE) (V2 :DOUBLE)) => VEC-3D

LISP-CV: (MAKE-VEC-3D (V0 :DOUBLE) (V1 :DOUBLE) (V2 :DOUBLE)) => VEC-3D

typedef Vec<double, 4> Vec4d;

LISP-CV: (VEC-4D) => VEC-4D

LISP-CV: (MAKE-VEC-4D) => VEC-4D

LISP-CV: (VEC-4D (V0 :DOUBLE) (V1 :DOUBLE) (V2 :DOUBLE) (V3 :DOUBLE)) => VEC-4D

LISP-CV: (MAKE-VEC-4D (V0 :DOUBLE) (V1 :DOUBLE) (V2 :DOUBLE) (V3 :DOUBLE)) => VEC-4D

typedef Vec<double, 6> Vec6d;

LISP-CV: (VEC-6D) => VEC-6D

LISP-CV: (MAKE-VEC-6D) => VEC-6D

LISP-CV: (VEC-6D (V0 :DOUBLE) (V1 :DOUBLE) (V2 :DOUBLE) (V3 :DOUBLE) (V4 :DOUBLE) (V5 :DOUBLE)) => VEC-6D

LISP-CV: (MAKE-VEC-6D (V0 :DOUBLE) (V1 :DOUBLE) (V2 :DOUBLE) (V3 :DOUBLE) (V4 :DOUBLE) (V5 :DOUBLE)) => VEC-6D

typedef Vec<float, 2> Vec2f;

LISP-CV: (VEC-2F) => VEC-2F

LISP-CV: (MAKE-VEC-2F) => VEC-2F

LISP-CV: (VEC-2F (V0 :FLOAT) (V1 :FLOAT)) => VEC-2F

LISP-CV: (MAKE-VEC-2F (V0 :FLOAT) (V1 :FLOAT)) => VEC-2F

typedef Vec<float, 3> Vec3f;

LISP-CV: (VEC-3F) => VEC-3F

LISP-CV: (MAKE-VEC-3F) => VEC-3F

LISP-CV: (VEC-3F (V0 :FLOAT) (V1 :FLOAT) (V2 :FLOAT)) => VEC-3F

LISP-CV: (MAKE-VEC-3F (V0 :FLOAT) (V1 :FLOAT) (V2 :FLOAT)) => VEC-3F

typedef Vec<float, 4> Vec4f;

LISP-CV: (VEC-4F) => VEC-4F

LISP-CV: (MAKE-VEC-4F) => VEC-4F

LISP-CV: (VEC-4F (V0 :FLOAT) (V1 :FLOAT) (V2 :FLOAT) (V3 :FLOAT)) => VEC-4F

LISP-CV: (MAKE-VEC-4F (V0 :FLOAT) (V1 :FLOAT) (V2 :FLOAT) (V3 :FLOAT)) => VEC-4F

typedef Vec<float, 6> Vec6f;

LISP-CV: (VEC-6F) => VEC-6F

LISP-CV: (MAKE-VEC-6F) => VEC-6F

LISP-CV: (VEC-6F (V0 :FLOAT) (V1 :FLOAT) (V2 :FLOAT) (V3 :FLOAT) (V4 :FLOAT) (V5 :FLOAT)) => VEC-6F

LISP-CV: (MAKE-VEC-6F (V0 :FLOAT) (V1 :FLOAT) (V2 :FLOAT) (V3 :FLOAT) (V4 :FLOAT) (V5 :FLOAT)) => VEC-6F

typedef Vec<int, 2> Vec2i;

LISP-CV: (VEC-2I) => VEC-2I

LISP-CV: (MAKE-VEC-2I) => VEC-2I

LISP-CV: (VEC-2I (V0 :INT) (V1 :INT)) => VEC-2I

LISP-CV: (MAKE-VEC-2I (V0 :INT) (V1 :INT)) => VEC-2I

typedef Vec<int, 3> Vec3i;

LISP-CV: (VEC-3I) => VEC-3I

LISP-CV: (MAKE-VEC-3I) => VEC-3I

LISP-CV: (VEC-3I (V0 :INT) (V1 :INT) (V2 :INT)) => VEC-3I

LISP-CV: (MAKE-VEC-3I (V0 :INT) (V1 :INT) (V2 :INT)) => VEC-3I

typedef Vec<int, 4> Vec4i;

LISP-CV: (VEC-4I) => VEC-4I

LISP-CV: (MAKE-VEC-4I) => VEC-4I

LISP-CV: (VEC-4I (V0 :INT) (V1 :INT) (V2 :INT) (V3 :INT)) => VEC-4I

LISP-CV: (MAKE-VEC-4I (V0 :INT) (V1 :INT) (V2 :INT) (V3 :INT)) => VEC-4I

typedef Vec<int, 6> Vec6i;

LISP-CV: (VEC-6I) => VEC-6I

LISP-CV: (MAKE-VEC-6I) => VEC-6I

LISP-CV: (VEC-6I (V0 :INT) (V1 :INT) (V2 :INT) (V3 :INT) (V4 :INT) (V5 :INT)) => VEC-6I

LISP-CV: (MAKE-VEC-6I (V0 :INT) (V1 :INT) (V2 :INT) (V3 :INT) (V4 :INT) (V5 :INT)) => VEC-6I

typedef Vec<int, 6> Vec6i;

LISP-CV: (VEC-8I) => VEC-8I

LISP-CV: (MAKE-VEC-8I) => VEC-8I

LISP-CV: (VEC-8I (V0 :INT) (V1 :INT) (V2 :INT) (V3 :INT) (V4 :INT) (V5 :INT) (V6 :INT) (V7 :INT)) => VEC-8I

LISP-CV: (MAKE-VEC-8I (V0 :INT) (V1 :INT) (V2 :INT) (V3 :INT) (V4 :INT) (V5 :INT) (V6 :INT) (V7 :INT)) => VEC-8I

typedef Vec<short, 2> Vec2s;

LISP-CV: (VEC-2S) => VEC-2S

LISP-CV: (MAKE-VEC-2S) => VEC-2S

LISP-CV: (VEC-2S (V0 :SHORT) (V1 :SHORT)) => VEC-2S

LISP-CV: (MAKE-VEC-2S (V0 :SHORT) (V1 :SHORT)) => VEC-2S

typedef Vec<short, 3> Vec3s;

LISP-CV: (VEC-3S) => VEC-3S

LISP-CV: (MAKE-VEC-3S) => VEC-3S

LISP-CV: (VEC-3S (V0 :SHORT) (V1 :SHORT) (V2 :SHORT)) => VEC-3S

LISP-CV: (MAKE-VEC-3S (V0 :SHORT) (V1 :SHORT) (V2 :SHORT)) => VEC-3S

typedef Vec<short, 4> Vec4s;

LISP-CV: (VEC-4S) => VEC-4S

LISP-CV: (MAKE-VEC-4S) => VEC-4S

LISP-CV: (VEC-4S (V0 :SHORT) (V1 :SHORT) (V2 :SHORT) (V3 :SHORT)) => VEC-4S

LISP-CV: (MAKE-VEC-4S (V0 :SHORT) (V1 :SHORT) (V2 :SHORT) (V3 :SHORT)) => VEC-4S

typedef Vec<uchar, 2> Vec2b;

LISP-CV: (VEC-2W) => VEC-2W

LISP-CV: (MAKE-VEC-2W) => VEC-2W

LISP-CV: (VEC-2W (V0 :USHORT) (V1 :USHORT)) => VEC-2W

LISP-CV: (MAKE-VEC-2W (V0 :USHORT) (V1 :USHORT)) => VEC-2W

typedef Vec<uchar, 3> Vec3b;

LISP-CV: (VEC-3W) => VEC-3W

LISP-CV: (MAKE-VEC-3W) => VEC-3W

LISP-CV: (VEC-3W (V0 :USHORT) (V1 :USHORT) (V2 :USHORT)) => VEC-3W

LISP-CV: (MAKE-VEC-3W (V0 :USHORT) (V1 :USHORT) (V2 :USHORT)) => VEC-3W

typedef Vec<uchar, 4> Vec4b;

LISP-CV: (VEC-4W) => VEC-4W

LISP-CV: (MAKE-VEC-4W) => VEC-4W

LISP-CV: (VEC-4W (V0 :USHORT) (V1 :USHORT) (V2 :USHORT) (V3 :USHORT)) => VEC-4W

LISP-CV: (MAKE-VEC-4W (V0 :USHORT) (V1 :USHORT) (V2 :USHORT) (V3 :USHORT)) => VEC-4W


The Vec class is commonly used to describe pixel types of multi-channel arrays. 


Example:


(defun vec-example ()

  ;Create an uninitialized VEC-* object and an 
  ;initialized VEC-* object for each VEC-* type

  (let ((vec-2b-0 (t:vec-2b))
	(vec-2b-2 (t:vec-2b 1 2))
	(vec-3b-0 (t:vec-3b))
	(vec-3b-3 (t:vec-3b 1 2 3))
	(vec-4b-0 (t:vec-4b))
	(vec-4b-4 (t:vec-4b 1 2 3 4))
	(vec-2d-0 (t:vec-2d))
	(vec-2d-2 (t:vec-2d 1d0 2d0))
	(vec-3d-0 (t:vec-3d))
	(vec-3d-3 (t:vec-3d 1d0 2d0 3d0))
	(vec-4d-0 (t:vec-4d))
	(vec-4d-4 (t:vec-4d 1d0 2d0 3d0 4d0))
	(vec-6d-0 (t:vec-6d))
	(vec-6d-6 (t:vec-6d 1d0 2d0 3d0 4d0 5d0 6d0))
	(vec-2f-0 (t:vec-2f))
	(vec-2f-2 (t:vec-2f 1f0 2f0))
	(vec-3f-0 (t:vec-3f))
	(vec-3f-3 (t:vec-3f 1f0 2f0 3f0))
	(vec-4f-0 (t:vec-4f))
	(vec-4f-4 (t:vec-4f 1f0 2f0 3f0 4f0))
	(vec-2i-0 (t:vec-2i))
	(vec-2i-2 (t:vec-2i 1 2))
	(vec-6f-0 (t:vec-6f))
	(vec-6f-6 (t:vec-6f 1f0 2f0 3f0 4f0 5f0 6f0))
	(vec-3i-0 (t:vec-3i))
	(vec-3i-3 (t:vec-3i 1 2 3))
	(vec-4i-0 (t:vec-4i))
	(vec-4i-4 (t:vec-4i 1 2 3 4))
	(vec-6i-0 (t:vec-6i))
	(vec-6i-6 (t:vec-6i 1 2 3 4 5 6))
	(vec-8i-0 (t:vec-8i))
	(vec-8i-8 (t:vec-8i 1 2 3 4 5 6 7 8))
	(vec-2s-0 (t:vec-2s))
	(vec-2s-2 (t:vec-2s 1 2))
	(vec-3s-0 (t:vec-3s))
	(vec-3s-3 (t:vec-3s 1 2 3))
	(vec-4s-0 (t:vec-4s))
	(vec-4s-4 (t:vec-4s 1 2 3 4))
	(vec-2w-0 (t:vec-2w))
	(vec-2w-2 (t:vec-2w 1 2))
	(vec-3w-0 (t:vec-3w))
	(vec-3w-3 (t:vec-3w 1 2 3))
	(vec-4w-0 (t:vec-4w))
	(vec-4w-4 (t:vec-4w 1 2 3 4)))
    ;Print the values of each VEC-* object
    ;The '@' is a macro for CFFI::MEM-AREF
    (format t "~%The return value of VEC-2B-0 is: ~a~%" vec-2b-0)
    (format t "~%The elements of VEC-2B-2 are: (~a, ~a)~%" 
	    (@ vec-2b-2 :uchar) (@ vec-2b-2 :uchar 1))
    (format t "~%The return value of VEC-3B-0 is: ~a~%" vec-3b-0)
    (format t "~%The elements of VEC-3B-3 are: (~a, ~a, ~a)~%" 
	    (@ vec-3b-3 :uchar) (@ vec-3b-3 :uchar 1) (@ vec-3b-3 :uchar 2))
    (format t "~%The return value of VEC-4B-0 is: ~a" vec-4b-0)
    (format t "~%~%The elements of VEC-4B-4 are: (~a, ~a, ~a, ~a)~%" 
	    (@ vec-4b-4 :uchar) (@ vec-4b-4 :uchar 1)
	    (@ vec-4b-4 :uchar 2) (@ vec-4b-4 :uchar 3))
    (format t "~%The return value of VEC-2D-0 is: ~a~%" vec-2d-0)
    (format t "~%The elements of VEC-2D-2 are: (~a, ~a)~%" 
	    (@ vec-2d-2 :double) (@ vec-2d-2 :double 1))
    (format t "~%The return value of VEC-3D-0 is: ~a~%" vec-3d-0)
    (format t "~%The elements of VEC-3D-3 are: (~a, ~a, ~a)~%" 
	    (@ vec-3d-3 :double) (@ vec-3d-3 :double 1) (@ vec-3d-3 :double 2))
    (format t "~%The return value of VEC-4D-0 is: ~a" vec-4d-0)
    (format t "~%~%The elements of VEC-4D-4 are: (~a, ~a, ~a, ~a)~%" 
	    (@ vec-4d-4 :double) (@ vec-4d-4 :double 1)
	    (@ vec-4d-4 :double 2) (@ vec-4d-4 :double 3))
    (format t "~%The return value of VEC-6d-0 is: ~a~%" vec-6d-0)
    (format t "~%The elements of VEC-6D-6 are: (~a, ~a, ~a, ~a, ~a, ~a)~%" 
	    (@ vec-6d-6 :double) (@ vec-6d-6 :double 1) (@ vec-6d-6 :double 2) 
	    (@ vec-6d-6 :double 3)  (@ vec-6d-6 :double 4) (@ vec-6d-6 :double 5))
    (format t "~%The return value of VEC-2F-0 is: ~a~%" vec-2f-0)
    (format t "~%The elements of VEC-2F-2 are: (~a, ~a)~%"
	    (@ vec-2f-2 :float) (@ vec-2f-2 :float 1))
    (format t "~%The return value of VEC-3F-0 is: ~a~%" vec-3f-0)
    (format t "~%The elements of VEC-3F-3 are: (~a, ~a, ~a)~%" 
	    (@ vec-3f-3 :float) (@ vec-3f-3 :float 1) (@ vec-3f-3 :float 2))
    (format t "~%The return value of VEC-4F-0 is: ~a~%" vec-4f-0)
    (format t "~%The elements of VEC-4F-4 are: (~a, ~a, ~a, ~a)~%" 
	    (@ vec-4f-4 :float) (@ vec-4f-4 :float 1)
	    (@ vec-4f-4 :float 2) (@ vec-4f-4 :float 3))
    (format t "~%The return value of VEC-6F-0 is: ~a~%" vec-6f-0)
    (format t "~%The elements of VEC-6F-6 are: (~a, ~a, ~a, ~a, ~a, ~a)~%" 
	    (@ vec-6f-6 :float) (@ vec-6f-6 :float 1) (@ vec-6f-6 :float 2) 
	    (@ vec-6f-6 :float 3) (@ vec-6f-6 :float 4) (@ vec-6f-6 :float 5))
    (format t "~%The return value of VEC-2I-0 is: ~a~%" vec-2i-0)
    (format t "~%The elements of VEC-2I-2 are: (~a, ~a)~%" 
	    (@ vec-2i-2 :int) (@ vec-2i-2 :int 1))
    (format t "~%The return value of VEC-3I-0 is: ~a~%" vec-3i-0)
    (format t "~%The elements of VEC-3I-3 are: (~a, ~a, ~a)~%" 
	    (@ vec-3i-3 :int) (@ vec-3i-3 :int 1) (@ vec-3i-3 :int 2))
    (format t "~%The return value of VEC-4I-0 is: ~a~%" vec-4i-0)
    (format t "~%The elements of VEC-4I-4 are: (~a, ~a, ~a, ~a)~%" 
	    (@ vec-4i-4 :int) (@ vec-4i-4 :int 1)
	    (@ vec-4i-4 :int 2) (@ vec-4i-4 :int 3))
    (format t "~%The return value of VEC-6I-0 is: ~a~%" vec-6i-0)
    (format t "~%The elements of VEC-6I-6 are: (~a, ~a, ~a, ~a, ~a, ~a)~%" 
	    (@ vec-6i-6 :int) (@ vec-6i-6 :int 1) (@ vec-6i-6 :int 2) 
	    (@ vec-6i-6 :int 3)  (@ vec-6i-6 :int 4) (@ vec-6i-6 :int 5))
    (format t "~%The return value of VEC-8I-0 is: ~a~%" vec-8i-0)
    (format t "~%The elements of VEC-8I-8 are: (~a, ~a, ~a, ~a, ~a, ~a, ~a, ~a)~%" 
	    (@ vec-8i-8 :int) (@ vec-8i-8 :int 1) (@ vec-8i-8 :int 2) 
	    (@ vec-8i-8 :int 3) (@ vec-8i-8 :int 4) (@ vec-8i-8 :int 5)
	    (@ vec-8i-8 :int 6) (@ vec-8i-8 :int 7))
    (format t "~%The return value of VEC-2S-0 is: ~a~%" vec-2s-0)
    (format t "~%The elements of VEC-2S-2 are: (~a, ~a)~%" 
	    (@ vec-2s-2 :short) (@ vec-2s-2 :short 1))
    (format t "~%The return value of VEC-3S-0 is: ~a~%" vec-3s-0)
    (format t "~%The elements of VEC-3S-3 are: (~a, ~a, ~a)~%" 
	    (@ vec-3s-3 :short) (@ vec-3s-3 :short 1) (@ vec-3s-3 :short 2))
    (format t "~%The return value of VEC-4S-0 is: ~a~%" vec-4s-0)
    (format t "~%The elements of VEC-4S-4 are: (~a, ~a, ~a, ~a)~%" 
	    (@ vec-4s-4 :short) (@ vec-4s-4 :short 1)
	    (@ vec-4s-4 :short 2) (@ vec-4s-4 :short 3))
    (format t "~%The return value of VEC-2W-0 is: ~a~%" vec-2w-0)
    (format t "~%The elements of VEC-2W-2 are: (~a, ~a)~%" 
	    (@ vec-2w-2 :ushort) (@ vec-2w-2 :ushort 1))
    (format t "~%The return value of VEC-3W-0 is: ~a~%" vec-3w-0)
    (format t "~%The elements of VEC-3W-3 are: (~a, ~a, ~a)~%" 
	    (@ vec-3w-3 :ushort) (@ vec-3w-3 :ushort 1) (@ vec-3w-3 :ushort 2))
    (format t "~%The return value of VEC-4W-0 is: ~a~%" vec-4w-0)
    (format t "~%The elements of VEC-4W-4 are: (~a, ~a, ~a, ~a)~%~%" 
	    (@ vec-4w-4 :ushort) (@ vec-4w-4 :ushort 1)
	    (@ vec-4w-4 :ushort 2) (@ vec-4w-4 :ushort 3))))


========================================================================================================================================
#CORE - #OPERATIONS ON ARRAYS
========================================================================================================================================
========================================================================================================================================
#TRACE*
========================================================================================================================================

Returns the trace of a matrix.

C++: Scalar trace(InputArray mtx)

LISP-CV: (TRACE* (MTX MAT)) => SCALAR


    Parameters:	

        MTX - Input matrix.

The function TRACE* returns the sum of the diagonal elements of the matrix MTX.


See OpenCV Documentation at this link:

http://docs.opencv.org/trunk/modules/core/doc/operations_on_arrays.html?highlight=trace#trace

for the formula.


Note: This function is named TRACE* instead of TRACE because, TRACE is the name of a Common Lisp macro.


Example:

(defun trace*-example ()
    ;;Create a 3x3 matrix called MTX
    (with-object ((data (alloc :uchar '(1 2 3 4 5 6 7 8 9))))
      (with-mat ((mtx (mat 3 3 +8u+ data)))
	;;Print MTX
	(format t "~%MTX = ~%~%")
	(print-mat mtx)
	;;Print the sum of the diagonal of MTX
	(format t "~%The sum of the diagonal of MTX is ~a~%~%" (@ (trace* mtx) :double)))))

========================================================================================================================================
#ABS
========================================================================================================================================

Calculates an absolute value of each matrix element.

Note: The LISP-CV function ABS overloads the Common Lisp function ABS so both functions can use the 
same name. The LISP-CV function ABS provides the the same functionality as the Common Lisp function 
ABS and the OpenCV C++ ABS function. To use the Common Lisp function ABS directly, while you are in 
the LISP-CV package, you need to evaluate CL:ABS.

C++: MatExpr abs(const Mat& m)

LISP-CV: (ABS (M MAT)) => MAT-EXPR

    Parameters:	

        M - matrix.

ABS is a meta-function that is expanded to one of (ABS-DIFF) or (CONVERT-SCALE-ABS) forms:

        (DEFPARAMETER C (ABS (>> (SUB A B)))) is equivalent to (ABSDIFF A B C)

        (DEFPARAMETER C (ABS A)) is equivalent to (ABSDIFF A (SCALAR-ALL 0) C)


The output matrix has the same size and the same type as the input one except for the last case, 
where C is (EQ DEPTH +8U+). 


See also:

Matrix Expressions(MAT-EXPR), (ABS-DIFF), (CONVERT-SCALE-ABS)


Example:

(defun abs-example ()

  ;;Allocate data and create a 2x2 matrix.
  (with-object ((data (alloc :float '(4f0 -7f0 2f0 -3f0))))
    (with-mat ((mat (mat 2 2 +32f+ data)))
      ;;Print MAT.
      (format t "~%MAT:~%~%")
      (print-mat mat)
      ;;Find absolute value of all MAT elements.
      (with-mat-expr ((abs-val (abs mat)))
	(with-mat ((forced-abs-val (>> abs-val)))
	  ;;Print MAT's absolute value.
          (format t "~%The absolute value of all MAT elements:~%~%")
	  (print-mat forced-abs-val)
	  (format t "~%"))))))

========================================================================================================================================
#ABSDIFF
========================================================================================================================================

Calculates the per-element absolute difference between two arrays or between an array and a scalar.

C++: void absdiff(InputArray src1, InputArray src2, OutputArray dst)

LISP-CV: (ABSDIFF (SRC1 MAT) (SRC2 MAT) (DEST MAT))

    Parameters:	

        SRC1 - first input array or a scalar.

        SRC2 - second input array or a scalar.

        DEST - output array that has the same size and type as input arrays.

The function absdiff calculates:

        Absolute difference between two arrays when they have the same size and type.

        Absolute difference between an array and a scalar when the second array is constructed from
        Scalar or has as many elements as the number of channels in SRC1:

        Absolute difference between a scalar and an array when the first array is constructed from 
        Scalar or has as many elements as the number of channels in SRC2:

        where I is a multi-dimensional index of array elements. In case of multi-channel arrays, ea-
        ch channel is processed independently.

Note:

Saturation is not applied when the arrays have the depth +32S+. You may even get a negative value i-
n the case of overflow.


See also:

(ABS) 


Example:

(defun absdiff-example (&optional 
			  (camera-index 
			   *camera-index*) 
			  (width *default-width*)
			  (height *default-height*))

  "The function ABSDIFF calculates the per-element absolute 
   difference between FRAME(the camera stream) and SCALAR a-
   nd outputs the result to a window...Makes for quite an i-
   nteresting effect."

  (with-captured-camera (cap camera-index :width width :height height)
    (let ((scalar (mat 1 1 +64f+ (t:scalar 128 128 128)))
	  (window-name "ABSDIFF Example"))
      (if (not (is-opened cap)) 
	  (return-from absdiff-example 
	    (format t "Cannot open the video camera")))
      (with-named-window (window-name +window-normal+)
	(move-window window-name 759 175)
	(with-mat ((frame (mat)))
	  (loop
	     (read cap frame)
	     (absdiff frame scalar frame)
	     (imshow window-name frame)
	     (let ((c (wait-key 33)))
	       (when (= c 27)
		 (return)))))))))

========================================================================================================================================
#ADD-WEIGHTED
========================================================================================================================================

Calculates the weighted sum of two arrays.

C++: void addWeighted(InputArray src1, double alpha, InputArray src2, double beta, double gamma, OutputArray dst, int dtype=-1)

LISP-CV: (ADD-WEIGHTED (SRC1 MAT) (ALPHA :DOUBLE) (SRC2 MAT) (BETA :DOUBLE) (GAMMA :DOUBLE) (DEST MAT) &OPTIONAL ((DTYPE :INT) -1)) 
          => :VOID

    Parameters:	

        SRC1 - First input array.

        ALPHA - Weight of the first array elements.

        SRC2 - Second input array of the same size and channel number as SRC1.

        BETA - Weight of the second array elements.

        DEST - Output array that has the same size and number of channels as the input arrays.

        GAMMA- Scalar added to each sum.

        DTYPE - Optional depth of the output array; when both input arrays have the same depth, DTYPE 
                can be set to -1, which will be equivalent to (DEPTH SRC1).


The function ADD-WEIGHTED calculates the weighted sum of two arrays as follows:


See OpenCV documentation for a description and formula:

http://docs.opencv.org/modules/core/doc/operations_on_arrays.html?highlight=addwe#addweighted


See also:

(ADD), (SUBTRACT), (SCALE-ADD), (CONVERT-TO), Matrix Expressions(MAT-EXPR)



(defun add-weighted-example (filename1 filename2)

  "Try using the <lisp-cv-source-directory>/ubuntu-logo.jpg 
   and the <lisp-cv-source-directory>/blue.jpg to get a nic-
   e effect on this example."

  (let ((window-name "Linear Blend - ADD-WEIGHTED Example"))
    (with-named-window (window-name +window-normal+)
      (set-window-property window-name +wnd-prop-fullscreen+ 
			   +window-fullscreen+)
      (set-window-property window-name +wnd-prop-aspectratio+ 
			   +window-freeratio+)
      (with-object ((alpha (alloc :int 62))
		    (beta (alloc :int 175))
		    (gamma (alloc :int 0)))
	(create-trackbar "Alpha" window-name alpha 150)
	(create-trackbar "Beta" window-name beta 1500)
	(create-trackbar "Gamma" window-name gamma 215)
	(with-mat ((src1 (imread filename1))
		   (src2 (imread filename2))
		   (dest (mat)))
	  (if (empty src1) 
	      (return-from add-weighted-example 
		(format t "~%Error loading SRC1~%~%")))
	  (if (empty src2) 
	      (return-from add-weighted-example 
		(format t "~%Error loading SRC2~%~%")))
	  (loop
	     (add-weighted src1 (coerce (/ (@ alpha :int) 100) 'double-float) 
                           src2 (coerce (/  (@ beta :int) 100) 'double-float) 
			   (coerce (@ gamma :int) 'double-float) dest)
	     (imshow window-name dest)
	     (let ((c (wait-key 33)))
	       (when (= c 27)
		 (return)))))))))


========================================================================================================================================
BITWISE-AND
========================================================================================================================================

Calculates the per-element bit-wise conjunction of two arrays.

C++: void bitwise_and(InputArray src1, InputArray src2, OutputArray dst, InputArray mask=noArray())

LISP-CV: (BITWISE-AND (SRC1 MAT) (SRC2 MAT) (DEST MAT) &OPTIONAL ((MASK MAT) (MAT))) => :VOID


    Parameters:	

        SRC1 - First input array.

        SRC2 - Second input array.

        DEST - Output array that has the same size and type as the input arrays.

        MASK - Optional operation mask, 8-bit single channel array, that 
               specifies elements of the output array to be changed.


The function calculates the per-element bit-wise logical conjunction for two arrays when SRC1 and SRC2 
have the same size. In case of floating-point arrays, their machine-specific bit representations (usually 
IEEE754-compliant) are used for the operation. In case of multi-channel arrays, each channel is processed 
independently.


(defun bitwise-and-example (filename-1 filename-2)

  "Calculates the per-element bit-wise conjunction of two 
   images.

   Note: You are encouraged to use the black-and-white.png 
   and the white-and-black.png in the LISP-CV images direc-
   tory to get the full effect of this example."

  (let* ((image-1 (imread filename-1 1))
	 (image-2 (imread filename-2 1))
	 (dest (mat (rows image-1) (cols image-1) +8uc3+))
	 (window-name-1 "IMAGE-1 - BITWISE-AND Example")
	 (window-name-2 "IMAGE-2 - BITWISE-AND Example")
	 (window-name-3 "DEST - BITWISE-AND Example"))
    (named-window window-name-1 +window-normal+)
    (named-window window-name-2 +window-normal+)
    (named-window window-name-3 +window-normal+)
    (move-window window-name-1 310 175)
    (move-window window-name-2 760 175)
    (move-window window-name-3 1210 175)
    (bitwise-and image-1 image-2 dest)
    (imshow window-name-1 image-1)
    (imshow window-name-2 image-2)
    (imshow window-name-3 dest)
    (loop while (not (= (wait-key 0) 27)))
    (del-mat image-1)
    (del-mat image-2)
    (del-mat dest)
    (destroy-all-windows)))


========================================================================================================================================
BITWISE-NOT
========================================================================================================================================

Inverts every bit of an array.

C++: void bitwise_not(InputArray src, OutputArray dst, InputArray mask=noArray())

LISP-CV: (BITWISE-NOT (SRC MAT) (DEST MAT) &OPTIONAL ((MASK MAT) (MAT))) => :VOID


    Parameters:	

        SRC - Input array.

        DEST - Output array that has the same size and type as the input array.

        MASK - Optional operation mask, 8-bit single channel array, that 
               specifies elements of the output array to be changed.


The function calculates per-element bit-wise inversion of the input array. In case of a floating-point 
input array, its machine-specific bit representation (usually IEEE754-compliant) is used for the operation. 
In case of multi-channel arrays, each channel is processed independently.


(defun bitwise-not-example (filename-1 filename-2)

  "Inverts every bit of IMAGE-1 and IMAGE-2.

   Note: You are encouraged to use the black-and-white.png 
   in the LISP-CV images directory and an image of your ow-
   n choosing to get the full effect of this example."

  (let* ((image-1 (imread filename-1 1))
	 (image-2 (imread filename-2 1))
	 (dest-1 (mat (rows image-1) (cols image-1) +8uc3+))
         (dest-2 (mat (rows image-2) (cols image-2) +8uc3+))
	 (window-name-1 "IMAGE-1 - BITWISE-NOT Example")
	 (window-name-2 "IMAGE-2 - BITWISE-NOT Example")
	 (window-name-3 "DEST-1 - BITWISE-NOT Example")
	 (window-name-4 "DEST-2 - BITWISE-NOT Example"))
    (named-window window-name-1 +window-normal+)
    (named-window window-name-2 +window-normal+)
    (named-window window-name-3 +window-normal+)
    (named-window window-name-4 +window-normal+)
    (move-window window-name-1 485 98)
    (move-window window-name-2 894 98)
    (move-window window-name-3 485 444)
    (move-window window-name-4 894 444)
    (bitwise-not image-1 dest-1)
    (bitwise-not image-2 dest-2)
    (imshow window-name-1 image-1)
    (imshow window-name-2 dest-1)
    (imshow window-name-3 image-2)
    (imshow window-name-4 dest-2)
    (loop while (not (= (wait-key 0) 27)))
    (del-mat image-1)
    (del-mat image-2)
    (del-mat dest-1)
    (del-mat dest-2)
    (destroy-all-windows)))


========================================================================================================================================
BITWISE-OR
========================================================================================================================================

Calculates the per-element bit-wise disjunction of two arrays.

C++: void bitwise_or(InputArray src1, InputArray src2, OutputArray dst, InputArray mask=noArray())

LISP-CV: (BITWISE-OR (SRC1 MAT) (SRC2 MAT) (DEST MAT) &OPTIONAL ((MASK MAT) (MAT))) => :VOID

when
    Parameters:	

        SRC1 - First input array.

        SRC2 - Second input array.

        DEST - Output array that has the same size and type as the input arrays.

        MASK - Optional operation mask, 8-bit single channel array, that 
               specifies elements of the output array to be changed.


The function calculates the per-element bit-wise logical disjunction for two arrays when SRC1 and SRC2 
have the same size. In case of floating-point arrays, their machine-specific bit representations (usually 
IEEE754-compliant) are used for the operation. In case of multi-channel arrays, each channel is processed 
independently.


(defun bitwise-or-example (filename-1 filename-2)

  "Calculates the per-element bit-wise disjunction of two 
   images.

   Note: You are encouraged to use the black-and-white.png 
   and the white-and-black.png in the LISP-CV images direc-
   tory to get the full effect of this example."

  (let* ((image-1 (imread filename-1 1))
	 (image-2 (imread filename-2 1))
	 (dest (mat (rows image-1) (cols image-1) +8uc3+))
	 (window-name-1 "IMAGE-1 - BITWISE-OR Example")
	 (window-name-2 "IMAGE-2 - BITWISE-OR Example")
	 (window-name-3 "DEST - BITWISE-OR Example"))
    (named-window window-name-1 +window-normal+)
    (named-window window-name-2 +window-normal+)
    (named-window window-name-3 +window-normal+)
    (move-window window-name-1 310 175)
    (move-window window-name-2 760 175)
    (move-window window-name-3 1210 175)
    (bitwise-or image-1 image-2 dest)
    (imshow window-name-1 image-1)
    (imshow window-name-2 image-2)
    (imshow window-name-3 dest)
    (loop while (not (= (wait-key 0) 27)))
    (del-mat image-1)
    (del-mat image-2)
    (del-mat dest)
    (destroy-all-windows)))


========================================================================================================================================
BITWISE-XOR
========================================================================================================================================

Calculates the per-element bit-wise “exclusive or” operation on two arrays.

C++: void bitwise_xor(InputArray src1, InputArray src2, OutputArray dst, InputArray mask=noArray())

LISP-CV: (BITWISE-XOR (SRC1 MAT) (SRC2 MAT) (DEST MAT) &OPTIONAL (MASK MAT)) => :VOID

    Parameters:	

        SRC1 - First input array.

        SRC2 - Second input array.

        DEST - Output array that has the same size and type as the input arrays.

        MASK - Optional operation mask, 8-bit single channel array, that 
               specifies elements of the output array to be changed.


The function calculates the per-element bit-wise logical “exclusive-or” operation for two arrays 
when SRC1 and SRC2 have the same size. In case of floating-point arrays, their machine-specific bit 
representations (usually IEEE754-compliant) are used for the operation. In case of multi-channel 
arrays, each channel is processed independently.


(defun bitwise-xor-example (filename-1 filename-2)

  "Calculates the per-element bit-wise “exclusive or” oper-
   ation of two images.

   Note: You are encouraged to use the black-and-white.png 
   and the white-and-black.png in the LISP-CV images direc-
   tory to get the full effect of this example."

  (let* ((image-1 (imread filename-1 1))
	 (image-2 (imread filename-2 1))
	 (dest (mat (rows image-1) (cols image-1) +8uc3+))
	 (window-name-1 "IMAGE-1 - BITWISE-XOR Example")
	 (window-name-2 "IMAGE-2 - BITWISE-XOR Example")
	 (window-name-3 "DEST - BITWISE-XOR Example"))
    (named-window window-name-1 +window-normal+)
    (named-window window-name-2 +window-normal+)
    (named-window window-name-3 +window-normal+)
    (move-window window-name-1 310 175)
    (move-window window-name-2 760 175)
    (move-window window-name-3 1210 175)
    (bitwise-xor image-1 image-2 dest)
    (imshow window-name-1 image-1)
    (imshow window-name-2 image-2)
    (imshow window-name-3 dest)
    (loop while (not (= (wait-key 0) 27)))
    (del-mat image-1)
    (del-mat image-2)
    (del-mat dest)
    (destroy-all-windows)))


========================================================================================================================================
#CALC-COVAR-MATRIX
========================================================================================================================================

Calculates the covariance matrix of a set of vectors.


C++: void calcCovarMatrix(InputArray samples, OutputArray covar, InputOutputArray mean, int flags, int ctype=CV_64F)

LISP-CV: (CALC-COVAR-MATRIX (SAMPLES MAT) (COVAR MAT) (MEAN MAT) (FLAGS :INT) ((CTYPE :INT) +64F+)) => :VOID


    Parameters:	

        SAMPLES - Samples stored either as separate matrices or as rows/columns of a single matrix.

        COVAR - Output covariance matrix of the type CTYPE and square size.

        MEAN - Input or output (depending on the flags) array as the average value of the input vectors.

        FLAGS -

          Operation flags as a combination of the following values


                      +COVAR-SCRAMBLED+ 

                      +COVAR-NORMAL+ 

                      +COVAR-USE-AVG+

                      +COVAR-SCALE+ 

                      +COVAR-ROWS+ 

                      +COVAR-COLS+ 


See OpenCV documentation at this link for a description of the flags and formulae: 

http://docs.opencv.org/trunk/modules/core/doc/operations_on_arrays.html?highlight=calccovar#calccovarmatrix

Note: At the above link, the first variant of this function is not currently supported in this library.


        CTYPE - Type of the matrix; it equals ‘+64F+’ by default.

        
The functions CALC-COVAR-MATRIX calculate the covariance matrix and, optionally, the mean vector of 
the set of input vectors.


See also:

PCA, (MUL-TRANSPOSED), (MAHALANOBIS)


Example:

See MAHALANOBIS-EXAMPLE in this file.

========================================================================================================================================
#CHECK-RANGE
========================================================================================================================================

Checks every element of an input array for invalid values.

C++: bool checkRange(InputArray a, bool quiet=true, Point* pos=0, double minVal=-DBL_MAX, double maxVal=DBL_MAX )

LISP-CV: (CHECK-RANGE (A MAT) &OPTIONAL ((QUIET :BOOLEAN) T) ((POS POINT) (CFFI::NULL-POINTER)) ((MIN-VAL :DOUBLE) +-DBL-MAX+)
                      ((MAX-VAL :DOUBLE)  +DBL-MAX+)) => :BOOLEAN

    Parameters:	

        A - Input array.

        QUIET - A flag, indicating whether the functions quietly return NIL when the array elements 
                are out of range or they throw an exception.

        POS - Optional output parameter, where the position of the first outlier is stored.

        MIN-VAL - inclusive lower boundary of valid values range.

        MAX-VAL - exclusive upper boundary of valid values range.

The function CHECK-RANGE checks that every array element is neither NaN nor infinite. When (< MINVAL +-DBL-MAX+) 
and (< MAX-VAL +DBL-MAX+), the function also checks that each value is between MIN-VAL and MAX-VAL. In case of 
multi-channel arrays, each channel is processed independently. If some values are out of range, position of the 
first outlier is stored in POS (when: (NOT (EQ POS (CFFI::NULL-POINTER))) ). Then, the functions either return NIL 
(when: (EQ QUIET T) ) or throw an exception.


Example:

(defun check-range-example ()

  (format t "~%create matrix a with integers 0 thru 10.~%")
  (with-object ((data (alloc :int '(1 2 3 4 5 6 7 8 9))))
    (with-mat ((a (mat 3 3 +32s+ data)))
      (format t "~%a:~%~%")
      (print-mat a)
      (format t "~%~%")
      (format t "run check-range with quiet param set to t...~%~%~%") 
      (format t "since 1 and 9 are elements in the matrix,~%~%") 
      (format t "check-range will return nil, or false, here,~%~%")
      (format t "meaning that all of the matrix elements do not~%~%")
      (format t "lie between 1 and 9:~%~%~%")

      (format t "return of check-range: ~a~%~%~%" (check-range a t (gc:point) 1d0 9d0))

      (format t "now, run check-range with the quiet param set to nil...~%~%") 
      (format t "check-range returns true. because all matrix elements~%~%") 
      (format t "are between 0.5 and 9.5:~%~%~%")
      (format t "return of check-range: ~a~%~%" (check-range a t (gc:point) 0.5d0 9.5d0)))))

========================================================================================================================================
#COMPLETE-SYMM
========================================================================================================================================


Copies the lower or the upper half of a square matrix to another half.


C++: void completeSymm(InputOutputArray mtx, bool lowerToUpper=false)

LISP-CV: (COMPLETE-SYMM (MTX MAT) &OPTIONAL (LOWER-TO-UPPER NIL)) => :VOID


    Parameters:	

        MTX - Input-Output floating-point square matrix.

        LOWER-TO-UPPER - Operation flag; if true, the lower half is copied to the upper half. Otherwise, 
                         the upper half is copied to the lower half.



The function COMPLETE-SYMM copies the lower half of a square matrix to its another half. The matrix 
diagonal remains unchanged:


See OpenCV documentation at this link for a formula:

http://docs.opencv.org/trunk/modules/core/doc/operations_on_arrays.html?highlight=symm#completesymm


See also:

(FLIP), (TRANSPOSE)


(defun complete-symm-example ()

  ;;Create double float matrix data for MAT1.

  ;;Note: If I used the same data array for 
  ;;MAT1 and MAT2, this example, as is other
  ;;wise, wouldn't work. The data array is a-
  ;;lso written to by COMPLETE-SYMM.

  (with-object ((data1 (alloc :float '(1f0 2f0 3f0 4f0 5f0 
				       6f0 7f0 8f0 9f0))))
    ;;Create double float matrix MAT1.
    (with-mat ((mat1 (mat 3 3 +32f+ data1)))
      (format t "~%Original MAT1: ~%~%")
      ;;Print original MAT1.
      (print-mat mat1)
      (format t "~%")
      ;;Copy the lower half to the upper
      ;;See documentation link in:
      ;;<LISP-CV-SRC-DIR>EXAMPLES/EXAMPLES.LISP 
      ;;for precise equation.
      (complete-symm mat1 t)
      (format t "MAT1 after copying lower half to upper: ~%~%")
      ;;Print MAT1 after COMPLETE-SYMM.
      (print-mat mat1))
    ;;Create double float matrix data.
    (with-object ((data2 (alloc :float '(1f0 2f0 3f0 4f0 5f0 
					 6f0 7f0 8f0 9f0))))
      ;;Create double float matrix data for MAT2.
      (with-mat ((mat2 (mat 3 3 +32f+ data2)))
	(format t "~%Original MAT2: ~%~%")
	;;Print original MAT2.
	(print-mat mat2)
	(format t "~%")
	;;Copy the upper half to the lower.
	(complete-symm mat2 nil)
	(format t "MAT2 after copying upper half to lower: ~%~%")
	;;Print MAT2 after COMPLETE-SYMM.
	(print-mat mat2)
	(format t "~%")))))

========================================================================================================================================
#CONVERT-SCALE-ABS
========================================================================================================================================

Scales, calculates absolute values, and converts the result to 8-bit.

C++: void convertScaleAbs(InputArray src, OutputArray dst, double alpha=1, double beta=0)

LISP-CV: (CONVERT-SCALE-ABS  (SRC MAT) (DEST MAT) &OPTIONAL ((ALPHA :DOUBLE) 1.0D0) ((BETA :DOUBLE) 0.0D0)) => :VOID

    Parameters:	

        SRC - input array.

        DEST - output array.

        ALPHA - optional scale factor.

        BETA - optional delta added to the scaled values.

On each element of the input array, the function CONVERT-SCALE-ABS performs three operations sequentially: 
scaling, taking an absolute value, conversion to an unsigned 8-bit type. In case of multi-channel arrays, 
the function processes each channel independently. 


Example:

(defun convert-scale-abs-example (&optional (cam *camera-index*) 
				    (width *default-width*)
				    (height *default-height*))

  (with-captured-camera (cap cam :width width :height height)
    (if (not (is-opened cap)) 
	(return-from convert-scale-abs-example 
	  (format t "Cannot open the video camera")))  
    (let ((window-name "CONVERT-SCALE-ABS Example"))
      (with-named-window (window-name +window-normal+)
	(move-window window-name 759 175)
	;;Create a matrix
	(with-mat ((mat (mat-ones 6 4 +32f+)))
	  ;;Print original type of MAT
	  (format t "~%MAT type before conversion = ~a(or +32f+)~%~%" 
		  (mat-type mat))
	  ;;Print original MAT before conversion
	  (format t "Printing MAT before the conversion~%~%")
	  (print-mat mat)
	  ;;CONVERT-SCALE-ABS, scales by 2 and 
	  ;;adds 5, to every elemement of MAT,
          ;;and converts the result to 8-bit
	  (convert-scale-abs mat mat 2d0 5d0)
	  ;;Print converted MAT type which is 8-bit
	  (format t "~%MAT type after conversion = ~a(or +8u+)" 
		  (mat-type mat))
	  ;;Print converted MAT
	  (format t "~%~%Printing MAT after the conversion~%~%")
	  (print-mat mat)
          (format t "~%")
	  (with-mat ((frame (mat)))
	    (loop
	       (read cap frame)
	       ;;Run CONVERT-SCALE-ABS on the camera
               ;;output, just to see what happens
	       (convert-scale-abs frame frame 2d0 5d0)
	       (imshow window-name frame)
	       (let ((c (wait-key 33)))
		 (when (= c 27)
		   (return))))))))))

========================================================================================================================================
#DET
========================================================================================================================================

Returns the determinant of a square floating-point matrix.

C++: double determinant(InputArray mtx)

LISP-CV: (DET (MTX MAT)) => :DOUBLE

    Parameters:	

        MYX - Input matrix that must have +32FC1+ or +64FC1+ type and square size.
 

The function determinant calculates and returns the determinant of the specified matrix. For small 
matrices, the direct method is used. For larger matrices, the function uses LU factorization with 
partial pivoting.

For symmetric positively-determined matrices, it is also possible to use (EIGEN) decomposition to 
calculate the determinant.

See also:

(TRACE), (INVERT), (SOLVE), (EIGEN), Matrix Expressions(MAT-EXPR)


;Note: If a function has a GC: prefix, that 
;means it is automatically Garbage Collected


Example:

(defun det-example ()
  ;;Create matrix data.
  (with-object ((data-1 (alloc :float '(1f0 2f0 3f0 4f0 5f0 6f0 5f0 7f0 9f0)))
		(data-2 (alloc :float '(4f0 5f0 6f0 6f0 5f0 4f0 4f0 6f0 5f0))))
    ;;Create matrix with zero determinant.
    (let ((zero-det-mat (gc:mat 3 3 +32f+ data-1))
	  ;;Create matrix with non-zero determinant.
	  (mat (gc:mat 3 3 +32f+ data-2))      
	  (zero-det-mat-inv 0)
	  (mat-inv 0)
          (identity-mat 0))
      ;;Print MAT.
      (format t "~%MAT =~%~%")
      (print-mat mat)
      ;;Print ZERO-DET-MAT.
      (format t "~%ZERO-DET-MAT =~%~%")
      (print-mat zero-det-mat)
      (format t "~%")
      ;;Check if the determinant of MAT is 0. It
      ;;isn't, so an inverse can be determined.
      (format t "The determinant of MAT = ~a~%~%" 
	      (det mat))
      ;;Check if the determinant of ZERO-DET-MAT is 0. 
      ;;It is not, so an inverse cannot be determined.
      (format t "The determinant of ZER0-DET-MAT = ~a~%~%" 
	      (det zero-det-mat))
      ;;Find inverse of MAT and print it.
      (setf mat-inv (gc:>> (gc:inv mat +decomp-lu+)))
      (format t "The inverse of MAT =~%~%")
      (print-mat mat-inv)
      ;;Find inverse of ZERO-DET-MAT and 
      ;;print it. It will be all zeros.
      (setf zero-det-mat-inv  
	    (gc:>> (gc:inv zero-det-mat +decomp-lu+)))
      (format t "~%The inverse of ZERO-DET-MAT =~%~%")
      (print-mat zero-det-mat-inv)
      ;;Multiply MAT-INV by MAT to verify it is 
      ;;the true inverse. If it is, the output 
      ;;will be an identity matrix. The return 
      ;;value of MUL is converted from MAT-EXPR,
      ;;back to MAT, with the (>>) function.
      (setf identity-mat (gc:>> (gc:mul mat-inv mat)))
      ;;Print the identity matrix
      (format t "~%The product of MAT-INV and MAT =~%~%")
      (print-mat identity-mat)
      (format t "~%"))))

========================================================================================================================================
#DIVIDE
========================================================================================================================================

Performs per-element division of two arrays or a scalar by an array.

C++: void divide(InputArray src1, InputArray src2, OutputArray dst, double scale=1, int dtype=-1)

LISP-CV: (DIVIDE (SRC1 MAT) (SRC2 MAT) (DEST MAT) &OPTIONAL ((SCALE :DOUBLE) 1) ((DTYPE :INT) -1)) => :VOID

C++: void divide(double scale, InputArray src2, OutputArray dst, int dtype=-1)

LISP-CV: (DIVIDE (SCALE :DOUBLE) (SRC2 MAT) (DEST MAT) &OPTIONAL ((DTYPE :INT) -1)) => :VOID


    Parameters:	

        SRC1 - First input array.

        SRC2 - Second input array of the same size and type as SRC2.

        SCALE - Scalar factor.

        DST - Output array of the same size and type as SRC2.

        DTYPE - Optional depth of the output array; if -1, DEST will have depth (DEPTH SRC2), but in 
                case of an array-by-array division, you can only pass -1 when (EQ (DEPTH SRC1) (DEPTH SRC2)).


See OpenCv documenetation:

http://docs.opencv.org/trunk/modules/core/doc/operations_on_arrays.html?highlight=divide#divide

for a description and formulae:


See also:

(MULTIPLY), (ADD), (SUBTRACT), Matrix Expressions(MAT-EXPR)


(defun divide-example ()

  "In this example, DIVIDE is used to find 
   the per element quotient of M1 and M2,
   Then DIVIDE is used to find the per ele-
   ment quotient of a scalar and a new M1."

  (with-scalar ((scalar (scalar 5)))
    (with-mat ((m1 (mat-ones 3 3 +32f+))
	       (m2 (assign (mat-ones 3 3 +32f+) scalar)))
      (with-mat ((result (mat 3 3 +32f+)))
	(divide m1 m2 result)
	(format t "~%M1:~%~%")
	(print-mat m1)
	(format t "~%M2:~%~%")
	(print-mat m2)
	(format t "~%RESULT:~%~%")
	(print-mat result)))
    (with-mat ((m1 (assign 
		    (mat-ones 3 3 +32f+) 
		    scalar))
	       (result (mat 3 3 +32f+)))
      (divide 7d0 m1 result)
      (format t "~%M1:~%~%")
      (print-mat m1)
      (format t "~%RESULT: ~%~%")
      (print-mat result)
      (format t "~%"))))

========================================================================================================================================
#EXP
========================================================================================================================================

Calculates the exponent of every array element.

Note: The LISP-CV function EXP overloads the Common Lisp function EXP so both functions can use the 
same name. The LISP-CV function EXP provides the the same functionality as the Common Lisp function 
EXP and the OpenCV 'exp' function. To use the Common Lisp function EXP directly, while you are in the 
LISP-CV package, you need to evaluate CL:EXP.

C++: void exp(InputArray src, OutputArray dst)

LISP-CV: (EXP (SRC MAT) (DEST MAT)) => :VOID


    Parameters:	

        SRC - Input array.

        DEST - Output array of the same size and type as SRC.


The function EXP calculates the exponent of every element of the input array:

See OpenCV documentation:

http://docs.opencv.org/modules/core/doc/operations_on_arrays.html?highlight=log#exp 

for a description and formula.


See also:

(LOG), (CART-TO-POLAR), (POLAR-TO-CART), (PHASE), (POW), (SQRT), (MAGNITUDE)


Example:

(defun exp-example ()
  ;;Create double float matrix data
  (with-object ((data (alloc :double '(1d0 2d0 3d0 4d0 5d0 
				       6d0 7d0 8d0 9d0))))
    ;;Create double float matrix
    (with-mat ((mat (mat 3 3 +64f+ data)))
      (format t "~%MAT: ~%~%")
      ;;Print MAT
      (print-mat mat)
      ;;Calculate exponent of each element of 
      ;;MAT, using MAT as destination matrix
      (format t "~%Calculate exponent of each element of MAT: ~%~%")
      (exp mat mat)
      (format t "MAT: ~%~%")
      ;;Print MAT
      (print-mat mat)
      ;;Calculating natural logarithm of each 
      ;;matrix element of MAT, virtually reve-
      ;;rts MAT to it's original state
      (format t "~%Calculate natural logarithm or each element of MAT: ~%~%")
      (log mat mat)
      (format t "MAT: ~%~%")
      ;;Print MAT
      (print-mat mat)
      (format t "~%"))))

========================================================================================================================================
#FLIP
========================================================================================================================================

Flips a 2D array around vertical, horizontal, or both axes.

C++: void flip(InputArray src, OutputArray dst, int flipCode)

LISP-CV: (FLIP (SRC MAT) (DEST MAT) (FLIP-CODE :INT)) => :VOID

    Parameters:	

        SRC - Input array.

        DEST - Output array of the same size and type as SRC.

        FLIP-CODE - A flag to specify how to flip the array; 0 means flipping around the x-axis and
                    positive value (for example, 1) means flipping around y-axis. Negative value 
                    (for example, -1) means flipping around both axes (see the discussion below for 
                    the formulas).

The function FLIP flips the array in one of three different ways (row and column indices are 0-based).

The example scenarios of using the function are the following:

        Vertical flipping of the image (EQ FLIP-CODE 0) to switch between top-left and bottom-left 
        image origin. This is a typical operation in video processing on Microsoft Windows* OS.

        Horizontal flipping of the image with the subsequent horizontal shift and absolute difference 
        calculation to check for a vertical-axis symmetry (> FLIP-CODE 0).

        Simultaneous horizontal and vertical flipping of the image with the subsequent shift and absolute 
        difference calculation to check for a central symmetry (< FLIP-CODE  0).

        Reversing the order of point arrays ((> FLIP-CODE 0) OR (EQ FLIP-CODE 0)).


See also:

(TRANSPOSE) , (REPEAT) , (COMPLETE-SYMM)


Example:

(defun flip-example (&optional (cam *camera-index*))

  "Note: In this example I use all 3 types of memory management, 
   manual memory management, with-* macros and TG finalizers."

  ;;Capture camera feed 
  (with-captured-camera (cap cam :width 640 :height 480)
    ;;Allocate matrix data
    (with-object ((data (alloc :uchar '(1 2 3 4 5 6 7 8 9))))
      ;;Create a data matrix, MAT  
      (let* ((mat (gc:mat 3 3 +8u+ data))    
	     ;;Create array of MAT clones
	     (mat-clone-arr (make-array 3 :initial-contents 
					(list 
					 (gc:clone mat) (gc:clone mat) (gc:clone mat))))
	     ;;Initialize array of FRAME clones
	     (frame-clone-arr (make-array 3 :initial-contents '(0 0 0)))
	     ;;Make array of window names
	     (window-name-arr 
	      (make-array 6 :initial-contents 
			  (list
			   "Matrix flipped on both axes - FLIP Example"
			   "Matrix flipped on x-axis - FLIP Example"
			   "Matrix flipped on y-axis - FLIP Example"
			   "Camera output flipped on both axes - FLIP Example"
			   "Camera output flipped on x-axis - FLIP Example"
			   "Camera output flipped on y-axis - FLIP Example"))))
	;;Create array of windows
	(dotimes (i 6)
	  (named-window (aref window-name-arr i) +window-normal+))
	;;Move windows to specified locations
	(move-window (aref window-name-arr 0) 288 150)
	(move-window (aref window-name-arr 1) 738 150)
	(move-window (aref window-name-arr 2) 1188 150)
	(move-window (aref window-name-arr 3) 288 518)
	(move-window (aref window-name-arr 4) 738 518)
	(move-window (aref window-name-arr 5) 1188 518)
	;;Flip the first, second and third MAT clones we created 
	;;around the x, y and both axes, respectively
	(dotimes (i 3)
	  (flip (aref mat-clone-arr i) (aref mat-clone-arr i) (- i 1)))
	;;Show the first, second and third 
	;;MAT clones in the top windows
	(dotimes (i 3)
	  (imshow (aref window-name-arr i) (aref mat-clone-arr i)))
	(with-mat ((frame (mat)))
	  (loop
	     ;;Assign camera feed to FRAME
	     (read cap frame)
	     ;;Make 3 frame clones
	     (dotimes (i 3)
	       (setf (aref frame-clone-arr i) (gc:clone frame)))
	     ;;Flip the first, second and third FRAME clones we 
	     ;;created around the x, y and both axes respectively
	     (dotimes (i 3)
	       (flip (aref frame-clone-arr i) (aref frame-clone-arr i) (- i 1)))
	     ;;Show all FRAME clones in windows
	     (dotimes (i 3)
	       (imshow (aref window-name-arr (+ i 3)) (aref frame-clone-arr i)))
	     ;;Clean up used memory
	     (dotimes (i 3)
	       (del-mat (aref frame-clone-arr i)))
	     (let ((c (wait-key 33)))
	       (when (= c 27)
		 (destroy-all-windows)
		 (return)))))))))

========================================================================================================================================
#IN-RANGE-S
========================================================================================================================================

Checks if array elements lie between the elements of two other arrays.

C++: void inRange(InputArray src, InputArray lowerb, InputArray upperb, OutputArray dst)

LISP-CV: (IN-RANGE-S (SRC MAT) (LOWERB SCALAR) (UPPERB SCALAR) (DEST MAT)) => :VOID


    Parameters:	

        SRC - First input array.

        LOWERB - A scalar.

        UPPERB - A scalar.

        DEST - Output array of the same size as SRC and +8U+ type.


All the arrays must have the same type, except the destination, and the same size (or ROI size).


Example:

(defun in-range-s-example (&optional 
			     (cam *camera-index*) 
			     (width *default-width*)
			     (height *default-height*))

  ;;Set camera feed to CAP and set camera feed width/height
  (with-captured-camera (cap cam :width width :height height)  
    (let ((window-name-1 "Original camera feed - IN-RANGE-S Example")
	  (window-name-2 "Only red objects - IN-RANGE-S Example"))
      (if (not (is-opened cap)) 
	  (return-from in-range-s-example 
	    (format t "Cannot open the video camera")))
      (format t "~%Frame Size : ~ax~a~%~%" 
	      (get* cap +cap-prop-frame-width+)
	      (get* cap +cap-prop-frame-height+))
      (with-named-window (window-name-1 +window-normal+)
	(with-named-window (window-name-2 +window-normal+)
	  (move-window window-name-1 533 175)
	  (move-window window-name-2 984 175)
	  (with-mat ((frame (mat))
                     (img-hsv (mat))
		     (img-thresh (mat)))
	    ;;Iterate through each frames of the video
	    (loop
	       ;;Set camera feed to FRAME
	       (read cap frame)
	       (with-mat ((src (clone frame)))
		 (with-scalar ((lower-hsv (scalar 170 160 60))
			       (upper-hsv (scalar 180 2556 256)))
		   ;;Smooth the original image using Gaussian kernel
		   (gaussian-blur src src (size 5 5) 0.0d0 0.0d0)
		   ;;Change the color format from BGR to HSV
		   (cvt-color src img-hsv +bgr2hsv+)
		   ;;Threshold the HSV image and create a binary image
		   (in-range-s img-hsv lower-hsv upper-hsv img-thresh)
		   ;;Smooth the binary image using Gaussian kernel
		   (gaussian-blur img-thresh img-thresh (size 5 5) 0.0d0 0.0d0)
		   (imshow window-name-1 src)
		   (imshow window-name-2 img-thresh))
		 (let ((c (wait-key 33)))
		   (when (= c 27)
		     (return)))))))))))

========================================================================================================================================
#INVERT
========================================================================================================================================

Finds the inverse or pseudo-inverse of a matrix.

C++: double invert(InputArray src, OutputArray dst, int flags=DECOMP_LU)

LISP-CV: (INVERT (SRC MAT) (DEST MAT) &OPTIONAL ((FLAGS :INT) +DECOMP-LU+))) => :DOUBLE

    Parameters:	

        SRC - Input floating-point M x N matrix.

        DEST - Output matrix of N x M size and the same type as SRC.

        flags -

        Inversion method :

            +DECOMP-LU+ Gaussian elimination with the optimal pivot element chosen.

            +DECOMP-SVD+ singular value decomposition (SVD) method.

            +DECOMP-CHOLESKY+ Cholesky decomposition; the matrix must 
                              be symmetrical and positively defined.


The function INVERT inverts the matrix SRC and stores the result in DEST . When the matrix SRC is 
singular or non-square, the function calculates the pseudo-inverse matrix (the DEST matrix) so that 
(NORM (- (* SRC DST) I)) is minimal, where I is an identity matrix.

In case of the +DECOMP-LU+ method, the function returns non-zero value if the inverse has been successfully 
calculated and 0 if SRC is singular.


In case of the +DECOMP-SVD+ method, the function returns the inverse condition number of SRC (the 
ratio of the smallest singular value to the largest singular value) and 0 if SRC is singular. The 
SVD method calculates a pseudo-inverse matrix if SRC is singular.

Similarly to +DECOMP-LU+ , the method +DECOMP-CHOLESKY+ works only with non-singular square matrices 
that should also be symmetrical and positively defined. In this case, the function stores the inverted 
matrix in DEST and returns non-zero. Otherwise, it returns 0.


See also:

(SOLVE), SVD


Example:

(defun invert-example (&optional 
			 (cam *camera-index*) 
			 (width *default-width*)
			 (height *default-height*)) 

  (with-captured-camera (cap cam :width width :height height)
    (if (not (is-opened cap)) 
	(return-from invert-example 
	  (format t "Cannot open the video camera")))
    (let ((invert-return 0)
	  (identity-mat 0)
	  ;;Create an array of window names
	  (window-name-arr 
	   (make-array 6 :initial-contents 
		       (list
			"Original MAT - INVERT Example"
			"Inverted MAT - INVERT Example"
			"IDENTITY-MAT - INVERT Example"
			"Camera output - 1 channel float - INVERT Example"
			"Camera output inverted - INVERT Example"
			"Identity MAT - INVERT Example")))
	  (n (coerce (/ 1 255) 'double-float)))
      ;;Create array of windows
      (dotimes (i 6)
	(named-window (aref window-name-arr i) +window-normal+))
      ;;Move windows to specified locations
      (move-window (aref window-name-arr 0) 288 150)
      (move-window (aref window-name-arr 1) 738 150)
      (move-window (aref window-name-arr 2) 1188 150)
      (move-window (aref window-name-arr 3) 288 518)
      (move-window (aref window-name-arr 4) 738 518)
      (move-window (aref window-name-arr 5) 1188 515)
      ;;Allocate matrix data and create a square matrix
      (with-object ((data (alloc :float '(4f0 -7f0 2f0 -3f0))))
	(with-mat ((mat (mat 2 2 +32f+ data))
		   ;;Create a destination matrix 
		   ;;the same size/type as MAT
		   (dest (mat 2 2 +32f+)))
	  ;;Print MAT
          (format t "~%MAT:~%~%")
	  (print-mat mat)
	  ;;Find inverse of MAT
          (format t "~%Finding inverse of MAT...~%")
	  (setf invert-return (invert mat dest +decomp-lu+))
	  ;;Print the return of INVERT
	  (format t "~%Return from Invert Function = ~a~%(non-zero means a success!)~%~%" 
		  invert-return)
	  ;;Print the inverse of MAT
          (format t "The inverse of MAT:~%~%")
	  (print-mat dest)
	  (format t "~%")
	  ;;Multiply MAT by its inverse. If the inversion was 
	  ;;a success the output will be an identity matrix
	  (format t "Multiplying MAT by its inverse...~%~%")
	  (setf identity-mat (gc:>> (gc:mul mat dest))) 
	  (format t "Operation was a success! Print identity matrix!:~%~%")
	  (print-mat identity-mat)
	  (format t "~%")
	  ;;Show MAT, its inverse and the identity 
	  ;;matrix in the top windows
	  (imshow (aref window-name-arr 0) mat)
	  (imshow (aref window-name-arr 1) dest)
	  (imshow (aref window-name-arr 2) identity-mat)
	  (with-mat ((frame (mat)))
	    (loop ;;Read in camera feed
	       (read cap frame)
	       ;;Make a clone of the camera feed, DEST
	       (with-mat ((dest (clone frame))
			  ;;Crop FRAME to make it a square matrix, set to ROI
			  (roi (roi frame (gc:rect 0 0 (rows frame) (rows frame)))))
		 ;;Convert ROI to 1 channel image
		 (cvt-color roi roi +bgr2gray+)
		 ;;Convert ROI to a float(+32F+) matrix
		 (convert-to roi roi +32f+ n)
		 ;;Show the float matrix in bottom-left window
		 (imshow (aref window-name-arr 3) roi)
		 ;;Find the inverse of ROI and show it in 
		 ;;bottom-center window, just for fun. 
                 ;;Note: Running invert on a matrix this 
                 ;;big makes the example run slowly.
		 (invert roi dest +decomp-lu+)
		 (imshow (aref window-name-arr 4) dest)
		 ;;Find out if inverse was a success by multiplying 
                 ;;the original ROI by the INVERT function's output. 
		 ;;Then show the resulting identity matrix in the b-
                 ;;ottom-right window. 
                 ;;Note: Running MUL on a matrix this big makes the 
                 ;;example slow too.
		 (with-mat ((identity-mat (>> (mul roi dest))))
		   (imshow (aref window-name-arr 5) identity-mat)))
	       (let ((c (wait-key 33)))
		 (when (= c 27)
		   (destroy-all-windows)
		   (return))))))))))

========================================================================================================================================
#LOG
========================================================================================================================================

Calculates the natural logarithm of every array element.

Note: The LISP-CV function LOG overloads the Common Lisp function LOG so both functions can use the 
same name. The LISP-CV function LOG provides the the same functionality as the Common Lisp function 
LOG and the OpenCV 'log' function. To use the Common Lisp function LOG directly, while in the LISP-CV
package, you need to evaluate CL:LOG.

C++: void log(InputArray src, OutputArray dst)

LISP-CV: (LOG (SRC MAT) (DEST MAT)) => :VOID


    Parameters:	

        SRC - Input array.

        DST - Output array of the same size and type as SRC.


The function LOG calculates the natural logarithm of the absolute value of every element of the 
input array:


See OpenCV documentation:

http://docs.opencv.org/modules/core/doc/operations_on_arrays.html?highlight=log#log

for a description and formula.


See also:

(EXP), (CART-TO-POLAR), (POLAR-TO-CART), (PHASE), (POW), (SQRT), (MAGNITUDE)


Example:

(defun log-example ()

  ;;Create double float matrix data
  (with-object ((data (alloc :double '(1d0 2d0 3d0 4d0 5d0 
				       6d0 7d0 8d0 9d0))))
    (with-mat ((mat (mat 3 3 +64f+ data)))
      (format t "~%MAT:~%~%")
      ;;Print MAT
      (print-mat mat)
      ;;Calculate natural logarithm of each element 
      ;;of MAT, using MAT as destination matrix
      (format t "~%Calculate natural logarithm... ~%~%")
      (log mat mat)
      (format t "MAT:~%~%")
      ;;Print MAT
      (print-mat mat)
      (format t "~%"))))

========================================================================================================================================
#MAGNITUDE
========================================================================================================================================

Calculates the magnitude of 2D vectors.

C++: void magnitude(InputArray x, InputArray y, OutputArray magnitude)

LIP-CV: (MAGNITUDE (X MAT) (Y MAT) (MAGNITUDE MAT)) => :VOID


    Parameters:	

        X - Floating-point array of x-coordinates of the vectors.

        Y - Floating-point array of y-coordinates of the vectors; it must have the same size as X.

        MAGNITUDE - Output array of the same size and type as X.


The function magnitude calculates the magnitude of 2D vectors formed from the corresponding elements 
of x and y arrays:


See OpenCV documentation here:

http://docs.opencv.org/trunk/modules/core/doc/operations_on_arrays.html?highlight=magnitude#magnitude

for the formula.


See also:

(CART-TO-POLAR), (POLAR-TO-CART), (PHASE), (SQRT)


Example:

(defun magnitude-example ()

  (with-mat ((x (mat 1 1 +32f+ (t:scalar 3)))
	     (y (mat 1 1 +32f+ (t:scalar -5)))
	     (magnitude (mat 1 1 +32f+)))

    (magnitude x y magnitude)

    (format t "~%The magnitude of X and Y = ")
    (print-mat magnitude)
    (format t "~%")))

========================================================================================================================================
#MAHALANOBIS
========================================================================================================================================

Calculates the Mahalanobis distance between two vectors.


C++: double Mahalanobis(InputArray v1, InputArray v2, InputArray icovar)

LISP-CV: (MAHALANOBIS (V1 MAT) (V2 MAT) (ICOVAR MAT)) => :DOUBLE


    Parameters:	

        VEC1 - First 1D input vector.

        VEC2 - Second 1D input vector.

        ICOVAR - Inverse covariance matrix.


The function MAHALANOBIS calculates and returns the weighted distance between two vectors:


See OpenCV Documentation at this link:

http://docs.opencv.org/trunk/modules/core/doc/operations_on_arrays.html?highlight=mahalanobi#mahalanobis

for the formula.


The covariance matrix may be calculated using the (CALC-COVAR-MATRIX) function and then inverted using 
the (INVERT) function (preferably using the +DECOMP-SVD+ method, as the most accurate).


Example:

(defun mahalanobis-example ()

  "Here we calculate Covariance Matrix, Inverse 
   Covariance Matrix and Mahalanobis Distance."

  (let ((rows 5)
	(cols 3)
	(x (make-array '(5 3) :initial-contents
		       '((20f0 55f0 119f0)
			 (123f0 333f0 11f0)
			 (113f0 321f0 11f0)
			 (103f0 313f0 191f0)
			 (123f0 3433f0 1100f0)))))

    (with-mat ((points (mat rows cols +32f+ (t:scalar 0)))
	       (mean (mat))
	       (covar (mat))
	       (invcovar (mat))
	       (p1 (mat points (gc:range 0 1) (gc:range-all)))
	       (p2 (mat points (gc:range 1 2) (gc:range-all)))
               (mat (mat 3 3 +32f+)))

      (dotimes (i rows)
	(dotimes (j cols)
	  (setf (@ :float points i j) (aref x i j))))
      (format t "~%Input matrix: ~%~%")
      (print-mat points)
      (format t "~%")
      ;;For covariance:
      (calc-covar-matrix points covar mean 
			 (+ +covar-normal+ +covar-rows+) -1)
      (assign mat (gc:scalar (- (rows points) 1)))
      (format t "Covar matrix: ~%~%")
      (setf covar (gc:>> (gc:div covar mat)))
      (print-mat covar)
      ;;For inverse matrix:
      (invert covar invcovar +decomp-svd+)
      (format t "~%Inverse covar matrix: ~%~%")
      (print-mat invcovar)
      (format t "~%Mahalanobis distance between: ~%~%")
      (format t "P1: ")
      (print-mat p1)
      (format t "~%and~%")
      (format t "~%P2: ")
      (print-mat p2)
      (format t "~%is: ")
      ;;For Mahalanobis Distance:
      (format t "~a~%~%"(mahalanobis p1 p2 invcovar)))))

========================================================================================================================================
#MAX
========================================================================================================================================

Calculates per-element maximum of two arrays.

Note: The LISP-CV function MAX overloads the Common Lisp function MAX so both functions can use the 
same name. The LISP-CV function MAX provides the the same functionality as the Common Lisp function 
MAX and the OpenCV 'max' function. To use the Common Lisp function MAX directly, while in the LISP-CV 
package, you need to evaluate CL:MAX.

C++: void max(InputArray src1, InputArray src2, OutputArray dst)

LISP-CV: (MAX (SRC1 MAT) (SRC2 MAT) (DEST MAT)) => :VOID    (loop while (not (= (wait-key 0) 27)))


    Parameters:	

        SRC1 - First input array.

        SRC2 - Second input array of the same size and type as SRC1.

        DEST - Output array of the same size and type as SRC1.


The function MAX calculates the per-element maximum of two arrays. When the input array is multi-channel, 
each channel is compared with value independently.


See also:

(MIN), (COMPARE), (IN-RANGE), (MIN-MAX-LOC), Matrix Expressions(MAT-EXPR)


Example:

(defun max-example (&optional (cam 0)
		      (width *default-width*)
		      (height *default-height*))

  "Look at the first window and notice that whatever is black
   in the first window has a beautiful glow in the third wind-
   ow. You can change the effect by altering the color of the 
   matrix MAT-3 in the middle window with the trackbar. The t-
   rackbar changes the scalar value the ASSIGN method uses to
   decide what to set each element of MAT-3 to."

  ;;Create camera capture, CAP, set CAP to default width and height
  (with-captured-camera (cap cam :width width :height height)  
    (let* ((window-name-1 "MAT-3 after THRESHOLD - MAX-Example")
	   (window-name-2 "MAT-5 after ASSIGN - MAX-Example")
	   (window-name-3 "MAT-4 after MAX - MAX-Example"))
      ;;Create two matrices: MAT-1 and MAT-2(used to show how MAX works)
      (with-object ((data-1 (alloc :int '(1 2 3 4 5 6 7 8 9)))
		    (data-2 (alloc :int '(9 8 7 6 5 4 3 2 1))))
	(with-mat ((mat-1 (mat 3 3 +32s+ data-1))
		   (mat-2 (mat 3 3 +32s+ data-2))
		   ;;Create destination matrix of same size and type: DEST
		   (dest (mat 3 3 +32s+))
		   ;;Create 3 matrices used to hold 
		   ;;data we use later in the example
		   (mat-3 (mat height width +8u+))
		   (mat-4 (mat height width +8u+))
		   (mat-5 (mat height width +8u+))) 
	  ;;Create windows and move to specified locations
	  (with-named-window (window-name-1 +window-normal+)
	    (with-named-window (window-name-2 +window-normal+)
	      (with-named-window (window-name-3 +window-normal+)
		(move-window window-name-1 310 175)
		(move-window window-name-2 760 175)
		(move-window window-name-3 1210 175)
		;;Print MAT-1
		(format t "~%~%MAT-1:~%~%")
		(print-mat mat-1)
		(format t "~%~%")
		;;Print MAT-2
		(format t "MAT-2:~%~%")
		(print-mat mat-2)
		(format t "~%~%")
		;;Find per element maximum of 
		;;MAT-1 and MAT-2, set to DEST
		(max mat-1 mat-2 dest)
		;;Print DEST
		(format t "Per element maximum of MAT-1 and  MAT-2:~%~%")
		(print-mat dest)
		(format t "~%~%")
		;;Allocate :int pointer for trackbar to change
		(with-object ((val (alloc :int 76)))
		  ;;Create trackbar on middle window which changes 
		  ;;the scalar value ASSIGN uses in loop
		  (create-trackbar "Value of mat-3" window-name-2 val 255)
		  (with-mat ((frame (mat)))
		    (loop
		       ;;Set camera feed to FRAME
		       (read cap frame)
		       ;;Convert FRAME to 1 channel 
		       ;;grayscale image, set to mat-1
		       ;;FRAME stays the same
		       (cvt-color frame mat-3 +bgr2gray+)
		       ;;Convert FRAME to 1 channel 
		       ;;grayscale image, set to MAT-4
		       ;;FRAME stays the same
		       (cvt-color frame mat-4  +bgr2gray+)
		       ;;Apply a fixed-level threshold to 
		       ;;each array element of MAT-3
		       (threshold mat-3 mat-3 128d0 255d0 +thresh-binary-inv+)
		       ;;Assign each element of MAT-5 a scalar value
		       (assign mat-5 (scalar (mem-aref val :int)))
		       ;;Find the maximum of each element 
		       ;;of MAT-4 and MAT-5, set to MAT-4
		       (max mat-4 mat-5 mat-4)
		       ;;Show MAT-3, MAT-5 and MAT-4 in windows
		       (imshow window-name-1 mat-3)
		       (imshow window-name-2 mat-5)
		       (imshow window-name-3 mat-4)
		       (let ((c (wait-key 33)))
			 (when (= c 27)
			   (return))))))))))))))

========================================================================================================================================
#MEAN
========================================================================================================================================

Calculates an average (mean) of array elements.

C++: Scalar mean(InputArray src, InputArray mask=noArray())

LISP-CV: (MEAN (SRC MAT) &OPTIONAL ((MASK MAT) (MAT)))) => SCALAR


    Parameters:	

        SRC - Input array that should have from 1 to 4 channels so that the result can be stored in SCALAR.

        MASK - Optional operation mask.

The function mean calculates the mean value M of array elements, independently for each channel, and 
returns it:

See OpenCv documentation at this link for the formula:

http://docs.opencv.org/trunk/modules/core/doc/operations_on_arrays.html?highlight=mean#mean

When all the mask elements are 0’s, the function returns (SCALAR-ALL 0).


See also:

(COUNT-NON-ZERO), (MEAN-STD-DEV), (NORM), (MIN-MAX-LOC)


Example:

(defun mean-example (&optional (cam *camera-index*) 
		       (width *default-width*)
		       (height *default-height*))

  "Position the rectangle in the window by moving the trackbar 
   sliders. The rectangle gets its color from the averaging of 
   the pixels in the region of the rectangle. This averaging is
   calculated by the function MEAN. For example if you position 
   the rectangle over some thing red, the rectangle will turn a 
   shade of red. The rectangle starts at 0,0 X,Y coordinates."

  (with-captured-camera (cap cam :width width :height height)
    (let* ((window-name "IMG - MEAN Example")
           (n 10))
      ;;Initialize the rectangle location/
      ;;dimension variables
      (with-rect ((rect-x (alloc :int '(0)))
		  (rect-y (alloc :int '(0)))
		  (rect-width (alloc :int (list (round (/ width n)))))
		  (rect-height (alloc :int (list (round (/ height n))))))      
	;;Create fullscreen window
	(with-named-window (window-name +window-autosize+)
	  (set-window-property window-name +wnd-prop-fullscreen+ 
			       +window-fullscreen+)
	  (move-window window-name 624 100)
	  (with-mat ((frame (mat)))
	    (loop
	       ;;Set FRAME to a frame of the camera feed
	       (read cap frame)
	       ;;Print rectangle location/dimensions
	       (format t "RECT-X: ~a~%~%" (mem-ref rect-x :int))
	       (format t "RECT-Y: ~a~%~%" (mem-ref rect-y :int))
	       (format t "RECT-WIDTH: ~a~%~%" (mem-ref rect-width :int))
	       (format t "RECT-HEIGHT: ~a~%~%" (mem-ref rect-height :int))
	       ;;Create trackbars to control the rectangle location/dimensions
	       (create-trackbar "RECT-X" window-name rect-x width)
	       (create-trackbar "RECT-Y" window-name rect-y height)
	       (create-trackbar "RECT-WIDTH" window-name rect-width width)
	       (create-trackbar "RECT-HEIGHT" window-name rect-height height)
	       ;;Instantiate logic for the location/dimensions 
	       ;;of the rectangle based on the trackbar input
	       (if (equal (mem-ref rect-x :int) 0) 
		   (setf (mem-ref rect-x :int) 0))
	       (if (> (mem-ref rect-x :int) 
		      (- width (mem-ref rect-width :int))) 
		   (setf (mem-ref rect-x :int) 
			 (- width (mem-ref rect-width :int))))
	       (if (equal (mem-ref rect-y :int) 0) 
		   (setf (mem-ref rect-y :int) 1))
	       (if (> (mem-ref rect-y :int) 
		      (- height (mem-ref rect-height :int))) 
		   (setf (mem-ref rect-y :int) 
			 (- height (mem-ref rect-height :int))))
	       (if (< (mem-ref rect-width :int) 1) 
		   (setf (mem-ref rect-width :int) 1))
	       (if (< (mem-ref rect-height :int) 1) 
		   (setf (mem-ref rect-height :int) 1))
	       ;;Create an empty matrix
	       (with-mat ((img (mat)))
		 ;;Make a copy of FRAME, IMG, to use 
		 ;;for the fullscreen camera output
		 (copy-to frame img)
		 ;;Set position parameters of the RECTANGLE we will create, 
		 ;;that will be the color of the mean of the pixels in FRAME, 
		 ;;to that of the position of the region of interest of FRAME
		 (with-point ((point-1 (point (mem-ref rect-x :int) 
					      (mem-ref rect-y :int)))
			      (point-2 (point (+ (mem-ref rect-x :int) 
						 (mem-ref rect-width :int)) 
					      (+ (mem-ref rect-y :int) 
						 (mem-ref rect-height :int)))))
		   ;;Set region of interest of FRAME to the rectangle 
		   ;;location/dimensions we specified
		   (with-rect ((roi (rect (mem-ref rect-x :int) (mem-ref rect-y :int)
					  (mem-ref rect-width :int) (mem-ref rect-height :int))))
		     ;;Set region of interest of FRAME to ROI. This region of 
		     ;;interest is the where we find the mean of the pixels. 
		     (with-mat ((frame (roi frame roi)))
		       ;;Find mean of FRAME and set to 
		       ;;COLOR parameter of RECTANGLE
		       (with-scalar ((color (mean frame (mat))))
			 ;;Create a rectangle the color of 
			 ;;the mean of the pixels it covers
			 (rectangle img point-1 point-2 color +filled+ 4 0)
			 (imshow window-name img))))))
	       (let ((c (wait-key 33)))
		 (when (= c 27)
		   (return))))))))))

========================================================================================================================================
#MIN
========================================================================================================================================

Calculates per-element minimum of two arrays.

Note: The LISP-CV function MIN overloads the Common Lisp function MIN so both functions can use the 
same name. The LISP-CV function MIN provides the the same functionality as the Common Lisp function 
MIN and the OpenCV 'min' function. To use the Common Lisp function MIN directly, while in the LISP-CV 
package, you need to evaluate CL:MIN.

C++: void min(InputArray src1, InputArray src2, OutputArray dst)

LISP-CV: (MIN (SRC1 MAT) (SRC2 MAT) (DEST MAT)) => :VOID


    Parameters:	

        SRC1 - First input array.

        SRC2 - Second input array of the same size and type as SRC1.

        DEST - Output array of the same size and type as SRC1.


The function MIN calculates the per-element minimum of two arrays. When the input array is multi-
channel, each channel is compared with value independently.


See also:

(MAX), (COMPARE), (IN-RANGE), (MIN-MAX-LOC), Matrix Expressions(MAT-EXPR)


Example:

(defun min-example (&optional (cam 0)
		      (width *default-width*)
		      (height *default-height*))

  "Look at the first window and notice that whatever is black
   in the first window has a beautiful glow in the third wind-
   ow. You can change the effect by altering the color of the 
   matrix MAT-3 in the middle window with the trackbar. The t-
   rackbar changes the scalar value the ASSIGN method uses to
   decide what to set each element of MAT-3 to."

  ;;Create video capture, CAP. Set CAP to default width and height
  (with-captured-camera (cap cam :width width :height height)   
    ;;Create two matrices: MAT-1 and MAT-2(used to show how MIN works)
    (with-object ((data-1 (alloc :int '(1 2 3 4 5 6 7 8 9)))
		  (data-2  (alloc :int '(9 8 7 6 5 4 3 2 1))))
      (with-mat ((mat-1 (mat 3 3 +32s+ data-1))
		 (mat-2 (mat 3 3 +32s+ data-2))
		 ;;Create destination matrix of same size and type, DEST
		 (dest (mat 3 3 +32s+))
		 ;;Create 3 matrices used to hold the
		 ;;data we use later in the example
		 (mat-3 (mat height width +8u+))
		 (mat-4 (mat height width +8u+))
		 (mat-5 (mat height width +8u+)))
	(let ((window-name-1 "MAT-3 after THRESHOLD - MIN-Example")
	      (window-name-2 "MAT-5 after ASSIGN - MIN-Example")
	      (window-name-3 "MAT-4 after MIN - MIN-Example")) 
	  ;;Create windows and move to specified locations
	  (with-named-window (window-name-1 +window-normal+)
	    (with-named-window (window-name-2 +window-normal+)
	      (with-named-window (window-name-3 +window-normal+)
		(move-window window-name-1 310 175)
		(move-window window-name-2 760 175)
		(move-window window-name-3 1210 175)
		;;Allocate int pointer for trackbar to change
		(with-object ((val (alloc :int '(128))))
		  ;;Create trackbar on the middle window that changes 
		  ;;the scalar value the method ASSIGN will use.
		  (create-trackbar "Value of mat-3" window-name-2 val 255)
		  ;;Print MAT-1
		  (format t "~%MAT-1:~%~%")
		  (print-mat mat-1)
		  (format t "~%")
		  ;;Print MAT-2
		  (format t "MAT-2:~%~%")
		  (print-mat mat-2)
		  (format t "~%")
		  ;;Find per element minimum of 
		  ;;MAT-1 and MAT-2, set to DEST
		  (min mat-1 mat-2 dest)
		  ;;Print DEST
		  (format t "Per element minimum of MAT-1 and  MAT-2:~%~%")
		  (print-mat dest)
		  (format t "~%")
		  (with-mat ((frame (mat)))
		    (loop
		       ;;Set camera feed to FRAME
		       (read cap frame)
		       ;;Convert FRAME to 1 channel grayscale 
		       ;;image, set to MAT-3. FRAME stays the 
		       ;;same
		       (cvt-color frame mat-3 +bgr2gray+)
		       ;;Convert FRAME to 1 channel grayscale 
		       ;;image, set to MAT-4. FRAME stays the 
		       ;;same
		       (cvt-color frame mat-4  +bgr2gray+)
		       ;;Apply a fixed-level threshold to 
		       ;;each array element of MAT-3
		       (threshold mat-3 mat-3 128d0 255d0 +thresh-binary-inv+)
		       
		       ;;Assign each element of MAT-5 a scalar value

		       ;;Note: The 't:' prefix to SCALAR toggles its 
		       ;;finalizer to true. Also, '@' is a macro for 
		       ;;CFFI::MEM-AREF

		       (assign mat-5 (t:scalar (@ val :int)))
		       ;;Find the minimum of each element 
		       ;;of MAT-4 AND MAT-5, set to MAT-4
		       (min mat-4 mat-5 mat-4)
		       ;;Show MAT-3, MAT-4 and MAT-5 in windows
		       (imshow window-name-1 mat-3)
		       (imshow window-name-2 mat-5)
		       (imshow window-name-3 mat-4) 
		       (let ((c (wait-key 33)))
			 (when (= c 27)
			   (return))))))))))))))

========================================================================================================================================
#MIN-MAX-LOC
========================================================================================================================================

Finds the global minimum and maximum in an array.

C++: void minMaxLoc(InputArray src, double* minVal, double* maxVal=0, Point* minLoc=0, Point* maxLoc=0, InputArray mask=noArray())

LISP-CV: (MIN-MAX-LOC (SRC MAT) (MIN-VAL :POINTER) &OPTIONAL ((MAX-VAL :POINTER) (CFFI::NULL-POINTER)) 
                     ((MIN-LOC POINT) (CFFI::NULL-POINTER)) ((MAX-LOC POINT) (CFFI::NULL-POINTER)) ((MASK MAT) data))) :VOID

    Parameters:	

        SRC - Input single-channel array.

        MIN-VAL - Pointer to the returned minimum value; (CFFI::NULL-POINTER) is used if not required.

        MAX-VAL - Pointer to the returned maximum value; (CFFI::NULL-POINTER) is used if not required.

        MIN-LOC - Pointer to the returned minimum location (in 2D case); (CFFI::NULL-POINTER) is used if not required.

        MAX-LOC - Pointer to the returned maximum location (in 2D case); (CFFI::NULL-POINTER) is used if not required.

        MASK - Optional mask used to select a sub-array.


The functions MIN-MAX-LOC find the minimum and maximum element values and their positions. The extremums 
are searched across the whole array or, if mask is not an empty array, in the specified array region.

The functions do not work with multi-channel arrays. If you need to find minimum or maximum elements across 
all the channels, use (RESHAPE) first to reinterpret the array as single-channel. Or extract the particular 
channel using either (EXTRACT-IMAGE-COI), or (MIX-CHANNELS), or (SPLIT).


See also

(MAX), (MIN), (COMPARE), (IN-RANGE), (EXTRACT-IMAGE-COI), (MIX-CHANNELS), (SPLIT), (RESHAPE)


Example: 

(defun min-max-loc-example (filename &optional (cam 0))

  "Printing the 'checkerboard.png' image in the LISP-CV images 
   directory to use for the object you want to track and using 
   the 'resized-checkerboard.png' for the template image gives
   a nice effect in this example. It is very basic, so you'll
   have to play with the distance you hold the object from the 
   camera to get a good track and then move the object slowly
   Probably good to be in a well lighted room."

  (with-captured-camera (cap cam :width 640 :height 480) 
    ;;Create windows
    (let* ((window-name-1 "TPL - MIN-MAX-LOC Example")
	   (window-name-2 "FRAME - MIN-MAX-LOC Example")
	   (window-name-3 "MATCHES - MIN-MAX-LOC Example")
	   ;;Initialize size parameters 
	   ;;for the matches
           (iwidth 0)
	   (iheight 0))      
      ;;Create windows
      (with-named-window (window-name-1 +window-autosize+)
	(with-named-window (window-name-2 +window-autosize+) 
	  (with-named-window (window-name-3 +window-autosize+) 
	    ;;Move windows to specified locations     
	    (move-window window-name-1 325 0)
	    (move-window window-name-2 325 260)
	    (move-window window-name-3 969 260)
	    (with-point ((minloc (point))
			 (maxloc (point)))
	      (with-object ((minval (alloc :double 0d0))
			    (maxval (alloc :double 0d0)))
		;;Set rectangle color
		(with-scalar ((color (scalar 0 0 255)))
		  (with-mat ((frame (mat))
			     ;;Load template image
			     (tpl (imread filename 1)))
		    (loop
		       ;;Set camera feed to FRAME
		       (read cap frame)
		       (setf iwidth (+ (- (cols frame) (cols tpl)) 1))
		       (setf iheight (+ (- (rows frame) (rows tpl)) 1))
		       ;;Create  matrix to hold all of the matches
		       (with-mat ((matches (mat iheight iwidth +32f+)))
			 ;;Run MATCH-TEMPLATE on each frame of the camera 
			 ;;feed and run NORMALIZE on each match 
			 (match-template frame tpl matches +tm-ccoeff-normed+)
			 (normalize matches matches 0d0 1d0 +norm-minmax+)
			 ;;Run MIN-MAX-LOC to set point 
					;coordinates for each match
			 (min-max-loc matches minval maxval minloc maxloc)
			 (rectangle frame (gc:point (x minloc) (y minloc)) 
				    (gc:point (+ (x minloc) (cols tpl)) 
					      (+ (y minloc) (rows tpl))) 
				    color 10 0 0)
			 ;;Show image, template and matches in a window
			 (imshow window-name-1 tpl)
			 (imshow window-name-2 frame)
			 (imshow window-name-3 matches)
			 (let ((c (wait-key 33)))
			   (when (= c 27)
			     (return)))))))))))))))

========================================================================================================================================
#MUL-TRANSPOSED
========================================================================================================================================


Calculates the product of a matrix and its transposition.


C++: void mulTransposed(InputArray src, OutputArray dst, bool aTa, InputArray delta=noArray(), double scale=1, int dtype=-1 )

LISP-CV: (MUL-TRANSPOSED (SRC MAT) (DEST MAT) (A-T-A :BOOLEAN) &OPTIONAL ((DELTA MAT) (MAT)) ((SCALE :DOUBLE) 1D0) 
                        ((DTYPE :INT) -1)) => :VOID


    Parameters:	

        SRC - Input single-channel matrix. Note that unlike (GEMM), the function can multiply not 
              only floating-point matrices.

        DEST - Output square matrix.

        A-T-A - Flag specifying the multiplication ordering. See the description below.

        DELTA - Optional delta matrix subtracted from SRC before the multiplication. When the matrix 
                is empty (EQ DELTA (MAT)), it is assumed to be zero, that is, nothing is subtracted. 
                If it has the same size as SRC , it is simply subtracted. Otherwise, it is “repeated” 
                (see (REPEAT) ) to cover the full SRC and then subtracted. Type of the delta matrix, 
                when it is not empty, must be the same as the type of created output matrix. See the 
                DTYPE parameter description below.

        SCALE - Optional scale factor for the matrix product.

        DTYPE - Optional type of the output matrix. When it is negative, the output matrix will have 
                the same type as SRC . Otherwise, it will be type=CV_MAT_DEPTH(dtype) (<--internal C++ 
                function. See <OpenCV-source-directory>/modules/core/include/opencv2/core/cvdef.h) that 
                should be either +32F+ or +64F+.


The function MUL-TRANSPOSED calculates the product of SRC and its transposition.


See OpenCV documentation at this link:

http://docs.opencv.org/trunk/modules/core/doc/operations_on_arrays.html?highlight=multransposed#multransposed

for further description and formulae.


See also:

(CALC-COVAR-MATRIX), (GEMM), (REPEAT), (REDUCE)


Example:


To show this functions works as stated, first multiply A by its transpose, using the MUL function:
(The GC: prefix to these functions signal automatic Garbage Collection is activated.)


Define A, a single float matrix:


CV> (DEFPARAMETER A (GC:MAT 3 3 +32f+ :FLOAT '(1f0 2f0 3f0 4f0 5f0 6f0 7f0 8f0 9f0)))


A


Define B as the transpose of A:


CV> (DEFPARAMETER B (GC:>> (GC:MAT-EXPR-T A))) <--- The MAT-EXPR type output of MAT-EXPR-T is converted 
                                                    back to MAT with the (>>) function, so it can be used 
B                                                   as input to MUL. 


Finally, multiply A and B and print the output. Again, output must be converted to MAT type before 
sending to PRINT-MAT.


CV> (PRINT-MAT (GC:>> (GC:MUL A B)))


#((14.0 32.0 50.0)
  (32.0 77.0 122.0)
  (50.0 122.0 194.0))


Now, do the same operation with MUL-TRANSPOSE:


First define A, a single float matrix:


CV> (DEFPARAMETER A (GC:MAT 3 3 +32f+ :FLOAT '(1f0 2f0 3f0 4f0 5f0 6f0 7f0 8f0 9f0)))


A


Multipy A by its transpose. A is the destination matrix:


CV> (MUL-TRANSPOSED A A NIL) 


; No value


Print A:


CV>  (PRINT-MAT A)


#((14.0 32.0 50.0)
  (32.0 77.0 122.0)
  (50.0 122.0 194.0))


========================================================================================================================================
#MULTIPLY
========================================================================================================================================

Calculates the per-element scaled product of two arrays.

C++: void multiply(InputArray src1, InputArray src2, OutputArray dst, double scale=1, int dtype=-1 )

LISP-CV: (MULTIPLY (SRC1 MAT) (SRC2 MAT) (DEST MAT) &OPTIONAL ((SCALE :DOUBLE) 1) ((DTYPE :INT) -1)) => :VOID


    Parameters:	

        SRC1 - First input array.

        SRC2 - Second input array of the same size and the same type as SRC1.

        DEST - Output array of the same size and type as SRC1.

        SCALE - Optional scale factor.
  
        DTYPE - Destination matrix type, default is -1 i.e. (EQ (MAT-TYPE DEST) (MAT-TYPE SRC))
                You can change DTYPE to a double float(+64F+) to achieve higher precision).


The function multiply calculates the per-element product of two arrays. There is also a Matrix 
Expressions (MAT-EXPR) variant of this function. See (MUL). For a not-per-element matrix product, 
see (GEMM).

Note:

Saturation is not applied when the output array has the depth +32S+. You may even get result of an 
incorrect sign in the case of overflow.

See also:

(ADD), (SUBTRACT), (DIVIDE), MAT-EXPR, (SCALE-ADD), (ADD-WEIGHTED), (ACCUMULATE), (ACCUMULATE-PRODUCT), 
(ACCUMULATE-SQUARE), (CONVERT-TO)


Example:

(defun multiply-example ()
  ;;Allocate int, double float and unsigned char matrix data
  (with-object ((int-data (alloc :int '(1 2 3 4 5 6 7 8 9)))
		(double-data (alloc :double '(1d0 2d0 3d0 4d0 5d0 6d0 7d0 8d0 9d0)))
		(uchar-data (alloc :uchar '(1 2 3 4 5 6 7 8 9))))
    ;;Create two identical source matrices and 
    ;;one destination matrix for each data type
    (with-mat ((int-mat-1 (mat 3 3 +32s+ int-data))
	       (int-mat-2 (mat 3 3 +32s+ int-data))
	       (dest-1 (mat))
	       (double-mat-1 (mat 3 3 +64f+ double-data))
	       (double-mat-2 (mat 3 3 +64f+ double-data))
	       (dest-2 (mat))
	       (uchar-mat-1 (mat 3 3 +8u+ uchar-data))
	       (uchar-mat-2 (mat 3 3 +8u+ uchar-data))
	       (dest-3 (mat)))
      ;;Multiply int matrix by identical matrix using 
      ;;a default DTYPE(destination type) parameter
      (multiply int-mat-1 int-mat-2 dest-1 1d0 -1)
      ;;Multiply double float matrix by identical matrix using 
      ;;a DTYPE parameter of 6(+64F+) or double float type
      (multiply double-mat-1 double-mat-2 dest-2 1d0 6)
      ;;Multiply uchar matrix by identical matrix using 
      ;;a default DTYPE parameter and scalar 2
      (multiply uchar-mat-1 uchar-mat-2 dest-3 2d0 -1)
      ;;Print results
      (format t "~%DEST-1:~%~%")
      (print-mat dest-1)
      (format t "~%~%DEST-2:~%~%")
      (print-mat dest-2)
      (format t "~%~%DEST3:~%~%")
      (print-mat dest-3)
      (format t "~%"))))

========================================================================================================================================
#NORM
========================================================================================================================================

Calculates an absolute array norm, an absolute difference norm, or a relative difference norm.

C++: double norm(InputArray src1, int normType=NORM_L2, InputArray mask=noArray())

LISP-CV: (NORM (SRC1 MAT) &OPTIONAL ((NORM-TYPE :INT) +NORM-L2+) ((MASK MAT) (MAT))) => :DOUBLE

C++: double norm(InputArray src1, InputArray src2, int normType=NORM_L2, InputArray mask=noArray() )

LISP-CV: (NORM (SRC1 MAT) (SRC2 MAT) &OPTIONAL ((NORM-TYPE :INT) +NORM-L2+) ((MASK MAT) (MAT))) => :DOUBLE


    Parameters:	

        SRC1 - First input array.

        SRC2 - Second input array of the same size and the same type as SRC1.

        NORM-TYPE - Type of the norm (see the details below).

        MASK - Optional operation mask; it must have the same size as SRC1 and +8UC1+ type.

The functions NORM calculate an absolute norm of SRC1 (when there is no SRC2):


See OpenCV documentation:

http://docs.opencv.org/trunk/modules/core/doc/operations_on_arrays.html?highlight=norm#norm

for a description and formulae


Example:

(defun norm-example (filename &optional (cam 0))

  "This example is an improvement on how MIN-MAX-LOC tracks an 
   object, in the MIN-MAX-LOC example, in a couple ways. First, 
   you'll notice the result of MIN-MAX-LOC, as shown in the wi-
   ndow 'MATCHES', is better defined as a result of NORM being 
   used instead of NORMALIZE. You'll still have to adjust the 
   distance you hold the object from the camera to get a good 
   track, however you can improve the objects track by adjusti
   ng the 'Brightness' and 'Contrast' trackbar sliders. Also, 
   if you look at the MATCHES window while trying to get a tra-
   ck, you notice the visual clues there help you to do that.

   Note: Printing the 'checkerboard.png' image, in the LISP-CV 
   images directory, to use for the object to track and using 
   the 'resized-checkerboard.png', in the same directory, for 
   the template image gives a good effect in this example."

  (with-captured-camera (cap cam :width 640 :height 480) 
    ;;Create windows
    (let* ((window-name-1 "TEMPL - NORM Example")
	   (window-name-2 "FRAME - NORM Example")
	   (window-name-3 "Move Trackbars to change Brightness and Contrast - NORM Example")
	   (window-name-4 "MATCHES - NORM Example")
	   ;;Initialize size parameters 
	   ;;for the matches
           (iwidth 0)
	   (iheight 0)
	   (brightness 0)
	   (contrast 0))      
      ;;Create windows
      (with-named-window (window-name-1 +window-autosize+)
	(with-named-window (window-name-2 +window-autosize+) 
	  (with-named-window (window-name-3 +window-autosize+) 
	    (with-named-window (window-name-4 +window-autosize+) 
	      ;;Move windows to specified locations     
	      (move-window window-name-1 250 29)
	      (move-window window-name-2 99 260)
	      (move-window window-name-3 743 260)
	      (move-window window-name-4 1387 260)
	      (with-point ((minloc (point))
			   (maxloc (point)))
		(with-object ((minval (alloc :double 0d0))
			      (maxval (alloc :double 0d0))
			      (val1 (alloc :int 50))
			      (val2 (alloc :int 50)))
		  ;;Set rectangle color
		  (with-scalar ((color (scalar 0 0 255)))
		    ;;Load template image
		    (with-mat ((frame (mat))
			       (templ (imread filename 1))
			       (dest (mat)))
		      (create-trackbar "Brightness" window-name-3 val1 100)
		      (create-trackbar  "Contrast" window-name-3 val2 100)
		      (loop
			 ;;Set camera feed to FRAME
			 (read cap frame)
			 ;;Set brightness and contrast values 
			 ;;based on trackbar input
			 (setf brightness (- (mem-ref val1 :int) 50))
			 (setf contrast (/ (mem-ref val2 :int) 50))
			 (copy-to frame dest)
			 (convert-to frame dest -1 (coerce contrast 'double-float)  
				     (coerce brightness 'double-float))
			 (setf iwidth (+ (- (cols frame) (cols templ)) 1))
			 (setf iheight (+ (- (rows frame) (rows templ)) 1))
			 ;;Create a matrix to hold all of the matches
			 (with-mat ((matches (mat iheight iwidth +32f+)))
			   ;;Run MATCH-TEMPLATE on each frame of the camera 
			   ;;feed and run NORM on each match 
			   (match-template dest templ matches +tm-ccoeff-normed+)
			   (norm matches matches +norm-l2+)
			   ;;Run MIN-MAX-LOC to set point 
			   ;;coordinates for each match
			   (min-max-loc matches minval maxval minloc maxloc)
			   (rectangle frame (gc:point (x minloc) (y minloc)) 
				      (gc:point (+ (x minloc) (cols templ)) 
						(+ (y minloc) (rows templ))) 
				      color 10 0 0)
			   ;;Show image, template and matches and DEST in a window
			   (imshow window-name-1 templ)
			   (imshow window-name-2 frame)
			   (imshow window-name-3 dest)
			   (imshow window-name-4 matches)
			   (let ((c (wait-key 33)))
			     (when (= c 27)
			       (return))))))))))))))))

========================================================================================================================================
#NORMALIZE
========================================================================================================================================

Normalizes the norm or value range of an array.

C++: void normalize(InputArray src, OutputArray dst, double alpha=1, double beta=0, int norm_type=NORM_L2, int dtype=-1, 
     InputArray mask=noArray())

LISP-CV: (NORMALIZE (SRC MAT) (DEST MAT) &OPTIONAL ((ALPHA :DOUBLE) 1) ((BETA :DOUBLE) 0) 
         ((NORM-TYPE :INT) +NORM-L2+) ((DTYPE :INT) -1) ((MASK MAT) (MAT))) => :VOID 

    Parameters:	

        SRC - Input array.

        DEST - Output array of the same size as SRC.

        ALPHA - Norm value to normalize to or the lower range boundary in case of the range normalization.

        BETA - Upper range boundary in case of the range normalization; it is not used for the norm 
               normalization.

        NORM-TYPE - Normalization type (see the details below).

        DTYPE - When negative, the output array has the same type as SRC; otherwise, it has the same 
                number of channels as SRC and the depth =CV_MAT_DEPTH(dtype)(internal, See OpenCV source 
                code at: <opencv_source_directory>/modules/core/include/opencv2/core/cvdef.h

        MASK - Optional operation mask.


See OpenCV documentation:

http://docs.opencv.org/modules/core/doc/operations_on_arrays.html?highlight=normalize#normalize

for a description and formulae.


See also:

(NORM), (CONVER-TO)


Example:

See MATCH-TEMPLATE-EXAMPLE for example usage of NORMALIZE.

========================================================================================================================================
#PCA
========================================================================================================================================

PCA constructors

Note: Both PCA and MAKE-PCA are provided in this library. The first, to match OpenCV's naming 
conventions, the second, to adhere to Common Lisp naming conventions. Except for the name, they 
are the same function. I use the PCA function in the examples in this file because it will make 
them easier to compare with OpenCV examples you find online, thus making this library easier to 
learn.

C++: PCA::PCA()

LISP-CV: (PCA) => PCA

LISP-CV: (MAKE-PCA) => PCA

C++: PCA::PCA(InputArray data, InputArray mean, int flags, double retainedVariance)

LISP-CV: (PCA (DATA MAT) (MEAN MAT) (FLAGS :INT) (RETAINED-VARIANCE :DOUBLE)) => PCA

SETF-able member accessors.

C++: Mat PCA::eigenvalues

LISP-CV: (EIGENVALUES (SELF PCA)) => MAT

LISP-CV: (PCA-EIGENVALUES (SELF PCA)) => MAT ;Alias for EIGENVALUES

LISP-CV: (SETF (EIGENVALUES (SELF PCA)) (VAL MAT)) => MAT

LISP-CV: (SETF (PCA-EIGENVALUES (SELF PCA)) (VAL MAT)) => MAT ;Alias for (SETF EIGENVALUES)

C++: Mat PCA::eigenvectors

LISP-CV: (EIGENVECTORS (SELF PCA)) => MAT

LISP-CV: (PCA-EIGENVECTORS (SELF PCA)) => MAT ;Alias for EIGENVEECTORS

LISP-CV: (SETF (EIGENVECTORS (SELF PCA)) (VAL MAT)) => MAT

LISP-CV: (SETF (PCA-EIGENVECTORS (SELF PCA)) (VAL MAT)) => MAT ;Alias for (SETF EIGENVECTORS)

C++: Mat PCA::mean

LISP-CV: (MEAN (SELF PCA)) => MAT

LISP-CV: (PCA-MEAN (SELF PCA)) => MAT ;Alias for MEAN

LISP-CV: (SETF (MEAN (SELF PCA)) (VAL MAT)) => MAT

LISP-CV: (SETF (PCA-MEAN (SELF PCA)) (VAL MAT)) => MAT ;Alias for (SETF MEAN)


    Parameters:	

        DATA - Input samples stored as matrix rows or matrix columns.

        MEAN - Optional mean value; if the matrix is empty, the mean is computed from the data.

        FLAGS - Operation flags; currently the parameter is only used to specify the data layout:

            +PCA-DATA-AS-ROW+ indicates that the input samples are stored as matrix rows.

            +PCA-DATA-AS-COL+ indicates that the input samples are stored as matrix columns.

        RETAINED-VARIANCE - Percentage of variance that PCA should retain. Using this parameter will 
                            let the PCA decided how many components to retain but it will always keep 
                            at least 2.

        VAL - A new value.


The default constructor initializes an empty PCA structure. The other constructors initialize the 
structure and call PCA::operator()(In the underlying C++ code).


Example:

#|

This program demonstrates how to use LispCV PCA with
a specified amount of variance to retain. The effect 
is illustrated further by using a trackbar to change 
the value for retained varaince. The program takes a
text file as input with each line of the file consis-
ting of the full path to an image. PCA will be perfo-
rmed on this list of images. It is reccommended that 
you use the first 15 faces of the AT&T face data set:
http://www.cl.cam.ac.uk/research/dtg/attarchive/facedatabase.html
so your input text file would end up looking like this:

<path_to_at&t_faces>/orl_faces/s1/1.pgm
<path_to_at&t_faces>/orl_faces/s2/1.pgm
<path_to_at&t_faces>/orl_faces/s3/1.pgm
<path_to_at&t_faces>/orl_faces/s4/1.pgm
<path_to_at&t_faces>/orl_faces/s5/1.pgm
<path_to_at&t_faces>/orl_faces/s6/1.pgm
<path_to_at&t_faces>/orl_faces/s7/1.pgm
<path_to_at&t_faces>/orl_faces/s8/1.pgm
<path_to_at&t_faces>/orl_faces/s9/1.pgm
<path_to_at&t_faces>/orl_faces/s10/1.pgm
<path_to_at&t_faces>/orl_faces/s11/1.pgm
<path_to_at&t_faces>/orl_faces/s12/1.pgm
<path_to_at&t_faces>/orl_faces/s13/1.pgm
<path_to_at&t_faces>/orl_faces/s14/1.pgm
<path_to_at&t_faces>/orl_faces/s15/1.pgm

|#

;;Note: The t: prefix to some of these functions enables automatic GC.

;;Initialize global variables.
(defparameter win-name "Reconstruction - PCA Example") 
(defparameter data 0) 
(defparameter ch 0) 
(defparameter rows 0) 
(defparameter pca 0) 


;;;Functions:

(defun read-img-list (filename)
  (let ((in (open filename :if-does-not-exist nil))
	(img-list (list)))
    (if in
	(loop for line = (read-line in nil)

	   while line do
	     (push (t:imread line 0) img-list))
	(error "No valid input file was given, please check the given filename."))
    (close in)
    (reverse img-list)))


(defun format-images-for-pca (data-list)

  (let* ((dest (mat (length data-list) (* (cols (nth 0 data-list)) 
					  (rows (nth 0 data-list))) +32F+))
         (image-row)
	 (row-i))
    (dotimes (i (length data-list))
      (setf image-row (t:reshape (t:clone (nth i data-list)) 1 1))
      (setf row-i (t:row dest i))
      (convert-to image-row row-i +32f+))
    dest))


(defun to-grayscale (src) 
  ;;Only allow one channel.
  (if (not (= (channels src) 1))
      (error  "Only Matrices with one channel are supported")
      ;;Create and return normalized image.
      (let ((dest (mat)))
	(normalize src dest 0d0 255d0 +norm-minmax+ +8uc1+)
	dest)))


(defcallback on-trackbar :void ((pos :int))

  (format t "Retained Variance = ~a%~%" pos)
  (format t "re-calculating PCA...~%")

  ;;Don't let POS go below 1 
  ;;or program will freeze.
  (if (eq pos 0) (setf pos 1))

  (let ((var (float (/ pos 100) 1d0)))

    (setf pca (pca data (t:mat) +pca-data-as-row+ var))

    (with-mat ((data-row-0 (row data 0))
	       (point (project pca data-row-0))
	       (reconstruction (back-project pca point))
	       (reshaped-reconstruction (reshape reconstruction ch rows))
	       (grayscale-reconstruction (to-grayscale reshaped-reconstruction)))

      (imshow win-name grayscale-reconstruction)
      (format t "done!  # of principal components: ~a~%" 
	      (rows (t:eigenvectors pca))))))


(defun pca-example (csv)

  ;;Vector to hold the images.
  (let ((img-list (read-img-list csv)))

    ;;Quit if there are not enough images for this demo.
    (if (<= (length img-list) 1)       
	(error "This demo needs at least 2 images to work. Please add more images to your data set!"))

    ;;Reshape and stack images into a row matrix.
    (with-mat ((data (format-images-for-pca img-list)))

      ;;;Perform PCA.

      ;;Trackbar is initially set here, also this is a common value 
      ;;for RETAINED-VARIANCE.
      (with-pca ((pca (pca data (t:mat) +pca-data-as-row+ 0.95d0))) 

	;;;Demonstration of the effect of RETAINED-VARIANCE on the first image.

	(with-mat ((data-row-0 (row data 0))
		   ;;Project into the eigenspace, thus the image becomes a "point".
		   (point (project pca data-row-0)) 
		   ;;Re-create the image from the "point".
		   (reconstruction (back-project pca point))
		   ;;Reshape from a row vector into image shape.
		   (reshaped-reconstruction (reshape reconstruction (channels (nth 0 img-list)) 
						     (rows (nth 0 img-list))))
		   ;;Re-scale for displaying purposes.
		   (grayscale-reconstruction (to-grayscale reshaped-reconstruction))) 

	  ;;Data the trackbar can adjust.
	  (let ((pos (t:alloc :int 95)))

	    ;;Initialize highgui window.
	    (with-named-window (win-name +window-normal+)
	      (move-window win-name 759 175)

	      ;;Pass data to trackbar handler 
              ;;through the global variables.
	      (setf data data)
	      (setf ch (channels (nth 0 img-list)))
	      (setf rows (rows (nth 0 img-list)))
	      (setf pca pca)
	      
	      ;;Create the tracbar.
	      (create-trackbar "Retained Variance (%)" win-name pos 
			       100 (callback on-trackbar))

	      ;;Display until user presses Esc.
	      (imshow win-name grayscale-reconstruction)
	      (loop
		 (let ((c (wait-key )))
		   (when (= c 27)
		     (return)))))))))))

========================================================================================================================================
#PCA-PROJECT
========================================================================================================================================

Projects vector(s) to the principal component subspace.

Note: The name PCA-PROJECT is used in the documentation to refer to the binding for the "project" 
member of the OpenCV PCA class because it's more descriptive and it is easier to search for in this 
file. The PROJECT method may also be used to call this binding.

C++: Mat PCA::project(InputArray vec) const

LISP-CV: (PROJECT (SELF PCA) (VEC MAT)) => MAT

LISP-CV: (PCA-PROJECT (SELF PCA) (VEC MAT)) => MAT

    Parameters:	

        VEC - Input vector(s); must have the same dimensionality and the same layout as the input 
              data used at PCA phase, that is, if the flag +PCA-DATA-AS-ROW+ is specified, then 
              (= (COLS VEC) (COLS DATA)) (vector dimensionality) and (ROWS VEC) is the number of 
              vectors to project, and the same is true for the +PCA-DATA-AS-COL+ case.

The methods project one or more vectors to the principal component subspace, where each vector projection is represented by coefficients in the principal component basis. The first form of the method returns the matrix that the second form writes to the result. So the first form can be used as a part of expression while the second form can be more efficient in a processing loop.



========================================================================================================================================
#PHASE
========================================================================================================================================

Calculates the rotation angle of 2D vectors.

C++: void phase(InputArray x, InputArray y, OutputArray angle, bool angleInDegrees=false)

LISP-CV: (PHASE (X MAT) (Y MAT) (ANGLE MAT) &OPTIONAL (ANGLE-IN-DEGREES :BOOLEAN)) => :VOID

    Parameters:	

        X - Input floating-point array of x-coordinates of 2D vectors.

        Y - Input array of y-coordinates of 2D vectors; it must have the same size and the same type as X.

        ANGLE - Output array of vector angles; it has the same size and same type as X.

        ANGLE-IN-DEGREES - When true, the function calculates the angle in degrees, otherwise, they are measured in radians.

The function phase calculates the rotation angle of each 2D vector that is formed from the corresponding elements of X and Y:


See OpenCV documentation at this link for further description and a formula:

http://docs.opencv.org/trunk/modules/core/doc/operations_on_arrays.html?highlight=phase#phase


Example:

(defun random-color (rng)
  (return-from random-color (scalar (uniform rng 0 255) 
				    (uniform rng 0 255) (uniform rng 0 255))))

(defun phase-example ()
  ;;Declare variables
  (let ((window-name "Move Trackbars to change the start/end angles of the ellipse - PHASE Example")
        (x1 0)
        (y1 0)
        (y2 0)
        (x2 0)
        (count 720)
        (start-angle 0)
        (end-angle 0)
        (font-face +font-hershey-plain+)
	(scale 1.25d0)
        (line-type 4)
        (thickness 1)
        (text1 0)
        (text2 0)
        (text3 0)
        (text4 0)
        (text5 0)
        (text6 0))
    ;;Allocate varables for the x,y coordinates 
    ;;that the trackbar can adjust
    (with-object ((x-val-1 (alloc :int 0))
		  (y-val-1 (alloc :int 0))
		  (x-val-2 (alloc :int 0))
		  (y-val-2 (alloc :int 0)))
      ;;Create a window
      (with-named-window (window-name +window-autosize+)
	(move-window window-name 639 175)
        ;;Create trackbars for adjusting 
        ;;the x,y values given to PHASE
	(create-trackbar  "X value 1" window-name x-val-1  count)
	(create-trackbar  "Y value 1" window-name y-val-1 count)
        (create-trackbar  "X value 2" window-name x-val-2  count)
	(create-trackbar  "Y value 2" window-name y-val-2 count)
	;;Initialize random number generator
	(with-rng ((rng (rng #xFFFFFFFF)))
	  (loop
	     ;; Set ELLIPSE CENTER and AXES parameters
	     (with-point ((center (point 320 311)))
	       (with-size ((axes (size 125d0 125d0)))
		 ;;Set the X1,Y1,X2,Y2 to the values output by the trackbars  
		 (setf x1 (- (coerce (@ x-val-1 :int) 'single-float) 360))
		 (setf y1 (- (coerce (@ y-val-1 :int) 'single-float) 360))
		 (setf x2 (- (coerce (@ x-val-2 :int) 'single-float) 360))
		 (setf y2 (- (coerce (@ y-val-2 :int) 'single-float) 360))
		 ;;Allocate memory to hold the x,y coordinates
		 (with-object ((x-coordinates (alloc :float (list x1 x2)))
			       (y-coordinates (alloc :float (list y1 y2))))
		   ;;Create a black background, MAT
		   (with-mat ((mat (mat-zeros 480 640 +8uc3+))
			      ;;Create two vectors, using the function 
			      ;;MAT, to hold the x,y coordinates PHASE 
			      ;;uses to determine the rotation angles
			      (x (mat 1 2 +32f+ x-coordinates))
			      (y (mat 1 2 +32f+ y-coordinates))
			      ;;Output matrix used to hold 
			      ;;the two rotation angles
			      (angle (mat 1 2 +32f+)))
		     ;;Set COLOR parameter for PUT-TEXT
             	     (with-scalar ((red (scalar 0 0 255)))
		       ;;Set TEXT parameter for PUT-TEXT
		       (setf text1 (cat "x value 1: " (write-to-string x1)))
		       (setf text2 (cat "y value 1: " (write-to-string y1)))
		       (setf text3 (cat "x value 2: " (write-to-string x2)))
		       (setf text4 (cat "y value 2: " (write-to-string y2)))
		       (setf text5 (cat "start-angle: " (write-to-string start-angle)))
		       (setf text6 (cat "end-angle: " (write-to-string end-angle)))
		       ;;Output the values of X1, Y1, X2, Y2, START-ANGLE and END-ANGLE 
		       (put-text mat text1 (gc:point 0 18) font-face  scale red thickness line-type)
		       (put-text mat text2 (gc:point 0 43) font-face scale red thickness line-type)
		       (put-text mat text3 (gc:point 0 68) font-face scale red thickness line-type)
		       (put-text mat text4 (gc:point 0 93) font-face scale red thickness line-type)
		       (put-text mat text5 (gc:point 0 118) font-face scale red thickness line-type)
		       (put-text mat text6 (gc:point 0 143) font-face scale red thickness line-type))
		     ;;Doing the following actions, multiple times
		     ;;in a loop, makes the ELLIPSE look better
		     (dotimes (n 10)
		       ;;Compute the rotation angles 
		       ;;of X1,Y1,X2,Y2 with PHASE
		       (phase* x y angle t)
		       ;;Set START-ANGLE and END-ANGLE of the ellipse to 
		       ;;the 0,0 and 0,1 elements of the matrix ANGLE
		       (setf start-angle (coerce (@ :float angle 0 0) 'double-float))
		       (setf end-angle (coerce (@ :float angle 0 1) 'double-float))
		       ;;Draw the ellipse
		       (ellipse mat center axes 360d0 start-angle end-angle
				(random-color rng) (uniform rng -1 9) +aa+)
		       (sleep .015)
		       ;;Show and then delete MAT 
		       ;;as it goes out of focus
		       (imshow window-name mat)))
		   (let ((c (wait-key 33)))
		     (when (= c 27)
		       (return))))))))))))

========================================================================================================================================
#POW
========================================================================================================================================

Raises every array element to a power.

C++: void pow(InputArray src, double power, OutputArray dst)

LISP-CV: (POW (SRC MAT) (POWER :DOUBLE) (DEST MAT)) => :VOID


    Parameters:	

        SRC - Input array.

        POWER - Exponent of power.

        DEST - Output array of the same size and type as SRC.


See OpenCV documentation:

http://docs.opencv.org/modules/core/doc/operations_on_arrays.html?highlight=pow#pow

for description and formula.


See also:

(SQRT), (EXP), (LOG), (CART-TO-POLAR), (POLAR-TO-CART)

========================================================================================================================================
#RAND-SHUFFLE
========================================================================================================================================

Shuffles the array elements randomly.

C++: void randShuffle(InputOutputArray dst, double iterFactor=1., RNG* rng=0 )

LISP-CV: (RAND-SHUFFLE (DEST MAT) &OPTIONAL ((ITER-FACTOR :DOUBLE) 1D0) ((RNG RNG) (NULL-POINTER))) => :VOID

    Parameters:	

        DEST - Input/output numerical 1D array.

        ITER-FACTOR - Scale factor that determines the number of random swap operations (see the details below).

        RNG - Optional random number generator used for shuffling; if it is zero, theRNG()(<=internal C++ function) 
              is used instead.

The function RAND-SHUFFLE shuffles the specified 1D array by randomly choosing pairs of elements and 
swapping them. The number of such swap operations will be (* (ROWS DEST) (COLS DEST) ITER-FACTOR).

See also:

RNG, (SORT)


Example:

(defun rand-shuffle-example (filename)
  ;;Load an image.
  (with-mat ((img (imread filename 0)))
    (let ((window-name "RAND-SHUFFLE Example")
	  ;;Integer values trackbar can adjust.
	  (iter-factor (t:alloc :int 0))
	  (img-width (t:alloc :int (list (cols img))))
	  (img-height (t:alloc :int (list (rows img))))
	  (delay (t:alloc :int 0)))
      (with-named-window (window-name +window-normal+)
	;;Set window to fullscreen.
	(set-window-property window-name +wnd-prop-fullscreen+ 
			     +window-fullscreen+)
	;;Move next trackbar to choose number of random swap operations.
	;;(See documentation for details on the ITER-FACTOR parameter.)
	(create-trackbar "ITER-FACTOR" window-name iter-factor 100)
	;;Move next two trackbars to choose the new width and height of 
	;;IMG. If you resize IMG to the pixel level you'll be able to see
	;;RAND-SHUFFLE randomly choosing pairs of elements and swapping them.
	(create-trackbar "IMG-WIDTH" window-name img-width 1280)
	(create-trackbar "IMG-HEIGHT" window-name img-height 1024)
	;;This trackbar allows you to slow down/speed up 
	;;the example so you can precisely see the swap 
	;;operations take place.
	(create-trackbar "DELAY" window-name delay 50)
	(loop
	   ;;Reload the image.
	   (with-mat ((img (imread filename 0)))
             ;;Don't let IMG get resized to 0 or example will freeze.
	     (if (< (get-trackbar-pos "IMG-WIDTH" window-name) 1) 
		 (set-trackbar-pos "IMG-WIDTH" window-name 1) nil)
	     (if (< (get-trackbar-pos "IMG-HEIGHT" window-name) 1) 
		 (set-trackbar-pos "IMG-HEIGHT" window-name 1) nil)
	     (resize img img (t:size (@ img-width :int) (@ img-height :int)))
	     (with-mat ((1d-img (reshape img 0 1)))
	       (if (empty img) 
		   (return-from rand-shuffle-example 
		     (format t "Image not loaded")))
	       ;;Randomly shuffle all elements of image:
	       ;;Note: This creates a snowy kind of effect
	       ;;like on a tv. You can also click the window 
               ;;and then scroll in until you see pixels and 
               ;;see the random swap operations in action that way too.
	       (rand-shuffle 1d-img (float (@ iter-factor :int) 1d0))
	       ;;Convert 1D-IMAGE back to 3d matrix 
	       ;;so it can be shown in the window.
	       (with-mat ((3d-img (reshape 1d-img 0 (rows img))))
		 (imshow window-name 3d-img))
	       (sleep (* (@ delay :int) 0.01))
	       (let ((c (wait-key 1)))
		 (when (= c 27)
		   (return))))))))))

========================================================================================================================================
#RANDU
========================================================================================================================================

Generates a single uniformly-distributed random number or an array of random numbers.

C++: void randu(InputOutputArray dst, InputArray low, InputArray high)

LISP-CV: (RANDU (DEST MAT) (LOW SCALAR) (HIGH SCALAR)) => :VOID


    Parameters:	

        DEST - output array of random numbers; the array must be pre-allocated.

        LOW - inclusive lower boundary of the generated random numbers.

        HIGH - exclusive upper boundary of the generated random numbers.


This function fills the matrix dst with uniformly-distributed random numbers from the specified range.

See also:

(RNG), (RANDN), (THE-RNG)

Examples:

(defun randu-example ()
  (with-object ((data (alloc :float '(1.0f0 2.0f0 3.0f0 4.0f0 5.0f0 
				      6.0f0 7.0f0 8.0f0 9.0f0))))
    (with-mat ((m (mat 3 3 +32f+ data)))
      (format t "~%Print matrix M:~%~%")
      (print-mat m)
      (format t "~%")
      (format t "*Fill matrix M with random values with RANDU*~%~%")
      (randu m (scalar -100) (scalar 100))
      (format t "Print matrix M again:~%~%")
      (print-mat m)
      (format t "~%"))))

========================================================================================================================================
#REPEAT
========================================================================================================================================

Fills the output array with repeated copies of the input array.


C++: void repeat(InputArray src, int ny, int nx, OutputArray dst)

LISP-CV: (REPEAT (SRC MAT) (NY :INT) (NX :INT) (DEST MAT)) => :VOID 


    Parameters:	

        SRC - Input array to replicate.

        DST - Output array of the same type as SRC.

        NY - Flag to specify how many times the SRC is repeated along the vertical axis.

        NX - Flag to specify how many times the SRC is repeated along the horizontal axis.


The function (REPEAT) duplicates the input array one or more times along each of the two axes:


See OpenCV documentation at this link for the formula: 

http://docs.opencv.org/trunk/modules/core/doc/operations_on_arrays.html?highlight=repeat#repeat


See also:

(REDUCE), Matrix Expressions(MAT-EXPR)


Example:

Create a 2x2 matrix. (The GC: prefix indicates automatic Garbage Collection is activated.)

CV> (DEFPARAMETER A (GC:MAT 2 2 +32s+ :INT '(1 2 3 4))) 

A

Print the original matrix A

CV>  (PRINT-MAT A)

#((1 2)
  (3 4))

Create a 10x10 matrix to hold the repeated copies of marix A data.

CV> (DEFPARAMETER B (GC:MAT 10 10 +32s+ :INT))

B

Evaluate the REPEAT function to fill matrix B with repeated copies of A.

CV> (REPEAT A 5 5 B)

; No value

Print B.

CV>  (PRINT-MAT B)

#((1 2 1 2 1 2 1 2 1 2)
  (3 4 3 4 3 4 3 4 3 4)
  (1 2 1 2 1 2 1 2 1 2)
  (3 4 3 4 3 4 3 4 3 4)
  (1 2 1 2 1 2 1 2 1 2)
  (3 4 3 4 3 4 3 4 3 4)
  (1 2 1 2 1 2 1 2 1 2)
  (3 4 3 4 3 4 3 4 3 4)
  (1 2 1 2 1 2 1 2 1 2)
  (3 4 3 4 3 4 3 4 3 4))

========================================================================================================================================
#RNG
========================================================================================================================================

The constructors

Note: Both RNG and MAKE-RNG are provided in this library. The first, to match OpenCV's naming 
conventions, the second, to adhere to Common Lisp naming conventions. Except for the name, they are 
the same function. I use the RNG function in the examples in this file because it will make them 
easier to compare with OpenCV examples you find online, thus making this library easier to learn.

C++: RNG::RNG()

LISP-CV: (RNG) => RNG

LISP-CV: (MAKE-RNG) => RNG

C++: RNG::RNG(uint64 state)

LISP-CV: (RNG (STATE :UINT64)) => RNG

LISP-CV: (MAKE-RNG (STATE :UINT64)) => RNG

    Parameters:	

        STATE - 64-bit value used to initialize the RNG.


These are the RNG constructors. The first form sets the state to some pre-defined value, equal to 
2**32-1 in the current implementation. The second form sets the state to the specified value. If 
you passed (EQ STATE 0) , the constructor uses the above default value instead to avoid the singular 
random number sequence, consisting of all zeros.


Example:


CV> (DEFPARAMETER RNG (RNG #XFFFFFFFF))

RNG

CV> (UNIFORM RNG 0 10)

6

CV> (UNIFORM RNG 0D0 10D0)

6.992592005760082d0

CV> (UNIFORM RNG 0F0 10F0)

3.1438508

========================================================================================================================================
RNG-FILL
========================================================================================================================================

Fills arrays with random numbers.

Note: The name RNG-FILL is used in the documentation to refer to the binding for the "fill" member 
of the OpenCV RNG class because it is more descriptive and it is easier to search for in this file. 
The FILL function may also be used to call this binding.

Note: The LISP-CV function FILL overloads the Common Lisp function FILL so both functions can use the 
same name. The LISP-CV function FILL provides the the same functionality as the Common Lisp function 
FILL and the OpenCV C++ FILL function. To use the Common Lisp function FILL directly, while you are in 
the LISP-CV package, you need to evaluate CL:FILL.

C++: void RNG::fill(InputOutputArray mat, int distType, InputArray a, InputArray b, bool saturateRange=false )

LISP-CV: (FILL (SELF RNG) (MAT MAT) (DIST-TYPE :INT) (A SCALAR) (B SCALAR) &OPTIONAL ((SATURATE-RANGE :BOOLEAN) NIL)) => :VOID

LISP-CV: (RNG-FILL (SELF RNG) (MAT MAT) (DIST-TYPE :INT) (A SCALAR) (B SCALAR) &OPTIONAL ((SATURATE-RANGE :BOOLEAN) NIL)) => :VOID

    Parameters:	

        MAT - 2D or N-dimensional matrix; currently matrices with more than 4 channels are not supported 
              by the functions, use (RESHAPE) as a possible workaround.

        DIST-TYPE - Distribution type, +RNG-UNIFORM+ or +RNG-NORMAL+.

        A - First distribution parameter; in case of the uniform distribution, this is an inclusive 
            lower boundary, in case of the normal distribution, this is a mean value.

        B - Second distribution parameter; in case of the uniform distribution, this is a non-inclusive 
            upper boundary, in case of the normal distribution, this is a standard deviation (diagonal 
            of the standard deviation matrix or the full standard deviation matrix).

        SATURATE-RANGE - Pre-saturation flag; for uniform distribution only; if T, the function will 
                         first convert A and B to the acceptable value range (according to MAT datatype) 
                         and then will generate uniformly distributed random numbers within the range 
                         [saturate(A), saturate(B)], if (= SATURATE-RANGE MIL), the method will generate 
                         uniformly distributed random numbers in the original range [A, B) and then will 
                         saturate them, it means, for example, that:

                              (RNG-FILL (MAT ROWS COLS +8U+) +RNG-UNIFORM+ +-DBL-MAX+ +DBL-MAX+) 

                         will likely produce array mostly filled with 0’s and 255’s, since the range (0 255) 
                         (for the +8U+ matrix type, uchar)is significantly smaller than (+-DBL-MAX+ +DBL-MAX+).

Each of the methods fills the matrix with the random values from the specified distribution. As the 
new numbers are generated, the RNG state is updated accordingly. In case of multiple-channel images, 
every channel is filled independently, which means that RNG cannot generate samples from the multi-
dimensional Gaussian distribution with non-diagonal covariance matrix directly. To do that, RNG-FILL
generates samples from multi-dimensional standard Gaussian distribution with zero mean and identity 
covariation matrix, and then transforms them using (TRANSFORM) to get samples from the specified 
Gaussian distribution.


Example:

(defun rng-fill-example ()
  ;;Create matrix filled with zeros.
  (with-mat ((mat (mat 10 10 +8u+ 0)))
    (with-rng ((rng (rng 12345)))
      (let ((window-name "RNG-FILL Example")
	    ;;Integer values trackbar can adjust.
	    (a-val (t:alloc :int 0))
	    (b-val (t:alloc :int 0))
	    (delay (t:alloc :int 0)))
	(with-named-window (window-name +window-normal+)
	  ;;Set window to fullscreen with stretched aspect ratio.
	  (set-window-property window-name +wnd-prop-fullscreen+ 
			       +window-fullscreen+)
	  (set-window-property window-name +wnd-prop-aspectratio+ 
			       +window-freeratio+)
          ;;Adjust the inclusive lower boundary.
	  (create-trackbar "A-VAL" window-name a-val 255)
          ;;Adjust the non-inclusive upper boundary.
	  (create-trackbar "B-VAL" window-name b-val 255)
          ;;Set a delay in the loop.
	  (create-trackbar "DELAY" window-name delay 100)
	  (loop
	     (sleep (* (@ delay :int) 0.01))
             ;;Fill MAT with random numbers based on trackbar selections.
	     (fill rng mat +rng-uniform+ (scalar (@ a-val :int)) 
		   (scalar (@ b-val :int)) nil)
             ;;Show MAT in a window.
	     (imshow window-name mat)
	     (let ((c (wait-key 1)))
	       (when (= c 27)
		 (return)))))))))

========================================================================================================================================
#SCALE-ADD
========================================================================================================================================

Calculates the sum of a scaled array and another array.

C++: void scaleAdd(InputArray src1, double alpha, InputArray src2, OutputArray dst)

LISP-CV: (SCALE-ADD (SRC1 MAT) (ALPHA :DOUBLE) (SRC2 MAT) (DEST MAT)) => :VOID


    Parameters:	

        SRC1 - First input matrix.

        ALPHA - Scale factor for the first matrix.

        SRC2 - Second input matrix of the same size and type as SRC1.

        DEST - Output matrix of the same size and type as SRC1.


The function SCALE-ADD is one of the classical primitive linear algebra operations, known as DAXPY 
or SAXPY in BLAS. It calculates the sum of a scaled matrix and another matrix.


See also:

(ADD), (ADD-WEIGHTED), (SUBTRACT), (DOT), (CONVERT-TO), Matrix Expressions(MAT-EXPR)


(defun scale-add-example (filename-1 filename-2)

  "Calculates the sum of a scaled IMAGE-1 and IMAGE-2 
   and shows the result in the third window. Moving t-
   he trackabar changes the scalar value used to scal-
   e IMAGE-1. 

   Using the bear-drawing.jpg and bear-painting.jpg i-
   n the LISP-CV images directory for IMAGE-1 and IMA-
   GE-2 respectively will give a nice effect in this 
   example."

  (let* ((image-1 (imread filename-1 1))
	 (image-2 (imread filename-2 1))
	 (dest (mat (rows image-1) (cols image-1) +8uc3+))
	 (alpha-val (alloc :int '(0))) 
	 (window-name-1 "IMAGE-1 - SCALE-ADD Example")
	 (window-name-2 "IMAGE-2 - SCALE-ADD Example")
	 (window-name-3 "DEST - SCALE-ADD Example"))
    (if (and (empty image-1)
             (empty image-2)) 
	(return-from scale-add-example 
	  (format t "Images were not loaded")))
    (named-window window-name-1 +window-normal+)
    (named-window window-name-2 +window-normal+)
    (named-window window-name-3 +window-normal+)
    (move-window window-name-1 310 175)
    (move-window window-name-2 760 175)
    (move-window window-name-3 1210 175)
    (do* ((n 0))
	 ((plusp (wait-key *millis-per-frame*)) 
	  (format t "Key is pressed by user"))
      (create-trackbar "ALPHA-VAL" window-name-1 alpha-val 100)
      (format t "ALPHA-VAL = ~a~%~%" 
	      (setf n (coerce (mem-aref alpha-val :int) 
			      'double-float)))
      (scale-add image-1 n image-2 dest)
      (imshow window-name-1 image-1)
      (imshow window-name-2 image-2)
      (imshow window-name-3 dest))
    (free alpha-val)
    (destroy-all-windows)))

========================================================================================================================================
#SUBTRACT
========================================================================================================================================

Calculates the per-element difference between two arrays or array and a scalar.

C++: void subtract(InputArray src1, InputArray src2, OutputArray dst, InputArray mask=noArray(), int dtype=-1)

LISP-CV: (SUBTRACT (SRC1 MAT) (SRC2 MAT) (DEST MAT) &OPTIONAL ((MASK MAT) (MAT)) 
         ((DTYPE :INT) -1) => :VOID


    Parameters:	

        SRC1 - First input array or a scalar.

        SRC2 - Second input array or a scalar.

        DST - Output array of the same size and the same number of channels as the input arrays.

        MASK - Optional operation mask; this is an 8-bit single channel array that specifies elements 
               of the output array to be changed.

        DTYPE - Optional depth of the output array (see the details below).


See OpenCV documentation:

http://docs.opencv.org/modules/core/doc/operations_on_arrays.html?highlight=log#subtract

for description and formulae.


See also:

(ADD), (ADD-WEIGHTED), (SCALE-ADD), (CONVERT-TO), Matrix Expressions(MAT-EXPR)


Example:

(defun subtract-example (&optional (cam 0) 
			   (width *default-width*)
			   (height *default-height*))

  (with-captured-camera (cap cam :width width :height height)
    (let* ((window-name "Frame Subtract - SUBTRACT Example"))
      (with-named-window (window-name +window-autosize+)
	(move-window window-name 610 225)
	(with-mat ((last-frame (mat height width +8uc3+))
		   (dest (mat height width +8uc3+)))
	  (loop
	     (with-mat ((frame (mat)))
	       (read cap frame)
	       (subtract frame last-frame dest)
	       (imshow window-name dest)
	       (copy-to frame last-frame)
	       (let ((c (wait-key 33)))
		 (when (= c 27)
		   (return))))))))))

========================================================================================================================================
#SUM
========================================================================================================================================

Calculates the sum of array elements.

C++: Scalar sum(InputArray src)

LISP-CV: (SUM (SRC MAT)) => SCALAR


    Parameters:	SUM - Input array that must have from 1 to 4 channels.


The functions sum calculate and return the sum of array elements, independently for each channel.


See also:

(COUNT-NON-ZERO), (MEAN), (MEAN-STD-DEV), (NORM), (MIN-MAX-LOC), (REDUCE)


Example: 

(defun sum-example ()
  
  ;;Note: the t: prefix 
  ;;enables finalization. 

  ;;Create matrix.
  (let* ((mat (t:mat 4 4 +8u+))
         ;;Initialize random number generator.
         (rng (t:rng #xFFFFFFFF)))
    (format t "~%")
    ;;Fill MAT with random values.
    (dotimes (i (rows mat))
      (dotimes (j (cols mat))
	(setf (@ :uchar mat i j) (uniform rng 1 8))))
    ;;Print MAT.
    (dotimes (i (rows mat))
      (dotimes (j (cols mat))
	(format t "~a" (@ :uchar mat i j))
	(princ #\Space))
      (princ #\Newline))
    (format t "~%")
    ;;Assign each each element 
    ;;of MAT the sum of its ra-
    ;;ndom elements.
    (assign mat (sum mat))
    ;;Print MAT.
    (dotimes (i (rows mat))
      (dotimes (j (cols mat))
	(format t "~a" (@ :uchar mat i j))
	(princ #\Space))
      (princ #\Newline))
    (format t "~%")))

========================================================================================================================================
#UNIFORM
========================================================================================================================================

Returns the next random number sampled from the uniform distribution.

C++: int RNG::uniform(int a, int b)

LISP-CV: (UNIFORM (RNG (:POINTER RNG)) (A :DOUBLE) (B :DOUBLE)) => :DOUBLE

C++: float RNG::uniform(float a, float b)

LISP-CV: (UNIFORM (RNG (:POINTER RNG)) (A :FLOAT) (B :FLOAT)) => :FLOAT

C++: double RNG::uniform(double a, double b)

LISP-CV: (UNIFORM (RNG (:POINTER RNG)) (A :INT) (B :INT)) => :INT


    Parameters:	

        RNG - An RNG object

        A - lower inclusive boundary of the returned random numbers.

        B - upper non-inclusive boundary of the returned random numbers.


The methods transform the state using the MWC algorithm and return the next uniformly-distributed r-
andom number of the specified type, deduced from the input parameter type, from the range (a, b) . 
There is a nuance illustrated by the following example:


(defparameter rng (rng))

;; always produces 0
(defparameter a (uniform rng 0 1))

;; produces double from (0, 1)
(defparameter a1 (uniform rng 0d0 1d0))

;; produces float from (0, 1)
(defparameter b (uniform-f rng 0.0f0 1.0f0))

;; may cause compiler error because of ambiguity:
(defparameter d (uniform rng 0 .999999))


========================================================================================================================================
#CORE - #DRAWING FUNCTIONS
========================================================================================================================================

========================================================================================================================================
#CLIP-LINE
========================================================================================================================================

Clips the line against the image rectangle.

C++: bool clipLine(Rect imgRect, Point& pt1, Point& pt2)

LISP-CV: (CLIP-LINE (IMG-RECT RECT) (PT1 POINT) (PT2 POINT)) => :BOOLEAN


    Parameters:	

        IMG-RECT - Image rectangle.

        PT1 - First line point.

        PT2 - Second line point.


The functions CLIP-LINE calculate a part of the line segment that is entirely within the specified 
rectangle. They return NIL if the line segment is completely outside the rectangle. Otherwise, they 
return T.


Example:


(defun random-color (rng)
  (return-from random-color (gc:scalar (uniform rng 0 255) 
				       (uniform rng 0 255) (uniform rng 0 255))))

(defun clip-line-example (&optional (width *default-width*)
			    (height *default-height*))
  ;;Declare variables
  (let* ((window-name "Move Trackbars to Change the Position of the Line - CLIP-LINE Example")
	 (n 2)
	 (bool 0)
	 (text 0)
	 (font-face +font-hershey-duplex+ )
	 (scale 0.85d0)
	 (line-type 4)
	 (thickness 10)
	 (rect-x (round (/ width 4)))
	 (rect-y (round (/ height 4)))
	 (rect-width (round (/ width n)))
	 (rect-height (round (/ height n))))
    ;;Allocate memory to hold the line pt1 and pt2 values.
    (with-object ((line-pt1-x (alloc :int '(640)))
		  (line-pt1-y (alloc :int '(0)))
		  (line-pt2-x (alloc :int '(0)))
		  (line-pt2-y (alloc :int '(0))))    
      ;;Create a window
      (with-named-window (window-name +window-autosize+)
	(move-window window-name 639 175)
	;;Create trackbars to control the line position/length.
	(create-trackbar "line-pt1-x" window-name line-pt1-x width)
	(create-trackbar "line-pt1-y" window-name line-pt1-y 3000)
	(create-trackbar "line-pt2-x" window-name line-pt2-x width)
	(create-trackbar "line-pt2-y" window-name line-pt2-y height)
	;;Initialize the random number generator. It is used to 
        ;;create random colors for the rectangle, line and text.
	(with-rng ((rng (rng #xFFFFFFFF)))
	  (loop
	     ;;Create a black background, MAT.
	     (with-mat ((mat (mat-zeros 480 640 +8uc3+)))
	       (with-point ((rect-pt1 (point rect-x rect-y))
			    (rect-pt2 (point (+ rect-x rect-width) 
					     (+ rect-y rect-height))))
		 (with-point ((line-pt1 (point (mem-ref line-pt1-x :int) 
					       (mem-ref line-pt1-y :int)))
			      (line-pt2 (point (mem-ref line-pt2-x :int) 
					       (mem-ref line-pt2-y :int))))
		   (with-scalar ((color (scalar 0 255 0)))
		     ;;Create a rectangle.
		     (rectangle mat rect-pt1 rect-pt2 (random-color rng) +filled+ 4 0)
		     ;;Create a line.
		     (line mat line-pt1 line-pt2 (random-color rng) thickness line-type)
		     ;;Evaluate CLIP-LINE and then set to BOOL. If the line is 
		     ;;inside the bounds of the rectangle, return T, else, NIL.
		     (with-rect ((rect (rect rect-x rect-y rect-width rect-height)))
		       (setf bool (clip-line rect line-pt1 line-pt2))
		       ;;Set TEXT parameter for PUT-TEXT.
		       (setf text (cat "Is the Line inside the Rectangle? ===> " 
				       (if bool "YES" "NO")))
		       ;;Print text to window.
		       (put-text mat text (gc:point 10 35) font-face  scale (random-color rng) 
				 (round (/ thickness 5)) line-type))
		     ;;Show and then delete MAT 
		     ;;as it goes out of scope.
		     (imshow window-name mat)))))
	     (let ((c (wait-key 1)))
	       (when (= c 27)
		 (return)))))))))

========================================================================================================================================
BGR
========================================================================================================================================

A macro for SCALAR organized as BGR(BLUE, GREEN, RED) color values.

Note: Both BGR and MAKE-BGR are provided in this library. The first, to match OpenCV's naming 
conventions, the second, to adhere to Common Lisp naming conventions. Except for the name, they are 
the same function. I use the BGR function in the examples in this file because it will make them 
easier to compare with OpenCV examples you find online, thus making this library easier to learn.

LISP-CV: (BGR B G R) => SCALAR
 
LISP-CV: (MAKE-BGR B G R) => SCALAR


    Parameters:	

        B - The blue color value

        G - The green color value

        R - The red color value


BGR is the default color space in OpenCV and Lisp-CV.


Example:

Here BGR supplies a blue color value. The T: prefix signifies that automatic memory management is 
enabled in the RGB macro, (EQ FINALIZER T).

CV> (CIRCLE IMAGE POINT RADIUS (T:BRG 255 0 0) +FILLED+ +AA+ 0)

========================================================================================================================================
ELLIPSE
========================================================================================================================================

Draws a simple or thick elliptic arc or fills an ellipse sector.

C++: void ellipse(Mat& img, Point center, Size axes, double angle, double startAngle, double endAngle, const Scalar& color, 
     int thickness=1, int lineType=8, int shift=0)

LISP-CV: (ELLIPSE (IMG MAT) (CENTER POINT) (AXES SIZE) (ANGLE :DOUBLE) (START-ANGLE :DOUBLE)
             (END-ANGEL :DOUBLE) (COLOR SCALAR) &OPTIONAL ((THICKNESS :INT) 1) ((LINE-TYPE :INT) 8) ((SHIFT :INT) 0)) => :VOID

C++: void ellipse(Mat& img, const RotatedRect& box, const Scalar& color, int thickness=1, int lineType=8)

LISP-CV: (ELLIPSE (IMG MAT) (BOX ROTATED-RECT) (COLOR SCALAR) &OPTIONAL ((THICKNESS :INT) 1) ((LINE-TYPE :INT) 8)) => :VOID


    Parameters:	

        IMG - Image.

        CENTER - Center of the ellipse.

        AXES - Half of the size of the ellipse main axes.

        AMGLE - Ellipse rotation angle in degrees.

        START-ANGLE - Starting angle of the elliptic arc in degrees.

        END-ANGLE - Ending angle of the elliptic arc in degrees.

        BOX - Alternative ellipse representation via ROTATED-RECT. This means that the function dra-
              ws an ellipse inscribed in the rotated rectangle.

        COLOR - Ellipse color.

        THICKNESS - Thickness of the ellipse arc outline, if positive. Otherwise, this indicates th-
                    at a filled ellipse sector is to be drawn.

        LINE-TYPE - Type of the ellipse boundary. See the (LINE) description.

        SHIFT - Number of fractional bits in the coordinates of the center and values of axes.


The functions ELLIPSE with less parameters draws an ellipse outline, a filled ellipse, an elliptic 
arc, or a filled ellipse sector. A piecewise-linear curve is used to approximate the elliptic arc 
boundary. If you need more control of the ellipse rendering, you can retrieve the curve using the 
function (ELLIPSE-2-POLY) and then render it with the function (POLYLINES) or fill it with the 
function (FILL-POLY) . If you use the first variant of the function and you want to draw the whole 
ellipse, not an arc, pass (EQ START-ANGLE 0) and (END-ANGLE 360).


Example 1:

(defun random-color (rng)
  (return-from random-color (scalar (uniform rng 0 255) 
				    (uniform rng 0 255) (uniform rng 0 255))))

(defun ellipse-example-1 ()

  (let ((window-name "ELLIPSE Example 1")
	(angle 0d0))
    ;;Create a window
    (with-named-window (window-name +window-normal+)
      ;;Set window to fullscreen
      (set-window-property window-name +wnd-prop-fullscreen+ 
			   +window-fullscreen+)
      (if (equal 1.0d0 (get-window-property window-name +wnd-prop-fullscreen+)) 
	  (set-window-property window-name +wnd-prop-aspectratio+ 
			       +window-freeratio+))
      ;;Initialize random number generator
      (with-rng ((rng (rng #xFFFFFFFF)))
	(loop
	   ;; Set ELLIPSE CENTER and AXES parameters to random values
	   (with-point ((center (point (uniform rng 0 640) (uniform rng 0 480))))
	     (with-size ((axes (size (coerce (uniform rng 0 420) 'double-float) 
				     (coerce (uniform rng 0 420) 'double-float))))
	       ;;Create a black background, MAT
	       (with-mat ((mat (mat-zeros 640 480 +8uc3+)))
		 (dotimes (n 10)
		   ;;Draw multiple ellipses with varied parameters
		   (ellipse mat center axes angle 0.0d0 
			    (coerce (uniform rng 0 360) 'double-float)
			    (random-color rng) (uniform rng -1 9) +aa+)
		   (sleep .015)
		   ;;Show and then delete MAT
		   (imshow window-name mat)))
	       (let ((c (wait-key 33)))
		 (when (= c 27)
		   (return))))))))))


Example 2:

(defun random-color (rng)
  (return-from random-color (scalar (uniform rng 0 255) 
				    (uniform rng 0 255) (uniform rng 0 255))))

(defun ellipse-example-2 ()
  (let ((window-name "ELLIPSE Example 2")
	(box-angle 0f0))
    ;; Create a window
    (with-named-window (window-name +window-normal+)
      ;; Set window to fullscreen
      (set-window-property window-name +wnd-prop-fullscreen+ 
			   +window-fullscreen+)
      (if (equal 1.0d0 (get-window-property window-name +wnd-prop-fullscreen+)) 
	  (set-window-property window-name +wnd-prop-aspectratio+ 
			       +window-freeratio+))
      ;; Initialize random number generator
      (with-rng ((rng (rng #xFFFFFFFF)))
	(loop
	   ;; Set BOX location and size to random values
	   (with-point ((box-loc (point (uniform rng 0 640) (uniform rng 0 480))))
	     (with-size ((box-size (size (coerce (uniform rng 0 420) 'double-float) 
					 (coerce (uniform rng 0 420) 'double-float))))
	       (setf box-angle (coerce (uniform rng 0 360) 'single-float))
	       ;; Create BOX
	       (with-rotated-rect ((box (rotated-rect box-loc box-size box-angle)))
		 ;; Create a black background, MAT
		 (with-mat ((mat (mat-zeros 640 480 +8uc3+)))
		   (dotimes (n 10)
		     ;;Draw multiple ellipses with varied parameters
		     (ellipse mat box (random-color rng) (uniform rng -1 9) 
			      +aa+)
		     (sleep .015)
		     ;; Show and then delete MAT
		     (imshow window-name mat)))
		 (let ((c (wait-key 33)))
		   (when (= c 27)
		     (return)))))))))))

========================================================================================================================================
#GET-TEXT-SIZE
========================================================================================================================================


Calculates the width and height of a text string.


C++: Size getTextSize(const string& text, int fontFace, double fontScale, int thickness, int* baseLine)

LISP-CV:  (GET-TEXT-SIZE (TEXT :STRING) (FONT-FACE :INT) (FONT-SCALE :DOUBLE) (THICKNESS :INT) (BASE-LINE :POINTER)) 
           => SIZE


    Parameters:	

        TEXT - Input text string.

        FONT-FACE - Font to use. See (PUT-TEXT) for details.

        FONT-SCALE - Font scale. See (PUT-TEXT) for details.

        THICKNESS - Thickness of lines used to render the text. See (PUT-TEXT) for details.

        BASE-LINE - Output parameter - y-coordinate of the baseline relative to the bottom-most text 
                    point.


The function GET-TEXT-SIZE calculates and returns the size of a box that contains the specified text. 
That is, the following code renders some text, the tight box surrounding it, and the baseline:


(defun get-text-size-example ()
        ;; Declare variables
  (let* ((window-name "GET-TEXT Example")
	 (text "Funny text inside the box")
	 (font-face +font-hershey-script-simplex+)
	 (font-scale 2.0d0)
	 (thickness 3))
             ;; Create background
    (with-mat ((img (mat 600 800 +8uc3+ (t:scalar-all 0))))
      (with-object ((base-line (alloc :int 0)))
	(with-named-window (window-name +window-normal+)

	  ;; Set window to fullscreen
	  (set-window-property window-name +wnd-prop-fullscreen+ 
			       +window-fullscreen+)
	  (set-window-property window-name +wnd-prop-aspectratio+ 
			       +window-freeratio+)
  
	  (setf (mem-aref base-line :int) thickness)
	  ;; Calculates the width and height of TEXT.
	  (with-size ((text-size (get-text-size text font-face font-scale thickness base-line)))
	    ;; Center the text
	    (with-point((text-org (point (round (/ (- (cols img) (width text-size)) 2)) 
					 (round (/ (- (rows img) (height text-size)) 2))))
                        ;; Set rectangle coordinates
			(pt1 (point (x text-org) (round (+ (y text-org) 
								 (mem-aref base-line :int)))))

			(pt2 (point (round (+ (x text-org) (width text-size))) 
				    (round (- (y text-org) (height text-size))))))

	      (with-scalar ((color (scalar 0 0 255)))
                ;; Draw the box 
		(rectangle img pt1 pt2 color)
		(with-point ((pt1 (point (x text-org) (round (+ (y text-org) 
								      thickness))))
			     (pt2 (point (+ (x text-org) (round (width text-size))) 
					 (+ (y text-org) thickness))))
                  ;; Draw the baseline 
		  (line img pt1 pt2 color)

		  ;; Add the text
		  (with-scalar ((color (scalar-all 255)))
		    (put-text img text text-org font-face font-scale color thickness 8))
                  ;; Show the result
		  (imshow window-name img)
		  (loop
		     (let ((c (wait-key 33)))
		       (when (= c 27)
			 (return)))))))))))))

========================================================================================================================================
#LINE
========================================================================================================================================

Draws a line segment connecting two points.

C++: void line(Mat& img, Point pt1, Point pt2, const Scalar& color, int thickness=1, int lineType=8, int shift=0)

LISP-CV: (LINE (IMG MAT) (PT-1 POINT) (PT-2 POINT) (COLOR SCALAR) &OPTIONAL ((THICKNESS :INT) 1) ((LINE-TYPE :INT) 8) 
         ((SHIFT :INT) 0)) => :VOID

    Parameters:	

              IMG - Image.

              PT1 - First point of the line segment.

              PT2 - Second point of the line segment.

              COLOR - Line color.

              THICKNESS - Line thickness.

              LINE-TYPE - Type of the line:

                       8 (or omitted) - 8-connected line.

                       4 - 4-connected line.

                       +AA+ - antialiased line.

              SHIFT - Number of fractional bits in the point coordinates.



The function LINE draws the line segment between PT1 and PT2 points in the image. The line is clipped 
by the image boundaries. For non-antialiased lines with integer coordinates, the 8-connected or the 
4-connected Bresenham algorithm is used. Thick lines are drawn with rounding endings. Antialiased lines 
are drawn using Gaussian filtering. To specify the line color, you may use the macros RGB -> (RGB R G B) 
and BGR -> (BGR B G R).


(defun line-example ()

  (let ((window-name "LINE Example")
        ;; Initialize random number generator
	(rng (rng #xFFFFFFFF))
	;; Create a black background
	(mat (mat-zeros 640 480 +8uc3+)))
    ;; Create a window
    (named-window window-name +window-normal+)
    ;; Set window to fullscreen
    (set-window-property window-name +wnd-prop-fullscreen+ 
			 +window-fullscreen+)
    (if (equal 1.0d0 (get-window-property window-name +wnd-prop-fullscreen+)) 
	(set-window-property window-name +wnd-prop-aspectratio+ 
			     +window-freeratio+))
    ;; Set line type and thickness
    (do* ((line-type +aa+)
	  (thickness 1)
	  (pt1 0)
	  (pt2 0)
          (x-1 -450)
	  (x-2 1350)
	  (y-1 -450)
	  (y-2 1350))
	 ((plusp (wait-key 1)) 
	  (format t "Key is pressed by user"))
      ;; Set the lines points to random values
      (setf pt1 (point (uniform rng x-1 x-2) (uniform rng y-1 y-2)))    
      (setf pt2 (point (uniform rng x-1 x-2) (uniform rng y-1 y-2)))
      ;; Draw a line
      (line mat pt1 pt2 (bgr 255 0 0) thickness line-type)
      ;; Show output
      (imshow window-name mat))
    (destroy-window window-name)))

========================================================================================================================================
#PUT-TEXT
========================================================================================================================================

Draws a text string.

C++: void putText(Mat& img, const string& text, Point org, int fontFace, double fontScale, Scalar color, int thickness=1, 
     int lineType=8, bool bottomLeftOrigin=false )

LISP-CV: (PUT-TEXT (IMG MAT) (TEXT :STRING) (ORG POINT) (FONT-FACE :INT) (FONT-SCALE :DOUBLE)  
             (COLOR SCALAR) &OPTIONAL (THICKNESS :INT) (LINE-TYPE :INT) (BOTTOM-LEFT-ORIGN :BOOLEAN)) => :VOID
 
    Parameters:	

        IMG - Image.

        TEXT - Text string to be drawn.

        ORG - Bottom-left corner of the text string in the image.

        FONT-FACE - Font type. One of: +FONT-HERSHEY-SIMPLEX+ 

                                       +FONT-HERSHEY-PLAIN+ 

                                       +FONT-HERSHEY-DUPLEX+ 

                                       +FONT-HERSHEY-COMPLEX+ 

                                        FONT_HERSHEY_ITALIC

                                       +FONT-HERSHEY-COMPLEX-SMALL+ 

                                       +FONT-HERSHEY-SCRIPT-SIMPLEX+ 
 
                                       +FONT-HERSHEY-SCRIPT-COMPLEX+ 


where each of the font id’s can be combined with +FONT-ITALIC+ to get the slanted letters.


        FONT-SCALE - Font scale factor that is multiplied by the font-specific base size.

        COLOR- Text color.

        THICKNESS - Thickness of the lines used to draw a text.

        LINE-TYPE - Line type. See the line for details.

        BOTTOM-LEFT-ORIGIN - When true, the image data origin is at the bottom-left corner. Otherwi-
                             se, it is at the top-left corner.


The function PUT-TEXT renders the specified text string in the image. Symbols that cannot be render
ed using the specified font are replaced by question marks. See (GET-TEXT-SIZE) for another text 
rendering code example.


Example:

(defun random-color (rng)
  (return-from random-color (scalar (uniform rng 0 255) 
				    (uniform rng 0 255) (uniform rng 0 255))))

(defun put-text-example ()

  (let* ((window-name "PUT-TEXT Example")
	 (window-width 1280)
	 (window-height 1024)
	 ;; Initialize random number generator
	 (rng (rng #xFFFFFFFF))
	 ;; Create a black background
	 (mat (mat-zeros window-width window-height +8uc3+)))
    ;; Create a window
    (named-window window-name +window-normal+)
    ;; Set window to fullscreen
    (set-window-property window-name +wnd-prop-fullscreen+ 
			 +window-fullscreen+)
    (if (equal 1.0d0 (get-window-property window-name +wnd-prop-fullscreen+)) 
	(set-window-property window-name +wnd-prop-aspectratio+ 
			     +window-freeratio+))
    ;; Set line type
    (do* ((line-type +aa+)
	  (i 0)
          (iterations 0)
          (scale 10.40d0)
	  ;; Initialize text position variables
	  (org 0)
          (x-1 0)
	  (x-2 0)
          (y 0))
	 ((plusp (wait-key 1)) 
	  (format t "Key is pressed by user"))
      ;; Were doing multiple prints of text to screen per loop here
      (dotimes (n iterations) 
	;; Set the texts location to random values
	(setf org (point (uniform rng x-1 x-2) y))
        ;; Print text
	(put-text mat "LisP-CV" org +font-hershey-complex-small+
		  scale  (random-color rng) (uniform rng 5 50) line-type))
      (incf i)
      (if (< y (+ window-height 358)) (incf y 2) (setf y 0))
      (if (< iterations 4) (incf iterations 1) (setf iterations 1))
      ;; Show result in window
      (imshow window-name mat))
    (destroy-window window-name)))

========================================================================================================================================
#RECTANGLE
========================================================================================================================================

Draws a simple, thick, or filled up-right rectangle.

C++: void rectangle(Mat& img, Point pt1, Point pt2, const Scalar& color, int thickness=1, int lineType=8, int shift=0)

LISP-CV: (RECTANGLE (IMG MAT) (PT1 POINT) (PT2 POINT) (COLOR SCALAR) &OPTIONAL ((THICKNESS :INT) 1) ((LINE-TYPE :INT) 8) 
         ((SHIFT :INT) 0)) => :VOID


    Parameters:	

        Parameters:	

              IMG - Image.

              PT1 - Vertex of the rectangle.

              PT2 - Vertex of the rectangle opposite to pt1 .

              COLOR - Rectangle color or brightness (grayscale image).

              THICKNESS - Thickness of lines that make up the rectangle. 
                          Negative values, like +FILLED+ (-1) , mean that 
                          the function has to draw a filled rectangle.

              LINE-TYPE - Type of the line:

                      8 (or omitted) - 8-connected line.

                      4 - 4-connected line.

                     +AA+ - antialiased line.

             SHIFT - Number of fractional bits in the point coordinates.

The function rectangle draws a rectangle outline or a filled rectangle whose two opposite corners a-
re PT1 and PT2.


Example:

(defun random-color (rng &optional (icolor 0))
  (setf icolor rng)
  (return-from random-color (scalar (uniform rng 0 255) 
				    (uniform rng 0 255) 
				    (uniform rng 0 255))))

(defun rectangle-example ()
  (with-rng ((rng (rng #xFFFFFFFF)))
    (let* ((window-name "RECTANGLE Example")
	   (window-width 640)
	   (window-height 480)
	   ;; Set line type and thickness
	   (line-type +aa+)
	   (thickness (uniform rng -3 10))
	   ;; Initialize rectangle position variables
	   (x-1 (/ (* window-width -1) 2))
	   (x-2 (/ (* window-width 3) 2))
	   (y-1 (/ (* window-width -1) 2))
	   (y-2 (/ (* window-width 3) 2)))
      ;; Create a window
      (with-named-window 
	  (window-name +window-normal+)
	;; Set window to fullscreen
	(set-window-property window-name +wnd-prop-fullscreen+ 
			     +window-fullscreen+)
	(set-window-property window-name +wnd-prop-aspectratio+ 
			     +window-freeratio+)
	;; Initialize random number generator
	;; Create a black background
	(with-mat 
	    ((mat (mat-zeros window-width window-height +8uc3+)))
	  (loop
	     ;; Print randomly colored rectangles to screen
	     (with-point 
		 ((pt1 (point (uniform rng x-1 x-2) (uniform rng y-1 y-2)))
		  
		  (pt2 (point (uniform rng x-1 x-2) (uniform rng y-1 y-2))))
	       (rectangle mat pt1 pt2 (random-color rng) thickness line-type)
	       ;; Show result in window
	       (imshow window-name mat)
	       (let ((c (wait-key 33)))
		 (when (= c 27)
		   (return))))))))))

========================================================================================================================================
#RGB
========================================================================================================================================

A macro for SCALAR organized as RGB(RED, GREEN, BLUE) color values.

Note: Both RGB and MAKE-RGB are provided in this library. The first, to match OpenCV's naming 
conventions, the second, to adhere to Common Lisp naming conventions. Except for the name, they are 
the same function. I use the RGB function in the examples in this file because it will make them 
easier to compare with OpenCV examples you find online, thus making this library easier to learn.

LISP-CV: (RGB R G B) => SCALAR

LISP-CV: (MAKE-RGB R G B) => SCALAR

    Parameters:	

        R - The red color value

        G - The green color value

        B - The blue color value

A creative reversal of the default BGR color space in Lisp-CV. Values are put into the RGB macro in
Red, Green, Blue, order, but are ultimately entered into the recieving function as BGR. This macro 
is designed for ease of use.


Usage:

Here RGB supplies a red color value. The T: prefix signifies that automatic memory management is 
enabled in the RGB macro, (EQ FINALIZER T).

CV> (CIRCLE IMAGE POINT RADIUS (T:RGB 255 0 0) +FILLED+ +AA+ 0) 


========================================================================================================================================
#CORE - #XML/YAML PERSISTENCE:
========================================================================================================================================

========================================================================================================================================
#FILE-STORAGE
========================================================================================================================================

The constructors.

Note: Both FILE-STORAGE and MAKE-FILE-STORAGE are provided in this library. The first, to match OpenCV's 
naming conventions, the second, to adhere to Common Lisp naming conventions. Except for the name, they are 
the same function. I use the FILE-STORAGE function in the examples in this file because it will make them 
easier to compare with OpenCV examples you find online, thus making this library easier to learn.

C++: FileStorage::FileStorage()

LISP-CV: (FILE-STORAGE) => FILE-STORAGE

LISP-CV: (MAKE-FILE-STORAGE) => FILE-STORAGE

C++: FileStorage::FileStorage(const String& source, int flags, const String& encoding=String())

LISP-CV: (FILE-STORAGE (SOURCE :STRING) (FLAGS :INT) (ENCODING :STRING)) => FILE-STORAGE

LISP-CV: (MAKE-FILE-STORAGE (SOURCE :STRING) (FLAGS :INT) (ENCODING :STRING)) => FILE-STORAGE

    Parameters:	


        SOURCE - Name of the file to open or the text string to read the data from. Extension of the 
                 file (.xml or .yml/.yaml) determines its format (XML or YAML respectively). Also you 
                 can append .gz to work with compressed files, for example myHugeMatrix.xml.gz. If both 
                 +FILE-STORAGE-WRITE+ and +FILE-STORAGE-MEMORY+ flags are specified, source is used just 
                 to specify the output file format (e.g. mydata.xml, .yml etc.).

        FLAGS -

        Mode of operation. Possible values are:

            +FILE-STORAGE-READ+ Open the file for reading.

            +FILE-STORAGE-WRITE+ Open the file for writing.

            +FILE-STORAGE-APPEND+ Open the file for appending.

            +FILE-STORAGE-MEMORY+ Read data from source or write data to the internal buffer (which 
                                  is returned by the FILE-STORAGE class RELEASE method)

        ENCODING - Encoding of the file. Note that UTF-16 XML encoding is not supported currently 
                   and you should use 8-bit encoding instead of it.


The full constructor opens the file. Alternatively you can use the default constructor and then call 
the FILE-STORAGE class OPEN method.


Example:

See FILE-STORAGE-WRITE-EXAMPLE

========================================================================================================================================
#FILE-STORAGE-OPEN
========================================================================================================================================

Opens a file.

Note: The name FILE-STORAGE-OPEN is used in the documentation to refer to the binding for the 
"open" member of the OpenCV FileStorage class because it is more descriptive and it is easier 
to search for in this file. The OPEN function may also be used to call this binding. 

Note: The LISP-CV function OPEN overloads the Common Lisp function OPEN so both functions can use the 
same name. The LISP-CV function OPEN provides the the same functionality as the Common Lisp function 
OPEN and the 'open' members of OpenCV's classes. To use the Common Lisp function OPEN directly, while 
you are in the LISP-CV package, you need to evaluate CL:OPEN.


C++: bool FileStorage::open(const String& filename, int flags, const String& encoding=String())

LISP-CV: (OPEN) (SELF FILE-STORAGE) (FILENAME :STRING) (FLAGS :INT) (ENCODING :STRING)) => :BOOLEAN

LISP-CV: (FILE-STORAGE-OPEN) (SELF FILE-STORAGE) (FILENAME :STRING) (FLAGS :INT) (ENCODING :STRING)) => :BOOLEAN


    Parameters:	

        FILENAME - Name of the file to open or the text string to read the data from. Extension of 
                   the file (.xml or .yml/.yaml) determines its format (XML or YAML respectively). 
                   Also you can append .gz to work with compressed files, e.g. myHugeMatrix.xml.gz. 
                   If both the +FILE-STORAGE-WRITE+ and +FILE-STORAGE-MEMORY+ flags are specified, 
                   source is used just to specify the output file format (e.g. mydata.xml/.yml...).

        FLAGS - Mode of operation. See FILE-STORAGE constructor for more details.

        ENCODING - Encoding of the file. Note that UTF-16 XML encoding is not supported currently 
                   and you should use 8-bit encoding instead of it.

See description of parameters in the FILE-STORAGE constructor. This function calls (FILE-STORAGE-RELEASE) 
before opening the file.


Example:

(defun file-storage-open-example (save-directory) 

  (let ((filename (cat save-directory "matrix.yml")))
    ;;Create a matrix
    (with-mat ((matrix (mat-ones 5 5 +64f+)))
      ;;Create a FILE-STORAGE object
      (with-file-storage ((fs (file-storage)))
	;;Open the file for writing
	(if (open fs filename +file-storage-write+)
	    (format t "~%File open...~%") nil)
	;;Write the matrix to the file
	(write fs "matrix" matrix)
	(format t "~%Wrote matrix to ~a~%~%" filename)
	(release fs)))))

========================================================================================================================================
#FILE-STORAGE-RELEASE
========================================================================================================================================

Note: The name FILE-STORAGE-RELEASE is used in the documentation to refer to the binding for the 
"release" member of the OpenCV FileStorage class because it is more descriptive and it is easier 
to search for in this file. The RELEASE method may also be used to call this binding. 


Closes the file and releases all the memory buffers.

C++: void FileStorage::release()

LISP-CV: (RELEASE (SELF FILE-STORAGE)) => :VOID

LISP-CV: (FILE-STORAGE-RELEASE (SELF FILE-STORAGE)) => :VOID

Call this method after all I/O operations with the storage are finished.


Example:

See FILE-STORAGE-OPEN-EXAMPLE in this file

========================================================================================================================================
#FILE-STORAGE-WRITE
========================================================================================================================================

Writes an object or number to file storage.


Note: The name FILE-STORAGE-WRITE is used in the documentation to refer to the binding for the 
"write" member of the OpenCV FileStorage class because it is more descriptive and it is easier 
to search for in this file. The WRITE methods may also be used to call this binding. 


C++: void write( FileStorage& fs, const String& name, double value )

LISP-CV: (WRITE (FS FILE-STORAGE) (NAME :STRING) (VALUE :DOUBLE)) => :VOID

LISP-CV: (FILE-STORAGE-WRITE (FS FILE-STORAGE) (NAME :STRING) (VALUE :DOUBLE)) => :VOID

C++: void write( FileStorage& fs, const String& name, float value )

LISP-CV: (WRITE (FS FILE-STORAGE) (NAME :STRING) (VALUE :FLOAT)) => :VOID

LISP-CV: (FILE-STORAGE-WRITE (FS FILE-STORAGE) (NAME :STRING) (VALUE :FLOAT)) => :VOID

C++: void write( FileStorage& fs, const String& name, int value )

LISP-CV: (WRITE (FS FILE-STORAGE) (NAME :STRING) (VALUE :INT)) => :VOID

LISP-CV: (FILE-STORAGE-WRITE (FS FILE-STORAGE) (NAME :STRING) (VALUE :INT)) => :VOID

C++: void write( FileStorage& fs, const String& name, const String& value )

LISP-CV: (WRITE (FS FILE-STORAGE) (NAME :STRING) (VALUE STRING)) => :VOID

LISP-CV: (FILE-STORAGE-WRITE (FS FILE-STORAGE) (NAME :STRING) (VALUE STRING)) => :VOID

C++: void write( FileStorage& fs, const String& name, const Mat& value )

LISP-CV: (WRITE (FS FILE-STORAGE) (NAME :STRING) (VALUE MAT)) => :VOID

LISP-CV: (FILE-STORAGE-WRITE (FS FILE-STORAGE) (NAME :STRING) (VALUE MAT)) => :VOID

C++: void write( FileStorage& fs, const String& name, const std::vector<KeyPoint>& value)

LISP-CV: (WRITE (FS FILE-STORAGE) (NAME :STRING) (VALUE VECTOR-KEY-POINT)) => :VOID

LISP-CV: (FILE-STORAGE-WRITE (FS FILE-STORAGE) (NAME :STRING) (VALUE VECTOR-KEY-POINT)) => :VOID


    Parameters:	

        FS - A FILE-STORAGE object

        NAME - Name of the written object.
  
        VALUE - The object or number to be written.


The methods write an object or a number to file storage.


Example:

(defun file-storage-write-example (filename save-directory) 

  ;;Write a double float to a YML file
  (let ((double-float 1.0d0))
    (with-file-storage ((fs (file-storage 
			     (cat save-directory "double-float.yml")  
			     +file-storage-write+)))
      (write fs "double-float" double-float)

      (release fs)))

  ;;Write a single float to a YML file
  (let ((single-float 2.0f0))
    (with-file-storage ((fs (file-storage 
			     (cat save-directory "single-float.yml")  
			     +file-storage-write+)))
      (write fs "single-float" single-float)
      (release fs)))

  ;;Write an integer to a YML file
  (let ((integer 3))
    (with-file-storage ((fs (file-storage 
			     (cat save-directory "integer.yml")  
			     +file-storage-write+)))
      (write fs "integer" integer)
      (release fs)))

  ;;Write a string to a YML file
  (let ((string "LISP-CV ROCKS!!!"))
    (with-file-storage ((fs (file-storage 
			     (cat save-directory "string.yml")  
			     +file-storage-write+)))
      (write fs "string" string)
      (release fs)))

  ;;Write a matrix to a YML file
  (with-mat ((matrix (mat-eye 10 10 +64fc3+)))
    (with-file-storage ((fs (file-storage 
			     (cat save-directory "matrix.yml")  
			     +file-storage-write+)))
      (write fs "matrix" matrix)
      (release fs)))

  ;;Write a vector of keypoints to a YML file
  (with-named-window ("FILE-STORAGE-WRITE Example" +window-normal+)
    (move-window "FILE-STORAGE-WRITE Example" 759 175)
    ;;Read in image
    (with-mat ((image (imread filename +load-image-color+)))
      (if (empty image) 
	  (return-from file-storage-write-example 
	    (format t "Image was not loaded")))
      ;;Create BRISK feature detector
      (with-brisk ((detector (brisk)))
	;;Create vector to hold the keypoints
	(with-vector-key-point ((key-points (vector-key-point)))
	  ;;Detect the keypoints using BRISK
	  (detect detector image key-points)
	  ;;Create FILE-STORAGE object
	  (with-file-storage ((fs (file-storage 
				   (cat save-directory "keypoints.yml" ) 
				   +file-storage-write+)))
	    ;;Write the keypoints to a YML file
	    (write fs "keypoints" key-points)
	    ;;Release FILE-STORAGE object
	    (release fs)
	    (imshow "FILE-STORAGE-WRITE Example" image)
	    (loop
	       (let ((c (wait-key 33)))
		 (when (= c 27)
		   (return))))))))))


========================================================================================================================================
#CORE - #CLUSTERING
========================================================================================================================================

========================================================================================================================================
KMEANS
========================================================================================================================================

Finds centers of clusters and groups input samples around the clusters.

C++: double kmeans(InputArray data, int K, InputOutputArray bestLabels, TermCriteria criteria, int attempts, int flags, 
                   OutputArray centers=noArray() )

LISP-CV: (KMEANS (DATA MAT) (K :INT) (BEST-LABELS MAT) (CRITERIA TERM-CRITERIA) (ATTEMPTS :INT) (FLAGS :INT) 
                  &OPTIONAL ((CENTERS MAT) (%MAT))) => :VOID

    Parameters:	

        DATA - Data for clustering. An array of N-Dimensional points with float coordinates is needed. 

               Examples of this array can be:

                   (DEFPARAMETER POINTS (MAT COUNT 2 +32F+))

                   (DEFPARAMETER POINTS (MAT COUNT 1 +32FC2+))

                   (DEFPARAMETER POINTS (MAT 1 COUNT +32FC2+))

        K - Number of clusters to split the set by.

        BEST-LABELS - Input/output integer array that stores the cluster indices for every sample.

        CRITERIA - The algorithm termination criteria, that is, the maximum number of iterations and/or 
                   the desired accuracy. The accuracy is specified as (EPSILON CRITERIA). As soon as each 
                   of the cluster centers moves by less than (EPSILON CRITERIA) on some iteration, the algorithm 
                   stops.

        ATTEMPTS - Flag to specify the number of times the algorithm is executed using different initial labellings. 
                   The algorithm returns the labels that yield the best compactness (see the last function parameter).

        FLAGS - Flag that can take the following values:

            +KMEANS-RANDOM-CENTERS+ Select random initial centers in each attempt.

            +KMEANS-PP-CENTERS+ Use kmeans++ center initialization by Arthur and Vassilvitskii.

            +KMEANS-USE-INITIAL-LABELS+ During the first (and possibly the only) attempt, use the 
                                        user-supplied labels instead of computing them from the initial 
                                        centers. For the second and further attempts, use the random or semi-
                                        random centers. Use one of the +KMEANS-*-CENTERS+ flags to specify the 
                                        exact method.

        CENTERS - Output matrix of the cluster centers, one row per each cluster center.


See OpenCV documentation at this link:

http://docs.opencv.org/trunk/modules/core/doc/clustering.html?highlight=kmeans#kmeans

for further description and formulae:


Example:

(defun kmeans-example ()

  (let ((window-name "Clusters - KMEANS example")
        (max-clusters 5)
	(cluster-count)
	(sample-count)
        (cluster-idx)
        (ipt)
	;;Create an array of color values.
	(color-tab 
	 (t:alloc 'scalar (list
			   (scalar 0 0 255)
			   (scalar 0 255 0)
			   (scalar 255 100 100)
			   (scalar 255 0 255)
			   (scalar 0 255 255)))))
    (with-named-window (window-name +window-autosize+)
      (move-window window-name 710 175)
      (with-mat ((img (mat 500 500 +8UC3+)))
        ;;Create random number generator.
	(with-rng ((rng (rng 12345)))
	  ;;Set CLUSTER-COUNT and SAMPLE-COUNT to random numbers.
	  (setf cluster-count (uniform rng 2 (+ max-clusters 1)))
	  (setf sample-count (uniform rng 1 1001))
	  (with-mat ((points (mat sample-count 1 +32FC2+))
		     (labels* (mat)))
	    (setf cluster-count (min cluster-count sample-count))
	    (with-mat ((centers (mat)))

	      ;;;Generate random sample from multigaussian distribution:

	      (dotimes (k cluster-count)

		(with-point ((center (point)))

		  (setf (x center) (uniform rng 0 (cols img)))
		  (setf (y center) (uniform rng 0 (rows img)))
		  (with-mat ((point-chunk 
			      (row-range points (* k 
						   (floor 
						    (/ sample-count cluster-count)))
					 (if (eq k (- cluster-count 1)) sample-count
					     (floor (* (+ k 1) (/ sample-count cluster-count)))))))
		    ;;Fill POINT-CHUNK with random numbers.
		    (fill rng point-chunk +rng-normal+ (scalar (x center) (y center))
			  (scalar (* (cols img) 0.05d0) (* (cols img) 0.05d0))))))

	      ;;Shuffle the array elements.
	      (rand-shuffle points 1d0 rng)

	      (with-term-criteria ((criteria (term-criteria (+ 
							     +term-criteria-eps+
							     +term-criteria-count+) 10 1.0d0)))
                ;;Find centers of clusters and groups input samples around the clusters.
		(kmeans points cluster-count labels* criteria 3 +kmeans-pp-centers+ centers)))
            ;;Fill IMG with 0's.
	    (assign img (scalar-all 0))
	    ;;Draw input samples.
	    (dotimes (i sample-count)
	      (setf cluster-Idx (at-int labels* i))
	      (setf ipt (at-point-2f points i))
	      (circle img ipt 2 (@ color-tab 'scalar cluster-idx) +filled+ +aa+))
	    (imshow window-name img)
	    (loop
	       (let ((c (wait-key 33)))
		 (when (= c 27)
		   (return))))))))))

========================================================================================================================================
#CORE - #UTILITY AND SYSTEM FUNCTIONS AND MACROS
========================================================================================================================================

========================================================================================================================================
#CHECK-HARDWARE-SUPPORT
========================================================================================================================================

Returns true if the specified feature is supported by the host hardware.

C++: bool checkHardwareSupport(int feature)

LISP-CV: (CHECK-HARDWARE-SUPPORT (FEATURE :INT)) => :BOOLEAN

    Parameters:	feature -

       The feature of interest, one of:

             +CPU_MMX+ - MMX
             +CPU_SSE+ - SSE
             +CPU_SSE2+ - SSE 2
             +CPU_SSE3+ - SSE 3
             +CPU_SSSE3+ - SSSE 3
             +CPU_SSE4_1+ - SSE 4.1
             +CPU_SSE4_2+ - SSE 4.2
             +CPU_POPCNT+ - POPCOUNT
             +CPU_AVX+ - AVX

The function returns true if the host hardware supports the specified feature. When user calls 
(SET-USE-OPTIMIZED 0), the subsequent calls to (CHECK-HARDWARE-SUPPORT) will return false until 
(SET-USE-OPTIMIZED 1) is called. This way user can dynamically switch on and off the optimized 
code.


(defun check-hardware-support-example ()

  "Returns true if the specified feature is supported 
   by the host hardware. Returns 0 otherwise"

  (let*  ((mmx (check-hardware-support +cpu-mmx+))
	  (sse (check-hardware-support +cpu-sse+))
          (sse2 (check-hardware-support +cpu-sse2+))
          (sse3 (check-hardware-support +cpu-sse3+))
          (ssse3 (check-hardware-support +cpu-ssse3+))
          (sse4-1 (check-hardware-support +cpu-sse4-1+))   
          (sse4-2 (check-hardware-support +cpu-sse4-2+))
          (popcnt (check-hardware-support +cpu-popcnt+))
	  (avx (check-hardware-support +cpu-avx+))
	  (hardware-max-feature (check-hardware-support 
                                 +hardware-max-feature+)))
    (format t "~%MMX Support = ~a~%" mmx)
    (format t "SSE Support = ~a~%" sse)
    (format t "SSE2 Support = ~a~%" sse2)
    (format t "SSE3 Support = ~a~%" sse3)
    (format t "SSSE3 Support = ~a~%" ssse3)
    (format t "SSE4-1 Support = ~a~%" sse4-1)
    (format t "SSE4-2 Support= ~a~%" sse4-2)
    (format t "POPCOUNT Support = ~a~%" popcnt)
    (format t "AVX Support = ~a~%" avx)
    (format t "HARDWARE-MAX-FEATURE = ~a~%~%" 
	    hardware-max-feature)))


========================================================================================================================================
#CUBE-ROOT
========================================================================================================================================

Computes the cube root of an argument.

C++: float cubeRoot(float val)

LISP-CV:: (CUBE-ROOT (VAL :FLOAT)) => :FLOAT

    Parameters:	VAL - A function argument.

The function CUBE-ROOT computes the cubic root of VAL. Negative arguments are handled correctly. NAN 
and INFINITY are not handled. The accuracy approaches the maximum possible accuracy for single-precision 
data.


(defun cube-root-example (&optional (float-val 27.0))
  "Computes the cube root of FLOAT-VAL."
  (format t "Cube root of FLOAT-VAL = ~a~%~%" 
	  (cube-root float-val)))


========================================================================================================================================
#FAST-ATAN2
========================================================================================================================================

Calculates the angle of a 2D vector in degrees.

C++: float fastAtan2(float y, float x)

LISP-CV: (FAST-ATAN2 (X :FLOAT) (Y :FLOAT)) => :FLOAT

    Parameters:	

        X - x-coordinate of the vector.

        Y - y-coordinate of the vector.


The function FAST-ATAN2 calculates the full-range angle of an input 2D vector. The angle is measured 
in degrees and varies from 0 to 360 degrees. The accuracy is about 0.3 degrees.


(defun fast-atan2-example (x y)

  "Calculates the angle of a 2D 
   float vector in degrees."

  (let*  ((float-y x)
          (float-x y))
    (format t "Angle of vector - float = ~a~%~%" 
	    (fast-atan2 float-y float-x))))


========================================================================================================================================
get-Build-Information
========================================================================================================================================

Returns full configuration time cmake output.

C++: const String& getBuildInformation()

LISP-CV: (GET-BUILD-INFORMATION) => :STRING

Returned value is raw cmake output including version control system revision, compiler version, 
compiler flags, enabled modules and third party libraries, etc. Output format depends on target 
architecture.


Example:

No example neccessary here. All you do is evaluate the function:).

========================================================================================================================================
#GET-NUMBER-OF-CPUS
========================================================================================================================================

Returns the number of logical CPUs available for the process.


C++: int getNumberOfCPUs()

LISP-CV: (GET-NUMBER-OF-CPUS) => :INT


Example:

(defun get-number-of-cpus-example ()

  (format t "~%The number of CPU's = ~a~%~%" 

	  (get-number-of-cpus)))

========================================================================================================================================
#GET-TICK-COUNT
========================================================================================================================================

Returns the number of ticks.


C++: int64 getTickCount()

LISP-CV: (GET-TICK-COUNT) => :INT64


The function returns the number of ticks after the certain event (for example, when the machine was
turned on). It can be used to initialize (RNG) - Random Number Generator - or to measure a function 
execution time by reading the tick count before and after the function call. 

See also: (GET-TICK-FREQUENCY)



(defun get-tick-count-example ()

  "Calculates the amount CPU ticks that occur while 
   running the function used to create a matrix MAT 
   once and 1000 times in microseconds."

  (let* ((t1 0)
	 (t2 0)
	 (time-calc 0))
    (setf t1 (get-tick-count))
    (dotimes (i 1)
      (mat))
    (setf t2 (get-tick-count))
    (setf time-calc (- t2 t1))
    (format t "~a CPU ticks occurred while running MAT once ~%" 
	    time-calc)
    
    (setf t1 (get-tick-count))
    (dotimes (i 1000)
      (mat))
    (setf t2 (get-tick-count))
    (setf time-calc (- t2 t1))
    (format t "~a CPU ticks occurred while ruuning MAT 1000 times ~%"  
	    time-calc)))

========================================================================================================================================
#GET-TICK-FREQUENCY
========================================================================================================================================

Returns the number of ticks per second.


C++: double getTickFrequency()

LISP-CV: (GET-TICK-FREQUENCY) => :DOUBLE


The function returns the number of ticks per second. That is, the following code computes the execu-
tion time in seconds:


(defun get-tick-frequency-example ()

  "Calculates the seconds that pass while the SLEEP function 
   is ran for 5 seconds and the seconds that pass while runn-
   ing the MAT-EYE function(used to create an identity matri-
   x) 1 million times for comparision.
   
   Note: This function takes about 6 seconds to complete on 
   a Quad-Core Processor."

  (let* ((t1 0)
	 (t2 0)
	 (time-calc 0))
    (setf t1 (coerce (get-tick-count) 'double-float))
    (sleep 5)
    (setf t2 (coerce (get-tick-count) 'double-float))
    (setf time-calc (/ (- t2 t1) (get-tick-frequency)))
    (format t "Sleeping for 5 seconds took ~a seconds~%~%" 
	    time-calc)
    (setf t1 (coerce (get-tick-count) 'double-float))
    (dotimes (i 1000000)
      (mat-eye 3 3 +8u+))
    (setf t2 (coerce (get-tick-count) 'double-float))
    (setf time-calc (/ (- t2 t1) (get-tick-frequency)))
    (format t "1 million runs of MAT-EYE took ~a seconds"  
	    time-calc)))


========================================================================================================================================
#SQRT
========================================================================================================================================

Calculates a square root of array elements.

Note: The LISP-CV SQRT methods overload the Common Lisp function SQRT so both can use the same name. 
The LISP-CV SQRT methods provide the the same functionality as the Common Lisp function SQRT and the 
OpenCV 'sqrt' function. To use the Common Lisp function SQRT directly, while you are in the LISP-CV 
package, you need to evaluate CL:SQRT.

C++: void sqrt(InputArray src, OutputArray dst)

LISP-CV: (SQRT (SRC MAT) (DEST MAT)) => :VOID

    Parameters:	

        SRC - Input floating-point array.

        DEST - Output array of the same size and type as SRC.


The functions SQRT calculate a square root of each input array element. In case of multi-channel 
arrays, each channel is processed independently. The accuracy is approximately the same as of the 
Common Lisp function SQRT.


See also:

(POW), (MAGNITUDE)


Example:

(defun sqrt-example ()

  "Computes the square root of 
   each element of matrix M."

  (with-object ((data (alloc :float '(53.0f0 62.0f0 85.0f0 64.0f0 23.0f0 
				      97.0f0 52.0f0 16.0f0 12.0f0))))
    (with-mat ((m (mat 3 3 +32f+ data))
	       (dest (mat 3 3 +32f+)))
      (format t "~%M:~%~%")
      (print-mat m)
      (format t "~%~%")
      (sqrt m dest)
      (format t "DEST:~%~%")
      (print-mat dest)
      (format t "~%"))))

========================================================================================================================================
#IMGPROC - #IMAGE FILTERING
========================================================================================================================================

========================================================================================================================================
BILATERAL-FILTER
========================================================================================================================================

Applies the bilateral filter to an image.

C++: void bilateralFilter(InputArray src, OutputArray dst, int d, double sigmaColor, double sigmaSpace, int borderType=BORDER_DEFAULT )

LISP-CV (BILATERAL-FILTER (SRC MAT) (DEST MAT) (D :INT) (SIGMA-COLOR :DOUBLE) (SIGMA-SPACE :DOUBLE) &OPTIONAL
        ((BORDER-TYPE :INT) +BORDER-DEFAULT+)) => :VOID


    Parameters:	

        SRC - Source 8-bit or floating-point, 1-channel or 3-channel image.

        DST - Destination image of the same size and type as SRC.

        D - Diameter of each pixel neighborhood that is used during filtering. If it is non-positive, 
            it is computed from sigma-Space.

        SIGMA-COLOR - Filter sigma in the color space. A larger value of the parameter means that 
                      farther colors within the pixel neighborhood (see SIGMA-SPACE) will be mixed 
                      together, resulting in larger areas of semi-equal color.

        SIGMA-SPACE - Filter sigma in the coordinate space. A larger value of the parameter means that 
                      farther pixels will influence each other as long as their colors are close enough 
                      (see SIGMA-COLOR). When (> d 0) , it specifies the neighborhood size regardless of 
                      SIGMA-SPACE . Otherwise, D is proportional to SIGMA-SPACE .


The function applies bilateral filtering to the input image, as described in:

http://www.dai.ed.ac.uk/CVonline/LOCAL_COPIES/MANDUCHI1/Bilateral_Filtering.html 

BILATERAL-FILTER can reduce unwanted noise very well while keeping edges fairly sharp. However, it is 
very slow compared to most filters.

Sigma values: For simplicity, you can set the 2 sigma values to be the same. If they are small (< 10), 
the filter will not have much effect, whereas if they are large (> 150), they will have a very strong 
effect, making the image look “cartoonish”.

Filter size: Large filters (> D 5) are very slow, so it is recommended to use (= D 5) for real-time 
applications, and perhaps (= D 9) for offline applications that need heavy noise filtering.

This filter does not work inplace.

Example:

See BLUR-EXAMPLE in this file.


========================================================================================================================================
BLUR
========================================================================================================================================

Blurs an image using the normalized box filter.


C++: void blur(InputArray src, OutputArray dst, Size ksize, Point anchor=Point(-1,-1), int borderType=BORDER_DEFAULT )

LISP-CV: (BLUR (SRC MAT) (DEST MAT) (KSIZE SIZE) &OPTIONAL ((ANCHOR POINT) (POINT -1 -1)) ((BORDER-TYPE :INT) +BORDER-DEFAULT+)) => :VOID


    Parameters:	

        SRC - Input image; it can have any number of channels, which are processed independently, but 
              the depth should be +8U+, +16U+, +16S+, +32F+ or +64F+.

        DST - Output image of the same size and type as SRC.

        KSIZE - Blurring kernel size.

        ANCHOR - Anchor point; default value (POINT -1,-1) means that the anchor is at the kernel center.

        BORDER-TYPE - Border mode used to extrapolate pixels outside of the image.


The function smoothes an image using the kernel:

See OpenCV documentation for the formula:

http://docs.opencv.org/trunk/modules/imgproc/doc/filtering.html?highlight=blur#blur


See also:

(BOX-FILTER), (BILATERAL-FILTER), (GAUSSIAN-BLUR), (MEDIAN-BLUR)


Example:


;;; Global Variables

(defparameter delay-caption 1500)
(defparameter delay-blur 100)
(defparameter max-kernel-length 31)

;;; Load the source image
(defparameter src (gc:imread "/d1" 1))

(defparameter dst (gc:mat))
(defparameter window-name "GAUSSIAN-BLUR Example")


(defun display-caption (caption &optional c)
  (setf dst (gc:mat-zeros (rows src) (cols src) (mat-type src)))
  (put-text dst caption (gc:point (round (/ (cols src) 4)) 
			       (round (/ (rows src) 2))) 
	    +font-hershey-complex+
	    1d0 (gc:scalar 255 255 255))
  (imshow window-name dst)
  (setf c (wait-key delay-caption))
  (if (>= c 0) (return-from display-caption -1)
      (return-from display-caption 0)))


(defun display-dst (delay &optional c)
  (imshow window-name dst)
  (setf c (wait-key delay))
  (if (>= c 0) (return-from display-dst -1)
      (return-from display-dst 0)))


(defun blur-example ()

  (with-named-window (window-name +window-autosize+)
    (move-window window-name (cols src) 0)
    
    (if (not (eq 0 (display-caption "Original Image"))) 
	(return-from blur-example 0))

    (setf dst (gc:clone src))

    (if (not (eq 0 (display-dst delay-caption))) 
	(return-from blur-example 0))

        ;;; Applying Homogeneous blur
    (if (not (eq 0 (display-caption "Homogeneous Blur"))) 
	(return-from blur-example 0))

    (do ((i 1 (+ i 2)))
	((> i max-kernel-length))
      (blur src dst (gc:size i i))

      (if (not (eq 0 (display-dst delay-blur))) 
	  (return-from blur-example 0)))

        ;;; Applying Gaussian blur
    (if (not (eq 0 (display-caption "Gaussian Blur"))) 
	(return-from blur-example 0))

    (do ((i 1 (+ i 2)))
	((> i max-kernel-length))
      (gaussian-blur src dst (gc:size i i) 0d0 0d0)

      (if (not (eq 0 (display-dst delay-blur))) 
	  (return-from blur-example 0)))

        ;;; Applying Median blur
    (if (not (eq 0 (display-caption "Median Blur"))) 
	(return-from blur-example 0))

    (do ((i 1 (+ i 2)))
	((> i max-kernel-length))
      (median-blur src dst i)

      (if (not (eq 0 (display-dst delay-blur))) 
	  (return-from blur-example 0)))

        ;;; Applying Bilateral Filter
    (if (not (eq 0 (display-caption "Bilateral Blur"))) 
	(return-from blur-example 0))

    (do ((i 1 (+ i 2)))
	((> i max-kernel-length))
      (bilateral-filter src dst i (coerce (* i 2) 'double-float) 
			(coerce (round (/ i 2)) 'double-float))

      (if (not (eq 0 (display-dst delay-blur))) 
	  (return-from blur-example 0)))

       ;;; Wait until user press a key
    (display-caption "End: Press a key!")
    (loop
       (let ((c (wait-key 27)))
	 (when (>= c 0)
	   (return))))))

========================================================================================================================================
#COPY-MAKE-BORDER
========================================================================================================================================

Forms a border around an image.

C++: void copyMakeBorder(InputArray src, OutputArray dst, int top, int bottom, int left, int right, int borderType, 
     const Scalar& value=Scalar() )

LISP-CV: (COPY-MAKE-BORDER (SRC MAT) (DEST MAT) (TOP :INT) (BOTTOM :INT) (LEFT :INT) (RIGHT :INT) 
         (BORDER-TYPE :INT) &OPTIONAL ((VALUE SCALAR) (SCALAR-0))) => :VOID

    Parameters:	

        SRC - Source image.

        DEST - Destination image of the same type as SRC and the size:

                (+ (COLS SRC) LEFT RIGHT), (+ (ROWS SRC) TOP BOTTOM).

        TOP -

        BOTTOM -

        LEFT -

        RIGHT - 
   
                Parameters specifying how many pixels in each direction from the source image rectangle 
                to extrapolate. For example, (EQ TOP 1), (EQ BOTTOM 1), (EQ LEFT 1), (EQ RIGHT 1) means 
                that 1 pixel-wide border needs to be built.

        BORDER-TYPE - Border type, one of the +BORDER-*+ constants, except for +BORDER-TRANSPARENT+ 
                      and +BORDER-ISOLATED+. 

        VALUE - Border value if (EQ BORDER-TYPE +BORDER-CONSTANT+).


The function copies the source image into the middle of the destination image. The areas to the left, 
to the right, above and below the copied source image will be filled with extrapolated pixels. This 
is not what the OpenCV class FilterEngine or filtering functions based on it do (they extrapolate pi-
xels on-fly), but what other more complex functions, including your own, may do to simplify image bo-
undary handling.


Note:

When the source image is a part (ROI) of a bigger image, the function will try to use the pixels outside 
of the ROI to form a border. To disable this feature and always do extrapolation, as if src was not a ROI, 
use (LOGIOR BORDER-TYPE +BORDER-ISOLATED+).


See also:

(BORDER-INTERPOLATE)


Example:

(defun copy-make-border-example (&optional (cam 0) 
				   (width *default-width*)
				   (height *default-height*))
  "Forms a border around FRAME"

  (with-captured-camera (cap cam :width width :height height)
    (let* ((window-name "COPY-MAKE-BORDER Example")
	   (border 100)
           (border-width (+ (* 2  border) width))
           (border-height (+ (* 2  border) height)))
      (with-named-window (window-name +window-normal+)
	(move-window window-name 759 175)
	;;Create a matrix big enough to accommodate 
	;;a one hundred pixel border on all sides
	(with-mat ((rgb (mat border-height border-width +8uc3+))
		   (frame (mat)))
	  (loop
	     (read cap frame)
	     ;;Make a border around FRAME
	     (copy-make-border frame rgb border border border border  
			       +border-replicate+ (scalar-all 75))
	     (imshow window-name rgb)
	     (let ((c (wait-key 33)))
	       (when (= c 27)
		 (return)))))))))

========================================================================================================================================
#DILATE
========================================================================================================================================

Dilates an image by using a specific structuring element.

C++: void dilate(InputArray src, OutputArray dst, InputArray kernel, Point anchor=Point(-1,-1), int iterations=1, 
     int borderType=BORDER_CONSTANT, const Scalar& borderValue=morphologyDefaultBorderValue() )

LISP-CV: (DILATE (SRC MAT) (DEST MAT) (KERNEL MAT) &OPTIONAL ((ANCHOR POINT) (POINT -1 -1)) ((ITERATIONS :INT) 1) 
         ((BORDER-TYPE :INT) +BORDER-CONSTANT+) ((BORDER-VALUE SCALAR) (MORPHOLOGY-DEFAULT-BORDER-VALUE+))) => :VOID

    Parameters:	

        SRC - Input image; the number of channels can be arbitrary, but the depth should be one of 
              +8U+, +16U+, +16S+, +32F+ or +64F+.

        DEST - Output image of the same size and type as SRC.

        KERNEL - Structuring element used for erosion; if (EQ ELEMENT (MAT)) , a 3 x 3 rectangular 
                 structuring element is used. Kernel can be created using (GET-STRUCTURING-ELEMENT).

        ANCHOR - Position of the anchor within the element; default value (-1, -1) means that the 
                  anchor is at the element center.

        ITERATIONS - Number of times dilation is applied.

        BORDER-TYPE - Border type, one of the +BORDER-*+ constants, except 
                      for +BORDER-TRANSPARENT+ and +BORDER-ISOLATED+.

        BORDER-VALUE - Border value in case of a constant border. 


The function dilates the source image using the specified structuring element that determines the 
shape of a pixel neighborhood over which the maximum is taken:

See OpenCv documentation:

http://docs.opencv.org/trunk/modules/imgproc/doc/filtering.html?highlight=erode#dilate

for a description and formula.

The function supports the in-place mode. Dilation can be applied several (ITERATIONS) times. In case 
of multi-channel images, each channel is processed independently.


See also:

(ERODE), (MORPHOLOGY-EX), (CREATE-MORPHOLOGY-FILTER), (GET-STRUCTURING-ELEMENT)


========================================================================================================================================
Example:
========================================================================================================================================


;; Global variables

(defparameter window-name "DILATION-DEST - DILATE Example")
;; Load an image
(defparameter src (imread "/my-pic.jpg" 1))
(defparameter dilation-dest (mat))
(defparameter dilation-elem (alloc :int 0))
(defparameter dilation-size (alloc :int 0))
(defparameter max-elem 2)
(defparameter max-kernel-size 21)


;; DILATION is a callback function called by the TRACKBAR in ERODE-EXAMPLE

(defcallback dilation :void ((dilation-type :int))
  ;; Adjust the GET-STRUCTURING-ELEMENT SHAPE 
  ;; parameter based on trackbar position
  (if (eq 0 (@ dilation-elem :int)) (setf dilation-type +morph-rect+) 
      (if (eq 1 (@ dilation-elem :int)) (setf dilation-type +morph-cross+)
	  (if (eq 2 (@ dilation-elem :int)) (setf dilation-type +morph-ellipse+))))
  ;; Specify the shape of the kernel used 
  ;; to perform the dilation operation
  (with-mat ((element (%get-structuring-element 
		       dilation-type 
		       (gc:size (+ (* (@ dilation-size :int) 2) 1)
			     (+ (* (@ dilation-size :int) 2) 1)) 
		       (gc:point (@ dilation-size :int) (@ dilation-size :int)))))
    ;; Apply the dilation operation
    (dilate src dilation-dest element)
    (imshow window-name dilation-dest)))


(defun dilate-example ()

  (if (empty src) 
      (return-from dilate-example
	(format t "Image not loaded")))
  ;; Create window
  (with-named-window (window-name 1)
    (move-window window-name (cols src) 0)
    ;; Create trackbar that, adjusts the GET-STRUCTURING-ELEMENT 
    ;; SHAPE parameter and calls the DILATION callback function, 
    ;; every time it is moved
    (create-trackbar "SHAPE" window-name dilation-elem max-elem (callback dilation))
    ;; Create trackbar that, adjusts the GET-STRUCTURING-ELEMENT 
    ;; KSIZE and KERNEL parameters and calls the DILATION callback 
    ;; function, every time it is moved
    (create-trackbar  "KERNEL/KSIZE" window-name dilation-size max-kernel-size 
		      (callback dilation))
    (imshow window-name src)
    (loop
       (let ((c (wait-key 33)))
	 (when (= c 27)
 	   (del-mat src)
	   (del-mat dilation-dest)
	   (del dilation-elem)
	   (del dilation-size)
	   (return))))))


========================================================================================================================================
ERODE
========================================================================================================================================

Erodes an image by using a specific structuring element.

C++: void erode(InputArray src, OutputArray dst, InputArray kernel, Point anchor=Point(-1,-1), int iterations=1, 
     int borderType=BORDER_CONSTANT, const Scalar& borderValue=morphologyDefaultBorderValue() )

LISP-CV: (ERODE (SRC MAT) (DEST MAT) (KERNEL MAT) ((ANCHOR POINT) (POINT -1 -1)) 
         ((ITERATIONS :INT) 1) ((BORDER-TYPE :INT) +BORDER-CONSTANT+) 
         ((BORDER-VALUE SCALAR) (MORPHOLOGY-DEFAULT-BORDER-VALUE+))) => :VOID

    Parameters:	

        SRC - Input image; the number of channels can be arbitrary, but the depth should be one of 
              +8U+, +16U+, +16S+, +32F+ or +64F+.

        DEST - Output image of the same size and type as SRC.

        KERNEL - Structuring element used for erosion; if (EQ ELEMENT (MAT)) , a 3 x 3 rectangular 
                 structuring element is used. Kernel can be created using (GET-STRUCTURING-ELEMENT).

        ANCHOR - Position of the anchor within the element; default value (-1, -1) means that the 
                  anchor is at the element center.

        ITERATIONS - Number of times erosion is applied.

        BORDER-TYPE - Border type, one of the +BORDER-*+ constants, except 
                      for +BORDER-TRANSPARENT+ and +BORDER-ISOLATED+.

        BORDER-VALUE - Border value in case of a constant border. 


The function erodes the source image using the specified structuring element that determines the shape 
of a pixel neighborhood over which the minimum is taken:

See OpenCv documentation:

http://docs.opencv.org/trunk/modules/imgproc/doc/filtering.html?highlight=erode#erode

for a description and formula.

The function supports the in-place mode. Erosion can be applied several (ITERATIONS) times. In case 
of multi-channel images, each channel is processed independently.


See also:

(DILATE), (MORPHOLOGY-EX), (CREATE-MORPHOLOGY-FILTER), (GET-STRUCTURING-ELEMENT)


Example:


;; Global variables
(defparameter window-name "EROSION-DEST - ERODE Example")
;; Load an image
(defparameter src (imread "/my-pic.jpg" 1))
(defparameter erosion-dest (mat))
(defparameter erosion-elem (alloc :int 0))
(defparameter erosion-size (alloc :int 0))
(defparameter max-elem 2)
(defparameter max-kernel-size 21)


;; EROSION is a callback function called by the TRACKBAR in ERODE-EXAMPLE

(defcallback erosion :void ((erosion-type :int))
  ;; Adjust the GET-STRUCTURING-ELEMENT SHAPE 
  ;; parameter based on trackbar position
  (if (eq 0 (@ erosion-elem :int)) (setf erosion-type +morph-rect+) 
      (if (eq 1 (@ erosion-elem :int)) (setf erosion-type +morph-cross+)
	  (if (eq 2 (@ erosion-elem :int)) (setf erosion-type +morph-ellipse+))))
  ;; Specify the shape of the kernel used 
  ;; to perform the erosion operation
  (with-mat ((element (get-structuring-element 
		       erosion-type 
		       (gc:size (+ (* (@ erosion-size :int) 2) 1)
			     (+ (* (@ erosion-size :int) 2) 1)) 
		       (gc:point (@ erosion-size :int) (@ erosion-size :int)))))
    ;; Apply the erosion operation
    (erode src erosion-dest element)
    (imshow window-name erosion-dest)))

(defun erode-example ()

  (if (empty src) 
      (return-from erode-example
	(format t "Image not loaded")))
  ;; Create window
  (with-named-window (window-name 1)
    (move-window window-name (cols src) 0)
    ;; Create trackbar that, adjusts the GET-STRUCTURING-ELEMENT 
    ;; SHAPE parameter and calls the EROSION callback function, 
    ;; every time it is moved
    (create-trackbar "SHAPE" window-name erosion-elem max-elem (callback erosion))
    ;; Create trackbar that, adjusts the GET-STRUCTURING-ELEMENT 
    ;; KSIZE and KERNEL parameters and calls the EROSION callback 
    ;; function, every time it is moved
    (create-trackbar  "KERNEL/KSIZE" window-name erosion-size max-kernel-size 
		      (callback erosion))
    (imshow window-name src)
    (loop
       (let ((c (wait-key 33)))
	 (when (= c 27)
	   (del-mat src)
	   (del-mat erosion-dest)
	   (del erosion-elem)
	   (del erosion-size)
	   (return))))))


========================================================================================================================================
#FILTER-2D
========================================================================================================================================

Convolves an image with the kernel.

C++: void filter2D(InputArray src, OutputArray dst, int ddepth, InputArray kernel, Point anchor=Point(-1,-1), double delta=0, 
     int borderType=BORDER_DEFAULT )

LISP-CV: (FILTER-2D (SRC MAT) (DEST MAT) (DDEPTH :INT) (KERNEL MAT) &OPTIONAL ((ANCHOR POINT) (POINT -1 -1)) ((DELTA :DOUBLE) 0D0) 
         ((BORDER-TYPE :INT) +BORDER-DEFAULT+)) => :VOID

    Parameters:	

        SRC - Input image.

        DEST - Output image of the same size and the same number of channels as SRC.

        DDEPTH - Desired depth of the destination image; if it is negative, it will be the same as
                (DEPTH SRC); 

The following combinations of (DEPTH SRC) and ddepth are supported:

                (EQ (DEPTH SRC) +8U+): (EQ DDEPTH (OR -1 +16S+ +32F+ +64F+))

                (EQ (DEPTH SRC) (OR +16U+ +16S+)) -> (EQ DDEPTH (OR -1 +32F+ +64F+))

                (EQ (DEPTH SRC) +32F+) -> (EQ DDEPTH (OR -1 +32F+ +64F+))

                (EQ (DEPTH SRC) +64F+) -> (EQ DDEPTH (OR -1 +64F+))

        when (EQ DDEPTH -1), the output image will have the same depth as the source.
     
        KERNEL - Convolution kernel (or rather a correlation kernel), a single-channel floating point 
                 matrix; if you want to apply different kernels to different channels, split the image 
                 into separate color planes using (SPLIT) and process them individually.

        ANCHOR - Anchor of the kernel that indicates the relative position of a filtered point within 
                 the kernel; the anchor should lie within the kernel; default value (-1,-1) means that 
                 the anchor is at the kernel center.

        DELTA - Optional value added to the filtered pixels before storing them in DEST.

        BORDER-TYPE - Border type, one of the +BORDER-*+ constants, except 
                      for +BORDER-TRANSPARENT+ and +BORDER-ISOLATED+.


The function applies an arbitrary linear filter to an image. In-place operation is supported. When 
the aperture is partially outside the image, the function interpolates outlier pixel values according 
to the specified border mode.

See OpenCV documentation:

http://docs.opencv.org/trunk/modules/imgproc/doc/filtering.html?highlight=filter2#filter2d

for further description and formulae.

See also:

(SEP-FILTER-2D), (CREATE-LINEAR-FILTER), (DFT), (MATCH-TEMPLATE)


(defun filter-2d-example (filename)

  (let ((window-name "FILTER-2D Example")
	(ind 0)
       ;Initialize filter parameters
	(delta 0d0)
	(ddepth  -1)
	(kernel-size 0))
    (with-point ((anchor (point -1 -1)))
     ;Load an image
      (with-mat ((img (imread filename +load-image-color+)))
	(with-named-window (window-name +window-autosize+)
	  (move-window window-name (cols img) 175)
	  (with-mat ((dest (mat)))
	   ;The loop filters the image with 5 different 
	   ;kernel sizes, each lasting 0.5 seconds
	    (loop 
	      ;Update kernel size for a normalized box filter
	       (setf kernel-size (+ (* (mod ind 5) 2) 3))
	       (with-mat ((temp (mat-ones kernel-size kernel-size +32f+)))
		 (with-scalar ((scalar (scalar (* kernel-size kernel-size))))
		   (convert-to (assign temp scalar) temp +32f+)
		   (with-mat ((kernel (mat-ones kernel-size kernel-size +32f+)))
		     (divide kernel temp kernel)
		    ;Apply filter
		     (filter-2d img dest ddepth kernel anchor delta +border-default+)
		     (imshow window-name dest)
		     (incf ind)
		     (let ((c (wait-key 500)))
		       (when (= c 27)
			 (return)))))))))))))


========================================================================================================================================
#GAUSSIAN-BLUR
========================================================================================================================================

Blurs an image using a Gaussian filter.

C++: void GaussianBlur(InputArray src, OutputArray dst, Size ksize, double sigmaX, double sigmaY=0,
     int borderType=BORDER_DEFAULT )                   

Commom Lisp: (GAUSSIAN-BLUR (SRC MAT) (DEST MAT) (KSIZE SIZE) (SIGMA-X :DOUBLE) &OPTIONAL ((SIGMA-Y :DOUBLE) 0) 
             ((BORDER-TYPE :INT) +BORDER-DEFAULT+))

    Parameters:	

        SRC - input image; the image can have any number of channels, which are processed independently, 
              but the depth should be +8U+, +16U+, +16S+, +32F+ or +64F+.

        DST - output image of the same size and type as SRC.

        KSIZE - Gaussian kernel size KSIZE width and KSIZE height can differ but they both must be 
                positive and odd. Or, they can be zero’s and then they are computed from sigma.

        SIGMAX - Gaussian kernel standard deviation in X direction.

        SIGMAY - Gaussian kern
el standard deviation in Y direction; if SIGMAY is zero, it is set to 
                 be equal to SIGMAX, if both sigmas are zeros, they are computed from KSIZE width and 
                 KSIZE height , respectively (see (GET-GAUSSIAN-KERNEL) for details); to fully control 
                 the result regardless of possible future modifications of all this semantics, it is 
                 recommended To specify all of KSIZE, SIGMA-X, AND SIGMA-Y.

        BORDER-TYPE - Pixel extrapolation method, one of the +BORDER-*+ constants, except for 
                      +BORDER-TRANSPARENT+ and +BORDER-ISOLATED+.


The function convolves the source image with the specified Gaussian kernel. In-place filtering is s-
upported.

See also:

(SEP-FILTER-2D), FILTER-2D), (BLUR), (BOX-FILTER), (BILATERAL-FILTER), (MEDIAN-BLUR)


Example:

See BLUR-EXAMPLE in this file.

========================================================================================================================================
#GET-STRUCTURING-ELEMENT
========================================================================================================================================

Returns a structuring element of the specified size and shape for morphological operations.


C++: Mat getStructuringElement(int shape, Size ksize, Point anchor=Point(-1,-1))

LISP-CV: (GET-STRUCTURING-ELEMENT (SHAPE :INT) (KSIZE SIZE) &OPTIONAL ((KERNEL POINT) (POINT -1 -1))) => MAT


    Parameters:	

        SHAPE - Element shape that could be one of the following:

            +MORPH-RECT+ - A rectangular structuring element:

            +MORPH-ELLIPSE+ - An elliptic structuring element, that is, a filled ellipse inscribed 
                              into the rectangle.

            +MORPH-CROSS+ - A cross-shaped structuring element:

        KSIZE - Size of the structuring element.

        ANCHOR - Anchor position within the element. The default value (-1 -1) means that the anchor 
                 is at the center. Note that only the shape of a cross-shaped element depends on the 
                 anchor position. In other cases the anchor just regulates how much the result of the 
                 morphological operation is shifted.


The function constructs and returns the structuring element that can be further passed to (CREATE-MORPHOLOGY-FILTER), 
(ERODE), (DILATE) or (MORPHOLOGY-EX) . But you can also construct an arbitrary binary mask yourself 
and use it as the structuring element.


;;; Global variables

(defparameter window-name "GET-STRUCTURING-ELEMENT Example")

;;; Load an image - The <lisp-cv-source-dir>/images/baboon.jpg works great with this example

(defparameter src (gc:imread "/home/w/quicklisp/dists/quicklisp/software/lisp-cv-master/images/baboon.jpg"))
(defparameter dest (gc:clone src))
(defparameter morph-elem (alloc :int 0))
(defparameter morph-size (alloc :int 0))
(defparameter morph-operator (alloc :int 0))


;;; Callback function MORPHOLOGY-OPERATIONS

(defcallback morphology-operations :void ((operation :int) (element mat))

  (setf operation (+ (@ morph-operator :int) 2))

  ;;; ELEMENT is the kernel to be used. We use the function 
  ;;; GET-STRUCTURING-ELEMENT to define our own structure.

  (setf element 
	(gc:get-structuring-element (@ morph-elem :int) 
				 (gc:size 
				  (+ (* (@ morph-size :int) 2) 1) 
				  (+ (* (@ morph-size :int) 2) 1)) 
				 (gc:point 
				  (@ morph-size :int) 
				  (@ morph-size :int))))

  ;;; Apply the specified morphology operation
  (morphology-ex src dest operation element)
  (imshow window-name dest))


(defun get-structuring-element-example ()

  (let ((window-name "GET-STRUCTURING-ELEMENT Example")
        (max-operator 4)
        (max-elem 2)
        (max-kernel-size 21))

    ;;; Create window
    (with-named-window (window-name +window-autosize+)
      (move-window window-name 759 175)

      ;;; Create Trackbar to select
      ;;; Morphology operation:

      ;;; 0: Opening 
      ;;; 1: Closing
      ;;; 2: Gradient 
      ;;; 3: Top Hat 
      ;;; 4: Black Hat

      (create-trackbar "Operator: " window-name morph-operator max-operator 
		       (callback morphology-operations))

       ;;; Create Trackbar to 
       ;;; select kernel type:

       ;;; 0: Rect 
       ;;; 1: Cross 
       ;;; 2: Ellipse

      (create-trackbar "Element: " window-name morph-elem max-elem 
		       (callback morphology-operations))

      ;;; Create Trackbar to choose kernel size

      (create-trackbar "Kernel size:"  window-name morph-size max-kernel-size 
		       (callback morphology-operations))
      (loop
         ;;; Default start
	 (imshow window-name dest)
	 (let ((c (wait-key 33)))
	   (when (= c 27)
	     (free morph-elem)
	     (free morph-size)
	     (free morph-operator)
	     (return)))))))


========================================================================================================================================
#LAPLACIAN
========================================================================================================================================

Calculates the Laplacian of an image.

C++: void Laplacian(InputArray src, OutputArray dst, int ddepth, int ksize=1, double scale=1, double delta=0, 
     int borderType=BORDER_DEFAULT )

LISP-CV: (LAPLACIAN (SRC MAT) (DEST MAT) (DDEPTH :INT) &OPTIONAL ((KSIZE :INT) -1) ((SCALE :DOUBLE) 1D0) ((DELTA :DOUBLE) 0D0) 
         ((BORDER-TYPE :INT) +BORDER-DEFAULT+)) => :VOID

    Parameters:	

        SRC - Source image.

        DEST - Destination image of the same size and the same number of channels as SRC.

        DDEPTH - Desired depth of the destination image.

        KSIZE - Aperture size used to compute the second-derivative filters. See (GET-DERIV-KERNELS) 
                for details. The size must be positive and odd.

        SCALE - Optional scale factor for the computed Laplacian values. By default, no scaling is applied. 
                See (GET-DERIV-KERNELS) for details.

        DELTA - Optional delta value that is added to the results prior to storing them in DEST.

        BORDER-TYPE - Border type, one of the +BORDER-*+ constants, except 
                      for +BORDER-TRANSPARENT+ and +BORDER-ISOLATED+.


The function calculates the Laplacian of the source image by adding up the second x and y derivatives 
calculated using the Sobel operator:


See OpenCV documentation:

http://docs.opencv.org/trunk/modules/imgproc/doc/filtering.html?highlight=laplace#laplacian 

for further description and formulae.


See also:

(SOBEL), (SCHARR)


(defun laplacian-example (&optional 
			    (cam *camera-index*) 
			    (width *default-width*)
			    (height *default-height*))

  (with-captured-camera (cap cam :width width :height height)
    (let* ((window-name  "LAPLACIAN Example")) 
      (with-named-window (window-name +window-normal+)
	(set-window-property window-name +wnd-prop-fullscreen+ 
			     +window-fullscreen+)
	(set-window-property window-name +wnd-prop-aspectratio+ 
			     +window-freeratio+)
	(with-mat ((frame (mat))
		   (cvt (mat height width +8u+))
		   (src (mat height width +8u+))
		   (tmp (mat height width +8u+)))
	  (loop
	     (read cap frame)
	     (cvt-color frame cvt +bgr2gray+)
	     (imshow window-name (progn
				   (laplacian cvt tmp +64f+ 3)
				   (convert-scale-abs tmp src) src))
	     (let ((c (wait-key 33)))
	       (when (= c 27)
		 (return)))))))))

========================================================================================================================================
#MEDIAN-BLUR
========================================================================================================================================

Blurs an image using the median filter.


C++: void medianBlur(InputArray src, OutputArray dst, int ksize)

LISP-CV: (MEDIAN-BLUR (SRC MAT) (DEST MAT) (KSIZE :INT)) => :VOID


    Parameters:	

        SRC - Input 1, 3, or 4 channel image; when KSIZE is 3 or 5, the image depth should be +8U+, 
              +16U+, or +32F+, for larger aperture sizes, it can only be +8U+.

        DEST - Destination array of the same size and type as SRC.

        KSIZE - Aperture linear size; it must be odd and greater than 1, for example: 3, 5, 7 ...


The function smoothes an image using the median filter with the (* KSIZE KSIZE) aperture. Each channel 
of a multi-channel image is processed independently. In-place operation is supported.

See also:

(BILATERAL-FILTER), (BLUR), (BOX-FILTER), (GAUSSIAN-BLUR)


Example:

See BLUR-EXAMPLE in this file.


========================================================================================================================================
#MORPHOLOGY-EX
========================================================================================================================================

Performs advanced morphological transformations.

C++: void morphologyEx(InputArray src, OutputArray dst, int op, InputArray kernel, Point anchor=Point(-1,-1), int iterations=1, 
     int borderType=BORDER_CONSTANT, const Scalar& borderValue=morphologyDefaultBorderValue() )

LISP-CV: (MORPHOLOGY-EX (SRC MAT) (DEST MAT) (OP :INT) (KERNEL MAT) &OPTIONAL ((ANCHOR POINT) (POINT -1 -1)) ((ITERATIONS :INT) 1) 
        ((BORDER-TYPE :INT) +BORDER-CONSTANT+) ((BORDER-VALUE SCALAR) (MORPHOLOGY-DEFAULT-BORDER-VALUE))) => :VOID

    Parameters:	

        SRC - Source image. The number of channels can be arbitrary. The depth should be one of +8U+, 
              +16U+, +16S+, +32F+ or +64F+.

        DST - Destination image of the same size and type as SRC.

        KERNEL - Structuring element. It can be created using (GET-STRUCTURING-ELEMENT).

        ANCHOR - Anchor position with the kernel. Negative values mean that the anchor is at the kernel center.

        OP -

        Type of a morphological operation that can be one of the following:

            +MORPH-OPEN+ - An opening operation

            +MORPH-CLOSE+ - a closing operation

            +MORPH-GRADIENT+ - a morphological gradient

            +MORPH-TOPHAT+ - “top hat”

            +MORPH-BLACKHAT+ - “black hat”


        ITERATIONS - Number of times erosion and dilation are applied.

        BORDER-TYPE - Border type, one of the +BORDER-*+ constants, except 
                      for +BORDER-TRANSPARENT+ and +BORDER-ISOLATED+.

        BORDERVALUE - Border value in case of a constant border. The default value has a special 
                      meaning. See (CREATE-MORPHOLOGY-FILTER) for details.


The function can perform advanced morphological transformations using an erosion and dilation as basic operations.


See OpenCv documentation:

http://docs.opencv.org/trunk/modules/imgproc/doc/filtering.html?highlight=morphologyex#morphologyex

for a description and formulae.


Example:


(defun morphology-ex-example (filename)

   "This example basically converts text to a binary image. 
    The binary image can be used in further OCR operations. 
    A good image to use for this example is:

       <lisp-cv-source-dir>/images/webpage-1.png"

  (let ((window-name "MORPHOLOGY-EX Example"))
    (with-named-window (window-name +window-normal+)
      (set-window-property window-name +wnd-prop-fullscreen+ 
			   +window-fullscreen+) 
      (set-window-property window-name +wnd-prop-aspectratio+ 
			   +window-freeratio+)
      (with-mat ((image (imread filename 0)))
	(if (empty image) 
	    (return-from morphology-ex-example 
	      (format t "Image not loaded")))
	;Divide the image by its morphologically closed counterpart
	(with-size ((size (size 19 19)))
	  (with-mat ((kernel (get-structuring-element +morph-ellipse+ size)))
	    (with-mat ((closed (mat)))
	      (morphology-ex image closed +morph-close+ kernel)
	      ;Divide requires floating-point
	      (convert-to image image +32f+)
	      (divide image closed image 1d0 +32f+)
	      (normalize image image 0d0 255d0 +norm-minmax+)
	      ;Convert back to unsigned int
	      (convert-to image image +8u+)
	      ;Threshold each block (3x3 grid) of the image separately to
	      (dotimes (i 3)
		(dotimes (j 3)
		  (with-mat ((block (col-range 
				     (row-range image (* (round (/ (rows image) 3)) i) 
                                     (* (round (/ (rows image) 3)) (+ i 1))) 
				     (* (round (/ (cols image) 3)) j) 
				     (* (round (/ (cols image) 3)) (+ j 1)))))
		    (threshold block block -1d0 255d0(+ +thresh-binary-inv+ +thresh-otsu+)))
		  (imshow window-name image)
		  (loop
		     (let ((c (wait-key 33)))
		       (when (= c 27)
			 (return)))))))))))))


========================================================================================================================================
#PYR-DOWN
========================================================================================================================================

Blurs an image and downsamples it.

C++: void pyrDown(InputArray src, OutputArray dst, const Size& dstsize=Size(), int borderType=BORDER_DEFAULT )

LISP-CV: (PYR-DOWN (SRC MAT) (DEST MAT) &OPTIONAL ((DSTSIZE SIZE) (SIZE-0)) 
         ((BORDER-TYPE :INT) +BORDER-DEFAULT+)) => :VOID

    Parameters:	

        SRC - Input image.

        DEST - Output image; it has the specified size and the same type as SRC.

        DSTSIZE -

        size of the output image; by default, it is computed as:

               (SIZE (/ (+ (COLS SRC) 1) 2) (/ (+ (ROW SRC) 1) 2)), 


        BORDER-TYPE - Border type, one of the +BORDER-*+ constants, except 
                      for +BORDER-TRANSPARENT+ and +BORDER-ISOLATED+.
     

The function performs the downsampling step of the Gaussian pyramid construction. First, it convolves 
the source image with the kernel, then, it downsamples the image by rejecting even rows and columns.


(defun pyr-down-example (filename)

  (defun do-pyr-down (in)
    (let* ((in-size (size in)) 
           (in-height (round (height in-size)))
	   (in-width (round (width in-size)))
	   (out (gc:mat (/ in-height 2) (/ in-width 2) +8uc3+)))

      ;;Make sure input image is divisible by two."
      (assert (and (equal (mod in-height 2) 0)
		   (equal (mod in-width 2) 0))
	      (in-height in-width)
	      "~S or ~S are not divisible by two" in-width in-height)

      ;;Blur and downsample image
      (pyr-down in out)
      out))

  (defun main (filename)
    
    (let* ((img-2 0)
	   (window-name-1 "Original image - PYR-DOWN Example")
	   (window-name-2 "Downsampled blurred Image - PYR-DOWN Example"))
      (with-mat ((img-1 (imread filename 1)))
	(if (empty img-1) 
	    (return-from main
	      (format t "Image not loaded")))
	(with-named-window (window-name-1 +window-autosize+)
	  (with-named-window (window-name-2 +window-autosize+)
	    (move-window window-name-1 533 175)
	    (move-window window-name-2 984 175)
	    (format t "~%Image size before downsampling = (~a, ~a)
       ~%~%"(rows img-1) (cols img-1))
	    ;;Show original image in window
	    (imshow window-name-1 img-1)
	    (setf img-2 (do-pyr-down img-1))
	    (format t "Image size after downsampling = (~a, ~a)
       ~%~%"(rows img-2)(cols img-2))
	    ;;Show blurred downsampled image in window
	    (imshow window-name-2 img-2)
	    (loop
	       (let ((c (wait-key 33)))
		 (when (= c 27)
		   (return)))))))))

  (main filename))


========================================================================================================================================
#PYR-UP
========================================================================================================================================

Upsamples an image and then blurs it.

C++: void pyrUp(InputArray src, OutputArray dst, const Size& dstsize=Size(), int borderType=BORDER_DEFAULT )

LISP-CV: (PYR-UP (SRC MAT) (DEST MAT) &OPTIONAL ((DSTSIZE SIZE) (SIZE-0)) 
         ((BORDER-TYPE :INT) +BORDER-DEFAULT+)) => :VOID

    Parameters:	

        SRC - Input image.

        DEST - Output image. It has the specified size and the same type as SRC.

        DESTSIZE - Size of the output image; by default, it is computed as:

                   (SIZE (* (COLS SRC) 2) (* (ROWS SRC) 2)) 

        BORDER-TYPE - Border type, one of the +BORDER-*+ constants, except 
                      or +BORDER-TRANSPARENT+ and +BORDER-ISOLATED+.


The function performs the upsampling step of the Gaussian pyramid construction, though it can actually 
be used to construct the Laplacian pyramid. First, it upsamples the source image by injecting even 
zero rows and columns and then convolves the result with the same kernel as in (PYR-DOWN) multiplied by 4.



(defun pyr-up-example (filename)

  (defun do-pyr-up (in)
    (let* ((in-size (size in)) 
           (in-height (round (height in-size)))
	   (in-width (round (width in-size)))
	   (out (gc:mat (/ in-height 2) (/ in-width 2) +8uc3+)))

      ;;Make sure input image is divisible by two."
      (assert (and (equal (mod in-height 2) 0)
		   (equal (mod in-width 2) 0))
	      (in-height in-width)
	      "~S or ~S are not divisible by two" in-width in-height)

      ;;Blur and upsample image
      (pyr-up in out)
      out))

  (defun main (filename)
    
    (let* ((img-2 0)
	   (window-name-1 "Original image - PYR-UP Example")
	   (window-name-2 "Upsampled blurred Image - PYR-UP Example"))
      (with-mat ((img-1 (imread filename 1)))
	(if (empty img-1) 
	    (return-from main
	      (format t "Image not loaded")))
	(with-named-window (window-name-1 +window-autosize+)
	  (with-named-window (window-name-2 +window-autosize+)
	    (move-window window-name-1 533 175)
	    (move-window window-name-2 984 175)
	    (format t "~%Image size before upsampling = (~a, ~a)
       ~%~%"(rows img-1) (cols img-1))
	    ;;Show original image in window
	    (imshow window-name-1 img-1)
	    (setf img-2 (do-pyr-up img-1))
	    (format t "Image size after upsampling = (~a, ~a)
       ~%~%"(rows img-2)(cols img-2))
	    ;;Show blurred upsampled image in window
	    (imshow window-name-2 img-2)
	    (loop
	       (let ((c (wait-key 33)))
		 (when (= c 27)
		   (return)))))))))

  (main filename))


========================================================================================================================================
#SCHARR
========================================================================================================================================

Calculates the first x- or y- image derivative.

C++: void Scharr(InputArray src, OutputArray dst, int ddepth, int dx, int dy, double scale=1, double delta=0, 
     int borderType=BORDER_DEFAULT )

LISP-CV: (SCHARR (SRC MAT) (DEST MAT) (DDEPTH :INT) (DX :INT) (DY :INT) &OPTIONAL ((SCALE :DOUBLE) 1) ((DELTA :DOUBLE) 1D0) 
         ((BORDER-TYPE :INT) +BORDER-DEFAULT+)) => :VOID


    Parameters:	

        SRC - Input image.

        DST - Output image of the same size and the same number of channels as SRC.

        DDEPTH - Output image depth (see SOBEL for the list of supported combination of (DEPTH SRC) and DDEPTH).

        DX - Order of the derivative x.

        DX - Order of the derivative y.

        SCALE - Optional scale factor for the computed derivative values; by default, no scaling is 
                applied (see (GET-DERIV-KERNELS) for details).

        DELTA - Optional delta value that is added to the results prior to storing them in DEST.

        BORDER-TYPE - Pixel extrapolation method, one of the +BORDER-*+ constants, except for 
                      +BORDER-TRANSPARENT+ and +BORDER-ISOLATED+. 


The function SCHARR computes the first x- or y- spatial image derivative.


See OpenCV documentation: 

http://docs.opencv.org/trunk/modules/imgproc/doc/filtering.html?highlight=scharr#scharr

for description and formulae.


See also:

(CART-TO-POLAR)


Example:

(defun scharr-example (&optional (cam 0))

  "In this example, we compare the code for the SOBEL function with the 
   same code for the SCHARR function. The SOBEL version is shown in the 
   left window and the SCHARR version in the right. This example should 
   give an idea of how this function works."

  (with-captured-camera (cap cam :width 640 :height 480)
    (let* ((window-name-1 "SOBEL - SCHARR Example")
	   (window-name-2 "SCHARR - SCHARR Example")
	   ;;Declare variables 
           (scale 1d0)
	   (delta 0d0)
	   (ddepth +16s+))
      (with-named-window (window-name-1 +window-normal+)
	(with-named-window (window-name-2 +window-normal+)
	  (move-window window-name-1 533 175)
	  (move-window window-name-2 984 175)
	  ;;Declare objects
	  (with-size ((size (size 3 3)))
	    (with-mat ((frame (mat))
		       (src-gray (mat))
		       (grad (mat))
		       (grad-x (mat))
		       (grad-y (mat))
		       (abs-grad-x (mat))
		       (abs-grad-y (mat)))
	      (loop
		 ;;Load camera feed
		 (read cap frame)

		 ;;SOBEL version:
		 
		 ;;First, we apply a GAUSSIAN-BLUR to 
		 ;;our image to reduce the noise 
		 (gaussian-blur frame frame  size 0d0 0d0)
		 ;;Now we convert camera feed to grayscale
		 (cvt-color frame src-gray +bgr2gray+)

		 ;;Then, we calculate the “derivatives” 
		 ;;in x and y directions, using SOBEL

		 ;;Gradient x  
		 (sobel src-gray grad-x ddepth 1 0 3 scale delta +border-default+)
		 ;;Gradient y
		 (sobel src-gray grad-y ddepth 0 1 3 scale delta +border-default+)
		 ;;We convert our partial 
		 ;;results back to +8U+
		 (convert-scale-abs grad-x abs-grad-x)
		 (convert-scale-abs grad-y abs-grad-y)
		 ;;Add both directional gradients
		 (add-weighted abs-grad-x 0.5d0 abs-grad-y 0.5d0 0d0 grad)
		 ;;Then, show SOBEL version in a window
		 (imshow window-name-1 grad)

		 ;;SCHARR version:

		 ;;Apply a GAUSSIAN-BLUR
		 (gaussian-blur frame frame  size 0d0 0d0)
		 ;;Convert camera feed to grayscale
		 (cvt-color frame src-gray +bgr2gray+)
		 ;;Calculate the “derivatives" in the 
		 ;;x and y directions, using SCHARR
		 (scharr src-gray grad-x ddepth 1 0 scale delta +border-default+)
		 (scharr src-gray grad-y ddepth 0 1 scale delta +border-default+)
		 ;;Convert results back to +8U+      
		 (convert-scale-abs grad-x abs-grad-x)
		 (convert-scale-abs grad-y abs-grad-y)
		 ;;Add both directional gradients
		 (add-weighted abs-grad-x 0.5d0 abs-grad-y 0.5d0 0d0 grad)
		 ;;Show SCHARR version in a window
		 (imshow window-name-2 grad)
		 (let ((c (wait-key 33)))
		   (when (= c 27)
		     (return)))))))))))

========================================================================================================================================
#SOBEL
========================================================================================================================================

Calculates the first, second, third, or mixed image derivatives using an extended Sobel operator.

C++: void Sobel(InputArray src, OutputArray dst, int ddepth, int dx, int dy, int ksize=3, double scale=1, 
     double delta=0, int borderType=BORDER_DEFAULT)

LISP-CV: (SOBEL (SRC MAT) (DEST MAT) (DDEPTH :INT) (DX :INT) (DY :INT) &OPTIONAL ((KSIZE :INT) 3) 
         ((SCALE :DOUBLE) 1D0) ((DELTA :DOUBLE) 0D0) ((BORDER-TYPE :INT) +BORDER-DEFAULT+))  => :VOID


    Parameters:	

        SRC - Input image.

        DEST - Output image of the same size and the same number of channels as SRC.

        DDEPTH -

        Output image depth; the following combinations of (DEPTH SRC) and DDEPTH are supported:

                (EQ (DEPTH SRC) +8U+): (EQ DDEPTH (OR -1 +16S+ +32F+ +64F+))

                (EQ (DEPTH SRC) (OR +16U+ +16S+)) -> (EQ DDEPTH (OR -1 +32F+ +64F+))

                (EQ (DEPTH SRC) +32F+) -> (EQ DDEPTH (OR -1 +32F+ +64F+))

                (EQ (DEPTH SRC) +64F+) -> (EQ DDEPTH (OR -1 +64F+))

        when (EQ DDEPTH -1), the destination image will have the same depth as the source; in the 
        case of 8-bit input images it will result in truncated derivatives.

        DX - Order of the derivative x.

        DY - Order of the derivative y.

        KSIZE - Size of the extended Sobel kernel; it must be 1, 3, 5, or 7.

        SCALE - Optional scale factor for the computed derivative values; by default, no scaling is 
                applied (see (GET-DERIV-KERNELS) for details).

        DELTA - Optional delta value that is added to the results prior to storing them in DEST.

        BORDER-TYPE - Pixel extrapolation method, one of the +BORDER-*+ constants, except for 
                      +BORDER-TRANSPARENT+ and +BORDER-ISOLATED+. 


Description: See OpenCv documentation:


http://docs.opencv.org/modules/imgproc/doc/filtering.html?highlight=sobel#sobel


for a description and formulae.


See also:

(SCHARR), (LAPLACIAN), (SEP-FILTER2D), FILTER-2D), (GAUSSIAN-BLUR), (CART-TO-POLAR)


Example 1:

(defun sobel-example-1 (&optional (cam *camera-index*))

  (with-captured-camera (cap cam :width 640 :height 480)
    (let* ((window-name  "SOBEL Example 1")
           (ddepth +32f+)) 
      (with-named-window (window-name +window-normal+)
       	(set-window-property window-name +wnd-prop-fullscreen+ 
			     +window-fullscreen+)
	(set-window-property window-name +wnd-prop-aspectratio+ 
			     +window-freeratio+)
	(with-mat ((gray (mat))
		   (sobelx (mat))
                   (draw (mat))
		   (frame (mat)))
	  (with-object ((minval (alloc :double 0d0))
			(maxval (alloc :double 0d0)))
	    (loop
	       ;;Set camera to frame
	       (read cap frame)
	       ;;Show original camera 
	       ;;output in a window
	       (imshow window-name frame)
	       ;;Convert camera output, a 3 channel 
	       ;;matrix, to 1 channel matrix
	       (cvt-color frame gray +bgr2gray+)
	       ;;Compute Sobel x derivative and set 
	       ;;to destination matrix SOBELX
	       (sobel gray sobelx ddepth 0 1 -7)
	       ;;Find minimum and maximum intensities
	       (min-max-loc sobelx minval maxval)
	       ;;+32F+ image needs to be converted to +8U+ type
	       (convert-to sobelx draw +8u+ (/ 255d0 (- (@ maxval :double) 
							(@ minval :double))) 
			   (* (* (@ minval :double) -1.283)  
			      (/ 255.d0 (- (@ maxval :double) 
					   
					   (@ minval :double)))))
	       (imshow window-name draw)
	       (let ((c (wait-key 33)))
		 (when (= c 27)
		   (return))))))))))



Example 2:


(defun sobel-example-2 (&optional 
			  (cam *camera-index*) 
			  (width *default-width*)
			  (height *default-height*))

  (with-captured-camera (cap cam :width 640 :height 480)
    (let* ((window-name  "SOBEL Example")) 
      (with-named-window (window-name +window-normal+)
	(set-window-property window-name +wnd-prop-fullscreen+ 
			     +window-fullscreen+)
	(set-window-property window-name +wnd-prop-aspectratio+ 
			     +window-freeratio+)
	(with-mat ((frame (mat))
		   (cvt (mat height width +8u+))
		   (src (mat height width +8u+))
		   (tmp (mat height width +8u+)))
	  (loop
	     (read cap frame)
	     (cvt-color frame cvt +bgr2gray+)
	     (imshow window-name (progn
				   (sobel cvt tmp +32f+ 0 1 -1)
				   (convert-scale-abs tmp src) src))
	     (let ((c (wait-key 33)))
	       (when (= c 27)
		 (return)))))))))


========================================================================================================================================
#IMGPROC - #GEOMETRIC IMAGE TRANSFORMATIONS
========================================================================================================================================


========================================================================================================================================
#GET-AFFINE-TRANSFORM
========================================================================================================================================

Calculates an affine transform from three pairs of the corresponding points.

C++: Mat getAffineTransform(InputArray src, InputArray dst)

LISP-CV: (GET-AFFINE-TRANSFORM (SRC MAT) (DEST MAT)) => MAT


    Parameters:	

        SRC - Coordinates of triangle vertices in the source image.

        DST - Coordinates of the corresponding triangle vertices in the destination image.


The function calculates the 2x3 matrix of an affine transform so that:


See OpenCv documentation at this link:

http://docs.opencv.org/trunk/modules/imgproc/doc/geometric_transformations.html?highlight=warpaff#getaffinetransform

for the formulae.


See also:

(WARP-AFFINE), (TRANSFORM)


Example:

(defun get-affine-transform-example (filename)

  "This example is similar to the WARP-AFFINE-EXAMPLE, except that 
   trackbars are added so that you can adjust the values of all of 
   the points given to GET-AFFINE-TRANSFORM. This will help you to 
   better understand the math behind the operation of the function."

  ;;Load the image.
  (with-mat ((src (imread filename 1))         
             (src-tri (mat 3 2 +32f+))
             (dst-tri (mat 3 2 +32f+))
	     ;;Set the destination image to the same 
	     ;;type and size as the source image.
             (warp-dst (mat-zeros (rows src) (cols src) (mat-type src)))
             (warp-rotate-dst (mat)))
    (if (empty src) 
	(return-from get-affine-transform-example 
	  (format t "Image not loaded")))
    (let ((window-name "GET-AFFINE-TRANSFORM Example"))
      (with-named-window (window-name +window-normal+)
	(set-window-property window-name +wnd-prop-fullscreen+ 
			     +window-fullscreen+)
	;;Allocate memory to hold the values that the trackbar can 
	;;adjust that will later be given to GET-AFFINE-TRANSFORM.
	(with-object ((src-tri-1 (alloc :int 0))
		      (src-tri-2 (alloc :int 0))
		      (src-tri-3 (alloc :int (list (cols src))))
		      (src-tri-subt-3 (alloc :int 1))
		      (src-tri-4 (alloc :int 0))
		      (src-tri-5 (alloc :int 0))
		      (src-tri-6 (alloc :int (list (rows src))))
		      (src-tri-subt-6 (alloc :int 1))
		      (dst-tri-1 (alloc :int (list (cols src))))
                      (dst-tri-mult-1 (alloc :int 0))
		      (dst-tri-2 (alloc :int (list (rows src))))
		      (dst-tri-mult-2 (alloc :int 33))
		      (dst-tri-3 (alloc :int (list (cols src))))
		      (dst-tri-mult-3 (alloc :int 85))
		      (dst-tri-4 (alloc :int (list (rows src))))
		      (dst-tri-mult-4 (alloc :int 25))
		      (dst-tri-5 (alloc :int (list (cols src))))
		      (dst-tri-mult-5 (alloc :int 15))
		      (dst-tri-6 (alloc :int (list (rows src))))
		      (dst-tri-mult-6 (alloc :int 7)))

	  ;;Create the trackbars used to adjust the values of the 
	  ;;elements in the SRC-TRI matrix.

	  ;;When the values are set into the SRC-TRI matrix in the 
	  ;;WARP-AFFINE-EXAMPLE, two subtrahends are involved. The
	  ;;'ST SUBT 3' and 'ST SUBT 6' trackbars adjust those two
	  ;;subtrahends.

	  (create-trackbar "SRC-TRI 1" window-name src-tri-1 10000)
	  (create-trackbar "SRC-TRI 2" window-name src-tri-2 10000)
	  (create-trackbar "SRC-TRI 3" window-name src-tri-3 10000)
	  (create-trackbar "ST SUBT 3" window-name src-tri-subt-3 3000)
	  (create-trackbar "SRC-TRI 4" window-name src-tri-4 10000)
	  (create-trackbar "SRC-TRI 5" window-name src-tri-5 3000)
	  (create-trackbar "SRC-TRI 6" window-name src-tri-6 5000)
	  (create-trackbar "ST SUBT 6" window-name src-tri-subt-6 5000)

	  ;;Create the trackbars used to adjust the values of the 
	  ;;elements in the DST-TRI matrix.

	  ;;When the values are set into the DST-TRI matrix in the 
	  ;;WARP-AFFINE-EXAMPLE, six multiplicands are involved. t-
	  ;;he 'DT MULT *' trackbars adjust the six multiplicands.

	  (create-trackbar "DST-TRI 1" window-name dst-tri-1 20000)
	  (create-trackbar "DT MULT 1" window-name dst-tri-mult-1 4000)
	  (create-trackbar "DST-TRI 2" window-name dst-tri-2 23000)
	  (create-trackbar "DT MULT 2" window-name dst-tri-mult-2 4000)
	  (create-trackbar "DST-TRI 3" window-name dst-tri-3 120000)
	  (create-trackbar "DT MULT 3" window-name dst-tri-mult-3 15000)
	  (create-trackbar "DST-TRI 4" window-name dst-tri-4 200000)
	  (create-trackbar "DT MULT 4" window-name dst-tri-mult-4 100000)
	  (create-trackbar "DST-TRI 5" window-name dst-tri-5 200000)
	  (create-trackbar "DT MULT 5" window-name dst-tri-mult-5 142000)
	  (create-trackbar "DST-TRI 6" window-name dst-tri-6 200000)
	  (create-trackbar "DT MULT 6" window-name dst-tri-mult-6 7000)

	  (loop

	     ;;Based on the position of the trackbars, set three points 
	     ;;both in the src image and the dst image, that will next 
	     ;;be used to calculate the Affine Transform.

	     ;;Note: the '@' is a macro for CFFI::MEM-AREF. It is used 
	     ;;to get the values inside the memory locations that were 
	     ;;allocated by the ALLOC functions above.

	     (setf (@ :float src-tri 0 0) (coerce (@ src-tri-1 :int) 'single-float)) 
	     (setf (@ :float src-tri 0 1) (coerce (@ src-tri-2 :int) 'single-float)) 
	     (setf (@ :float src-tri 1 0) (- (@ src-tri-3 :int) 
					     (coerce (@ src-tri-subt-3 :int) 'single-float)))
	     (setf (@ :float src-tri 1 1) (coerce (@ src-tri-4 :int) 'single-float))
	     (setf (@ :float src-tri 2 0) (coerce (@ src-tri-5 :int) 'single-float)) 
	     (setf (@ :float src-tri 2 1) (- (@ src-tri-6 :int) 
					     (coerce (@ src-tri-subt-6 :int) 'single-float)))
	     (setf (@ :float dst-tri 0 0) (* (@ dst-tri-1 :int) 
					     (* (@ dst-tri-mult-1 :int) 0.01f0))) 
	     (setf (@ :float dst-tri 0 1) (* (@ dst-tri-2 :int) 
					     (* (@ dst-tri-mult-2 :int) 0.01f0)))
	     (setf (@ :float dst-tri 1 0) (* (@ dst-tri-3 :int) 
					     (* (@ dst-tri-mult-3 :int) 0.01f0)))
	     (setf (@ :float dst-tri 1 1) (* (@ dst-tri-4 :int) 
					     (* (@ dst-tri-mult-4 :int) 0.01f0)))
	     (setf (@ :float dst-tri 2 0) (* (@ dst-tri-5 :int) 
					     (* (@ dst-tri-mult-5 :int) 0.01f0)))
	     (setf (@ :float dst-tri 2 1) (* (@ dst-tri-6 :int) 
					     (* (@ dst-tri-mult-6 :int) 0.1f0)))

	     (with-size ((warp-dest-size (size warp-dst)))
	       ;;Get the Affine Transform.
	       (with-mat ((warp-mat (get-affine-transform src-tri dst-tri))) 
		 ;;Apply the Affine Transform, just found, to SRC.
		 (warp-affine src warp-dst warp-mat warp-dest-size)

		 #| Rotating the image after Warp |#

		 ;;Compute a rotation matrix with respect to the image center.
		 (with-point-2f ((center (point-2f (/ (cols src) 2f0) (/ (rows src) 2f0))))
		   (let ((angle -50d0)
			 (scale 0.6d0))
		     ;;Get the rotation matrix with the above specifications.
		     (with-mat ((rot-mat (get-rotation-matrix-2d center angle scale)))
		       ;;Rotate the warped image.
		       (warp-affine warp-dst warp-rotate-dst rot-mat warp-dest-size)
		       ;;Show the result.
		       (imshow window-name warp-rotate-dst)
		       (let ((c (wait-key 33)))
			 (when (= c 27)
			   (return))))))))))))))

========================================================================================================================================
#GET-ROTATION-MATRIX-2D
========================================================================================================================================

Calculates an affine matrix of 2D rotation.

C++: Mat getRotationMatrix2D(Point2f center, double angle, double scale)

LISP-CV: (GET-ROTATION-MATRIX-2D) (CENTER POINT-2F) (ANGLE :DOUBLE) (SCALE :DOUBLE)) => MAT


    Parameters:	

        CENTER - Center of the rotation in the source image.

        ANGLE - Rotation angle in degrees. Positive values mean counter-clockwise rotation (the 
                coordinate origin is assumed to be the top-left corner).

        SCALE - Isotropic scale factor.


The function calculates the following matrix:


See OpenCV documentation at this link:

http://docs.opencv.org/trunk/modules/imgproc/doc/geometric_transformations.html?highlight=warpaff#getrotationmatrix2d

for the formulae.


The transformation maps the rotation center to itself. If this is not the target, adjust the shift.


See also:

(GET-AFFINE-TRANSFORM), (WARP-AFFINE), (TRANSFORM)


Example:

(defun get-rotation-matrix-2d-example (filename)

  "This example is similar to the WARP-AFFINE-EXAMPLE except that 
   trackbars are added that you can use to adjust the CENTER, the 
   ANGLE and the SCALE values given to the GET-ROTATION-MATRIX-2D 
   function."

  ;;Load the image
  (with-mat ((src (imread filename 1))         
             (src-tri (mat 3 2 +32f+))
             (dst-tri (mat 3 2 +32f+))
	     ;;Create destination image of the same 
	     ;;type and size as the source image
             (warp-dst (mat-zeros (rows src) (cols src) (mat-type src)))
             (warp-rotate-dst (mat)))
    (if (empty src) 
	(return-from get-rotation-matrix-2d-example 
	  (format t "Image not loaded")))
    (let ((window-name "Trackbars adjust CENTER, ANGLE and SCALE of the image - GET-ROTATION-MATRIX-2D Example"))
      (with-named-window (window-name +window-autosize+)
	(move-window window-name (cols src) 175)
	;;Allocate memory to hold the integer values 
        ;;the trackbar can adjust
	(with-object ((center-x-val (alloc :int 2))
                      (center-y-val (alloc :int 2))
		      (angle-val (alloc :int 50))
		      (scale-val (alloc :int 6))) 
	  ;;Create the trackbars used to adjust the CENTER, ANGLE and 
          ;;SCALE parameters of the function GET-ROTATION-MATRIX-2D
	  (create-trackbar "CENTER X" window-name center-x-val 10)
	  (create-trackbar "CENTER Y" window-name center-y-val 10)
	  (create-trackbar "ANGLE" window-name angle-val 360)
	  (create-trackbar "SCALE" window-name scale-val 1000)
	  (loop
	     ;;Set three points both in the src and dst images 
             ;;that are used to calculate the Affine Transform
	     (setf (@ :float src-tri 0 0) 0f0) 
	     (setf (@ :float src-tri 0 1) 0f0) 
	     (setf (@ :float src-tri 1 0) (- (cols src) 1f0))
	     (setf (@ :float src-tri 1 1) 0f0)
	     (setf (@ :float src-tri 2 0) 0f0) 
	     (setf (@ :float src-tri 2 1) (- (rows src) 1f0))
	     (setf (@ :float dst-tri 0 0) (* (rows src) 0.0f0)) 
	     (setf (@ :float dst-tri 0 1) (* (rows src) 0.33f0))
	     (setf (@ :float dst-tri 1 0) (* (cols src) 0.85f0)) 
	     (setf (@ :float dst-tri 1 1) (* (rows src) 0.25f0))
	     (setf (@ :float dst-tri 2 0) (* (cols src) 0.15f0)) 
	     (setf (@ :float dst-tri 2 1) (* (rows src) 0.7f0))
	     (with-size ((warp-dest-size (size warp-dst)))
	       ;;Get the Affine Transform
	       (with-mat ((warp-mat (get-affine-transform src-tri dst-tri))) 
		 ;;Apply the Affine Transform, just found, to SRC
		 (warp-affine src warp-dst warp-mat warp-dest-size)

		 ;;Compute a rotation matrix with respect 
                 ;;to the center of the image

                 ;;Note: the '@' is a macro for CFFI::MEM-AREF

		 (with-point-2f ((center (point-2f (/ (cols src) 
						      (coerce 
						       (+ (@ center-x-val :int) 1) 
						       'single-float)) 
						   (/ (rows src) 
						      (coerce 
						       (+ (@ center-y-val :int) 1) 
						       'single-float)))))
		   (let ((angle (* (@ angle-val :int) -1.0d0))
			 (scale (*  (@ scale-val :int) 0.1d0)))
		     ;;Get the rotation matrix with the specifications above
		     (with-mat ((rot-mat (get-rotation-matrix-2d center angle scale)))
		       ;;Rotate the warped image
		       (warp-affine warp-dst warp-rotate-dst rot-mat warp-dest-size)
		       ;;Show what you got
		       (imshow window-name warp-rotate-dst)
		       (let ((c (wait-key 33)))
			 (when (= c 27)
			   (return))))))))))))))

========================================================================================================================================
#GET-PERSPECTIVE-TRANSFORM
========================================================================================================================================

Calculates a perspective transform from four pairs of the corresponding points.

C++: Mat getPerspectiveTransform(InputArray src, InputArray dst)

LISP-CV: (get-perspective-transform) (src mat) (dst mat)) => MAT


    Parameters:	

        SRC - Coordinates of quadrangle vertices in the source image.

        DST - Coordinates of the corresponding quadrangle vertices in the destination image.


The function calculates the 3x3 matrix of a perspective transform so that:


See OpenCV documentation at this link:

http://docs.opencv.org/trunk/modules/imgproc/doc/geometric_transformations.html#getperspectivetransform

for the formulae.


See also:

(FIND-HOMOGRAPHY), (WARP-PERSPECTIVE), (PERSPECTIVE-TRANSFORM)


Example:

(defun get-perspective-transform-example (&optional 
					    (cam *camera-index*) 
					    (width *default-width*)
					    (height *default-height*))

  "Trackbars are added here so that you can adjust the values of 
   the points given to GET-PERSPECTIVE-TRANSFORM. Taking note of 
   the values and how they affect the camera output will help in 
   understanding the math behind the operation of the function."

  ;;Create VIDEO-CAPTURE and set to default width and height,
  (with-captured-camera (cap cam :width width :height height)
    (if (not (is-opened cap)) 
	(return-from get-perspective-transform-example 
	  (format t "Cannot open the video camera")))
    ;;Input Quadilateral or Image plane coordinates.
    (with-mat ((input-quad (mat 4 2 +32f+))
	       ;;Output Quadilateral or World plane coordinates.
	       (output-quad (mat 4 2 +32f+))
	       ;;Create Lambda Matrix filled with zeros and set 
               ;;to the same type/size as the camera feed.
	       (lambda (mat-zeros height width +8u+)))
      ;;Create a fullscreen window
      (let ((window-name "GET-PERSPECTIVE-TRANSFORM Example"))
	(with-named-window (window-name +window-normal+)
	  (set-window-property window-name +wnd-prop-fullscreen+ 
			       +window-fullscreen+)
	  ;;Allocate memory to hold the values that the trackbar can 
	  ;;adjust that will be given to GET-PERSPECTIVE-TRANSFORM.
	  (with-object ((input-quad-0-x (alloc :int 95))
			(input-quad-0-y (alloc :int 72))
			(input-quad-1-x (alloc :int 407))
			(input-quad-1-y (alloc :int 31))
			(input-quad-2-x (alloc :int 513))
			(input-quad-2-y (alloc :int 331))
			(input-quad-3-x (alloc :int 172))
			(input-quad-3-y (alloc :int 440))
			(output-quad-0-x (alloc :int 0))
			(output-quad-0-y (alloc :int 0))
			(output-quad-1-x (alloc :int (list width)))
			(output-quad-1-x-subt (alloc :int 1))
			(output-quad-1-y (alloc :int 0))
			(output-quad-2-x (alloc :int (list width)))
			(output-quad-2-x-subt (alloc :int 1))
			(output-quad-2-y (alloc :int (list height)))
			(output-quad-2-y-subt (alloc :int 1))
			(output-quad-3-x (alloc :int 0))
			(output-quad-3-y (alloc :int (list height)))
			(output-quad-3-y-subt (alloc :int 1)))

	    ;;Create the trackbars used to adjust the values of the 
	    ;;elements in the INPUT-QUAD matrix. INPUT-QUAD is the 
            ;;src matrix parameter of GET-PERSPECTIVE-TRANSFORM.

	    (create-trackbar "IQ 0 X" window-name input-quad-0-x 383)
	    (create-trackbar "IQ 0 Y" window-name input-quad-0-y 463)
	    (create-trackbar "IQ 1 X" window-name input-quad-1-x 1449)
	    (create-trackbar "IQ 1 Y" window-name input-quad-1-y 266)
	    (create-trackbar "IQ 2 X" window-name input-quad-2-x 100000)
	    (create-trackbar "IQ 2 Y" window-name input-quad-2-y 2013)
	    (create-trackbar "IQ 3 X" window-name input-quad-3-x 551)
	    (create-trackbar "IQ 3 Y" window-name input-quad-3-y 14878)

	    ;;Create the trackbars used to adjust the values of the 
	    ;;elements in the OUTPUT-QUAD matrix. OUTPUT-QUAD is the 
            ;;dest matrix parameter of GET-PERSPECTIVE-TRANSFORM.

	    ;;When the values are set (with SETF below) into the OUTPUT-QUAD 
	    ;;matrix six subtrahends are involved. the 'SUBT * *' trackbars 
	    ;;adjust those six subtrahends.

	    (create-trackbar "OQ 0 X" window-name output-quad-0-x 638)
	    (create-trackbar "OQ 0 Y" window-name output-quad-0-y 480)
	    (create-trackbar "OQ 1 X" window-name output-quad-1-x 21099)
	    (create-trackbar "SUBT 1 X" window-name output-quad-1-x-subt 21099)
	    (create-trackbar "OQ 1 Y" window-name output-quad-1-y 477)
	    (create-trackbar "OQ 2 X" window-name output-quad-2-x 10000)
	    (create-trackbar "SUBT 2 X" window-name output-quad-2-x-subt 10000)
	    (create-trackbar "OQ 2 Y" window-name output-quad-2-y 100000)
	    (create-trackbar "SUBT 2 Y" window-name output-quad-2-y-subt 100000)
	    (create-trackbar "OQ 3 X" window-name output-quad-3-x 636)
	    (create-trackbar "OQ 3 Y" window-name output-quad-3-y 100000)
	    (create-trackbar "SUBT 3 Y" window-name output-quad-3-y-subt 478)

	    (loop
	       ;;Input and Output matrices.
	       (with-mat ((input (mat)) 
			  (output (mat)))
		 ;;Set camera feed to INPUT.
		 (read cap input)

		 ;;The 4 points that select quadilateral on the input, 
		 ;;from element 0x0 of INPUT-QUAD in clockwise order. 
                 ;;The four points are the sides of the rect box used 
                 ;;as input. 

		 ;;Note: the '@' is a macro for CFFI::MEM-AREF. It is 
		 ;;used to get the values inside the memory locations 
		 ;;that were allocated by the ALLOC functions above.

		 (setf (@ :float input-quad 0 0) (coerce (@ input-quad-0-x :int) 'single-float)) 
		 (setf (@ :float input-quad 0 1) (coerce (@ input-quad-0-y :int) 'single-float)) 
		 (setf (@ :float input-quad 1 0) (coerce (@ input-quad-1-x :int) 'single-float)) 
		 (setf (@ :float input-quad 1 1) (coerce (@ input-quad-1-y :int) 'single-float)) 
		 (setf (@ :float input-quad 2 0) (coerce (@ input-quad-2-x :int) 'single-float)) 
		 (setf (@ :float input-quad 2 1) (coerce (@ input-quad-2-y :int) 'single-float)) 
		 (setf (@ :float input-quad 3 0) (coerce (@ input-quad-3-x :int) 'single-float)) 
		 (setf (@ :float input-quad 3 1) (coerce (@ input-quad-3-y :int) 'single-float)) 

		 ;;The 4 points where mapping is to be done, from 
                 ;;element 0x0 of OUTPUT-QUAD in clockwise order.

		 (setf (@ :float output-quad 0 0) (coerce (@ output-quad-0-x :int) 'single-float)) 
		 (setf (@ :float output-quad 0 1) (coerce (@ output-quad-0-y :int) 'single-float)) 
		 (setf (@ :float output-quad 1 0) 
		       (- (@ output-quad-1-x :int) (coerce (@ output-quad-1-x-subt :int) 
							   'single-float))) 
		 (setf (@ :float output-quad 1 1) (coerce (@ output-quad-1-y :int) 'single-float)) 
		 (setf (@ :float output-quad 2 0) 
		       (- (@ output-quad-2-x :int) (coerce (@ output-quad-2-x-subt :int) 
							   'single-float))) 
		 (setf (@ :float output-quad 2 1) 
		       (- (@ output-quad-2-y :int) (coerce (@ output-quad-2-y-subt :int) 
							   'single-float))) 
		 (setf (@ :float output-quad 3 0) (coerce (@ output-quad-3-x :int) 'single-float)) 
		 (setf (@ :float output-quad 3 1) 
		       (- (@ output-quad-3-y :int) (coerce (@ output-quad-3-y-subt :int) 
							   'single-float))) 
		 ;;Get the Perspective Transform Matrix e.g. lambda
		 (with-mat ((lambda (get-perspective-transform input-quad output-quad)))
		   ;;Apply the Perspective Transform Matrix 
                   ;;just found to the camera feed.
                   (with-size ((output-size (size output)))
		     (warp-perspective input output lambda output-size))
		   ;;Display output
		   (imshow window-name output)
		   (let ((c (wait-key 33)))
		     (when (= c 27)
		       (return))))))))))))

========================================================================================================================================
#INVERT-AFFINE-TRANSFORM
========================================================================================================================================

Inverts an affine transformation.

C++: void invertAffineTransform(InputArray M, OutputArray iM)

LISP-CV: (INVERT-AFFINE-TRANSFORM (M MAT) (I-M MAT)) => :VOID


    Parameters:	

        M - Original affine transformation.

        I-M - Output reverse affine transformation.


The function computes an inverse affine transformation represented by 2x3 matrix M:


See OpenCv documentation at this link:

http://docs.opencv.org/trunk/modules/imgproc/doc/geometric_transformations.html?highlight=warpp#invertaffinetransform

for the formula.


The result is also a 2x3 matrix of the same type as M .

(defun invert-affine-transform-example (filename)

  ;;Load the image
  (with-mat ((src (imread filename 1))         
             (src-tri (mat 3 2 +32f+))
             (dst-tri (mat 3 2 +32f+))
	     ;;Set the dst matrices to the same 
	     ;;type and size as the src image
             (warp-dst (mat-zeros (rows src) (cols src) (mat-type src)))
             (inverted-warp-dst (mat-zeros (rows src) (cols src) (mat-type src))))
    (if (empty src) 
	(return-from invert-affine-transform-example 
	  (format t "Image not loaded")))
    (let ((source-window "Source - INVERT-AFFINE-TRANSFORM Example")
          (warp-window "Warp - INVERT-AFFINE-TRANSFORM Example")
	  (inverted-warp-window "Inverted - INVERT-AFFINE-TRANSFORM Example"))
      (with-named-window (source-window +window-normal+)
	(with-named-window (warp-window +window-normal+)
	  (with-named-window (inverted-warp-window +window-normal+)
	    (move-window source-window 310 175)
	    (move-window warp-window 760 175)
	    (move-window inverted-warp-window 1210 175)
	    ;;Show SRC in window 
            (imshow source-window src)
	    ;;Set three points here, both in the src and dst  
	    ;;images, used to calculate the Affine Transform
	    (setf (@ :float src-tri 0 0) 0f0) 
	    (setf (@ :float src-tri 0 1) 0f0) 
	    (setf (@ :float src-tri 1 0) (- (cols src) 1f0))
	    (setf (@ :float src-tri 1 1) 0f0)
	    (setf (@ :float src-tri 2 0) 0f0) 
	    (setf (@ :float src-tri 2 1) (- (rows src) 1f0))
	    (setf (@ :float dst-tri 0 0) (* (rows src) 0.0f0)) 
	    (setf (@ :float dst-tri 0 1) (* (rows src) 0.33f0))
	    (setf (@ :float dst-tri 1 0) (* (cols src) 0.85f0)) 
	    (setf (@ :float dst-tri 1 1) (* (rows src) 0.25f0))
	    (setf (@ :float dst-tri 2 0) (* (cols src) 0.15f0)) 
	    (setf (@ :float dst-tri 2 1) (* (rows src) 0.7f0))
	    (with-size ((warp-dest-size (size warp-dst)))
	      ;;Get the Affine Transform
	      (with-mat ((warp-mat (get-affine-transform src-tri dst-tri))) 
		;;Apply the Affine Transform, just found, to SRC
		(warp-affine src warp-dst warp-mat warp-dest-size)
		;;Show the transformed SRC in a window
		(imshow warp-window warp-dst)
		;;Invert the Affine Transform...
		(invert-affine-transform warp-mat warp-mat)
	        ;;...Apply to SRC
		(warp-affine src inverted-warp-dst warp-mat warp-dest-size)
		;;Show the Inverted Affine Transform in a window
		(imshow inverted-warp-window inverted-warp-dst)
		(loop
		   (let ((c (wait-key 33)))
		     (when (= c 27)
		       (return))))))))))))

========================================================================================================================================
#REMAP
========================================================================================================================================


Applies a generic geometrical transformation to an image.


C++: void remap(InputArray src, OutputArray dst, InputArray map1, InputArray map2, int interpolation, int borderMode=BORDER_CONSTANT, const Scalar& borderValue=Scalar())

LISP-CV: (REMAP (SRC MAT) (DEST MAT) (MAP1 MAT) (MAP2 MAT) (INTERPOLATION :INT) &OPTIONAL ((BORDER-MODE :INT) +BORDER-CONSTANT+) 
         ((BORDER-VALUE SCALAR) (SCALAR))) => :VOID

    Parameters:	

        SRC - Source image.

        DST - Destination image. It has the same size as MAP1 and the same type as SRC.

        MAP1 - The first map of either (x,y) points or just x values having the type +16SC2+, +32FC1+, 
               or +32FC2+ . See (CONVERT-MAPS) for details on converting a floating point representation 
               to fixed-point for speed.

        MAP2 - The second map of y values having the type +16UC1+ , +32FC1+ , or none (empty map if 
               MAP1 is (x,y) points), respectively.

        INTERPOLATION - Interpolation method (see (RESIZE)). The method +INTER-AREA+ is not supported by this function.

        BORDER-MODE - Pixel extrapolation method (see (BORDER-INTERPOLATE)). 

           When (EQ BORDER-MODE +BORDER-TRANSPARENT+) , it means that the pixels in the destination 
           image that corresponds to the “outliers” in the source image are not modified by the 
           function.

        BORDER-VALUE - Value used in case of a constant border. By default, it is 0.


The function remap transforms the source image using the specified map:

see OpenCV documentation:

http://docs.opencv.org/trunk/modules/imgproc/doc/geometric_transformations.html?highlight=remap#remap

for description and formula:

This function cannot operate in-place.


Example:

;;Global variables

(defparameter remap-window "REMAP Example")
(defparameter ind 0)

;;Load the image
(defparameter src (imread "/my-pic.jpg" 1))

;;Create DST, MAP-X and MAP-Y with the same size as SRC
(defparameter dst (gc:mat (rows src) (cols src) (mat-type src)))

(defparameter map-x (gc:mat (rows src) (cols src) +32f+))
(defparameter map-y (gc:mat (rows src) (cols src) +32f+))


;;Fill the MAP-X and MAP-Y matrices 
;;with 4 types of mappings
(defun update-map () 
  
  (setf ind (mod ind 4))

  (dotimes (j (rows src))
    (dotimes (i (cols src))

      (cond ((= 0 ind)

             (if (and (> i (* (cols src) 0.25)) 
                      (< i (* (cols src) 0.75)) 
		      (> j (* (rows src) 0.25)) 
                      (< j (* (rows src) 0.75)))
		 
                 (progn (setf (@ :float map-x j i) 
			      (+ (* 2 (- i (* (cols src) 0.25))) 0.5)) 
			(setf (@ :float map-y j i) 
			      (+ (* 2 (- j (* (rows src) 0.25))) 0.5))) 
		 
		 (progn (setf (@ :float map-x j i) 0f0)
			(setf (@ :float map-y j i) 0f0))))
	    
	    ((= 1 ind)

	     (progn (setf (@ :float map-x j i) 
			  (coerce i 'single-float))
		    (setf (@ :float map-y j i) 
			  (- (coerce (rows src) 'single-float)  j))))

	    ((= 2 ind)

	     (progn (setf (@ :float map-x j i) 
			  (- (coerce (cols src) 'single-float) i))
		    (setf (@ :float map-y j i) 
			  (coerce j 'single-float))))

	    ((= 3 ind) 

	     (progn (setf (@ :float map-x j i) 
			  (- (coerce (cols src) 'single-float) i))
		    (setf (@ :float map-y j i) 
			  (- (coerce (rows src) 'single-float) j)))))))
  (incf ind))


(defun remap-example ()

  (with-named-window (remap-window +window-autosize+)
    (move-window remap-window (cols src) 175)

    (loop
       ;;Update MAP-X and MAP-Y. Then apply REMAP
       (update-map)
       (remap src dst map-x map-y +inter-linear+ 
	      +border-constant+ (gc:scalar 0 0 0))
       ;;Display results
       (imshow remap-window dst)
       ;;Each 1 sec. Press ESC to exit the program
       (let ((c (wait-key 1000)))
	 (when (= c 27)
	   (return))))))


========================================================================================================================================
#RESIZE
========================================================================================================================================

Resizes an image.

C++: void resize(InputArray src, OutputArray dst, Size dsize, double fx=0, double fy=0, int interpolation=INTER_LINEAR )

LISP-CV: (RESIZE (SRC MAT) (DEST MAT) (DSIZE SIZE) &OPTIONAL ((FX :DOUBLE) 0D0) ((FY :DOUBLE) 0D0) 
        ((INTERPOLATION :INT) +INTER-LINEAR+)) => :VOID


    Parameters:	

        SRC - Input image.

        DEST - Output image; it has the size DSIZE (when it is non-zero) or the size computed from 
               (SIZE SRC), FX, and FY; the type of DEST is the same as of SRC.

        DSIZE - Output image size.

        FX - Scale factor along the horizontal axis.

        FY - Scale factor along the vertical axis.

        INTERPOLATION -

        interpolation method:

            +INTER-NEAREST+ - A nearest-neighbor interpolation

            +INTER-LINEAR+ - A bilinear interpolation (used by default)

            +INTER-AREA+ - Resampling using pixel area relation. It may be a preferred method for image 
                           decimation, as it gives moire’-free results. But when the image is zoomed, it 
                           is similar to the +INTER-NEAREST+ method.

            +INTER-CUBIC+ - a bicubic interpolation over 4x4 pixel neighborhood

            +INTER-LANCZOS4+ - a Lanczos interpolation over 8x8 pixel neighborhood


The function RESIZE resizes the image SRC down to or up to the specified size. Note that the initial 
DEST type or size are not taken into account. Instead, the size and type are derived from the SRC, 
DSIZE, FX , and FY . If you want to resize SRC so that it fits the pre-created DEST , you may call 
the function as follows:


;; Explicitly specify (EQ DSIZE (SIZE DEST)) FX and FY will be computed from that.


(RESIZE SRC DEST (SIZE DEST) 0d0 0d0 INTERPOLATION)


If you want to decimate the image by factor of 2 in each direction, you can call the function this way:


;; Specify FX and FY and let the function compute the destination image size.


(RESIZE SRC DEST (SIZE NIL) 0.5d0 0.5d0 INTERPOLATION)


To shrink an image, it will generally look best with +INTER-AREA+ interpolation, whereas to enlarge 
an image, it will generally look best with +INTER-CUBIC+ (slow) or +INTER-LINEAR+ (faster but still 
looks OK).


See also:

(WARP-AFFINE), (WARP-PERSPECTIVE), (REMAP)


Example:

(defun resize-example (&optional (cam *camera-index*) 
			 (width 640)
			 (height 480))

  "Uses RESIZE to enlarge the camera output and then shows
   both the resized FRAME(RESIZED) and the original FRAME 
   in windows."

  (with-captured-camera (cap cam :width width :height height)    
    (let* ((window-name-1 "Original FRAME - RESIZE Example")
	   (window-name-2 "RESIZED - RESIZE Example"))
      (with-named-window (window-name-1 +window-autosize+)
	(with-named-window (window-name-2 +window-autosize+)
	  (move-window window-name-1 0 0)
	  (move-window window-name-2 700 175)
	  (with-mat ((frame (mat))
		     (resized (mat (round (* height 2)) 
				   (round (* width 2)) 
				   +8uc3+)))
	    (loop
	       (read cap frame)
	       (resize frame resized (size 1280 960) 0.0d0 
		       0.0d0 +inter-lanczos4+)
	       (imshow window-name-1 frame)
	       (imshow window-name-2 resized)
	       (let ((c (wait-key 33)))
		 (when (= c 27)
		   (return))))))))))


========================================================================================================================================
#WARP-AFFINE
========================================================================================================================================


Applies an affine transformation to an image.


C++: void warpAffine(InputArray src, OutputArray dst, InputArray M, Size dsize, int flags=INTER_LINEAR, 
                     int borderMode=BORDER_CONSTANT, const Scalar& borderValue=Scalar())

LISP-CV:  (WARP-AFFINE (SRC MAT) (DEST MAT) (M MAT) (DSIZE SIZE) &OPTIONAL ((FLAGS :INT) +INTER-LINEAR+) 
                      ((BORDER-MODE :INT) +BORDER-CONSTANT+) ((BORDER-VALUE SCALAR) (SCALAR-0))) => :VOID


    Parameters:	

        SRC - Input image.

        DEST - Output image that has the size DSIZE and the same type as SRC.

        M - 2x3 transformation matrix.

        DSIZE - Size of the output image.

        FLAGS - Combination of interpolation methods (see (RESIZE) ) and the optional flag +WARP-INVERSE-MAP+ 
                that means that M is the inverse transformation ( DST ---> SRC ).

        BORDER-MODE - Pixel extrapolation method (see (BORDER-INTERPOLATE) ); when...
               
                        (EQ BORDER-MODE +BORDER-TRANSPARENT+), 

                      ...it means that the pixels in the destination image corresponding to the “outliers” in 
                      the source image are not modified by the function.

        BORDER-VALUE - Value used in case of a constant border; by default, it is 0.


The function WARP-AFFINE transforms the source image using the specified matrix:


See OpenCV documentation at this link for the formula.

http://docs.opencv.org/trunk/modules/imgproc/doc/geometric_transformations.html?highlight=warpaff#warpaffine


When the flag +WARP-INVERSE-MAP+ is set. Otherwise, the transformation is first inverted with (INVERT-AFFINE-TRANSFORM) 
and then put in the formula above instead of M . The function cannot operate in-place.


See also:

(WARP-PERSPECTIVE), (RESIZE), (REMAP), (GET-RECT-SUB-PIX), (TRANSFORM)


Example:

(defun warp-affine-example (filename)

  ;;Load the image
  (with-mat ((src (imread filename 1))         
             (src-tri (mat 3 2 +32f+))
             (dst-tri (mat 3 2 +32f+))
	     ;;Set the destination image to the same 
             ;;type and size as the source image
             (warp-dst (mat-zeros (rows src) (cols src) (mat-type src)))
             (warp-rotate-dst (mat)))
    (if (empty src) 
	(return-from warp-affine-example 
	  (format t "Image not loaded")))
    (let ((source-window "Source image - WARP-AFFINE Example")
          (warp-window "Warp - WARP-AFFINE Example")
	  (warp-rotate-window "Warp + Rotate - WARP-AFFINE Example"))
      (with-named-window (source-window +window-normal+)
	(with-named-window (warp-window +window-normal+)
	  (with-named-window (warp-rotate-window +window-normal+)
	    (move-window source-window 310 175)
	    (move-window warp-window 760 175)
	    (move-window warp-rotate-window 1210 175)
	    ;;Set 3 points both in the src image and the dst image 
            ;;that are used to calculate the Affine Transform
	    (setf (@ :float src-tri 0 0) 0f0) 
	    (setf (@ :float src-tri 0 1) 0f0) 
	    (setf (@ :float src-tri 1 0) (- (cols src) 1f0))
	    (setf (@ :float src-tri 1 1) 0f0)
	    (setf (@ :float src-tri 2 0) 0f0) 
	    (setf (@ :float src-tri 2 1) (- (rows src) 1f0))
	    (setf (@ :float dst-tri 0 0) (* (rows src) 0.0f0)) 
	    (setf (@ :float dst-tri 0 1) (* (rows src) 0.33f0))
	    (setf (@ :float dst-tri 1 0) (* (cols src) 0.85f0)) 
	    (setf (@ :float dst-tri 1 1) (* (rows src) 0.25f0))
	    (setf (@ :float dst-tri 2 0) (* (cols src) 0.15f0)) 
	    (setf (@ :float dst-tri 2 1) (* (rows src) 0.7f0))
	    (with-size ((warp-dest-size (size warp-dst)))
	      ;;Get the Affine Transform
	      (with-mat ((warp-mat (get-affine-transform src-tri dst-tri))) 
		;;Apply the Affine Transform, just found, to SRC
		(warp-affine src warp-dst warp-mat warp-dest-size)

	        #| Rotating the image after Warp |#

		;;Compute a rotation matrix with respect to the center of the image
		(with-point-2f ((center (point-2f (/ (cols src) 2f0) (/ (rows src) 2f0))))
		  (let ((angle -50d0)
			(scale 0.6d0))
		    ;;Get the rotation matrix with the specifications above
		    (with-mat ((rot-mat (get-rotation-matrix-2d center angle scale)))
		      ;;Rotate the warped image
		      (warp-affine warp-dst warp-rotate-dst rot-mat warp-dest-size)
		      ;;Show what you got
		      (imshow source-window src)
		      (imshow warp-window warp-dst)
		      (imshow warp-rotate-window warp-rotate-dst)
		      (loop
			 (let ((c (wait-key 33)))
			   (when (= c 27)
			     (return)))))))))))))))

========================================================================================================================================
#IMGPROC - #MISCELLANEOUS IMAGE TRANSFORMATIONS:
========================================================================================================================================


========================================================================================================================================
#ADAPTIVE-THRESHOLD
========================================================================================================================================

Applies an adaptive threshold to an array.


C++: void adaptiveThreshold(InputArray src, OutputArray dst, double maxValue, int adaptiveMethod, int thresholdType, 
     int blockSize, double C)

LISP-CV: (ADAPTIVE-THRESHOLD (SRC MAT) (DEST MAT) (MAX-VALUE :DOUBLE) (ADAPTIVE-METHOD :INT) (THRESHOLD-TYPE :INT) 
         (BLOCKSIZE :INT) (C :DOUBLE)) => :VOID


    Parameters:	

        SRC - Source 8-bit single-channel image.

        DEST - Destination image of the same size and the same type as SRC.

        MAX-VALUE - Non-zero value assigned to the pixels for which the condition is satisfied. 
                    See the details below.

        ADAPTIVE-METHOD - Adaptive thresholding algorithm to use, +ADAPTIVE-THRESH-MEAN-C+ or 
                          +ADAPTIVE-THRESH-GAUSSIAN-C+ . See the details below.

        THRESHOLD-TYPE - Thresholding type that must be either +THRESH-BINARY+ or +THRESH-BINARY-INV+.

        BLOCK-SIZE - Size of a pixel neighborhood that is used to calculate a threshold value for the 
                     pixel: 3, 5, 7, and so on.

        C - Constant subtracted from the mean or weighted mean (see the details below). Normally, it is 
            positive but may be zero or negative as well.


The function transforms a grayscale image to a binary image according to the formulae:

See OpenCV documentation for a description and formulae:

http://docs.opencv.org/trunk/modules/imgproc/doc/miscellaneous_transformations.html?highlight=adaptiveth#adaptivethreshold

The function can process the image in-place.


See also:

(THRESHOLD), (BLUR), (GAUSSIAN-BLUR)


;;Example in process



========================================================================================================================================
#CVT-COLOR
========================================================================================================================================

Converts an image from one color space to another.

C++: void cvtColor(InputArray src, OutputArray dst, int code, int dstCn=0 )

LISP-CV: (CVT-COLOR (SRC MAT) (DEST MAT) (CODE :INT) ((DEST-CN :INT) 0))


    Parameters:	

        SRC - input image: 8-bit unsigned, 16-bit unsigned ( +16UC...+ ), or single-precision float-
              ing-point.

        DST - output image of the same size and depth as src.

        CODE - color space conversion code (see the description below).

        DEST-CN - number of channels in the destination image; if the parameter is 0, the number of
                  the channels is derived automatically from src and code .


The function converts an input image from one color space to another. In case of a transformation t-
o-from RGB color space, the order of the channels should be specified explicitly (RGB or BGR). Note
that the default color format in OpenCV is often referred to as RGB but it is actually BGR (the byt-
es are reversed). So the first byte in a standard (24-bit) color image will be an 8-bit Blue compon-
ent, the second byte will be Green, and the third byte will be Red. The fourth, fifth, and sixth by-
tes would then be the second pixel (Blue, then Green, then Red), and so on.


The conventional ranges for R, G, and B channel values are:

    0 to 255 for +8U+ images

    0 to 65535 for +16U+ images

    0 to 1 for +32F+ images

In case of linear transformations, the range does not matter. But in case of a non-linear transform-
ation, an input RGB image should be normalized to the proper value range to get the correct results, 
for example, for RGB -> L*u*v* transformation. For example, if you have a 32-bit floating-point ima-
ge directly converted from an 8-bit image without any scaling, then it will have the 0..255 value r-
ange instead of 0..1 assumed by the function. So, before calling CVT-COLOR , you need first to scal-
e the image down:

(LET ((img (/ 1 255)))todo
  (CVT-COLOR IMG IMG +BGR2LUV))

If you use CVT-COLOR with 8-bit images, the conversion will have some information lost. For many ap-
plications, this will not be noticeable but it is recommended to use 32-bit images in applications 
that need the full range of colors or that convert an image before an operation and then convert back.

The function can do the following transformations:


        ***RGB <-> GRAY (+BGR2GRAY+, +RGB2GRAY+, +GRAY2BGR+, +GRAY2RGB+)*** 

Transformations within RGB space like adding/removing the alpha channel, reversing the channel orde-
r, conversion to/from 16-bit RGB color (R5:G6:B5 or R5:G5:B5), as well as conversion to/from graysc-
ale. The conversion from a RGB image to gray is done with:


(CVT-COLOR SRC BWSRC +RGB2GRAY+)

More advanced channel reordering can also be done with (MIX-CHANNELS).


For more info on the CVT-COLOR types below. See OpenCV's cvtColor Documentation at: 


http://docs.opencv.org/modules/imgproc/doc/miscellaneous_transformations.html?highlight=cvtcolor#cv.CvtColor


Thank you to Wikipedia for the information on Color Spaces provided below:


        ***RGB <-> CIE XYZ.REC 709 WITH D65 WHITE POINT (+BGR2XYZ+, +RGB2XYZ+, +XYZ2BGR+, +XYZ2RGB+)***


   Meaning of X, Y, and Z:

 A comparison between a typical normalised M cone's spectral sensitivity and the CIE 1931 luminosity
function for a standard observer in photopic vision

 When judging the relative luminance (brightness) of different colours in well-lit situations, human-
s tend to perceive light within the green parts of the spectrum as brighter than red or blue light 
of equal power. The luminosity function that describes the perceived brightnesses of different wave-
lengths is thus roughly analogous to the spectral sensitivity of M cones.

 The CIE model capitalises on this fact by defining Y as luminance. Z is quasi-equal to blue stimul-
ation, or the S cone response, and X is a mix (a linear combination) of cone response curves chosen 
to be nonnegative. The XYZ tristimulus values are thus analogous to, but not equal to, the LMS cone 
responses of the human eye. Defining Y as luminance has the useful result that for any given Y valu-
e, the XZ plane will contain all possible chromaticities at that luminance.


        ***RGB <-> YCRCB JPEG (OR YCC) (+BGR2YCRCB+, +RGB2YCRCB+, +YCRCB2BGR+, +YCRCB2RGB+)***


 YCbCr, Y′CbCr, or Y Pb/Cb Pr/Cr, also written as YCBCR or Y′CBCR, is a family of color spaces used 
as a part of the color image pipeline in video and digital photography systems. Y′ is the luma comp-
onent and CB and CR are the blue-difference and red-difference chroma components. Y′ (with prime) i-
s distinguished from Y, which is luminance, meaning that light intensity is nonlinearly encoded bas-
ed on gamma corrected RGB primaries.

 Y′CbCr is not an absolute color space; rather, it is a way of encoding RGB information. The actual 
color displayed depends on the actual RGB primaries used to display the signal. Therefore a value e-
xpressed as Y′CbCr is predictable only if standard RGB primary chromaticities are used.


        ***RGB <-> HSV (+BGR2HSV+, +RGB2HSV+, +HSV2BGR+, +HSV2RGB+)***

        ***RGB <-> HLS (+BGR2HLS+, +RGB2HLS+, +HLS2BGR+, +HLS2RGB+)***


 HSL and HSV are the two most common cylindrical-coordinate representations of points in an RGB colo-
r model. The two representations rearrange the geometry of RGB in an attempt to be more intuitive a-
nd perceptually relevant than the cartesian (cube) representation. Developed in the 1970s for compu-
ter graphics applications, HSL and HSV are used today in color pickers, in image editing software, 
and less commonly in image analysis and computer vision.


        ***RGB <-> CIE L*A*B* (+BGR2LAB+, +RGB2LAB+, +LAB2BGR+, +LAB2RGB+)***


 A Lab color space is a color-opponent space with dimension L for lightness and a and b for the colo-
r-opponent dimensions, based on nonlinearly compressed CIE XYZ color space coordinates.

 The dimensions of the Hunter 1948 L, a, b color space are L, a, and b.[1][2] However, Lab is now mo-
re often used as an informal abbreviation for the CIE 1976 (L*, a*, b*) color space (or CIELAB). Th-
e difference between Hunter and CIE color coordinates is that the CIE coordinates are based on a cu-
be root transformation of the color data, while the Hunter coordinates are based on a square root t-
ransformation.


        ***RGB <-> CIE L*U*V* (+BGR2LUV+, +RGB2LUV+, +LUV2BGR+, +LUV2RGB+)***


 In colorimetry, the CIE 1976 (L*, Readu*, v*) color space, commonly known by its abbreviation CIELUV, 
is a color space adopted by the International Commission on Illumination (CIE) in 1976, as a simple-
to-compute transformation of the 1931 CIE XYZ color space, but which attempted perceptual uniformit-
y. It is extensively used for applications such as computer graphics which deal with colored lights-
. Although additive mixtures of different colored lights will fall on a line in CIELUV's uniform ch-
romaticity diagram (dubbed the CIE 1976 UCS), such additive mixtures will not, contrary to popular 
belief, fall along a line in the CIELUV color space unless the mixtures are constant in lightness.


        ***BAYER <-> RGB (+BAYERBG2BGR+, +BAYERGB2BGR+, +BAYERRG2BGR+, +BAYERGR2BGR+
                         +BAYERBG2RGB+, +BAYERGB2RGB+, +BAYERRG2RGB+, +BAYERGR2RGB+)***


A Bayer filter mosaic is a color filter array (CFA) for arranging RGB color filters on a square gr-
id of photosensors. Its particular arrangement of color filters is used in most single-chip digital 
image sensors used in digital cameras, camcorders, and scanners to create a color image. The filter 
pattern is 50% green, 25% red and 25% blue, hence is also called RGBG,[1][2] GRGB,[3] or RGGB.[4]


Example:

(defun cvt-color-example (&optional (camera *camera-index*) 
			    (width 640)
			    (height 480))

  "In this example, the function CVT-COLOR converts 
   the camera output to 4 different color spaces an-
   d shows the results in four windows. See the CVT-
   COLOR documentation in:

   LISP-CV-MASTER/EXAMPLES/EXAMPLES.LISP 

   for more information on these color spaces."

  (with-captured-camera (cap camera :width width :height height)
    (let ((window-name-1 "+BGR2HSV+ - CVT-COLOR Example")
	  (window-name-2 "+BGR2XYZ+ - CVT-COLOR Example")
	  (window-name-3 "+BGR2GRAY+ - CVT-COLOR Example")
	  (window-name-4 "+BGR2HLS+ - CVT-COLOR Example"))
      (if (not (is-opened cap)) 
	  (return-from cvt-color-example 
	    (format t "Cannot open the video camera")))
      (format t "~%Frame Size : ~ax~a~%~%" 
	      (get* cap +cap-prop-frame-width+)
	      (get* cap +cap-prop-frame-height+))
      (with-named-window (window-name-1 +window-normal+)
	(with-named-window (window-name-2 +window-normal+)
	  (with-named-window (window-name-3 +window-normal+)
	    (with-named-window (window-name-4 +window-normal+)
	      (move-window window-name-1 485 98)
	      (move-window window-name-2 894 98)
	      (move-window window-name-3 485 444)
	      (move-window window-name-4 894 444)
	      (with-mat ((frame (mat)))
		(loop
		   (read cap frame)
		   (with-mat ((src1 (clone frame))
			      (src2 (clone frame))
			      (src3 (clone frame)))
		     (cvt-color frame frame +BGR2HSV+)
		     (cvt-color src1 src1 +BGR2XYZ+)
		     (cvt-color src2 src2 +BGR2GRAY+)
		     (cvt-color src3 src3 +BGR2HLS+)
		     (imshow window-name-1 frame)
		     (imshow window-name-2 src1)
		     (imshow window-name-3 src2)
		     (imshow window-name-4  src3)
		     (let ((c (wait-key 33)))
		       (when (= c 27)
			 (return)))))))))))))

========================================================================================================================================
#DISTANCE-TRANSFORM
========================================================================================================================================

Calculates the distance to the closest zero pixel for each pixel of the source image.

C++: void fscalardistanceTransform(InputArray src, OutputArray dst, int distanceType, int maskSize, int dstType=CV_32F )

LISP-CV: (DISTANCE-TRANSFORM (SRC MAT) (DEST MAT) (DISTANCE-TYPE :INT) (MASK-SIZE :INT)) => :VOID

C++: void distanceTransform(InputArray src, OutputArray dst, OutputArray labels, int distanceType, int maskSize, 
     int labelType=DIST_LABEL_CCOMP )

LISP-CV: (DISTANCE-TRANSFORM (SRC MAT) (DEST MAT) (*LABELS MAT) (DISTANCE-TYPE :INT) (MASK-SIZE :INT) &OPTIONAL 
         ((LABEL-TYPE :INT) +DIST-LABEL-CCOMP+))

    Parameters:	

        SRC - 8-bit, single-channel (binary) source image.

        DST - Output image with calculated distances. It is a 8-bit or 32-bit floating-point, 
              single-channel image of the same size as SRC.

        DISTANCE-TYPE - Type of distance. It can be +DIST-L1+, +DIST-L2+ , or +DIST-C+ .

        MASK-SIZE - Size of the distance transform mask. It can be 3, 5, or +DIST-MASK-PRECISE+ (the 
                    latter option is only supported by the first function). In case of the +DIST-L1+ 
                    or +DIST-C+ distance type, the parameter is forced to 3 because a 3 X 3 mask gives 
                    the same result as 5 X 5 or any larger aperture.

        DST-TYPE - Type of output image. It can be +8U+ or +32F+. Type +8U+ can be used only for the 
                   first variant of the function and (EQ DISTANCE-TYPE +DIST-L1+).

        LABELS - Optional output 2D array of labels (the discrete Voronoi diagram). It has the type 
                 +32SC1+ and the same size as SRC . See the details below.

        LABELTYPE - Type of the label array to build. If (EQ LABEL-TYPE +DIST-LABEL-CCOMP+) then each 
                    connected component of zeros in SRc (as well as all the non-zero pixels closest 
                    to the connected component) will be assigned the same label. If (EQ label-Type 
                    +DIST-LABEL-PIXEL+ then each zero pixel (and all the non-zero pixels closest to 
                    it) gets its own label.

The DISTANCE-TRANSFORM functions calculate the approximate or precise distance from every binary image 
pixel to the nearest zero pixel. For zero image pixels, the distance will obviously be zero.

When (EQ MASK-SIZE +DIST-MASK-PRECISE+) and (EQ DISTANCE-TYPE +DIST-L2+) , the function runs the algorithm 
described in [Felzenszwalb04]. This algorithm is parallelized with the TBB library.

In other cases, the algorithm [Borgefors86] is used. This means that for a pixel the function finds the 
shortest path to the nearest zero pixel consisting of basic shifts: horizontal, vertical, diagonal, or 
knight’s move (the latest is available for a 5 x 5 mask). The overall distance is calculated as a sum of 
these basic distances. Since the distance function should be symmetric, all of the horizontal and vertical 
shifts must have the same cost (denoted as a ), all the diagonal shifts must have the same cost (denoted as 
b ), and all knight’s moves must have the same cost (denoted as c ). For the +DIST-C+ and +DIST-L1+ types, 
the distance is calculated precisely, whereas for +DIST-L2+ (Euclidean distance) the distance can be calcu-
lated only with a relative error (a 5 x 5 mask gives more accurate results). For a,``b`` , and c , OpenCV 
uses the values suggested in the original paper:

+DIST-C+ 	(3 x 3) 	(EQ A 1), (EQ B 1)
+DIST-L1+ 	(3 x 3) 	(EQ A 1), (EQ B 1)
+DIST-L2+ 	(3 x 3) 	(EQ A 0.955), (EQ B 1.3693)
+DIST-L2+ 	(5 x 5) 	(EQ A 1), (EQ B 1.4), (EQ C 2.1969)

Typically, for a fast, coarse distance estimation +DIST-L2+, a 3 x 3 mask is used. For a more accurate 
distance estimation +DIST-L2+, a 5 x 5 mask or the precise algorithm is used. Note that both the precise 
and the approximate algorithms are linear on the number of pixels.

The second variant of the function does not only compute the minimum distance for each pixel (x, y) 
but also identifies the nearest connected component consisting of zero pixels (EQ LABEL-TYPE +DIST-
LABEL-CCOMP+) or the nearest zero pixel (EQ LABEL-TYPE +DIST-LABEL-PIXEL+). Index of the component/
pixel is stored (LABELS X Y) . When (EQ LABEL-TYPE +DIST-LABEL-CCOMP+), the function automatically 
finds connected components of zero pixels in the input image and marks them with distinct labels. 
When (EQ LABEL-TYPE +DIST-LABEL-CCOMP+), the function scans through the input image and marks all 
the zero pixels with distinct labels.

In this mode, the complexity is still linear, the function provides a very fast way to compute the 
Voronoi diagram for a binary image. The second variant can use only the approximate distance transform 
algorithm currently,  i.e. (EQ MASK-SIZE +DIST-MASK-PRECISE+) is not supported yet.


Example:

(defun distance-transform-example (&optional (cam 0) 
				     (width *default-width*)
				     (height *default-height*))

  "I came up with an amazing 3D visual effect that changes as you move 
   in front of the camera. I used the functions CANNY, THRESHOLD, DIST-
   ANCE-TRANSFORM and NORMALIZE to do this. I left the trackbar locati-
   ons at the position of my discovery. Try retracing my steps using t-
   he trackbars to get a better idea of how these functions are working 
   together to create this effect."

  (with-captured-camera (cap cam :width width :height height)
    (let ((window-name "DISTANCE-TRANSFORM Example"))
      (with-named-window (window-name +window-normal+)
	(set-window-property window-name +wnd-prop-fullscreen+ 
			     +window-fullscreen+)
	(set-window-property window-name +wnd-prop-aspectratio+ 
			     +window-freeratio+)
	(with-object ((canny-1 (alloc :int 471))
		      (canny-2 (alloc :int 128))
		      (threshold (alloc :int +thresh-binary-inv+))
		      (dist-trans (alloc :int +dist-c+)))
	  (create-trackbar "canny-1" window-name canny-1 500)
	  (create-trackbar "canny-2" window-name canny-2 500)
	  (create-trackbar "threshold" window-name threshold 4)
	  (create-trackbar "dist-trans" window-name dist-trans 3)
	  (with-mat ((src (mat height width +8u+))
		     (dst (mat height width +8u+))
		     (final (mat height width +32f+)))
	    (with-mat ((frame (mat)))
	      (loop
		 (read cap frame)
		 (cvt-color frame src +bgr2gray+)
		 (canny src dst (coerce (@ canny-1 :int) 'double-float) 
			(coerce (@ canny-2 :int) 'double-float))
		 (threshold dst dst 1d0 255d0 (@ threshold :int))
		 (if (< (get-trackbar-pos "dist-trans" window-name) 1) 
		     (set-trackbar-pos "dist-trans" window-name 1) nil)
		 (distance-transform dst final (@ dist-trans :int) 3)
		 (normalize final final 0.0d0 1.0d0 +norm-minmax+)
		 (imshow window-name final)
		 (let ((c (wait-key 33)))
		   (when (= c 27)
		     (return)))))))))))


========================================================================================================================================
#FLOOD-FILL
========================================================================================================================================

Fills a connected component with the given color.

C++: int floodFill(InputOutputArray image, InputOutputArray mask, Point seedPoint, Scalar newVal, Rect* rect=0, 
                   Scalar loDiff=Scalar(), Scalar upDiff=Scalar(), int flags=4 )

LISP-CV: (FLOOD-FILL (IMAGE MAT) (MASK MAT) (SEED-POINT POINT) (NEW-VAL SCALAR) ((RECT RECT) (NULL-POINTER)) 
                    ((LODIFF SCALAR) (SCALAR-0)) ((UPDIFF SCALAR) (SCALAR-0)) ((FLAGS :INT) 4)) => :INT

    Parameters:	

        IMAGE - Input/output 1 or 3-channel, 8-bit, or floating-point image. It is modified by the
                function unless the +FLOODFILL-MASK-ONLY+ flag is set.

        MASK - Operation mask that should be a single-channel 8-bit image, 2 pixels wider and 2 pixels 
               taller than the IMAGE parameter. Since this is both an input and output parameter, you must 
               take responsibility of initializing it. Flood-filling cannot go across non-zero pixels in the 
               input mask. For example, an edge detector output can be used as a mask to stop filling at edges. 
               On output, pixels in the mask corresponding to filled pixels in the image are set to 1 or to the 
               value specified in FLAGS as described below. It is, for that reason, possible to use the same mask 
               in multiple calls to the function to make sure the filled areas do not overlap.

        Note: Since the mask is larger than the filled image, a pixel (x, y) in image corresponds to 
              the pixel ((+ x 1), (+ y 1)) in the mask.

        SEED-POINT - Starting point.

        NEW-VAL - New value of the repainted domain pixels.

        LO-DIFF - Maximal lower brightness/color difference between the currently observed pixel and 
                  one of its neighbors belonging to the component, or a seed pixel being added to the
                  component.

        UP-DIFF - Maximal upper brightness/color difference between the currently observed pixel and 
                  one of its neighbors belonging to the component, or a seed pixel being added to the 
                  component.

        RECT - Optional output parameter set by the function to the minimum bounding rectangle of the 
               repainted domain.

        FLAGS - Operation flags. The first 8 bits contain a connectivity value. The default value of 4 
                means that only the four nearest neighbor pixels (those that share an edge) are considered. 
                A connectivity value of 8 means that the eight nearest neighbor pixels (pixels that share a 
                corner) will be considered. The next 8 bits (8-16) contain a value between 1 and 255 with which 
                to fill the mask (the default value is 1). For example, (LOGIOR 4 (ASH 255 8)) will consider 4 
                nearest neighbours and fill the mask with a value of 255. The following additional options occupy 
                higher bits and therefore may be further combined with the connectivity and mask fill values using 
                bit-wise or (LOGIOR):

            +FLOODFILL-FIXED-RANGE+ If set, the difference between the current pixel and seed pixel 
                                    is considered. Otherwise, the difference between neighbor pixels 
                                    is considered (that is, the range is floating).

            +FLOODFILL-MASK-ONLY+ If set, the function does not change the image (NEW-VAL is ignored), 
                                  and only fills the mask with the value specified in bits 8-16 of FLAGS 
                                  as described above. 

The function FLOOD-FILL fills a connected component starting from the seed point with the specified 
color. The connectivity is determined by the color/brightness closeness of the neighbor pixels. The 
pixel at (x,y) is considered to belong to the repainted domain if...

See OpenCV documentation at this link: 
http://docs.opencv.org/trunk/modules/imgproc/doc/miscellaneous_transformations.html?highlight=floodfill#floodfill
For further description of this function and related formulae.


Example:

(defun flood-fill-example ()

  (let ((window-name-1 "INPUT IMAGE - FLOOD-FILL Example")
        (window-name-2 "MASK - FLOOD-FILL Example"))
    (with-named-window (window-name-1 +window-normal+)
      (with-named-window (window-name-2 +window-normal+)
	(move-window window-name-1 533 175)
	(move-window window-name-2 984 175)

	;;Create a simple input image:

	;;Note: the t: prefix signifies that 
	;;automatic finalization is enabled.

	(with-point ((seed-point (point 4 4)))
	  (with-mat ((img (mat-zeros 100 100 +8uc1+)))
	    (circle img seed-point 20 (t:scalar 128) 3)

	    ;;Show input image.

	    (imshow window-name-1 img)

	    ;;Create a mask from edges 
	    ;;in the original image.

	    (with-mat ((mask (mat)))
	      (canny img mask 100d0 200d0)
	      (copy-make-border mask mask 1 1 1 1 +border-replicate+)

	      ;;Fill mask with value 128.

	      ;;All zero-valued pixels in the same connected component 
	      ;;as the seed point of the mask are replaced by the value 
	      ;;you specify, in this case FILL-VALUE. This value must be 
	      ;;added to FLAGS parameter and left-shifted by 8 bits, like
	      ;;below, with the Common Lisp function ASH. The FLAG value 4 
	      ;;specifies the pixel neighborhood with which to compare the 
	      ;;color value difference.

	      (let ((fill-value 128))
		(flood-fill img mask seed-point (t:scalar 255) (null-pointer) (t:scalar) (t:scalar) 
			    (logior 4 (logior +floodfill-mask-only+ (ash fill-value 8)))))

	      ;;Show mask: The white pixels in the mask are the result of 
	      ;;edge detection, while the grey pixels are the result of the 
	      ;;flood-fill.

	      (imshow window-name-2 mask)
	      (loop
		 (let ((c (wait-key 33)))
		   (when (= c 27)
		     (return)))))))))))

========================================================================================================================================
#THRESHOLD
========================================================================================================================================

Applies a fixed-level threshold to each array element.

C++: double threshold(InputArray src, OutputArray dst, double thresh, double maxval, int type)

LISP-CV: (THRESHOLD (SRC MAT) (DEST MAT) (THRESH :DOUBLE) (MAX-VAL :DOUBLE) (TYPE :INT)) => :DOUBLE


    Parameters:	

        SRC - Input array (single-channel, 8-bit or 32-bit floating point).

        DEST - Output array of the same size and type as SRC.

        THRESH - Threshold value.

        MAX-VAL - Maximum value to use with the +THRESH-BINARY+ and +THRESH-BINARY-INV+ thresholding types.

        TYPE - Thresholding type (see the details below).


The function applies fixed-level thresholding to a single-channel array. The function is typically 
used to get a bi-level (binary) image out of a grayscale image ( (COMPARE) could be also used for 
this purpose) or for removing a noise, that is, filtering out pixels with too small or too large 
values. There are several types of thresholding supported by the function. 

They are determined by type:

                        +THRESH-BINARY+

                        +THRESH-BINARY-INV+

                        +THRESH-TRUNC+

                        +THRESH-TOZERO+

                        +THRESH-TOZERO-INV+


Also, the special value +THRESH-OTSU+ may be combined with one of the above values. In this case, 
the function determines the optimal threshold value using the Otsu’s algorithm and uses it instead 
of the specified thresh . The function returns the computed threshold value. Currently, the Otsu’s 
method is implemented only for 8-bit images. 


See also:

(ADAPTIVE-THRESHOLD), (FIND-CONTOURS), (COMPARE), (MIN), (MAX)


Example:

(defun threshold-example (&optional (cam 0) (width 640) (height 480))

  "Show the camera output and a thresholded version in a single window."

  (with-captured-camera (cap cam :width width :height height)
    (let* ((window-name "Camera/Threshold"))
      (with-named-window (window-name +window-autosize+)
	(move-window window-name 333 175)
	(with-mat ((frame (mat))
		   (grayscale (mat height width +8u+))
		   (threshold (mat height width +8u+))
		   (threshold3 (mat height width +8uc3+))
		   ;;Create a double wide window to show the camera 
		   ;;output and a thresholded camera output in
		   (window (mat height (* width 2) +8uc3+)))
	  (loop
	     ;;Set camera feed to FRAME
	     (read cap frame)
	     ;;Convert FRAME to a 1 channel grayscale 
	     ;;image and assign to GRAYSCALE
	     (cvt-color frame grayscale +bgr2gray+)
	     ;;Apply a fixed-level threshold to 
	     ;;each array element of GRAYSCALE
	     (threshold grayscale threshold 128d0 255d0 +thresh-binary+)
	     ;;Convert threshold back to a 3 channel 
	     ;;BGR image and assign to THRESHOLD3
	     (cvt-color threshold threshold3 +gray2bgr+)
	     ;;Set WINDOW roi to the left half
	     (with-mat ((a (adjust-roi window 0 0 0 (* (cols threshold3) -1))))
	       ;;Copy original camera feed(FRAME) to WINDOW 
	       (copy-to frame window)
	       ;;Set WINDOW roi to the right half
	       (with-mat ((b (adjust-roi window 0 0 (* (cols frame) -1) 
					 (cols threshold3))))
		 ;;Copy thresholded camera feed to WINDOW
		 (copy-to threshold3 window)
		 ;;Restore original roi
		 (with-mat ((c (adjust-roi window 0 0 (cols frame) 0)))
		   ;;Show WINDOW in a window
		   (imshow window-name window)
		   (let ((c (wait-key 33)))
		     (when (= c 27)
		       (return))))))))))))

========================================================================================================================================
#IMGPROC - #HISTOGRAMS
========================================================================================================================================

========================================================================================================================================
EQUALIZE-HIST
========================================================================================================================================


Equalizes the histogram of a grayscale image.


C++: void equalizeHist(InputArray src, OutputArray dst)

LISP-CV: (EQUALIZE-HIST (SRC MAT) (DEST MAT)) => :VOID


    Parameters:	

        SRC - Source 8-bit single channel image.

        DST - Destination image of the same size and type as SRC.


The function equalizes the histogram of the input image using the following algorithm:

See OpenCV documentation for algorithm: 

http://docs.opencv.org/modules/imgproc/doc/histograms.html?highlight=equalizeh#equalizehist


Example:

(defun equalize-hist-example (&optional 
				(camera-index *camera-index*) 
				(width *default-width*)
				(height *default-height*))

  (with-captured-camera (cap camera-index :height height :width width)
    (let* ((window-name-1 "Original FRAME - EQUALIZE-HIST Example")
           (window-name-2 "1 channel FRAME - EQUALIZE-HIST Example")
           (window-name-3 "Equalized FRAME - EQUALIZE-HIST Example"))
      (if (not (is-opene cap)) 
	  (return-from equalize-hist-example 
	    (format t "Cannot open the video camera")))
      (format t "~%Frame Size : ~ax~a~%~%" 
	      (get* cap +cap-prop-frame-width+)
	      (get* cap +cap-prop-frame-height+))
      (with-named-window (window-name-1 +window-autosize+)
	(with-named-window (window-name-2 +window-autosize+)
	  (with-named-window (window-name-3 +window-autosize+)
	    (move-window window-name-1 184 175)
	    (move-window window-name-2 634 175)
	    (move-window window-name-3 1084 175)
	    (with-mat ((frame (mat))
		       (frame-gray (mat)))
	      (loop
		 ;;Set camera to frame
		 (read cap frame)
		 ;;Show FRAME in a window
		 (imshow window-name-1 frame)
		 ;;Convert FRAME to 1 channel 
		 ;;image, FRAME-GRAY
		 (cvt-color frame frame-gray +bgr2gray+)
		 ;;Show FRAME-GRAY in a window
		 (imshow window-name-2 frame-gray)
		 ;;Run EQUALIZE-HIST on FRAME-GRAY
		 (equalize-hist frame-gray frame-gray)
		 ;;Show FRAME-GRAY in a window
		 (imshow window-name-3 frame-gray)
		 (let ((c (wait-key 33)))
		   (when (= c 27)
		     (return)))))))))))


========================================================================================================================================
#IMGPROC - #MOTION ANALYSIS AND OBJECT TRACKING
========================================================================================================================================

========================================================================================================================================
#CREATE-HANNING-WINDOW
========================================================================================================================================

This function computes a Hanning window coefficients in two dimensions. 

See: http://en.wikipedia.org/wiki/Hann_function and: 

http://en.wikipedia.org/wiki/Window_function for more information.

C++: void createHanningWindow(OutputArray dst, Size winSize, int type)

LISP-CV: (CREATE-HANNING-WINDOW (DEST MAT) (WIN-SIZE SIZE) (TYPE :INT)) => :VOID


    Parameters:	

        DEST - Destination array to place Hann coefficients in.

        WIN-SIZE - The window size specifications.

        TYPE - Created array type.


An example is shown below:


;;Create hanning window with
;;size 100x100 and type +32F+

(with-mat ((hann (mat)))
  (with-size ((win-size (size 0 0)))
    (create-Hanning-Window hann win-size +32F+)))


See also:

(PHASE-CORRELATE) (PHASE-CORRELATE-EXAMPLE)

========================================================================================================================================
#PHASE-CORRELATE
========================================================================================================================================

The function is used to detect translational shifts that occur between two images. The operation takes 
advantage of the Fourier shift theorem for detecting the translational shift in the frequency domain. It 
can be used for fast image registration as well as motion estimation. For more information please see:

http://en.wikipedia.org/wiki/Phase_correlation.

Calculates the cross-power spectrum of two supplied source arrays. the arrays are padded if needed 
with (GET-OPTIMAL-DFT-SIZE).

C++: Point2d phaseCorrelate(InputArray src1, InputArray src2, InputArray window=noArray(), double* response=0)

LISP-CV: (PHASE-CORRELATE (SRC-1 MAT) (SRC-2 MAT) ((WINDOW MAT) (MAT)) ((RESPONSE :POINTER) (CFFI::NULL-POINTER))) => POINT-2D

    Parameters:	

        SRC-1 - Source floating point array (+32FC1+ or +64FC1+)
+
        SRC-2 - Source floating point array (+32FC1+ or +64FC1+)

        WINDOW - Floating point array with windowing coefficients to reduce edge effects (optional).

        RESPONSE - Signal power within the 5x5 centroid around the peak, between 0 and 1 (optional).


Return value: detected phase shift (sub-pixel) between the two arrays.


See OpenCv documentation at this link:

http://docs.opencv.org/trunk/modules/imgproc/doc/motion_analysis_and_object_tracking.html?highlight=phasec#phasecorrelate

for further description and formulae.


See also:

(DFT), (GET-OPTIMAL-DFT-SIZE), (IDFT), (MUL-SPECTRUMS) (CREATE-HANNING-WINDOW)


Example:

(defun phase-correlate-example (&optional 
				  (cam *camera-index*) 
				  (width *default-width*)
				  (height *default-height*))

  "In this example PHASE-CORRELATE detects the motion of the camera not 
   the subject. To see the effect of this this example you will need to 
   pick up the camera and move it different directions and at different 
   speeds. When a transitional shift between two camera frames is detec-
   ted and certain criteria is met, a circle with a line inside indicat-
   ing the direction of movement, will be drawn to the window."

  (with-captured-camera (cap cam :width width :height height)
    (if (not (is-opened cap)) 
	(return-from phase-correlate-example 
	  (format t "Cannot open the video camera")))      
    (let ((window-name "Phase Shift - PHASE-CORRELATE Example"))
      (with-named-window (window-name +window-autosize+)
	(move-window window-name 639 115)
	(with-mat ((frame (mat))
		   (curr (mat))
		   (prev (mat))
		   (curr-64f (mat))
		   (prev-64f (mat))
		   (hann (mat)))
	  (with-scalar ((scalar (scalar 0 255 0)))

	    (loop
	       (let ((radius 0))
		 (read cap frame)
		 (cvt-color frame curr +bgr2gray+)
		 (if (empty prev) (progn (setf prev (t:clone curr)) 
					 (create-hanning-window hann (size curr) +64f+)))
		 (convert-to prev prev-64f +64f+)
		 (convert-to curr curr-64f +64f+)
		 (with-point-2d ((shift (phase-correlate prev-64f curr-64f hann)))
		   (setf radius (coerce (sqrt (+ (* (x shift) (x shift)) 
						 (* (y shift) (y shift)))) 'double-float))
		   (if (> radius 5) (progn 

				      ;;Draw a circle and line indicating the shift direction
				      (with-point ((center (point (ash (cols curr) -1)  
								  (ash (rows curr) -1))))
					(with-point ((pt-2 (point (+ (x center) (floor (x shift))) 
								  (+ (y center) (floor (y shift))))))
					  (circle frame center (floor radius) scalar 3 +aa+)
					  (line frame center pt-2 scalar 3 +aa+)) nil))))
		 (imshow window-name frame)
		 (let ((key (wait-key 2)))
		   (setf prev (t:clone curr))
		   (when (= key 27)  ;Esc to exit...
		     (return)))))))))))

========================================================================================================================================
#IMGPROC - #FEATURE DETECTION
========================================================================================================================================

========================================================================================================================================
#CANNY
========================================================================================================================================

Finds edges in an image using the [Canny86] algorithm.

C++: void Canny(InputArray image, OutputArray edges, double threshold1, double threshold2, int apertureSize=3, bool L2gradient=false)

LISP-CV: (CANNY (IMAGE MAT) (EDGES MAT) (THRESHOLD1 :DOUBLE) (THRESHOLD2 :DOUBLE) ((APERTURE-SIZE :INT) 3) 
               ((L2-GRADIENT :BOOLEAN) NIL)) => :VOID

    Parameters:	

        IMAGE - Single-channel 8-bit input image.

        EDGES - Output edge map; it has the same size and type as image.

        THRESHOLD1 - First threshold for the hysteresis procedure.

        THRESHOLD2 - Second threshold for the hysteresis procedure.

        APERTURE-SIZE - Aperture size for the (SOBEL) operator.

        L2-GRADIENT - A flag, indicating whether a more accurate L2 norm should be used to calculate 
                      the image gradient magnitude (EQ L2-GRADIENT T), or whether the default L1 norm 
                      is enough (EQ L2-GRADIENT NIL).

The function finds edges in the input image IMAGE and marks them in the output map edges using the 
Canny algorithm. The smallest value between THRESHOLD1 and THRESHOLD2 is used for edge linking. The 
largest value is used to find initial segments of strong edges. 

See: http://en.wikipedia.org/wiki/Canny_edge_detector


Example:

(defun canny-example (&optional 
			(cam *camera-index*) 
			(width *default-width*)
			(height *default-height*))

  (with-captured-camera (cap cam :width 640 :height 480)
    (let* ((window-name  "CANNY Example")
	   (aperture-size 3)
           (l2-gradient nil)) 
      (with-named-window (window-name +window-normal+)
	(set-window-property window-name +wnd-prop-fullscreen+ 
			     +window-fullscreen+)
	(set-window-property window-name +wnd-prop-aspectratio+ 
			     +window-freeratio+)
	;;Allocate int pointers for trackbars to adjust
	(with-object ((low-thresh (alloc :int 50)) 
		      (high-thresh (alloc :int 60))
		      (l2-gradient-switch (alloc :int 0)))
	  (create-trackbar "LOW-THRESH" window-name low-thresh 500)                         
	  (create-trackbar "HIGH-THRESH" window-name high-thresh 500)
	  (create-trackbar "L2-GRADIENT" window-name l2-gradient-switch 1)
	  (with-mat ((frame (mat))
		     ;;Create the destination matrix 
		     ;;half the size of camera feed
		     (out (mat (/ height 2) 
			       (/ width 2) +8uc3+)))
	    (loop
               ;;Set camera feed to frame
	       (read cap frame)
	       ;;Clone FRAME
	       (with-mat ((clone (clone frame)))
		 (if (eq (@ l2-gradient-switch :int) 1) (setf l2-gradient t) 
		     (setf l2-gradient nil))
		 ;;Convert CLONE to a 1 channel grayscale image.
		 (cvt-color clone clone +bgr2gray+)
		 ;;Blur and downsample CLONE
		 (pyr-down clone out)
		 ;;Detect edges in camera feed. The LOW-THRESH, 
		 ;;HIGH-THRESH and L2-GRADIENT parameters can 
		 ;;be changed by sliding the trackbars
		 (canny out out (coerce (@ low-thresh :int) 'double-float) 
			(coerce (@ high-thresh :int) 'double-float) 
			aperture-size l2-gradient)
		 ;;Show result in window
		 (imshow window-name out))	     
	       (let ((c (wait-key 33)))
		 (when (= c 27)
		   (return))))))))))


========================================================================================================================================
CORNER-SUB-PIX
========================================================================================================================================

Refines the corner locations.

C++: void cornerSubPix(InputArray image, InputOutputArray corners, Size winSize, Size zeroZone, TermCriteria criteria)

LISP-CV: (CORNER-SUB-PIX (IMAGE MAT) (CORNERS MAT) (WIN-SIZE SIZE) (ZERO-ZONE SIZE) (CRITERIA TERM-CRITERIA)) => :VOID


    Parameters:	

        IMAGE - Input image.

        CORNERS - Initial coordinates of the input corners and refined coordinates provided for output.

        WIN-SIZE - Half of the side length of the search window. For example, if (EQ WIN-SIZE (SIZE 5 5)), 
                   then a (=  (*  (+ (* 5 2) 1)  (+ (* 5 2) 1) )  (* 11 11) ) search window is used.

        ZERO-ZONE - Half of the size of the dead region in the middle of the search zone over which the 
                    summation in the formula below is not done. It is used sometimes to avoid possible 
                    singularities of the autocorrelation matrix. The value of (-1 -1) indicates that there 
                    is no such a size.

        CRITERIA - Criteria for termination of the iterative process of corner refinement. That is, the 
                   process of corner position refinement stops either after (CRITERIA MAX-COUNT) iterations 
                   or when the corner position moves by less than (EPSILON CRITERIA) on some iteration.


The function iterates to find the sub-pixel accurate location of corners or radial saddle points. 


See OpenCV documentation at this link:

http://docs.opencv.org/trunk/modules/imgproc/doc/feature_detection.html?highlight=corn#cornersubpix

for images, further description and formulae.


Example:

(defun coner-sub-pix-example (&optional 
				(cam *camera-index*) 
				(width *default-width*)
				(height *default-height*))

  (with-captured-camera (cap cam :width width :height height)
    (if (not (is-opened cap)) 
	(return-from coner-sub-pix-example
	  (format t "Cannot open the video camera")))
    (let ((window-name "FRAME - GOOD-FEATURES-TO-TRACK Example")

	  ;;Below are all the GOOD-FEATURES-TO-TRACK 
          ;;parameters, that you can change with the 
          ;;trackbars, and their definitions.

	  ;;The maximum number of corners to return. 
	  (max-corners (t:alloc :int 71))
	  ;;Minimal accepted quality of the corners
	  (quality-level (t:alloc :int 1))
	  ;;Minimum possible Euclidean distance 
	  ;;between the returned corners.
	  (min-distance  (t:alloc :int 20))
	  ;;Size of the averaging block for computing derivative 
	  ;;covariation matrix over each pixel neighborhood. 
	  (block-size (t:alloc :int 3))
	  ;;Indicates, whether to use a Harris 
          ;;detector or (CORNER-MIN-EIGEN-VAL)
	  (use-harris-detector (t:alloc :int 0))
	  ;;Free parameter of Harris detector.
	  (k (t:alloc :int 4))

	  ;;Below are some CORNER-SUB-PIX parameters
	  ;;that you can change with the trackbars and 
          ;;their definitions.

          ;;Allows you to turn CORNER-SUB-PIX on or off.
	  (use-corner-sub-pix (t:alloc :int 0))

          ;;        WIN-SIZE
          ;;        ========

          ;;Half of the side length of the search window. 
	  (win-size-width (t:alloc :int 21))
	  (win-size-height (t:alloc :int 21))

          ;;        ZERO-ZONE
          ;;        =========

          ;;Half of the size of the dead region in the middle 
          ;;of the search zone over which the summation in the 
          ;;formula below is not done.  
	  (zero-zone-width (t:alloc :int 0))
	  (zero-zone-height (t:alloc :int 0)))

      (with-named-window (window-name +window-autosize+)
	(move-window window-name 640 159)
        
	(create-trackbar "MAX CRNRS" window-name max-corners 450)
	(create-trackbar "QUAL-LEVEL" window-name quality-level 500)
	(create-trackbar "MIN-DIST." window-name min-distance 500)
	(create-trackbar "BLOCK-SIZE" window-name block-size 500)
	(create-trackbar "USE-HARRIS" window-name use-harris-detector 1)
	(create-trackbar "K" window-name k 500)
	(create-trackbar "USE-CORNER-SUB-PIX" window-name use-corner-sub-pix 1)
	(create-trackbar "WIN-SIZE-WIDTH" window-name win-size-width 200)
	(create-trackbar "WIN-SIZE-HEIGHT" window-name win-size-width 200)
	(create-trackbar "ZERO-ZONE-WIDTH" window-name zero-zone-width 200)
	(create-trackbar "ZERO-ZONE-HEIGHT" window-name zero-zone-height 200)

	(with-mat ((frame (mat)))

	  (loop
	     (read cap frame)
	     ;;Convert FRAME to 1 channel image.
	     (cvt-color frame frame +bgr2gray+)
	     ;;Equalize histogram of FRAME 
	     ;;so we get better tracking.
	     (equalize-hist frame frame)
	     ;;Here we stop trackbar going below 1 on the
             ;;following trackbars(or program will freeze)
	     (with-mat ((corners (mat (@ max-corners :int) 2 +32f+)))
	       (if (< (get-trackbar-pos "QUAL-LEVEL" window-name) 1) 
		   (set-trackbar-pos "QUAL-LEVEL" window-name 1) nil)
	       (if (< (get-trackbar-pos "BLOCK-SIZE" window-name) 1) 
		   (set-trackbar-pos "BLOCK-SIZE" window-name 1) nil)
	       (if (< (get-trackbar-pos "WIN-SIZE-WIDTH" window-name) 1) 
		   (set-trackbar-pos "WIN-SIZE-WIDTH" window-name 1) nil)
	       (if (< (get-trackbar-pos "WIN-SIZE-HEIGHT" window-name) 1) 
		   (set-trackbar-pos "WIN-SIZE-HEIGHT" window-name 1) nil)
	       ;;Detect strong corners in FRAME.
               ;;Note: the @ macro dereferences the 
               ;;integer pointer created by ALLOC.
	       (good-features-to-track frame corners 
				       (@ max-corners :int)
				       (* (@ quality-level :int) 0.001d0)
				       (* (@ min-distance :int) 1d0) 
				       (t:mat)
				       (@ block-size :int)	
				       (if (= (@ use-harris-detector :int) 1) t nil))

               ;;Here, we evaluate CORNER-SUB-PIX, if the 
               ;;USE-CORNER-SUB-PIX trackbar is set to 1.

	       (if (= (@ use-corner-sub-pix :int) 1)
		   (with-term-criteria ((criteria (term-criteria 
						   (logior +termcrit-iter+ +termcrit-eps+)
						   20 0.03d0)))

		     (with-size ((win-size (size (@ win-size-width :int) 
						 (@ win-size-height :int))))
		       (with-size ((zero-zone (size (- (@ zero-zone-width :int) 1) 
						    (- (@ zero-zone-height :int) 1))))
			 ;;Refine the features.
			 (corner-sub-pix frame corners win-size zero-zone criteria)))))

	       ;;Convert frame back to a 3 channel
	       ;;image so the circles have color.
	       (cvt-color frame frame +gray2bgr+)

               ;;Draw the detected corners with CIRCLE.
	       (dotimes (i (* (rows corners) (cols corners)))
		 (with-point ((center (point (ceiling (@ (at-point-2f corners 0 i) :float)) 
					     (ceiling (@ (at-point-2f corners 0 i) :float 1)))))
		   (circle frame center 8 (t:bgr 255 0 111) -1)
		   (circle frame center 8 (t:bgr 0 255 0) 1)))

               ;;Print the corner locations.
	       (format t "~%CORNERS:~%~%")
	       (print-mat corners)
	       (format t "~%")

	       (imshow window-name frame)
	       (let ((c (wait-key 33)))
		 (when (= c 27)
		   (return))))))))))

========================================================================================================================================
#GOOD-FEATURES-TO-TRACK
========================================================================================================================================

Determines strong corners on an image.

C++: void goodFeaturesToTrack(InputArray image, OutputArray corners, int maxCorners, double qualityLevel, 
                              double minDistance, InputArray mask=noArray(), int blockSize=3, bool useHarrisDetector=false, 
                              double k=0.04 )

LISP-CV: (GOOD-FEATURES-TO-TRACK (IMAGE MAT) (CORNERS MAT) (MAX-CORNERS :INT) (QUALITY-LEVEL :DOUBLE) (MIN-DISTANCE :DOUBLE) 
                                  &OPTIONAL ((MASK MAT) (%MAT)) ((BLOCK-SIZE :INT) 3) ((USE-HARRIS-DETECTOR :BOOLEAN) NIL) 
                                 ((K :DOUBLE) 0.04)) => :VOID

    Parameters:	

        IMAGE - Input 8-bit or floating-point 32-bit, single-channel image.

        CORNERS - Output vector of detected corners.

        MAX-CORNERS - Maximum number of corners to return. If there are more corners than are found, 
                      the strongest of them is returned.

        QUALITY-LEVEL - Parameter characterizing the minimal accepted quality of image corners. The 
                        parameter value is multiplied by the best corner quality measure, which is 
                        the minimal eigenvalue (see (CORNER-MIN-EIGEN-VAL)) or the Harris function 
                        response (see (CORNER-HARRIS)). The corners with the quality measure less 
                        than the product are rejected. i.e., if the best corner has quality measure 
                        equal to 1500, and  (= QUALITY-LEVEL 0.01d0), then all the corners with the 
                        quality measure less than 15 are rejected.

        MIN-DISTANCE - Minimum possible Euclidean distance between the returned corners.

        MASK - Optional region of interest. If the image is not empty (it needs to have type +8UC1+ 
               and the same size as IMAGE), it specifies the region in which the corners are detected.

        BLOCK-SIZE - Size of an average block for computing a derivative covariation matrix over each 
                     pixel neighborhood. See (CORNER-EIGEN-VALS-AND-VECS).

        USE-HARRIS-DETECTOR - Parameter indicating whether to use a Harris detector (see (CORNER-HARRIS)) 
                              or (CORNER-MIN-EIGEN-VAL)).

        k - Free parameter of the Harris detector.

The function finds the most prominent corners in the image or in the specified image region, as 
described in [Shi94]:


[Shi94] =	

    Shi and C. Tomasi. Good Features to Track. Proceedings of the IEEE Conference on Computer Vision 
    and Pattern Recognition, pages 593-600, June 1994.


See OpenCV documentation at this link:

http://docs.opencv.org/trunk/modules/imgproc/doc/feature_detection.html?highlight=goodf#goodfeaturestotrack

for further description and formulae:


See also:

(CORNER-MIN-EIGEN-VAL), (CORNER-HARRIS), (CALC-OPTICAL-FLOW-PYR-LK), (ESTIMATE-RIGID-TRANSFORM)


Example:

;;Path to the classifier.
(defparameter face-cascade-name "<opencv-src-dir>/data/haarcascades/haarcascade_frontalface_alt.xml")
;;Create CASCADE-CLASSIFIER object.
(defparameter face-cascade (cascade-classifier))


(defun detect-face (frame &optional mask)

  (let ((num-buffers 2)
        (size-factor 1.1d0)
	(faces-list 0)
        (roi 0))
    (with-vector-rect ((faces (vector-rect)))
      (with-mat ((frame-gray (mat)))
	(with-size ((face-size (size 30 30)))
	  ;;Detect faces with DETECT-MULTI-SCALE.
	  (detect-multi-scale face-cascade frame faces size-factor 
			      num-buffers +cascade-do-canny-pruning+ face-size))
	;;Convert VECTOR-RECT to a Lisp list for speed.
	(setf faces-list (vector-rect :to-lisp-list faces))
	;;Iterate through all current elements (detected faces).
	(dotimes (index-current (length faces-list))
	  (setf roi (clone (nth index-current faces-list))) 
	  ;;Display detected faces on main window.
	  (with-point ((pt1 (point (x (nth index-current faces-list)) 
				   (y (nth index-current faces-list))))
		       (pt2 (point (+ (x (nth index-current faces-list)) 
				      (height (nth index-current faces-list)))
				   (+ (y (nth index-current faces-list)) 
				      (width (nth index-current faces-list))))))
	    (with-scalar ((white (scalar 255 255 255)))

	      (rectangle mask pt1 pt2 white -1 8 0))))))
    (tg:finalize roi (lambda () (del-rect roi)))))


(defun good-features-to-track-example (&optional 
					 (cam *camera-index*) 
					 (width *default-width*)
					 (height *default-height*))

  "In this example we detect faces in the camera feed with 
   DETECT-MULTI-SCALE. Then we use GOOD-FEATURES-TO-TRACK 
   to determine the best points to track in those detected 
   faces."

  (with-captured-camera (cap cam :width width :height height)
    (if (not (is-opened cap)) 
	(return-from good-features-to-track-example
	  (format t "Cannot open the video camera")))
    ;;Load the classifier.
    (if (not (cascade-classifier-load face-cascade face-cascade-name))
	(return-from good-features-to-track-example 
	  (format t "Error Loading")))
    (let ((window-name-1 "MASK - GOOD-FEATURES-TO-TRACK Example")
          (window-name-2 "FRAME - GOOD-FEATURES-TO-TRACK Example")

	  ;;Below are some GOOD-FEATURES-TO-TRACK parameters
	  ;;that you can change with the trackbars and their 
          ;;definitions.
	  
          ;;Note: The t: prefix signifies auto GC is enabled.

	  ;;          MAX-CORNERS              
	  ;;          ===========

	  ;;The maximum number of corners to return. 
	  ;;If there are more corners than that the 
	  ;;strongest of them will be returned.
	  (max-corners (t:alloc :int 10))


	  ;;         QUALITY-LEVEL
	  ;;         =============

	  ;;The minimal accepted quality of corners
	  ;;of the image, The value of the parameter 
	  ;;is multiplied by the best corner quality  
	  ;;measure (which is the minimum eigenvalue,
	  
	  ;;     See: (CORNER-MIN-EIGEN-VAL)

	  ;;or the Harris function response,

	  ;;     See: (CORNER-HARRIS)

	  ;;The corners, which quality measure is less 
	  ;;than the product, will be rejected. i.e. if 
	  ;;the best corner has the quality measure equal 
          ;;to 1500 and (= QUALITY-LEVEL 0.01d0) , then all 
          ;;corners which quality measure is less than 15 is 
          ;;rejected.
	  (quality-level (t:alloc :int 1))


	  ;;         MIN-DISTANCE
	  ;;         ============

	  ;;The minimum possible Euclidean distance 
	  ;;between the returned corners.
	  (min-distance  (t:alloc :int 20))
	  ;;Size of the averaging block for computing derivative 
	  ;;covariation matrix over each pixel neighborhood, 

	  ;;     See: (CORNER-EIGENVALS-AND-VECS)

	  (block-size (t:alloc :int 3))


	  ;;       USE-HARRIS-DETECTOR
	  ;;       ===================

	  ;;Indicates, whether to use a Harris detector or: 
	  
	  ;;      (CORNER-MIN-EIGEN-VAL)

	  (use-harris-detector (t:alloc :int 0))


	  ;;               K
	  ;;               =

	  ;;Free parameter of Harris detector.

	  (k (t:alloc :int 4))
	  (mask 0)
          (roi 0))

      (with-named-window (window-name-1 +window-autosize+)
	(with-named-window (window-name-2 +window-autosize+)
	  (move-window window-name-1 280 175)
	  (move-window window-name-2 997 175)
	  (create-trackbar "MAX CRNRS" window-name-2 max-corners 500)
	  (create-trackbar "QUAL-LEVEL" window-name-2 quality-level 500)
	  (create-trackbar "MIN-DIST." window-name-2 min-distance 500)
	  (create-trackbar "BLOCK-SIZE" window-name-2 block-size 500)
	  (create-trackbar "USE-HARRIS" window-name-2 use-harris-detector 1)
	  (create-trackbar "K" window-name-2 k 500)
	  (with-mat ((frame (mat)))

	    (loop
	       (read cap frame)
	       ;;The optional region of interest. If the mask is 
	       ;;not empty (then it needs to have the type +8UC1+ 
	       ;;and the same size as image), it will specify the 
	       ;;region in which the corners are detected.
	       (setf mask (mat (rows frame) (cols frame) +8uc1+ 0))
	       ;;Convert to 1 channel image.
	       (cvt-color frame frame +bgr2gray+)
	       ;;Equalize frame histogram 
	       ;;to get better tracking.
	       (equalize-hist frame frame)
	       (if (not (empty frame)) 
		   ;;Apply the classifier to the frame.
		   (setf roi (detect-face frame mask))
		   (format t "No captured frame: Break!"))
               ;;Don't let trackbar go below 1 for QUAL-LEVEL/BLOCK-SIZE
	       (with-mat ((corners (mat (@ max-corners :int) 2 +32f+)))
		 (if (< (get-trackbar-pos "QUAL-LEVEL" window-name-2) 1) 
		     (set-trackbar-pos "QUAL-LEVEL" window-name-2 1) nil)
		 (if (< (get-trackbar-pos "BLOCK-SIZE" window-name-2) 1) 
		     (set-trackbar-pos "BLOCK-SIZE" window-name-2 1) nil)
                 ;;Detect strong corners in the face ROI.
		 (good-features-to-track frame corners 
					 (@ max-corners :int)
					 (* (@ quality-level :int) 0.001d0)
					 (* (@ min-distance :int) 1d0) 
					 mask
					 (@ block-size :int)	
					 (if (= (@ use-harris-detector :int) 1) t nil))
                 ;;Convert frame back to 3 channel image 
                 ;;so circles and rectangle have color.
		 (cvt-color frame frame +gray2bgr+)
                 ;;Draw the detected corners.
		 (dotimes (i (* (rows corners) (cols corners)))
		   (with-point ((center (point (ceiling (@ (at-point-2f corners 0 i) :float)) 
					       (ceiling (@ (at-point-2f corners 0 i) :float 1)))))
		     (circle frame center 8 (t:bgr 255 0 111) -1)
		     (circle frame center 8 (t:bgr 0 255 0) 1)))

		 (format t "~%Output Matrix of Corners:~%~%")
		 (print-mat corners)
		 (format t "~%")

		 (imshow window-name-1 mask)
		 (del-mat mask)
		 (if (rect-p roi) 
		     (with-scalar ((white (scalar 255 255 255)))
		       (rectangle frame (tl roi) (br roi) white 2 8 0))))
	       (imshow window-name-2 frame)
	       (let ((c (wait-key 33)))
		 (when (= c 27)
		   (return))))))))))

========================================================================================================================================
#HOUGH-LINES
========================================================================================================================================

Finds lines in a binary image using the standard Hough transform.

C++: void HoughLines(InputArray image, OutputArray lines, double rho, double theta, int threshold, double srn=0, 
                     double stn=0, double min_theta=0, double max_theta=CV_PI )

LISP-CV: (HOUGH-LINES (IMAGE MAT) (LINES MAT) (RHO :DOUBLE) (THETA :DOUBLE) (THRESHOLD :INT) &OPTIONAL 
                     ((SRN :DOUBLE) 0D0)  ((STN :DOUBLE) 0D0) ((MIN-THETA :DOUBLE) 0D0) ((MAX-THETA :DOUBLE) +PI+)) => :VOID
    Parameters:	

        IMAGE - 8-bit, single-channel binary source image. The image may be modified by the function.

        LINES - Output matrix of lines. Each line is represented by a two-element row of the matrix.
 
                See OpenCV documentation at the link below for a more formulaic description of this parameter:.

                    http://docs.opencv.org/trunk/modules/imgproc/doc/feature_detection.html?highlight=hough#houghlines

        RHO - Distance resolution of the accumulator in pixels.

        THETA - Angle resolution of the accumulator in radians.

        THRESHOLD - Accumulator threshold parameter. Only those lines are returned that get enough 
                    votes (> THRESHOLD).

        SRN - For the multi-scale Hough transform, it is a divisor for the distance resolution RHO. 
              The coarse accumulator distance resolution is RHO and the accurate accumulator resolution 
              is (/ RHO SRN). If both (= SRN 0d0) and (= STN 0d0) , the classical Hough transform is used. 
              Otherwise, both these parameters should be positive.

        STN - For the multi-scale Hough transform, it is a divisor for the distance resolution THETA.

        MIN-THETA - For standard and multi-scale Hough transform, minimum angle to check for lines. 
                    Must fall between 0 and MAX-THETA.

        MAX-THETA - For standard and multi-scale Hough transform, maximum angle to check for lines. 
                    Must fall between MIN-THETA and +PI+.


This function implements the standard or standard multi-scale Hough transform algorithm for line detection. 

See: http://homepages.inf.ed.ac.uk/rbf/HIPR2/hough.htm for a good explanation of Hough transform. 


Example:

;;Define global parameters.
(defparameter edges (t:mat))
(defparameter probabilistic-name "Probabilistic - HOUGH-LINES Example")
(defparameter standard-name "Standard - HOUGH-LINES Example")
(defparameter min-threshold 50)
(defparameter max-trackbar 150)
(defparameter s-trackbar (t:alloc :int max-trackbar))
(defparameter p-trackbar (t:alloc :int max-trackbar))

;;Callback function STANDARD-HOUGH.
(defcallback standard-hough :void ()

  (let ((r)
	(t*)
	(cos-t)
	(sin-t)
	(x0)
	(y0)
	(alpha 1000))
    (with-mat ((s-lines (mat))
	       (standard-hough (mat)))
      (cvt-color edges standard-hough +gray2bgr+)
      ;;Use Standard Hough Transform.
      (hough-lines edges s-lines 1d0 (/ +pi+ 180) (+ min-threshold (@ s-trackbar :int) 0 0))
      ;;Show the result.
      (dotimes (i (* (rows s-lines) (cols s-lines)))
	(setf r (at-float s-lines i 0))
	(setf t* (at-float s-lines i 1))
	(setf cos-t (cos t*))
	(setf sin-t (sin t*))
	(setf x0 (* cos-t r)) 
	(setf y0 (* sin-t r))
	(line standard-hough (t:point (round (+ x0 (* alpha (- sin-t)))) (round (+ y0 (* alpha cos-t))))
	      (t:point (round (- x0 (* alpha (- sin-t)))) (round (- y0 (* alpha cos-t))))
	      (t:scalar 255 0 0) 3 +aa+))

      (imshow standard-name standard-hough))))

;;Callback function PROBABILISTIC-HOUGH.
(defcallback probabilistic-hough :void ()

  (with-mat ((p-lines (mat))
	     (probabilistic-hough (mat)))
    (cvt-color edges probabilistic-hough +gray2bgr+)
    ;;Use Probabilistic Hough Transform.
    (hough-lines-p edges p-lines 1d0 (/ +pi+ 180) 
		   (round (+ min-threshold (@ p-trackbar :int))) 30d0 10d0)
					;lShow the result.
    (dotimes (i (* (rows p-lines) (cols p-lines)))
      (let ((ptr (ptr p-lines i)))
	(line probabilistic-hough (t:point (round (@ ptr :int)) (round (@ ptr :int 1))) 
	      (t:point (round (@ ptr :int 2)) (round (@ ptr :int 3))) 
	      (t:scalar 0 0 255) 3 +aa+)))
    (imshow probabilistic-name probabilistic-hough)))


(defun hough-lines-example (filename)

  "Note: building.jpg in the LISP-CV images 
   directory works nicely with this example."

  (let ((thresh-label-1 "Thres: 50")
	(thresh-label-2 "Thres: 50"))
    ;;Read the image.
    (with-mat ((src (imread filename +load-image-color+)))
      (if (empty src) 
	  (return-from hough-lines-example
	    (format t "Image not loaded")))
      ;;Pass the image to gray.
      (with-mat ((src-gray (mat)))
	(cvt-color src src-gray +rgb2gray+)
	;;Apply Canny edge detector.
	(canny src-gray edges 50d0 200d0 3)
	;;Create trackbars for thresholds.
	(with-named-window  (standard-name +window-autosize+)
	  (create-trackbar thresh-label-1 standard-name s-trackbar max-trackbar 
			   (callback standard-hough))
	  (with-named-window (probabilistic-name +window-autosize+)
	    (create-trackbar thresh-label-2 probabilistic-name p-trackbar max-trackbar 
			     (callback probabilistic-hough))
	    ;;Initialize callback functions.
	    (set-trackbar-pos thresh-label-1 standard-name (- max-trackbar 1))
	    (set-trackbar-pos thresh-label-2 probabilistic-name (- max-trackbar 1))
	    (loop
	       (let ((c (wait-key 33)))
		 (when (= c 27)
		   (return))))))))))

========================================================================================================================================
HOUGH-LINES-P
========================================================================================================================================

Finds line segments in a binary image using the probabilistic Hough transform.

C++: void HoughLinesP(InputArray image, OutputArray lines, double rho, double theta, int threshold, double minLineLength=0, 
                      double maxLineGap=0 )

LISP-CV: (HOUGH-LINES-P (IMAGE MAT) (LINES MAT) (RHO :DOUBLE) (THETA :DOUBLE) (THRESHOLD :INT) ((MIN-LINE-LENGTH :DOUBLE) 0D0) 
                       ((MAX-LINE-GAP :DOUBLE) 0D0)) => :VOID

    Parameters:	

        image - 8-bit, single-channel binary source image. The image may be modified by the function.

        LINES - Output matrix of lines. Each line is represented by a 4-element row of the matrix (x-1 y-1 x-2 y-2)
                where (x-1 y-1) and (x-2, y-2) are the ending points of each detected line segment.

        RHO - Distance resolution of the accumulator in pixels.

        THETA - Angle resolution of the accumulator in radians.

        THRESHOLD - Accumulator threshold parameter. Only those lines are returned that get enough 
                    votes ( > THRESHOLD).

        MIN-LINE-LENGTH - Minimum line length. Line segments shorter than that are rejected.

        MAX-LINE-GAP - Maximum allowed gap between points on the same line to link them.


The function implements the probabilistic Hough transform algorithm for line detection, described in:

Matas, J. and Galambos, C. and Kittler, J.V., Robust Detection of Lines Using the Progressive Probabilistic Hough Transform.


Example:

See the HOUGH-LINES-EXAMPLE in this file.

========================================================================================================================================
#IMGPROC - #OBJECT DETECTION
========================================================================================================================================

========================================================================================================================================
#MATCH-TEMPLATE:
========================================================================================================================================

Compares a template against overlapped image regions.

C++: void matchTemplate(InputArray image, InputArray templ, OutputArray result, int method)

LISP-CV: (MATCH-TEMPLATE (IMAGE MAT) (TEMPL MAT) (RESULT MAT) 
         (METHOD :INT))) => :VOID


    Parameters:	

        IMAGE - Image where the search is running. It must be 8-bit or 32-bit floating-point.

        TEMPL - Searched template. It must be not greater than the source image and have the 
                same data type.

        RESULT - Map of comparison results. It must be single-channel 32-bit floating-point. 
                 If image is (* W H) and templ is (* w h), then result is: (* (+ (- W w) 1) (+ (- H h) 1)).

        METHOD - Parameter specifying the comparison method (see below).


The function slides through image , compares the overlapped patches of size (* w h) against TEMPL 
using the specified method and stores the comparison results in RESULT. (See OpenCV documentation:
 
http://docs.opencv.org/modules/imgproc/doc/object_detection.html?highlight=matchtem#matchtemplate 

for the formulae for the available comparison methods). 

After the function finishes the comparison, the best matches can be found as global minimums (when 
+TM-SQDIFF+ was used) or maximums (when +TM-CCORR+ or +TM-CCOEFF+ was used) using the (MIN-MAX-LOC) 
function. In case of a color image, template summation in the numerator and each sum in the denominator 
is done over all of the channels and separate mean values are used for each channel. That is, the 
function can take a color template and a color image. The result will still be a single-channel image, 
which is easier to analyze.


Example 1:

(defun match-template-example-1 (&optional (cam *camera-index*) 
				   (width *default-width*)
				   (height *default-height*))

  "Here a template image extracted from a frame of the camera feed is 
   compared to that frame to find the area most similiar to the templ-
   ate image in the camera feed. 
   
   The function: 

   (MATCH-TEMPLATE IMAGE TEMPL RESULT METHOD)
 
   is used for the matching. The last parameter chooses the method of 
   template matching. We use all six methods, shown in six windows st-
   arting with square difference matching (SQDIFF).

   Note the use of (NORMALIZE) in this code, which allows us to show 
   the results in a consistent way (recall that some of the matching 
   methods can return negative-valued results. For this exammple, we 
   use the +NORM-MIN-MAX+ flag when normalizing; this tells the funct-
   ion to shift and scale the floating-point images so that all retur-
   ned values are between 0 and 1.

   Matches are indicated by dark areas in the left column of black an-
   d white images and by bright spots in the other two columns. Posit-
   ion the rectangle, in the top-left-most window, to select the temp-
   late MATCH-TEMPLATE uses to find objects in camera feed by moving 
   the trackbar sliders in the bottom-left-most window."

  (with-captured-camera (cap cam :width width :height height)
    ;;Create array of window names
    (let* ((window-name-arr (make-array 8 :initial-contents 
					(list "SRC - MATCH-TEMPLATE-EXAMPLE-1"
					      "FRAME - MATCH-TEMPLATE-EXAMPLE-1"
					      "SQDIFF - MATCH-TEMPLATE-EXAMPLE-1"
					      "SQDIFF-NORMED - MATCH-TEMPLATE-EXAMPLE-1"
					      "CCORR - MATCH-TEMPLATE-EXAMPLE-1"
					      "CCORR-NORMED - MATCH-TEMPLATE-EXAMPLE-1"
					      "COEFF - MATCH-TEMPLATE-EXAMPLE-1"
					      "COEFF-NORMED - MATCH-TEMPLATE-EXAMPLE-1")))
	   ;;Initialize size parameters 
	   ;;for the matches
	   (iwidth 0)
	   (iheight 0)
	   (arr (make-array '(6)))
           (n 10))      
      ;;Create array of windows
      (dotimes (i 8)
	(named-window (aref window-name-arr i) +window-normal+))
      ;;Move windows to specified locations     
      (move-window (aref window-name-arr 0) 134 0)
      (move-window (aref window-name-arr 1) 134 400)
      (move-window (aref window-name-arr 2) 551 0)
      (move-window (aref window-name-arr 3) 551 400)
      (move-window (aref window-name-arr 4) 968 0)
      (move-window (aref window-name-arr 5) 968 400)
      (move-window (aref window-name-arr 6) 1385 0)
      (move-window (aref window-name-arr 7) 1385 400)
      ;;Allocate int pointers for the trackbars to 
      ;;adjust which will set the template image a-
      ;;nd the guiding rectangle location and boun-
      ;;daries
      (with-object ((rect-x (alloc :int '(0))))
	(with-object ((rect-y (alloc :int '(0))))
	  (with-object ((rect-width (alloc :int (list (round (/ width n))))))
	    (with-object ((rect-height (alloc :int (list (round (/ height n))))))
	      ;;Create trackbars used to adjust template and rectangle position
	      (create-trackbar "RECT-X" (aref window-name-arr 1) rect-x width)
	      (create-trackbar "RECT-Y" (aref window-name-arr 1) rect-y height)
	      (create-trackbar "RECT-WIDTH" (aref window-name-arr 1) rect-width width)
	      (create-trackbar "RECT-HEIGHT" (aref window-name-arr 1) rect-height height)
	      (with-mat ((frame (mat)))
		(with-rect ((roi (rect 0 0 (cols frame) (rows frame))))	      
		  ;;Set rectangle color
		  (with-scalar ((color (scalar 0 255 0)))
		    (loop
		       ;;Set camera feed to FRAME
		       (read cap frame)
		       ;;Print location and size of the 
		       ;;template used to do the matchi-
		       ;;ng and the rectangle
		       (format t "RECT-X: ~a~%~%" (mem-ref rect-x :int))
		       (format t "RECT-Y: ~a~%~%" (mem-ref rect-y :int))
		       (format t "RECT-WIDTH: ~a~%~%" (mem-ref rect-width :int))
		       (format t "RECT-HEIGHT: ~a~%~%" (mem-ref rect-height :int))
		       ;;Instantiate logic used to move the 
		       ;;template and the rectangle as one
		       (if (< (mem-ref rect-x :int) (round (/ (mem-ref rect-width :int) 128))) 
			   (setf (mem-ref rect-x :int) 1))
		       (if (> (mem-ref rect-x :int) 
			      (- (cols frame) (mem-ref rect-width :int))) 
			   (setf (mem-ref rect-x :int) 
				 (- (cols frame) (mem-ref rect-width :int))))
		       (if (< (mem-ref rect-y :int) (round (/ (mem-ref rect-height :int) 128))) 
			   (setf (mem-ref rect-y :int) 1))
		       (if (> (mem-ref rect-y :int) 
			      (- (rows frame) (mem-ref rect-height :int))) 
			   (setf (mem-ref rect-y :int) 
				 (- (rows frame) (mem-ref rect-height :int))))
		       (if (< (mem-ref rect-width :int) 1) 
			   (setf (mem-ref rect-width :int) 1))
		       (if (< (mem-ref rect-height :int) 1) 
			   (setf (mem-ref rect-height :int) 1))
		       ;;Create 2 clones of FRAME, IMG will be where the 
		       ;;rectangle is moved to choose the template. SRC 
		       ;;is MATCH-TEMPLATE IMAGE parameter. FRAME will b-
		       ;;e the template image 
		       (with-mat ((img (clone frame)))
			 (with-mat ((src (clone frame)))
			   ;;Set template position and location parameters
			   (with-rect ((roi (rect (mem-ref rect-x :int)
						  (mem-ref rect-y :int)
						  (mem-ref rect-width :int)
						  (mem-ref rect-height :int))))
			     ;;Create template image from FRAME 
			     ;;to use in MATCH-TEMPLATE. Set to 
			     ;;FRAME
			     (copy-to (roi frame roi) frame))
			   ;;Set rectangle location parameters
			   (with-point ((point-1 (point (mem-ref rect-x :int) 
							(mem-ref rect-y :int)))
					(point-2 (point (+ (mem-ref rect-x :int) 
							   (mem-ref rect-width :int)) 
							(+ (mem-ref rect-y :int) 
							   (mem-ref rect-height :int))))) 
			     ;;Create rectangle on IMG at same 
			     ;;position as the template
			     (rectangle img point-1 point-2 color 5 4 0)
			     (imshow (aref window-name-arr 0) img))
			   ;;Set width and height of matrices 
			   ;;we will create in next step
			   (setf iwidth (+ (- (cols src) (cols frame)) 1))
			   (setf iheight (+ (- (rows src) (rows frame)) 1))
			   ;;Create an array of finalized matrices 
			   ;;to hold all of the matches. All of the
			   ;;functions with automatic GC are in the
			   ;;gc.lisp file and can be used by adding
			   ;;the 'gc' prefix to the function name.    
			   (dotimes (i 6)
			     (setf (aref arr i) (gc:mat iheight iwidth +32f+)))
			   ;;Run all versions of MATCH-TEMPLATE 
			   ;;and run NORMALIZE on each match 
			   (dotimes (i 6)
			     (match-template src frame (aref arr i) i)
			     (normalize (aref arr i) (aref arr i) 1d0 0d0 +norm-minmax+)) 
			   ;;Show template(FRAME) in a window
			   (imshow (aref window-name-arr 1) frame)
			   ;;Show matches
			   (dotimes (i 6)
			     (imshow (aref window-name-arr (+ i 2)) (aref arr i)))))
		       ;;Reset ROI
		       (copy-to (roi frame roi) frame)
		       (let ((c (wait-key 33)))
			 (when (= c 27)
			   (destroy-all-windows)
			   (return))))))))))))))


Example 2:

(defun match-template-example-2 (&optional (cam *camera-index*) 
				   (width *default-width*)
				   (height *default-height*))

  "This is just like the MATCH-TEMPLATE-EXAMPLE-1 but just shows just one 
   MATCH-TEMPLATE method result in a window, +TM-CCOEFF-NORMED+. I wrote 
   this example, because in the MATCH-TEMPLATE-EXAMPLE-1 this block of co-
   de takes about half a second to run:

	(dotimes (i 6)
	  (match-template src frame (aref arr i) i)
	  (normalize (aref arr i) (aref arr i) 1d0 0d0 +norm-minmax+))

   The normal frame rate for videos is 0.033333333 second per frame. 
   This example should fill in any cracks left by the other one."

  (with-captured-camera (cap cam :width width :height height)
    ;;Create array of window names
    (let* ((window-name-arr (make-array 3 :initial-contents 
					(list "IMG - MATCH-TEMPLATE-EXAMPLE-2"
					      "FRAME - MATCH-TEMPLATE-EXAMPLE-2"
					      "SQDIFF - MATCH-TEMPLATE-EXAMPLE-2")))
	   ;;Initialize size parameters 
	   ;;for the matches
           (iwidth 0)
	   (iheight 0)
           (n 10))      
      ;;Create windows
      (with-named-window ((aref window-name-arr 0) +window-normal+)
	(with-named-window ((aref window-name-arr 1) +window-normal+)
	  (with-named-window ((aref window-name-arr 2) +window-autosize+)   
	    ;;Move windows to specified locations     
	    (move-window (aref window-name-arr 0) 253 0)
	    (move-window (aref window-name-arr 1) 253 400)
	    (move-window (aref window-name-arr 2) 670 150)
	    ;;Allocate int pointers for the trackbars to 
	    ;;adjust which will set the template image a-
	    ;;nd the guiding rectangle location and boun-
	    ;;daries
	    (with-object ((rect-x (alloc :int '(0))))
	      (with-object ((rect-y (alloc :int '(0))))
		(with-object ((rect-width (alloc :int (list (round (/ width n))))))
		  (with-object ((rect-height (alloc :int (list (round (/ height n))))))
		    ;;Create trackbars used to adjust template and rectangle position
		    (create-trackbar "RECT-X" (aref window-name-arr 1) rect-x width)
		    (create-trackbar "RECT-Y" (aref window-name-arr 1) rect-y height)
		    (create-trackbar "RECT-WIDTH" (aref window-name-arr 1) rect-width 
				     width)
		    (create-trackbar "RECT-HEIGHT" (aref window-name-arr 1) rect-height 
				     height)
		    (with-mat ((frame (mat)))
		      (with-rect ((roi (rect 0 0 (cols frame) (rows frame))))
			;;Set rectangle color
			(with-scalar ((color (scalar 0 255 0)))
			  (loop
			     ;;Set camera feed to FRAME
			     (read cap frame)
			     ;;Print location and size of the 
			     ;;template used to do the matchi-
			     ;;ng and the rectangle
			     (format t "RECT-X: ~a~%~%" (mem-ref rect-x :int))
			     (format t "RECT-Y: ~a~%~%" (mem-ref rect-y :int))
			     (format t "RECT-WIDTH: ~a~%~%" (mem-ref rect-width :int))
			     (format t "RECT-HEIGHT: ~a~%~%" (mem-ref rect-height :int))
			     ;;Instantiate logic used to move the 
			     ;;template and the rectangle as one
			     (if (< (mem-ref rect-x :int) (round (/ (mem-ref rect-width :int) 128))) 
				 (setf (mem-ref rect-x :int) 1))
			     (if (> (mem-ref rect-x :int) 
				    (- (cols frame) (mem-ref rect-width :int))) 
				 (setf (mem-ref rect-x :int) 
				       (- (cols frame) (mem-ref rect-width :int))))
			     (if (< (mem-ref rect-y :int) (round (/ (mem-ref rect-height :int) 128))) 
				 (setf (mem-ref rect-y :int) 1))
			     (if (> (mem-ref rect-y :int) 
				    (- (rows frame) (mem-ref rect-height :int))) 
				 (setf (mem-ref rect-y :int) 
				       (- (rows frame) (mem-ref rect-height :int))))
			     (if (< (mem-ref rect-width :int) 1) 
				 (setf (mem-ref rect-width :int) 1))
			     (if (< (mem-ref rect-height :int) 1) 
				 (setf (mem-ref rect-height :int) 1))
			     ;;Create 2 copies of FRAME, IMG will be where the 
			     ;;rectangle is moved to choose the template. SRC 
			     ;;is MATCH-TEMPLATE IMAGE parameter. FRAME will b-
			     ;;Set template position and location parameters
			     (with-mat ((img (clone frame)))
			       (with-mat ((src (clone frame)))
				 (with-rect ((roi (rect (mem-ref rect-x :int)
							(mem-ref rect-y :int)
							(mem-ref rect-width :int)
							(mem-ref rect-height :int))))
				   ;;Create template image from FRAME 
				   ;;to use in MATCH-TEMPLATE. Set to 
				   ;;FRAME
				   (copy-to (roi frame roi) frame))
				 ;;Set rectangle location parameters
				 (with-point ((point-1 (point (mem-ref rect-x :int) 
							      (mem-ref rect-y :int)))
					      (point-2 (point (+ (mem-ref rect-x :int) 
								 (mem-ref rect-width :int)) 
							      (+ (mem-ref rect-y :int) 
								 (mem-ref rect-height :int))))) 
				   ;;Create rectangle on IMG at same 
				   ;;position as the template
				   (rectangle img point-1 point-2 color 5 4 0)
				   (imshow (aref window-name-arr 0) img))
				 ;;Set width and height of matrices 
				 ;;we will create in next step
				 (setf iwidth (+ (- (cols src) (cols frame)) 1))
				 (setf iheight (+ (- (rows src) (rows frame)) 1))
				 ;;Create  matrix to hold all of the matches
				 (with-mat ((matches (mat iheight iwidth +32f+)))
				   ;;Run MATCH-TEMPLATE on each frame of the camera 
				   ;;feed and run NORMALIZE on each match 
				   (match-template src frame matches +tm-ccoeff-normed+)
				   (normalize matches matches 1d0 0d0 +norm-minmax+)
				   ;;Show template(FRAME) in a window
				   (imshow (aref window-name-arr 1) frame)
				   ;;Show matches
				   (imshow (aref window-name-arr 2) matches)
				   ;;Reset ROI
				   (copy-to (roi frame roi) frame))
				 (let ((c (wait-key 33)))
				   (when (= c 27)
				     (return)))))))))))))))))))

========================================================================================================================================
#HIGHGUI - #USER INTERFACE
========================================================================================================================================

========================================================================================================================================
#CREATE-TRACKBAR
========================================================================================================================================

Creates a trackbar and attaches it to the specified window.

C++: int createTrackbar(const string& trackbarname, const string& winname, int* value, int count, TrackbarCallback onChange=0, 
                        void* userdata=0)

LISP-CV:  (CREATE-TRACKBAR (TRACKBARNAME :STRING) (WINNAME :STRING) (VALUE :POINTER) (COUNT :INT) &OPTIONAL 
                          ((ON-CHANGE TRACKBAR-CALLBACK) (CFFI::NULL-POINTER)) ((USERDATA :POINTER) (CFFI::NULL-POINTER))) => :INT

    
    Parameters:	

        TRACKBARNAME - Name of the created trackbar

        WINNAME - Name of the window that will be used as a parent of the created trackbar.

        VALUE - Optional pointer to an integer variable whose value reflects the position of the slider. 
                Upon creation, the slider position is defined by this variable.

        COUNT - Maximal position of the slider. The minimal position is always 0.

        ON-CHANGE - Pointer to the function to be called every time the slider changes position. This 
                    function should be prototyped as in the below example, where the first parameter 
                    is the trackbar position and the second parameter is the user data (see the next 
                    parameter). If the callback is the NULL pointer, no callbacks are called, but only 
                    value is updated.

        USERDATA - User data that is passed as is to the callback. It can be used to handle trackbar 
                   events without using global variables.


The function CREATE-TRACKBAR creates a trackbar (a slider or range control) with the specified name
and range, assigns a variable value to be a position synchronized with the trackbar and specifies the 
callback function onChange to be called on the trackbar position change. The created trackbar is displayed 
in the specified window winname.

Note: (Qt Backend Only) WINNAME can be empty (or NIL) if the trackbar should be attached to the control panel.


Example:


;; a callback function called by the CREATE-TRACKBAR
;; ON-CHANGE parameter...a HELLO-WORLD function.

(defcallback hello-world-brightness :void ((pos :int) (ptr :pointer))
  (format t "Hello World!~%~%~a~a~%~%" (mem-aref ptr :string 0) pos))

;; another HELLO-WORLD callback function
(defcallback hello-world-contrast :void ((pos :int) (ptr :pointer))
  (format t "Hello World!~%~%~a~a~%~%" (mem-aref ptr :string 0) pos))


(defun create-trackbar-example (filename)
  (let ((window-name "Adjust brightness and contrast by moving the sliders.")
	(brightness 0)
	(contrast 0))
    (with-named-window (window-name +window-autosize+)
      (move-window window-name 759 175)
      ;; allocate two :int pointers that trackbar can adjust
      (with-object ((slider-1-value (alloc :int '(50)))
		    (slider-2-value (alloc :int '(50)))
		    ;; data to be passed to HELLO-WORLD-BRIGHTNESS callback function
		    (userdata-1 (alloc :string "Brightness =  "))
		    ;; data to be passed to HELLO-WORLD-CONTRAST callback function
		    (userdata-2 (alloc :string "Contrast = ")))
	(loop
	   ;; read in image supplied by filename parameter
	   (with-mat ((src (imread filename 1)))
	     (if (empty src) 
		 (return-from create-trackbar-example
		   (format t "Image not loaded")))
	     ;; Clone the source image to dest
	     (with-mat  ((dest (clone src)))
	       ;; create Trackbar with name, 'Brightness'
	       (create-trackbar "Brightness" window-name slider-1-value 100
				;; pointer to a callback function to be called every 
				;; time the trackbar slider changes position 
				(callback hello-world-brightness) 
				;; user data that is passed to 
				;; the callback function           
				userdata-1)
	       ;; create trackbar with name, 'Contrast'
	       (create-trackbar  "Contrast" window-name slider-2-value 100
				 ;; again,a callback function pointer 
				 (callback hello-world-contrast) 
				 ;; user data
				 userdata-2)
	       ;; when the top trackbar is moved, adjust brightness variable
	       (setf brightness (- (mem-ref slider-1-value :int) 50))
	       ;; when the bottom Trackbar is moved, adjust contrast variable
	       (setf contrast (/ (mem-ref slider-2-value :int) 50))
	       ;; apply brightness and contrast settings to the destination image
	       (convert-to src dest -1 (coerce contrast 'double-float)  
			   (coerce brightness 'double-float))
	       ;; show adjusted image in a window
	       (imshow window-name dest)
	       (let ((c (wait-key 33)))
		 (when (= c 27)
		   (return))))))))))


========================================================================================================================================
#DESTROY-WINDOW
========================================================================================================================================

Destroys a window.


C++: void destroyWindow(const string& winname)

LISP-CV: (DESTROY-WINDOW (WINNAME :STRING)) => :VOID


    Parameters:	WINNAME - Name of the window to be destroyed.


The function DESTROY-WINDOW destroys the window with the given name.


Example:

(defun destroy-window-example ()

  "Creates a window. Window will be closed 
   by DESTROY-WINDOW when it is active and
   any key is pressed."

  (let* ((window-name "DESTROY-WINDOW Example"))
    (named-window window-name +window-normal+)
    (loop while (not (= (wait-key 0) 27)))
    (destroy-window window-name)))

========================================================================================================================================
#DESTROY-ALL-WINDOWS
========================================================================================================================================

Destroys all of the HighGUI windows.

C++: void destroyAllWindows()

LISP-CV: (DESTROY-ALL-WINDOWS) => :VOID


The function DESTROY-ALL-WINDOWS destroys all of the opened HighGUI windows.


(defun destroy-all-windows-example ()

  "In this example we create
 12 windows and DESTROY THEM!!!"

  (let* ((window-name-arr 
	  (make-array 12 :initial-contents 

		      (list
		       "WINDOW 1 - DESTROY-ALL-WINDOWS Example"
		       "WINDOW 2 - DESTROY-ALL-WINDOWS Example"
		       "WINDOW 3 - DESTROY-ALL-WINDOWS Example"
		       "WINDOW 4 - DESTROY-ALL-WINDOWS Example"
		       "WINDOW 5 - DESTROY-ALL-WINDOWS Example"
		       "WINDOW 6 - DESTROY-ALL-WINDOWS Example"
		       "WINDOW 7 - DESTROY-ALL-WINDOWS Example"
		       "WINDOW 8 - DESTROY-ALL-WINDOWS Example"
		       "WINDOW 9 - DESTROY-ALL-WINDOWS Example"
		       "WINDOW 10 - DESTROY-ALL-WINDOWS Example"
		       "WINDOW 11 - DESTROY-ALL-WINDOWS Example"
		       "WINDOW 12 - DESTROY-ALL-WINDOWS Example"))))

    ;; Create 12 windows to DESTROY!!!
    (dotimes (i 12)
      (named-window (aref window-name-arr i) +window-normal+))
    ;; Move the windows to specific coordinates.
    (move-window (aref window-name-arr 0) 88 0)
    (move-window (aref window-name-arr 1) 538 0)
    (move-window (aref window-name-arr 2) 988 0)
    (move-window (aref window-name-arr 3) 1438 0)
    (move-window (aref window-name-arr 4) 88 368)
    (move-window (aref window-name-arr 5) 538 368)
    (move-window (aref window-name-arr 6) 988 368)
    (move-window (aref window-name-arr 7) 1438 368)
    (move-window (aref window-name-arr 8) 88 708)
    (move-window (aref window-name-arr 9) 538 708)
    (move-window (aref window-name-arr 10) 988 708)
    (move-window (aref window-name-arr 11) 1438 708)
    ;; When you press the escape key, you will...
    ;; DESTROY 12 WINDOWS!!!
    (loop while (not (= (wait-key 0) 27)))
    (destroy-all-windows)))
    
========================================================================================================================================
#GET-TRACKBAR-POS
========================================================================================================================================

Returns the trackbar position.

C++: int getTrackbarPos(const String& trackbarname, const String& winname)

LISP-CV: (GET-TRACKBAR-POS (TRACKBARNAME :STRING) (WINNAME :STRING)) => :INT


    Parameters:	

        TRACKBARNAME - Name of the trackbar.
        
        WINNAME - Name of the window that is the parent of the trackbar.
        

The function returns the current position of the specified trackbar.


(defun get-trackbar-pos-example (filename)
  (let ((window-name "See trackbars curre")
	(text 0)
	(pos 0)
        (scale 0.70d0)
	(thickness 1))
    ;Read in image 
    (with-mat ((img (imread filename 1)))
      (if (empty img) 
	  (return-from get-trackbar-pos-example
	    (format t "Image not loaded")))
      (with-named-window (window-name +window-autosize+)
	(move-window window-name (cols img) 0)
	(with-point ((org (point 0 25)))
	  (with-scalar ((color (scalar 255 255 255)))
	    (with-object ((unused-val (alloc :int 0)))
	      (loop
		 (with-mat ((clone (clone img)))
		   (create-trackbar "Position" window-name unused-val 100)
		   ;Get trackbar position and 
		   ;print it to window
		   (setf pos (get-trackbar-pos "Position" window-name))
		   (setf text (concatenate 'string "Current trackbar position: " 
					   (write-to-string pos)))
		   (put-text clone text org +font-hershey-triplex+
			     scale  color thickness +aa+)
		   (imshow window-name clone))
		 (let ((c (wait-key 33)))
		   (when (= c 27)
		     (return)))))))))))

    
========================================================================================================================================
#IMSHOW
========================================================================================================================================

Displays an image in the specified window.

C++: void imshow(const string& winname, InputArray mat)

LISP-CV: (IMSHOW (WINNAME :STRING) (MAT MAT)) => :void

    Parameters:	

        WINNAME - Name of the window.

        MAT - Image to be shown.


The function IMSHOW displays an image in the specified window. If the window was created with the 
+WINDOW-AUTOSIZE+ flag, the image is shown with its original size. Otherwise, the image is scaled 
to fit the window. The function may scale the image, depending on its depth:

        If the image is 8-bit unsigned, it is displayed as is.

        If the image is 16-bit unsigned or 32-bit integer, the pixels are divided by 256. That is, 
        the value range [0,255*256] is mapped to [0,255].

        If the image is 32-bit floating-point, the pixel values are multiplied by 255. That is, the
        value range [0,1] is mapped to [0,255].



(defun imshow-example (filename)

  "Opens the image FILENAME and shows it 
   in a window with IMSHOW."

  (with-mat ((image (imread filename 1)))
    (if (empty image) 
	(return-from imshow-example 
	  (format t "Image not loaded")))
    (let ((window-name "IMSHOW Example"))
      (with-named-window (window-name +window-normal+)
	(move-window window-name 759 175)
	(imshow window-name image)
	(loop
	   (let ((c (wait-key 33)))
	     (when (= c 27)
	       (return))))))))

========================================================================================================================================
#MOVE-WINDOW
========================================================================================================================================

Moves window to the specified position

C++: void moveWindow(const string& winname, int x, int y)

LISP-CV: (MOVE-WINDOW (WINNAME :STRING) (X :INT) (Y :INT)) => VOID


    Parameters:	

        WINNAME - Window name

        X - The new x-coordinate of the window

        Y - The new y-coordinate of the window


(defun move-window-example ()

  "Creates a window then uses MOVE-WINDOW 
   to move the window to (x, y) position 
   (720, 175)."

  (let* ((window-name "MOVE-WINDOW Example")))
    (named-window window-name +window-normal+)
    (move-window window-name 759 175)
    (loop while (not (= (wait-key 0) 27)))
    (destroy-window window-name))

========================================================================================================================================
#NAMED-WINDOW
========================================================================================================================================

Creates a window.


C++: void namedWindow(const string& winname, int flags=WINDOW_AUTOSIZE)

LISP-CV: (NAMED-WINDOW (WINNAME :STRING) &OPTIONAL ((FLAGS :INT) +WINDOW-AUTOSIZE+)) => :VOID


    Parameters:	

        NAME - Name of the window in the window caption that may be used as a window identifier.

        FLAGS -

        Flags of the window. The supported flags are:

            +WINDOW-NORMAL+ If this is set, the user can resize the window (no constraint).

            +WINDOW-AUTOSIZE+ If this is set, the window size is automatically adjusted to fit the 
                              displayed image (see (IMSHOW) ), and you cannot change the window size 
                              manually.

            +WINDOW-OPENGL+ If this is set, the window will be created with OpenGL support.


The function NAMED-WINDOW creates a window that can be used as a placeholder for images and trackbars. 
Created windows are referred to by their names.

If a window with the same name already exists, the function does nothing.

You can call (DESTROY-WINDOW) or (DESTROY-ALL-WINDOWS) to close the window and de-allocate any associated 
memory usage. For a simple program, you do not really have to call these functions because all the resources 
and windows of the application are closed automatically by the operating system upon exit.


Note:

Qt backend supports additional flags:

        +WINDOW-NORMAL+ or +WINDOW-AUTOSIZE+: +WINDOW-NORMAL+ enables you to resize the window, whereas 
        +WINDOW-AUTOSIZE adjusts automatically the window size to fit the displayed image (see (IMSHOW) ), 
        and you cannot change the window size manually.

        +WINDOW-FREERATIO+ or +WINDOW-KEEPRATIO+: +WINDOW-FREERATIO+ adjusts the image with no respect to 
        its ratio, whereas +WINDOW-KEEPRATIO keeps the image ratio. 
        
        +GUI-NORMAL+ or +GUI-EXPANDED+: +GUI-NORMAL+ is the old way to draw the window without statusbar 
        and toolbar, whereas +GUI-EXPANDED+ is a new enhanced GUI.

By default, (= FLAGS (LOGIOR +WINDOW-AUTOSIZE+  +WINDOW-KEEPRATIO+  +GUI-EXPANDED+))



(defun named-window-example ()

  "Creates a named window with NAMED-WINDOW. Window 
   will close when it is selected and any key is pr-
   essed."

  (let* ((window-name "NAMED-WINDOW Example"))
    (named-window window-name +window-normal+)
    (loop while (not (= (wait-key 0) 27)))
    (destroy-window window-name)))

========================================================================================================================================
#SET-MOUSE-CALLBACK
========================================================================================================================================

Sets mouse handler for the specified window


C++: void setMouseCallback(const string& winname, MouseCallback onMouse, void* userdata=0 )

LISP-CV: (SET-MOUSE-CALLBACK (WINNAME :STRING) (ON-MOUSE MOUSE-CALLBACK) (USERDATA :VOID)) => :VOID


    Parameters:	

        WINNAME - Window name

        ONMOUSE - Mouse callback. See example below for how to use the callback.

        USERDATA - The optional parameter passed to the callback.



(defcallback call-back-func :void ((event :int)(x :int)(y :int)
                                   (flags :int)(userdata :pointer))
  ;; This callback function is called by the SET-MOUSE CALLBACK function
  ;; in the example below. The mouse handler created by SET-MOUSE CALLBACK
  ;; captures movements made by the mouse along with 3 different keypresses.
  ;; They are then processed in this function.

  (format t "Recieved ~a~%~%" (mem-aref userdata :string))

  (if (= event +event-mousemove+)
      (format t "Mouse move over the window (~a, ~a)~%~%" x y))
  (if (= event +event-lbuttondown+)
      (format t "Left button of the mouse down (~a, ~a)~%~%" x y))
  (if (= event +event-rbuttondown+)
      (format t "Right button of the mouse down (~a, ~a)~%~%" x y))
  (if (= event +event-mbuttondown+)
      (format t "Middle button of the mouse down (~a, ~a)~%~%" x y))
  (if (= event +event-lbuttonup+)
      (format t "Left button of the mouse up (~a, ~a)~%~%" x y))
  (if (= event +event-rbuttonup+)
      (format t "Right button of the mouse up (~a, ~a)~%~%" x y))
  (if (= event +event-mbuttonup+)
      (format t "Middle button of the mouse up (~a, ~a)~%~%" x y))
  (if (= event +event-lbuttondblclk+)
      (format t "Left button double-click flag triggered (~a, ~a)~%~%" x y))
  (if (= event +event-rbuttondblclk+)
      (format t "Right button double-click flag triggered (~a, ~a)~%~%" x y))
  (if (= event +event-mbuttondblclk+)
      (format t "Middle button double-click flag triggered (~a, ~a)~%~%" x y))
  (if (= flags (+ +event-flag-ctrlkey+ +event-flag-lbutton+))
      (format t "Left mouse button is clicked while pressing CTRL key (~a, ~a)~%~%" x y))
  (if (= flags (+ +event-flag-shiftkey+ +event-flag-rbutton+))
      (format t "Right mouse button is clicked while pressing SHIFT key (~a, ~a)~%~%" x y))
  (if (= flags (+ +event-flag-altkey+ +event-mousemove+))
      (format t "Mouse is moved over the window while pressing ALT key  (~a, ~a)~%~%" x y )))


(defun set-mouse-callback-example (filename)
  ;; load image
  (let ((src (imread filename 1))
	(window-name "SET-MOUSE-CALLBACK Example")
	;; Declare a userdata parameter 
	(userdata (alloc :string "USERDATA output")))
    (if (empty src) 
	(return-from set-mouse-callback-example
	  (format t "Image not loaded")))
    (named-window window-name 1)
    (move-window window-name 759 175)
    ;; Set mouse handler for the window, which passes a constant 
    ;; stream of mouse and mouse button positional data to the f-
    ;; unction above.  Also passes the contents of USERDATA to t-
    ;; he above function CALL-BACK-FUNC.
    (set-mouse-callback window-name (callback call-back-func) userdata)
    (imshow window-name src)
    (loop while (not (= (wait-key 0) 27)))
    (destroy-window window-name)
    (del-mat src)
    (free userdata)))

========================================================================================================================================
#SET-TRACKBAR-POS
========================================================================================================================================

Sets the trackbar position.

C++: void setTrackbarPos(const String& trackbarname, const String& winname, int pos)

LISP-CV: (SET-TRACKBAR-POS (TRACKBARNAME :STRING) (WINNAME :STRING) (POS :INT)) => :VOID


    Parameters:	

        TRACKBARNAME - Name of the trackbar.
        
        WINNAME - Name of the window that is the parent of trackbar.
        
        POS - New position.
        

The function sets the position of the specified trackbar in the specified window.


(defun set-trackbar-pos-example (filename)
  (let ((window-name "SET-TRACKBAR-POS Example")
	(text 0)
        (pos 0)
        (scale 0.70d0)
	(thickness 1))
    ;Read in image
    (with-mat ((img (imread filename 1)))
      (if (empty img) 
	  (return-from set-trackbar-pos-example
	    (format t "Image not loaded")))
      (with-named-window (window-name +window-autosize+)
	(move-window window-name (cols img) 0)
	(with-point ((org (point 0 25)))
	  (with-scalar ((color (scalar 255 255 255)))
	    (with-object ((unused-val (alloc :int 0)))
	      (loop
		 (with-mat ((clone (clone img)))
		   ;Create primary trackbar
		   (create-trackbar "Primary" window-name unused-val 100)
		   ;Set primary trackbar position to POS
		   (setf pos (get-trackbar-pos "Primary" window-name))
		   ;Print primary trackbar position on window
		   (setf text (concatenate 'string "Primary trackbar position: " 
					   (write-to-string pos)))
		   (put-text clone text org +font-hershey-triplex+
			     scale  color thickness +aa+)
		   ;Create 4 slave trackbars
		   (create-trackbar "Slave 1" window-name unused-val 100)
		   (create-trackbar "Slave 2" window-name unused-val 100)
		   (create-trackbar "Slave 3" window-name unused-val 100)
		   (create-trackbar "Slave 4" window-name unused-val 100)
		   ;Set slave trackbars position to POS
		   (set-trackbar-pos "Slave 1" window-name pos)
		   (set-trackbar-pos "Slave 2" window-name pos)
		   (set-trackbar-pos "Slave 3" window-name pos)
		   (set-trackbar-pos "Slave 4" window-name pos)
		   (imshow window-name clone))
		 (let ((c (wait-key 33)))
		   (when (= c 27)
		     (return)))))))))))

========================================================================================================================================
#START-WINDOW-THREAD
========================================================================================================================================


Creates a separate thread that will manage window events.


C++: int startWindowThread()

LISP-CV: (START-WINDOW-THREAD) => :INT


(defun start-window-thread-example ()

  (let* ((window-name "START-WINDOW-THREAD Example"))
    ;Start the window thread
    (start-window-thread)
    ;Open a window
    (named-window window-name +window-normal+)
    ;Wait until a key gets pressed inside the window
    (loop while (not (= (wait-key 0) 27)))
    ;Close the window
    (destroy-window window-name)))

========================================================================================================================================
#WAIT-KEY
========================================================================================================================================

Waits for a pressed key.


C++: int waitKey(int delay=0)

LISP-CV: (WAIT-KEY &OPTIONAL ((DELAY :INT) 0)) => :INT


    Parameters:	DELAY - Delay in milliseconds. 0 is the special value that means “forever”.


The function WAIT-KEY waits for a key event infinitely when (<= DELAY 0), for DELAY milliseconds when 
it is positive. Since the OS has a minimum time between switching threads, the function will not wait 
exactly delay ms, it will wait at least delay ms, depending on what else is running on your computer 
at that time. It returns the code of the pressed key or -1 if no key was pressed before the specified 
time had elapsed.

Note:

This function is the only method in HighGUI that can fetch and handle events, so it needs to be called 
periodically for normal event processing unless HighGUI is used within an environment that takes care 
of event processing.

Note:

The function only works if there is at least one HighGUI window created and the window is active. If 
there are several HighGUI windows, any of them can be active.


(defun wait-key-example ()

  "After window is created with NAMED-WINDOW 
   and moved with MOVE-WINDOW this function 
   waits until a keypress(ESC) is detected w-
   ith the function WAIT-KEY until it runs t-
   he function DESTROY-WINDOW. Note: window 
   must be active before the key press will 
   be detected."

  (let* ((window-name "WAIT-KEY Example"))
    (named-window window-name +window-normal+)
    (move-window window-name 759 175)
    (loop while (not (= (wait-key 0) 27)))
    (destroy-window window-name)))

========================================================================================================================================
#HIGHGUI - #READING AND WRITING IMAGES AND VIDEO
========================================================================================================================================

========================================================================================================================================
#IMDECODE
========================================================================================================================================

Reads an image from a buffer in memory.

C++: Mat imdecode(InputArray buf, int flags)

LISP-CV: (IMDECODE (BUF VECTOR-UCHAR) (FLAGS :INT)) => MAT


    Parameters:	

        BUF - Input array or vector of bytes.

        FLAGS - The same flags as in (IMREAD).


The function reads an image from the specified buffer in the memory. If the buffer is too short or 
contains invalid data, the empty matrix/image is returned.

See (IMREAD) for the list of supported formats and flags description.

Note: In the case of color images, the decoded images will have the channels stored in B G R order.


Example:

(defun imdecode-example (&optional 
			   (cam *camera-index*) 
			   (width *default-width*)
			   (height *default-height*))

  "In a loop, a frame of the camera feed is encoded with IMENCODE and 
   then decoded with IMDECODE and shown in a window. You can move the 
   trackbar to choose the flag specifying decoded image's color type ."

  (with-captured-camera (cap cam :width width :height height)
    (if (not (is-opened cap)) 
	(return-from imdecode-example 
	  (format t "Cannot open the video camera")))      
    (let ((window-name "IMDECODE Example")
          (text 0)
          (scale 0.785d0)
          (thickness 1)
          (line-type 8))
      (with-named-window (window-name +window-autosize+)
	(move-window window-name 640 175)
	(with-object ((color-type (alloc :int 1)))
	  (create-trackbar "Color Type" window-name color-type 2)
	  (with-mat ((frame (mat)))
	    (with-vector-uchar ((buf (vector-uchar)))
	      (with-vector-int ((params (vector-int (list +imwrite-jpeg-quality+ 100))))
		(with-point ((org (point 7 35)))
		  (with-scalar ((blue (bgr 255 0 0)))
		    (loop
		       (read cap frame)
		       (imencode ".jpg" frame buf params)
		       (cond ((eq (@ color-type :int) 0)
			      (setf text (cat "Current Color Type is: " "+LOAD-IMAGE-GRAYSCALE")))
			     ((eq (@ color-type :int) 1)
			      (setf text (cat "Current Color Type is: " "+LOAD-IMAGE-COLOR")))
			     ((eq (@ color-type :int) 2)
			      (setf text (cat "Current Color Type is: " "+LOAD-IMAGE-ANYDEPTH"))))
		       (with-mat ((decoded-image (imdecode buf (@ color-type :int))))
			 (put-text decoded-image text org +font-hershey-duplex+ scale 
				   blue thickness line-type)
			 (imshow window-name decoded-image))
		       (let ((c (wait-key 33)))
			 (when (= c 27)
			   (return))))))))))))))

========================================================================================================================================
#IMENCODE
========================================================================================================================================

Encodes an image into a memory buffer.

C++: bool imencode(const String& ext, InputArray img, vector<uchar>& buf, const vector<int>& params=vector<int>())

LISP-CV: (IMENCODE (EXT :STRING) (IMG MAT) (BUF VECTOR-UCHAR) ((PARAMS VECTOR-INT) (MAKE-VECTOR-INT))) => :BOOLEAN

    Parameters:	

        EXT - File extension that defines the output format.

        IMG - Image to be written.

        BUF - Output buffer resized to fit the compressed image.

        PARAMS - Format-specific parameters. See (IMWRITE).

The function compresses the image and stores it in the memory buffer that is resized to fit the result. 
See (IMWRITE) for the list of supported formats and flags description.


Example:

;;Functions in a separate thread will access 
;;these variables so they need to be global.
(defparameter window-name 0)
(defparameter output-file-path 0)
(defparameter vector-of-params 0)
(defparameter frame 0)
(defparameter text-1 0)
(defparameter text-2 0)
(defparameter timer (alloc :int 0))

(defun imencode-example (output-folder filename &optional 
						  (cam *camera-index*) 
						  (width *default-width*)
						  (height *default-height*))

  "This example allows you to capture images from the camera feed and 
   save them to a directory. Moving the 'J/W/PN/PX' Trackbar allows you 
   to choose between any one of the following four file types to save your 
   image as, JPG, WEBP, PNG, and PGM. Once you have chosen the file type for 
   your image, you can move one of the four trackbars that are underneath the 
   'J/W/PN/PX' trackbar to set the quality/compression level of the image. You 
   can toggle the bottom trackbar to disable the text before writing your image. 
   Tap the 'w' key to write your image to disk. Slide the 'Timer' trackbar from 
   0 to 15 if you would like to change the time(seconds) the program waits before 
   capturing an image."

  (with-captured-camera (cap cam :width width :height height)
    (if (not (is-opened cap)) 
	(return-from imencode-example 
	  (format t "Cannot open the video camera")))      
    (let ((params 0)
          (ext 0)
          (scale 1.15d0)
          (thickness 1)
          (line-type 8)
	  (n nil))
      (setf window-name "IMENCODE Example")
      (with-named-window (window-name +window-autosize+)
	(move-window window-name 640 175)
        ;;Create values the trackbars can adjust.
	(with-object ((jpeg-qual (alloc :int 95))
		      (webp-qual (alloc :int 100))
		      (png-comp (alloc :int 3))
		      (pxm-binary (alloc :int 1))
		      (mode (alloc :int 0))
                      (toggle-text (alloc :int 1)))
	  (create-trackbar "J/W/PN/PX" window-name mode 3)
	  (create-trackbar "JPG Qual." window-name jpeg-qual 99)
	  (create-trackbar "WEBP Qual." window-name webp-qual 99)
	  (create-trackbar "PNG Comp." window-name png-comp 8)
	  (create-trackbar "PXM bin." window-name pxm-binary 1)
	  (create-trackbar "Togg, Text" window-name toggle-text 1)
          (create-trackbar "Timer" window-name timer 15)
	  (setf frame (mat))
          ;;Create origin parameter for PUT-TEXT.
	  (with-point ((org (point 7 35)))
            ;;Create color parameter for PUT-TEXT.
	    (with-scalar ((green (rgb 0 255 0)))
	      (loop
		 (read cap frame)
                 ;;Create buffer to hold the encoded image.
		 (with-vector-uchar ((buf (vector-uchar)))
		   
                   ;;Create the format parameters for IMENCODE 
                   ;;and IMWRITE(based on top tackbar position).
		   (cond ((eq (@ mode :int) 0)
			  (setf params (list +imwrite-jpeg-quality+ 
					     (@ jpeg-qual :int)))
			  (setf ext ".jpg"))
			 ((eq (@ mode :int) 1)
			  (setf params (list +imwrite-webp-quality+ 
					     (@ webp-qual :int)))
			  (setf ext ".webp"))
			 ((eq (@ mode :int) 2)
			  (setf params (list +imwrite-png-compression+ 
					     (@ png-comp :int)))
			  (setf ext ".png"))
			 ((eq (@ mode :int) 3)
			  (setf params (list +imwrite-pxm-binary+ 
					     (@ pxm-binary :int)))
			  (setf ext ".pgm")))
                   ;;Push the format parameters into a vector.
		   (setf vector-of-params (vector-int params))
                   ;;Encode a frame of the camera feed into BUF.
		   (imencode ext frame buf vector-of-params)
                   ;;Create text string for PUT-TEXT.
		   (setf text-1 (cat "Size of Compressed Image: " 
				     (write-to-string (length buf)))) ;Find length of 
		   (if (eq (@ toggle-text :int) 1)                    ;encoded image
                       ;;Print size of BUF to screen.
		       (put-text frame text-1 org +font-hershey-script-simplex+ scale 
				 green thickness line-type))
                   ;;If 'Esc' is pressed, 
                   ;;then, exit program.
		   (let ((c (wait-key 33)))
		     (if (eq c 27)
			 (return-from imencode-example 
			   (progn (format t "~%Break!~%") 
				  (del-mat frame) 
				  (del-vector-int vector-of-params) 
				  (free timer) (setf *file-number* 0))))
		     ;;If 'w' is pressed, 
		     ;;then, write image.
		     (if (eq c 119) 
			 (progn
			   (setf text-2 (cat "Waiting"))
			   (display-overlay window-name text-2 (* (@ timer :int) 1000))
			   (setf output-file-path (cat output-folder filename 
						       (write-to-string 
							*file-number*) ext))
			   (incf *file-number*)
                           ;;Create separate thread so SLEEP 
                           ;;function won't pause the program.
			   (setf n (bt:make-thread (lambda ()  
						     (sleep (@ timer :int))
						     (imwrite output-file-path 
							      frame vector-of-params)
						     (setf text-1 (cat "Wrote " 
								       (write-to-string 
									output-file-path)))
						     (display-overlay window-name text-1 2500))))))))
		 (imshow window-name frame)
		 (when nil
		   (return))))))))))

========================================================================================================================================
#IMREAD
========================================================================================================================================

Loads an image from a file.

C++: Mat imread(const string& filename, int flags=1)

LISP-CV: (IMREAD (FILENAME :STRING) &OPTIONAL ((FLAGS :INT) +LOAD-IMAGE-COLOR+)) => MAT


    Parameters:	

        FILENAME - Name of file to be loaded.

        FLAGS -

        Flags specifying the color type of a loaded image:

            +LOAD-IMAGE-ANYDEPTH+ - If set, return 16-bit/32-bit image when the input has
                                    the corresponding depth, otherwise convert it to 8-bit.

            +LOAD-IMAGE-COLOR+ - If set, always convert image to the color one.

            +LOAD-IMAGE-GRAYSCALE+ - If set, always convert image to the grayscale one.


         For example:

            (> FLAGS 0) Return a 3-channel color image.

                Note:

                In the current implementation the alpha channel, if any, is stripped from
                the output image. Use negative value if you need the alpha channel.

            (= FLAGS 0) Return a grayscale image.

            (< FLAGS 0) Return the loaded image as is (with alpha channel).


The function IMREAD loads an image from the specified file and returns it. If the image cannot be 
read (because of missing file, improper permissions, unsupported or invalid format), the function 
returns an empty matrix e.g. (EQ (CFFI::NULL-POINTER-P (DATA MATRIX)) T). Currently, the following file 
formats are supported:

        Windows bitmaps - *.bmp, *.dib (always supported)

        JPEG files - *.jpeg, *.jpg, *.jpe (see the Notes section)

        JPEG 2000 files - *.jp2 (see the Notes section)

        Portable Network Graphics - *.png (see the Notes section)

        Portable image format - *.pbm, *.pgm, *.ppm (always supported)

        Sun rasters - *.sr, *.ras (always supported)

        TIFF files - *.tiff, *.tif (see the Notes section)

Note:

    The function determines the type of an image by the content, not by the file extension.

    On Microsoft Windows* OS and MacOSX*, the codecs shipped with an LISP-CV image (libjpeg
    , libpng, libtiff, and libjasper) are used by default. So, LISP-CV can always read JPEG-
    s, PNGs, and TIFFs. On MacOSX, there is also an option to use native MacOSX image readers. But 
    beware that currently these native image loaders give images with different pixel values becaus-
    e of the color management embedded into MacOSX. 

    On Linux*, BSD flavors and other Unix-like open-source operating systems, LISP-CV looks
    for codecs supplied with an OS image. Install the relevant packages (do not forget the developm-
    ent files, for example, “libjpeg-dev”, in Debian* and Ubuntu*) to get the codec support or turn 
    on the OPENCV_BUILD_3RDPARTY_LIBS flag in CMake.

Note:

In the case of color images, the decoded images will have the channels stored in B G R order.


Examples:


Example using manual memory management:

(defun imread-example-1 (filename)

  "Open the image FILENAME with IMREAD 
   and show it in a window. This examp-
   le uses manual memory management"

  (let* ((image (imread filename 1))
	 (window-name "IMREAD Example 1"))
    (if (empty image) 
	(return-from imread-example-1 
	  (format t "Image not loaded")))
    (with-named-window (window-name +window-normal+)
      (move-window window-name 759 175)
      (imshow window-name image)
      (loop
	 (let ((c (wait-key 33)))
	   (when (= c 27)
	     (del-mat image)
	     (return)))))))


Example using a WITH-* macrs for memory/window managemant:

(defun imread-example-2 (filename)

  "Open the image FILENAME with IMREAD 
   and show it in a window. This examp-
   le uses a with-* macro for memory m-
   anagement."

  (let ((window-name "IMREAD Example 2"))
    (with-named-window (window-name +window-normal+)
      (move-window window-name 759 175)
      (with-mat ((image (imread filename 1)))
	(if (empty image) 
	    (return-from imread-example-2 
	      (format t "Image not loaded")))
	(imshow window-name image)
	(loop
	   (let ((c (wait-key 33)))
	     (when (= c 27)
	       (return))))))))


Example using TG finalizers for memory management:

(defun imread-example-3 (filename)

  "Open the image FILENAME with IMREAD 
   and show it in a window. This examp-
   le uses a TG finalizer for memory m-
   anagement"

  (let* ((image (gc:imread filename 1))
	 (window-name "IMREAD Example 3"))
    (if (empty image) 
	(return-from imread-example-3 
	  (format t "Image not loaded")))
    (with-named-window (window-name +window-normal+)
      (move-window window-name 759 175)
      (imshow window-name image)
      (loop
	 (let ((c (wait-key 33)))
	   (when (= c 27)
	     (return)))))))

========================================================================================================================================
#IMWRITE
========================================================================================================================================

Saves an image to a specified file.

C++: bool imwrite(const string& filename, InputArray img, const vector<int>& params=vector<int>() )

LISP-CV: (IMWRITE (FILENAME :STRING) (IMG MAT) ((PARAMS VECTOR-INT) (VECTOR-INT))) => :BOOLEAN

    Parameters:	

        FILENAME - Name of the file.

        IMAGE - Image to be saved.

        PARAMS -

        Format-specific save parameters encoded as pairs PARAM-ID-1, PARAM-VALUE-1, PARAM-ID-2, 
        PARAM-VALUE-2, ... . The following parameters are currently supported:

            For JPEG, it can be a quality (+IMWRITE-JPEG-QUALITY+) from 0 to 100 (the higher is the 
            better). Default value is 95.

            For PNG, it can be the compression level (+IMWRITE-PNG-COMPRESSION+) from 0 to 9. A higher 
            value means a smaller size and longer compression time. Default value is 3.

            For PPM, PGM, or PBM, it can be a binary format flag (+IMWRITE-PXM-BINARY+ ), 0 or 1. 
            Default value is 1.

The function IMWRITE saves the image to the specified file. The image format is chosen based on the 
filename extension (see (IMREAD) for the list of extensions). Only 8-bit (or 16-bit unsigned (+16U+) 
in case of PNG, JPEG 2000, and TIFF) single-channel or 3-channel (with ‘BGR’ channel order) images 
can be saved using this function. If the format, depth or channel order is different, use (CONVERT-TO), 
and (CVT-COLOR) to convert it before saving. Or, use the universal XML I/O functions to save the image 
to XML or YAML format.

It is possible to store PNG images with an alpha channel using this function. To do this, create 8-bit 
(or 16-bit) 4-channel image BGRA, where the alpha channel goes last. Fully transparent pixels should 
have alpha set to 0, fully opaque pixels should have alpha set to 255/65535. 


Examples:

Default example:

Usage: (IMWRITE-EXAMPLE "/MY-PIC.JPG" "/HOME/USERS/OUT-FILE.JPG")

(defun imwrite-example (filename out-file)
  
  (let* ((window-name-1 "Original image - IMWRITE Example")
         (window-name-2 "Flipped image - IMWRITE Example"))
    ;;Read in image
    (with-mat ((image (imread filename 1)))
      (if (empty image) 
	  (return-from imwrite-example 
	    (format t "Image not loaded")))
      (with-named-window (window-name-1 +window-normal+)
	(with-named-window (window-name-2 +window-normal+)
	  (move-window window-name-1 533 175)
	  (move-window window-name-2 984 175)
	  ;;Show original IMAGE in window
	  (imshow window-name-1 image)
	  ;;Flip IMAGE around the x-axis
	  (flip image image -1)
	  ;;Show flipped image in window
	  (imshow window-name-2 image)
	  ;;Write flipped image to filename specified 
	  ;;by the OUT-FILE parameter 
	  (imwrite out-file image 
		   (vector-int 
		    (list +imwrite-jpeg-quality+ 99)))
	  (loop 
    	     (let ((c (wait-key 33)))
	       (when (= c 27)
		 (return)))))))))


Small example program used to extract frames from the camera feed:


(defun image-extractor (&optional 
			  (cam *camera-index*) 
			  (width *default-width*)
			  (height *default-height*))

  "Extracts frames from the camera feed and saves as 
    .jpg files in the Lisp-CV Data Directory. This is 
    useful if you want to create large training sets 
    easily."

  (with-captured-camera (cap cam :width width :height height)
    (if (not (is-opened cap)) 
	(return-from image-extractor 
	  (format t "Cannot open the video camera")))      
    (let ((window-name "IMAGE-EXTRACTOR Example")
          (filename 0))
      (format t "~%Frame Size : ~ax~a~%~%" 
	      (get* cap +cap-prop-frame-width+)
	      (get* cap +cap-prop-frame-height+))
      (with-named-window (window-name +window-normal+)
	(move-window window-name 759 175)
	(with-mat ((frame (mat)))
	  (loop
	     (read cap frame)
	     (setf filename (cat *lisp-cv-data-dir* "img-" 
				 (write-to-string *file-number*) ".jpg"))
	     (incf *file-number*)
	     (imwrite filename frame)
	     (imshow window-name frame)
	     (let ((c (wait-key 33)))
	       (when (= c 27)
		 (return)))))))))

========================================================================================================================================
#VIDEO-CAPTURE
========================================================================================================================================

VIDEO-CAPTURE constructors.

Note: Both VIDEO-CAPTURE and MAKE-VIDEO-CAPTURE are provided in this library. The first, to match 
OpenCV's naming conventions, the second, to adhere to Common Lisp naming conventions. Except for 
the name, they are the same function. I use the VIDEO-CAPTURE function in the examples in this file 
because it will make them easier to compare with OpenCV examples you find online, thus making this 
library easier to learn.

C++: VideoCapture::VideoCapture()

LISP-CV: (VIDEO-CAPTURE) => VIDEO-CAPTURE

LISP-CV: (MAKE-VIDEO-CAPTURE) => VIDEO-CAPTURE

C++: VideoCapture::VideoCapture(int device)

LISP-CV: (VIDEO-CAPTURE &OPTIONAL (SRC :INT)) => VIDEO-CAPTURE

LISP-CV: (MAKE-VIDEO-CAPTURE &OPTIONAL (SRC :INT)) => VIDEO-CAPTURE

C++: VideoCapture::VideoCapture(const string& filename)

LISP-CV: (VIDEO-CAPTURE &OPTIONAL (SRC :STRING)) => VIDEO-CAPTURE

LISP-CV: (MAKE-VIDEO-CAPTURE &OPTIONAL (SRC :STRING)) => VIDEO-CAPTURE


  Parameters:	

        SRC - A device: ID of the opened video capturing device (i.e. a camera index). If there is 
                        a single camera connected, just pass 0.     

              A file name: Name of the opened video file (eg. video.avi) or image sequence (eg. 
                           img_%02d.jpg, which will read samples like img_00.jpg, img_01.jpg, 
                           img_02.jpg, ...)

  
If no arguments are provided this function creates an uninitialized VIDEO-CAPTURE object.
        

Example:

(defun video-capture-example (filename &optional 
					 (camera-index *camera-index*))

  "This example use the function VIDEO-CAPTURE to open a video 
   capturing device, supplied by the *CAMERA-INDEX* parameter. 
   The setf-able *CAMERA-INDEX* parameter defaults to 0. Then 
   the function VIDEO-CAPTURE is used to open a video file sup-
   plied by the parameter FILENAME."
  
  (with-video-capture ((camera-capture (video-capture camera-index))
		       (file-capture (video-capture filename)))
    (let ((window-name-1 "Camera Feed - VIDEO-CAPTURE Example")
	  (window-name-2 "Video file - VIDEO-CAPTURE Example"))
      (if (not (is-opened camera-capture)) 
	  (return-from video-capture-example 
	    (format t "Cannot open the video camera")))
      (if (not (is-opened file-capture)) 
	  (return-from video-capture-example 
	    (format t "Cannot open the video file")))
      (with-named-window (window-name-1 +window-normal+)
	(with-named-window (window-name-2 +window-normal+)
	  (move-window window-name-1 533 175)
	  (move-window window-name-2 984 175)
	  (with-mat ((camera-frame (mat))
		     (video-frame (mat)))
	    (loop 
	       (read camera-capture camera-frame)
	       (imshow window-name-1 camera-frame)
	       (read file-capture video-frame)
	       (imshow window-name-2 video-frame)
	       (let ((c (wait-key 33)))
		 (when (= c 27)
		   (return))))))))))

========================================================================================================================================
#VIDEO-CAPTURE-GET
========================================================================================================================================

Returns the specified VIDEO-CAPTURE property


Note: The name VIDEO-CAPTURE-GET is used in the documentation to refer to the binding for the "get" 
member of the OpenCV VideoCapture class because it is more descriptive and it is easier to search for 
in this file. The *GET method may also be used to call this binding.

Note: The name *GET is used for the method because GET is the name of a Common Lisp accessor.


C++: double VideoCapture::get(int propId)

LISP-CV: (*GET (SELF VIDEO-CAPTURE) (PROP-ID :INT))

LISP-CV: (VIDEO-CAPTURE-GET (SELF VIDEO-CAPTURE) (PROP-ID :INT))


    Parameters:	SELF - The VIDEO-CAPTURE structure. 

                PROP-ID -

       Property identifier. It can be one of the following:

            +CAP-PROP-POS-MSEC+ Current position of the video file in milliseconds or video capture 
                                time-stamp.
            +CAP-PROP-POS-FRAMES+ 0-based index of the frame to be decoded/captured next.

            +CAP-PROP-POS-AVI-RATIO+ Relative position of the video file: 0 - start of the film, 1 - 
                                     end of the film.
            +CAP-PROP-FRAME-WIDTH+ Width of the frames in the video stream.

            +CAP-PROP-FRAME-HEIGHT+ Height of the frames in the video stream.

            +CAP-PROP-FPS+ Frame rate.

            +CAP-PROP-FOUR-CC+ 4-character code of codec.

            +CAP-PROP-FRAME-COUNT+ Number of frames in the video file.

            +CAP-PROP-FORMAT+ Format of the Mat objects returned by retrieve() .

            +CAP-PROP-MODE+ Backend-specific value indicating the current capture mode.

            +CAP-PROP-BRIGHTNESS+ Brightness of the image (only for cameras).

            +CAP-PROP-CONTRAST+ Contrast of the image (only for cameras).

            +CAP-PROP-SATURATION+ Saturation of the image (only for cameras).

            +CAP-PROP-HUE+ Hue of the image (only for cameras).

            +CAP-PROP-GAIN+ Gain of the image (only for cameras).

            +CAP-PROP-EXPOSURE+ Exposure (only for cameras).

            +CAP-PROP-CONVERT-RGB+ Boolean flags indicating whether images should be converted to RGB.

            +CAP-PROP-WHITE-BALANCE+ Currently not supported

            +CAP-PROP-RECTIFICATION+ Rectification flag for stereo cameras (note: only supported by DC1394 
                                     v 2.x backend currently)

Note: When querying a property that is not supported by the backend used by the VideoCapture class <-todo,
value 0 is returned.


(defun video-capture-get-example (&optional 
				    (cam *camera-index*) 
				    (width *default-width*)
				    (height *default-height*))

  "Gets the width and height of the camera capture 
   with the method *GET and prints it."

  (with-captured-camera (cap cam :width width :height height)
    (let ((window-name "VIDEO-CAPTURE-GET Example"))
      (if (not (is-opened cap)) 
	  (return-from video-capture-get-example
	    (format t "Cannot open the video camera")))
      (set cap +cap-prop-frame-width+ width)
      (set cap +cap-prop-frame-height+ height)
      (format t "~%Frame Size : ~ax~a~%~%" 
	      (get* cap +cap-prop-frame-width+)
	      (get* cap +cap-prop-frame-height+))
      (with-named-window (window-name +window-normal+)
	(move-window window-name 759 175)
	(with-mat ((frame (mat)))
	  (loop
	     (read cap frame)
	     (imshow window-name frame)
	     (let ((c (wait-key 33)))
	       (when (= c 27)
		 (return)))))))))



========================================================================================================================================
#VIDEO-CAPTURE-GRAB
========================================================================================================================================

Grabs the next frame from video file or capturing device.

Note: The name VIDEO-CAPTURE-GRAB is used in the documentation to refer to the binding for the "grab"
member of the OpenCV VideoCapture class because it is more descriptive and it is easier to search for 
in this file. The GRAB function may also be used to call this binding.


C++: bool VideoCapture::grab()

LISP-CV: (GRAB (SELF VIDEO-CAPTURE)) => :BOOLEAN

LISP-CV: (VIDEO-CAPTURE-GRAB (SELF VIDEO-CAPTURE)) => :BOOLEAN


The functions grab the next frame from video file or camera and return true (non-zero) in the case 
of success.

The primary use of the function is in multi-camera environments, especially when the cameras do not 
have hardware synchronization. That is, you call (VIDEO-CAPTURE-GRAB) for each camera and after that 
call the slower method (VIDEO-CAPTURE-RETRIEVE) to decode and get frame from each camera. This way the 
overhead on demosaicing or motion jpeg decompression etc. is eliminated and the retrieved frames from 
different cameras will be closer in time.

Also, when a connected camera is multi-head (e.g., a stereo camera or a Kinect device), the correct way 
of retrieving data from it is to call "VIDEO-CAPTURE-GRAB" first and then call (VIDEO-CAPTURE-RETRIEVE) 
one or more times with different values of the channel parameter. See:

https://github.com/Itseez/opencv/tree/master/samples/cpp/openni_capture.cpp


Example:

See VIDEO-CAPTURE-RETRIEVE-EXAMPLE in this file.

========================================================================================================================================
#VIDEO-CAPTURE-IS-OPENED
========================================================================================================================================

Returns true if video capturing has been initialized already.


Note: The name VIDEO-CAPTURE-IS-OPENED is used in the documentation to refer to the binding for the 
"isOpened" member of the OpenCV VideoCapture class because it is more descriptive and it is easier 
to search for in this file. The IS-OPENED method may also be used to call this binding.


C++: bool VideoCapture::isOpened()

LISP-CV: (IS-OPENED (SELF VIDEO-CAPTURE)) => :BOOLEAN

LISP-CV: (VIDEO-CAPTURE-IS-OPENED (SELF VIDEO-CAPTURE)) => :BOOLEAN


Parameters:	

         SELF - The VIDEO-CAPTURE structure.


If previous call to VIDEO-CAPTURE constructor or VIDEO-CAPTURE-IS-OPENED succeeded, the function 
or method returns true.


Example: 

(defun video-capture-is-opened-example (&optional (cam 0))

  "If the previous call to VIDEO-CAPTURE constructor (e.g. 

   (VIDEO-CAPTURE CAMERA-INDEX) 
  
   in the this example) or the method IS_OPENED succeeded, 
   the method returns true. The boolean output of PRINC in 
   the IF statement in this example reflects a good or bad 
   capture. Output will likely be 'T' unless the camera is 
   unplugged. Try unplugging your camera to test it out."

  (with-video-capture ((cap (video-capture cam))) 
    (let ((window-name "VIDEO-CAPTURE-IS-OPENED Example"))
      (if (not (princ (is-opened cap))) 
	  (return-from video-capture-is-opened-example
	    (format t "~%Cannot open the video camera")))
      (with-named-window (window-name +window-normal+)
	(move-window window-name 759 175)
	(with-mat ((frame (mat)))
	  (loop
	     (read cap frame)
	     (imshow window-name frame)
     	     (let ((c (wait-key 33)))
	       (when (= c 27)
		 (return)))))))))

========================================================================================================================================
#VIDEO-CAPTURE-READ
========================================================================================================================================

Grabs, decodes and returns the next video frame.


Note: The name VIDEO-CAPTURE-READ is used in the documentation to refer to the binding for the "read" 
member of the OpenCV VideoCapture class because it is more descriptive and it is easier to search for 
in this file. The READ function may also be used to call this binding.

Note: The LISP-CV function READ overloads the Common Lisp function READ so both functions can use the 
same name. The LISP-CV function READ provides the the same functionality as the Common Lisp function 
READ and the 'read' members of OpenCV's classes. To use the Common Lisp function READ directly, while 
you are in the LISP-CV package, you need to evaluate CL:READ.


C++: bool VideoCapture::read(Mat& image)

LISP-CV: (READ (SELF VIDEO-CAPTURE) (IMAGE MAT)) => :BOOLEAN

LISP-CV: (VIDEO-CAPTURE-READ (SELF VIDEO-CAPTURE) (IMAGE MAT)) => :BOOLEAN


    Parameters:	

         SELF - The "grabbed" camera feed.

         IMAGE - The returned frame.


The methods/functions combine (VIDEO-CAPTURE-GRAB) and (VIDEO-CAPTURE-RETRIEVE) in one call. This is 
the most convenient method for reading video files or capturing data from decode and return the just 
grabbed frame. If no frames have been grabbed (if camera has been disconnected, or there are no more 
frames in video file), the methods return false and the functions return NULL pointer.


(defun video-capture-read-example (&optional (camera-index 
					      *camera-index*))

  (with-video-capture ((cap (video-capture camera-index)))
    (let ((window-name "VIDEO-CAPTURE-READ Example"))
      (if (not (is-opened cap)) 
	  (return-from video-capture-read-example
	    (format t "Cannot open the video camera")))
      (with-named-window (window-name +window-normal+)
	(move-window window-name 759 175)
	(with-mat ((frame (mat)))
	  (loop
	     (read cap frame)
	     (imshow window-name frame)
	     (let ((c (wait-key 33)))
	       (when (= c 27)
		 (return)))))))))

========================================================================================================================================
#VIDEO-CAPTURE-RELEASE
========================================================================================================================================

Closes video file or capturing device.

Note: The name VIDEO-CAPTURE-RELEASE is used in the documentation to refer to the binding for the 
"release" member of the OpenCV VideoCapture class because it is more descriptive and it is easier 
to search for in this file. The RELEASE method may also be used to call this binding.


C++: void VideoCapture::release()

LISP-CV: (RELEASE (SELF VIDEO-CAPTURE)) => :VOID

LISP-CV: (VIDEO-CAPTURE-RELEASE (SELF VIDEO-CAPTURE)) => :VOID


The methods are automatically called by subsequent (VIDEO-CAPTURE-OPEN) and by VIDEO-CAPTURE destructor.


    Parameters:	

         SELF - The VIDEO-CAPTURE structure.


(defun video-capture-release-example (&optional 
					(camera-index 
					 *camera-index*))
  
  (with-video-capture ((cap (video-capture camera-index)))
    (let ((window-name "VIDEO-CAPTURE-RELEASE Example"))
      (if (not (is-opened cap)) 
	  (return-from video-capture-release-example 
	    (format t "Cannot open the video camera")))
      (with-named-window (window-name +window-normal+)
      (move-window window-name 759 175)
      (with-mat ((frame (mat)))
	(loop
	   (read cap frame)
	   (imshow window-name frame)
	   (let ((c (wait-key 33)))
	     (when (= c 27)
	       (release cap)
	       (return)))))))))


========================================================================================================================================
#VIDEO-CAPTURE-RETRIEVE
========================================================================================================================================

Decodes and returns the grabbed video frame.

Note: The name VIDEO-CAPTURE-RETRIEVE is used in the documentation to refer to the binding for the 
"retrieve" member of the OpenCV VideoCapture class because it is more descriptive and it is easier 
to search for in this file. The RETRIEVE function may also be used to call this binding.


C++: bool VideoCapture::retrieve(OutputArray image, int flag=0 )

LISP-CV: (RETRIEVE (SELF VIDEO-CAPTURE) (IMAGE MAT) &OPTIONAL ((FLAGS :INT) 0)) => :BOOLEAN

LISP-CV: (VIDEO-CAPTURE-RETRIEVE (SELF VIDEO-CAPTURE) (IMAGE MAT) &OPTIONAL ((FLAGS :INT) 0)) => :BOOLEAN


The methods/functions decode and return the just grabbed frame. If no frames has been grabbed, e.g. 
camera has been disconnected, or there are no more frames in video file, the methods return false and 
the functions return NULL pointer.


Example:


(defun video-capture-retrieve-example (&optional (camera-index 
						  *camera-index*))

  (with-video-capture ((cap (video-capture camera-index)))
    (let ((window-name "VIDEO-CAPTURE-RETRIEVE Example"))
      (if (not (is-opened cap)) 
	  (return-from video-capture-retrieve-example
	    (format t "Cannot open the video camera")))
      (with-named-window (window-name +window-normal+)
	(move-window window-name 759 175)
	(with-mat ((frame (mat)))
	  (loop
	     (grab cap)
	     (retrieve cap frame)
	     (read cap frame)
	     (imshow window-name frame)
	     (let ((c (wait-key 33)))
	       (when (= c 27)
		 (return)))))))))

========================================================================================================================================
#VIDEO-CAPTURE-SET
========================================================================================================================================

Sets a property in the VIDEO-CAPTURE

Note: The name VIDEO-CAPTURE-SET is used in the documentation to refer to the binding for the "set" 
member of the OpenCV VideoCapture class because it is more descriptive and it is easier to search for 
in this file. The SET method may also be used to call this binding.

Note: The LISP-CV function SET overloads the Common Lisp function SET so both functions can use the 
same name. The LISP-CV function SET provides the the same functionality as the Common Lisp function 
SET and the 'set' members of OpenCV's classes. To use the Common Lisp function SET directly, while 
you are in the LISP-CV package, you need to evaluate CL:SET.


C++: bool VideoCapture::set(int propId, double value)

LISP-CV: (SET (SELF VIDEO-CAPTURE) (PROP-ID :INT) (VALUE :DOUBLE)) => :BOOLEAN

LISP-CV: (VIDEO-CAPTURE-SET (SELF VIDEO-CAPTURE) (PROP-ID :INT) (VALUE :DOUBLE)) => :BOOLEAN


    Parameters:	SELF - A VIDEO-CAPTURE object.

                PROP-ID -

       Property identifier. It can be one of the following:

            +CAP-PROP-POS-MSEC+ Current position of the video file in milliseconds.

            +CAP-PROP-POS-FRAMES+ 0-based index of the frame to be decoded/captured next.

            +CAP-PROP-POS-AVI-RATIO+ Relative position of the video file: 0 - start of the file, 

                                                                          1 - end of the file.

            +CAP-PROP-FRAME-WIDTH+ Width of the frames in the video stream.

            +CAP-PROP-FRAME-HEIGHT+ Height of the frames in the video stream.

            +CAP-PROP-FPS+ Frame rate.

            +CAP-PROP-FOUR-CC+ 4-character code of codec.

            +CAP-PROP-FRAME-COUNT+ Number of frames in the video file.

            +CAP-PROP-FORMAT+ Format of the Mat objects returned by retrieve() .

            +CAP-PROP-MODE+ Backend-specific value indicating the current capture mode.

            +CAP-PROP-BRIGHTNESS+ Brightness of the image (only for cameras).

            +CAP-PROP-CONTRAST+ Contrast of the image (only for cameras).

            +CAP-PROP-SATURATION+ Saturation of the image (only for cameras).

            +CAP-PROP-HUE+ Hue of the image (only for cameras).

            +CAP-PROP-GAIN+ Gain of the image (only for cameras).

            +CAP-PROP-EXPOSURE+ Exposure (only for cameras).

            +CAP-PROP-CONVERT-RGB+ Boolean flags indicating whether images should be converted to RGB.

            +CAP-PROP-WHITE-BALANCE+ Currently unsupported

            +CAP-PROP-RECTIFICATION+ Rectification flag for stereo cameras (note: only supported by
                                     DC1394 v 2.x backend currently)
  
                 VALUE - Value of the property.

   
Example:

(defun video-capture-set-example (&optional 
				    (camera-index 
				     *camera-index*))

  "Changes the brightness level of the camera output 
   ,with the method SET, and then prints it."

  (with-video-capture ((cap (video-capture camera-index)))
    (let ((window-name "VIDEO-CAPTURE-SET Example"))
      (if (not (is-opened cap)) 
	  (return-from video-capture-set-example
	    (format t "Cannot open the video camera")))
      (set cap +cap-prop-brightness+ 0.7)
      (format t "~%Brightness level: ~a~%~%" 
	      (get* cap +cap-prop-brightness+))
      (with-named-window (window-name +window-normal+)
	(move-window window-name 759 175)
	(with-mat ((frame (mat)))
	  (loop
	     (read cap frame)
	     (imshow window-name frame)
     	     (let ((c (wait-key 33)))
	       (when (= c 27)
		 (return)))))))))

========================================================================================================================================
#VIDEO-WRITER
========================================================================================================================================

VIDEO-WRITER constructors

Note: Both VIDEO-WRITER and MAKE-VIDEO-WRITER are provided in this library. The first, to match OpenCV's 
naming conventions, the second, to adhere to Common Lisp naming conventions. Except for the name, they are 
the same function. I use the VIDEO-WRITER function in the examples in this file because it will make them 
easier to compare with OpenCV examples you find online, thus making this library easier to learn.

C++: VideoWriter::VideoWriter()

LISP-CV: (VIDEO-WRITER) => VIDEO-WRITER

LISP-CV: (MAKE-VIDEO-WRITER) => VIDEO-WRITER

C++: VideoWriter::VideoWriter(const string& filename, int fourcc, double fps, Size frameSize, bool isColor=true)

LISP-CV: (VIDEO-WRITER (FILENAME :STRING) (FOUR-CC :INT) (FPS :DOUBLE) (FRAME-SIZE SIZE) ((IS-COLOR :INT) T)) => VIDEO-WRITER

LISP-CV: (MAKE-VIDEO-WRITER (FILENAME :STRING) (FOUR-CC :INT) (FPS :DOUBLE) (FRAME-SIZE SIZE) ((IS-COLOR :INT) T)) => VIDEO-WRITER


    Parameters:	

        FILENAME - Name of the output video file.

        FOUR-CC - 4-character code of codec used to compress the frames. For example, (FOUR-CC #\P #\I #\M #\1) 
                  is a MPEG-1 codec, (FOUR-CC #\M #\J #\P #\G)  is a motion-jpeg codec etc. List of codes can be 
                  obtained at: http://www.fourcc.org/codecs.php

        FPS - Framerate of the created video stream.

        FRAME-SIZE - Size of the video frames.

        IS-COLOR - If it is not zero, the encoder will expect and encode color frames, otherwise it 
                   will work with grayscale frames (the flag is currently supported on Windows only)


The constructors/functions initialize video writers. On Linux FFMPEG is used to write videos; on Windows 
FFMPEG or VFW is used; on MacOSX QTKit is used.


(defun video-writer-example (filename &optional	
					(cam 0) 
					(width *default-width*)
					(height *default-height*))
  (with-captured-camera (cap cam :width width :height height)
    (let* ((filename filename)
	   (window-name "VIDEO-WRITER Example")
	   (dheight (rational (get* cap +cap-prop-frame-height+)))
	   (dwidth (rational (get* cap +cap-prop-frame-width+))))
      (with-size ((frame-size (size width height)))
	;;Initialize the VIDEO-WRITER object 
	(with-video-writer ((o-video-writer (video-writer filename 
							  (four-cc #\D #\I #\V #\X)
							  20.0d0 frame-size 1))) 
	  (if (not (is-opened cap))
	      (return-from video-writer-example 
		(format t "ERROR: Cannot open the video file")))
	  (if (not (video-writer-is-opened o-video-writer)) 
	      (return-from video-writer-example 
		(format t "ERROR: Failed to write the video"))) 
	  (format t "~%Frame Size : ~ax~a~%~%" dwidth dheight)     
	  (with-named-window (window-name +window-normal+)
	    (move-window window-name 759 175)
	    (with-mat ((frame (mat)))	
	      (loop
		 (read cap frame)
		 (if (not frame) 
		     (return-from video-writer-example 
		       (format t "ERROR: Cannot read video file")))
		 ;;Write a frame into the file
		 (write o-video-writer frame)
		 (imshow window-name frame)
		 (let ((c (wait-key 33)))
		   (when (= c 27)
		     (return)))))))))))

========================================================================================================================================
#VIDEO-WRITER-IS-OPENED
========================================================================================================================================

Returns true if video writer has been successfully initialized.

Note: The name VIDEO-WRITER-IS-OPENED is used in the documentation to refer to the binding for the 
"isOpened" member of the OpenCV VideoWriter class because it is more descriptive and it is easier 
to search for in this file. The IS-OPENED method may also be used to call this binding.

C++: bool VideoWriter::isOpened()

LISP-CV: (IS-OPENED (SELF VIDEO-WRITER)) :BOOLEAN

LISP-CV: (VIDEO-WRITER-IS-OPENED (SELF VIDEO-WRITER)) :BOOLEAN


(defun video-writer-is-opened-example (filename &optional (camera-index *camera-index*))
  ;;Open the video camera
  (with-video-capture ((cap (video-capture camera-index))) 
    ;;Initialize the VideoWriter object 
    (with-video-writer ((o-video-writer (video-writer filename 1196444237 ; todo
						      20.0d0 (size 640 480) 1)))
      (format t "~%If VIDEO-WRITER is open a T will be displayed, else NIL: ~a~%~%"
	      (is-opened o-video-writer)))))

========================================================================================================================================
#VIDEO-WRITER-WRITE
========================================================================================================================================

Writes the next video frame

Note: The name VIDEO-WRITER-WRITE is used in the documentation to refer to the binding for the 
"write" member of the OpenCV VideoWriter class because it is more descriptive and it is easier 
to search for in this file. The WRITE method may also be used to call this binding.

Note: The LISP-CV function WRITE overloads the Common Lisp function WRITE so both functions can use the 
same name. The LISP-CV function WRITE provides the the same functionality as the Common Lisp function 
WRITE and the 'write' members of OpenCV's classes. To use the Common Lisp function WRITE directly, while 
you are in the LISP-CV package, you need to evaluate CL:WRITE.

C++: void VideoWriter::write(const Mat& image)

LISP-CV: (WRITE (SELF VIDEO-WRITER) (IMAGE MAT)) => VIDEO-WRITER

LISP-CV: (VIDEO-WRITER-WRITE (SELF VIDEO-WRITER) (IMAGE MAT)) => VIDEO-WRITER

    Parameters:	

        SELF - Pointer to VIDEO-WRITER

        IMAGE - The written frame


The function VIDEO-WRITER-WRITE writes the specified image to video file. It must have the same size 
as has been specified when opening the video writer.


(defun video-writer-write-example (filename &optional (cam 0))

  "Saves the camera feed to a video file. The save 
   location is specified by the FILENAME parameter."

  (with-video-capture ((cap (video-capture cam))) 
    (let* ((window-name "VIDEO-WRITER-WRITE Example"))
      (with-size ((frame-size (size 640 480)))
	(with-video-writer ((o-video-writer (video-writer filename 
							  (four-cc #\D #\I #\V #\X)
							  20.0d0 frame-size 1)))
	  (if (not (is-opened cap)) 
	      (return-from video-writer-write-example 
		(format t "ERROR: Cannot open the video file")))
	  (if (not (is-opened o-video-writer)) 
	      (return-from video-writer-write-example 
		(format t "ERROR: Failed to write the video"))) 
	  (with-named-window (window-name +window-normal+)
	    (move-window window-name 759 175)
	    (with-mat ((frame (mat)))
	      (loop
		 (read cap frame) 
		 (write o-video-writer frame) 
		 (imshow window-name frame)
		 (let ((c (wait-key 33)))
		   (when (= c 27)
		     (return)))))))))))

========================================================================================================================================
#WITH-CAPTURED-CAMERA
========================================================================================================================================

Ensures VIDEO-CAPTURE-RELEASE and DEL-VIDEO-CAPTURE gets called on captures. Also sets capture width/height in function.


LISP-CV: (WITH-CAPTURED-CAMERA ((CAPTURE-VAR (DEV-INDEX :INT) &KEY (WIDTH :INT) (HEIGHT :INT)) &BODY BODY)) => VIDEO-CAPTURE


Parameters:	

         CAPTURE-VAR - A variable representing the function used to open video file or a capturing 
                       device. Similar to the variable in a LET statement.

         DEV-INDEX - ID of the opened video capturing device (e.g. a camera index). If there is a 
                     single camera connected, just pass 0.

         WIDTH - Width of the frames in the video stream.

         HEIGHT - Height of the frames in the video stream.
    
         BODY - The body of the code to be executed once the video file or capturing device is open.


Example:

(defun with-captured-camera-example ()

  (format t "~%Please enter in the device id of your camera: ")

  (let ((window-name "WITH-CAPTURED-FILE Example")
	(cam (read)))
    (with-named-window (window-name +window-normal+)
      (move-window window-name 759 175)
      (with-captured-camera (cap cam :width 640 
				     :height 480)
	(if (not (is-opened cap)) 
	    (return-from with-captured-camera-example 
	      (format t "~%Cannot open the video camera~%~%")))
	(with-mat ((frame (mat)))
	  (loop
	     (read cap frame)
	     (imshow window-name frame)
	     (let ((c (wait-key 33)))
	       (when (= c 27)
		 (return)))))))))

========================================================================================================================================
#WITH-CAPTURED-FILE
========================================================================================================================================

Ensures VIDEO-CAPTURE-RELEASE and DEL-VIDEO-CAPTURE gets called on captures. Also sets capture width/height in function.

LISP-CV: (WITH-CAPTURED-FILE ((CAPTURE-VAR (FILE-PATH :INT) &KEY (WIDTH :INT) (HEIGHT :INT)) &BODY BODY))


Parameters:	

         CAPTURE-VAR - A variable representing the function used to open video file or a capturing 
                       device. Similar to the variable in a LET statement.

         FILE-PATH - Name of the opened video file (eg. video.avi) or image sequence (eg. img-%02d.jpg, 
                     which will read samples like img-00.jpg, img-01.jpg, img-02.jpg,...)

         WIDTH - Width of the frames in the video stream.

         HEIGHT - Height of the frames in the video stream.
    
         BODY - The body of the code to be executed once the video file or capturing device is open.


Example:

(defun with-captured-file-example (file-path)

  (let ((window-name "WITH-CAPTURED-FILE Example"))
    (with-named-window (window-name +window-normal+)
      (move-window window-name 759 175)
      (with-captured-file (cap file-path 
			       :width 640 
			       :height 480)
	(with-mat ((frame (mat)))
	  (loop
	     (read cap frame)
	     (imshow window-name frame)
	     (let ((c (wait-key 33)))
	       (when (= c 27)
		 (return)))))))))

========================================================================================================================================
#HIGHGUI - #QT NEW FUNCTIONS
========================================================================================================================================

========================================================================================================================================
#DISPLAY-OVERLAY
========================================================================================================================================

Displays a text on a window image as an overlay for a specified duration.

C++: void displayOverlay(const String& winname, const String& text, int delayms=0 )

LISP-CV: (DISPLAY-OVERLAY (WINNAME :STRING) (TEXT :STRING) &OPTIONAL ((DELAYMS :INT) 0)) => :VOID


    Parameters:	

        NAME - Name of the window.

        TEXT - Overlay text to write on a window image.

        DELAYMS - The period (in milliseconds), during which the overlay text is displayed. If this 
                  function is called before the previous overlay text timed out, the timer is restarted 
                  and the text is updated. If this value is zero, the text never disappears.

The function DISPLAY-OVERLAY displays useful information/tips on top of the window for a certain amount 
of time delayms. The function does not modify the image, displayed in the window, that is, after the 
specified delay the original content of the window is restored.


(defun display-overlay-example (&optional (cap 0))

  (with-video-capture ((cap (video-capture cap)))
    (let ((window-name "DISPLAY-OVERLAY Example"))
      (with-named-window (window-name +window-normal+)
	(move-window window-name 759 175)
	(with-mat ((frame (mat)))
	  (loop
	     (read cap frame)
	     (display-overlay window-name "This is a test" 1)
	     (imshow window-name frame)
	     (let ((c (wait-key 33)))
	       (when (= c 27)
		 (return)))))))))

========================================================================================================================================
#GET-WINDOW-PROPERTY
========================================================================================================================================

Provides parameters of a window.

C++: double getWindowProperty(const string& winname, int prop_id)

LISP-CV: (GET-WINDOW-PROPERTY (WINNAME :STRING) (PROP-ID) :INT) => :DOUBLE


    Parameters:	

        WINNAME - Name of the window.

        PROP-ID -

           Window property to retrieve. The following operation flags are available:


               +WND-PROP-FULLSCREEN+ Change if the window is fullscreen;
  
                             (+WINDOW-NORMAL+ or +WINDOW-FULLSCREEN+).

               +WND-PROP-AUTOSIZE+ Change if the window is resizable;

                             (+WINDOW-NORMAL+ or +WINDOW-AUTOSIZE+).

                     +WND-PROP-ASPECTRATIO+ Change if the aspect ratio of the image is preserved;

                             (+WINDOW-FREERATIO+ or +WINDOW-KEEPRATIO+).


Note: See (SET-WINDOW-PROPERTY) to know the meaning of the returned values.

The function GET-WINDOW-PROPERTY returns properties of a window.


Example:

(defun get-window-property-example (filename)

  (let* ((window-name "GET-WINDOW-PROPERTY Example"))
    ;;Read in image
    (with-mat ((image (imread filename 1)))
      (if (empty image) 
	  (return-from get-window-property-example 
	    (format t "Image not loaded")))
      ;;Create window
      (with-named-window (window-name +window-normal+)
	;;Set window to fullscreen
	(set-window-property window-name +wnd-prop-fullscreen+ 
			     +window-fullscreen+)
	;;If aspect ratio is not stretched, set to stretched
	(if (equal 1.0d0 (get-window-property window-name +wnd-prop-fullscreen+)) 
	    (set-window-property window-name +wnd-prop-aspectratio+ 
				 +window-freeratio+))
	;;Show image
	(imshow window-name image)
	(loop 
	   (let ((c (wait-key 33)))
	     (when (= c 27)
	       (return))))))))


========================================================================================================================================
#SET-WINDOW-PROPERTY
========================================================================================================================================

Changes parameters of a window dynamically.


C++: void setWindowProperty(const string& winname, int prop_id, double prop_value)

LISP-CV: (SET-WINDOW-PROPERTY (WINNAME :STRING) (PROP-ID :INT) (PROP-VALUE :DOUBLE)) => :VOID

     
    Parameters:	

        WINNAME - Name of the window.

        PROP-ID -

           Window property to edit. The following operation flags are available:


               +WND-PROP-FULLSCREEN+ Change if the window is fullscreen;
                     
                             (+WINDOW-NORMAL+ or +WINDOW-FULLSCREEN+).

               +WND-PROP-AUTOSIZE+ Change if the window is resizable;
 
                             (+WINDOW-NORMAL+ or +WINDOW-AUTOSIZE+).

               +WND-PROP-ASPECTRATIO+ Change if the aspect ratio of the image is preserved;

                             (+WINDOW-FREERATIO+ or +WINDOW-KEEPRATIO+).

        PROP-VALUE -

           New value of the window property. the following operation flags are available:


               +WINDOW-NORMAL+ Change the window to normal size or make the window resizable.

               +WINDOW-AUTOSIZE+ Constrain the size by the displayed image. the window is not resizable.

               +WINDOW-FULLSCREEN+ Change the window to fullscreen.

               +WINDOW-FREERATIO+ Make the window resizable without any ratio constraints.

               +WINDOW-KEEPRATIO+ Make the window resizable, but preserve the proportions of the 
                                  displayed image.


The function SET-WINDOW-PROPERTY enables changing properties of a window.


Example:

(defun set-window-property-example (filename)

  (let ((window-name "SET-WINDOW-PROPERTY Example"))
    ;; Read in image
    (with-mat ((image (imread filename 1)))
      (if (empty image) 
	  (return-from set-window-property-example 
	    (format t "Image not loaded")))
      ;; Create window
      (with-named-window (window-name +window-normal+)
	;; Set window to fullscreen
	(set-window-property window-name +wnd-prop-fullscreen+ 
			     +window-fullscreen+)
	;; Show image
	(imshow window-name image)
	(loop
	   (let ((c (wait-key 33)))
	     (when (= c 27)
	       (return))))))))

========================================================================================================================================
#VIDEO - #MOTION ANALYSIS AND OBJECT TRACKING
========================================================================================================================================

========================================================================================================================================
#CALC-OPTICAL-FLOW-PYR-LK
========================================================================================================================================

Calculates an optical flow for a sparse feature set using the iterative Lucas-Kanade method with pyramids.

C++: void calcOpticalFlowPyrLK(InputArray prevImg, InputArray nextImg, InputArray prevPts, InputOutputArray nextPts, 
                               OutputArray status, OutputArray err, Size winSize=Size(21,21), int maxLevel=3, 
                               TermCriteria criteria=TermCriteria(TermCriteria::COUNT+TermCriteria::EPS, 30, 0.01), 
                               int flags=0, double minEigThreshold=1e-4 )

LISP-CV: (CALC-OPTICAL-FLOW-PYR-LK (PREV-IMG MAT) (NEXT-IMG MAT) (PREV-PTS MAT) (NEXT-PTS MAT) (STATUS MAT) (ERR MAT) &OPTIONAL 
                                  ((WIN-SIZE SIZE) (SIZE-2 21 21)) ((MAX-LEVEL :INT) 3) 
                                  ((CRITERIA TERM-CRITERIA) 
                                   (TERM-CRITERIA-3 (+ +TERM-CRITERIA-COUNT+ +TERM-CRITERIA-EPS+) 30 0.01D0)) 
                                  ((FLAGS :INT) 0) ((MIN-EIGEN-THRESHOLD :DOUBLE) 1.D-4)) => :VOID
    Parameters:	

        PREV-IMG - First 8-bit input image or pyramid constructed by (BUILD-OPTICAL-FLOW-PYRAMID).

        NEXT-IMG - Second input image or pyramid of the same size and the same type as PREV-IMG.

        PREV-PTS - Vector of 2D points for which the flow needs to be found; point coordinates must 
                   be single-precision floating-point numbers.

        NEXT-PTS - Output vector of 2D points (with single-precision floating-point coordinates) 
                   containing the calculated new positions of input features in the second image; 
                   when +OPTFLOW-USE-INITIAL-FLOW+ flag is passed, the vector must have the same 
                   size as in the input.

        STATUS - Output status vector (of unsigned chars); each element of the vector is set to 1 
                 if the flow for the corresponding features has been found, otherwise, is set to 0.

        ERR - Output vector of errors; each element of the vector is set to an error for the corresponding 
              feature, type of the error measure can be set in FLAGS parameter; if the flow wasn’t found then 
              the error is not defined (use the STATUS parameter to find such cases).

        WIN-SIZE - size of the search window at each pyramid level.

        MAX-LEVEL - 0-based maximal pyramid level number; if set to 0, pyramids are not used (single level), 
                    if set to 1, two levels are used, and so on; if pyramids are passed to input then algorithm 
                    will use as many levels as pyramids have but no more than MAX-LEVEL.

        CRITERIA - parameter, specifying the termination criteria of the iterative search algorithm (after the 
                   specified maximum number of iterations (MAX-COUNT CRITERIA) <criteria.maxCount in OpenCV>
                   or when the search window moves by less than (EPSILON CRITERIA) <criteria.epsilon in OpenCV>.

        FLAGS - operation flags:

            +OPTFLOW-USE-INITIAL-FLOW+ uses initial estimations, stored in NEXT-PTS; if the flag is not set, then PREV-PTS 
                                       is copied to NEXT-PTS and is considered the initial estimate.

            +OPTFLOW-LK-GET-MIN-EIGENVALS+ use minimum eigen values as an error measure (see MIN-EIG-THRESHOLD description); 
                                           if the flag is not set, then L1 distance between patches around the original and a 
                                           moved point, divided by number of pixels in a window, is used as a error measure.

        MIN-EIG-THRESHOLD - the algorithm calculates the minimum eigen value of a 2x2 normal matrix of optical flow equations 
                           (this matrix has been called a spatial gradient matrix), divided by number of pixels in a window; 
                            if this value is less than MIN-EIG-THRESHOLD, then a corresponding feature is filtered out and 
                            its flow is not processed, so it allows to remove bad points and get a performance boost.


The function implements a sparse iterative version of the Lucas-Kanade optical flow in pyramids. 


Example:

(defun calc-optical-flow-pyr-lk-example ()
  
  (let ((window-name-1 "ImageA - CALC-OPTICAL-FLOW-PYR-LK Example")
	(window-name-2 "ImageB - CALC-OPTICAL-FLOW-PYR-LK Example")
	(window-name-3 "ImageC - CALC-OPTICAL-FLOW-PYR-LK Example")
	(quality-level 0.05d0)
	(min-distance 5.0d0)
	(thickness -1)
	(line-type 8))
    (with-named-window (window-name-1 +window-autosize+)
      (with-named-window (window-name-2 +window-autosize+)
	(with-named-window (window-name-3 +window-autosize+)
	  (move-window window-name-1 250 175)
	  (move-window window-name-2 760 175)
	  (move-window window-name-3 1270 175)
          ;;Allocate integers the trackbars 
          ;;can increment/decrement. Later, 
          ;;the CFFI:MEM-AREF macro(@) will
          ;;dereference these pointers and
          ;;apply these adjusted values to 
          ;;functions that are integral to 
          ;;this process.
	  (with-object ((max-corners (alloc :int 20))
			(win-size.width (alloc :int 15))
			(win-size.height (alloc :int 15))
			(pt1.x (alloc :int 163))
			(pt1.y (alloc :int 152))
			(pt2.x (alloc :int 240))
			(pt2.y (alloc :int 280))
			(pt3.x (alloc :int 260))
			(pt3.y (alloc :int 140))
			(pt4.x (alloc :int 380))
			(pt4.y (alloc :int 260)))
	    (create-trackbar "max-corners" window-name-1 max-corners 480)
	    (create-trackbar "win-size.width" window-name-1 win-size.width 480)
	    (create-trackbar "win-size.height" window-name-1 win-size.height 480)
	    (create-trackbar "pt1.x" window-name-1 pt1.x 480)
	    (create-trackbar "pt1.y" window-name-1 pt1.y 480)
	    (create-trackbar "pt2.x" window-name-1 pt2.x 480)
	    (create-trackbar "pt2.y" window-name-1 pt2.y 480)
	    (create-trackbar "pt3.x" window-name-1 pt3.x 480)
	    (create-trackbar "pt3.y" window-name-1 pt3.y 480)
	    (create-trackbar "pt4.x" window-name-1 pt4.x 480)
	    (create-trackbar "pt4.y" window-name-1 pt4.y 480)
	    (with-mat ((mat (mat)))
	      (with-scalar ((black (scalar-all 0)))
		(with-size ((*win-size (size (@ win-size.width :int) (@ win-size.height :int)))
			    (zero-zone (size -1 -1)))
		  (loop     
		     
		     ;;;Create three images...
		     
		     ;;IMG-A will be one rectangle.

		     ;;IMG-B will be another rectangle.

		     ;;IMG-C will shows the 2 rectangles together...

                     ;;First, create 3 matrices...
		     (with-mat ((img-a (mat 480 480 +8u+ 255))
				(img-b (mat 480 480 +8u+ 255))
				(img-c (mat (rows img-a) (cols img-a) 16 255)))
                       ;;Then, create vertexes of the rectangles...
		       (with-point ((pt1 (point (@ pt1.x :int) (@ pt1.y :int)))
				    (pt2 (point (@ pt2.x :int) (@ pt2.y :int)))
				    (pt3 (point (@ pt3.x :int) (@ pt3.y :int)))
				    (pt4 (point (@ pt4.x :int) (@ pt4.y :int))))
                         ;;Finally, draw the rectangles.
			 (rectangle img-a pt1 pt2 black thickness line-type)
			 (rectangle img-b pt3 pt4 black thickness line-type)
			 (rectangle img-c pt1 pt2 black thickness line-type)
			 (rectangle img-c pt3 pt4 black thickness line-type))
                       ;;Create matrices to hold the detected corners.
		       (with-mat ((corners-a (mat (@ max-corners :int) 2 +32f+))
				  (corners-b (mat (@ max-corners :int) 2 +32f+)))
                         ;;Find the features.
			 (good-features-to-track img-a corners-a (@ max-corners :int) 
						 quality-level min-distance mat)
			 (good-features-to-track img-b corners-b (@ max-corners :int) 
						 quality-level min-distance mat)
			 (with-term-criteria ((criteria (term-criteria 
							 (logior +termcrit-iter+ +termcrit-eps+)
							 20 0.03d0)))
                           ;;Refine the features.
			   (corner-sub-pix img-a corners-a *win-size zero-zone criteria)
			   (corner-sub-pix img-b corners-b *win-size zero-zone criteria)
			   (with-mat ((features-found (mat (@ max-corners :int) 1 +8u+))                                                                             (feature-errors (mat (@ max-corners :int) 1 +32f+)))
			     (with-term-criteria ((criteria (term-criteria (+ +termcrit-iter+ 
									      +termcrit-eps+) 
									   20 0.3d0)))
			       ;;Call Lucas Kanade algorithm. This does the actual optic flow calculations.
			       (calc-optical-flow-pyr-lk img-a img-b corners-a corners-b 
							 features-found 
							 feature-errors 
							 *win-size 5 criteria 0))
			     ;;Draw the flow vectors on a combination of the two images to show this works.
			     (format t "~%Print ERROR vector;~%") 
			     (dotimes (i (* (rows features-found) (cols features-found)))
			       (format t "~%Error is: ~a,~%" (@ (ptr feature-errors 0) :float i))
			       (with-point ((p0 (point (ceiling (@ (at-point-2f corners-a 0 i) :float)) 
						       (ceiling (@ (at-point-2f corners-a 0 i) :float 1))))
					    (p1 (point (ceiling (@ (at-point-2f corners-b 0 i) :float)) 
						       (ceiling (@ (at-point-2f corners-b 0 i) :float 1)))))
				 (line img-C p0 p1 (t:RGB 255 0 0) 2)))
			     ;;Print status vector: Each element of 
                             ;;the vector is set to 1 if the flow 
			     ;;for the corresponding features has 
                             ;;been found, otherwise, it's set to 0.
			     (format t "~%Current status;~%~%") 
			     (print-mat features-found) 
			     (imshow window-name-1 img-a)
			     (imshow window-name-2 img-b)
			     (imshow window-name-3 img-c)
			     (let ((c (wait-key 33)))
			       (when (= c 27)
				 (return)))))))))))))))))

========================================================================================================================================
#FEATURES2D - #FEATURE DETECTION AND DESCRIPTION
========================================================================================================================================

========================================================================================================================================
BRISK
========================================================================================================================================

The BRISK constructor

Note: Both BRISK and MAKE-BRISK are provided in this library. The first, to match OpenCV's naming 
conventions, the second, to adhere to Common Lisp naming conventions. Except for the name, they are 
the same function. I use the BRISK function in the examples in this file because it will make them 
easier to compare with OpenCV examples you find online, thus making this library easier to learn.

C++: BRISK::BRISK(int thresh=30, int octaves=3, float patternScale=1.0f)

LISP-CV: (BRISK &OPTIONAL ((THRESH :INT) 30) ((OCTAVES :INT) 3) ((PATTERN-SCALE :FLOAT) 1.0F0) => BRISK

LISP-CV: (MAKE-BRISK &OPTIONAL ((THRESH :INT) 30) ((OCTAVES :INT) 3) ((PATTERN-SCALE :FLOAT) 1.0F0) => BRISK


    Parameters:	

        THRESH - FAST/AGAST detection threshold score.

        OCTAVES - detection octaves. Use 0 to do single scale.

        PATTERN-SCALE - apply this scale to the pattern used for sampling the neighbourhood of a keypoint.


BRISK is a object implementing the BRISK keypoint detector and descriptor extractor, described in [LCS11]:

http://docs.opencv.org/modules/features2d/doc/feature_detection_and_description.html?highlight=brisk#lcs11


Example:


(defun brisk-example (filename-1 filename-2)

  "Warning: Creating 12 BRISK objects uses a lot of RAM. It
   will get deleted though, within 30 seconds. It's best to 
   start this program with a good amount of available RAM.

   Don't let this example make you nervous, it's basically 
   12 FEATURE-DETECTOR-CREATE-EXAMPLES stacked, in one. I'm
   basically just showing, in a quick easy to see fashion, 
   how the THRESH, OUTPUT and PATTERN-SCALE parameters of t-
   he function BRISK's parameters affect it's output. Each 
   of the 12 windows has the function call used to set the 
   parameters printed on the titlebar, so you don't have to 
   look through the code to get the effect of this example. 
   For example, if you see this on the windows titlebar: 

                   (BRISK 0 0 0.0f0)
 
   then you know the BRISK parameter set for that window is: 

       THRESH = 0, OCTAVES  = 0, PATTERN-SCALE = 0.0f0.

   Note: Try using box.png and box-in-scene.png from the:
    
     LISP-CV-MASTER/IMAGES 

   directory to get a better understanding of this example 
   the first time you run it. And, just be aware, this exa-
   mple takes a few seconds to start."

  ;; read two images in grayscale, first the object you want to track,
  (let* ((gray-a (gc:imread filename-1 +load-image-grayscale+))
	 ;; second the image the object is a part of
	 (gray-b (gc:imread filename-2 +load-image-grayscale+))
         ;; make arrays to hold the keypoints and descriptors
         (keypoints-a-arr (make-array '(12))) 
         (keypoints-b-arr (make-array '(12)))
	 (descriptors-a-arr (make-array '(12)))
	 (descriptors-b-arr (make-array '(12)))  
	 (matcher-arr (make-array '(12))) 
	 (matches-arr (make-array '(12)))
	 (all-matches-arr (make-array '(12)))
	 ;; declare an array of BRISK objects
	 (brisk-arr 
	  (make-array 12 :initial-contents 
		      (list
		       (brisk 0 0 0.0f0)
		       (brisk 60 0 0.0f0)
		       (brisk 120 0 0.0f0)
		       (brisk 180 0 0.0f0)
		       (brisk 0 4 1.0f0)
		       (brisk 60 4 1.0f0)
		       (brisk 120 4 1.0f0)
		       (brisk 180 4 1.0f0)
		       (brisk 0 8 2.0f0)
		       (brisk 60 8 2.0f0)
		       (brisk 120 8 2.0f0)
		       (brisk 180 8 2.0f0))))
         ;; declare an array of 12 window names which will be used 
         ;; by MOVE-WINDOW, NAMED WINDOW, IMSHOW and  DESTROY-WINDOW
	 (window-name-arr 
	  (make-array 12 :initial-contents 

		      (list
		       "(BRISK 0 0 0.0f0) - BRISK Example"
		       "(BRISK 60 0 0.0f0) - BRISK Example"
		       "(BRISK 120 0 0.0f0) - BRISK Example"
		       "(BRISK 180 0 0.0f0) - BRISK Example"
		       "(BRISK 0 4 1.0f0) - BRISK Example"
		       "(BRISK 60 4 1.0f0) - BRISK Example"
		       "(BRISK 120 4 1.0f0) - BRISK Example"
		       "(BRISK 180 4 1.0f0) - BRISK Example"
		       "(BRISK 0 8 2.0f0) - BRISK Example"
		       "(BRISK 60 8 2.0f0) - BRISK Example"
		       "(BRISK 120 8 2.0f0) - BRISK Example"
		       "(BRISK 180 8 2.0f0) - BRISK Example"))))
    ;; if images not loaded, break
    (if (empty (or gray-a gray-b)) 
	(return-from brisk-example 
	  (format t "Both images were not loaded")))
    ;; create 12 windows to show the output images in
    (dotimes (i 12)
      (named-window (aref window-name-arr i) +window-normal+))
    ;; move the windows to specific coordinates
    (move-window (aref window-name-arr 0) 88 0)
    (move-window (aref window-name-arr 1) 538 0)
    (move-window (aref window-name-arr 2) 988 0)
    (move-window (aref window-name-arr 3) 1438 0)
    (move-window (aref window-name-arr 4) 88 368)
    (move-window (aref window-name-arr 5) 538 368)
    (move-window (aref window-name-arr 6) 988 368)
    (move-window (aref window-name-arr 7) 1438 368)
    (move-window (aref window-name-arr 8) 88 708)
    (move-window (aref window-name-arr 9) 538 708)
    (move-window (aref window-name-arr 10) 988 708)
    (move-window (aref window-name-arr 11) 1438 708)
    ;; declare 2 arrays of 12 keypoints each
    (dotimes (i 12)
      (setf (aref keypoints-a-arr i) (gc:vector-key-point))
      (setf (aref keypoints-b-arr i) (gc:vector-key-point))
      ;; declare an array of 12 query descriptors 
      (setf (aref descriptors-a-arr i) (gc:mat))
      ;; declare an array of 12 train descriptors 
      (setf (aref descriptors-b-arr i) (gc:mat))
      ;; declare an array of 12 matchers
      (setf (aref matcher-arr i) (gc:bf-matcher))
      ;; declare an array of 12 MAT objects to hold the 
      ;; matches from the first image to the second one
      (setf (aref matches-arr i) (gc:vector-dmatch))
      ;; declare an array of 12 MAT objects to hold the final output images
      (setf (aref all-matches-arr i) (gc:mat))
      ;; find matches, between the two images, 12 times,
      ;; each using a different set of BRISK parameters
      (create :feature-detector (aref brisk-arr i) "BRISK")
      ;; detect keypoints in the image GRAY-A
      (detect (aref brisk-arr i) gray-a (aref keypoints-a-arr i))
      ;; Compute the descriptors for a set of keypoints detected in GRAY-A
      (compute :feature-2d (aref brisk-arr i) gray-a (aref keypoints-a-arr i) 
	       (aref descriptors-a-arr i))
      ;; detect keypoints in the image GRAY-B
      (detect (aref brisk-arr i) gray-b (aref keypoints-b-arr i))
      ;; compute the descriptors for a set of keypoints detected in GRAY-B
      (compute :feature-2d (aref brisk-arr i) gray-b (aref keypoints-b-arr i) 
	       (aref descriptors-b-arr i))
      ;; find the best match for each descriptor
      (match (aref matcher-arr i) (aref descriptors-a-arr i) 
	     (aref descriptors-b-arr i) (aref matches-arr i))
      ;; draw the found matches
      (draw-matches gray-a (aref keypoints-a-arr i) gray-b (aref keypoints-b-arr i) 
		    (aref matches-arr i) (aref all-matches-arr i) 
		    (gc:scalar-all -1) (gc:scalar-all -1) (gc:vector-char) 
		    +draw-rich-keypoints+)
      ;; show the 12 different matches in 12 windows
      (imshow (aref window-name-arr i) (aref all-matches-arr i))
      (del-brisk (aref brisk-arr i)))
    ;; after 'esc' key is pressed destroy all 12 windows
    (loop while (not (= (wait-key 0) 27)))
    (dotimes (i 12)
      (destroy-window (aref window-name-arr i)))))

========================================================================================================================================
#FAST
========================================================================================================================================

Detects corners using the FAST algorithm

C++: FastFeatureDetector( int threshold=10, bool nonmaxSuppression=true)

LISP-CV: (FAST-FEATURE-DETECTOR ((THRESHOLD :INT) 10) ((NON-MAX-SUPPRESSION :BOOLEAN) T)) => FAST-FEATURE-DETECTOR


    Parameters:	

        THRESHOLD - Threshold on difference between intensity of the central pixel and pixels of a
                    circle around this pixel.

        NON-MAX-SUPPRESSION - If true, non-maximum suppression is applied to detected corners.


Detects corners using the FAST algorithm by Edward Rosten - 2006.


Example:

See DRAW-KEYPOINTS-EXAMPLE in this file.


========================================================================================================================================
#FEATURES2D - #COMMON INTERFACES OF FEATURE DETECTORS
========================================================================================================================================

========================================================================================================================================
#FEATURE-DETECTOR-CREATE
========================================================================================================================================

Creates a feature detector by its name.


Note: The name FEATURE-DETECTOR-CREATE is used in the documentation to refer to the binding for the 
"create" member of the OpenCV FeatureDetector class because it is more descriptive and it is easier 
to search for in this file. The CREATE method may also be used to call this binding.


C++: Ptr<FeatureDetector> FeatureDetector::create(const string& detectorType)

LISP-CV: (CREATE (TYPE SYMBOL) (SELF BF-MATCHER) (DETECTOR-TYPE :STRING)) => BF-MATCHER

LISP-CV: (CREATE (TYPE SYMBOL) (SELF BRISK) (DETECTOR-TYPE :STRING)) => BRISK

LISP-CV: (CREATE (TYPE SYMBOL) (SELF SURF) (DETECTOR-TYPE :STRING)) => SURF

LISP-CV: (FEATURE-DETECTOR-CREATE (SELF BF-MATCHER) (DETECTOR-TYPE :STRING)) => BF-MATCHER

LISP-CV: (FEATURE-DETECTOR-CREATE (SELF BRISK) (DETECTOR-TYPE :STRING)) => BRISK

LISP-CV: (FEATURE-DETECTOR-CREATE (SELF SURF) (DETECTOR-TYPE :STRING)) => SURF


    Parameters:	

        TYPE - A symbol. Must be specified as :FEATURE-DETECTOR.
 
        SELF - A BF-MATCHER, BRISK or SURF object.

        DETECTOR-TYPE - Feature detector type:


The following detector types are supported:


       "FAST" - FAST-FEATURE-DETECTOR
   
       "STAR" - STAR-FEATURE-DETECTOR
   
       "SIFT" - SIFT (nonfree module)
   
       "SURF" - SURF (nonfree module)
   
       "ORB" - ORB
   
       "BRISK" - BRISK
   
       "MSER" - MSER
   
       "GFTT" - GOOD-FEATURES-TO-TRACK-DETECTOR
   
       "HARRIS" - GOOD-FEATURES-TO-TRACK-DETECTOR with Harris detector enabled
   
       "Dense" - DENSE-FEATURE-DETECTOR
   
       "SimpleBlob" - SIMPLE-BLOB-DETECTOR
   
  
Also a combined format is supported: feature detector adapter name:

           ("GRID" - GRID-ADAPTED-FEATURE-DETECTOR, "PYRAMID" - PYRAMID-ADAPTED-FEATURE-DETECTOR) + 

                                     feature detector name: (see above), for example: "GRIDFAST", "PYRAMIDSTAR".


Example:


(defun feature-detector-create-example (filename-1 filename-2) 

  "Try using the box.png and the box-in-scene.png from
   the LISP-CV-MASTER/IMAGES directory to get a better 
   understanding of this example the first time you ru-
   n it."

  ;; set brisk parameters
  (let* ((thresh 60)
	 (octaves 4)
	 (pattern-scale 2.0f0)
	 (window-name "All Matches - CREATE Example"))
    ;; read some images in grayscale -> The object you want to track
    (with-mat ((gray-a (imread filename-1 +load-image-grayscale+))
	       ;; The image the object is a part of
	       (gray-b (imread filename-2 +load-image-grayscale+)) 
	       (descriptors-a (mat))
	       (descriptors-b (mat))
	       (all-matches (mat)))
      (if (empty (or gray-a gray-b)) 
	  (return-from feature-detector-create-example 
	    (format t "Both images were not loaded")))
      (with-vector-key-point ((keypoints-a (vector-key-point))
			      (keypoints-b (vector-key-point)))
	;; declare BRISK keypoint detector/descriptor extractor
	(with-brisk ((briskd (brisk thresh octaves pattern-scale)))
	  ;; declare matcher
	  (with-bf-matcher ((matcher (bf-matcher)))
	    ;; create vector of DMATCH objects to hold the matches
	    (with-vector-dmatch ((matches (vector-dmatch)))
	      ;; create a feature detector
	      (create :feature-detector briskd "STAR")
	      ;; detect keypoints in the image GRAY-A
	      (detect briskd gray-a keypoints-a)
	      ;; Compute the descriptors for a set of keypoints detected in GRAY-A
	      (compute :feature-2d briskd gray-a keypoints-a descriptors-a)
	      ;; detect keypoints in the image GRAY-B
	      (detect briskd gray-b keypoints-b)
	      ;; Compute the descriptors for a set of keypoints detected in GRAY-B
	      (compute :feature-2d  briskd gray-b keypoints-b descriptors-b)
	      ;; find the best match for each descriptor
	      (match matcher descriptors-a descriptors-b matches)
	      (with-named-window (window-name +window-normal+)
		(move-window window-name 759 175)
		(with-scalar ((scalar (scalar-all -1)))
		  ;; draw the found matches
		  (with-vector-char ((matches-mask (gc:vector-char)))
		    (draw-matches gray-a keypoints-a gray-b keypoints-b matches all-matches 
				  scalar scalar matches-mask
				  +not-draw-single-points+)
		    ;; show the matches in a window 
		    (imshow window-name all-matches)
		    (loop 
		       (let ((c (wait-key 33)))
			 (when (= c 27)
			   (return))))))))))))))

========================================================================================================================================
#FEATURE-DETECTOR-DETECT
========================================================================================================================================

Detects keypoints in an image.

Note: The name FEATURE-DETECTOR-DETECT is used in the documentation to refer to the binding for the 
"detect" member of the OpenCV FeatureDetector class because it is more descriptive and it is easier 
to search for in this file. The DETECT method may also be used to call this binding.


C++: void FeatureDetector::detect(InputArray image, vector<KeyPoint>& keypoints, InputArray mask=noArray() ) const

LISP-CV: (DETECT (SELF BF-MATCHER) (IMAGE MAT) (KEYPOINTS KEY-POINT) &OPTIONAL ((MASK MAT) (MAT))) => :VOID

LISP-CV: (DETECT (SELF BRISK) (IMAGE MAT) (KEYPOINTS KEY-POINT) &OPTIONAL ((MASK MAT) (MAT))) => :VOID

LISP-CV: (DETECT (SELF FAST-FEATURE-DETECTOR) (IMAGE MAT) (KEYPOINTS KEY-POINT) &OPTIONAL ((MASK MAT) (MAT))) => :VOID

LISP-CV: (DETECT (SELF SURF) (IMAGE MAT) (KEYPOINTS KEY-POINT) &OPTIONAL ((MASK MAT) (MAT))) => :VOID

LISP-CV: (FEATURE-DETECTOR-DETECT (SELF BF-MATCHER) (IMAGE MAT) (KEYPOINTS KEY-POINT) &OPTIONAL ((MASK MAT) (MAT))) => :VOID

LISP-CV: (FEATURE-DETECTOR-DETECT (SELF BRISK) (IMAGE MAT) (KEYPOINTS KEY-POINT) &OPTIONAL ((MASK MAT) (MAT))) => :VOID

LISP-CV: (FEATURE-DETECTOR-DETECT (SELF FAST-FEATURE-DETECTOR) (IMAGE MAT) (KEYPOINTS KEY-POINT) &OPTIONAL 
                                 ((MASK MAT) (MAT))) => :VOID

LISP-CV: (FEATURE-DETECTOR-DETECT (SELF SURF) (IMAGE MAT) (KEYPOINTS KEY-POINT) &OPTIONAL ((MASK MAT) (MAT))) => :VOID


    Parameters:	

        SELF - A BF-MATCHER, BRISK or SURF object.

        IMAGE - An image.

        KEYPOINTS - The detected keypoints.

        MASK - Mask specifying where to look for keypoints (optional). It must be a 8-bit integer 
               matrix with non-zero values in the region of interest.


Example:


(defun feature-detector-detect-example (&optional 
					  (cam *camera-index*) 
					  (width *default-width*)
					  (height *default-height*))

  "Note: The 'GC:' prefix to some of these functions 
   signifies automatic garbage collection is enabled."

  (with-captured-camera (cap cam :width width :height height)
    ;;Initialize the template location, dimension and 
    ;;min-hessian variables for the trackbars to adjust
    (with-object ((template-x (alloc :int '(0)))
		  (template-y (alloc :int '(0)))
		  (template-width (alloc :int (list (round (/ width 2)))))
		  (template-height (alloc :int (list (round (/ height 2)))))
		  (min-hessian (alloc :int 400)))
      ;;Vectors for holding all keypoints
      (let* ((keypoints-1 (gc:vector-key-point))
	     (keypoints-2 (gc:vector-key-point))
             ;;Matrices for holding the descriptors
	     (descriptors-1 (gc:mat))
	     (descriptors-2 (gc:mat))
	     (matcher (gc:bf-matcher +norm-l2+))
             ;;Vector for holding the matches
	     (matches (gc:vector-dmatch))
             ;;Output matrix
	     (img-matches (gc:mat))
	     (window-name "Image Matches - FEATURE-DETECTOR-DETECT Example"))
        ;;Create fullscreen window
	(with-named-window (window-name +window-normal+)
	  ;;Set window to fullscreen
	  (set-window-property window-name +wnd-prop-fullscreen+ 
			       +window-fullscreen+)
	  ;;Trackbars that control the template location/dimensions
	  (create-trackbar "TEMPLATE-X" window-name template-x 250)
	  (create-trackbar "TEMPLATE-Y" window-name template-y 250)
	  (create-trackbar "TEMPLATE-WIDTH" window-name template-width width)
	  (create-trackbar "TEMPLATE-HEIGHT" window-name template-height height) 
          (create-trackbar "TEMPLATE-WIDTH" window-name template-width width)
          ;;Trackbar to set the hessian keypoint detector threshold
	  (create-trackbar "MIN-HESSIAN" window-name min-hessian 30000) 
	  (with-mat ((frame (mat)))
	    (loop ;;Were using the camera feed as the image here and a
	       ;;region of interest of the feed as the template
	       (read cap frame)
	       ;;Instantiate logic for the location/dimensions 
	       ;;of the template based on the trackbar input
	       (if (equal (@ template-x :int) 0) 
		   (setf (@ template-x :int) 0))
	       (if (> (@ template-x :int) 
		      (- width (@ template-width :int))) 
		   (setf (@ template-x :int) 
			 (- width (@ template-width :int))))
	       (if (equal (@ template-y :int) 0) 
		   (setf (@ template-y :int) 1))
	       (if (> (@ template-y :int) 
		      (- height (@ template-height :int))) 
		   (setf (@ template-y :int) 
			 (- height (@ template-height :int))))
	       (if (< (@ template-width :int) 1) 
		   (setf (@ template-width :int) 1))
	       (if (< (@ template-height :int) 1) 
		   (setf (@ template-height :int) 1))
	       (with-rect ((roi (rect (@ template-x :int) (@ template-y :int)
				      (@ template-width :int) (@ template-height :int))))
		 ;;Set region of interest of FRAME to ROI. This 
                 ;;region of interest will be the template image.
		 (with-mat ((template (roi frame roi)))
		   (cvt-color template template +bgr2gray+)
		   (with-surf ((detector (surf (coerce (@ min-hessian :int) 'double-float)))
			       (extractor (gc:surf)))
		     ;;-- Step 1: Detect keypoints in the
                     ;;-- image and template using DETECT
		     (detect detector template keypoints-1)
		     (detect detector frame keypoints-2)
		     ;;-- Step 2: Calculate descriptors(feature vectors) 
                     ;;-- using the keypoints detected in the last step
		     (compute :feature-2d extractor template keypoints-1 descriptors-1)
		     (compute :feature-2d extractor frame keypoints-2 descriptors-2)
		     ;;-- Step 3: Match descriptor vectors with a brute force matcher
		     (match matcher descriptors-1 descriptors-2 matches)
		     ;;-- Draw matches
		     (draw-matches template keypoints-1 frame keypoints-2 matches img-matches)
		     ;;-- Show detected matches
		     (imshow window-name img-matches))))
	       (let ((c (wait-key 33)))
		 (when (= c 27)
		   (return))))))))))

========================================================================================================================================
#FEATURES2D - #COMMON INTERFACES OF DESCRIPTOR EXTRACTORS
========================================================================================================================================

========================================================================================================================================
#DESCRIPTOR-EXTRACTOR-COMPUTE
========================================================================================================================================

Computes the descriptors for a set of keypoints detected in an image


Note: The name DESCRIPTOR-EXTRACTOR-COMPUTE is used in the documentation to refer to the binding for the 
"compute" member of the OpenCV DescriptorExtractor class because it is more descriptive and it is easier 
to search for in this file. The COMPUTE method may also be used to call this binding.


C++: void DescriptorExtractor::compute(InputArray image, vector<KeyPoint>& keypoints, OutputArray descriptors) const

LISP-CV: (COMPUTE (TYPE SYMBOL) (SELF BF-MATCHER) (IMAGE MAT) (KEYPOINTS VECTOR-KEY-POINT) (DESCRIPTORS MAT)) => BF-MATCHER

LISP-CV: (COMPUTE (TYPE SYMBOL) (SELF BRISK) (IMAGE MAT) (KEYPOINTS VECTOR-KEY-POINT) (DESCRIPTORS MAT)) => BRISK

LISP-CV: (COMPUTE (TYPE SYMBOL) (SELF SURF) (IMAGE MAT) (KEYPOINTS VECTOR-KEY-POINT) (DESCRIPTORS MAT)) => SURF

LISP-CV: (DESCRIPTOR-EXTRACTOR-COMPUTE (SELF BF-MATCHER) (IMAGE MAT) (KEYPOINTS VECTOR-KEY-POINT) (DESCRIPTORS MAT)) => BF-MATCHER

LISP-CV: (DESCRIPTOR-EXTRACTOR-COMPUTE (SELF BRISK) (IMAGE MAT) (KEYPOINTS VECTOR-KEY-POINT) (DESCRIPTORS MAT)) => BRISK

LISP-CV: (DESCRIPTOR-EXTRACTOR-COMPUTE (SELF SURF) (IMAGE MAT) (KEYPOINTS VECTOR-KEY-POINT) (DESCRIPTORS MAT)) => SURF


    Parameters:	

        TYPE - A symbol. Must be specified as :DESCRIPTOR-EXTRACTOR.

        SELF - A BF-MATCHER, BRISK or SURF object.

        IMAGE - Image.

        KEYPOINTS - Input collection of keypoints. Keypoints for which a descriptor cannot be computed 
                    are removed. Sometimes new keypoints can be added, for example: SIFT duplicates keypoint 
                    with several dominant orientations (for each orientation).

        DESCRIPTORS - Computed descriptors. 



Example:

See the FEATURE-DETECTOR-CREATE-EXAMPLE in this file.

========================================================================================================================================
#DESCRIPTOR-EXTRACTOR-CREATE
========================================================================================================================================

Creates a descriptor extractor by name.


Note: The name DESCRIPTOR-EXTRACTOR-CREATE is used in the documentation to refer to the binding for the 
"create" member of the OpenCV DescriptorExtractor class because it is more descriptive and it is easier 
to search for in this file. The CREATE method may also be used to call this binding.


C++: Ptr<DescriptorExtractor> DescriptorExtractor::create(const String& descriptorExtractorType)

LISP-CV: (CREATE) (TYPE SYMBOL) (SELF BF-MATCHER) (DESCRIPTOR-EXTRACTOR-TYPE :STRING)) => BF-MATCHER

LISP-CV: (CREATE) (TYPE SYMBOL) (SELF BRISK) (DESCRIPTOR-EXTRACTOR-TYPE :STRING)) => BRISK

LISP-CV: (CREATE) (TYPE SYMBOL) (SELF SURF) (DESCRIPTOR-EXTRACTOR-TYPE :STRING)) => SURF

LISP-CV: (DESCRIPTOR-EXTRACTOR-CREATE) (SELF BF-MATCHER) (DESCRIPTOR-EXTRACTOR-TYPE :STRING)) => BF-MATCHER

LISP-CV: (DESCRIPTOR-EXTRACTOR-CREATE) (SELF BRISK) (DESCRIPTOR-EXTRACTOR-TYPE :STRING)) => BRISK

LISP-CV: (DESCRIPTOR-EXTRACTOR-CREATE) (SELF SURF) (DESCRIPTOR-EXTRACTOR-TYPE :STRING)) => SURF


    Parameters:	    

        TYPE - A symbol. Must be specified as :DESCRIPTOR-EXTRACTOR.

        SELF - A BF-MATCHER, BRISK or SURF object.

        DESCRIPTOR-EXTRACTOR-TYPE - Descriptor extractor type.


The current implementation supports the following types of a descriptor extractor:


        "SIFT" - SIFT

        "SURF" - SURF

        "BRIEF" - BriefDescriptorExtractor

        "BRISK" - BRISK

        "ORB" - ORB

        "FREAK" - FREAK


A combined format is also supported: descriptor extractor adapter name:
 
        ("Opponent" - OpponentColorDescriptorExtractor) 

+ descriptor extractor name (see above), for example: "OpponentSIFT".


Note: OpponentColorDescriptorExtractor is an internal OpenCV class that is called when you add the 
"Opponent" prefix to one of the descriptor extractor types listed above. It is not implemented in 
LISP-CV as a class or function.

Example:(Coming soon)

========================================================================================================================================
#FEATURES2D - #DRAWING FUNCTION OF KEYPOINTS AND MATCHES
========================================================================================================================================

========================================================================================================================================
#DRAW-KEYPOINTS
========================================================================================================================================

Draws keypoints.

C++: void drawKeypoints(InputArray image, const vector<KeyPoint>& keypoints, InputOutputArray outImage, 
                        const Scalar& color=Scalar::all(-1), int flags=DrawMatchesFlags::DEFAULT )

LISP-CV: (DRAW-KEYPOINTS (IMAGE MAT) (KEYPOINTS VECTOR-KEY-POINT) (OUT-IMAGE MAT) &OPTIONAL 
                        ((COLOR SCALAR) (SCALAR-ALL -1)) ((FLAGS :INT) +DRAW-MATCHES-FLAGS-DEFAULT+)) => :VOID

    Parameters:	

        IMAGE - Source image.

        KEYPOINTS - Keypoints from the source image.

        OUT-IMAGE - Output image. Its content depends on the FLAGS value defining what is drawn in 
                    the output image. See possible FLAGS bit values below.

        COLOR - Color of keypoints.

        FLAGS - Flags setting drawing features. See details below in (DRAW-MATCHES).


Example:


(defun draw-keypoints-example (&optional filename)

  (if (not filename) 
      (setf filename 
	    (cat *lisp-cv-images-dir* "Phoenician.jpg")))

  (let ((window-name "FAST Features - DRAW-KEYPOINTS Example"))
    (with-named-window (window-name +window-autosize+)
      (move-window window-name 560 175)
      (with-mat ((image (imread filename +load-image-color+)))
	(if (empty image) 
	    (return-from draw-keypoints-example 
	      (format t "Image not loaded")))
	(with-vector-key-point ((keypoints (vector-key-point)))
	  ;;Construction of the Fast feature detector object
	  (with-fast-feature-detector ((fast (fast-feature-detector 40)));threshold for detection
	    ;;Feature point detection
	    (detect fast image keypoints)
	    ;;Draw keypoints on an image
	    (draw-Keypoints image ;Original image
			    keypoints ;Vector of keypoints
			    image ;The output image
			    (t:scalar 255 255 255) ;Key point color
			    +draw-matches-flags-draw-over-outimg+ ;Drawing flag
			    )
	    (imshow window-name image)
	    (loop
	       (let ((c (wait-key 33)))
		 (when (= c 27)
		   (return))))))))))

========================================================================================================================================
#DRAW-MATCHES
========================================================================================================================================

Draws the found matches of keypoints from two images.

C++: void drawMatches(const Mat& img1, const vector<KeyPoint>& keypoints1, const Mat& img2, 
                      const vector<KeyPoint>& keypoints2, const vector<DMatch>& matches1to2, 
                      Mat& outImg, const Scalar& matchColor=Scalar::all(-1), 
                      const Scalar& singlePointColor=Scalar::all(-1), 
                      const vector<char>& matchesMask=vector<char>(), 
                      int flags=DrawMatchesFlags::DEFAULT )

LISP-CV: (DRAW-MATCHES (IMG1 MAT) (KEYPOINTS1 KEYPOINT) (IMG2 MAT) (KEYPOINTS2 KEYPOINT) (MATCHES1TO2 VECTOR-DMATCH) 
                       (OUT-IMG MAT) (MATCH-COLOR SCALAR) (SINGLE-POINT-COLOR SCALAR) &OPTIONAL ((MATCHES-MASK VECTOR-CHAR) 
                       (VECTOR-CHAR)) ((FLAGS :INT) +DRAW-MATCHES-FLAGS-DEFAULT+)) => :VOID


    Parameters:	

        IMG1 - First source image.

        KEYPOINTS1 - Keypoints from the first source image.

        IMG2 - Second source image.

        KEYPOINTS2 - Keypoints from the second source image.

        MATCHES1TO2 - Matches from the first image to the second one, which means that (KEYPOINTS1 I)
                      has a corresponding point in (KEYPOINTS2 (MATCHES I)).

        OUT-IMG - Output image. Its content depends on the flags value defining what is drawn in the 
                  output image. See possible flags bit values below.

        MATCH-COLOR - Color of matches (lines and connected keypoints). If (EQ MATCH-COLOR (SCALAR-ALL -1)) 
                      the color is generated randomly.

        SINGLE-POINT-COLOR - Color of single keypoints (circles), which means that keypoints do not 
                             have the matches. If (EQ SINGLE-POINT-COLOR (SCALAR-ALL -1)) , the color 
                             is generated randomly.

        MATCHES-MASK - Mask determining which matches are drawn. If the mask is empty, all matches are drawn.

        FLAGS - Flags setting drawing features. Possible flags bit values are defined below.

This function draws matches of keypoints from two images in the output image. Match is a line connecting 
two keypoints (circles). The FLAGS parameters are defined as follows:

        +DRAW-MATCHES-FLAGS-DEFAULT+ - Output image matrix will be created (MAT-CREATE), i.e. existing memory of 
                                       output image may be reused. Two source images, matches, and single keypoints 
                                       will be drawn. For each keypoint, only the center point will be drawn (without 
                                       a circle around the keypoint with the keypoint size and orientation).

        +DRAW-MATCHES-FLAGS-DRAW-OVER-OUTIMG+ - Output image matrix will not be created (using MAT-CREATE). Matches 
                                                will be drawn on existing content of output image.

        +DRAW-MATCHES-FLAGS-NOT-DRAW-SINGLE-POINTS+ - Single keypoints will not be drawn.

        +DRAW-MATCHES-FLAGS-DRAW-RICH-KEYPOINTS+ - For each keypoint, the circle around keypoint with keypoint size
                                                   and orientation wilL be drawn.


Example:


(defun draw-matches-example (filename-1 filename-2) 

  "I use this example to show examples of the parameters of DRAW-MATCHES.
   See the documentation in EXAMPLES.LISP for more details on these para-
   meters. Each window is labeled, first, with the color used to define g-
   ood matches between images, the MATCH-COLOR parameter. Secondly the co-
   lor used to mark empty keypoints or non-matches, the SINGLE-POINT-COLOR 
   parameter. Finally, each window is labeled with the name of the flag u-
   sed to set drawing features for that particular window, for example:
 
      * BLUE * WHITE * NOT-DRAW-SINGLE-POINTS *
    
    Try using the box.png and box-in-scene.png images located inside the
    LISP-CV-MASTER/IMAGES directory to get a clearer understanding of th-
    is example the first time you run it."

  (let ((window-name-1 "RANDOM * RANDOM * DEFAULT")
	(window-name-2 "PURPLE * WHITE * DRAW-OVER-OUTIMG")
	(window-name-3 "BLUE * WHITE * NOT-DRAW-SINGLE-POINTS")
	(window-name-4 "WHITE * RANDOM * DRAW-RICH-KEYPOINTS")
	;; Set brisk parameters
	(thresh 60)
	(octaves 4)
	(pattern-scale 2.0f0))
    (with-named-window (window-name-1 +window-normal+)
      (with-named-window (window-name-2 +window-normal+)
	(with-named-window (window-name-3 +window-normal+)
	  (with-named-window (window-name-4 +window-normal+)
	    (move-window window-name-1 485 98)
	    (move-window window-name-2 894 98)
	    (move-window window-name-3 485 444)
	    (move-window window-name-4 894 444)
	    ;; Declare feature detector
	    (with-brisk ((briskd (brisk thresh octaves pattern-scale)))
	      ;; Declare matcher
	      (with-bf-matcher ((matcher (bf-matcher)))
		;; The object you want to track 
		(with-mat ((object (imread filename-1 +load-image-grayscale+))
			   ;; The image the object is a part of
			   (image (imread filename-2 +load-image-grayscale+))
			   ;; Matrices used to hold the descriptors
			   (descriptors-a (mat))
			   (descriptors-b (mat))) 
		  ;; Vectors used to hold the keypoints
		  (with-vector-key-point ((keypoints-a (vector-key-point))
					  (keypoints-b (vector-key-point)))
		    (with-vector-dmatch ((matches (vector-dmatch)))

		      (if (empty (or object image)) 
			  (return-from draw-matches-example 
			    (format t "Both images were not loaded")))

		      ;; Create a feature detector
		      (create :feature-detector briskd "SimpleBlob")
		      ;; Detect keypoints in OBJECT
		      (detect briskd object keypoints-a)
		      ;; Compute the descriptors for a set of keypoints detected in object
		      (compute :feature-2d briskd object keypoints-a descriptors-a)
		      ;; Detect keypoints in IMAGE
		      (detect briskd image keypoints-b)
		      ;; Compute the descriptors for a set of keypoints detected in IMAGE
		      (compute :feature-2d briskd image keypoints-b descriptors-b)
		      ;; Find the best match for each descriptor
		      (match matcher descriptors-a descriptors-b matches)
		      ;; Draw the found matches and show in a window, 
		      ;; four times, each with different parameters
		      (with-mat ((all-matches (mat)))
			(draw-matches object keypoints-a image keypoints-b matches all-matches 
				      (gc:scalar-all -1) (gc:scalar-all -1) (gc:vector-char) 
				      +draw-matches-flags-default+)
			(imshow window-name-1 all-matches))
		      (with-mat ((all-matches (mat (rows image) (+ (cols image) (cols image)) 16)))
			(draw-matches object keypoints-a image keypoints-b matches all-matches 
				      (gc:scalar 255 0 128) (gc:scalar 255 255 255) (gc:vector-char)
				      +draw-matches-flags-draw-over-outimg+)
			(imshow window-name-2 all-matches))
		      (with-mat ((all-matches (mat)))
			(draw-matches object keypoints-a image keypoints-b matches all-matches 
				      (gc:scalar 255 0 0) (gc:scalar 255 255 2555) (gc:vector-char)
				      +draw-matches-flags-not-draw-single-points+)
			(imshow window-name-3 all-matches))
		      (with-mat ((all-matches (mat)))
			(draw-matches object keypoints-a image keypoints-b matches all-matches 
				      (gc:scalar-all 255) (gc:scalar-all -1) (gc:vector-char) 
				      +draw-matches-flags-draw-rich-keypoints+)
			(imshow window-name-4 all-matches))
		      (loop
			 (let ((c (wait-key 33)))
			   (when (= c 27)
			     (return)))))))))))))))

========================================================================================================================================
#FEATURES2D - #COMMON INTERFACES OF DESCRIPTOR MATCHERS
========================================================================================================================================

========================================================================================================================================
#BF-MATCHER
========================================================================================================================================

Brute-force matcher constructor.

Note: Both BF-MATCHER and MAKE-BF-MATCHER are provided in this library. The first, to match OpenCV's naming 
conventions, the second, to adhere to Common Lisp naming conventions. Except for the name, they are 
the same function. I use the BF-MATCHER function in the examples in this file because it will make them 
easier to compare with OpenCV examples you find online, thus making this library easier to learn.

C++: BFMatcher::BFMatcher(int normType=NORM_L2, bool crossCheck=false )

LISP-CV:  (BF-MATCHER &OPTIONAL ((NORM-TYPE :INT) +NORM-L2+) ((CROSS-CHECK :BOOLEAN) NIL)) => BF-MATCHER

LISP-CV:  (MAKE-BF-MATCHER &OPTIONAL ((NORM-TYPE :INT) +NORM-L2+) ((CROSS-CHECK :BOOLEAN) NIL)) => BF-MATCHER


    Parameters:	

        NORM-TYPE - One of +NORM-L1+, +NORM-L2+, +NORM-HAMMING+, +NORM-HAMMING2+. L1 and L2 norms 
                    are preferable choices for SIFT and SURF descriptors, +NORM-HAMMING+ should be 
                    used with ORB, BRISK and BRIEF, +NORM-HAMMING2+ should be used with ORB when 
                    (EQ WTA-K 3) or (EQ WTA-K 4) (see ORB constructor description).

        CROSS-CHECK - If it is false, this is will be default BF-MATCHER behaviour when it finds the 
                      k nearest neighbors for each query descriptor. If (EQ CROSS-CHECK T), then the 
                      (KNN-MATCH) method with (EQ K 1) will only return pairs (i,j) such that for i-th 
                      query descriptor the j-th descriptor in the matcher’s collection is the nearest 
                      and vice versa, i.e. the BF-MATCHER will only return consistent pairs. Such technique 
                      usually produces best results with minimal number of outliers when there are enough 
                      matches. This is alternative to the ratio test, used by D. Lowe in SIFT paper.


Example:

See BRISK-EXAMPLE in this file.

========================================================================================================================================
#DESCRIPTOR-MATCHER-MATCH
========================================================================================================================================

Finds the best match for each descriptor from a query set.


Note: The name DESCRIPTOR-MATCHER-MATCH is used in the documentation to refer to the binding for the 
"match" member of the OpenCV DescriptorMatcher class because it is more descriptive and it is easier 
to search for in this file. The MATCH method may also be used to call this binding.


C++: void DescriptorMatcher::match(InputArray queryDescriptors, InputArray trainDescriptors, vector<DMatch>& matches, 
     InputArray mask=noArray() ) const

LISP-CV: (MATCH (SELF BF-MATCHER) (QUERY-DESCRIPTORS MAT) (TRAIN-DESCRIPTORS MAT) (MATCHES VECTOR-DMATCH) &OPTIONAL
                (MASK MAT)) => :VOID

LISP-CV: (MATCH (SELF BRISK) (QUERY-DESCRIPTORS MAT) (TRAIN-DESCRIPTORS MAT) (MATCHES VECTOR-DMATCH) &OPTIONAL
                (MASK MAT)) => :VOID

LISP-CV: (MATCH (SELF SURF) (QUERY-DESCRIPTORS MAT) (TRAIN-DESCRIPTORS MAT) (MATCHES VECTOR-DMATCH) &OPTIONAL
                (MASK MAT)) => :VOID

LISP-CV: (DESCRIPTOR-MATCHER-MATCH (SELF BF-MATCHER) (QUERY-DESCRIPTORS MAT) (TRAIN-DESCRIPTORS MAT) (MATCHES VECTOR-DMATCH) &OPTIONAL
                                   (MASK MAT)) => :VOID

LISP-CV: (DESCRIPTOR-MATCHER-MATCH (SELF BRISK) (QUERY-DESCRIPTORS MAT) (TRAIN-DESCRIPTORS MAT) (MATCHES VECTOR-DMATCH) &OPTIONAL
                                   (MASK MAT)) => :VOID

LISP-CV: (DESCRIPTOR-MATCHER-MATCH (SELF SURF) (QUERY-DESCRIPTORS MAT) (TRAIN-DESCRIPTORS MAT) (MATCHES VECTOR-DMATCH) &OPTIONAL
                                   (MASK MAT)) => :VOID


    Parameters:	

        SELF - A BF-MATCHER. BRISK or SURF object,

        QUERY-DESCRIPTORS - Query set of descriptors.

        TRAIN-DESCRIPTORS - Train set of descriptors. This set is not added to the train descriptors 
                            collection stored in the class object.

        MATCHES - Matches. If a query descriptor is masked out in mask , no match is added for this 
                  descriptor. So, matches size may be smaller than the query descriptors count.

        MASK - Mask specifying permissible matches between an input query and train matrices of descriptors.



In this method the train descriptors are passed as an input argument. An optional mask can be passed 
to specify which query and training descriptors can be matched. Namely, (QUERY-DESCRIPTORS I) can be 
matched with (TRAIN-DESCRIPTORS J) only if (AT MASK I J :UCHAR) is non-zero.


Example:

See BRISK-EXAMPLE

========================================================================================================================================
#FLANN-BASED-MATCHER
========================================================================================================================================

Flann-based matcher constructor.

Note: Both FLANN-BASED-MATCHER and MAKE-FLANN-BASED-MATCHER are provided in this library. The first, 
to match OpenCV's naming conventions, the second, to adhere to Common Lisp naming conventions. Except 
for the name, they are the same function. I use the FLANN-BASED-MATCHER function in the examples in this 
file because it will make them easier to compare with OpenCV examples you find online, making this library 
easier to learn.


C++: FlannBasedMatcher( const Ptr<flann::IndexParams>& indexParams=makePtr<flann::KDTreeIndexParams>(),
                       const Ptr<flann::SearchParams>& searchParams=makePtr<flann::SearchParams>() );

LISP-CV:  (FLANN-BASED-MATCHER) => FLANN-BASED-MATCHER

LISP-CV:  (MAKE-FLANN-BASED-MATCHER) => FLANN-BASED-MATCHER

Note: Until an issue is resolved, concerning the OpenCv class Ptr, in the C bindings this library 
binds to, only the uninitialized FLANN-BASED-MATCHER constructor will be available.

Description:

Flann-based descriptor matcher. This matcher trains flann::Index_(internal C++ class) on a train 
descriptor collection and calls its nearest search methods to find the best matches. So, this matcher 
may be faster when matching a large train collection than the brute force matcher(BF-MATCHER in Lisp-CV). 
FLANN-BASED-MATCHER does not support masking permissible matches of descriptor sets because flann::Index 
does not support this.


Example:

(defun flann-based-matcher-example (filename-1 filename-2) 

  "Try using the box.png and the box-in-scene.png from
   the LISP-CV-MASTER/IMAGES directory to get a better 
   understanding of this example the first time you ru-
   n it."

  (let ((window-name "Good Matches & Object detection - FLANN-BASED-MATCHER Example")
	(min-hessian 400d0)
	(min-dist 100)
	(max-dist 0)
	(dist)) 

    ;;;Read in images in grayscale;

    ;;...the object you want to track,
    (with-mat ((img-object (imread filename-1 +load-image-grayscale+))
	       ;;...the image the object is a part of.
	       (img-scene (imread filename-2 +load-image-grayscale+))
	       (descriptors-object (mat))
	       (descriptors-scene (mat))
	       (img-matches (mat)))
      (with-vector-key-point ((keypoints-object (vector-key-point))
			      (keypoints-scene (vector-key-point)))
	(with-vector-dmatch ((matches (vector-dmatch)))
	  (with-flann-based-matcher ((matcher (flann-based-matcher)))
	    (if (empty (or img-object img-scene)) 
		(return-from flann-based-matcher-example 
		  (format t "Error reading images.")))
	    (with-named-window (window-name +window-autosize+)
	      (move-window window-name 541 175)
	      ;;Detect keypoints using SURF.
	      (with-surf ((detector (surf min-hessian))
			  (extractor (surf)))
		(detect detector img-object keypoints-object)
		(detect detector img-scene keypoints-scene)
		;;Calculate descriptors (feature vectors).
		(compute :feature-2d extractor img-object keypoints-object descriptors-object)
		(compute :feature-2d extractor img-scene keypoints-scene descriptors-scene)
		;;Matching descriptor vectors using FLANN matcher.
		(match matcher descriptors-object descriptors-scene matches)
		;;Quick calculation of max and min distances between keypoints.
		(dotimes (i (rows descriptors-object))
		  (setf dist (distance (@ matches i)))
		  (if (< dist min-dist) (setf min-dist dist))
		  (if (> dist max-dist) (setf dist max-dist)))
		(format t "-- Max dist: ~a ~%" max-dist)
		(format t "-- Min dist: ~a ~%"  min-dist)
		;;Draw only "good" matches (i.e. whose distance is less than (* 3 MIN-DIST).
		(with-vector-dmatch ((good-matches (vector-dmatch)))
		  (dotimes (i (rows descriptors-object))
		    (if (< (distance (@ matches i)) (* 3 min-dist))
			(push-back good-matches (@ matches i))))
		  (draw-matches img-object keypoints-object img-scene keypoints-scene good-matches 
				img-matches (t:scalar-all -1) (t:scalar-all -1) (t:vector-char) 
				+draw-matches-flags-not-draw-single-points+)
                  ;;;Localize the object.
		  (with-mat ((obj (mat (length good-matches) 2 +32f+))
			     (scene (mat (length good-matches) 2 +32f+)))
		    (dotimes (i (length good-matches))
		      ;;Get the keypoints from the good matches.
		      (setf (@ :float obj i 0) (x (@ keypoints-object (query-idx (@ good-matches i)))))
		      (setf (@ :float obj i 1) (y (@ keypoints-object (query-idx (@ good-matches i)))))
		      (setf (@ :float scene i 0) (x (@ keypoints-scene (train-idx (@ good-matches i)))))
		      (setf (@ :float scene i 1) (y (@ keypoints-scene (train-idx (@ good-matches i))))))
		    (with-mat ((h (find-homography obj scene +ransac+)))
		      ;;Get the corners from IMAGE-OBJ(the object to be "detected").
		      (with-mat ((obj-corners 
				  (mat 4 2 +32fc2+ (list 0f0 0f0
							 (float (cols img-object)) 0f0
							 (float (cols img-object)) (float (rows img-object)) 
							 0f0 (float (rows img-object)))))
				 (scene-corners (mat 4 2 +32fc2+)))
			(perspective-transform obj-corners scene-corners h)
			;;Draw lines between the corners (the mapped object in the scene, IMAGE-SCENE).
			(line img-matches (t:point 
					   (floor (+ (@ :float scene-corners 0 0) (cols img-object))) 
					   (floor (@ :float scene-corners 0 1)))
			      (t:point 
			       (floor (+ (@ :float scene-corners 0 2) (cols img-object))) 
			       (floor (@ :float scene-corners 0 3)))
			      (t:scalar 0 255 0) 4)
			(line img-matches (t:point 
					   (floor (+ (@ :float scene-corners 0 2) (cols img-object))) 
					   (floor (@ :float scene-corners 0 3))) 
			      (t:point (floor (+ (@ :float scene-corners 1 0) (cols img-object))) 
				       (floor (@ :float scene-corners 1 1)))
			      (t:scalar 0 255 0) 4)
			(line img-matches (t:point
					   (floor (+ (@ :float scene-corners 1 0) (cols img-object)))
					   (floor (@ :float scene-corners 1 1))) 
			      (t:point 
			       (floor (+ (@ :float scene-corners 1 2) (cols img-object))) 
			       (floor (@ :float scene-corners 1 3)))
			      (t:scalar 0 255 0) 4)
			(line img-matches (t:point 
					   (floor (+ (@ :float scene-corners 1 2) (cols img-object))) 
					   (floor (at-float scene-corners 1 3))) 
			      (t:point 
			       (floor (+ (@ :float scene-corners 0 0) (cols img-object))) 
			       (floor (@ :float scene-corners 0 1)))
			      (t:scalar 0 255 0) 4)
			;;Show detected matches.
			(imshow window-name img-matches)
			(loop
			   (let ((c (wait-key 33)))
			     (when (= c 27)
			       (return))))))))))))))))

========================================================================================================================================
#OBJDETECT - #CASCADE CLASSIFICATION
========================================================================================================================================

========================================================================================================================================
#CASCADE-CLASSIFIER
========================================================================================================================================

Creates a CASCADE-CLASSIFIER object or loads a classifier from a file.

Note: Both CASCADE-CLASSIFIER and MAKE-CASCADE-CLASSIFIER are provided in this library. The first, 
to match OpenCV's naming conventions, the second, to adhere to Common Lisp naming conventions. Except 
for the name, they are the same function. I use the CASCADE-CLASSIFIER function in the examples in this 
file because it will make them easier to compare with OpenCV examples you find online, thus making this 
library easier to learn.

C++: CascadeClassifier::CascadeClassifier()

C++: CascadeClassifier::CascadeClassifier(const string& filename)

LISP-CV: (CASCADE-CLASSIFIER) => CASCADE-CLASSIFIER

LISP-CV: (MAKE-CASCADE-CLASSIFIER) => CASCADE-CLASSIFIER

LISP-CV: (CASCADE-CLASSIFIER (FILENAME :STRING)) => CASCADE-CLASSIFIER

LISP-CV: (MAKE-CASCADE-CLASSIFIER (FILENAME :STRING)) => CASCADE-CLASSIFIER


    Parameters:	

        SELF - A CASCADE-CLASSIFIER object

        FILENAME - Name of the file from which the classifier is loaded.


Example:

Create an uninitialized CASCADE-CLASSIFIER object

CV> (DEFPARAMETER FACE-CASCADE (CASCADE-CLASSIFIER))

FACE-CASCADE


Create a CASCADE-CLASSIFIER object initialized with an XML classifier 

CV> (DEFPARAMETER FACE-CASCADE-NAME "<opencv-source-directory>/data/haarcascades/haarcascade_frontalface_alt.xml")

FACE-CASCADE-NAME

CV> (DEFPARAMETER FACE-CASCADE (CASCADE-CLASSIFIER FACE-CASCADE-NAME))

FACE-CASCADE

========================================================================================================================================
#CASCADE-CLASSIFIER-LOAD
========================================================================================================================================

Loads a classifier from a file.

C++: bool CascadeClassifier::load(const string& filename)

LISP-CV: (CASCADE-CLASSIFIER-LOAD (SELF CASCADE-CLASSIFIER) (FILENAME :STRING)) => :BOOLEAN


    Parameters:	

        SELF - A CASCADE-CLASSIFIER object

        FILENAME - Name of the file from which the classifier is loaded. The file may contain an old 
                   HAAR classifier trained by the haartraining application or a new cascade classifier 
                   trained by the traincascade application.


Example:


CV> (DEFPARAMETER FACE-CASCADE-NAME "<opencv_source_directory>/data/haarcascades/haarcascade_frontalface_alt.xml")

FACE-CASCADE-NAME

CV> (DEFPARAMETER FACE-CASCADE (CASCADE-CLASSIFIER)) ;Create CASCADE-CLASSIFIER object 

FACE-CASCADE

CV> (CASCADE-CLASSIFIER-LOAD FACE-CASCADE FACE-CASCADE-NAME)  ;Load the Classifier

T <--- Operation successful


========================================================================================================================================
#DETECT-MULTI-SCALE
========================================================================================================================================

Detects objects of different sizes in the input image. The detected objects are returned as a list of rectangles.

C++: void CascadeClassifier::detectMultiScale(InputArray image, vector<Rect>& objects, double scaleFactor=1.1, 
                                              int minNeighbors=3, int flags=0, Size minSize=Size(), 
                                              Size maxSize=Size())

LISP-CV: (DETECT-MULTI-SCALE (SELF CASCADE-CLASSIFIER) (IMAGE MAT) (OBJECTS VECTOR-RECT) &OPTIONAL 
                            ((SCALE-FACTOR :DOUBLE) 1.1D0) ((MIN-NEIGHBORS :INT) 3) ((FLAGS :INT) 0) 
                            ((MIN-SIZE SIZE) (SIZE-0)) ((MAX-SIZE SIZE) (SIZE-0))) => :VOID

C++: void CascadeClassifier::detectMultiScale(InputArray image, vector<Rect>& objects, vector<int>& numDetections, 
                                              double scaleFactor=1.1, int minNeighbors=3, int flags=0, 
                                              Size minSize=Size(), Size maxSize=Size())

LISP-CV: (DETECT-MULTI-SCALE (SELF CASCADE-CLASSIFIER) (IMAGE MAT) (OBJECTS VECTOR-RECT) (NUM-DETECTIONS VECTOR-INT) 
                              &OPTIONAL (SCALE-FACTOR :DOUBLE) 1.1D0) ((MIN-NEIGHBORS :INT) 3) ((FLAGS :INT) 0)
                            ((MIN-SIZE SIZE) (SIZE-0)) ((MAX-SIZE SIZE) (SIZE-0))) => :VOID

C++: void CascadeClassifier::detectMultiScale(const Mat& image, vector<Rect>& objects, std::vector<int>& rejectLevels, 
                                              vector<double>& levelWeights, double scaleFactor = 1.1, int minNeighbors = 3, 
                                              int flags = 0, Size minSize = Size(), Size maxSize = Size(), 
                                              bool outputRejectLevels = false )

LISP-CV: (DETECT-MULTI-SCALE (SELF CASCADE-CLASSIFIER) (IMAGE MAT) (OBJECTS VECTOR-RECT) (NUM-DETECTIONS VECTOR-INT) &OPTIONAL 
         (SCALE-FACTOR :DOUBLE) 1.1D0) ((MIN-NEIGHBORS :INT) 3) ((FLAGS :INT) 0) ((MIN-SIZE SIZE) (SIZE-0)) 
         ((MAX-SIZE SIZE) (SIZE-0))) => :VOID


    Parameters:	

        SELF - A CASCADE-CLASSIFIER object

        IMAGE - Matrix of the type +8U+ containing an image where objects are detected.

        OBJECTS - Vector of rectangles where each rectangle contains the detected object, the rectangles
                  may be partially outside the original image.

        NUM-DETECTIONS - Vector of detection numbers for the corresponding objects. An object’s number 
                         of detections is the number of neighboring positively classified rectangles 
                         that were joined together to form the object.

        SCALE-FACTOR - Parameter specifying how much the image size is reduced at each image scale.

        MINN-EIGHBORS - Parameter specifying how many neighbors each candidate rectangle should have to retain it.

        FLAGS - Can be one of the following:

                              +CASCADE-DO-CANNY-PRUNING+ 

                              +CASCADE-SCALE-IMAGE+ 

                              +CASCADE-FIND-BIGGEST-OBJECT+ 

                              +CASCADE-DO-ROUGH-SEARCH+  

        MIN-SIZE - Minimum possible object size. Objects smaller than that are ignored.

        MAX-SIZE - Maximum possible object size. Objects larger than that are ignored.

This function is parallelized with the TBB library.


;Global variables

;;Path to the classifier.
(defparameter face-cascade-name "<opencv-src-dir>/data/haarcascades/haarcascade_frontalface_default.xml")
;;Create CASCADE-CLASSIFIER object.
(defparameter face-cascade (cascade-classifier))
;;Number of file to be saved.
(defparameter filenumber 0)
;;Name of file to be saved. 
(defparameter filename 0) 
(defparameter crop (mat))



(defun detect-and-display (frame)

  (let ((text 0)
        (num-buffers 2)
        (size-factor 1.1d0)
	(area-current 0) 
	(index-biggest 0)
	(area-biggest 0) 
	(faces-list 0))
    (with-vector-rect ((faces (vector-rect)))
      (with-mat ((frame-gray (mat))
		 (res (mat))
		 (gray (mat)))
	(cvt-color frame frame-gray +bgr2gray+)
	(equalize-hist frame-gray frame-gray)
	;;Detect faces.
	(with-size ((face-size (size 30 30)))
	  (detect-multi-scale face-cascade frame-gray faces size-factor 
			      num-buffers +cascade-do-canny-pruning+ face-size) 1)
	;;Convert VECTOR-RECT to a Lisp list for speed.
	(setf faces-list (vector-rect :to-lisp-list faces))
	;;Set Region of Interest...
	(with-rect ((roi (rect)))
	  ;;Iterate through all current elements (detected faces).
	  (dotimes (index-current (length faces-list))
	    ;;Get the area of current element (detected face)
            ;;AREA-CURRENT is area of current element.
	    (setf area-current (* (width (nth index-current faces-list))  ;AREA-CURRENT is area 
   				  (height (nth index-current faces-list)))) ;of current element.
            ;;INDEX-BIGGEST is index of the biggest element.
	    (setf roi (gc:clone (nth index-biggest faces-list))) 

	    ;;Get the area of biggest element, at the.
            ;;beginning it is same as current element.
	    
            ;;AREA-BIGGEST is area of the biggest element.
	    (setf area-biggest (* (width (nth index-biggest faces-list)) 
                                  (height (nth index-biggest faces-list)))) 
            (if (> area-current area-biggest)
		(progn 
		  (setf index-biggest index-current)
		  (setf roi (gc:clone (nth index-biggest faces-list)))) nil)

	    (setf crop (gc:roi frame roi))
	    ;;This will be needed later while saving images.
	    (resize crop res (size 128 128) 0d0 0d0 +inter-linear+)
	    ;;Convert cropped image to Grayscale.
	    (cvt-color crop gray +bgr2gray+)
	    ;;Form a filename. It is suggested that you create a directory to 
            ;;put the cropped images in because there will be a lot or them.
	    (setf filename (concatenate 'string "/home/user/Pictures/my-face/my-face-" 
					(write-to-string filenumber) ".png"))
	    (incf filenumber)
            ;;Write cropped images to directory
            ;;you specified in previous step.
	    (imwrite filename gray)
	    ;;Display detected faces on main window - live stream from camera.
	    (with-point ((pt1 (point (x (nth index-current faces-list)) 
				     (y (nth index-current faces-list))))
			 (pt2 (point (+ (x (nth index-current faces-list)) 
					(height (nth index-current faces-list)))
				     (+ (y (nth index-current faces-list)) 
					(width (nth index-current faces-list))))))
	      (with-scalar ((color1 (scalar 0 255 0)))
		(rectangle frame pt1 pt2 color1 2 8 0))))

	  (setf text (concatenate 'string "Crop area size: " 
				  (write-to-string (width roi)) "x" 
				  (write-to-string (height roi)) " Filename: " 
				  (write-to-string filename))))
	(with-point ((org (point 2 30)))
	  (with-scalar ((color2 (scalar 0 0 255)))	
	    (put-text frame text org +font-hershey-complex-small+ 
		      0.66d0 color2 1 +aa+)))))))



(defun detect-multi-scale-example (&optional 
				     (cam *camera-index*) 
				     (width *default-width*)
				     (height *default-height*))

  ;;Setting width/height to 2 less than default width/height vastly
  ;;improves the speed of DETECT-MULTI-SCALE in this example.
  (with-captured-camera (cap cam :width width :height height)
    (let ((window-name "Original - DETECT-MULTI-SCALE Example"))
      ;;Check if camera is opened.
      (if (not (is-opened cap)) 
	  (return-from detect-multi-scale-example 
	    (format t "Cannot open the video camera")))
      ;;Load the classifier.
      (if (not (cascade-classifier-load face-cascade face-cascade-name))
	  (return-from detect-multi-scale-example 
	    (format t "Error Loading")))
      (with-named-window (window-name +window-autosize+)
	(move-window window-name 0 300)
	(format t "~%Frame Size : ~ax~a~%~%" 
		(get* cap +cap-prop-frame-width+)
		(get* cap +cap-prop-frame-height+))
	(with-mat ((frame (mat)))
	  (loop
             ;;Read the video stream.
	     (read cap frame)
	     (if (not (empty frame)) 
		 ;;Apply the classifier to the frame.
		 (detect-and-display frame)
		 (format t "No captured frame: Break!"))
	     ;;Show camera feed.
	     (imshow window-name frame)
	     ;;Show image.
	     (if (not (empty crop)) 
		 (progn (imshow "Detected" crop)
			(setf crop (gc:mat)))
		 (destroy-window "Detected"))
	     (let ((c (wait-key 33)))
	       (when (= c 27)
		 (destroy-window "Detected")
		 (return)))))))))

========================================================================================================================================
#ML - #LISP-CV SPECIFIC FUNCTIONS
========================================================================================================================================

========================================================================================================================================
#MAKE-TRAINING-MATRIX
========================================================================================================================================

Constructs single-float training data matrix.

C++: Specific to LISP-CV.

LISP-CV: (MAKE-TRAINING-MATRIX &KEY (DIRECTORY :STRING) (DIRECTORY-CONTENTS KEYWORD) (DSIZE :INT)) => MAT


    Parameters:

        DIRECTORY - Directory of square images: (AND (EQ (ROWS IMG) (COLS IMG))).

        DIRECTORY-CONTENTS - Keyword flag, either :DIRECTORIES or :FILES, specifying whether or not 
                             the provided DIRECTORY argument(a pathname) contains only files or only 
                             directories(must be one or the other).

        DSIZE - The new rows and cols value each image in DIRECTORY is resized to before being added 
                into the output training data matrix. (WIDTH DSIZE) and (HEIGHT DSIZE) must be equal. 
                The bigger the DSIZE value, the longer this function takes to run, This function was 
                tested with 1016 input images, sized 128x128, and a DSIZE argument of (SIZE 50 50) on 
                a two core 3.2GHZ chip. Running time in that configuration took about 0.8 seconds.


To train specific Machine Learning functions in this library on a set of images, first you have to 
construct the training matrix. This function creates that matrix. The training matrix is specified 
as follows: each row of the matrix corresponds to one image, and each element in that row corresponds 
to one feature of the class, in this case, the color of the pixel at a certain point. The pathname 
given to this function must be a directory containing square images of the same size/type. 

First, this function loads all the images in the specified directory. Then, it resizes them, to the 
size specified with the DSIZE parameter, and reshapes them to 1D. Finally, this function pushes the, 
images, one image per row, to the output training data matrix. 

Note: The output matrix must be garbage collected, You can use manual MM(DEL-MAT function), a with-* 
macro (the WITH-MAT macro) or you can enable automatic finalization by adding a GC: or T: prefix to 
the functions name.


Example:

(defun make-labels-matrix (&key training-matrix)

  (let ((labels (mat (rows training-matrix) 1 +32fc1+)))
    (dotimes (i (rows labels))
      ;;@ sets and returns a matrix element.
      (setf (@ :float labels i 0) (+ i 1f0)))
    labels))

(defun make-training-matrix-example (training-image-directory test-image)

  "This example performs OCR using Support Vector Machines. It is a basic, 
   but powerful, example of the right way to create a training matrix filled 
   with images to give to LISP-CV's SVM train method. The name, SVM, for Support 
   Vector Machines, is the name bindings for the OpenCV class CvSVM are referred to
   by in this library.
  
   Note: It is reccommended, to get the full effect of this example, you download 
   the link in the:
   
    <LISP-CV-SRC-DIR>/IMAGES/OCR-TRAINING-DATA/
   
   folder, un-tar it, and pick a folder inside the resultant: 
   
   /English/Fnt/
   
   folder to use as the :DIRECTORY argument, to the function we will use to 
   create our OCR training data matrix in this example, the LISP-CV specific, 
   MAKE-TRAINING-MATRIX function. Each folder, inside the Fnt folder, contains 
   a total of 1016 images of a specific number, upper-case letter or a lower-case 
   letter. And those images will be used to tell the SVM what a variety of a specific 
   letter or number looks like, so when you add a single image from the folder you gave 
   to the MAKE-TRAINING-MATRIX function, as the TEST-IMAGE parameter to this example, the 
   SVM PREDICT method will be able to predict what image, out of 1016 images in the folder, 
   that it was.  Remember, when you give a pathname to the MAKE-TRAINING-MATRIX function, 
   to include a trailing backslash."
  
;;; Let's get started!

  ;; First, we set the size parameter, that each 
  ;; of the 1016 images in the selected folder, 
  ;; will be resized to. If you used the images
  ;; that I suggested in the intro to this examp-
  ;; le, for best results, you should leave the 
  ;; DSIZE parameter as is.
  (with-size ((dsize (size 128 128)))
    ;; Here we create the training matrix using the MAKE-TRAINING-MATRIX function.
    ;; This functions adds all of the images in the TRAINING-IMAGE-DIRECTORY into 
    ;; TRAINING-MAT, as 1D images, one image per row.
    (with-mat ((training-mat (make-training-matrix training-image-directory :files dsize))
	       ;; Here we make a labels matrix with the MAKE-LABELS-MATRIX function
	       ;; above, that we will later give to the SVM TRAIN method. A labels 
	       ;; matrix is specified as a 1D matrix, where each element in the 1D 
	       ;; matrix corresponds to each row(an image) in the 2D matrix. e.g.
	       ;; since there are 1016 images in TRAINING-MAT, the labels matrix w-
	       ;; ill have 1016 rows, each row having one element, a number, from 
	       ;; 1 to 1016. So in this example if image 1 is in the first row of 
	       ;; TRAINING-MAT, then the first row of LABELS-MAT will have a 1.0d0
	       ;; (double float) in it, and so on. 
	       (labels-mat (make-labels-matrix :training-matrix training-mat))
	       ;; Load the test image.
	       (image (imread test-image +load-image-grayscale+)))

      ;; Convert TEST-IMAGE to single-float.
      (convert-to image image +32fc1+)
      
      ;; Resize TEST-IMAGE to match the size of 
      ;; the images in TRAINING-MAT. Not needed 
      ;; but performed anyways in case you want 
      ;; to change the DSIZE parameter. 
      (resize image image dsize)

      ;; Create SVM-PARAMS object 
      ;; and set its parameters.
      (with-svm-params ((params (svm-params)))
	(setf (degree params) 1d0)
	(setf (svm-type params) +svm-c-svc+)
	(setf (kernel-type params) +svm-poly+)
	(setf (gamma params) 3d0)

	;; Create an SVM object.
	(with-svm ((svm (svm)))
	  ;; Train SVM based on the data entered.
	  (with-mat ((mat (mat)))
	    (format t "~%Training the SVM...this may take a few seconds...")
	    (train svm training-mat labels-mat mat mat params))
	  (format t "~%~%Training Complete!!!")
	  ;; Convert TEST-IMAGE to 1D matrix
	  (with-mat ((1d-image (reshape image 0 1)))
	    
	    ;; Predict which, of the 1016 images in the
	    ;; TRAINING-IMAGE-DIRECTORY, you specified 
	    ;; as TEST-IMAGE.
	    (with-mat ((results (mat))) ;Create output matrix to hold the results
					;(to show another method of obtaining them).
	      (format t "~%~%Prediction..you entered image number ~a as TEST-IMAGE.~%~%" 
		      (round (svm-predict svm 1d-image nil)))
	      ;;Print RESULTS
              (format t "Results matrix => ")
	      (print-mat results)
              (format t "~%"))

	    ;; Create a window to show TEST-IMAGE in.
	    (let ((window-name "TEST-IMAGE - MAKE-TRAINING-MATRIX-EXAMPLE"))
	      (with-named-window (window-name +window-normal+)
		(move-window window-name 759 175)

		;; Show TEST-IMAGE in a window
		(imshow window-name image)

		(loop
		   (let ((c (wait-key 33)))
		     (when (= c 27)
		       (return))))))))))))
  
========================================================================================================================================
#ML - #STATISTICAL-MODELS
========================================================================================================================================

========================================================================================================================================
#STAT-MODEL-LOAD
========================================================================================================================================

Loads the model from a file.

Note: The name STAT-MODEL-LOAD is used in the documentation to refer to the binding for the "load" 
member of the OpenCV CvStatModel class because it is more descriptive and it is easier to search for 
in this file. The LOAD method may also be used to call this binding.


C++: void CvStatModel::load(const char* filename, const char* name=0 )

LISP-CV: (LOAD (FILENAME :STRING) ((NAME :STRING) (CFFI::NULL-POINTER))) => :VOID

LISP-CV: (STAT-MODEL-LOAD (FILENAME :STRING) ((NAME :STRING) (CFFI::NULL-POINTER))) => :VOID


The method load loads the complete model state with the specified name (or default model-dependent 
name) from the specified XML or YAML file. The previous model state is cleared by STAT-MODEL-CLEAR.


Note:(to clarify) In OpenCV the CvStatModel class is the public class to the following OpenCV classes; 

CvSVM, CvANN_MLP, CvBoost, CvDTree, CvGBTrees, CvKNearest, CvNormalBayesClassifier, CvRTrees.

(LISP-CV variants: SVM, ANN-MLP, BOOST, D-TREE, GB-TREES, K-NEAREST, NORMAL-BAYES-CLASSIFIER, R-TREES). 

As a result of that the CvStatModel::load method in OpenCV as well as this binding can load any saved 
model state created with any of those classes train methods.


Example:

(defun stat-model-load-example (svm-model-state training-image-directory)

  "This is a continuation of the STAT-MODEL-SAVE-EXAMPLE. Try checking 
   out that example to get up to speed with this one. Once you are up to 
   speed, the SVM model state saved in the STAT-MODEL-SAVE-EXAMPLE is used 
   to predict which image you select with the trackbar.

   Usage: The SVM-MODEL-STATE parameter is the exact .yml file that you saved
          so it would be:
      
     'SAVE-DIRECTORY/SVM/ALPHANUMERIC/SVM_ALPHA_NUMERIC.yml'

          The TRAINING-IMAGE-DIRECTORY parameter is the same path supplied as 
          the TRAINING-IMAGE-DIRECTORY parameter in the STAT-MODEL-SAVE-EXAMPLE."

  ;;Make list of all the files in all the subfolders in TRAINING-IMAGE-DIRECTORY.
  (let ((pathname-list (make-pathname-list :directory 
					   (ensure-trailing-slash training-image-directory) 
					   :directory-contents :directories))
	(window-name "STAT-MODEL-LOAD-EXAMPLE"))
    ;;Create a window used to show all the
    ;;images in TRAINING-IMAGE-DIRECTORY.
    (with-named-window (window-name +window-normal+)
      (move-window window-name 759 175)
      ;;Allocated pointer to an integer that
      ;;the trackbar can increment/decrement. 
      (with-object ((n (alloc :int 0)))
        ;;Sliding the trackbar selects which pathname 
        ;;in PATNAME-LIST to give to IMREAD function.
	(create-trackbar  "#IMAGE:" window-name n 4960)
	(loop
           ;;Load a TEST-IMAGE
	   (with-mat ((test-image (imread (nth (@ n :int) pathname-list) +load-image-grayscale+)))
             ;;Convert TEST-IMAGE to single float.
	     (convert-to test-image test-image +32f+)
             ;;Resize TEST-IMAGE to a 50x50 matrix.
             ;;The 't:' prefix signifies automatic 
             ;;finalization is enabled for (SIZE).
	     (resize test-image test-image (t:size 50 50))
             ;;Create a SVM object.
	     (with-svm ((svm (svm)))
               ;;Load SVM model state, created in the
               ;;last example, into the SVM object.
	       (load svm svm-model-state "SVM_ALPHA_NUMERIC")
               ;;Convert TEST-IMAGE to a one dimensional matrix.
	       (with-mat ((reshaped-test-image (reshape test-image 0 1)))
                 ;;Predict which letter TEST-IMAGE is.
		 (let* ((prediction (round (predict svm reshaped-test-image)))
                        (result))
                 ;;This COND is used to traverse the ASCII character 
		 ;;codes, setting PREDICTION to 0...9, A...Z, a...z,
                 ;;based on the output of the PREDICT method.
		   (cond ((<= prediction 10) 
			  (setf result (string (code-char (+ prediction 47)))))
			 ((and (>= prediction 11) (<= prediction 35)) 
			  (setf result (string (code-char (+ prediction 54)))))
			 ((>= prediction 36) 
			  (setf result (string (code-char (+ prediction 60))))))
                   ;;Show prediction.
		   (display-overlay window-name (cat "Prediction: " result) 1000)
                   ;;Show current image
		   (imshow window-name test-image)
		   (let ((c (wait-key 33)))
		     (when (= c 27)
		       (format t "~%")
		       (return))))))))))))

========================================================================================================================================
#STAT-MODEL-SAVE
========================================================================================================================================

Saves the model to a file.

Note: The name STAT-MODEL-SAVE is used in the documentation to refer to the binding for the "save" 
member of the OpenCV CvStatModel class because it is more descriptive and it is easier to search for 
in this file. The SAVE method may also be used to call this binding.


C++: void CvStatModel::save(const char* filename, const char* name=0 )

LISP-CV: (SAVE (FILENAME :STRING) ((NAME :STRING) (CFFI::NULL-POINTER))) => :VOID

LISP-CV: (STAT-MODEL-SAVE (FILENAME :STRING) ((NAME :STRING) (CFFI::NULL-POINTER))) => :VOID


The method save saves the complete model state to the specified XML or YAML file with the specified 
name or default name (which depends on a particular class).


Note:(to clarify) In OpenCV the CvStatModel class is the public class to the following OpenCV classes; 

CvSVM, CvANN_MLP, CvBoost, CvDTree, CvGBTrees, CvKNearest, CvNormalBayesClassifier, CvRTrees.

(LISP-CV variants: SVM, ANN-MLP, BOOST, D-TREE, GB-TREES, K-NEAREST, NORMAL-BAYES-CLASSIFIER, R-TREES). 

As a result of that the CvStatModel::save method in OpenCV as well as this binding can save the 
trained model state created with any of those classes train methods.


Example:

(defun make-labels-matrix (&key training-matrix)

  (let ((label-matrix (mat (rows training-matrix) 1 +32fc1+)))
    (loop for x from 0 below (rows label-matrix) do 
	 (setf (at-float label-matrix x 0) (float (+ (truncate x 80) 1))))
    label-matrix))

(defun stat-model-save-example (training-image-directory save-directory)

  "In this example, we train a SVM(Support Vector Machine) with 
   OCR training data and save the resulting SVM model states to 
   a subfolder of the folder you specified as the SAVE-DIRECTORY 
   parameter.

   You will need to use the small OCR training set I added to the:
  
   <LISP-CV-SRC-DIR>/IMAGES/OCR-TRAINING-DATA/ 

   folder for the training images in this example. Just un-tar the 
   english.tar.gz file in that folder and use the resulting:

   <LISP-CV-SRC-DIR>/IMAGES/OCR-TRAINING-DATA/ENGLISH/FNT/  

   as the TRAINING-IMAGE-DIRECTORY parameter. This example takes a few  
   seconds to run(tested on a 3.2GHZ 2-CORE CPU), but you'll be informed 
   of its progress as detailed notes are printed to the screen. When the 
   example has completed, you will have a trained SVM model state, saved 
   as a .yml files in SAVE-DIRECTORY/SVM/ALPHA_NUMERIC/. This example is 
   part one of a two-parter. Check out the STAT-MODEL-LOAD-EXAMPLE which 
   is in EXAMPLES.LISP to find out how to use it."

  ;;DSIZE is the size that the MAKE-TRAINING-MATRIX function will 
  ;;resize the 128x128 OCR images to before pushing them into the 
  ;;training matrix.
  (with-size ((dsize (size 50 50)))
    ;;Make a list of all the subfolders <LISP-CV-SRC-DIR>/ENGLISH/FNT/.
    (let* ((save-directory (ensure-trailing-slash save-directory))
	   (svm-save-dir (ensure-directories-exist (cat save-directory ;Create directory to save
							"SVM/ALPHA_NUMERIC/")))) ;the SVM state.
      (if (uiop:directory-pathname-p save-directory) 
	  nil 
	  (return-from stat-model-save-example (format t "SAVE-DIRECTORY is not an actual directory.")))
      ;;Make the training matrix with the LISP-CV specific MAKE-TRAINING-MATRIX function.
      ;;This function will add all of the images in all of the subfolders of:
      ;;                 TRAINING-IMAGE-DIRECTORY
      ;;to TRAINING-MAT, as 1D images, one image per row.
      ;;Search #MAKE-TRAINING-MATRIX in EXAMPLES.LISP for more details about this function.
      (with-mat ((training-mat (make-training-matrix training-image-directory :directories dsize))
		 ;;Create a 1x(NUM-OF-IMAGES) matrix of labels.
		 (labels-mat (make-labels-matrix :training-matrix training-mat)))

	;;Set the SVM's parameters.
	(with-svm-params ((params (svm-params)))
	  (setf (degree params) 1d0)
	  (setf (svm-type params) +svm-c-svc+)
	  (setf (kernel-type params) +svm-poly+)
	  (setf (gamma params) 3d0)

	  ;;Set the FILENAME and NAME parameters 
	  ;;of the SAVE(STAT-MODL-SAVE) method.
	  (let* ((name "SVM_ALPHA_NUMERIC")
		 (filename (cat svm-save-dir name ".yml")))
	    
	    ;; Create an SVM object.
	    (with-svm ((svm (svm)))
	      (with-mat ((mat (mat)))
		(format t "~%Training ~a..." name)
                ;;Train the SVM with the OCR data.
		(train svm training-mat labels-mat mat mat params))
	      (format t "~%~%Training ~a Complete!~%" name)

	      (format t "~%Saving:~%~% ~a...~%~%" filename)
	      ;;Save current SVM's model state to SAVE-DIRECTORY/SVM/ALPHA_NUMERIC/.
	      (save svm filename name))))))))

========================================================================================================================================
#ML - #NORMAL BAYES CLASSIFIER
========================================================================================================================================

========================================================================================================================================
#NORMAL-BAYES-CLASSIFIER
========================================================================================================================================

Default and training constructors.

Note: Both NORMAL-BAYES-CLASSIFIER and MAKE-NORMAL-BAYES-CLASSIFIER are provided in this library. 
The first, to match OpenCV's naming conventions, the second, to adhere to Common Lisp naming conventions. 
Except for the name, they are the same function. I use the NORMAL-BAYES-CLASSIFIER function in the examples 
in this file because it will make them easier to compare with OpenCV examples you find online, thus making this 
library easier to learn.

C++: CvNormalBayesClassifier::CvNormalBayesClassifier()

C++: CvNormalBayesClassifier::CvNormalBayesClassifier(const Mat& trainData, const Mat& responses, const Mat& varIdx=Mat(), 
                                                      const Mat& sampleIdx=Mat() )

LISP-CV: (NORMAL-BAYES-CLASSIFIER &OPTIONAL (TRAIN-DATA MAT) (RESPONSES MAT) ((VAR-IDX MAT) (MAT)) 
                                           ((SAMPLE-IDX MAT) (MAT))) => NORMAL-BAYES-CLASSIFIER

LISP-CV: (MAKE-NORMAL-BAYES-CLASSIFIER &OPTIONAL (TRAIN-DATA MAT) (RESPONSES MAT) ((VAR-IDX MAT) (MAT)) 
                                                ((SAMPLE-IDX MAT) (MAT))) => NORMAL-BAYES-CLASSIFIER


The constructors follow conventions of (STAT-MODEL). See (STAT-MODEL-TRAIN) for parameters descriptions.


Example:

;; Note: This example is similar to, but is a more advanced 
;; and informative version of the ANN-MLP-EAXMPLE in this f-
;; ile.

;; Download the PDF at this link for more details.

;; https://github.com/bytefish/opencv/blob/master/machinelearning/doc/machinelearning.pdf 

;; Declare global variables.

(defparameter *plot-support-vectors* t)
(defparameter *num-training-points* 200)
(defparameter *num-test-points* 2000)
(defparameter *size* 200)

;; Move the trackbar on the middle window to decide 
;; which equation in the (F) function to use.

(defparameter *equation* (alloc :int 2))

;; Move the trackbars on the middle window to decide 
;; what to multiply X by in the (F) function equatio-
;; ns. Each trackbar in this list corresponds to a s-
;; etting of the *EQUATION* variable and affects the 
;; equations in the (F) function.

;; Note: When changing any of the five below values 
;; with the trackbar, make sure not to move the trac-
;; kbar to less than 1, or the program will freeze. 
;; Leaving this possibility allows for more precise 
;; adjustments.

(defparameter *equation-0* (alloc :int 10))
(defparameter *equation-1* (alloc :int 10))
(defparameter *equation-2* (alloc :int 2))
(defparameter *equation-3* (alloc :int 10))
(defparameter *other* (alloc :int 10))

;; You can change the number of Neurons per layer wi-
;; the trackbars, though it is reccomended that you 
;; read the notes below before you do so. See the co-
;; mments in the (MLP) function under the LAYERS hea-
;; ding for more information.

;; The number of Neurons in some of the layers are n-
;; ot adjustable, or, they are not easily adjustable. 
;; I left the oppurtunity for you to try because the 
;; C++ errors in *INFERIOR-LISP*(or your implementat-
;; ions version) offer good information and are usef-
;; ul debug tools.

;; Note 1: *LAYER-0* needs to stay on 2. Take a note 
;; of the C++ error in *INFERIOR-LISP* if you do dec-
;; ide to change it.

;; Note 2: If the value of *LAYER-1* goes below two 
;; you will get an error in *INFERIOR-LISP*. I could 
;; have added two to the value, when *LAYER-1* is cal-
;; led, to subvert the error, but I didn't for the sa-
;; ke of precision. Nou you will be able to see exac-
;; tly how many Neurons you're creating with the tra-
;; ckbar in Layer 1(and all layers).

;; Note 3: *LAYER-2* operates the same as *LAYER-1*.
;; See Note 2 for more details.

;; Note 4: *LAYER-3* operates the same as *LAYER-0*, 
;; but needs to stay on 1. See Note 1 for details.

(defparameter *layer-0* (alloc :int 2)) 
(defparameter *layer-1* (alloc :int 10))
(defparameter *layer-2* (alloc :int 15))
(defparameter *layer-3* (alloc :int 1))

;; Calculates the accuracy of the Normal Bayes Classifier and the Neural Network. 
;; The accuracy is affected by the equations and equation's parameters you choose 
;; for the (F) function and also by the number of Neurons per layer you choose in 
;; the (MLP) function.

(defun evaluate (predicted actual &optional p a (*t 0) (f 0)) 
  (if (eq (rows predicted) (rows actual))
      (dotimes (i (rows actual))
	(setf p (@ :float predicted i 0))
	(setf a (@ :float actual i 0))
	(if (or (and (>= p 0.0f0) (>= a 0.0f0)) (and (<= p 0.0f0) (<= a 0.0f0))) 
	    (incf *t)
	    (incf f))) nil)
  (/ (* *t 1.0) (+ *t f)))

;; Function to learn. The trackbars on the middle window change the values held in 
;; the EQUATION-* variables. The (@ *EQUATION-* :INT) statements dereference those 
;; variables and supply their values to the equations in this function. The '@' is 
;; a macro for CFFI's dereferencing function, MEM-AREF. Again, make sure not to mo-
;; ve the trackbar to less than 1 when adjusting these variables.

(defun f (x y equation) 
  (case equation (0 (return-from f (if (> y (sin (* x (@ *equation-0* :int)))) -1 1)))
	(1 (return-from f (if (> y (cos (* x (@ *equation-1* :int)))) -1 1)))
	(2 (return-from f (if (> y (* x (@ *equation-2* :int))) -1 1)))
	(3 (return-from f (if (> y (tan (* x (@ *equation-3* :int)))) -1 1)))
	(otherwise (return-from f (if (> y (cos (* x (@ *other* :int)))) -1 1)))))

;; NORMAL BAYES CLASSIFIER
(defun bayes (training-data training-classes test-data test-classes) 
  (with-normal-bayes-classifier ((bayes (normal-bayes-classifier training-data training-classes)))
    (with-mat ((predicted (mat (rows test-classes) 1 +32f+)))
      (dotimes (i (rows test-data))
	(with-mat ((sample (row test-data i)))
	  (setf (@ :float predicted i 0) (normal-bayes-classifier-predict bayes sample))))
      ;; Calculate the accuracy of the Normal Bayes Classifier
      (let ((evaluate (evaluate predicted test-classes)))
	(format t "~%Accuracy_{BAYES} = ~a~%" evaluate))
      ;; Plot the predictions
      (plot-binary test-data predicted "Predictions Bayes"))))

;; NEURAL NETWORK

(defun mlp (training-Data training-Classes test-Data test-Classes) 

  ;; LAYERS

  ;; The purpose of a neural network is to generalize, which is the ability 
  ;; to approximate outputs for inputs not available in the training set. W-
  ;; hile small networks may not be able to approximate a function, large n-
  ;; etworks tend to overfit and not find any relationship in data. It has 
  ;; been shown that, given enough data, a multi layer perceptron with one 
  ;; hidden layer can approximate any continuous function to any degree of 
  ;; accuracy. Here the number of neurons per layer is stored in the row-o-
  ;; rdered MAT below, LAYERS.

  (with-mat ((layers (mat 4 1 +32SC1+)))
    (setf (@ :int layers 0 0) (@ *layer-0* :int)) 
    (setf (@ :int layers 1 0) (@ *layer-1* :int))
    (setf (@ :int layers 2 0) (@ *layer-2* :int))
    (setf (@ :int layers 3 0) (@ *layer-3* :int))
    (with-ann-mlp ((mlp (ann-mlp)))
      (with-term-criteria ((criteria (term-criteria (logior +term-criteria-max-iter+ 
							    +term-criteria-eps+) 
						    100 0.00001d0)))
	(with-ann-mlp-train-params ((params (ann-mlp-train-params criteria 
								  +ann-mlp-train-params-backprop+ 
								  0.05d0 
	 							  0.05d0)))
	  (ann-mlp-create mlp layers)
	  ;; Train the Neural Net.
	  (with-mat ((predicted (mat (rows test-classes) 1 +32f+))
                     (sample-weights (mat))
                     (sample-idx (mat)))
	    (ann-mlp-train mlp training-data training-classes sample-weights sample-idx params)
	    (dotimes (i (rows test-data))
	      (with-mat ((response (mat 1 1 +32fc1+)))
		(with-mat ((sample (row test-data i)))
		  (ann-mlp-predict mlp sample response))
		(setf (@ :float predicted i 0) (@ :float response 0 0))))
            ;; Print the values of all adjustable variables.
            (format t "~%*EQUATION* = ~a~%" (@ *equation* :int))
            (format t "~%*EQUATION-0* = ~a~%" (@ *equation-0* :int))
            (format t "~%*EQUATION-1* = ~a~%" (@ *equation-1* :int))
            (format t "~%*EQUATION-2* = ~a~%" (@ *equation-2* :int))
            (format t "~%*EQUATION-3* = ~a~%" (@ *equation-3* :int))
            (format t "~%*OTHER* = ~a~%" (@ *other* :int))
            (format t "~%*LAYER-0* = ~a~%" (@ *layer-0* :int))
            (format t "~%*LAYER-1* = ~a~%" (@ *layer-1* :int))
            (format t "~%*LAYER-2* = ~a~%" (@ *layer-2* :int))
            (format t "~%*LAYER-3* = ~a~%" (@ *layer-3* :int))
            ;; Calculate the accuracy of the Neural Net
            (let ((evaluate (evaluate predicted test-classes)))
	      (format t "~%Accuracy_{MLP} = ~a~%" evaluate))
            ;; Plot the predictions
	    (plot-binary test-data predicted "Predictions Backpropagation")
	    nil ))))))

;; Plot Data and Class function
(defun plot-binary(data classes name &optional x y) 
  (with-mat ((plot (mat *size* *size* +8uc3+)))
    (with-scalar ((scalar (scalar 255 255 255)))
      (assign plot scalar))
    (dotimes (i (rows data))
      (setf x (* (@ :float data i 0) *size*))
      (setf y (* (@ :float data i 1) *size*))
      (with-scalar ((color1 (rgb 255 0 0))
		    (color2 (rgb 0 255 0)))
	(if (> (@ :float classes i 0) 0f0)
            ;; Plot the points with the CIRCLE function
	    (with-point ((center (point (round x) (round y))))
	      (circle plot center 1 color1 1))
	    (with-point ((center (point (round x) (round y))))
	      (circle plot center 1 color2 1)))))
    (imshow name plot)))



(defun normal-bayes-classifier-example ()

  "In this example, in the 2 right-most windows, a Normal Bayes 
   Classifier is compared side by side with a Neural Network."
  ;; Window names available to all of the functions
  (let ((window-name-1 "Training data")
	(window-name-2 "Test data")
	(window-name-3 "Predictions Backpropagation")
        (window-name-4 "Predictions Bayes")
        ;; Declare other variables
        (training-classes 0)
        (test-classes 0)
        (x 0)
        (y 0))
    ;; Create windows
    (with-named-window (window-name-1 +window-normal+)
      (with-named-window (window-name-2 +window-autosize+)
	(with-named-window (window-name-3 +window-normal+)
	  (with-named-window (window-name-4 +window-normal+)
	    ;; Move windows to specified locations
	    (move-window window-name-1 85 175)
	    (move-window window-name-2 549 175)
	    (move-window window-name-3 971 175)
	    (move-window window-name-4 1435 175)
	    ;; Create trackbars used to adjust the values in the (F) 
            ;; and (MLP) functions. The trackbar names are hints at 
            ;; how not to adjust them e.g. This, 'Eq 0: > 1', means 
            ;; do not let the trackbar go below 1. This, 'Layr 0: 2',
            ;; means the trackbar must stay at 2. Not abiding by the
            ;; guidelines will cause the program to freeze.
	    (create-trackbar "Equation" window-name-2 *equation* 4)
	    (create-trackbar "Eq 0: > 1" window-name-2 *equation-0* 150)
	    (create-trackbar "Eq 1: > 1" window-name-2 *equation-1* 150)
	    (create-trackbar "Eq 2: > 1" window-name-2 *equation-2* 10)
	    (create-trackbar "Eq 3: > 1" window-name-2 *equation-3* 150)
	    (create-trackbar "Other: > 1" window-name-2 *other* 150)
	    (create-trackbar "Lyr 0: 2" window-name-2 *layer-0* 10)
	    (create-trackbar "Lyr 1: > 2" window-name-2 *layer-1* 500)
	    (create-trackbar "Lyr 2: > 2 " window-name-2 *layer-2* 500)
	    (create-trackbar "Lyr 3: 1" window-name-2 *layer-3* 5)
	    (with-mat ((training-data (mat *num-training-points* 2 +32fc1+))
		       (test-data (mat *num-test-points* 2 +32fc1+)))

	      (loop;; Fill training and test data matrices 
		 ;; with random numbers from zero to one
		 (with-scalar ((zero (scalar 0))
			       (one (scalar 1)))
		   (randu training-data zero one)
		   (randu test-data zero one))

		 ;; Label data with equation
		 (with-mat ((labels1 (mat (rows training-data) 1 +32fc1+)))
		   (dotimes (i (rows training-data))
		     (setf x (@ :float training-data i 0))
		     (setf y (@ :float training-data i 1))
		     (setf (@ :float labels1 i 0) (coerce (f x y (@ *equation* :int)) 
							   'single-float)))

		   (with-mat ((labels2 (mat (rows test-data) 1 +32fc1+)))
		     (dotimes (i (rows test-data))
		       (setf x (@ :float test-data i 0))
		       (setf y (@ :float test-data i 1))
		       (setf (@ :float labels2 i 0) (coerce (f x y (@ *equation* :int)) 
							     'single-float)))

		     (setf training-classes labels1)
		     (setf test-classes labels2)

		     ;; Plot training data
		     (plot-binary training-data training-classes window-name-1)
		     ;; Plot test data
		     (plot-binary test-data test-classes window-name-2)
		     ;; Plot predictions
		     (bayes training-data training-classes test-data test-classes)
		     (mlp training-data training-classes test-data test-classes)))
		 (let ((c (wait-key 33)))
		   (when (= c 27)
		     (return)))))))))))

========================================================================================================================================
#NORMAL-BAYES-CLASSIFIER-PREDICT
========================================================================================================================================

Predicts the response for sample(s).

C++: float CvNormalBayesClassifier::predict(const Mat& samples, Mat* results=0, Mat* results_prob=0 ) const

LISP-CV: (NORMAL-BAYES-CLASSIFIER-PREDICT (SELF NORMAL-BAYES-CLASSIFIER) (SAMPLES MAT) ((RESULTS MAT) (CFFI::NULL-POINTER)) 
                                          ((RESULTS-PROB MAT) (CFFI::NULL-POINTER))) => :FLOAT

The method estimates the most probable classes for input vectors. Input vectors (one or more) are 
stored as rows of the matrix samples. In case of multiple input vectors, there should be one output 
vector RESULTS. The predicted class for a single input vector is returned by the method. The vector 
RESULTS-PROB contains the output probabilities coresponding to each element of RESULTS.

The function is parallelized with the TBB library.


Example:

See NORMAL-BAYES-CLASSIFIER-EXAMPLE in this file.

========================================================================================================================================
#ML - #K-NEAREST NEIGHBORS
========================================================================================================================================

========================================================================================================================================
#K-NEAREST
========================================================================================================================================

Default and training constructors.

Note: Both K-NEAREST and MAKE-K-NEAREST are provided in this library. The first, to match OpenCV's 
naming conventions, the second, to adhere to Common Lisp naming conventions. Except for the name, 
they are the same function. I use the K-NEAREST function in the examples in this file because it 
will make them easier to compare with OpenCV examples you find online, thus making this library 
easier to learn.

C++: CvKNearest::CvKNearest()

C++: CvKNearest::CvKNearest(const Mat& trainData, const Mat& responses, const Mat& sampleIdx=Mat(), bool isRegression=false, 
                            int max_k=32 )

LISP-CV: (K-NEAREST (&OPTIONAL (TRAIN-DATA MAT) (RESPONSES MAT) ((SAMPLE-IDX MAT) (CFFI::NULL-POINTER)) ((IS-REGRESSION :BOOLEAN) NIL) 
                    ((MAX-K :INT) 32))) => K-NEAREST

LISP-CV: (MAKE-K-NEAREST (&OPTIONAL (TRAIN-DATA MAT) (RESPONSES MAT) ((SAMPLE-IDX MAT) (CFFI::NULL-POINTER)) ((IS-REGRESSION :BOOLEAN) NIL) 
                    ((MAX-K :INT) 32))) => K-NEAREST


See (K-NEAREST-TRAIN) for additional parameters descriptions.


Example:

;; This example compares a Multi Layer Perceptron, a
;; Normal Bayes Classifier, and a K-Nearest Neighbors 
;; model.

;; Download the PDF at this link for more 
;; details.

;; https://github.com/bytefish/opencv/blob/master/machinelearning/doc/machinelearning.pdf 

;; Declare global variables.

(defparameter *plot-support-vectors* t)
(defparameter *num-training-points* 200)
(defparameter *num-test-points* 2000)
(defparameter *size* 200)

;; Move the trackbar on the middle window to decide 
;; which equation in the (F) function to use.

(defparameter *equation* (alloc :int 2))

;; Move the trackbars on the middle window to decide 
;; what to multiply X by in the (F) function equatio-
;; ns. Each trackbar in this list corresponds to a s-
;; etting of the *EQUATION* variable and affects the 
;; equations in the (F) function.

;; Note: When changing any of the five below values 
;; with the trackbar, make sure not to move the trac-
;; kbar to less than 1, or the program will freeze. 
;; Leaving this possibility allows for more precise 
;; adjustments.

(defparameter *equation-0* (alloc :int 10))
(defparameter *equation-1* (alloc :int 10))
(defparameter *equation-2* (alloc :int 2))
(defparameter *equation-3* (alloc :int 10))
(defparameter *other* (alloc :int 10))

;; You can change the number of Neurons per layer wi-
;; the trackbars, though it is reccomended that you 
;; read the notes below before you do so. See the co-
;; mments in the (MLP) function under the LAYERS hea-
;; ding for more information.

;; The number of Neurons in some of the layers are n-
;; ot adjustable, or, they are not easily adjustable. 
;; I left the oppurtunity for you to try because the 
;; C++ errors in *INFERIOR-LISP*(or your implementat-
;; ions version) offer good information and are usef-
;; ul debug tools.

;; Note 1: *LAYER-0* needs to stay on 2. Take a note 
;; of the C++ error in *INFERIOR-LISP* if you do dec-
;; ide to change it.

;; Note 2: If the value of *LAYER-1* goes below two 
;; you will get an error in *INFERIOR-LISP*. I could 
;; have added two to the value, when *LAYER-1* is cal-
;; led, to subvert the error, but I didn't for the sa-
;; ke of precision. Nou you will be able to see exac-
;; tly how many Neurons you're creating with the tra-
;; ckbar in Layer 1(and all layers).

;; Note 3: *LAYER-2* operates the same as *LAYER-1*.
;; See Note 2 for more details.

;; Note 4: *LAYER-3* operates the same as *LAYER-0*, 
;; but needs to stay on 1. See Note 1 for details.

(defparameter *layer-0* (alloc :int 2)) 
(defparameter *layer-1* (alloc :int 10))
(defparameter *layer-2* (alloc :int 15))
(defparameter *layer-3* (alloc :int 1))

;; Calculates the accuracy of the K-Nearest Neighbors model, the Normal Bayes 
;; Classifier and the Neural Network. The accuracy is affected by the equatio-
;; ns and equation's parameters you choose for the (F) function,  it is also 
;; affected by the number of Neurons per layer chosen in the (MLP) function.

(defun evaluate (predicted actual &optional p a (*t 0) (f 0)) 
  (if (eq (rows predicted) (rows actual))
      (dotimes (i (rows actual))
	(setf p (@ :float predicted i 0))
	(setf a (@ :float actual i 0))
	(if (or (and (>= p 0.0f0) (>= a 0.0f0)) (and (<= p 0.0f0) (<= a 0.0f0))) 
	    (incf *t)
	    (incf f))) nil)
  (float (/ (* *t 1) (+ *t f))))

;; Function to learn. The trackbars on the middle window change the values held in 
;; the EQUATION-* variables. The (@ *EQUATION-* :INT) statements dereference those 
;; variables and supply their values to the equations in this function. The '@' is 
;; a macro for CFFI's dereferencing function, MEM-AREF. Again, make sure not to mo-
;; ve the trackbar to less than 1 when adjusting these variables.

(defun f (x y equation) 
  (case equation (0 (return-from f (if (> y (sin (* x (@ *equation-0* :int)))) -1 1)))
	(1 (return-from f (if (> y (cos (* x (@ *equation-1* :int)))) -1 1)))
	(2 (return-from f (if (> y (* x (@ *equation-2* :int))) -1 1)))
	(3 (return-from f (if (> y (tan (* x (@ *equation-3* :int)))) -1 1)))
	(otherwise (return-from f (if (> y (cos (* x (@ *other* :int)))) -1 1)))))


;; K-NEAREST NEIGHBORS
(defun knn (training-data training-classes test-data test-classes k) 
  (with-mat ((mat (mat)))
    (with-k-nearest ((knn (k-nearest training-data training-classes mat nil k)))
      (with-mat ((predicted (mat (rows test-classes) 1 +32f+)))
	(dotimes (i (rows test-data))
	  (with-mat ((sample (row test-data i)))
	    (setf (@ :float predicted i 0) (k-nearest-find-nearest knn sample k))))
	;; Calculate the accuracy of the K-Nearest Neighbors
	(let ((evaluate (evaluate predicted test-classes)))
	  (format t "~%Accuracy_{KNN} = ~a~%" evaluate))
	;; Plot the predictions
	(plot-binary test-data predicted "Predictions KNN")))))


;; NORMAL BAYES CLASSIFIER
(defun bayes (training-data training-classes test-data test-classes) 
  (with-normal-bayes-classifier ((bayes (normal-bayes-classifier training-data training-classes)))
    (with-mat ((predicted (mat (rows test-classes) 1 +32f+)))
      (dotimes (i (rows test-data))
	(with-mat ((sample (row test-data i)))
	  (setf (@ :float predicted i 0) (normal-bayes-classifier-predict bayes sample))))
      ;; Calculate the accuracy of the Normal Bayes Classifier
      (let ((evaluate (evaluate predicted test-classes)))
	(format t "~%Accuracy_{BAYES} = ~a~%" evaluate))
      ;; Plot the predictions
      (plot-binary test-data predicted "Predictions Bayes"))))


;; NEURAL NETWORK

(defun mlp (training-Data training-Classes test-Data test-Classes) 

  ;; LAYERS

  ;; The purpose of a neural network is to generalize, which is the ability 
  ;; to approximate outputs for inputs not available in the training set. W-
  ;; hile small networks may not be able to approximate a function, large n-
  ;; etworks tend to overfit and not find any relationship in data. It has 
  ;; been shown that, given enough data, a multi layer perceptron with one 
  ;; hidden layer can approximate any continuous function to any degree of 
  ;; accuracy. Here the number of neurons per layer is stored in the row-o-
  ;; rdered MAT below, LAYERS.

  (with-mat ((layers (mat 4 1 +32SC1+)))
    (setf (@ :int layers 0 0) (@ *layer-0* :int)) 
    (setf (@ :int layers 1 0) (@ *layer-1* :int))
    (setf (@ :int layers 2 0) (@ *layer-2* :int))
    (setf (@ :int layers 3 0) (@ *layer-3* :int))
    (with-ann-mlp ((mlp (ann-mlp)))
      (with-term-criteria ((criteria (term-criteria (logior +term-criteria-max-iter+ 
							    +term-criteria-eps+) 
						    100 0.00001d0)))
	(with-ann-mlp-train-params ((params (ann-mlp-train-params criteria 
								  +ann-mlp-train-params-backprop+ 
								  0.05d0 
	 							  0.05d0)))
	  (ann-mlp-create mlp layers)
	  ;; Train the Neural Net.
	  (with-mat ((predicted (mat (rows test-classes) 1 +32f+))
                     (sample-weights (mat))
                     (sample-idx (mat)))
	    (ann-mlp-train mlp training-data training-classes sample-weights sample-idx params)
	    (dotimes (i (rows test-data))
	      (with-mat ((response (mat 1 1 +32fc1+)))
		(with-mat ((sample (row test-data i)))
		  (ann-mlp-predict mlp sample response))
		(setf (@ :float predicted i 0) (@ :float response 0 0))))
            ;; Print the values of all adjustable variables.
            (format t "~%*EQUATION* = ~a~%" (@ *equation* :int))
            (format t "~%*EQUATION-0* = ~a~%" (@ *equation-0* :int))
            (format t "~%*EQUATION-1* = ~a~%" (@ *equation-1* :int))
            (format t "~%*EQUATION-2* = ~a~%" (@ *equation-2* :int))
            (format t "~%*EQUATION-3* = ~a~%" (@ *equation-3* :int))
            (format t "~%*OTHER* = ~a~%" (@ *other* :int))
            (format t "~%*LAYER-0* = ~a~%" (@ *layer-0* :int))
            (format t "~%*LAYER-1* = ~a~%" (@ *layer-1* :int))
            (format t "~%*LAYER-2* = ~a~%" (@ *layer-2* :int))
            (format t "~%*LAYER-3* = ~a~%" (@ *layer-3* :int))
            ;; Calculate the accuracy of the Neural Net
            (let ((evaluate (evaluate predicted test-classes)))
	      (format t "~%Accuracy_{MLP} = ~a~%" evaluate))
            ;; Plot the predictions
	    (plot-binary test-data predicted "Predictions Backpropagation")
	    nil ))))))

;; Plot Data and Class function
(defun plot-binary(data classes name &optional x y) 
  (with-mat ((plot (mat *size* *size* +8uc3+)))
    (with-scalar ((scalar (scalar 255 255 255)))
      (assign plot scalar))
    (dotimes (i (rows data))
      (setf x (* (@ :float data i 0) *size*))
      (setf y (* (@ :float data i 1) *size*))
      (with-scalar ((color1 (rgb 255 0 0))
		    (color2 (rgb 0 255 0)))
	(if (> (@ :float classes i 0) 0f0)
            ;; Plot the points with the CIRCLE function
	    (with-point ((center (point (round x) (round y))))
	      (circle plot center 1 color1 1))
	    (with-point ((center (point (round x) (round y))))
	      (circle plot center 1 color2 1)))))
    (imshow name plot)))


(defun k-nearest-example ()

  "In this example, in the top 3 windows, a K-Nearest Neighbors model 
   is compared with a Normal Bayes Classifier and a Neural Network."

  ;; Window names available to all of the functions
  (let ((window-name-1 "Training data")
	(window-name-2 "Test data")
	(window-name-3 "Predictions Backpropagation")
        (window-name-4 "Predictions Bayes")
        (window-name-5 "Predictions KNN")
        ;; Declare other variables
        (training-classes 0)
        (test-classes 0)
        (x 0)
        (y 0))
    ;; Create windows
    (with-named-window (window-name-1 +window-normal+)
      (with-named-window (window-name-2 +window-autosize+)
	(with-named-window (window-name-3 +window-normal+)
	  (with-named-window (window-name-4 +window-normal+)
	    (with-named-window (window-name-5 +window-normal+)
	      ;; Move windows to specified locations
	      (move-window window-name-3 310 96)
	      (move-window window-name-4 760 96)
	      (move-window window-name-5 1210 96)
	      (move-window window-name-1 533 500)
	      (move-window window-name-2 984 500)
	      ;; Create trackbars used to adjust the values in the (F) 
	      ;; and (MLP) functions. The trackbar names are hints at 
	      ;; how not to adjust them e.g. This, 'Eq 0: > 1', means 
              ;; do not let the trackbar go below 1. This, 'Layr 0: 2',
              ;; means the trackbar must stay at 2. Not following the
	      ;; guidelines will cause the program to freeze.
	      (create-trackbar "Equation" window-name-2 *equation* 4)
	      (create-trackbar "Eq 0: > 1" window-name-2 *equation-0* 150)
	      (create-trackbar "Eq 1: > 1" window-name-2 *equation-1* 150)
	      (create-trackbar "Eq 2: > 1" window-name-2 *equation-2* 10)
	      (create-trackbar "Eq 3: > 1" window-name-2 *equation-3* 150)
	      (create-trackbar "Other: > 1" window-name-2 *other* 150)
	      (create-trackbar "Lyr 0: 2" window-name-2 *layer-0* 10)
	      (create-trackbar "Lyr 1: > 2" window-name-2 *layer-1* 500)
	      (create-trackbar "Lyr 2: > 2 " window-name-2 *layer-2* 500)
	      (create-trackbar "Lyr 3: 1" window-name-2 *layer-3* 5)
	      (with-mat ((training-data (mat *num-training-points* 2 +32fc1+))
			 (test-data (mat *num-test-points* 2 +32fc1+)))

		(loop;; Fill training and test data matrices 
		     ;; with random numbers from zero to one
		   (with-scalar ((zero (scalar 0))
				 (one (scalar 1)))
		     (randu training-data zero one)
		     (randu test-data zero one))

		   ;; Label data with equation
		   (with-mat ((labels1 (mat (rows training-data) 1 +32fc1+)))
		     (dotimes (i (rows training-data))
		       (setf x (@ :float training-data i 0))
		       (setf y (@ :float training-data i 1))
		       (setf (@ :float labels1 i 0) (coerce (f x y (@ *equation* :int)) 'single-float)))

		     (with-mat ((labels2 (mat (rows test-data) 1 +32fc1+)))
		       (dotimes (i (rows test-data))
			 (setf x (@ :float test-data i 0))
			 (setf y (@ :float test-data i 1))
			 (setf (@ :float labels2 i 0) (coerce (f x y (@ *equation* :int)) 'single-float)))

		       (setf training-classes labels1)
		       (setf test-classes labels2)

		       ;; Plot training data
		       (plot-binary training-data training-classes window-name-1)
		       ;; Plot test data
		       (plot-binary test-data test-classes window-name-2)
		       ;; Plot predictions
		       (knn training-data training-classes test-data test-classes 3)
		       (bayes training-data training-classes test-data test-classes)
		       (mlp training-data training-classes test-data test-classes)))
		   (let ((c (wait-key 33)))
		     (when (= c 27)
		       (return))))))))))))

========================================================================================================================================
#K-NEAREST-FIND-NEAREST
========================================================================================================================================

Finds the neighbors and predicts responses for input vectors.

C++: float CvKNearest::find_nearest(const Mat& samples, int k, Mat& results, Mat& neighborResponses, Mat& dists) const

LISP-CV: (K-NEAREST-FIND-NEAREST (SELF MAT) (SAMPLES MAT) &OPTIONAL ((RESULTS MAT) (CFFI::NULL-POINTER)) 
                                ((NEIGHBOR-RESPONSES MAT) (CFFI::NULL-POINTER)) (DISTS (CFFI::NULL-POINTER))) => :FLOAT

    Parameters:	

        SAMPLES - Input samples stored by rows. It is a single-precision floating-point matrix of 
                  (* Mumber-of-samples number-of-features) size.

        K - Number of used nearest neighbors. It must satisfy constraint: (<= K (K-NEAREST-GET-MAX-K)).

        RESULTS - Vector with results of prediction (regression or classification) for each input 
                  sample. It is a single-precision floating-point vector with NUMBER-OF-SAMPLES 
                  elements.

        NEIGHBORS - Optional output pointers to the neighbor vectors themselves. It is an array of 
                    (* K (ROWS SAMPLES)) pointers.

        NEIGHBOR_RESPONSES - Optional output values for corresponding neighbors. It is a single-precision 
                             floating-point matrix of (* NUMBER-OF-SAMPLES K) size.

        DIST - Optional output distances from the input vectors to the corresponding neighbors. It is 
               a single-precision floating-point matrix of (* NUMBER-OF-SAMPLES K)  size.

For each input vector (a row of the matrix samples), the method finds the k nearest neighbors. In 
case of regression, the predicted result is a mean value of the particular vector’s neighbor responses. 
In case of classification, the class is determined by voting.

For each input vector, the neighbors are sorted by their distances to the vector.

In case of C++ interface(Lisp-CV binds to the C++ interface) you can use output pointers to empty 
matrices and the function will allocate memory itself.

If only a single input vector is passed, all output matrices are optional and the predicted value is 
returned by the function.

The function is parallelized with the TBB library.


Example:

See the K-NEAREST-EXAMPLE in this library

========================================================================================================================================
#ML - #SUPPORT VECTOR MACHINES
========================================================================================================================================

========================================================================================================================================
GET-SUPPORT-VECTOR
========================================================================================================================================

Retrieves a number of support vectors and the particular vector.


C++: int CvSVM::get_support_vector_count() const

LISP-CV: (GET-SUPPORT-VECTOR-COUNT (SELF SVM)) => :INT

C++: const float* CvSVM::get_support_vector(int i) const

LISP-CV: (GET-SUPPORT-VECTOR (SELF SVM) (I :INT)) => :POINTER

  
  Parameters:	

        SELF - A SVM object.

        I - Index of the particular support vector.


The methods can be used to retrieve a set of support vectors.


Example:

See SVM-EXAMPLE in this file.

========================================================================================================================================
#SVM
========================================================================================================================================

Default and training constructors.

Note: Both SVM and MAKE-SVM are provided in this library. The first, to match OpenCV's naming conventions, 
the second, to adhere to Common Lisp naming conventions. Except for the name, they are the same function. I 
use the SVM function in the examples in this file because it will make them easier to compare with OpenCV 
examples you find online, thus making this library easier to learn.


C++: CvSVM::CvSVM()

LISP-CV: (SVM) => SVM

LISP-CV: (SVM) => MAKE-SVM

C++: CvSVM::CvSVM(const Mat& trainData, const Mat& responses, const Mat& varIdx=Mat(), const Mat& sampleIdx=Mat(), 
                  CvSVMParams params=CvSVMParams() )

LISP-CV: (SVM &OPTIONAL (TRAIN-DATA MAT) (RESPONSES MAT) ((VAR-IDX MAT) (%MAT)) ((SAMPLE-IDX MAT) (%MAT)) 
                       ((PARAMS SVM-PARAMS) (SVM-PARAMS-0))) => SVM

LISP-CV: (MAKE-SVM &OPTIONAL (TRAIN-DATA MAT) (RESPONSES MAT) ((VAR-IDX MAT) (%MAT)) ((SAMPLE-IDX MAT) (%MAT)) 
                       ((PARAMS SVM-PARAMS) (SVM-PARAMS-0))) => SVM


The constructors follow conventions of (STAT-MODEL). See (STAT-MODEL-TRAIN) for parameters descriptions.


Example:

(defun svm-example ()

  (let* ((window-name "SVM-EXAMPLE")
	 (width 512)
	 (height 512)
         (term-crit-struct 0)
	 (response 0)
	 (thickness -1)
	 (line-type 8)
	 (c 0)
	 (v 0))
    (with-named-window (window-name)
      (move-window window-name 704 175)
      ;;Data for visual representation.
      (with-mat ((image (mat-zeros height width +8uc3+)))
	;;Set up training data.
	(with-object ((*labels (alloc :float '(1.0 -1.0 -1.0 -1.0))))
	  (with-mat ((labels-mat (mat 4 1 +32fc1+ *labels)))
	    (with-object ((training-data (foreign-array-alloc #2A((501f0 10f0) 
								  (255f0 10f0) 
								  (501f0 255f0) 
								  (10f0 501f0)) 
							      '(:array :float 4 2))))
	      (with-mat ((training-data-mat (mat 4 2 +32fc1+ training-data)))
		;;Set up SVM's parameters.
		(with-svm-params ((params (svm-params)))
		  (with-term-criteria ((term-crit (term-criteria +termcrit-iter+ 100 
								 (coerce 1e-6 'double-float))))
		    (setf term-crit-struct (term-crit-to-cv-term-crit term-crit))
		    (setf (svm-type params) +svm-c-svc+)
		    (setf (kernel-type params) +svm-linear+)
		    (setf (term-crit params) term-crit-struct)
		    ;; Train the SVM.
		    (with-svm ((svm (svm)))
		      (with-mat ((mat (mat)))
			(train svm  training-data-mat labels-mat mat mat params)

			(with-vec-3b ((green (vec-3b 0 255 0))
				      (blue (vec-3b 255 0 0)))
			  ;;Show the decision regions given by the SVM.
			  (dotimes (i (rows image))
			    (dotimes (j (cols image))
			      (with-object ((data (alloc :float (list (float j) (float i)))))
				(with-mat ((sample-mat (mat 1 2 +32fc1+ data)))
				  (setf response (predict svm sample-mat))

				  (if (= response 1) 
				      (setf (@ :vec-3b image i j) green) 
				      (if (= response -1)
					  (setf (@ :vec-3b image i j) blue)))))))

			  ;;Show the training data.
			  (with-point ((center-1 (point 501 10))
				       (center-2 (point 255 10))
				       (center-3 (point 501 255))
				       (center-4 (point 10 501)))
			    (with-scalar ((black (scalar 0 0 0))
					  (white (scalar 255 255 255)))
			      (circle image center-1 5 black thickness line-type)
			      (circle image center-2 5 white thickness line-type)
			      (circle image center-3 5 white thickness line-type)
			      (circle image center-4 5 white thickness line-type)

			      ;;Show support vectors.
			      (setf thickness 2)
			      (setf line-type 8)

			      (setf c (get-support-vector-count svm))

			      (dotimes (i c)
				(setf v (get-support-vector svm i))
				(with-point ((center-5 (point (floor (@ v :float 0)) 
							      (floor (@ v :float 1)))))
				  (with-scalar ((grey (scalar 128 128 128)))
				    (circle image center-5 6 grey thickness line-type))))

			      (imwrite "result.png" image) ;Save the image.
			      (loop
				 (imshow window-name image) ;Show it to the user.
				 (let ((c (wait-key 33)))
				   (when (= c 27)
				     (return)))))))))))))))))))


========================================================================================================================================
#SVM-PARAMS
========================================================================================================================================

The constructors.

Note: Both SVM-PARAMS and MAKE-SVM-PARAMS are provided in this library. The first, to match OpenCV's 
naming conventions, the second, to adhere to Common Lisp naming conventions. Except for the name, they 
are the same function. I use the SVM-PARAMS function in the examples in this file because it will make 
them easier to compare with OpenCV examples you find online, thus making this library easier to learn.

C++: CvSVMParams::CvSVMParams()

LISP-CV: (SVM-PARAMS) => SVM-PARAMS

LISP-CV: (MAKE-SVM-PARAMS) => SVM-PARAMS

C++: CvSVMParams::CvSVMParams(int svm_type, int kernel_type, double degree, double gamma, double coef0, double Cvalue, 
                              double nu, double p, CvMat* class_weights, CvTermCriteria term_crit)

LISP-CV: (svm-params (svm-type :int) (kernel-type :int) (degree :double) (gamma :double) (coef-0 :double) 
                     (c-value :double) (nu :double) (p :double) (class-weights mat-struct)
                     (term-crit (:pointer (:struct term-criteria-struct)))) => SVM-PARAMS


See OpenCV documentation at this link:

http://docs.opencv.org/trunk/modules/ml/doc/support_vector_machines.html?highlight=svmparams#CvSVMParams

for a description of the parameters and formulae.


The constants at above link are translated into LISP-CV as follows:


(Using CvSVM::C_SVC as example):


1. The Cv is stripped: SVM::C_SVC

2. The :: is replaced with - : SVM-C_SVC

3. The _ is replaced with - : SVM-C-SVC

4. Plus signs are added to either end: +SVM-C-SVC+


Example:

(defun svm-params-example ()

  "Per this excerpt from the OpenCv SVM tutorial here:

   http://docs.opencv.org/doc/tutorials/ml/introduction_to_svm/introduction_to_svm.html

   'A Support Vector Machine (SVM) is a discriminative classifier 
    formally defined by a separating hyperplane. In other words, given 
    labeled training data (supervised learning), the algorithm outputs 
    an optimal hyperplane which categorizes new examples.'

    This example allows you to change the data inside the training matrix, 
    represented by black and white points on the screen, with the trackbars, 
    moving the optimal separating hyperplane in the process."

  (let* ((window-name "SVM-PARAMS-EXAMPLE")
	 (width 512)
	 (height 512)
         (term-crit-struct 0)
	 (response 0)
	 (thickness -1)
	 (line-type 8)
	 (c 0)
	 (v 0))
    (with-named-window (window-name)
      (move-window window-name 704 175)
      ;;Allocate memory to hold the integer 
      ;;values the trackbars will adjust.
      (with-object ((svm-type (alloc :int 0))
                    (0-0 (alloc :int 501))
		    (0-1 (alloc :int 10))
		    (1-0 (alloc :int 255))
		    (1-1 (alloc :int 10))
		    (2-0 (alloc :int 501))
		    (2-1 (alloc :int 255))
		    (3-0 (alloc :int 10))
		    (3-1 (alloc :int 501)))
        ;;Create trackbars used to change the eight 
        ;;elements inside the training data matrix.
        ;;The default training values are the same 
        ;;as in the SVM-EXAMPLE in examples.lisp.
	(create-trackbar "0,0" window-name 0-0 501)
	(create-trackbar "0,1" window-name 0-1 500)
	(create-trackbar "1,0" window-name 1-0 500)
	(create-trackbar "1,1" window-name 1-1 500)
	(create-trackbar "2,0" window-name 2-0 501)
	(create-trackbar "2.1" window-name 2-1 500)
	(create-trackbar "3,0" window-name 3-0 500)
	(create-trackbar "3,1" window-name 3-1 501)
	(loop
	   ;;Data for visual representation.
	   (with-mat ((image (mat-zeros height width +8uc3+)))

	     ;;;Set up training data.

	     (with-object ((*labels (alloc :float '(1.0 -1.0 -1.0 -1.0))))
               ;;Create a 4x1 labels matrix, with a label of -1 for each 
               ;;white dot and a label of 1 for the single black dot.
	       (with-mat ((labels-mat (mat 4 1 +32fc1+ *labels)))
                 ;;Create a training matrix with data output by trackbars.
		 (with-object ((training-data (alloc :float (list
							     (coerce (@ 0-0 :int) 'single-float) 
							     (coerce (@ 0-1 :int) 'single-float) 
							     (coerce (@ 1-0 :int) 'single-float) 
							     (coerce (@ 1-1 :int) 'single-float) 
							     (coerce (@ 2-0 :int) 'single-float) 
							     (coerce (@ 2-1 :int) 'single-float) 
							     (coerce (@ 3-0 :int) 'single-float) 
							     (coerce (@ 3-1 :int) 'single-float)))))
		   (with-mat ((training-data-mat (mat 4 2 +32fc1+ training-data)))

		     ;;;In the next few lines, set up SVM's parameters.

		     (with-svm-params ((params (svm-params)))
                       ;; Termination criteria of the iterative SVM training procedure. 
		       (with-term-criteria ((term-crit (term-criteria +termcrit-iter+ 100 
								      (coerce 1e-6 'double-float))))

			 ;;Convert the TERM-CRITERIA object, just created, into a struct 
			 ;;(CvTermCriteria in OpenCV)before giving it to SVM-PARAMS. 
			 (setf term-crit-struct (term-crit-to-cv-term-crit term-crit))
                         ;;Set termination criteria into SVM-PARAMS object.
			 (setf (term-crit params) term-crit-struct)
                         ;;Set the type of the SVM formulation.
			 (setf (svm-type params) +svm-c-svc+)
                         ;;Create a linear kernel, the fastest kernel type.
			 (setf (kernel-type params) +svm-linear+)
                         
			 ;; Train the SVM.
			 (with-svm ((svm (svm)))
			   (with-mat ((mat (mat)))
			     (train svm  training-data-mat labels-mat mat mat params) 
			     (with-vec-3b ((green (vec-3b 0 255 0))
					   (blue (vec-3b 255 0 0)))
			       ;;Show the decision regions given by the SVM.
			       (dotimes (i (rows image))
				 (dotimes (j (cols image))
				   (with-object ((data (alloc :float (list (float j) (float i)))))
				     (with-mat ((sample-mat (mat 1 2 +32fc1+ data)))
				       (setf response (predict svm sample-mat))

				       (if (= response 1) 
					   (setf (@ :vec-3b image i j) green) 
					   (if (= response -1)
					       (setf (@ :vec-3b image i j) blue)))))))

			       ;;Show the training data.
			       (with-point ((center-1 (point (@ 0-0 :int) (@ 0-1 :int)))
					    (center-2 (point (@ 1-0 :int) (@ 1-1 :int)))
					    (center-3 (point (@ 2-0 :int) (@ 2-1 :int)))
					    (center-4 (point (@ 3-0 :int) (@ 3-1 :int))))
				 (with-scalar ((black (scalar 0 0 0))
					       (white (scalar 255 255 255)))
				   (circle image center-1 5 black thickness line-type)
				   (circle image center-2 5 white thickness line-type)
				   (circle image center-3 5 white thickness line-type)
				   (circle image center-4 5 white thickness line-type)

				   ;;Show support vectors.
				   (setf thickness 2)
				   (setf line-type 8)

				   (setf c (get-support-vector-count svm))

				   (dotimes (i c)
				     (setf v (get-support-vector svm i))
				     (with-point ((center-5 (point (floor (@ v :float 0)) 
								   (floor (@ v :float 1)))))
				       (with-scalar ((grey (scalar 128 128 128)))
					 (circle image center-5 6 grey thickness line-type))))
                                   ;;Show it to the user.
				   (imshow window-name image) 

				   (let ((c (wait-key 33)))
				     (when (= c 27)
				       (return))))))))))))))))))))

========================================================================================================================================
#ML - #DECISION TREES
========================================================================================================================================

========================================================================================================================================
#D-TREE
========================================================================================================================================

A D-TREE object constructor.

Note: Both D-TREE and MAKE-D-TREE are provided in this library. The first, to match OpenCV's naming 
conventions, the second, to adhere to Common Lisp naming conventions. Except for the name, they are 
the same function. I use the D-TREE function in the examples in this file because it will make them 
easier to compare with OpenCV examples you find online, thus making this library easier to learn.

C++: CvDTree::CvDTree()

LISP-CV: (D-TREE) => D-TREE

LISP-CV: (MAKE-D-TREE) => D-TREE


This function implements a decision tree as described in the beginning of this link:

http://docs.opencv.org/trunk/modules/ml/doc/decision_trees.html?highlight=dtreep#cvdtree


Example:

;; This example compares Decision Trees, a Multi Layer Perceptron,
;; Normal Bayes Classifier, and a K-Nearest Neighbors 
;; model.

;; Download the PDF at this link for more details.

;; https://github.com/bytefish/opencv/blob/master/machinelearning/doc/machinelearning.pdf 

;; Declare global variables.

(defparameter *plot-support-vectors* t)
(defparameter *num-training-points* 200)
(defparameter *num-test-points* 2000)
(defparameter *size* 200)

;; Move the trackbar on the middle window to decide 
;; which equation in the (F) function to use.

(defparameter *equation* (alloc :int 2))

;; Move the trackbars on the middle window to decide 
;; what to multiply X by in the (F) function equatio-
;; ns. Each trackbar in this list corresponds to a s-
;; etting of the *EQUATION* variable and affects the 
;; equations in the (F) function.

;; Note: When changing any of the five below values 
;; with the trackbar, make sure not to move the trac-
;; kbar to less than 1, or the program will freeze. 
;; Leaving this possibility allows for more precise 
;; adjustments.

(defparameter *equation-0* (alloc :int 10))
(defparameter *equation-1* (alloc :int 10))
(defparameter *equation-2* (alloc :int 2))
(defparameter *equation-3* (alloc :int 10))
(defparameter *other* (alloc :int 10))

;; You can change the number of Neurons per layer wi-
;; the trackbars, though it is reccomended that you 
;; read the notes below before you do so. See the co-
;; mments in the (MLP) function under the LAYERS hea-
;; ding for more information.

;; The number of Neurons in some of the layers are n-
;; ot adjustable, or, they are not easily adjustable. 
;; I left the oppurtunity for you to try because the 
;; C++ errors in *INFERIOR-LISP*(or your implementat-
;; ions version) offer good information and are usef-
;; ul debug tools.

;; Note 1: *LAYER-0* needs to stay on 2. Take a note 
;; of the C++ error in *INFERIOR-LISP* if you do dec-
;; ide to change it.

;; Note 2: If the value of *LAYER-1* goes below two 
;; you will get an error in *INFERIOR-LISP*. I could 
;; have added two to the value, when *LAYER-1* is cal-
;; led, to subvert the error, but I didn't for the sa-
;; ke of precision. Nou you will be able to see exac-
;; tly how many Neurons you're creating with the tra-
;; ckbar in Layer 1(and all layers).

;; Note 3: *LAYER-2* operates the same as *LAYER-1*.
;; See Note 2 for more details.

;; Note 4: *LAYER-3* operates the same as *LAYER-0*, 
;; but needs to stay on 1. See Note 1 for details.

(defparameter *layer-0* (alloc :int 2)) 
(defparameter *layer-1* (alloc :int 10))
(defparameter *layer-2* (alloc :int 15))
(defparameter *layer-3* (alloc :int 1))

;; Calculates the accuracy of the Decision Trees, the K-Nearest Neighbors model, 
;; the Normal Bayes Classifier and the Neural Network. The accuracy is affected 
;; by the equations and equation's parameters you choose for the (F) function, 
;; and it's also affected by the number of Neurons per layer chosen in the (MLP) 
;; function.

(defun evaluate (predicted actual &optional p a (*t 0) (f 0)) 
  (if (eq (rows predicted) (rows actual))
      (dotimes (i (rows actual))
	(setf p (@ :float predicted i 0))
	(setf a (@ :float actual i 0))
	(if (or (and (>= p 0.0f0) (>= a 0.0f0)) (and (<= p 0.0f0) (<= a 0.0f0))) 
	    (incf *t)
	    (incf f))) nil)
  (float (/ (* *t 1) (+ *t f))))

;; Function to learn. The trackbars on the middle window change the values held in 
;; the EQUATION-* variables. The (@ *EQUATION-* :INT) statements dereference those 
;; variables and supply their values to the equations in this function. The '@' is 
;; a macro for CFFI's dereferencing function, MEM-AREF. Again, make sure not to mo-
;; ve the trackbar to less than 1 when adjusting these variables.

(defun f (x y equation) 
  (case equation (0 (return-from f (if (> y (sin (* x (@ *equation-0* :int)))) -1 1)))
	(1 (return-from f (if (> y (cos (* x (@ *equation-1* :int)))) -1 1)))
	(2 (return-from f (if (> y (* x (@ *equation-2* :int))) -1 1)))
	(3 (return-from f (if (> y (tan (* x (@ *equation-3* :int)))) -1 1)))
	(otherwise (return-from f (if (> y (cos (* x (@ *other* :int)))) -1 1)))))


;; DECISION TREE

(defun decision-tree (training-data training-classes test-data test-classes &optional prediction)
  (with-d-tree ((d-tree (d-tree)))

    (with-mat ((var-type (mat 3 1 +8u+))
	       (predicted (mat (rows test-classes) 1 +32f+))
               (mat (mat)))
      ;; Define attributes as numerical
      (setf (@ :uint var-type 0 0) +var-numerical+)
      ;; Define output node as numerical
      (setf (@ :uint var-type 0 1) +var-numerical+)
      (setf (@ :uint var-type 0 2) +var-numerical+)
      (d-tree-train d-tree training-data +row-sample+ training-classes mat mat var-type mat (d-tree-params))
      (dotimes (i (rows test-data))
	(with-mat ((sample (row test-data i)))
	  (setf prediction (d-tree-predict d-tree sample))
	  (with-foreign-slots ((value) prediction (:struct d-tree-node))
	    (setf (@ :float predicted i 0) (coerce value 'single-float)))))
      ;; Calculate the accuracy of the Decision Trees
      (let ((evaluate (evaluate predicted test-classes)))
	(format t "~%Accuracy_{TREE} = ~a~%" evaluate))
      ;; Plot the predictions
      (plot-binary test-data predicted "Predictions Tree"))))


;; K-NEAREST NEIGHBORS
(defun knn (training-data training-classes test-data test-classes k) 
  (with-mat ((mat (mat)))
    (with-k-nearest ((knn (k-nearest training-data training-classes mat nil k)))
      (with-mat ((predicted (mat (rows test-classes) 1 +32f+)))
	(dotimes (i (rows test-data))
	  (with-mat ((sample (row test-data i)))
	    (setf (@ :float predicted i 0) (k-nearest-find-nearest knn sample k))))
	;; Calculate the accuracy of the K-Nearest Neighbors
	(let ((evaluate (evaluate predicted test-classes)))
	  (format t "~%Accuracy_{KNN} = ~a~%" evaluate))
	;; Plot the predictions
	(plot-binary test-data predicted "Predictions KNN")))))


;; NORMAL BAYES CLASSIFIER
(defun bayes (training-data training-classes test-data test-classes) 
  (with-normal-bayes-classifier ((bayes (normal-bayes-classifier training-data training-classes)))
    (with-mat ((predicted (mat (rows test-classes) 1 +32f+)))
      (dotimes (i (rows test-data))
	(with-mat ((sample (row test-data i)))
	  (setf (@ :float predicted i 0) (normal-bayes-classifier-predict bayes sample))))
      ;; Calculate the accuracy of the Normal Bayes Classifier
      (let ((evaluate (evaluate predicted test-classes)))
	(format t "~%Accuracy_{BAYES} = ~a~%" evaluate))
      ;; Plot the predictions
      (plot-binary test-data predicted "Predictions Bayes"))))


;; NEURAL NETWORK

(defun mlp (training-Data training-Classes test-Data test-Classes) 

  ;; LAYERS

  ;; The purpose of a neural network is to generalize, which is the ability 
  ;; to approximate outputs for inputs not available in the training set. W-
  ;; hile small networks may not be able to approximate a function, large n-
  ;; etworks tend to overfit and not find any relationship in data. It has 
  ;; been shown that, given enough data, a multi layer perceptron with one 
  ;; hidden layer can approximate any continuous function to any degree of 
  ;; accuracy. Here the number of neurons per layer is stored in the row-o-
  ;; rdered MAT below, LAYERS.

  (with-mat ((layers (mat 4 1 +32SC1+)))
    (setf (@ :int layers 0 0) (@ *layer-0* :int)) 
    (setf (@ :int layers 1 0) (@ *layer-1* :int))
    (setf (@ :int layers 2 0) (@ *layer-2* :int))
    (setf (@ :int layers 3 0) (@ *layer-3* :int))
    (with-ann-mlp ((mlp (ann-mlp)))
      (with-term-criteria ((criteria (term-criteria (logior +term-criteria-max-iter+ 
							    +term-criteria-eps+) 
						    100 0.00001d0)))
	(with-ann-mlp-train-params ((params (ann-mlp-train-params criteria 
								  +ann-mlp-train-params-backprop+ 
								  0.05d0 
								  0.05d0)))
	  (ann-mlp-create mlp layers)
	  ;; Train the Neural Net.
	  (with-mat ((predicted (mat (rows test-classes) 1 +32f+))
		     (sample-weights (mat))
		     (sample-idx (mat)))
	    (ann-mlp-train mlp training-data training-classes sample-weights sample-idx params)
	    (dotimes (i (rows test-data))
	      (with-mat ((response (mat 1 1 +32fc1+)))
		(with-mat ((sample (row test-data i)))
		  (ann-mlp-predict mlp sample response))
		(setf (@ :float predicted i 0) (@ :float response 0 0))))
	    ;; Print the values of all adjustable variables.
	    (format t "~%*EQUATION* = ~a~%" (@ *equation* :int))
	    (format t "~%*EQUATION-0* = ~a~%" (@ *equation-0* :int))
	    (format t "~%*EQUATION-1* = ~a~%" (@ *equation-1* :int))
	    (format t "~%*EQUATION-2* = ~a~%" (@ *equation-2* :int))
	    (format t "~%*EQUATION-3* = ~a~%" (@ *equation-3* :int))
	    (format t "~%*OTHER* = ~a~%" (@ *other* :int))
	    (format t "~%*LAYER-0* = ~a~%" (@ *layer-0* :int))
	    (format t "~%*LAYER-1* = ~a~%" (@ *layer-1* :int))
	    (format t "~%*LAYER-2* = ~a~%" (@ *layer-2* :int))
	    (format t "~%*LAYER-3* = ~a~%" (@ *layer-3* :int))
	    ;; Calculate the accuracy of the Neural Net
	    (let ((evaluate (evaluate predicted test-classes)))
	      (format t "~%Accuracy_{MLP} = ~a~%" evaluate))
	    ;; Plot the predictions
	    (plot-binary test-data predicted "Predictions Backpropagation")
	    nil ))))))

;; Plot Data and Class function
(defun plot-binary(data classes name &optional x y) 
  (with-mat ((plot (mat *size* *size* +8uc3+)))
    (with-scalar ((scalar (scalar 255 255 255)))
      (assign plot scalar))
    (dotimes (i (rows data))
      (setf x (* (@ :float data i 0) *size*))
      (setf y (* (@ :float data i 1) *size*))
      (with-scalar ((color1 (rgb 255 0 0))
		    (color2 (rgb 0 255 0)))
	(if (> (@ :float classes i 0) 0f0)
	    ;; Plot the points with the CIRCLE function
	    (with-point ((center (point (round x) (round y))))
	      (circle plot center 1 color1 1))
	    (with-point ((center (point (round x) (round y))))
	      (circle plot center 1 color2 1)))))
    (imshow name plot)))


(defun d-tree-example ()

  "In this example, Decision trees are compared with a K-Nearest 
   Neighbors model, a Normal Bayes Classifier and a Neural Network."

  ;; Window names available to all of the functions
  (let ((window-name-1 "Training data")
	(window-name-2 "Test data")
	(window-name-3 "Predictions Backpropagation")
	(window-name-4 "Predictions Bayes")
	(window-name-5 "Predictions KNN")
	(window-name-6 "Predictions Tree")
	;; Declare other variables
	(training-classes 0)
	(test-classes 0)
	(x 0)
	(y 0))
    ;; Create windows
    (with-named-window (window-name-1 +window-normal+)
      (with-named-window (window-name-2 +window-autosize+)
	(with-named-window (window-name-3 +window-normal+)
	  (with-named-window (window-name-4 +window-normal+)
	    (with-named-window (window-name-5 +window-normal+)
	      (with-named-window (window-name-6 +window-normal+)
		;; Move windows to specified locations
		(move-window window-name-1 288 150)
		(move-window window-name-2 756 0)
		(move-window window-name-3 1188 150)
		(move-window window-name-4 288 518)
		(move-window window-name-5 738 639)
		(move-window window-name-6 1188 518)
		;; Create trackbars used to adjust the values in the (F) 
		;; and (MLP) functions. The trackbar names are hints at 
		;; how not to adjust them e.g. This, 'Eq 0: > 1', means 
		;; do not let the trackbar go below 1. This, 'Layr 0: 2',
		;; means the trackbar must stay at 2. Not following the
		;; guidelines will cause the program to freeze.
		(create-trackbar "Equation" window-name-2 *equation* 4)
		(create-trackbar "Eq 0: > 1" window-name-2 *equation-0* 150)
		(create-trackbar "Eq 1: > 1" window-name-2 *equation-1* 150)
		(create-trackbar "Eq 2: > 1" window-name-2 *equation-2* 10)
		(create-trackbar "Eq 3: > 1" window-name-2 *equation-3* 150)
		(create-trackbar "Other: > 1" window-name-2 *other* 150)
		(create-trackbar "Lyr 0: 2" window-name-2 *layer-0* 10)
		(create-trackbar "Lyr 1: > 2" window-name-2 *layer-1* 500)
		(create-trackbar "Lyr 2: > 2 " window-name-2 *layer-2* 500)
		(create-trackbar "Lyr 3: 1" window-name-2 *layer-3* 5)
		(with-mat ((training-data (mat *num-training-points* 2 +32fc1+))
			   (test-data (mat *num-test-points* 2 +32fc1+)))

		  (loop;; Fill training and test data matrices 
		     ;; with random numbers from zero to one
		     (with-scalar ((zero (scalar 0))
				   (one (scalar 1)))
		       (randu training-data zero one)
		       (randu test-data zero one))

		     ;; Label data with equation
		     (with-mat ((labels1 (mat (rows training-data) 1 +32fc1+)))
		       (dotimes (i (rows training-data))
			 (setf x (@ :float training-data i 0))
			 (setf y (@ :float training-data i 1))
			 (setf (@ :float labels1 i 0) (coerce (f x y (@ *equation* :int)) 
							       'single-float)))

		       (with-mat ((labels2 (mat (rows test-data) 1 +32fc1+)))
			 (dotimes (i (rows test-data))
			   (setf x (@ :float test-data i 0))
			   (setf y (@ :float test-data i 1))
			   (setf (@ :float labels2 i 0) (coerce (f x y (@ *equation* :int)) 
								 'single-float)))
			 (setf training-classes labels1)
			 (setf test-classes labels2)

			 ;; Plot training data
			 (plot-binary training-data training-classes window-name-1)
			 ;; Plot test data
			 (plot-binary test-data test-classes window-name-2)
			 ;; Plot predictions
			 (mlp training-data training-classes test-data test-classes)
			 (bayes training-data training-classes test-data test-classes)
			 (knn training-data training-classes test-data test-classes 3)
			 (decision-tree training-data training-classes test-data test-classes)))
		     (let ((c (wait-key 33)))
		       (when (= c 27)
			 (return)))))))))))))

========================================================================================================================================
#D-TREE-PARAMS
========================================================================================================================================

The constructors.

Note: Both D-TREE-PARAMS and MAKE-D-TREE-PARAMS are provided in this library. The first, to match 
OpenCV's naming conventions, the second, to adhere to Common Lisp naming conventions. Except for the 
name, they are the same function. I use the D-TREE-PARAMS function in the examples in this file because 
it will make them easier to compare with OpenCV examples you find online, thus making this library easier 
to learn.

C++: CvDTreeParams::CvDTreeParams()

C++: CvDTreeParams::CvDTreeParams(int max_depth, int min_sample_count, float regression_accuracy, bool use_surrogates, 
                                  int max_categories, int cv_folds, bool use_1se_rule, bool truncate_pruned_tree, const float* priors)

LISP-CV: (D-TREE-PARAMS (&OPTIONAL (MAX-DEPTH :INT) (MIN-SAMPLE-COUNT :INT) (REGRESSION-ACCURACY :FLOAT) (USE-SURROGATES :BOOLEAN) 
                        (MAX-CATEGORIES :INT) (FOLDS :INT) (USE-1SE-RULE :BOOLEAN) (TRUNCATE-PRUNED-TREE:BOOLEAN) (PRIORS :POINTER)) 
                         => D-TREE-PARAMS

LISP-CV: (MAKE-D-TREE-PARAMS (&OPTIONAL (MAX-DEPTH :INT) (MIN-SAMPLE-COUNT :INT) (REGRESSION-ACCURACY :FLOAT) 
                             (USE-SURROGATES :BOOLEAN) (MAX-CATEGORIES :INT) (FOLDS :INT) (USE-1SE-RULE :BOOLEAN) 
                             (TRUNCATE-PRUNED-TREE:BOOLEAN) (PRIORS :POINTER)) => D-TREE-PARAMS


    Parameters:	

        MAX-DEPTH - The maximum possible depth of the tree. That is the training algorithms attempts 
                    to split a node while its depth is less than MAX-DEPTH. The actual depth may be 
                    smaller if the other termination criteria are met (see the outline of the training 
                    procedure at the top of this link:
   
                    http://docs.opencv.org/trunk/modules/ml/doc/decision_trees.html?highlight=dtreep#decision-trees 

                    ),and/or if the tree is pruned.

        MIN-SAMPLE-COUNT - If the number of samples in a node is less than this parameter then the 
                           node will not be split.

        REGRESSION-ACCURACY - Termination criteria for regression trees. If all absolute differences 
                              between an estimated value in a node and values of train samples in this 
                              node are less than this parameter then the node will not be split.

        USE-SURROGATES - If true then surrogate splits will be built. These splits allow to work with 
                         missing data and compute variable importance correctly.

        MAX-CATEGORIES - Cluster possible values of a categorical variable into (<= K MAX-CATEGORIES) 
                         clusters to find a suboptimal split. If a discrete variable, on which the training 
                         procedure tries to make a split, takes more than MAX-CATEGORIES values, the precise 
                         best subset estimation may take a very long time because the algorithm is exponential. 
                         Instead, many decision trees engines (including The OpenCV ML module) try to find sub-
                         optimal split in this case by clustering all the samples into MAX-CATEGORIES clusters 
                         that is. some categories are merged together. The clustering is applied only in (> N 2)-
                         class classification problems for categorical variables with (> N MAX-CATEGORIES) possible 
                         values. In case of regression and 2-class classification the optimal split can be found 
                         efficiently without employing clustering, thus the parameter is not used in these cases.

        FOLDS - If (> FOLDS 1) then prune a tree with K-fold cross-validation where K is equal to FOLDS.

        USE-1SE-RULE - If true then a pruning will be harsher. This will make a tree more compact and 
                       more resistant to the training data noise but a bit less accurate.

        TRUNCATE-PRUNED-TREE - If true then pruned branches are physically removed from the tree. 
                               Otherwise they are retained and it is possible to get results from 
                               the original unpruned (or pruned less aggressively) tree by decreasing 
                               CvDTree::pruned_tree_idx parameter <- todo.

        PRIORS - The array of a priori class probabilities, sorted by the class label value. The 
                 parameter can be used to tune the decision tree preferences toward a certain class. 
                 For example, if you want to detect some rare anomaly occurrence, the training base 
                 will likely contain much more normal cases than anomalies, so a very good classification 
                 performance will be achieved just by considering every case as normal. To avoid this, the 
                 priors can be specified, where the anomaly probability is artificially increased (up to 0.5 
                 or even greater), so the weight of the misclassified anomalies becomes much bigger, and the 
                 tree is adjusted properly. You can also think about this parameter as weights of prediction 
                 categories which determine relative weights that you give to misclassification. That is, if 
                 the weight of the first category is 1 and the weight of the second category is 10, then each 
                 mistake in predicting the second category is equivalent to making 10 mistakes in predicting 
                 the first category.


The default constructor initializes all the parameters with the default values tuned for the standalone 
classification tree:

Note: Below are the default settings used in the underlying C++ code when D-TREE-PARAMS is called 
without entering any parameters:

CvDTreeParams() : max_categories(10), max_depth(INT_MAX), min_sample_count(10),
    cv_folds(10), use_surrogates(true), use_1se_rule(true),
    truncate_pruned_tree(true), regression_accuracy(0.01f), priors(0)
{}


Example:

See D-TREE-EXAMPLE in this file.

========================================================================================================================================
#D-TREE-PREDICT
========================================================================================================================================

Returns the leaf node of a decision tree corresponding to the input vector.

C++: CvDTreeNode* CvDTree::predict(const Mat& sample, const Mat& missingDataMask=Mat(), bool preprocessedInput=false ) const

LISP-CV: (D-TREE-PREDICT (SELF D-TREE) (SAMPLE MAT) &OPTIONAL ((MISSING-DATA-MASK MAT) (MAT)) 
                         ((PREPROCESSED-INPUT :BOOLEAN) NIL)) => (:POINTER (:STRUCT D-TREE-NODE))


    Parameters:	

        SELF - A D-TREE object.

        SAMPLE - Sample for prediction.

        MISSING-DATA-MASK - Optional input missing measurement mask.

        PREPROCESSED-INPUT - This parameter is normally set to false, implying a regular input. If it 
                             is true, the method assumes that all the values of the discrete input variables 
                             have been already normalized to 0 to (- (NUM-OF-CATEGORIES I) 1) ranges since the 
                             decision tree uses such normalized representation internally. It is useful for faster 
                             prediction with tree ensembles. For ordered input variables, the flag is not used.

The method traverses the decision tree and returns the reached leaf node as output. The prediction 
result, either the class label or the estimated function value, may be retrieved as the value field 
of the D-TREE-NODE structure, for example: 

(let ((prediction (d-tree-predict d-tree sample mask)))
  (with-foreign-slots ((value) prediction (:struct d-tree-node))
		      value))



Example:

See D-TREE-EXAMPLE in this file.

========================================================================================================================================
#D-TREE-TRAIN
========================================================================================================================================

Trains a decision tree.

C++: bool CvDTree::train(const Mat& trainData, int tflag, const Mat& responses, const Mat& varIdx=Mat(), const Mat& sampleIdx=Mat(), const Mat& varType=Mat(), const Mat& missingDataMask=Mat(), CvDTreeParams params=CvDTreeParams() )

LISP-CV:  (D-TREE-TRAIN (SELF D-TREE) (TRAIN-DATA MAT) (TFLAG :INT) (RESPONSES MAT) &OPTIONAL 
                       ((VAR-IDX MAT) (MAT)) ((SAMPLE-IDX MAT) (MAT)) 
                       ((VAR-TYPE MAT) (MAT)) ((MISSING-DATA-MASK MAT) (MAT)) 
                       ((PARAMS D-TREE-PARAMS) (D-TREE-PARAMS))) => :BOOLEAN

    This function follows the generic (STAT-MODEL-TRAIN) conventions. It is the most complete form. 
    Both data layouts (EQ TFLAG +ROW-SAMPLE+) and (EQ TFLAG +COL-SAMPLE+) are supported, as well as 
    sample and variable subsets, missing measurements, arbitrary combinations of input and output 
    variable types, and so on. The last parameter contains all of the necessary training parameters 
    (see the D-TREE-PARAMS description).

The function is parallelized with the TBB library.


Example:

See D-TREE-EXAMPLE in this file.

========================================================================================================================================
#ML - #NEURAL NETWORKS
========================================================================================================================================

========================================================================================================================================
#ANN-MLP
========================================================================================================================================

The constructors.

Note: Both ANN-MLP and MAKE-ANN-MLP are provided in this library. The first, to match OpenCV's naming 
conventions, the second, to adhere to Common Lisp naming conventions. Except for the name, they are 
the same function. I use the ANN-MLP function in the examples in this file because it will make them 
easier to compare with OpenCV examples you find online, thus making this library easier to learn.

C++: CvANN_MLP::CvANN_MLP()

C++: CvANN_MLP::CvANN_MLP(const CvMat* layerSizes, int activateFunc=CvANN_MLP::SIGMOID_SYM, double fparam1=0, double fparam2=0 )

LISP-CV: (ANN-MLP &OPTIONAL (LAYER-SIZES MAT) ((ACTIVATE-FUNC :INT) +ANN-MLP-SIGMOID-SYM+) ((FPARAM1 :DOUBLE) 0D0) 
                            ((FPARAM2 :DOUBLE) 0D0)) => ANN-MLP

LISP-CV: (MAKE-ANN-MLP &OPTIONAL (LAYER-SIZES MAT) ((ACTIVATE-FUNC :INT) +ANN-MLP-SIGMOID-SYM+) ((FPARAM1 :DOUBLE) 0D0) 
                                ((FPARAM2 :DOUBLE) 0D0)) => ANN-MLP

The advanced constructor allows to create MLP with the specified topology. See (ANN-MLP-CREATE) for 
details.


Example:

;; This example implements a feed-forward Artificial Neural Network or 
;; more particularly, Multi-Layer Perceptrons (MLP), the most commonly 
;; used type of Neural Networks. MLP consists of the input layer, outp-
;; ut layer, and one or more hidden layers. Each layer of MLP includes 
;; one or more neurons directionally linked with the neurons from the 
;; previous and the next layer. 


;; Declare global variables.

(defparameter *plot-support-vectors* t)
(defparameter *num-training-points* 200)
(defparameter *num-test-points* 2000)
(defparameter *size* 200)

;; Move the trackbar on the middle window to decide 
;; which equation in the (F) function to use.

(defparameter *equation* (alloc :int 2))

;; Move the trackbars on the middle window to decide 
;; what to multiply X by in the (F) function equatio-
;; ns. Each trackbar in this list corresponds to a s-
;; etting of the *EQUATION* variable and affects the 
;; equations in the (F) function.

(defparameter *equation-0* (alloc :int 10))
(defparameter *equation-1* (alloc :int 10))
(defparameter *equation-2* (alloc :int 2))
(defparameter *equation-3* (alloc :int 10))
(defparameter *equation-other* (alloc :int 10))


;; Calculates the accuracy of the Neural Network. the NN 
;; accuracy is affected the equations and equation's par-
;; ameters you choose for the (F) function.

(defun evaluate (predicted actual &optional p a (*t 0) (f 0)) 
  (if (eq (rows predicted) (rows actual))
      (dotimes (i (rows actual))
	(setf p (@ :float predicted i 0))
	(setf a (@ :float actual i 0))
	(if (or (and (>= p 0.0f0) (>= a 0.0f0)) (and (<= p 0.0f0) (<= a 0.0f0))) 
	    (incf *t)
	    (incf f))) nil)
  (float (/ (* *t 1) (+ *t f))))


;; Function to learn. The trackbars on the middle window change the values held in 
;; the EQUATION-* variables. The (@ *EQUATION-* :INT) statements dereference those 
;; variables and supply their values to the equations in this function. The @ func-
;; tion, is a macro for CFFI::MEM-AREF.

(defun f (x y equation) 
  (case equation (0 (return-from f (if (> y (sin (* x (@ *equation-0* :int)))) -1 1)))
	(1 (return-from f (if (> y (cos (* x (@ *equation-1* :int)))) -1 1)))
	(2 (return-from f (if (> y (* x (@ *equation-2* :int))) -1 1)))
	(3 (return-from f (if (> y (tan (* x (@ *equation-3* :int)))) -1 1)))
	(otherwise (return-from f (if (> y (cos (* x (@ *equation-other* :int)))) -1 1)))))



(defun mlp (training-Data training-Classes test-Data test-Classes) 

  (with-mat ((layers (mat 4 1 +32SC1+)))
    (setf (@ :int layers 0 0) 2)
    (setf (@ :int layers 1 0) 10)
    (setf (@ :int layers 2 0) 15)
    (setf (@ :int layers 3 0) 1)
    (with-ann-mlp ((mlp (ann-mlp)))
      (with-term-criteria ((criteria (term-criteria (logior +term-criteria-max-iter+ 
							    +term-criteria-eps+) 
						    100 0.00001d0)))
	(with-ann-mlp-train-params ((params (ann-mlp-train-params criteria 
								  +ann-mlp-train-params-backprop+ 
								  0.05d0 
								  0.05d0)))
	  (ann-mlp-create mlp layers)
	  ;; Train the NN.
	  (with-mat ((predicted (mat (rows test-classes) 1 +32f+))
                     (sample-weights (mat))
                     (sample-idx (mat)))
	    (ann-mlp-train mlp training-data training-classes sample-weights sample-idx params)
	    (dotimes (i (rows test-data))
	      (with-mat ((response (mat 1 1 +32fc1+)))
		(with-mat ((sample (row test-data i)))
		  (predict mlp sample response))
		(setf (@ :float predicted i 0) (@ :float response 0 0))))
            (format t "~%*EQUATION* = ~a~%" (@ *equation* :int))
            (format t "~%*EQUATION-0* = ~a~%" (@ *equation-0* :int))
            (format t "~%*EQUATION-1* = ~a~%" (@ *equation-1* :int))
            (format t "~%*EQUATION-2* = ~a~%" (@ *equation-2* :int))
            (format t "~%*EQUATION-3* = ~a~%" (@ *equation-3* :int))
            (format t "~%*EQUATION-OTHER* = ~a~%" (@ *equation-other* :int))
            (let ((evaluate (evaluate predicted test-classes)))
	      (format t "~%Accuracy_{MLP} = ~a~%" evaluate) 
	      (plot-binary test-data predicted "Predictions Backpropagation - ANN-MLP Example"))
	    nil ))))))


;; Plot data and class
(defun plot-binary(data classes name &optional x y) 
  (with-mat ((plot (mat *size* *size* +8uc3+)))
    (with-scalar ((scalar (scalar 255 255 255)))
      (assign plot scalar))
    (dotimes (i (rows data))
      (setf x (* (@ :float data i 0) *size*))
      (setf y (* (@ :float data i 1) *size*))
      (with-scalar ((color1 (rgb 255 0 0))
		    (color2 (rgb 0 255 0)))
	(if (> (@ :float classes i 0) 0f0)
	    (with-point ((center (point (round x) (round y))))
	      (circle plot center 1 color1 1))
	    (with-point ((center (point (round x) (round y))))
	      (circle plot center 1 color2 1)))))
    (imshow name plot)))


(defun ann-mlp-example ()

  (let ((window-name-1 "Training data - ANN-MLP Example")
	(window-name-2 "Test data - ANN-MLP Example")
	(window-name-3 "Predictions Backpropagation - ANN-MLP Example")
        ;; Declare other variables
        (training-classes 0)
        (test-classes 0)
        (x 0)
        (y 0))
    ;; Create windows
    (with-named-window (window-name-1 +window-normal+)
      (with-named-window (window-name-2 +window-autosize+)
	(with-named-window (window-name-3 +window-normal+)
          ;; Move windows to specified locations
	  (move-window window-name-1 310 175)
	  (move-window window-name-2 760 175)
	  (move-window window-name-3 1210 175)
          ;; Create trackbars used to adjust 
          ;; the (F) function equations
	  (create-trackbar "Equation" window-name-2 *equation* 4)
	  (create-trackbar "Equation 0" window-name-2 *equation-0* 150)
	  (create-trackbar "Equation 1" window-name-2 *equation-1* 150)
	  (create-trackbar "Equation 2" window-name-2 *equation-2* 10)
	  (create-trackbar "Equation 3" window-name-2 *equation-3* 150)
	  (create-trackbar "Eq. Other" window-name-2 *equation-other* 150)
	  (with-mat ((training-data (mat *num-training-points* 2 +32fc1+))
		     (test-data (mat *num-test-points* 2 +32fc1+)))

	    (loop;; Fill training and test data matrices 
	       ;; with random numbers from zero to one
	       (with-scalar ((zero (scalar 0))
			     (one (scalar 1)))
		 (randu training-data zero one)
		 (randu test-data zero one))

               ;; Label data with equation
	       (with-mat ((labels1 (mat (rows training-data) 1 +32fc1+)))
		 (dotimes (i (rows training-data))
		   (setf x (@ :float training-data i 0))
		   (setf y (@ :float training-data i 1))
		   (setf (@ :float labels1 i 0) (coerce (f x y (@ *equation* :int)) 
							'single-float)))

		 (with-mat ((labels2 (mat (rows test-data) 1 +32fc1+)))
		   (dotimes (i (rows test-data))
		     (setf x (@ :float test-data i 0))
		     (setf y (@ :float test-data i 1))
		     (setf (@ :float labels2 i 0) (coerce (f x y (@ *equation* :int))
							  'single-float)))

		   (setf training-classes labels1)
		   (setf test-classes labels2)

                   ;; Plot training data
		   (plot-binary training-data training-classes window-name-1)
                   ;; Plot test data
		   (plot-binary test-data test-classes window-name-2)
                   ;; Plot predictions
		   (mlp training-data training-classes test-data test-classes)))
	       (let ((c (wait-key 33)))
		 (when (= c 27)
		   (return))))))))))

========================================================================================================================================
#ANN-MLP-CREATE
========================================================================================================================================

Constructs MLP with the specified topology.

C++: void CvANN_MLP::create(const Mat& layerSizes, int activateFunc=CvANN_MLP::SIGMOID_SYM, double fparam1=0, double fparam2=0 )

LISP-CV: (ANN-MLP-CREATE (SELF ANN-MLP) (LAYER-SIZES MAT) &OPTIONAL ((ACTIVATE-FUNC :INT) +ANN-MLP-SIGMOID-SYM+) 
                         ((FPARAM1 :DOUBLE) 0D0) ((FPARAM2 :DOUBLE) 0D0)) => :VOID


    Parameters:	

        LAYER-SIZES - Integer vector specifying the number of neurons in each layer including the 
                      input and output layers.

        ACTIVATE-FUNC - Parameter specifying the activation function for each neuron: one of;
                        +ANN-MLP-IDENTITY+, +ANN-MLP-SIGMOID-SYM+, +ANN-MLP-GAUSSIAN+ 

        FPARAM1 - Free parameter of the ALPHA activation function. See the formulas in the 
                  introduction section.

        FPARAM2 - Free parameter of the BETA activation function. See the formulas in the 
                  introduction section.


Note: Introduction section of the OpenCV Neural Network documentation is at the top of this link:

http://docs.opencv.org/trunk/modules/ml/doc/neural_networks.html

There you will find a more complete explanation of the activation functions as well as the formulae.


The method creates an MLP network with the specified topology and assigns the same activation function 
to all the neurons.


Example:

See ANN-MLP-EXAMPLE in this file.

========================================================================================================================================
#ANN-MLP-PREDICT
========================================================================================================================================

Predicts responses for input samples.

C++: float CvANN_MLP::predict(const Mat& inputs, Mat& outputs) const

LISP-CV: (ANN-MLP-PREDICT (SELF ANN-MLP) (INPUTS MAT) (OUTPUTS MAT)) => :FLOAT


    Parameters:	

        SELF - An ANN-MLP object

        INPUT - Input samples.

        OUTPUTS - Predicted responses for corresponding samples.


The method returns a dummy value which should be ignored.

If you are using the default +ANN-MLP-SIGMOID-SYM+ activation function with the default parameter 
values (EQ FPARAM1 0) and (EQ FPARAM2 0) then the function used is (EQ Y (* 1.7159 (TANH (* 2/3 X)))),
so the output will range from (-1.7159, 1.7159), instead of (0,1).


Example:

See ANN-MLP-EXAMPLE in this file.

========================================================================================================================================
#ANN-MLP-TRAIN
========================================================================================================================================

Trains/updates MLP.

C++: int CvANN_MLP::train(const Mat& inputs, const Mat& outputs, const Mat& sampleWeights, const Mat& sampleIdx=Mat(), CvANN_MLP_TrainParams params=CvANN_MLP_TrainParams(), int flags=0 )

LISP-CV: (ANN-MLP-TRAIN (SELF ANN-MLP) (INPUTS MAT) (OUTPUTS MAT) (SAMPLE-WEIGHTS MAT) &OPTIONAL 
                        ((SAMPLE-IDX MAT) (MAT)) ((PARAMS ANN-MLP-TRAIN-PARAMS) (ANN-MLP-TRAIN-PARAMS)) 
                        ((FLAGS :INT) 0)) => :INT

    Parameters:	

        INPUTS - Floating-point matrix of input vectors, one vector per row.

        OUTPUTS - Floating-point matrix of the corresponding output vectors, one vector per row.

        SAMPLE-WEIGHTS - (RPROP only) Optional floating-point vector of weights for each sample. 
                         Some samples may be more important than others for training. You may want 
                         to raise the weight of certain classes to find the right balance between 
                         hit-rate and false-alarm rate, and so on.

        SAMPLE-IDX - Optional integer vector indicating the samples (rows of inputs and outputs) that 
                     are taken into account.

        PARAMS - Training parameters. See the ANN-MLP-TRAIN-PARAMS description.

        FLAGS -

          Various parameters to control the training algorithm.
          A combination of the following parameters is possible:

            +UPDATE-WEIGHTS+ Algorithm updates the network weights, rather than computes them from scratch. 
                             In the latter case the weights are initialized using the Nguyen-Widrow algorithm.

            +NO-INPUT-SCALE+ Algorithm does not normalize the input vectors. If this flag is not set, 
                             the training algorithm normalizes each input feature independently, shifting 
                             its mean value to 0 and making the standard deviation equal to 1. If the network 
                             is assumed to be updated frequently, the new training data could be much different 
                             from original one. In this case, you should take care of proper normalization.

            +NO-OUTPUT-SCALE+ Algorithm does not normalize the output vectors. If the flag is not set, 
                              the training algorithm normalizes each output feature independently, by 
                              transforming it to the certain range depending on the used activation function.


This method applies the specified training algorithm to computing/adjusting the network weights. It 
returns the number of done iterations.

The RPROP training algorithm is parallelized with the TBB library.

If you are using the default ANN-MLP-SIGMOID-SYM+ activation function then the output should be in 
the range [-1,1], instead of [0,1], for optimal results.


Example:

See ANN-MLP-EXAMPLE in this file.

========================================================================================================================================
#ANN-MLP-TRAIN-PARAMS
========================================================================================================================================

The constructors.

Note: Both ANN-MLP-PARAMS and MAKE-ANN-MLP-PARAMS are provided in this library. The first, to match 
OpenCV's naming conventions, the second, to adhere to Common Lisp naming conventions. Except for the 
name, they are the same function. I use the ANN-MLP-PARAMS function in the examples in this file because 
it will make them easier to compare with OpenCV examples you find online, thus making this library easier 
to learn.

C++: CvANN_MLP_TrainParams::CvANN_MLP_TrainParams()

C++: CvANN_MLP_TrainParams::CvANN_MLP_TrainParams(CvTermCriteria term_crit, int train_method, double param1, double param2=0 )

LISP-CV: (ANN-MLP-TRAIN-PARAMS (TERM-CRIT TERM-CRITERIA) (TRAIN-METHOD :INT) (PARAM1 :DOUBLE) ((PARAM2 :DOUBLE) 0.0D0)) 
                                => ANN-MLP-TRAIN-PARAMS

LISP-CV: (MAKE-ANN-MLP-TRAIN-PARAMS (TERM-CRIT TERM-CRITERIA) (TRAIN-METHOD :INT) (PARAM1 :DOUBLE) ((PARAM2 :DOUBLE) 0.0D0)) 
                                     => ANN-MLP-TRAIN-PARAMS

    Parameters:	

        TERM-CRIT - Termination criteria of the training algorithm. You can specify the maximum number 
                    of iterations (MAX-COUNT) and/or how much the error could change between the iterations 
                    to make the algorithm continue (EPSILON).

        TRAIN-METHOD -

        Training method of the MLP. Possible values are:

            +ANN-MLP-TRAIN-PARAMS-BACKPROP+ - The back-propagation algorithm.

            +ANN-MLP-TRAIN-PARAMS-RPROP+ - The RPROP algorithm.

        PARAM1 - Parameter of the training method. It is rp_dw0 for RPROP and bp_dw_scale for BACKPROP.

        PARAM2 - Parameter of the training method. It is rp_dw_min for RPROP and bp_moment_scale for 
                 BACKPROP.


Note: In OpenCV, rp_dw0, bp_dw_scale, rp_dw_min and bp_moment_scale are names of CvANN_MLP_TrainParams
struct members. The CvANN_MLP_TrainParams class is represented in Lisp as a pointer to the class named
ANN-MLP-TRAIN-PARAMS so the specific struct members are not referenced e.g. you will need to remember: 


If you are using the back-propagation algorithm:

   PARAM1 supplies the bp_dw_scale member value.

   PARAM2 supplies the bp_moment_scale member value.


If you are using the RPROP algorithm:

   PARAM1 supplies the rp_dw0 member value.

   PARAM2 supplies the rp_dw_min member value.



By default the RPROP algorithm is used. The following code from:

<Open-Cv-Source-Directory>/modules/ml/src/ann_mlp.cpp 

is how this function is called(in C++) when no values are supplied.


CvANN_MLP_TrainParams::CvANN_MLP_TrainParams()
{
    term_crit = cvTermCriteria( CV_TERMCRIT_ITER + CV_TERMCRIT_EPS, 1000, 0.01 );
    train_method = RPROP;
    bp_dw_scale = bp_moment_scale = 0.1;
    rp_dw0 = 0.1; rp_dw_plus = 1.2; rp_dw_minus = 0.5;
    rp_dw_min = FLT_EPSILON; rp_dw_max = 50.;
}


Example:

See ANN-MLP-EXAMPLE in this file.

========================================================================================================================================
#PHOTO - #INPAINTING
========================================================================================================================================

========================================================================================================================================
#IN-PAINT
========================================================================================================================================

Restores the selected region in an image using the region neighborhood.

C++: void inpaint(InputArray src, InputArray inpaintMask, OutputArray dst, double inpaintRadius, int flags)

LISP-CV: (IN-PAINT (SRC MAT) (IN-PAINT-MASK MAT) (DEST MAT) (IN-PAINT-RADIUS :DOUBLE) (FLAGS :INT)) => :VOID


    Parameters:	

        SRC - Input 8-bit 1-channel or 3-channel image.

        IN-PAINT-MASK - Inpainting mask, 8-bit 1-channel image. Non-zero pixels indicate the area 
                        that needs to be inpainted.

        DEST - Output image with the same size and type as SRC.

        IN-PAINT-RADIUS - Radius of a circular neighborhood of each point inpainted that is considered 
                          by the algorithm.

        FLAGS -

        Inpainting method that could be one of the following:

            +INPAINT-NS+ Navier-Stokes based method [Navier01]

            +INPAINT-TELEA+ Method by Alexandru Telea [Telea04].


The function reconstructs the selected image area from the pixel near the area boundary. The function 
may be used to remove dust and scratches from a scanned photo, or to remove undesirable objects from 
still images or video. See http://en.wikipedia.org/wiki/Inpainting for more details.


Example:

(defparameter pt 0)
(defparameter prev-pt 0)
(defparameter color 0)
(defparameter img 0)
(defparameter in-paint-mask 0)

(defun help ()

  (format t "~%Cool inpainting demonstration.")
  (format t "~%~%Inpainting repairs damage to images by floodfilling")
  (format t "~%the damage with surrounding image areas.")
  (format t "~%~%Hot keys:")
  (format t "~%~%ESC - quit the program")
  (format t "~%~%r - restore the original image")
  (format t "~%~%i or SPACE - run inpainting algorithm")
  (format t "~%~%(before running it, paint something on the image)~%~%"))


(defcallback on-mouse :void ((event :int) (x :int) (y :int) (flags :int))

  (if (or (= event +event-lbuttonup+) (zerop (logand flags +event-flag-lbutton+)))
      (setf prev-pt (gc:point -1 -1))
      (if (eq event +event-lbuttondown+)
	  (setf prev-pt (gc:point x y))
	  (if (and (eq event +event-mousemove+) (logand flags +event-flag-lbutton+))
	      (progn
		(setf pt (gc:point x y))
		(setf color (gc:scalar-all 255))
		(if (< (x prev-pt) 0)
		    (setf prev-pt pt))
		(line in-paint-mask prev-pt pt color 5 8 0)
		(line img prev-pt pt color 5 8 0)
		(setf prev-pt pt)
		(imshow "Image - IN-PAINT Example" img))))))


(defun in-paint-example (&optional filename)
  (if (not filename)
      (return-from in-paint-example 
	(progn (format t "~%Usage:")
	       (format t "~%~%(in-paint-example <image-name>)")
	       (format t "~%~%Try <lisp-cv-dir>/images/damaged-img-by-glen-luchford.jpeg~%~%"))))
  (let ((window-name-1 "Image - IN-PAINT Example")
	(window-name-2 "Inpainted image - IN-PAINT Example"))
    ;; load image
    (with-mat ((img (imread filename -1))
	       (img0 (clone img))    
	       (in-paint-mask (mat-zeros (rows img) (cols img) +8u+)))
      (if (empty img) 
	  (return-from in-paint-example
	    (format t "Couldn't open the image.")))
      (help)
      (with-named-window (window-name-1 +window-normal+)
	(with-named-window (window-name-2 +window-normal+)
	  (move-window window-name-1 533 175)
	  (move-window window-name-2 984 175)
	  (imshow window-name-1 img)
	  (imshow window-name-2 img)
	  (set-mouse-callback window-name-1 (callback on-mouse))
	  (loop 
	     (let ((c (wait-key)))
	       (if (eq c 27)
		   (return))
	       (if (eq c 114)
		   (with-scalar ((zeros (scalar-all 0)))
		     (assign in-paint-mask zeros)
		     (copy-to img0 img)
		     (imshow window-name-1 img)))
	       (if (or (eq c 105) (eq c 32))
		   (with-mat ((in-painted (mat)))
		     (in-paint img in-paint-mask in-painted 3d0 +inpaint-telea+)  
		     (imshow window-name-2 in-painted))))))))))

========================================================================================================================================
#PHOTO - #DECOLORIZATION
========================================================================================================================================

========================================================================================================================================
#DECOLOR
========================================================================================================================================

Transforms a color image to a grayscale image. It is a basic tool in digital printing, stylized 
black-and-white photograph rendering, and in many single channel image processing applications.

C++: void decolor(InputArray src, OutputArray grayscale, OutputArray color_boost)

LISP-CV: (DECOLOR (SRC MAT) (GRAYSCALE MAT) (COLOR-BOOST MAT)) => :VOID

    Parameters:	

        SRC - Input 8-bit 3-channel image.

        GRAYSCALE - Output 8-bit 1-channel image.

        COLOR-BOOST - Output 8-bit 3-channel image.


This function is to be applied on color images.


(defun decolor-example (filename)

  (let ((window-name-1 "SOURCE - DECOLOR Example")
	(window-name-2 "GRAYSCALE - DECOLOR Example")
	(window-name-3 "COLOR-BOOST - DECOLOR Example"))
    (with-named-window (window-name-1 +window-normal+)
      (with-named-window (window-name-2 +window-normal+)
	(with-named-window (window-name-3 +window-normal+)
	  (move-window window-name-1 310 175)
	  (move-window window-name-2 760 175)
	  (move-window window-name-3 1210 175)
	  (with-mat ((source (imread filename 1))
		     (grayscale (mat))
		     (color-boost (mat)))
	    (if (empty source)
		(return-from decolor-example))
	    (decolor source grayscale color-boost)
	    (imshow window-name-1 source)
	    (imshow window-name-2 grayscale)
	    (imshow window-name-3 color-boost)
	    (loop
	       (let ((c (wait-key 33)))
		 (when (= c 27)
		   (return))))))))))

========================================================================================================================================
#PHOTO - #SEAMLESS CLONING
========================================================================================================================================

========================================================================================================================================
#COLOR-CHANGE
========================================================================================================================================

Given an original color image, two differently colored versions of this image can be mixed seamlessly.


C++: void colorChange(InputArray src, InputArray mask, OutputArray dst, float red_mul=1.0f, float green_mul=1.0f, float blue_mul=1.0f)

LISP-CV: (COLOR-CHANGE (SRC MAT) (MASK MAT) (DEST MAT) &OPTIONAL ((RED-MUL :FLOAT) 1.0F0) ((GREEN-MUL :FLOAT) 1.0F0) 
                      ((BLUE-MUL :FLOAT) 1.0F0)) => :VOID

    Parameters:	

        SRC - Input 8-bit 3-channel image.

        MASK - Input 8-bit 1 or 3-channel image.

        DEST - Output image with the same size and type as SRC.

        RED-MUL - R-channel multiply factor.

        GREEN-MUL - G-channel multiply factor.

        BLUE-MUL - B-channel multiply factor.


Multiplication factor is between 0.5f0 to 2.5f0.


Example:

(defparameter *cloning-dir*
  (cat *lisp-cv-src-dir* "images/cloning"))

(defun color-change-example ()

  (let ((window-name-1 "SOURCE - COLOR-CHANGE Example")
	(window-name-2 "MASK - COLOR-CHANGE Example")
	(window-name-3 "RESULT - COLOR-CHANGE Example"))
    (with-named-window (window-name-1 +window-normal+)
      (with-named-window (window-name-2 +window-normal+)
	(with-named-window (window-name-3 +window-normal+)
	  (move-window window-name-1 310 175)
	  (move-window window-name-2 760 175)
	  (move-window window-name-3 1210 175)
	  (with-mat ((source (imread (cat *cloning-dir* "/color-change/source.png") 1))
		     (mask (imread (cat *cloning-dir* "/color-change/mask.png") 1))
		     (result (clone source)))
	    (if (empty source)
		(return-from color-change-example 
		  (format t "Could not load source image")))
	    (if (empty mask)
		(return-from color-change-example 
		  (format t "Could not load mask image")))
	    (color-change source mask result 1.5f0 0.5f0 0.5f0)
	    (imwrite (cat *cloning-dir* "/mixed-cloning/cloned.png") result)
	    (imshow window-name-1 source)
	    (imshow window-name-2 mask)
	    (imshow window-name-3 result)
	    (loop
	       (let ((c (wait-key 33)))
		 (when (= c 27)
		   (return))))))))))

========================================================================================================================================
#ILLUMINATION-CHANGE
========================================================================================================================================

Applying an appropriate non-linear transformation to the gradient field inside the selection and 
then integrating back with a Poisson solver, modifies locally the apparent illumination of an 
image.

C++: void illuminationChange(InputArray src, InputArray mask, OutputArray dst, float alpha=0.2f, float beta=0.4f)

LISP-CV: (ILLUMINATION-CHANGE (SRC MAT) (MASK MAT) (DEST MAT) &OPTIONAL ((ALPHA :FLOAT) 0.2F0) ((BETA :FLOAT) 0.4F0)) => :VOID

    Parameters:	

        SRC - Input 8-bit 3-channel image.

        MASK - Input 8-bit 1 or 3-channel image.

        DEST - Output image with the same size and type as SRC.

        ALPHA - Value ranges between 0-2.

        BETA - Value ranges between 0-2.


This is useful to highlight under-exposed foreground objects or to reduce specular reflections.



(defparameter *cloning-dir*
  (cat *lisp-cv-src-dir* "images/cloning"))

(defun illumination-change-example ()

  (let ((window-name-1 "SOURCE - ILLUMINATION-CHANGE Example")
	(window-name-2 "MASK - ILLUMINATION-CHANGE Example")
	(window-name-3 "RESULT - ILLUMINATION-CHANGE Example"))
    (with-named-window (window-name-1 +window-normal+)
      (with-named-window (window-name-2 +window-normal+)
	(with-named-window (window-name-3 +window-normal+)
	  (move-window window-name-1 310 175)
	  (move-window window-name-2 760 175)
	  (move-window window-name-3 1210 175)
	  (with-mat ((source (imread (cat *cloning-dir* "/illumination-change/source.png") 1))
		     (mask (imread (cat *cloning-dir* "/illumination-change/mask.png") 1))
		     (result (clone source)))
	    (if (empty source)
		(return-from illumination-change-example
		  (format t "Could not load source image")))
	    (if (empty mask)
		(return-from illumination-change-example 
		  (format t "Could not load mask image")))
	    (illumination-change source mask result 0.2f0 0.4f0)
	    (imwrite (cat *cloning-dir* "/illumination-change/cloned.png") result)
	    (imshow window-name-1 source)
	    (imshow window-name-2 mask)
	    (imshow window-name-3 result)
	    (loop
	       (let ((c (wait-key 33)))
		 (when (= c 27)
		   (return))))))))))

========================================================================================================================================
#SEAMLESS-CLONE
========================================================================================================================================

Image editing tasks concern either global changes (color/intensity corrections, filters, deformations) 
or local changes concerned to a selection. Here we are interested in achieving local changes, ones that 
are restricted to a region manually selected (ROI), in a seamless and effortless manner. The extent of 
the changes ranges from slight distortions to complete replacement by novel content.

C++: void seamlessClone(InputArray src, InputArray dst, InputArray mask, Point p, OutputArray blend, int flags)

LISP-CV:  (SEAMLESS-CLONING (SRC MAT) (DEST MAT) (MASK MAT) (P POINT) (BLEND MAT) (FLAGS :INT))  => :VOID

    Parameters:	

        SRC - Input 8-bit 3-channel image.

        DST - Input 8-bit 3-channel image.

        MASK - Input 8-bit 1 or 3-channel image.

        P - Point in DST image where object is placed.

        RESULT - Output image with the same size and type as DST.

        FLAGS -

        Cloning method that could be one of the following:

            +NORMAL-CLONE+ The power of the method is fully expressed when inserting objects with 
                           complex outlines into a new background.

            +MIXED-CLONE+ The classic method, color-based selection and alpha

                masking might be time consuming and often leaves an undesirable halo. Seamless cloning, 
                even averaged with the original image, is not effective. Mixed seamless cloning based 
                on a loose selection proves effective.

            +FEATURE-EXCHANGE+ Feature exchange allows the user to replace easily certain
                features of one object by alternative features.


Example 1:

(defparameter *cloning-dir*
  (cat *lisp-cv-src-dir* "images/cloning"))

(defun seamless-cloning-example-1 ()

  (let ((window-name-1 "SOURCE - SEAMLESS-CLONING Example 1")
        (window-name-2 "DESTINATION - SEAMLESS-CLONING Example 1")
	(window-name-3 "MASK - SEAMLESS-CLONING Example 1")
	(window-name-4 "RESULT - SEAMLESS-CLONING Example 1"))
    (with-named-window (window-name-1 +window-normal+)
      (with-named-window (window-name-2 +window-normal+)
	(with-named-window (window-name-3 +window-normal+)
	  (with-named-window (window-name-4 +window-normal+)
	    (move-window window-name-1 485 98)
	    (move-window window-name-2 894 98)
	    (move-window window-name-3 485 444)
	    (move-window window-name-4 894 444)
	    (with-mat ((source (imread (cat *cloning-dir* "/normal-cloning/source.png") 1))
		       (destination (imread (cat *cloning-dir* "/normal-cloning/destination.png") 1))
		       (mask (imread (cat *cloning-dir* "/normal-cloning/mask.png") 1))
		       (result (clone source)))
	      (if (empty source)
		  (return-from seamless-cloning-example-1 
		    (format t "Could not load source image")))
	      (if (empty destination)
		  (return-from seamless-cloning-example-1 
		    (format t "Could not load destination image")))
	      (if (empty mask)
		  (return-from seamless-cloning-example-1 
		    (format t "Could not load mask image")))
	      (with-point ((p (point 400 100)))
		(seamless-clone source destination mask p result +normal-clone+)
		(imwrite (cat *cloning-dir* "/normal-cloning/cloned.png") result)
		(imshow window-name-1 source)
		(imshow window-name-2 destination)
		(imshow window-name-3 mask)
		(imshow window-name-4 result)
		(loop
		   (let ((c (wait-key 33)))
		     (when (= c 27)
		       (return))))))))))))



Example 2:

(defparameter *cloning-dir*
  (cat *lisp-cv-src-dir* "images/cloning"))

(defun seamless-cloning-example-2 ()

  (let ((window-name-1 "SOURCE - SEAMLESS-CLONING Example 2")
	(window-name-2 "DESTINATION - SEAMLESS-CLONING Example 2")
	(window-name-3 "MASK - SEAMLESS-CLONING Example 2")
	(window-name-4 "RESULT - SEAMLESS-CLONING Example 2"))
    (with-named-window (window-name-1 +window-normal+)
      (with-named-window (window-name-2 +window-normal+)
	(with-named-window (window-name-3 +window-normal+)
	  (with-named-window (window-name-4 +window-normal+)
	    (move-window window-name-1 485 98)
	    (move-window window-name-2 894 98)
	    (move-window window-name-3 485 444)
	    (move-window window-name-4 894 444)
	    (with-mat ((source (imread (cat *cloning-dir* "/monochrome-transfer/source.png") 1))
		       (destination (imread (cat *cloning-dir* "/monochrome-transfer/destination.png") 1))
		       (mask (imread (cat *cloning-dir* "/monochrome-transfer/mask.png") 1))
		       (result (clone source)))
	      (if (empty source)
		  (return-from seamless-cloning-example-2 
		    (format t "Could not load source image")))
	      (if (empty destination)
		  (return-from seamless-cloning-example-2 
		    (format t "Could not load destination image")))
	      (if (empty mask)
		  (return-from seamless-cloning-example-2 
		    (format t "Could not load mask image")))
	      (with-point ((p (point (- (round (/ (width (size destination)) 2)) 10)
				     (round (/ (height (size destination)) 2)))))
		(seamless-clone source destination mask p result +feature-exchange+)
		(imwrite (cat *cloning-dir* "/mixed-cloning/cloned.png") result)
		(imshow window-name-1 source)
		(imshow window-name-2 destination)
		(imshow window-name-3 mask)
		(imshow window-name-4 result)
		(loop
		   (let ((c (wait-key 33)))
		     (when (= c 27)
		       (return))))))))))))

========================================================================================================================================
#TEXTURE-FLATTENING
========================================================================================================================================

By retaining only the gradients at edge locations, before integrating with the Poisson solver, one 
washes out the texture of the selected region, giving its contents a flat aspect. Here Canny Edge 
Detector is used.

C++: void textureFlattening(InputArray src, InputArray mask, OutputArray dst, double low_threshold=30 , double high_threshold=45, 
                            int kernel_size=3)

LISP-CV: (TEXTURE-FLATTENING (SRC MAT) (MASK MAT) (DEST MAT) &OPTIONAL ((LOW-THRESHOLD :DOUBLE) 30D0) 
                            ((HIGH-THRESHOLD :DOUBLE) 45D0) ((KERNAL-SIZE :INT) 3)) => :VOID

    Parameters:	

        SRC - Input 8-bit 3-channel image.

        MASK - Input 8-bit 1 or 3-channel image.

        DEST - Output image with the same size and type as SRC.

        LOW-THRESHOLD - Range from 0 to 100.

        HIGH-THRESHOLD - Value > 100.

        KERNEL-SIZE - The size of the Sobel kernel to be used.


NOTE:

The algorithm assumes that the color of the source image is close to that of the destination. This 
assumption means that when the colors don’t match, the source image color gets tinted toward the 
color of the destination image.


(defparameter *cloning-dir*
  (cat *lisp-cv-src-dir* "images/cloning"))

(defun texture-flattening-example ()

  (let ((window-name-1 "SOURCE - TEXTURE-FLATTENING Example")
	(window-name-2 "MASK - TEXTURE-FLATTENING Example")
	(window-name-3 "RESULT - TEXTURE-FLATTENING Example"))
    (with-named-window (window-name-1 +window-normal+)
      (with-named-window (window-name-2 +window-normal+)
	(with-named-window (window-name-3 +window-normal+)
	  (move-window window-name-1 310 175)
	  (move-window window-name-2 760 175)
	  (move-window window-name-3 1210 175)
	  (with-mat ((source (imread (cat *cloning-dir* "/texture-flattening/source.png") 1))
		     (mask (imread (cat *cloning-dir* "/texture-flattening/mask.png") 1))
		     (result (clone source)))
	    (if (empty source)
		(return-from texture-flattening-example
		  (format t "Could not load source image")))
	    (if (empty mask)
		(return-from texture-flattening-example 
		  (format t "Could not load mask image")))
	    (texture-flattening source mask result 30d0 45d0 3)
	    (imwrite (cat *cloning-dir* "/texture-flattening/cloned.png") result)
	    (imshow window-name-1 source)
	    (imshow window-name-2 mask)
	    (imshow window-name-3 result)
	    (loop
	       (let ((c (wait-key 33)))
		 (when (= c 27)
		   (return))))))))))

========================================================================================================================================
#PHOTO - #NON-PHOTOREALISTIC RENDERING
========================================================================================================================================

========================================================================================================================================
#DETAIL-ENHANCE
========================================================================================================================================

This filter enhances the details of a particular image.


C++: void detailEnhance(InputArray src, OutputArray dst, float sigma_s=10, float sigma_r=0.15f)

LISP-CV: (DETAIL-ENHANCE (SRC MAT) (DEST MAT) &OPTIONAL ((SIGMA-S :FLOAT) 60F0) ((SIGMA-R :FLOAT) 0.45F0)) => :VOID


    Parameters:	

        SRC - Input 8-bit 3-channel image.

        DEST - Output image with the same size and type as SRC.

        SIGMA-S - Range between 0 to 200.

        SIGMA-R - Range between 0 to 1.


Example:

See STYLIZATION-EXAMPLE in this file.

========================================================================================================================================
EDGE-PRESERVING-FILTER
========================================================================================================================================

Filtering is the fundamental operation in image and video processing. Edge-preserving smoothing filters 
are used in many different applications.

C++: void edgePreservingFilter(InputArray src, OutputArray dst, int flags=1, float sigma_s=60, float sigma_r=0.4f)

LISP-CV: (EDGE-PRESERVING-FILTER (SRC MAT) (DEST MAT) &OPTIONAL ((FLAGS :INT) 1) ((SIGMA-S :FLOAT) 60F0) 
                                ((SIGMA-R :FLOAT) 0.4F0)) => :VOID

    Parameters:	

        SRC - Input 8-bit 3-channel image.

        DEST - Output 8-bit 3-channel image.

        FLAGS -

        Edge preserving filters:

              +RECURS-FILTER+

              +NORMCONV-FILTER+

        SIGMA-S - Range between 0 to 200.

        SIGMA-R - Range between 0 to 1.


Example:

See STYLIZATION-EXAMPLE in this file.

========================================================================================================================================
#PENCIL-SKETCH
========================================================================================================================================

Pencil-like non-photorealistic line drawing.


C++: void pencilSketch(InputArray src, OutputArray dst1, OutputArray dst2, float sigma_s=60, float sigma_r=0.07f, 
                       float shade_factor=0.02f)

LISP-CV: (PENCIL-SKETCH (SRC MAT) (DEST1 MAT) (DEST2 MAT) &OPTIONAL ((SIGMA-S :FLOAT) 60F0) ((SIGMA-R :FLOAT) 0.07F0) 
                       ((SHADE-FACTOR :FLOAT) 0.02F0)) => :VOID

    Parameters:	

        SRC - Input 8-bit 3-channel image.

        DEST1 - Output 8-bit 1-channel image.

        DEST2 - Output image with the same size and type as SRC.

        SIGMA-S - Range between 0 to 200.

        SIGMA-R - Range between 0 to 1.

        SHADE-FACTOR - Range between 0 to 0.1.


Example:

See STYLIZATION-EXAMPLE in this file.

========================================================================================================================================
#STYLIZATION
========================================================================================================================================

Stylization aims to produce digital imagery with a wide variety of effects not focused on photorealism.
Edge-aware filters are ideal for stylization, as they can abstract regions of low contrast while preserving, 
or enhancing, high-contrast features.


C++: void stylization(InputArray src, OutputArray dst, float sigma_s=60, float sigma_r=0.45f)

LISP-CV: (STYLIZATION (SRC MAT) (DEST MAT) &OPTIONAL ((SIGMA-S :FLOAT) 60F0) ((SIGMA-R :FLOAT) 0.45F0)) => :VOID

    Parameters:	

        SRC - Input 8-bit 3-channel image.

        DEST - Output image with the same size and type as src.

        SIGMA-S - Range between 0 to 200.

        SIGMA-R - Range between 0 to 1.


Example:

(defun stylization-example (filename)

  "Note: If you don't get good results, try changing the 
   parameters or using different picture. Some pictures 
   don't work well with this example but most look great"

    (with-mat ((i (imread filename 1))
	       (img (mat))
	       (img1 (mat)))
      (if (empty i) 
	  (return-from stylization-example 
	    (format t "Image not found")))

      (format t "~%~% Edge Preserve Filter")
      (format t "~%----------------------")

      (format t "~%Options: ~%~%")

      (format t "~%~%1) Edge Preserve Smoothing")
      (format t "~%~%  a) Using Normalized convolution Filter")
      (format t "~%~%  b) Using Recursive Filter")
      (format t "~%~%2) Detail Enhancement")
      (format t "~%~%3) Pencil sketch/Color Pencil Drawing")
      (format t "~%~%4) Stylization~%~%")
      (format t "~%~%Press number 1-4 to choose from above techniques: ")
      (format t "~%~%Enter a number: ")
      (let ((num (read)))
	(if (eq num 1)
	    (progn (format t "~%~%Press 1 for Normalized Convolution Filter: ")
		   (format t "~%~%Press 2 for Recursive Filter: ")
                   (format t "~%~%Enter a number: ")
		   (let ((type (read)))
		     (edge-preserving-filter i img type))
		   (imshow "Edge Preserve Smoothing" img)
		   (move-window "Edge Preserve Smoothing" 759 175))
	    (if (eq num 2)
		(progn (detail-enhance i img)
		       (imshow "Detail Enhanced" img)
		       (move-window "Detail Enhanced" 759 175))
		(if (eq num 3)
		    (progn (pencil-sketch i img1 img 10f0 0.1f0 0.03f0)
			   (imshow "Pencil Sketch" img1)
			   (imshow "Color Pencil Sketch" img)
			   (move-window "Pencil Sketch" 533 175)
			   (move-window "Color Pencil Sketch" 984 175))
		    (if (eq num 4)
			(progn (stylization i img)
			       (imshow "Stylization" img)
			       (move-window "Stylization" 759 175))))))
	(loop
	   (let ((c (wait-key 33)))
	     (when (= c 27)
	       (destroy-all-windows)
	       (return)))))))

========================================================================================================================================
#NONFREE - #FEATURE DETECTION AND DESCRIPTION
========================================================================================================================================

========================================================================================================================================
#SURF
========================================================================================================================================

The SURF extractor constructors.

Note: Both SURF and MAKE-SURF are provided in this library. The first, to match OpenCV's naming 
conventions, the second, to adhere to Common Lisp naming conventions. Except for the name, they 
are the same function. I use the SURF function in the examples in this file because it will make 
them easier to compare with OpenCV examples you find online, thus making this library easier to 
learn.


C++: SURF::SURF()

LISP-CV: (SURF) => SURF

LISP-CV: (MAKE-SURF) => SURF

C++: SURF::SURF(double hessianThreshold, int nOctaves=4, int nOctaveLayers=2, bool extended=true, bool upright=false )

LISP-CV: (SURF (HESSIAN-THRESHOLD :DOUBLE) &OPTIONAL ((N-OCTAVES :INT) 4) ((EXTENDED :BOOLEAN) T) ((UPRIGHT :BOOLEAN) NIL)) => SURF

LISP-CV: (MAKE-SURF (HESSIAN-THRESHOLD :DOUBLE) &OPTIONAL ((N-OCTAVES :INT) 4) ((EXTENDED :BOOLEAN) T) ((UPRIGHT :BOOLEAN) NIL)) 
          => SURF


    Parameters:	

        HESSIAN-THRESHOLD - Threshold for hessian keypoint detector used in SURF.

        N-OCTAVES - Number of pyramid octaves the keypoint detector will use.

        N-OCTAVE-LAYERS - Number of octave layers within each octave.

        EXTENDED - Extended descriptor flag (t - use extended 128-element descriptors; nil - u-
                   se 64-element descriptors).

        UPRIGHT - Up-right or rotated features flag (t - do not compute orientation of features; 
                  nil - compute orientation).


Example:


(defun surf-example (filename-1 filename-2) 

  "Try using the box.png and the box-in-scene.png from
   the LISP-CV-MASTER/IMAGES directory to get a better 
   understanding of this example the first time you ru-
   n it."

  ;; Read in image in grayscale -> The object you want to track
  (let* ((img-1 (gc:imread filename-1 +load-image-grayscale+))
	 ;; The image the object is a part of
	 (img-2 (gc:imread filename-2 +load-image-grayscale+))
         (min-hessian 400d0) 
         (detector (gc:surf min-hessian))
	 (keypoints-1 (gc:vector-key-point))
	 (keypoints-2 (gc:vector-key-point))
         (extractor (gc:surf))
	 (descriptors-1 (gc:mat))
	 (descriptors-2 (gc:mat))
	 (matcher (gc:bf-matcher +norm-l2+))
	 (matches (gc:vector-dmatch))
	 (img-matches (gc:mat))
	 (window-name "Image Matches - SURF Example"))
    (if (empty (or img-1 img-2)) 
	(return-from surf-example 
	  (format t "Both images were not loaded")))
    (with-named-window (window-name +window-normal+)
      (move-window window-name 759 175)
      ;;-- Step 1: Detect the keypoints using SURF Detector
      (detect detector img-1 keypoints-1)
      (detect detector img-2 keypoints-2)
      ;;-- Step 2: Calculate descriptors (feature vectors)
      (compute :feature-2d extractor img-1 keypoints-1 descriptors-1)
      (compute :feature-2d extractor img-2 keypoints-2 descriptors-2)
      ;-- Step 3: Matching descriptor vectors with a brute force matcher
      (match matcher descriptors-1 descriptors-2 matches)
      ;;-- Draw matches
      (draw-matches img-1 keypoints-1 img-2 keypoints-2 matches img-matches)
      ;;-- Show detected matches
      (imshow window-name img-matches)
      (loop
	 (let ((c (wait-key 33)))
	   (when (= c 27)
	     (return)))))))


========================================================================================================================================
#CONTRIB - #COLORMAPS IN OPENCV
========================================================================================================================================

========================================================================================================================================
#APPLY-COLOR-MAP
========================================================================================================================================

Applies a GNU Octave/MATLAB equivalent colormap on a given image.

C++: void applyColorMap(InputArray src, OutputArray dst, int colormap)

LISP-CV: (APPLY-COLOR-MAP (SRC MAT) (DEST MAT) (COLORMAP :INT)) => :VOID

    Parameters:	

        SRC - The source image, grayscale or colored does not matter.

        DEST - The result is the colormapped source image. Note: In the OpenCV code Mat::create() 
               is called on DEST.

        COLORMAP - The colormap to apply, see the list of available colormaps below.


Currently the following GNU Octave/MATLAB equivalent colormaps are implemented:


(defanonenum 

  (+colormap-autumn+ 0)
  (+colormap-bone+ 1)
  (+colormap-jet+ 2)
  (+colormap-winter+ 3)
  (+colormap-rainbow+ 4)
  (+colormap-ocean+ 5)
  (+colormap-summer+ 6)
  (+colormap-spring+ 7)
  (+colormap-cool+ 8)
  (+colormap-hsv+ 9)
  (+colormap-pink+ 10)
  (+colormap-hot+ 11))


Description:

The human perception isn’t built for observing fine changes in grayscale images. Human eyes are more 
sensitive to observing changes between colors, so you often need to recolor your grayscale images to 
get a clue about them. OpenCV now comes with various colormaps to enhance the visualization in your 
computer vision application.

In Lisp-cv you only need (APPLY-COLOR-MAP) to apply a colormap on a given image. The following example 
code applies all 11 color map types to an image based on the position of a trackbar.


(defun apply-color-map-example (filename)

  (let ((window-name "APPLY-COLOR-MAP Example")
        (i (alloc :int 0)))
    (with-named-window (window-name +window-normal+)
      (move-window window-name 759 175)
      ;Create trackbar
      (create-trackbar "Color Map" window-name i 11)
      ;Load image as grayscale - Color is okay too
      (with-mat ((img0 (imread filename 0)))
	(if (empty img0) 
	    (return-from apply-color-map-example
	      (format t "Image not loaded")))
        (with-mat ((cm-img0 (mat)))
	  (loop
	     ;In a loop apply one of 11 color map 
	     ;types based on trackbar position
	     (apply-color-map img0 cm-img0 (@ i :int))
	     (imshow window-name cm-img0)
	     (let ((c (wait-key 33)))
	       (when (= c 27)
		 (return)))))))))



See OpenCv documentation for applyColorMap:

http://docs.opencv.org/trunk/modules/contrib/doc/facerec/colormaps.html?highlight=colormap#applycolormap

for the color scales for each of the available colormaps.

========================================================================================================================================
#SCALAR
========================================================================================================================================

SCALAR constructor.

Note: The functions SCALAR, SCALAR-ALL, MAKE-SCALAR and MAKE-SCALAR-ALL are provided in this library. 
The first two, are provided to match OpenCV's naming conventions, the second two, to adhere to Common 
Lisp naming conventions. Except for the difference in the names, SCALAR and SCALAR-ALL have the same 
functionality as MAKE-SCALAR and MAKE-SCALAR-ALL(respectively). I use the SCALAR and the SCALAR-ALL 
functions in the examples in this file because it makes them easier to compare with OpenCV examples 
you find online, thus making this library easier to learn.

C++:  Scalar::Scalar();

LISP-CV:  (SCALAR) => SCALAR

LISP-CV:  (MAKE-SCALAR) => SCALAR

C++: Scalar::Scalar(double v0, double v1, double v2, double v3)

LISP-CV:  (SCALAR ((V0 :DOUBLE) &OPTIONAL ((V1 :DOUBLE) 0) ((V2 :DOUBLE) 0) ((V3 :DOUBLE) 0))) => SCALAR

LISP-CV:  (MAKE-SCALAR ((V0 :DOUBLE) &OPTIONAL ((V1 :DOUBLE) 0) ((V2 :DOUBLE) 0) ((V3 :DOUBLE) 0))) => SCALAR

C++: Scalar::Scalar::all(double v0)

LISP-CV:  (SCALAR-ALL (V0 :DOUBLE)) => SCALAR

LISP-CV:  (MAKE-SCALAR-ALL (V0 :DOUBLE)) => SCALAR


    Parameters:	

        V0 - First scalar element or value of all scalar elements if evaluating (SCALAR-ALL V0).

        V1 - Second scalar element.
       
        V2 - Third scalar element.
    
        V3 - Fourth scalar element.



The functions SCALAR and MAKE-SCALAR are SCALAR constructors. They return a pointer to an up to 4 
element scalar. Both the functions SCALAR-ALL and MAKE-SCALAR-ALL return a pointer to a 4 element 
scalar with all elements having the same value. 

Note: Integer values entered into this function will be coerced to double float, but using double 
float values specifically as input will make this function 1/3 faster.


(defun scalar-example ()

  (with-scalar ((un-init-scalar (scalar))
                (scalar-1 (scalar 0 255 0))
		(scalar-2 (scalar-all 255)))
    (format t "~%UN-INIT-SCALAR = ~a~%~%" un-init-scalar)
    (format t "~%SCALAR-1 = (~a, ~a, ~a)~%~%" 
	    (@ scalar-1 :double 0)
	    (@ scalar-1 :double 1)
	    (@ scalar-1 :double 2))
    (format t "~%SCALAR-2 = (~a, ~a, ~a, ~a)~%~%" 
	    (@ scalar-2 :double 0)
	    (@ scalar-2 :double 1)
	    (@ scalar-2 :double 2)
	    (@ scalar-2 :double 3))))

========================================================================================================================================
#MAT-TYPE
========================================================================================================================================

Returns the type of a matrix element.

Note: The name MAT-TYPE is used in the documentation to refer to the binding for the "type" member 
of the OpenCV Mat class because it is more descriptive and it is easier to search for in this file. 
The TYPE* method may also be used to call this binding.


C++: int Mat::type() const

LISP-CV: (TYPE* (SELF MAT))

LISP-CV: (SETF (TYPE* (SELF MAT)) (VAL :INT))

LISP-CV: (MAT-TYPE (SELF MAT))

LISP-CV: (SETF (MAT-TYPE (SELF MAT)) (VAL :INT))


    Parameters:	

        SELF - A Mat object.

        VAL - The new matrix type.


The method returns a matrix element type. This is an identifier compatible with OpenCV's CvMat type
system, like CV_16SC3(+16SC3+ in LISP-CV) or 16-bit signed 3-channel array, and so on.


(defun mat-type-example ()

  "This function uses the TYPE* method 
   to find the type of two matrices."

  (with-mat ((mat-one (mat-zeros 1 2 +32f+))
	     (mat-two (gc:mat-zeros 2 4 +64f+)))
    (format t "~%MAT-ONE type is ~a(+32f+). It is a single float matrix.~%" 
	    (type* mat-one))
    (format t "~%MAT-TWO type is ~a(+64f+). It is a double float matrix.~%~%" 
	    (type* mat-two))))

========================================================================================================================================
#CIRCLE
========================================================================================================================================

Draws a circle.

C++: void circle(Mat& img, Point center, int radius, const Scalar& color, int thickness=1, int lineType=8, int shift=0)

LISP-CV: (CIRCLE (IMG MAT) (CENTER POINT) (RADIUS :INT) (COLOR SCALAR) &OPTIONAL ((THICKNESS :INT) 1) 
                ((LINE-TYPE :INT) 8) ((SHIFT :INT) 0)) => :VOID

    Parameters:	

        IMG - Image where the circle is drawn.

        CENTER - Center of the circle.

        RADIUS - Radius of the circle.

        COLOR - Circle color.

        THICKNESS - Thickness of the circle outline, if positive. Negative thickness means that a 
                    Filled circle is to be drawn.

        LINE-TYPE - Type of the circle boundary. See the (LINE) description.

        SHIFT - Number of fractional bits in the coordinates of the center and in the radius value.


The function circle draws a simple or filled circle with a given center and radius.


Example:

(defparameter x 40)
(defparameter y 40)
(defparameter point 0)
(defparameter the-right-wall 600)
(defparameter the-left-wall 40)
(defparameter the-ceiling 40)
(defparameter the-floor 440)
(defparameter rate 10)
(defparameter right-wall-switch 0)
(defparameter left-wall-switch 0)
(defparameter ceiling-switch 0)
(defparameter floor-switch 0)

(defun report ()
  (format t "x = ~a~%" x)
  (format t "y = ~a~%" y)
  (format t "right-wall-switch = ~a~%" right-wall-switch)
  (format t "left-wall-switch = ~a~%" left-wall-switch)
  (format t "ceiling-switch = ~a~%" ceiling-switch)
  (format t "floor-switch = ~a~%" floor-switch))


(defun circle-example (&optional (cam *camera-index*))

  "This example uses the function CIRCLE to create a little 
   red ball. Then it uses a bit of logic to make the ball b-
   ounce around the room."

  (with-captured-camera (cap cam :width 640 :height 480)
    (let* ((window-name "CICRLE Example"))
      (if (not (is-opened cap)) 
	  (return-from circle-example 
	    (format t "Cannot open the video camera")))
      (with-named-window (window-name +window-normal+)
	(move-window window-name 759 175)
	(with-mat ((frame (mat)))
	  (with-scalar ((color (scalar 0 0 255)))
	    (loop
	       (read cap frame)
	       (with-point ((point (point x y)))
		 (circle frame point 40 color +filled+ +aa+ 0)
		 (imshow window-name frame)
		 (if (= x the-right-wall) 
		     (progn 
		       (format t "right wall has been touched~%") 
		       (setf right-wall-switch 1)))    
		 (if (= x the-left-wall) 
		     (progn
		       (format t "left wall has been touched~%") 
		       (setf left-wall-switch 1)))	
		 (if (= y the-floor) 
		     (progn 
		       (format t "floor has been touched~%") 
		       (setf floor-switch 1))) 
		 (if (= y the-ceiling) 
		     (progn 
		       (format t"ceiling has been touched~%") 
		       (setf ceiling-switch 1))) 
		 (if (and (< x the-right-wall) (= right-wall-switch 0)) (incf x rate) (decf x rate))
		 (if (and (< y the-floor) (= floor-switch 0)) (incf y rate) (decf y rate))
		 (if (< x (+ 40 rate)) (setf right-wall-switch 0))
		 (if (< y (+ 40 rate)) (setf floor-switch 0))
		 (report))
	       (let ((c (wait-key 33)))
		 (when (= c 27)
		   (return))))))))))

========================================================================================================================================
#MAT-ONES
========================================================================================================================================

Returns an array of all 1’s of the specified size and type.

C++: static MatExpr Mat::ones(int rows, int cols, int type)

LISP-CV: (MAT-ONES (ROWS :INT) (COLS :INT) (TYPE :INT)) => MAT


    Parameters:	

        ROWS - Number of rows.

        COLS - Number of columns.

        TYPE - Created matrix type.


The method returns a Matlab-style 1’s array initializer, similarly to MAT-ZEROS. Note that using this
method you can initialize an array with an arbitrary value, using the following Matlab idiom:

(GC:SCALE (GC:<< (GC:MAT-ONES 100 100 +8U+)) 3D0)

The above operation does not form a 100x100 matrix of 1’s and then multiply it by 3. Instead, it just 
remembers the scale factor (3 in this case) and uses it when actually invoking the matrix initializer.


(defun mat-ones-example ()

  "In this example the function MAT-ONES 
   is used to create a matrix MAT filled 
   with ones. MAT is then shown in a win-
   dow."

  (let* ((mat (mat-ones 4 4 +8u+))
	 (window-name "MAT - MAT-ONES Example"))
    (named-window window-name +window-normal+)
    (move-window window-name 759 175)
    (imshow window-name mat)
    (loop while (not (= (wait-key 0) 27)))
    (destroy-window window-name)))

========================================================================================================================================         
DIAG
========================================================================================================================================

Extracts a diagonal from a matrix, or creates a diagonal matrix.

C++: Mat Mat::diag(int d=0 ) const

LISP-CV: (MAT-DIAG (SELF MAT) (D :INT)) => MAT

C++: static Mat Mat::diag(const Mat& d)


    Parameters:	

        D -

        Single-column matrix that forms a diagonal matrix or index of the diagonal, with the follow-
        ing values:

            (= D 0) is the main diagonal.

            (> D 0) is a diagonal from the lower half. For example, (= D 1) means the diagonal is s-
                    et immediately below the main one.

            (< D 0) is a diagonal from the upper half. For example, (= D -1) means the diagonal is 
                    set immediately above the main one.


The method makes a new header for the specified matrix diagonal. The new matrix is represented as a
single-column matrix. Similarly to (ROW) and (COL) , this is an O(1) operation.


(defun diag-example ()

  "In this exmple, the main diagonal of the 
   matrix MAT is retrieved with the functio-
   n DIAG and then it it is printed. The fu-
   nction DIAG makes a new header for the s-
   pecified matrix diagonal. The new matrix 
   is represented as a single-column matrix."

  (let* ((data (alloc :int '(1 2 3 4 5 6 7 8 9)))
	 (mat (mat 3 3 +32s+ data))
	 (diag (diag mat 0)))
    (dotimes (i 3)
      (format t "~a" (@ :int diag i 0))
      (princ #\Newline))
    (free data)))

========================================================================================================================================
#LISP-CV - MACROS AND EXTRA FUNCTIONS:
========================================================================================================================================

========================================================================================================================================
#$ 
========================================================================================================================================

Macro for the CL::TIME macro.

Time how long a function takes to complete n iterations.

LISP-CV: ($ FORM &optional (COUNT-FORM 1000000) ) => RESULT


    Parameters:	

        FORM - From the Common Lisp HyperSpec:
               1. any object meant to be evaluated. 2. a symbol, a compound form, or a self-evaluat-
               ing object. 3. (for an operator, as in ``<<operator>> form'') a compound form having 
               that operator as its first element. ``A quote form is a constant form.''

        COUNT-FORM - The number of iterations of FORM you would like to calculate.


This is useful, if you have just written a function and would like to time the seconds it takes to 
complete n iterations, because all you have to do is go back one in the REPL history and add a $ and 


Example:

(defun $-example ()
  ($ (sleep 1) 5))


CV: ($-example)

Evaluation took:
  5.0000 seconds of real time
  0.004951 seconds of total run time (0.003775 user, 0.001176 system)
  0.10% CPU
  12,501,013,695 processor cycles
  33,008 bytes consed
  
NIL
========================================================================================================================================
#@ 
========================================================================================================================================

CFFI::MEM-AREF macro and overloaded binding for the std::vector::at and cv::Mat::at members. 


These versions are light wrappers over CFFI-MEM-AREF:


CFFI: mem-aref ptr type &optional (index 0)

CFFI: (setf (mem-aref ptr type &optional (index 0)) new-value) 

LISP-CV: (@ PTR TYPE &OPTIONAL ((I :INT) 0)) => RESULT

LISP-CV: (SETF (@ PTR TYPE &OPTIONAL ((I :INT) 0)) NEW-VALUE) => RESULT


Matrix accessor versions:


C++: template<typename T> T& Mat::at(int i) const

C++: template<typename T> T& Mat::at(int i, int j)

C++: template<typename T> T& Mat::at(int i, int j, int k)


LISP-CV: (@ (TYPE KEYWORD) (SELF MAT) &OPTIONAL ((I :INT) 0)) => <type-name>

LISP-CV: (@ (TYPE KEYWORD) (SELF MAT) &OPTIONAL ((I :INT) 0) (J :INT)) => <type-name>

LISP-CV: (@ (TYPE KEYWORD) (SELF MAT) &OPTIONAL ((I :INT) 0) (J :INT) (K :INT)) => <type-name>


LISP-CV: (SETF (@ (TYPE KEYWORD) (SELF MAT) &OPTIONAL ((I :INT) 0)) NEW-VALUE) => <type-name>

LISP-CV: (SETF (@ (TYPE KEYWORD) (SELF MAT) &OPTIONAL ((I :INT) 0) (J :INT)) NEW-VALUE) => <type-name>

LISP-CV: (SETF (@ (TYPE KEYWORD) (SELF MAT) &OPTIONAL ((I :INT) 0) (J :INT) (K :INT)) NEW-VALUE) => <type-name>


Vector accessor versions:


reference at (size_type n)

LISP-CV: (@ (SELF VECTOR-<type-name>) &OPTIONAL ((IDX :INT) 0)) => OBJECT or ELEMENT(<type-name>)

LISP-CV: (SETF (@ (SELF VECTOR-<type-name>) &OPTIONAL ((IDX :INT) 0)) NEW-VALUE) => OBJECT or ELEMENT(<type-name>)


    Parameters:	

        SELF - OpenCV matrix or vector.

        PTR - Any LISP-CV class object or pointer.

        TYPE - A foreign-type, See below.

        NEW-VALUE - A Lisp value compatible with TYPE. 

        I - Index along the dimension 0

        J - Index along the dimension 1

        K - Index along the dimension 2

        IDX - Index of an element(object or number) inside the vector


This function is a macro for CFFI's MEM-AREF. Also it dispatches methods binding the OpenCV Mat::at 
and the STD library vector::at members. It can be used to retrieve any object inside a vector or matrix 
with minimal typing. If you'd like to retrieve an object(or element for number based vectors or matrices) 
at the 0th index, the 0 need not be supplied.


The typenames associated with @(as a MEM-AREF macro) include:

:char     :int16    :short    :uint32   :string
:double   :int32    :uchar    :uint64   :pointer
:float    :int64    :uint     :ullong
:int      :llong    :uint8    :ulong
:int8     :long     :uint16   :ushort

See this link in the CFFI doc. for longer versions of above types:

http://common-lisp.net/project/cffi/manual/cffi-manual.html#Built_002dIn-Types


Search <hashtag>MAT-AT in this file for typenames associated with @ as a matrix accessor:


Example for MEM-AREF functionality:


LCV> (DEFPARAMETER A (C-STRING "12545"))

A

LCV> A

#<STD-STRING {1003C23F63}>

LCV> (@ A :STRING)

"12545"

Search <hashtag>MAT-AT in this file for an example of accessing MAT elements.

Search <hashtag>VEC-AT in this file for an example of accessing VECTOR-<type-name> elements.

CV> (DEFPARAMETER VEC (VECTOR-DOUBLE '(1D0 2D0 3D0)))

VEC

CV> (@ VEC)

1.0d0

CV> (@ VEC 0)

1.0d0

CV> (@ VEC 1)

2.0d0

CV> (@ VEC 2)

3.0d0


CV> (DEFPARAMETER VEC (VECTOR-MAT (LIST (MAT 3 3 +8U+ 1) (MAT 3 3 +8U+ 2) (MAT 3 3 +8U+ 3))))

VEC

CV> (PRINT-MAT (@ VEC))

#2M((1 1 1)
    (1 1 1)
    (1 1 1))

CV> (PRINT-MAT (@ VEC 0))

#2M((1 1 1)
    (1 1 1)
    (1 1 1))

CV> (PRINT-MAT (@ VEC 1))

#2M((2 2 2)
    (2 2 2)
    (2 2 2))

CV> (PRINT-MAT (@ VEC 2))

#2M((3 3 3)
    (3 3 3)
    (3 3 3))

========================================================================================================================================
#ALLOC 
========================================================================================================================================

Macro for CFFI::FOREIGN-ALLOC.

CFFI: - foreign-alloc type &key initial-element initial-contents (count 1) null-terminated-p ⇒ pointer

LISP-CV: (ALLOC TYPE VALUE) => :POINTER


    Parameters:	

        TYPE - A CFFI type

        VALUE - A number or a sequence - stand-in for the INITIAL-ELEMENT 
                and INITIAL-CONTENTS keyword parameter of FOREIGN-ALLOC.

Example:

Note: The T: prefix to ALLOC signifies automatic GC is enabled for this function. If you use with-* 
macros(WITH-OBJECT) or manual MM(DEL) to GC this function, you'll get a slightly better performance 
out of it.

CV> (DEFPARAMETER A (T:ALLOC :DOUBLE 8.0D0))

A

CV> (@ A :DOUBLE)

8.0d0

CV> (DEFPARAMETER B (T:ALLOC :INT '(1 2 3)))

B

CV> (@ B :INT)

1

CV> (@ B :INT 1)

2

CV> (@ B :INT 2)

3

========================================================================================================================================
#CONTINUABLE
========================================================================================================================================

Catches any error and gives the option to ignore it and continue.

LISP-CV: (CONTINUABLE &BODY BODY)


    Parameters: 
          
         body - Give all expressions in the macro


Macro included for reference:

(defmacro continuable (&body body)
  `(restart-case
       (progn ,@body)
     (continue () :report "Continue"  )))


Example:


(defparameter filename "")

(defun continuable-example ()

  "You can update this program as it runs! 

   First, run M-x SLIME-COMPILE-AND-LOAD-FILE.

   Then, evaluate (LIVE-CODE-EDITING-EXAMPLE). 

   Now, Switch to the REPL, even though it is 
   not active.

   Next, evaluate (SETF FILENAME <NEW VALUE>) 
   to update the FILENAME parameter which will 
   update the image being shown in the window. 
   
   Note: After evaluating SETF once you'll get 
   the REPL back."

  (format t "Enter a filename:~%~%")
  (let ((filename (read))
        (window-name "CONTINUABLE-EXAMPLE")
        (image 0)
	(x 0))
    (with-named-window (window-name +window-normal+)
      (move-window window-name 759 175)
      (loop
	 (with-mat ((image (imread filename 1)))
	   (update-swank)
	   (continuable (imshow window-name image)))
	 (let ((c (wait-key 33)))
	   (when (= c 27)
	     (return)))))))


========================================================================================================================================
#DEL andd DEL-*
========================================================================================================================================

Deletes allocated memory


LISP-CV: (DEL (SELF :POINTER)) => :VOID

LISP-CV: (DEL-ANN-MLP (SELF ANN-MLP)) => :VOID

LISP-CV: (DEL-ANN-MLP-TRAIN-PARAMS (SELF ANN-MLP-TRAIN-PARAMS)) => :VOID

LISP-CV: (DEL-BF-MATCHER (SELF BF-MATCHER)) => :VOID

LISP-CV: (DEL-BRISK (SELF BRISK)) => :VOID

LISP-CV: (DEL-CASCADE-CLASSIFIER (SELF CASCADE-CLASSIFIER)) => :VOID

LISP-CV: (DEL-D-TREE (SELF D-TREE)) => :VOID

LISP-CV: (DEL-D-TREE-PARAMS (SELF D-TREE-PARAMS)) => :VOID

LISP-CV: (DEL-DMATCH (SELF DMATCH)) => :VOID

LISP-CV: (DEL-HOG-DESCRIPTOR (SELF HOG-DESCRIPTOR)) => :VOID

LISP-CV: (DEL-K-NEAREST (SELF K-NEAREST)) => :VOID

LISP-CV: (DEL-KEY-POINT (SELF KEY-POINT)) => :VOID

LISP-CV: (DEL-MAT (SELF MAT)) => :VOID

LISP-CV: (DEL-MAT-EXPR (SELF MAT-EXPR)) => :VOID

LISP-CV: (DEL-NORMAL-BAYES-CLASSIFIER (SELF NORMAL-BAYES-CLASSIFIER)) => :VOID

LISP-CV: (DEL-POINT (SELF POINT)) => :VOID

LISP-CV: (DEL-POINT-2D (SELF POINT-2D)) => :VOID

LISP-CV: (DEL-POINT-2F (SELF POINT-2F)) => :VOID

LISP-CV: (DEL-POINT-3D (SELF POINT-3D)) => :VOID

LISP-CV: (DEL-POINT-3F (SELF POINT-3F)) => :VOID

LISP-CV: (DEL-POINT-3I (SELF POINT-3I)) => :VOID

LISP-CV: (DEL-RANGE (SELF RANGE)) => :VOID

LISP-CV: (DEL-RECT (SELF RECT)) => :VOID

LISP-CV: (DEL-RNG (SELF RNG)) => :VOID

LISP-CV: (DEL-ROT-RECT (SELF ROT-RECT)) => :VOID

LISP-CV: (DEL-SCALAR (SELF SCALAR)) => :VOID

LISP-CV: (DEL-SIZE (SELF SIZE)) => :VOID

LISP-CV: (DEL-SIZE-2F (SELF SIZE-2F)) => :VOID

LISP-CV: (DEL-STD-STRING (SELF :STRING)) => :VOID

LISP-CV: (DEL-SURF (SELF SURF)) => :VOID

LISP-CV: (DEL-TERM-CRIT (SELF TERM-CRITERIA)) => :VOID

LISP-CV: (DEL-VEC-2B (SELF VEC-2B)) => :VOID

LISP-CV: (DEL-VEC-3B (SELF VEC-3B)) => :VOID

LISP-CV: (DEL-VEC-4B (SELF VEC-4B)) => :VOID

LISP-CV: (DEL-VEC-2D (SELF VEC-2D)) => :VOID

LISP-CV: (DEL-VEC-3D (SELF VEC-3D)) => :VOID

LISP-CV: (DEL-VEC-4D (SELF VEC-4D)) => :VOID

LISP-CV: (DEL-VEC-6D (SELF VEC-6D)) => :VOID

LISP-CV: (DEL-VEC-2F (SELF VEC-2F)) => :VOID

LISP-CV: (DEL-VEC-3F (SELF VEC-3F)) => :VOID

LISP-CV: (DEL-VEC-4F (SELF VEC-4F)) => :VOID

LISP-CV: (DEL-VEC-2I (SELF VEC-2I)) => :VOID

LISP-CV: (DEL-VEC-3I (SELF VEC-3I)) => :VOID

LISP-CV: (DEL-VEC-4I (SELF VEC-4I)) => :VOID

LISP-CV: (DEL-VEC-6I (SELF VEC-6I)) => :VOID

LISP-CV: (DEL-VEC-8I (SELF VEC-8I)) => :VOID

LISP-CV: (DEL-VEC-2S (SELF VEC-2S)) => :VOID

LISP-CV: (DEL-VEC-3S (SELF VEC-3S)) => :VOID

LISP-CV: (DEL-VEC-4S (SELF VEC-4S)) => :VOID

LISP-CV: (DEL-VEC-2W (SELF VEC-2w)) => :VOID

LISP-CV: (DEL-VEC-3W (SELF VEC-3W)) => :VOID

LISP-CV: (DEL-VEC-4W (SELF VEC-4W)) => :VOID

LISP-CV: (DEL-VECTOR-CHAR (SELF VECTOR-CHAR)) => :VOID

LISP-CV: (DEL-VECTOR-DOUBLE (SELF VECTOR-DOUBLE)) => :VOID

LISP-CV: (DEL-VECTOR-DMATCH (SELF VECTOR-DMATCH)) => :VOID

LISP-CV: (DEL-VECTOR-FLOAT (SELF VECTOR-FLOAT)) => :VOID

LISP-CV: (DEL-VECTOR-INT (SELF VECTOR-INT)) => :VOID

LISP-CV: (DEL-VECTOR-KEY-POINT (SELF VECTOR-KEY-POINT)) => :VOID

LISP-CV: (DEL-VECTOR-MAT (SELF VECTOR-MAT)) => :VOID

LISP-CV: (DEL-VECTOR-POINT (SELF VECTOR-POINT)) => :VOID

LISP-CV: (DEL-VECTOR-POINT-2F (SELF VECTOR-POINT-2F)) => :VOID

LISP-CV: (DEL-VECTOR-RECT (SELF VECTOR-RECT)) => :VOID

LISP-CV: (DEL-VECTOR-UCHAR (SELF VECTOR-UCHAR)) => :VOID

LISP-CV: (DEL-VECTOR-VEC-2B (SELF VECTOR-VEC-2B)) => :VOID

LISP-CV: (DEL-VECTOR-VEC-3B (SELF VECTOR-VEC-3B)) => :VOID

LISP-CV: (DEL-VECTOR-VEC-4B (SELF VECTOR-VEC-4B)) => :VOID

LISP-CV: (DEL-VECTOR-VEC-2D (SELF VECTOR-VEC-2D)) => :VOID

LISP-CV: (DEL-VECTOR-VEC-3D (SELF VECTOR-VEC-3D)) => :VOID

LISP-CV: (DEL-VECTOR-VEC-4D (SELF VECTOR-VEC-4D)) => :VOID

LISP-CV: (DEL-VECTOR-VEC-6D (SELF VECTOR-VEC-6D)) => :VOID

LISP-CV: (DEL-VECTOR-VEC-2F (SELF VECTOR-VEC-2F)) => :VOID

LISP-CV: (DEL-VECTOR-VEC-3F (SELF VECTOR-VEC-3F)) => :VOID

LISP-CV: (DEL-VECTOR-VEC-4F (SELF VECTOR-VEC-4F)) => :VOID

LISP-CV: (DEL-VECTOR-VEC-6F (SELF VECTOR-VEC-6F)) => :VOID

LISP-CV: (DEL-VECTOR-VEC-2I (SELF VECTOR-VEC-2I)) => :VOID

LISP-CV: (DEL-VECTOR-VEC-3I (SELF VECTOR-VEC-3I)) => :VOID

LISP-CV: (DEL-VECTOR-VEC-4I (SELF VECTOR-VEC-4I)) => :VOID

LISP-CV: (DEL-VECTOR-VEC-6I (SELF VECTOR-VEC-6I)) => :VOID

LISP-CV: (DEL-VECTOR-VEC-8I (SELF VECTOR-VEC-8I)) => :VOID

LISP-CV: (DEL-VECTOR-VEC-2S (SELF VECTOR-VEC-2S)) => :VOID

LISP-CV: (DEL-VECTOR-VEC-3S (SELF VECTOR-VEC-3S)) => :VOID

LISP-CV: (DEL-VECTOR-VEC-4S (SELF VECTOR-VEC-4S)) => :VOID

LISP-CV: (DEL-VECTOR-VEC-2W (SELF VECTOR-VEC-2W)) => :VOID

LISP-CV: (DEL-VECTOR-VEC-3W (SELF VECTOR-VEC-3W)) => :VOID

LISP-CV: (DEL-VECTOR-VEC-4W (SELF VECTOR-VEC-4W)) => :VOID

LISP-CV: (DEL-VIDEO-CAPTURE (SELF VIDEO-CAPTURE)) => :VOID

LISP-CV: (DEL-VIDEO-WRITER (SELF VIDEO-WRITER)) => :VOID


  Parameters:	

        SELF - A pointer to a <type> object


Some of the OpenCV C bindings for its C++ interface that this library binds to, allocate memory for
their return value, with a new operator. The return value of the C functions are a pointer to an OpenCv
class specified by the return value. e.g. Mat* (represented in LISP-CV as MAT) is a pointer to the OpenCV 
Mat class. A call to the C++ delete operator must be made for every call to new to avoid a memory leak. 
The DEL-* functions are wrappers for the C++ delete operator and pass the type of * to the delete operator 
when the DEL-* function is called. The DEL-* function types are below.


Note: Each DEL-* function has a companion WITH-* macro that calls the associated DEL-* function, when
the * goes out of scope, automatically. See <lisp-cv-source directory>/with-macros.lisp for the associated 
WITH-* macro.

The function DEL deletes anything(may not be safe on all implementations). Every other DEL-* function 
deletes a * object. 


Example:


CV> (DEFPARAMETER A (POINT 1 2)) ;A POINT is created

A

CV> (X A) ;The x coordinate of A is retrieved

1

CV> (Y A) ;The y coordinate of A is retrieved

2

CV> (DEL-POINT A) ;A is deleted with DEL-POINT

; No value


CV> (X A) ;The memory has been deallocated

0

CV> (Y A)

0



FREE (Macro for CFFI::FOREIGN-FREE)


CFFI: - foreign-free ptr ⇒ undefined

LISP-CV: (FREE PTR) => undefined


    Parameters:	

        PTR - A foreign pointer.


Example:

CV> (DEFPARAMETER A (ALLOC :INT 55))

A

CV> (MEM-AREF A :INT)

55

CV> (FREE A)

NIL

CV> (MEM-AREF A :INT)

0

========================================================================================================================================
#UPDATE-SWANK
========================================================================================================================================

Grabs SWANK connection and tells it to handle requests. 

LISP-CV: (UPDATE-SWANK)


Call this every loop in the main loop of your program.


Function included for reference:


(defun update-swank ()
  "Grabs SWANK connections and tells it to handle requests. 
   Call this every loop in the main loop of your program"
  (continuable
    (let ((connection (or swank::*emacs-connection*
			  (swank::default-connection))))
      (when connection
	(swank::handle-requests connection t)))))


Example:

(defparameter n (/ 1 1))


(defun update-swank-example (filename)

  "You can update this program as it runs! Just run 
   M-x SLIME-COMPILE-AND-LOAD-FILE then at the REPL 
   run (LIVE-CODE-EDITING-EXAMPLE FILENAME). Switch 
   to the REPL, even though its not active, you can 
   use (SETF N (/ 1 <NEW VALUE>)) to update N which 
   will change the strobe effect. After you running 
   SETF once you will get the REPL back

   Note: If the strobe effect does not change when 
   you update N, try using a smaller picture."

  (let ((window-name "UPDATE-SWANK-EXAMPLE")
	(x 0))
    (with-named-window (window-name +window-normal+)
      (move-window window-name 759 175)
      (loop
	 (with-mat ((image (imread filename 1)))
	   (incf x 1)
	   (with-scalar ((value (scalar 0 0 0)))
	     (if (= x 2) (progn (assign image value) (decf x 2))))
	   (update-swank)
	   (continuable (imshow window-name image)))
	 (with-mat ((image (imread filename 1)))
	   (sleep n)
	   (let ((c (wait-key 33)))
	     (when (= c 27)
	       (return))))))))

========================================================================================================================================
#VECTOR-<type-name>
========================================================================================================================================

Bindings for the C++ VECTOR class.


C++: template < class T, class Alloc = allocator<T> > class vector; 

C++: void std::vector::push_back (const value_type& val);

C++: reference std::vector::at (size_type n);


The following low-level functions have been externalized for use
because the names are less cryptic for others reading your code.

LISP-CV: (MAKE-VECTOR-<type-name>) => VECTOR-<type-name>

LISP-CV: (C-ARR-TO-VEC-<type-name> (A :POINTER)) => VECTOR-<type-name>

LISP-CV: (SEQ-TO-VEC-<type-name> (SEQ SEQUENCE)) => VECTOR-<type-name>

LISP-CV: (VEC-<type-name>-TO-C-ARR (VEC VECTOR-<type-name>)) => :POINTER

LISP-CV: (VEC-<type-name>-LENGTH (VEC VECTOR-<type-name>)) => :INT

LISP-CV: (VEC-<type-name>-TO-LISP-LIST (VEC VECTOR-<type-name>)) => LIST

LISP-CV: (VEC-<type-name>-TO-LISP-VEC (VEC VECTOR-<type-name>)) => VECTOR

LISP-CV: (VEC-<type-name>-PUSH-BACK (VEC VECTOR-<type-name>)) => OBJECT(<type-name>) 

LISP-CV: (VEC-<type-name>-AT (VEC VECTOR-<type-name>) (IDX :INT)) => OBJECT or ELEMENT(<type-name>)


Main interface(high-level) to the C++ vector bindings.
(See examples for usage).

LISP-CV: (VECTOR-<type-name>) => VECTOR-<type-name>

LISP-CV: (PUSH-BACK (VEC VECTOR-<type-name>)) => OBJECT(<type-name>) 

LISP-CV: (@ (SELF VECTOR-<type-name>) &OPTIONAL ((IDX :INT) 0)) => OBJECT or ELEMENT(<type-name>)

LISP-CV: (SETF (@ (SELF VECTOR-<type-name>) &OPTIONAL ((IDX :INT) 0)) NEW-VALUE) => OBJECT or ELEMENT(<type-name>)

(Note: Search <hashtag>@, inside this file, for more information on the @ macro.)


Descriptions of the functions:

Constructs uninitialized object.
(MAKE-VECTOR-<type-name>)

Converts foreign (C)array to C++ vector.
(C-ARR-TO-VEC-<type-name> (A :POINTER))

Converts Lisp SEQUENCE to C++ vector.
(SEQ-TO-VEC-<type-name> (SEQ SEQUENCE))

Converts C++ vector to foreign (C)array.
(VEC-<type-name>-TO-C-ARR) 

Retrieves the length of the vector.
(VEC-<type-name>-LENGTH

Converts C++ vector to Lisp LIST.
(VEC-<type-name>-TO-LISP-LIST

Converts C++ vector to Lisp VEC.
(VEC-<type-name>-TO-LISP-VEC (VEC VECTOR-<type-name>))

Adds a new element at the end of C++ vector.
(VEC-<type-name>-PUSH-BACK (VEC VECTOR-<type-name>))

Shortened version of the above function.
(PUSH-BACK (VEC VECTOR-<type-name>))

Returns the element at position n in the vector...
(VEC-<type-name>-AT (VEC VECTOR-<type-name>) (IDX :INT))

...this function is setf-able:
(SETF (VEC-<type-name>-AT (VEC VECTOR-<type-name>) (IDX :INT)) NEW-VALUE)

Shortened versions of above function(non setf-able).
(@ (VEC VECTOR-<type-name>) (IDX :INT))

See examples below...
(VECTOR-<type-name>) => VECTOR-<type-name>


    Parameters:	

       VEC - A C++ vector of type <type-name>. See below.

       IDX - Index of element at position n in the vector.

       SEQ - A Lisp sequence(list or vector).

       A - A foreign pointer. Can be created with the CFFI::FOREIGN-ALLOC macro ALLOC.
                                                   (Search <hashtag>ALLOC in this file)

The bindings for the C++ vector class, so far, are:

LISP-CV  <===>  C++              
===========================     
VECTOR-CHAR <===> vector<char>
===============================      
VECTOR-DMATCH <===> vector<DMatch> 
===============================       
VECTOR-DOUBLE <===> vector<double> 
=============================      
VECTOR-FLOAT <===> vector<float>
=============================    
VECTOR-INT <===>  vector<int>
====================================      
VECTOR-KEY-POINT <===> vector<KeyPoint>
====================================     
VECTOR-POINT <===> vector<Point>
==================================      
VECTOR-POINT-2F <===> vector<Point2f>
=================================  
VECTOR-RECT <===> vector<Rect>
=============================     
VECTOR-UCHAR <===> vector<uchar>
==============================    
VECTOR-VEC-2D <===> vector<Vec2d>
==============================
VECTOR-VEC-3D <===> vector<Vec3d>
==============================
VECTOR-VEC-4D <===> vector<Vec4d>
==============================
VECTOR-VEC-6D <===> vector<Vec6d>
==============================
VECTOR-VEC-2F <===> vector<Vec2f>
==============================
VECTOR-VEC-3F <===> vector<Vec3f>
==============================
VECTOR-VEC-4F <===> vector<Vec4f>
==============================
VECTOR-VEC-6F <===> vector<Vec6f>
==============================
VECTOR-VEC-2I <===> vector<Vec2i>
==============================
VECTOR-VEC-3I <===> vector<Vec3i>
==============================
VECTOR-VEC-4I <===> vector<Vec4i>
==============================
VECTOR-VEC-6I <===> vector<Vec6i>
==============================
VECTOR-VEC-8I <===> vector<Vec8i>
==============================

Examples:

Vectors with numbers as elements include, VECTOR-CHAR, VECTOR-DOUBLE, VECTOR-FLOAT, VECTOR-INT and 
VECTOR-UCHAR. The preceding vectors operate as follows:(Using VECTOR-FLOAT as the example of the 5.) 

The idea behind the vector functions in Lisp-CV is you use them primarily to pass data to and from the 
underlying OpenCV code only. The reason being, due to the nature of wrapping the C++ vector class in 
Lisp, some of the C++ speed is lost. Since Lisp vectors are extremely fast, the best workaround is to 
use Lisp's own vector and list processing functions to fill in the gaps. The functions are designed so 
first you would create, for instance, a Lisp vector or a list of floats e.g.


CV> (DEFPARAMETER A '(1F0 2F0 3F0))

A

CV> A

(1.0 2.0 3.0)


CV> (DEFPARAMETER A (LIST 1F0 2F0 3F0))

A

CV> A

(1.0 2.0 3.0)


CV> (DEFPARAMETER A (VECTOR 1F0 2F0 3F0))

A

CV> A

#(1.0 2.0 3.0)


Next, and this is where it gets fun, you can use any of the myriad of functions in Lisp designed 
to operate on lists and vectors and then pass the results to the underlying OpenCV code by way of 
the Lisp-CV vector functions. Since Lisp's main strength is list processing, hence it's name, this 
is a great feature and adds a lot of power to OpenCV and a lot of speed to the Lisp-CV bindings. 

Now, once you have created your vector as above and performed whatever operations you needed to on 
it, you can convert that vector to a C++ vector as so:


CV> (DEFPARAMETER B (VECTOR-FLOAT A))

B

CV> B


#<STD-VECTOR-FLOAT {1006BA6983}> <--- A CLOS object, STD-VECTOR-FLOAT type, pointing to a vector<float>



The VECTOR-* functions are basically for convenience and are a little slow(between .250 and 2 seconds 
depending on the type of operation they are used for). If you would like to pass an uninitialized VECTOR-* 
to a function that will use it to store data, it is faster to use the MAKE-VECTOR-* functions e.g.

CV> (DEFPARAMETER A (MAKE-VECTOR-FLOAT))


That's all there is to it. Now a vector<type> can be passed to any Lisp-CV binding for OpenCV or C++ that 
will accept it.


Now, if an OpenCV or C++ binding in this library outputs a STD-VECTOR-FLOAT(vector<float>) type object
(again, using vector<float> as an example of all number based C++ vector types). You can convert that 
back to a Lisp list or a Lisp vector like so:(variable B being a #<STD-VECTOR-FLOAT {1006BA6983}>:)

CV> (VECTOR-FLOAT :TO-LISP-LIST B)

(1.0 2.0 3.0)


CV> (VECTOR-FLOAT :TO-LISP-VEC B)

#(1.0 2.0 3.0)


and then complete any necessary operations on the data.


The ability to get the length of a vector is provided by this librarys overloaded LENGTH methods 
You just evaluate as follows(using variable B from above):


CV> (LENGTH B)

3  <--- Vector B length


If you would like to created an unititialized pointer to a vector<float> to pass to a function, you 
evaluate:


CV> (VECTOR-FLOAT)


#<STD-VECTOR-FLOAT {100352FEA3}> <--- Output is an object pointing to an uninitialized vector<float>.



If you would like to created an initialized C++ vector to pass to a function, you evaluate either of 
the below:


CV> (VECTOR-FLOAT '(1f0 2f0 3f0)) 


CV> (VECTOR-FLOAT (LIST 1f0 2f0 3f0)) 


CV> (VECTOR-FLOAT (VECTOR 1f0 2f0 3f0))  


#<STD-VECTOR-FLOAT {100352FEA3}> <--- Output is a CLOS object pointing to an initialized vector<float>.


Again these functions are a little bit slow for extremely large operations. However, if you assign 
the vector to a variable first like this:


CV> (DEFPARAMETER A (VECTOR 1F0 2F0 3F0 4F0 5F0))

A


CV> (VECTOR-FLOAT A)  <--- this only takes about 0.699 seconds for a million iterations



The functionality to retrieve data from an initialized vector is built into the VECTOR-* functions.
To retrieve data from a vector you evaluate as follows(vector elements are zero-based):


CV> (DEFPARAMETER A (VECTOR-FLOAT '(1F0 2F0 3F0)))

A

CV> (VECTOR-FLOAT A)  <--- Access the 0th element of A.

1.0

CV> (VECTOR-FLOAT A 1)   <---Access the 1st element of A.

2.0

CV> (VECTOR-FLOAT A 2)  <---Access the 2nd element of A.

3.0


Vectors with objects as their elements, VECTOR-DMATCH, VECTOR-KEY-POINT, VECTOR-POINT, VECTOR-POINT-2F,
VECTOR-RECT and VECTOR-VECTOR-4I operate as follows:(I use VECTOR-POINT as an example of the six vectors.)


If you would like to created an uninitialized vector, you evaluate:


CV> (VECTOR-POINT)

#<STD-VECTOR-POINT {1007B187B3}> <--- Output is a object pointing to an uninitialized POINT vector.


If you would like to created an initialized vector, you evaluate:


CV> (VECTOR-POINT (LIST (POINT 1 2) (POINT 3 4)))

#<STD-VECTOR-POINT {1002DBE013}> <--- Output is a object pointing to an initialized POINT vector.


Again, you'll get the most efficiency if you, first, assign the list or vector to a variable.


The functionality to retrieve data from an initialized vector of objects is built into the vector 
function. You just evaluate as follows(vector elements are zero-based):


CV> (DEFPARAMETER A (VECTOR-POINT (LIST (POINT 1 2) (POINT 3 4)))) <--- Create an initialized vector A.

A 


CV> (VECTOR-POINT A 0)  <--- Access the 0th POINT in vector A

#<CV-POINT {1003D4FA73}> 


CV> (VECTOR-POINT A 1)  <--- Access the 1st POINT in vector A

#<CV-POINT {10042AB633}> 



CV> (VECTOR-POINT A 0 0) <--- Access the 0th element of the 0th POINT in vector A.

1

CV> (VECT-POINT A 0 1) <--- Access the 1st element of the 0th POINT in vector A.

2

CV> (VECTOR-POINT A 1 0) <--- Access the 0th element of the 1st POINT in vector A.

3

CV> (VECTOR-POINT A 1 1) <--- Access the 1st element of the 1st POINT in vector A.

4


And, also, as above, you can convert the POINT vector back to a Lisp list or vector as follows:


CV> (VECTOR-POINT :TO-LISP-LIST A)


(#<CV-POINT {1006C49DA3}> #<CV-POINT {1006C49E03}>)  <--- Lisp list


CV> (VECTOR-POINT :TO-LISP-VEC A)


#(#<CV-POINT {1006C49DA3}> #<CV-POINT {1006C49E03}>)  <--- Lisp vector


And, again, you can also retrieve the length of the vector using its LENGTH method:


(LENGTH A)

2  <--- Vector A length


Note: The Common Lisp function LENGTH is overloaded in this libray so it can retrieve the length of 
a C++ vector as well. This overloading causes CL:LENGTH to take close to a 0.022 sceond per million 
iteration speed decrease. If you would like to use the Common Lisp function LENGTH directly, while 
you're in the LISP-CV package, you need to evaluate CL:LENGTH.


Note: If a VECTOR-DMATCH contains a 3 element DMATCH, the value you entered as the 3rd parameter to 
DMATCH will be accessible at the 4th index. The reason is, with 3 element DMATCH, the 3rd parameter 
contains the value of the OpenCV C++ DMatch class 'distance' member. That member is the fourth member
in the OpenCV DMatch class. If you access the value at the 3rd index, you will be retrieving the value 
of the OpenCv DMatch class imgIdx(IMG-IDX in Lisp-CV) member, which is of int type, and has a default 
value of -1, for example:


CV> (VECTOR-DMATCH A 0 2) <== IMG-IDX 
                                    
-1                                   
                                     
CV> (VECTOR-DMATCH A 0 3) <== DISTANCE

3.0

You may also use the accessor methods as below:

CV> (IMG-IDX (VECTOR-DMATCH A 0))

-1

CV> (DISTANCE (VECTOR-DMATCH A 0))

3.0


;;Now for pushing elements into a vector...

;;First, we create a VECTOR-MAT object...

(WITH-VECTOR-MAT ((VEC (VECTOR-MAT)))

;;Then, we create a 3x3 MAT object...

(WITH-MAT ((MAT (MAT 3 3 +8U+)))

(format t "~%")

;;Now, PUSH 1 million matrices into the vector and use the CL::TIME macro to time how long it takes.
;;Oddly enough(this being a C++ binding), it's quicker than C++ you do this(on my machine that is).

($ 
    (DOTIMES (N 1000000)
     (PUSH-BACK VEC MAT)) 1))

;;Print the LENGTH of VEC, a whopping ONE MILLION elements in record time!.

(FORMAT T "VEC length = ~a~%" (LENGTH VEC)))


Now we access vector elements using the @ macro(Vector elements are 0 based).


First, create a vector of matrices...

CV> (DEFPARAMETER VEC (t:VECTOR-MAT (LIST (t:MAT 3 3 +8U+ 1) (t:MAT 3 3 +8U+ 2) (t:MAT 3 3 +8U+ 3))))

VEC

Print the matrix at index 0(index of 0 doesn't need to be specified).

CV> (PRINT-MAT (@ VEC))

#2M((1 1 1)
    (1 1 1)
    (1 1 1))

Print the matrix at index 0(by specifying the index).

CV> (PRINT-MAT (@ VEC 0))

#2M((1 1 1)
    (1 1 1)
    (1 1 1))

Print the matrix at index 1.

CV> (PRINT-MAT (@ VEC 1))

#2M((2 2 2)
    (2 2 2)
    (2 2 2))

Print the matrix at index 2.

CV> (PRINT-MAT (@ VEC 2))

#2M((3 3 3)
    (3 3 3)
    (3 3 3))


All finished!!! I hope you enjoy these LISP-CV std::vector bindings:)
========================================================================================================================================
========================================================================================================================================
========================================================================================================================================
========================================================================================================================================
========================================================================================================================================
========================================================================================================================================
========================================================================================================================================
========================================================================================================================================
========================================================================================================================================
========================================================================================================================================
