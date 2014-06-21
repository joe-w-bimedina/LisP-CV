;;;; -*- mode: lisp; indent-tabs: nil -*-
;;;; constants.lisp
;;;; OpenCV bindings
;;;; OpenCV constants

(in-package :lisp-cv)


;; C Constants.

(defanonenum
  (+char-bit+ 8)           
  (+schar-min+ -28)        
  (+schar-max+ 127)        
  (+uchar-max+ 255)       
  (+char-min+ -128)        
  (+char-min-j+ 0)
  (+char-max+ 127)         
  (+char-max-j+ 255)       
  (+mb-len-max+ 5)         
  (+shrt-min+ -32768)    
  (+shrt-max+ 32767)      
  (+ushrt-max+ 65535)      
  (+int-min+ -2147483648)  
  (+int-max+ 2147483647)   
  (+uint-max+ 4294967295) 
  (+long-min+ -2147483648) 
  (+long-max+ 2147483647)  
  (+ulong-max+ 4294967295)
  (+dbl-min+ -2.2250738585072014d-308)
  (+-dbl-max+ -1.7976931348623157d308)
  (+dbl-max+ 1.7976931348623157d308)
  (+flt-max+ 3.40282347e38) 
  (+rand-max+ 2147483647)


;;; core

  (+max-dim+ 32)
  (+8u+ 0)
  (+8uc1+ 0)
  (+8uc2+ 8)
  (+8uc3+ 16)
  (+8uc4+ 24)
  (+8s+ 1)
  (+8sc1+ 1)
  (+8sc2+ 9)
  (+8sc3+ 17)
  (+8sc4+ 25)
  (+16u+ 2)
  (+16uc1+ 2)
  (+16uc2+ 10)
  (+16uc3+ 18)
  (+16uc4+ 26)
  (+16s+ 3)
  (+16sc1+ 3)
  (+16sc2+ 11)
  (+16sc3+ 19)
  (+16sc4+ 27)
  (+32s+ 4)
  (+32sc1+ 4)
  (+32sc2+ 12)
  (+32sc3+ 20)
  (+32sc4+ 28)
  (+32f+ 5)
  (+32fc1+ 5)
  (+32fc2+ 13)
  (+32fc3+ 21)
  (+32fc4+ 29)
  (+64f+ 6)
  (+64fc1+ 6)
  (+64fc2+ 14)
  (+64fc3+ 22)
  (+64fc4+ 30)
  (+count+ 1)
  (+max-iter+ 1)
  (+eps+ 2)
  (+ipl-depth-1u+ 1)
  (+ipl-depth-8u+ 8)
  (+ipl-depth-16u+ 16)
  (+ipl-depth-32f+ 32)
  (+ipl-depth-64f+ 64)                                
  (+ipl-depth-sign+ -2147483648) 
  (+ipl-depth-8s+ -2147483640)  
  (+ipl-depth-16s+ -2147483632) 
  (+ipl-depth-32s+ -2147483616)
  (+ipl-data-order-pixel+ 0)
  (+ipl-data-order-plane+ 1)
  (+ipl-origin-tl+ 0)
  (+ipl-origin-bl+ 1)
  (+auto-step+ 0)
  (+cmp-eq+ 0) 
  (+cmp-gt+ 1) 
  (+cmp-ge+ 2) 
  (+cmp-lt+ 3) 
  (+cmp-le+ 4) 
  (+cmp-ne+ 5)
  (+dft-inverse+ 1)
  (+dft-scale+ 2)
  (+dft-rows+ 4)
  (+dft-complex-output+ 16)
  (+dft-real-output+ 32)
  (+dxt-forward+ 0)
  (+dxt-inverse+ 1)
  (+dxt-inv-scale+ 2)
  (+dxt-inverse-scale+ 2)
  (+dxt-rows+ 4) 
  (+dxt-mul-conj+ 8) 
  (+decomp-lu+ 0)
  (+decomp-svd+ 1)
  (+decomp-eig+ 2)
  (+decomp-cholesky+ 3)
  (+decomp-qr+ 4)
  (+decomp-normal+ 16)
  (+C+ 1)
  (+l1+ 2)
  (+l2+ 4)
  (+norm-inf+ 1) 
  (+norm-l1+ 2) 
  (+norm-l2+ 4) 
  (+norm-hamming+ 6)
  (+norm-hamming2+ 7)
  (+norm-type-mask+ 7) 
  (+norm-relative+ 8)
  (+norm-minmax+ 32)
  (+minmax+ 32)
  (+relative-c+ 9)
  (+relative-l1+ 10)
  (+relative-l2+ 12)
  (+aa+ 16)
  (+filled+ -1)
  (+font-hershey-simplex+ 0)
  (+font-hershey-plain+ 1)
  (+font-hershey-duplex+ 2)
  (+font-hershey-complex+ 3)
  (+font-hershey-triplex+ 4)
  (+font-hershey-complex-small+ 5)
  (+font-hershey-script-simplex+ 6)
  (+font-hershey-script-complex+ 7)
  (+font-italic+ 16) 
  (+cpu-none+ 0)
  (+cpu-mmx+ 1)
  (+cpu-sse+ 2)
  (+cpu-sse2+ 3)
  (+cpu-sse3+ 4)
  (+cpu-ssse3+ 5)
  (+cpu-sse4-1+ 6)
  (+cpu-sse4-2+ 7)
  (+cpu-popcnt+ 8)
  (+cpu-avx+ 10)
  (+hardware-max-feature+ 255)
  (+max-feature+ 255)
  (+stsok+ 0)    
  (+stsbacktrace+ -1)       
  (+stserror+ -2)      
  (+stsinternal+ -3)        
  (+stsnomem+ -4)   
  (+stsbadarg+ -5)      
  (+stsbadfunc+ -6) 
  (+stsnoconv+ -7)            
  (+stsautotrace+ -8)  
  (+headerisnull+ -9)   
  (+badimagesize+ -10)              
  (+badoffset+ -11) 
  (+baddataptr+ -12)
  (+badstep+ -13)
  (+badmodelorchseq+ -14)
  (+badnumchannels+ -15)
  (+stskernelstructcontenterr+ -30)  
  (+stsfilteroffseterr+ -31) 
  (+stsbadsize+  -201) 
  (+stsdivbyzero+   -202) 
  (+stsinplacenotsupported+ -203)  
  (+stsobjectnotfound+ -204)  
  (+stsunmatchedformats+ -205)   
  (+stsbadflag+  -206)  
  (+stsbadpoint+ -207)  
  (+stsbadmask+  -208)  
  (+stsunmatchedsizes+ -209)  
  (+stsunsupportedformat+ -210)  
  (+stsoutofrange+  -211) 
  (+stsparseerror+  -212)  
  (+stsnotimplemented+ -213)  
  (+stsbadmemblock+ -214)
  (+stsassert+   -215)  
  (+gpunotsupported+ -216)
  (+gpuapicallerror+ -217)
  (+openglnotsupported+ -218)
  (+openglapicallerror+ -219)
  (+badnumchannel1u+ -16)
  (+baddepth+    -17)
  (+badalphachannel+ -18)
  (+badorder+    -19)
  (+badorigin+   -20)
  (+badalign+    -21)
  (+badcallback+ -22)
  (+badtilesize+ -23)
  (+badcoi+      -24)
  (+badroisize+  -25)
  (+maskistiled+ -26)
  (+stsnullptr+  -27)  
  (+stsveclengtherr+ -28) 
  (+stsfilterstructcontenterr+ -29) 
  (+termcrit-iter+ 1)
  (+termcrit-number 1)
  (+termcrit-eps+ 2)
  (+covar-scrambled+ 0)
  (+covar-normal+ 1)
  (+covar-use-avg+ 2)
  (+covar-scale+ 4)
  (+covar-rows+ 8)
  (+covar-cols+ 16)


;;; highgui


  (+cvtimg-flip+ 1)
  (+cvtimg-swap-rb+ 2)
  (+window-normal+ 0)
  (+window-autosize+ 1)
  (+window-opengl+ 4096)
  (+gui-expanded+ 0)
  (+gui-normal+ 16)
  (+cap-any+ 0)
  (+cap-prop-pos-msec+ 0)      
  (+cap-prop-pos-frames+ 1)    
  (+cap-prop-pos-avi-ratio+ 2) 
  (+cap-prop-frame-width+ 3)     
  (+cap-prop-frame-height+ 4) 
  (+cap-prop-fps+ 5)          
  (+cap-prop-fourcc+ 6)       
  (+cap-prop-frame-count+ 7)  
  (+cap-prop-format+ 8)       
  (+cap-prop-mode+ 9)          
  (+cap-prop-brightness+ 10)    
  (+cap-prop-contrast+ 11)      
  (+cap-prop-saturation+ 12)    
  (+cap-prop-hue+ 13)            
  (+cap-prop-gain+ 14)         
  (+cap-prop-exposure+ 15)      
  (+cap-prop-convert-rgb+ 16)   
  (+cap-prop-white-balance+ 17) 
  (+cap-prop-rectification+ 18)
  (+event-mousemove+ 0)
  (+event-lbuttondown+ 1) 
  (+event-rbuttondown+ 2) 
  (+event-mbuttondown+ 3) 
  (+event-lbuttonup+ 4) 
  (+event-rbuttonup+ 5) 
  (+event-mbuttonup+ 6) 
  (+event-lbuttondblclk+ 7)
  (+event-rbuttondblclk+ 8) 
  (+event-mbuttondblclk+ 9) 
  (+event-flag-lbutton+ 1) 
  (+event-flag-rbutton+ 2) 
  (+event-flag-mbutton+ 4) 
  (+event-flag-ctrlkey+ 8) 
  (+event-flag-shiftkey+ 16)
  (+event-flag-altkey+ 32) 
  (+imread-unchanged+ -1)
  (+imread-grayscale+ 0)
  (+imread-color+ 1)
  (+imread-anydepth+ 2)
  (+imread-anycolor+  4)
  (+imwrite-jpeg-quality+ 1)
  (+imwrite-png-compression+ 16)
  (+imwrite-png-strategy+ 17)
  (+imwrite-png-bilevel+ 18)
  (+imwrite-png-strategy-default+ 0)
  (+imwrite-png-strategy-filtered+ 1)
  (+imwrite-png-strategy-huffman-only+ 2)
  (+imwrite-png-strategy-rle+ 3)
  (+imwrite-png-strategy-fixed+ 4)
  (+imwrite-pxm-binary+ 32)
  (+imwrite-webp-quality+ 64)
  (+load-image-unchanged+ -1)
  (+load-image-grayscale+ 0)
  (+load-image-color+ 1)
  (+load-image-anydepth+ 2)
  (+load-image-anycolor+ 4)
  (+window-fullscreen+ 1) 
  (+window-freeratio+ 256) 
  (+window-keepratio+ 0) 
  (+wnd-prop-fullscreen+ 0) 
  (+wnd-prop-autosize+ 1) 
  (+wnd-prop-aspectratio+ 2)


;;; calib3d:

  (+calib-cb-adaptive-thresh+ 1)
  (+calib-cb-normalize-image+ 2)
  (+calib-cb-filter-quads+ 4)
  (+calib-cb-fast-check+ 8)

;;; imgproc:

  (+ipl-border-constant+ 0)
  (+ipl-border-replicate+ 1)
  (+border-constant+ 0)
  (+border-replicate+ 1)
  (+border-reflect+ 2)
  (+border-wrap+ 3)
  (+border-reflect-101+ 4)
  (+border-reflect101+ 4)
  (+border-default+ 4)
  (+border-transparent+ 5)
  (+border-isolated+ 16)
  (+cv-shape-rect+ 0)
  (+cv-shape-cross+ 1)
  (+cv-shape-ellipse+ 2)
  (+morph-erode+ 0)
  (+morph-dilate+ 1)
  (+morph-open+ 2)
  (+morph-close+ 3)
  (+morph-gradient+ 4)
  (+morph-tophat+ 5)
  (+morph-blackhat+ 6)
  (+morph-rect+ 0)
  (+morph-cross+ 1)
  (+morph-ellipse+ 2)
  (+shape-custom+ 100)
  (+gaussian-5x5+ 7)
  (+blur-no-scale+ 0)
  (+blur+ 1)
  (+gaussian+ 2)
  (+median+ 3)
  (+bilateral+ 4)
  (+scharr+ -1)
  (+warp-fill-outliers+ 8)
  (+warp-inverse-map+ 16)
  (+inter-nearest+ 0)
  (+inter-linear+ 1)
  (+inter-cubic+ 2)
  (+inter-area+ 3)
  (+inter-lanczos4+ 4)
  (+thresh-binary+ 0)
  (+thresh-binary-inv+ 1)
  (+thresh-trunc+ 2)
  (+thresh-tozero+ 3)
  (+thresh-tozero-inv+ 4)
  (+thresh-otsu+ 8)
  (+adaptive-thresh-mean-c+ 0)
  (+adaptive-thresh-gaussian-c+ 1) 
  (+bgr2bgra+ 0)
  (+rgb2rgba+ 0)
  (+bgra2bgr+ 1)
  (+rgba2rgb+ 1)
  (+bgr2rgba+ 2)
  (+rgb2bgra+ 2)
  (+rgba2bgr+ 3)
  (+bgra2rgb+ 3)
  (+bgr2rgb+ 4)
  (+rgb2bgr+ 4)
  (+bgra2rgba+ 5)
  (+rgba2bgra+ 5)
  (+bgr2gray+ 6)
  (+rgb2gray+ 7)
  (+gray2bgr+ 8)
  (+gray2rgb+ 8)
  (+gray2bgra+ 9)
  (+gray2rgba+ 9)
  (+bgra2gray+ 10)
  (+rgba2gray+ 11)
  (+bgr2bgr565+ 12)
  (+rgb2bgr565+ 13)
  (+bgr5652bgr+ 14)
  (+bgr5652rgb+ 15)
  (+bgra2bgr565+ 16)
  (+rgba2bgr565+ 17)
  (+bgr5652bgra+ 18)
  (+bgr5652rgba+ 19)
  (+gray2bgr565+ 20)
  (+bgr5652gray+ 21)
  (+bgr2bgr555+ 22)
  (+rgb2bgr555+ 23)
  (+bgr5552bgr+ 24)
  (+bgr5552rgb+ 25)
  (+bgra2bgr555+ 26)
  (+rgba2bgr555+ 27)
  (+bgr5552bgra+ 28)
  (+bgr5552rgba+ 29)
  (+gray2bgr555+ 30)
  (+bgr5552gray+ 31)
  (+bgr2xyz+ 32)
  (+rgb2xyz+ 33)
  (+xyz2bgr+ 34)
  (+xyz2rgb+ 35)
  (+bgr2ycrcb+ 36)
  (+rgb2ycrcb+ 37)
  (+ycrcb2bgr+ 38)
  (+ycrcb2rgb+ 39)
  (+bgr2hsv+ 40)
  (+rgb2hsv+ 41)
  (+bgr2lab+ 44)
  (+rgb2lab+ 45)
  (+bayerbg2bgr+ 46)
  (+bayergb2bgr+ 47)
  (+bayerrg2bgr+ 48)
  (+bayergr2bgr+ 49)
  (+bayerbg2rgb+ 48)
  (+bayergb2rgb+ 49)
  (+bayerrg2rgb+ 46)
  (+bayergr2rgb+ 47)
  (+bgr2luv+ 50)
  (+rgb2luv+ 51)
  (+bgr2hls+ 52)
  (+rgb2hls+ 53)
  (+hsv2bgr+ 54)
  (+hsv2rgb+ 55)
  (+lab2bgr+ 56)
  (+lab2rgb+ 57)
  (+luv2bgr+ 58)
  (+luv2rgb+ 59)
  (+hls2bgr+ 60)
  (+hls2rgb+ 61)
  (+bayerbg2bgr-vng+ 62)
  (+bayergb2bgr-vng+ 63)
  (+bayerrg2bgr-vng+ 64)
  (+bayergr2bgr-vng+ 65)
  (+bayerbg2rgb-vng+ 64)
  (+bayergb2rgb-vng+ 65)
  (+bayerrg2rgb-vng+ 62)
  (+bayergr2rgb-vng+ 63)
  (+bgr2hsv-full+ 66)
  (+rgb2hsv-full+ 67)
  (+bgr2hls-full+ 68)
  (+rgb2hls-full+ 69)
  (+hsv2bgr-full+ 70)
  (+hsv2rgb-full+ 71)
  (+hls2bgr-full+ 72)
  (+hls2rgb-full+ 73)
  (+lbgr2lab+ 74)
  (+lrgb2lab+ 75)
  (+lbgr2luv+ 76)
  (+lrgb2luv+ 77)
  (+lab2lbgr+ 78)
  (+lab2lrgb+ 79)
  (+luv2lbgr+ 80)
  (+luv2lrgb+ 81)
  (+bgr2yuv+ 82)
  (+rgb2yuv+ 83)
  (+yuv2bgr+ 84)
  (+yuv2rgb+ 85)
  (+bayerbg2gray+ 86)
  (+bayergb2gray+ 87)
  (+bayerrg2gray+ 88)
  (+bayergr2gray+ 89)
  (+yuv2rgb-nv12+ 90)
  (+yuv2bgr-nv12+ 91)
  (+yuv2rgb-nv21+ 92)
  (+yuv2bgr-nv21+ 93)
  (+yuv420sp2rgb+ 92)
  (+yuv420sp2bgr+ 93)
  (+yuv2rgba-nv12+ 94)
  (+yuv2bgra-nv12+ 95)
  (+yuv2rgba-nv21+ 96)
  (+yuv2bgra-nv21+ 97)
  (+yuv420sp2rgba+ 96)
  (+yuv420sp2bgra+ 97)
  (+yuv2rgb-yv12+ 98)
  (+yuv2bgr-yv12+ 99)
  (+yuv2rgb-iyuv+ 100)
  (+yuv2bgr-iyuv+ 101)
  (+yuv2rgb-i420+ 100)
  (+yuv2bgr-i420+ 101)
  (+yuv420p2rgb+ 98)
  (+yuv420p2bgr+ 99)
  (+yuv2rgba-yv12+ 102)
  (+yuv2bgra-yv12+ 103)
  (+yuv2rgba-iyuv+ 104)
  (+yuv2bgra-iyuv+ 105)
  (+yuv2rgba-i420+ 104)
  (+yuv2bgra-i420+ 105)
  (+yuv420p2rgba+ 103)
  (+yuv420p2bgra+ 103)
  (+yuv2gray-420+ 106)
  (+yuv2gray-nv21+ 106)
  (+yuv2gray-nv12+ 106)
  (+yuv2gray-yv12+ 106)
  (+yuv2gray-iyuv+ 106)
  (+yuv2gray-i420+ 106)
  (+yuv420sp2gray+ 106)
  (+yuv420p2gray+ 106)
  (+yuv2rgb-uyvy+ 107)
  (+yuv2bgr-uyvy+ 108)
  ;;(+yuv2rgb-vyuy+ 109)
  ;;(+yuv2bgr-vyuy+ 110)
  (+yuv2rgb-y422+ 107)
  (+yuv2bgr-y422+ 108)
  (+yuv2rgb-uynv+ 107)
  (+yuv2bgr-uynv+ 108)
  (+yuv2rgba-uyvy+ 111)
  (+yuv2bgra-uyvy+ 112)
  ;;(+yuv2rgba-vyuy+ 113)
  ;;(+yuv2bgra-vyuy+ 114)
  (+yuv2rgba-y422+ 111)
  (+yuv2bgra-y422+ 112)
  (+yuv2rgba-uynv+ 111)
  (+yuv2bgra-uynv+ 112)
  (+yuv2rgb-yuy2+ 115)
  (+yuv2bgr-yuy2+ 116)
  (+yuv2rgb-yvyu+ 117)
  (+yuv2bgr-yvyu+ 118)
  (+yuv2rgb-yuyv+ 115)
  (+yuv2bgr-yuyv+ 116)
  (+yuv2rgb-yunv+ 115)
  (+yuv2bgr-yunv+ 116)
  (+yuv2rgba-yuy2+ 119)
  (+yuv2bgra-yuy2+ 120)
  (+yuv2rgba-yvyu+ 121)
  (+yuv2bgra-yvyu+ 122)
  (+yuv2rgba-yuyv+ 119)
  (+yuv2bgra-yuyv+ 120)
  (+yuv2rgba-yunv+ 119)
  (+yuv2bgra-yunv+ 120)
  (+yuv2gray-uyvy+ 123)
  (+yuv2gray-yuy2+ 124)
  ;;(+yuv2gray-vyuy+ 123)
  (+yuv2gray-y422+ 123)
  (+yuv2gray-uynv+ 123)
  (+yuv2gray-yvyu+ 124)
  (+yuv2gray-yuyv+ 124)
  (+yuv2gray-yunv+ 124)
  (+rgba2mrgba+ 125)
  (+mrgba2rgba+ 126)
  (+rgb2yuv-i420+ 127)
  (+bgr2yuv-i420+ 128)
  (+rgb2yuv-iyuv+ 127)
  (+bgr2yuv-iyuv+ 128)
  (+rgba2yuv-i420+ 129)
  (+bgra2yuv-i420+ 130)
  (+rgba2yuv-iyuv+ 129)
  (+bgra2yuv-iyuv+ 130)
  (+rgb2yuv-yv12+ 131)
  (+bgr2yuv-yv12+ 132)
  (+rgba2yuv-yv12+ 133)
  (+bgra2yuv-yv12+ 134)
  (+colorcvt-max+ 135)
  (+dist-l1+ 1)
  (+dist-l2+ 2)
  (+dist-c+ 3)
  (+dist-label-ccomp+ 0)
  (+dist-label-pixel+ 1)
  (+dist-mask-3+ 3)
  (+dist-mask-5+ 5)
  (+dist-mask-precise+ 0)
  (+dist-user+ -1)
  (+poly-approx-dp+ 0)
  (+retr-external+ 0)
  (+retr-list+ 1)
  (+retr-ccomp+ 2)
  (+retr-tree+ 3)
  (+chain-code+ 0)
  (+chain-approx-none+ 1)
  (+chain-approx-simple+ 2)
  (+chain-approx-tc89-l1+ 3)
  (+chain-approx-tc89-kcos+ 4) 
  (+tm-sqdiff+ 0)  
  (+tm-sqdiff-normed+ 1)
  (+tm-ccorr+ 2) 
  (+tm-ccorr-normed+ 3)
  (+tm-ccoeff+ 4)
  (+tm-ccoeff-normed+ 5)
  (+lsd-refine-none+ 0)
  (+lsd-refine-std+ 1)
  (+lsd-refine-adv+ 2)


;;; features2d

  (+default+ 0)
  (+draw-over-outimg+ 1)
  (+not-draw-single-points+ 2)
  (+draw-rich-keypoints+ 4)

;;; objdetect

  (+cascade-do-canny-pruning+ 1)
  (+cascade-scale-image+ 2)
  (+cascade-find-biggest-object+ 4)
  (+cascade-do-rough-search+ 8)
  (+hog-descriptor-l-2-hys+ 0)
  (+hog-descriptor-default-nlevels+ 64)


;;; ml 

  (+ann-mlp-identity+ 0)
  (+ann-mlp-sigmoid-sym+ 1)
  (+ann-mlp-gaussian+  2) 
  (+ann-mlp-train-params-backprop+  0) 
  (+ann-mlp-train-params-rprop+  1)
  (+update-weights+ 1) 
  (+no-input-scale+ 2) 
  (+no-output-scale+ 4)
  (+var-numerical+ 0)
  (+var-ordered+ 0)
  (+var-categorical+ 1)
  (+col-sample+ 0)
  (+row-sample+ 1)


;;; photo

  (+recurs-filter+ 1)
  (+normconv-filter+ 2)
  (+inpaint-ns+ 0)
  (+inpaint-telea+ 1)
  (+normal-clone+ 1)
  (+mixed-clone+ 2)
  (+feature-exchange+ 3)
  (+monochrome-transfer+ 3)

;;; contrib

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
  (+colormap-hot+ 11)
)
