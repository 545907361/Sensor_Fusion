# Camera

### Outline
I.  Basics
II. Collision Detection System
1. Collision Detection Basics
2. Estimate TTC with Lidar
3. Estimate TTC with a Camera

III. Tracking Images Features
1. Intensity Gradient and Filtering
[2. Harris Corner Detection](#harriscornerdetection)

### II. Collision Detection System
#### 2.1. Collision Detection Basics
a. Problem
- A collision avoidance system (CAS) is an active safety that warns drivers or even triggers the brake in the event of an imminent collision with an object in the path of driving. 
- The CAS vehicle continously estimates the time-to-collision (TTC) if a preceding vehicle is present. 
- CAS vehicle makes safety decision when TTC falls under safety threshold. 
- Engineering task: try to solve for TTC.

![Image1](./images/draggedimage.png)

b. Constant Velocity vs. Constant Acceleration
- Make assumptions on physical behavior of the preceding vehicle.
- Assumption 1: Constant Velocity model - CVM (easy model, will focus in this course)
- Assumption 2: Constant Acceleration model - CAM (more realistic for use case in actual practice)

![Images2](./images/draggedimage-1.png)

#### 2.2. Estimate TTC with Lidar

#### 2.3. Estimate TTC with a Camera
- Monocular cameras are not able to measure metric distance. Require a second camera.
- Given two images taken by two carefully aligned cameras (stereo setup) at the same time instant, one can locate common point of interest in both images and then triangulate their distance using camera geometry and perspective projection.
- However, stereo cameras are going away in the market due to size, cost and computational load.
- Problem: trying to find TTC without distance using monocular camera. Using the sketch below to help solving the problem
![Image3](./images/pinhole.png)
    - f: focal lengt, d1: distance from camera to object at time t_1, d_0: distance from camera to object at time t_0.
    - H: real object height, h_0: image object height at time t_0, h_1: image object height at time t_1
- Generate equations:
![Image4](./images/pinhole-1.png)

### III. Tracking Image Features
#### 3.1. Intensity Gradient and Filtering
a. Locating keypoints in an images
![Image5](./images/keypoints.jpg)
    - Left: distinctive constrast between bright and dark pixels
    - Middle: Resemble a corner formed by a group of very dark pixels in the upper-left.
    - Right: a bright blob that might be approximated by an ellipse
- In order ot precisely locate a keypoint in an image, we need a way to assign them a unique coordinate in both x and y. The left image is hard for this purpose but the middle and right features are good candidate.

b. The Intensity Gradient
- To precisely locate the corner in the middle patch, we do not need to know its color but instead we require the color difference between the pixels that form the corner to be as high as possible. An ideal corner would consist of only black and white pixels.
- The below figure shows the intensity profile and intensity gradient (derivative of image intensity) of all pixels along the red line.
![Image6](./images/intensity-and-derivative.jpg)
    - Intensity profile increases rapidly at positions where the contrast between neighboring pixels changes significantly. 
    - If we wanted to assign unique coordinates to the pixels where the change occurs, we could do so by looking at the derivative of the intensity, which is the blue gradient profile you can see below the red line. Sudden changes in image intensity are clearly visible as distinct peaks and valleys in the gradient profile. 
    - If we were to look for such peaks not only from left to right but also from top to bottom, we could look for points which show a gradient peak both in horizontal and in vertical direction and choose them as keypoints with both x and y coordinates. In the example patches above, this would work best for the corner, whereas an edge-like structure would have more or less identical gradients at all positions with no clear peak in x and y.

- Based on the above observations, the first step into keypoint detection is thus the computation of a gradient image. Mathematically, the gradient is the partial derivative of the image intensity into both x and y direction. The figure below shows the intensity gradient for three example patches. The gradient direction is represented by the arrow.
![Image6](./images/intensity.png)
- Compute both the direction as well as magnitude
![Image7](./images/intensity-dir-mag.png)

c. Image Filters and Gaussian Smoothing
- Noise presents in all images (except the artifical ones). Noise decreases with increasing light intensity.
- To counteract noise in low-light condition, a smoothing operator has to be applied before gradient computation. Gaussian filter is used for this purpose which is shifted over the image and combined with the intensity values beneath it.
- Two paramters need to be adjusted in Gaussian filter
    - The standard deviation: control spatial extension of the filter in the image plane. The larger the standard deviation, the wider the area which covered by the filter
    ![Image8](./images/gaussian.png)
    - Kernel size: defines how many pixels around the center location will contribute to the smoothing operation.

Exercise: `gradient_filtering/src/gassian_smoothing.cpp`

d. Computing the Intensity Gradient
- Sobel operator: applying small integer-valued filters both in horizontal and vertical direction.
- The operators are 3x3 kernels, one for the gradient in x and one for the gradient in y. Both kernels are shown below.
![Image9](./images/sobel.png)

#### <a name="harriscornerdetection"></a>3.2. Haris Corner Detection
a. Local measure of uniqueness
- The idea of of keypoint detection: to detect a unique structure in an image that can be precisely located in both coordinate directions. 
- The idea of locating corners by means of an algorithm: to find a way to detect areas with a significant change in the image structure based on a displacement of a local window W. A suitable measure is sum of squared differences (SSD), which looks at the deviations of all pixels in a local neighborhood before and after the shift. 
![Image10](./images/ssd.png)
u: amount of shift on x direction, v: amount of shift in y direction
H: covariance matrix

- Eigenvalues compute from H:
![Image11](./images/eigenvalue.png)
- Harris Response with k factor range between k = 0.04-0.06
![Image12](./images/harris-response.png)