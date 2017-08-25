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

import KinectPV2.KJoint;
import KinectPV2.*;

KinectPV2 kinect;

Skeleton [] skeleton;

float time = 0; // 時間.
float time_bg = 0; // バックグラウンド時間.
float time_begin = 0; // 開始時間.
float time_end = 0; // 終了時間.

float time321 = 4; // 321カウント.

int state = 0; // 0: 待機, 1: 321カウント, 2: 稼働, 4: 終了

boolean clap = false; // 拍手判定.
PVector r, l; // 手ベクトル.
float hand_dist = 0; // 手の距離.

// Font.
PFont noto_sans;

// Color.
color pink = color(247, 202, 201); // PANTONE ROSE QUARTZ.
color blue = color(146, 168, 209); //PANTONE SERENITY.

void setup() {
  size(1920, 1080, P3D);

  frameRate(30);

  // Font.
  noto_sans = createFont("Noto Sans CJK JP", 72, true);
  textFont(noto_sans);

  kinect = new KinectPV2(this);

  kinect.enableSkeleton(true);
  kinect.enableSkeletonColorMap(true);
  kinect.enableColorImg(true);

  kinect.init();
}

void draw() {
  background(0);

  image(kinect.getColorImage(), 0, 0, width, height);

  skeleton =  kinect.getSkeletonColorMap();

  //individual JOINTS
  for (int i = 0; i < skeleton.length; i++) {
    if (skeleton[i].isTracked()) {
      KJoint[] joints = skeleton[i].getJoints();

      // color col  = getIndexColor(i);
      /*
      color col = color(0,0,255);
      fill(col);
      stroke(col);
      drawBody(joints);

      //draw different color for each hand state
      drawHandState(joints[KinectPV2.JointType_HandRight]);
      drawHandState(joints[KinectPV2.JointType_HandLeft]);
      */

      // 拍手.
      drawHandDist(joints[KinectPV2.JointType_HandRight], joints[KinectPV2.JointType_HandLeft]);
    }
  }

  // Kinectメタ情報.
  fill(255, 0, 0);
  // text(int(frameRate), 100, 100);

  // 時間を描画する.
  // time_bg = millis();

  if(state == 1){ // 321カウント.
    fill(255, 255, 255);
    textSize(200);
    textAlign(CENTER);

    if(int(time321) == 0){
      text("スタート！", width/2, 200);
      state = 2;
    }
    else if(int(time321) != 4){
      text(int(time321), width/2, 200);
    }

    time321 -= 1/frameRate*0.9;
  }

  if(state == 2){ // 稼働.
    fill(255, 255, 255);
    textSize(200);
    textAlign(CENTER);

    if(int(time) == 0){
      text("スタート！", width/2, 200);
    }
    else{
      text(int(time), width/2, 200);
    }

    time += 1/frameRate*0.9;
  }

  // 効果を描画する.
  // 拍手.
  if(clap == true){
    fill(255,0,0);
    textSize(250);
    textAlign(LEFT);
    text("Good!", 50, height/2);
  }
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

//DRAW BODY
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

void mouseClicked(){
  if(state == 0){ // 待機.
    // time_begin = time_bg;
    // time_end = time_begin + 60;
    state = 1; // 321カウント.
  }

  println("State: "+state);
  // println("TimeBegin: "+time_begin);
  // println("TimeEnd: "+time_end);
}

// 手の距離を描画する.
void drawHandDist(KJoint jointR, KJoint jointL){
  r = new PVector(jointR.getX(), jointR.getY()); // 右手ベクトル.
  l = new PVector(jointL.getX(), jointL.getY()); // 左手ベクトル.
  float dist_th = 50; // 閾値.

  // 手の距離を測定する.
  hand_dist = PVector.dist(r, l);

  // 手の距離を描画する.
  /*
  fill(0,0,255);
  stroke(0,0,255);
  strokeWeight(3);
  line(r.x, r.y, l.x, l.y);
  */

  // 拍手の判定をする.
  if(hand_dist <= dist_th && int(time)%3 == 0){
    clap = true;
  }
  else{
    clap = false;
  }
}
