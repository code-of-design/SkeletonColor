/*
Copyright (C) 2014  Thomas Sanchez Lengeling.
 KinectPV2, Kinect for Windows v2 library for processing

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

import processing.opengl.*;

import KinectPV2.KJoint;
import KinectPV2.*;

KinectPV2 kinect; // Kinectクラス.

Skeleton [] skeleton; // スケルトン配列.

int time = 0; // 時間.
boolean isTimer = false;
int begin_time = 0;
int count = 0; // カウント.
int COUNT_RATE = 1000; // カウントレート.

int FRAME_RATE = 60; // フレームレート.
float DISPLAY_PADDING = 100;

PVector r, l; // 手ベクトル.
float hand_dist = 0.0; // 手の距離.
float CLAP_TH = 50; // 拍手判定閾値.

// Font.
PFont noto_sans;

// Color.
color pink = color(247, 202, 201); // PANTONE ROSE QUARTZ.
color blue = color(146, 168, 209); // PANTONE SERENITY.

void setup() {
  size(1920, 1080, OPENGL);
  // size(1920*2, 1080*2, P3D);

  frameRate(FRAME_RATE); // フレームレート.

  // Fontを初期化する.
  noto_sans = createFont("Noto Sans CJK JP", 72, true);
  textFont(noto_sans);

  kinect = new KinectPV2(this); // Kinectクラスを生成する.

  kinect.enableSkeleton(true);
  kinect.enableSkeletonColorMap(true);
  kinect.enableColorImg(true);

  kinect.init(); // Kinectを初期化する.
}

void draw() {
  background(0);

  // 時間.
  time = (int)millis()/COUNT_RATE;

  image(kinect.getColorImage(), 0, 0, width, height);

  skeleton =  kinect.getSkeletonColorMap();

  // individual JOINTS
  for (int i = 0; i < skeleton.length; i++) {
    if (skeleton[i].isTracked()) {
      KJoint[] joints = skeleton[i].getJoints();

      /*
      color col = color(0,0,255);
      fill(col);
      stroke(col);
      drawBody(joints);
      //draw different color for each hand state
      drawHandState(joints[KinectPV2.JointType_HandRight]);
      drawHandState(joints[KinectPV2.JointType_HandLeft]);
      */

      // 手の距離を描写する.
      drawHandDist(joints[KinectPV2.JointType_HandRight], joints[KinectPV2.JointType_HandLeft]);
    }
  }

  // Kinectメタ情報を描画する.
  // カウント.
  if(isTimer){
    count = time-begin_time;
  }
  fill(0,0,255);
  textSize(100);
  text("COUNT", DISPLAY_PADDING, DISPLAY_PADDING);
  textSize(300);
  text(count, DISPLAY_PADDING, DISPLAY_PADDING+300);
}

// 手の距離を描画する.
void drawHandDist(KJoint jointR, KJoint jointL){
  r = new PVector(jointR.getX(), jointR.getY()); // 右手ベクトル.
  l = new PVector(jointL.getX(), jointL.getY()); // 左手ベクトル.

  // 手の距離を測定する.
  hand_dist = PVector.dist(r, l);

  // 手の距離を描画する.
  fill(0,0,255);
  stroke(0,0,255);
  strokeWeight(3);
  textSize(50);
  text(hand_dist, (r.x-l.x)/2+l.x-50, (r.y-l.y)/2+l.y-50);
  line(r.x, r.y, l.x, l.y);
  noFill();
  ellipse(r.x, r.y, 70, 70);
  ellipse(l.x, l.y, 70, 70);

  // 拍手の判定をする.
  if(hand_dist <= CLAP_TH && count%3 == 0){
    fill(0,0,255);
    textSize(200);
    text("GOOD", r.x, r.y);
  }
}

// 足の位置を描画する.
void drawAnklePosition(KJoint joint) {
  noStroke();
  pushMatrix();
  translate(joint.getX(), joint.getY(), joint.getZ());
  // ellipse(0, 0, 70, 70);
  textSize(60);
  text(joint.getX(),0,-180);
  text(joint.getY(),0,-120);
  text(int(joint.getZ()),0,-60);
  println(joint.getX(), joint.getY(), joint.getZ());
  popMatrix();
}

// カウントを開始する.
void mouseClicked() {
  isTimer = true;
  begin_time = time; // 開始時間の取得.
}

//use different color for each skeleton tracked
color getIndexColor(int index) {
  color col = color(255);
  if (index == 0)
    col = color(255, 0, 0);
  if (index == 1)
    col = color(0, 255, 0);
  if (index == 2)
    col = color(0, 0, 255);
  if (index == 3)
    col = color(255, 255, 0);
  if (index == 4)
    col = color(0, 255, 255);
  if (index == 5)
    col = color(255, 0, 255);

  return col;
}

// DRAW BODY
void drawBody(KJoint[] joints) {
  drawBone(joints, KinectPV2.JointType_Head, KinectPV2.JointType_Neck);
  drawBone(joints, KinectPV2.JointType_Neck, KinectPV2.JointType_SpineShoulder);
  drawBone(joints, KinectPV2.JointType_SpineShoulder, KinectPV2.JointType_SpineMid);
  drawBone(joints, KinectPV2.JointType_SpineMid, KinectPV2.JointType_SpineBase);
  drawBone(joints, KinectPV2.JointType_SpineShoulder, KinectPV2.JointType_ShoulderRight);
  drawBone(joints, KinectPV2.JointType_SpineShoulder, KinectPV2.JointType_ShoulderLeft);
  drawBone(joints, KinectPV2.JointType_SpineBase, KinectPV2.JointType_HipRight);
  drawBone(joints, KinectPV2.JointType_SpineBase, KinectPV2.JointType_HipLeft);

  // Right Arm
  drawBone(joints, KinectPV2.JointType_ShoulderRight, KinectPV2.JointType_ElbowRight);
  drawBone(joints, KinectPV2.JointType_ElbowRight, KinectPV2.JointType_WristRight);
  drawBone(joints, KinectPV2.JointType_WristRight, KinectPV2.JointType_HandRight);
  drawBone(joints, KinectPV2.JointType_HandRight, KinectPV2.JointType_HandTipRight);
  drawBone(joints, KinectPV2.JointType_WristRight, KinectPV2.JointType_ThumbRight);

  // Left Arm
  drawBone(joints, KinectPV2.JointType_ShoulderLeft, KinectPV2.JointType_ElbowLeft);
  drawBone(joints, KinectPV2.JointType_ElbowLeft, KinectPV2.JointType_WristLeft);
  drawBone(joints, KinectPV2.JointType_WristLeft, KinectPV2.JointType_HandLeft);
  drawBone(joints, KinectPV2.JointType_HandLeft, KinectPV2.JointType_HandTipLeft);
  drawBone(joints, KinectPV2.JointType_WristLeft, KinectPV2.JointType_ThumbLeft);

  // Right Leg
  drawBone(joints, KinectPV2.JointType_HipRight, KinectPV2.JointType_KneeRight);
  drawBone(joints, KinectPV2.JointType_KneeRight, KinectPV2.JointType_AnkleRight);
  drawBone(joints, KinectPV2.JointType_AnkleRight, KinectPV2.JointType_FootRight);

  // Left Leg
  drawBone(joints, KinectPV2.JointType_HipLeft, KinectPV2.JointType_KneeLeft);
  drawBone(joints, KinectPV2.JointType_KneeLeft, KinectPV2.JointType_AnkleLeft);
  drawBone(joints, KinectPV2.JointType_AnkleLeft, KinectPV2.JointType_FootLeft);

  drawJoint(joints, KinectPV2.JointType_HandTipLeft);
  drawJoint(joints, KinectPV2.JointType_HandTipRight);
  drawJoint(joints, KinectPV2.JointType_FootLeft);
  drawJoint(joints, KinectPV2.JointType_FootRight);

  drawJoint(joints, KinectPV2.JointType_ThumbLeft);
  drawJoint(joints, KinectPV2.JointType_ThumbRight);

  drawJoint(joints, KinectPV2.JointType_Head);
}

void drawJoint(KJoint[] joints, int jointType) {
  pushMatrix();
  translate(joints[jointType].getX(), joints[jointType].getY(), joints[jointType].getZ());
  ellipse(0, 0, 25, 25);
  popMatrix();
}

void drawBone(KJoint[] joints, int jointType1, int jointType2) {
  pushMatrix();
  translate(joints[jointType1].getX(), joints[jointType1].getY(), joints[jointType1].getZ());
  ellipse(0, 0, 25, 25);
  popMatrix();
  line(joints[jointType1].getX(), joints[jointType1].getY(), joints[jointType1].getZ(), joints[jointType2].getX(), joints[jointType2].getY(), joints[jointType2].getZ());
}

void drawHandState(KJoint joint) {
  noStroke();
  handState(joint.getState());
  pushMatrix();
  translate(joint.getX(), joint.getY(), joint.getZ());
  ellipse(0, 0, 70, 70);
  popMatrix();

  // println(joint.getX(), joint.getY(), joint.getZ());
}

/*
Different hand state
 KinectPV2.HandState_Open
 KinectPV2.HandState_Closed
 KinectPV2.HandState_Lasso
 KinectPV2.HandState_NotTracked
 */
void handState(int handState) {
  switch(handState) {
  case KinectPV2.HandState_Open:
    fill(0, 255, 0);
    break;
  case KinectPV2.HandState_Closed:
    fill(255, 0, 0);
    break;
  case KinectPV2.HandState_Lasso:
    fill(0, 0, 255);
    break;
  case KinectPV2.HandState_NotTracked:
    fill(255, 255, 255);
    break;
  }
}
