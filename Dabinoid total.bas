'******** 2족 보행로봇 초기 영점 프로그램 ********

DIM I AS BYTE
DIM J AS BYTE
DIM MODE AS BYTE
DIM A AS BYTE
DIM A_old AS BYTE
DIM B AS BYTE
DIM C AS BYTE
DIM 보행속도 AS BYTE
DIM 좌우속도 AS BYTE
DIM 좌우속도2 AS BYTE
DIM 보행순서 AS BYTE
DIM 현재전압 AS BYTE
DIM 반전체크 AS BYTE
DIM 모터ONOFF AS BYTE
DIM 자이로ONOFF AS BYTE
DIM 기울기앞뒤 AS INTEGER
DIM 기울기좌우 AS INTEGER
DIM DELAY_TIME AS BYTE
DIM DELAY_TIME2 AS BYTE
'DIM STEP AS BYTE
DIM 넘어진확인 AS BYTE
DIM 기울기확인횟수 AS BYTE
DIM 보행횟수 AS BYTE
DIM 보행COUNT AS BYTE
'************************************************
DIM NO_0 AS BYTE
DIM NO_1 AS BYTE
DIM NO_2 AS BYTE
DIM NO_3 AS BYTE
DIM NO_4 AS BYTE

DIM NUM AS BYTE

DIM BUTTON_NO AS INTEGER
DIM SOUND_BUSY AS BYTE
DIM TEMP_INTEGER AS INTEGER

'**** 기울기센서포트 설정 ****
CONST 앞뒤기울기AD포트 = 0
CONST 좌우기울기AD포트 = 1
CONST 기울기확인시간 = 20  'ms


CONST min = 61	'뒤로넘어졌을때
CONST max = 107	'앞으로넘어졌을때
CONST COUNT_MAX = 3
CONST 하한전압 = 154  '약6V전압
CONST 머리이동속도 = 10
'************************************************



PTP SETON 				'단위그룹별 점대점동작 설정
PTP ALLON				'전체모터 점대점 동작 설정

DIR G6A,1,0,0,1,0,0		'모터0~5번
DIR G6D,0,1,1,0,1,1		'모터18~23번
DIR G6B,1,1,1,1,1,1		'모터6~11번
DIR G6C,0,0,0,0,0,0		'모터12~17번    '0,0,0,0,1,0

'************************************************

OUT 52,0	'머리 LED 켜기
'***** 초기선언 '************************************************
'STEP = 0
보행순서 = 0
반전체크 = 0
기울기확인횟수 = 0
보행횟수 = 1
모터ONOFF = 0

'****초기위치 피드백*****************************

GOSUB 자이로INIT
GOSUB MOTOR_SET
TEMPO 230
MUSIC "g<abcdefg"
DELAY 1000

SPEED 15
GOSUB MOTOR_ON

'delay 3000

GOSUB 전원초기자세
GOSUB 기본자세
GOSUB 자이로MID2
GOSUB 자이로ON
GOSUB All_motor_mode3


'PRINT "VOLUME 200 !"
'PRINT "SOUND 12 !" '안녕하세요

GOTO MAIN	'시리얼 수신 루틴으로 가기

'************************************************


'************************************************
시작음:
    TEMPO 220
    MUSIC "O23EAB7EA>3#C"
    RETURN
    '************************************************
종료음:
    TEMPO 220
    MUSIC "O38GD<BGD<BG"
    RETURN
    '************************************************
에러음:
    TEMPO 250
    MUSIC "FFF"
    RETURN
    '************************************************
    '************************************************
MOTOR_ON: '전포트서보모터사용설정

    GOSUB MOTOR_GET

    MOTOR G6B
    DELAY 50
    MOTOR G6C
    DELAY 50
    MOTOR G6A
    DELAY 50
    MOTOR G6D

    모터ONOFF = 0
    'GOSUB 시작음			
    RETURN

    '************************************************
    '전포트서보모터사용설정
MOTOR_OFF:

    MOTOROFF G6B
    MOTOROFF G6C
    MOTOROFF G6A
    MOTOROFF G6D
    모터ONOFF = 1	
    GOSUB MOTOR_GET	
    'GOSUB 종료음	
    RETURN
    '************************************************
    '위치값피드백
MOTOR_GET:
    GETMOTORSET G6A,1,1,1,1,1,0
    GETMOTORSET G6B,1,1,1,0,0,1
    GETMOTORSET G6C,1,1,1,0,0,0
    GETMOTORSET G6D,1,1,1,1,1,0
    RETURN

    '************************************************
    '위치값피드백
MOTOR_SET:
    GETMOTORSET G6A,1,1,1,1,1,0
    GETMOTORSET G6B,1,1,1,0,0,1
    GETMOTORSET G6C,1,1,1,0,1,0
    GETMOTORSET G6D,1,1,1,1,1,0
    RETURN

    '************************************************
All_motor_Reset:

    MOTORMODE G6A,1,1,1,1,1,1
    MOTORMODE G6D,1,1,1,1,1,1
    MOTORMODE G6B,1,1,1,,,1
    MOTORMODE G6C,1,1,1,,1

    RETURN
    '************************************************
All_motor_mode2:

    MOTORMODE G6A,2,2,2,2,2
    MOTORMODE G6D,2,2,2,2,2
    MOTORMODE G6B,2,2,2,,,2
    MOTORMODE G6C,2,2,2,,2

    RETURN
    '************************************************
All_motor_mode3:

    MOTORMODE G6A,3,3,3,3,3
    MOTORMODE G6D,3,3,3,3,3
    MOTORMODE G6B,3,3,3,,,3
    MOTORMODE G6C,3,3,3,,3

    RETURN
    '************************************************
Leg_motor_mode1:
    MOTORMODE G6A,1,1,1,1,1
    MOTORMODE G6D,1,1,1,1,1
    RETURN
    '************************************************
Leg_motor_mode2:
    MOTORMODE G6A,2,2,2,2,2
    MOTORMODE G6D,2,2,2,2,2
    RETURN

    '************************************************
Leg_motor_mode3:
    MOTORMODE G6A,3,3,3,3,3
    MOTORMODE G6D,3,3,3,3,3
    RETURN
    '************************************************
Leg_motor_mode4:
    MOTORMODE G6A,3,2,2,1,3
    MOTORMODE G6D,3,2,2,1,3
    RETURN
    '************************************************
Leg_motor_mode5:
    MOTORMODE G6A,3,2,2,1,2
    MOTORMODE G6D,3,2,2,1,2
    RETURN
    '************************************************
LArm_motor_mode1:
    MOTORMODE G6B,1,1,1,,,1
    RETURN
    '************************************************
Arm_motor_mode1:
    MOTORMODE G6B,1,1,1,,,1
    MOTORMODE G6C,1,1,1,,1
    RETURN
    '************************************************
Arm_motor_mode2:
    MOTORMODE G6B,2,2,2,,,2
    MOTORMODE G6C,2,2,2,,2
    RETURN

    '************************************************
Arm_motor_mode3:
    MOTORMODE G6B,3,3,3,,,3
    MOTORMODE G6C,3,3,3,,3
    RETURN
    '************************************************
    '***********************************************
    '***********************************************
    '**** 자이로감도 설정 ****
자이로INIT:

    GYRODIR G6A, 0, 0, 1, 0,0
    GYRODIR G6D, 1, 0, 1, 0,0
    GYRODIR G6B, 1, 0, 0, 0,0
    GYRODIR G6C, 1, 0, 0, 0,0

    GYROSENSE G6A,200,150,30,150,0
    GYROSENSE G6D,200,150,30,150,0



    RETURN
    '***********************************************
    '**** 자이로감도 설정 ****
자이로MAX:

    GYROSENSE G6A,250,180,30,180,0
    GYROSENSE G6D,250,180,30,180,0

    RETURN
    '***********************************************
자이로MID:

    GYROSENSE G6A,200,150,30,150,0
    GYROSENSE G6D,200,150,30,150,0

    RETURN
    '***********************************************
자이로MID2:

    GYROSENSE G6A,250,100,30,100,
    GYROSENSE G6D,250,100,30,100,

    RETURN
    '***********************************************
자이로MIN:

    GYROSENSE G6A,200,100,30,100,0
    GYROSENSE G6D,200,100,30,100,0
    RETURN
    '***********************************************
자이로ON:


    GYROSET G6A, 4, 3, 3, 3, 0
    GYROSET G6D, 4, 3, 3, 3, 0


    자이로ONOFF = 1

    RETURN
    '***********************************************
자이로OFF:

    GYROSET G6A, 0, 0, 0, 0, 0
    GYROSET G6D, 0, 0, 0, 0, 0

    자이로ONOFF = 0
    RETURN

    '************************************************
전원초기자세:
    MOVE G6A,100,  76, 145,  93, 100, 100
    MOVE G6D,100,  76, 145,  93, 100, 100
    MOVE G6B,100,  35,  90
    MOVE G6C,100,  35,  90
    WAIT
    mode = 0
    RETURN

    '************************************************
안정화자세:
    MOVE G6A, 98,  76, 145,  93, 101, 100
    MOVE G6D, 98,  76, 145,  93, 101, 100
    MOVE G6B,100,  35,  90,
    MOVE G6C,100,  35,  90
    WAIT
    mode = 0
    RETURN
    '************************************************
기본자세:
    MOVE G6A,100,  76, 145,  93, 100, 100
    MOVE G6D,100,  76, 145,  93, 100, 25
    MOVE G6B,100,  35,  80, 100, 100, 100
    MOVE G6C,100,  35,  80, 100, 117, 100
    WAIT
    mode = 0
    ETX 4800,33
    RETURN
    '************************************************
기본자세2:
    MOVE G6A,100,  76, 145,  93, 100, 100
    MOVE G6D,100,  76, 145,  93, 100, 100
    MOVE G6B,100,  35,  80,
    MOVE G6C,100,  35,  80, 100, 180
    WAIT
    mode = 0
    RETURN
    '************************************************
차렷자세:
    MOVE G6A,100, 56, 182, 76, 100, 100
    MOVE G6D,100, 56, 182, 76, 100, 100
    MOVE G6B,100, 30, 90, 100, 100, 100
    MOVE G6C,100, 30, 90, 100, 100, 100
    WAIT
    mode = 2
    RETURN
    '******************************************
앉은자세:
    MOVE G6A,100, 144,  22, 145, 100, 100
    MOVE G6D,100, 146,  22, 145, 100, 100
    MOVE G6B,110,  35,  80, 100, 100, 100
    MOVE G6C,110,  35,  80, 100, 100, 100	
    WAIT
    mode = 1
    GOSUB 자이로OFF
    RETURN
    '**********************************************
    '**********************************************
    '**********************************************
RX_EXIT:

    ERX 4800, A, MAIN

    GOTO RX_EXIT

GOSUB_RX_EXIT:

    ERX 4800, A, GOSUB_RX_EXIT2

    GOTO GOSUB_RX_EXIT

GOSUB_RX_EXIT2:
    RETURN
    '**********************************************

EAST:
    PRINT "VOLUME 200 !"
    PRINT "SOUND 0 !"

    MOVE G6A,100,  76, 145,  93, 100, 100
    MOVE G6D,100,  76, 145,  93, 100, 100
    MOVE G6B,100,  35,  80, 100, 100, 100
    MOVE G6C,180,  35,  80, 100, 110, 100
    WAIT

    PRINT "VOLUME 200 !"
    PRINT "SOUND 0 !"

    MOVE G6A,100,  76, 145,  93, 100, 100
    MOVE G6D,100,  76, 145,  93, 100, 100
    MOVE G6B,100,  35,  80, 100, 100, 100
    MOVE G6C,100,  35,  80, 100, 117, 100
    WAIT

    mode = 0
    ETX 4800,33
    RETURN
    '**********************************************
WEST:
    PRINT "VOLUME 200 !"
    PRINT "SOUND 1 !"

    MOVE G6A,100,  76, 145,  93, 100, 100
    MOVE G6D,100,  76, 145,  93, 100, 100
    MOVE G6B,180,  35,  80, 100, 100, 100
    MOVE G6C,100,  35,  80, 100, 117, 100
    WAIT

    PRINT "VOLUME 200 !"
    PRINT "SOUND 1 !"

    MOVE G6A,100,  76, 145,  93, 100, 100
    MOVE G6D,100,  76, 145,  93, 100, 100
    MOVE G6B,100,  35,  80, 100, 100, 100
    MOVE G6C,100,  35,  80, 100, 117, 100
    WAIT

    mode = 0
    ETX 4800,33
    RETURN
    '**********************************************
SOUTH:
    PRINT "VOLUME 200 !"
    PRINT "SOUND 2 !"

    MOVE G6A,100,  76, 145,  93, 100, 100
    MOVE G6D,100,  76, 145,  93, 100, 100
    MOVE G6B,20,  35,  80, 100, 100, 100
    MOVE G6C,20,  35,  80, 100, 117, 100
    WAIT

    PRINT "VOLUME 200 !"
    PRINT "SOUND 2 !"

    MOVE G6A,100,  76, 145,  93, 100, 100
    MOVE G6D,100,  76, 145,  93, 100, 100
    MOVE G6B,100,  35,  80, 100, 100, 100
    MOVE G6C,100,  35,  80, 100, 117, 100
    WAIT

    mode = 0
    ETX 4800,33
    RETURN
    '**********************************************
NORTH:
    PRINT "VOLUME 200 !"
    PRINT "SOUND 3 !"

    MOVE G6A,100,  76, 145,  93, 100, 100
    MOVE G6D,100,  76, 145,  93, 100, 100
    MOVE G6B,180,  35,  80, 100, 100, 100
    MOVE G6C,180,  35,  80, 100, 117, 100
    WAIT

    PRINT "VOLUME 200 !"
    PRINT "SOUND 3 !"

    MOVE G6A,100,  76, 145,  93, 100, 100
    MOVE G6D,100,  76, 145,  93, 100, 100
    MOVE G6B,100,  35,  80, 100, 100, 100
    MOVE G6C,100,  35,  80, 100, 117, 100
    WAIT

    mode = 0
    ETX 4800,33
    RETURN
    '**********************************************
첫부분고개살짝들기:
    MOVE G6A,100,  76, 145,  93, 100, 100
    MOVE G6D,100,  76, 145,  93, 100, 100
    MOVE G6B,100,  35,  80,
    MOVE G6C,100,  35,  80, 100, 100
    WAIT
    mode = 0
    RETURN
    '**********************************************
WooWalk2:

    GOSUB 자이로ON
    HIGHSPEED SETOFF
    GOSUB All_motor_mode3

    SPEED 10
    MOVE G6A,100,  76, 145,  95, 100, 100
    MOVE G6D,100,  76, 145,  95, 100, 100
    MOVE G6B,100,  35,  80, 100, 100, 100
    MOVE G6C,100,  35,  80, 100, 117, 100
    WAIT

    SPEED 10
    MOVE G6D,108,  76, 145,  95, 104, 100
    MOVE G6A,100,  86, 125, 109, 100, 100
    MOVE G6B,100,  35,  80, 100, 100, 100
    MOVE G6C,100,  35,  80, 100, 117, 100
    WAIT

    '****************************************

    FOR I = 0 TO 2

        SPEED 10
        MOVE G6A, 99,  66, 145, 103, 100, 100
        MOVE G6D,100,  86, 145,  83, 100, 100
        MOVE G6B,100,  35,  80, 100, 100, 100
        MOVE G6C,100,  35,  80, 100, 117, 100
        WAIT

        SPEED 10
        MOVE G6A,108,  76, 145,  93, 104, 100
        MOVE G6D,100,  86, 125, 103, 100, 100
        MOVE G6B,100,  35,  80, 100, 100, 100
        MOVE G6C,100,  35,  80, 100, 117, 100
        WAIT

        SPEED 10
        MOVE G6D,101,  66, 145, 103, 100, 100
        MOVE G6A,100,  86, 145,  83, 100, 100
        MOVE G6B,100,  35,  80, 100, 100, 100
        MOVE G6C,100,  35,  80, 100, 117, 100
        WAIT

        SPEED 10
        MOVE G6D,108,  76, 145,  93, 104, 100
        MOVE G6A,100,  86, 125, 103, 100, 100
        MOVE G6B,100,  35,  80, 100, 100, 100
        MOVE G6C,100,  35,  80, 100, 117, 100
        WAIT

    NEXT I

    '****************************************

    SPEED 10
    MOVE G6A, 99,  66, 145, 103, 100, 100
    MOVE G6D,100,  86, 145,  83, 100, 100
    MOVE G6B,100,  35,  80, 100, 100, 100
    MOVE G6C,100,  35,  80, 100, 117, 100
    WAIT

    SPEED 10
    MOVE G6A,108,  76, 145,  93, 104, 100
    MOVE G6D,100,  86, 125, 103, 100, 100
    MOVE G6B,100,  35,  80, 100, 100, 100
    MOVE G6C,100,  35,  80, 100, 117, 100
    WAIT

    SPEED 10
    MOVE G6D,101,  66, 145, 103, 100, 100
    MOVE G6A,100,  86, 145,  83, 100, 100
    MOVE G6B,100,  35,  80, 100, 100, 100
    MOVE G6C,100,  35,  80, 100, 117, 100
    WAIT

    SPEED 10
    MOVE G6D,108,  76, 145,  91, 104, 100
    MOVE G6A,100,  86, 125,  97, 100, 100
    MOVE G6B,100,  35,  80, 100, 100, 100
    MOVE G6C,100,  35,  80, 100, 117, 100
    WAIT

    '****************************************

    SPEED 10
    MOVE G6A,100,  76, 145,  93, 100, 100
    MOVE G6D,100,  76, 145,  93, 100, 100
    MOVE G6B,100,  35,  80, 100, 100, 100
    MOVE G6C,100,  35,  80, 100, 117, 100
    WAIT

    GOSUB 자이로OFF

    DELAY 500

    RETURN
    '***************************
MinWalk1:
    GOSUB 자이로ON
    HIGHSPEED SETOFF
    GOSUB All_motor_mode3

    SPEED 15
    MOVE G6A,100,  76, 145,  95, 100, 100
    MOVE G6D,100,  76, 145,  95, 100, 100
    MOVE G6B,100,  35,  80, 100
    MOVE G6C,100,  35,  80, 100
    WAIT

    SPEED 15
    MOVE G6D,105,  76, 145,  95, 106, 100
    MOVE G6A,100,  86, 125, 107, 100, 100
    MOVE G6B,100,  35,  80, 100
    MOVE G6C,100,  35,  80, 100
    WAIT

    '****************************************

    FOR I = 0 TO 3

        SPEED 15
        MOVE G6A, 100,  66, 145, 103, 100, 100
        MOVE G6D,100,  86, 145,  83, 101, 100
        MOVE G6B,100,  35,  80, 100
        MOVE G6C,100,  35,  80, 100
        WAIT

        SPEED 15
        MOVE G6A,106,  76, 145,  93, 106, 100
        MOVE G6D,100,  86, 125, 103, 100, 100
        MOVE G6B,100,  35,  80, 100
        MOVE G6C,100,  35,  80, 100
        WAIT

        SPEED 15
        MOVE G6D,100,  66, 145, 103, 100, 100
        MOVE G6A,100,  86, 145,  83, 101, 100
        MOVE G6B,100,  35,  80, 100
        MOVE G6C,100,  35,  80, 100
        WAIT

        SPEED 15
        MOVE G6D,106,  76, 145,  93, 106, 100
        MOVE G6A,100,  86, 125, 103, 100, 100
        MOVE G6B,100,  35,  80, 100
        MOVE G6C,100,  35,  80, 100
        WAIT

    NEXT I

    '****************************************

    SPEED 15
    MOVE G6A, 100,  66, 145, 103, 100, 100
    MOVE G6D,100,  86, 145,  83, 101, 100
    MOVE G6B,100,  35,  80, 100
    MOVE G6C,100,  35,  80, 100
    WAIT

    SPEED 15
    MOVE G6A,106,  76, 145,  93, 106, 100
    MOVE G6D,100,  86, 125, 103, 100, 100
    MOVE G6B,100,  35,  80, 100
    MOVE G6C,100,  35,  80, 100
    WAIT

    SPEED 15
    MOVE G6D,100,  66, 145, 103, 100, 100
    MOVE G6A,100,  86, 145,  83, 101, 100
    MOVE G6B,100,  35,  80, 100
    MOVE G6C,100,  35,  80, 100
    WAIT

    SPEED 15
    MOVE G6D,106,  76, 145,  91, 106, 100
    MOVE G6A,100,  86, 125,  97, 100, 100
    MOVE G6B,100,  35,  80, 100
    MOVE G6C,100,  35,  80, 100
    WAIT

    '****************************************

    SPEED 15
    MOVE G6A,100,  76, 145,  93, 100, 100
    MOVE G6D,100,  76, 145,  93, 100, 100
    MOVE G6B,100,  35,  80, 100
    MOVE G6C,100,  35,  80, 100
    WAIT

    GOSUB 자이로OFF

    DELAY 500

    RETURN
    '**********************************************
Lturn90:

    GOSUB 자이로OFF

    GOSUB Leg_motor_mode1

    SPEED 15
    MOVE G6A,95, 104, 145,  65, 105, 100
    MOVE G6D,95,  48, 145,  121, 105, 100
    WAIT

    SPEED 15
    MOVE G6A,90, 104, 145,  65, 105, 100
    MOVE G6D,90,  48, 145,  121, 105, 100
    WAIT

    SPEED 10
    GOSUB 기본자세
    DELAY 500

    GOSUB 자이로ON
    RETURN
    '**********************************************
jiwon:

    GOSUB 자이로OFF
    GOSUB leg_motor_mode1

    SPEED 5
    MOVE G6A,100, 150,  28, 140, 100, 100
    MOVE G6D,100, 150,  28, 140, 100, 100
    MOVE G6B,110,  35,  80, 100, 100, 100
    MOVE G6C,110,  35,  80, 100, 100, 100	
    WAIT
    DELAY 100

    SPEED 5
    MOVE G6A,100, 150,  28, 140, 100, 100
    MOVE G6D,100, 150,  28, 140, 100, 100
    MOVE G6B,160,  35,  80, 100, 100, 100
    MOVE G6C,160,  35,  80, 100, 100, 100	
    WAIT

    SPEED 5
    MOVE G6A, 60, 150,  28, 155, 140, 100
    MOVE G6D, 60, 150,  28, 155, 140, 100
    MOVE G6B,170,  35,  80, 100, 100, 100
    MOVE G6C,170,  35,  80, 100, 100, 100	
    WAIT

    SPEED 5
    MOVE G6A, 60, 162,  30, 162, 145, 100
    MOVE G6D, 60, 162,  30, 162, 145, 100
    MOVE G6B,170,  35, 80, 100, 100, 100
    MOVE G6C,170,  35, 80, 100, 100, 100
    WAIT

    SPEED 1
    MOVE G6A, 65, 157,  40, 162, 155, 100
    MOVE G6D, 65, 157,  40, 162, 155, 100
    MOVE G6B,170,  15, 55, 100, 100, 100
    MOVE G6C,170,  15, 55, 100, 100, 100
    WAIT

    '****************************************************************
    SPEED 5
    MOVE G6A, 60, 162,  30, 162, 145, 100
    MOVE G6D, 60, 162,  30, 162, 145, 100
    MOVE G6B,190,  15, 55, 100, 100, 100
    MOVE G6C,190,  15, 55, 100, 100, 100
    WAIT

    SPEED 5
    MOVE G6A, 60, 150,  28, 155, 140, 100
    MOVE G6D, 60, 150,  28, 155, 140, 100
    MOVE G6B,190,  15,  55, 100, 100, 100
    MOVE G6C,190,  15,  55, 100, 100, 100
    WAIT

    SPEED 5
    MOVE G6A,100, 150,  28, 140, 100, 100
    MOVE G6D,100, 150,  28, 140, 100, 100
    MOVE G6B,190,  15,  55, 100, 100, 100
    MOVE G6C,190,  15,  55, 100, 100, 100
    WAIT
    DELAY 100


    SPEED 7
    MOVE G6A,100,  76, 145,  93, 100, 100
    MOVE G6D,100,  76, 145,  93, 100, 100
    MOVE G6B,190,  15,  55, 100, 160, 100
    MOVE G6C,190,  15,  55, 100, 160, 100
    WAIT

    SPEED 7
    MOVE G6A,100,  76, 145,  93, 100, 100
    MOVE G6D,100,  76, 145,  93, 100, 100
    MOVE G6B,190,  15,  55, 100, 160, 100
    MOVE G6C,190,  15,  55, 100, 160, 100
    WAIT

    DELAY 100
    RETURN
    '***************************************
milkwalkfront: 'minwalk + 우유들기

    GOSUB 자이로ON
    HIGHSPEED SETOFF
    GOSUB All_motor_mode3

    SPEED 15
    MOVE G6A,100,  76, 145,  95, 100, 100
    MOVE G6D,100,  76, 145,  95, 100, 100
    MOVE G6B,165, 15,  55, 100, 160, 100
    MOVE G6C,165,  15,  55, 100, 120, 100
    WAIT

    SPEED 15
    MOVE G6D,105,  76, 145,  95, 106, 100
    MOVE G6A,100,  86, 125, 107, 100, 100
    MOVE G6B,165, 15,  55, 100, 160, 100
    MOVE G6C,165,  15,  55, 100, 120, 100
    WAIT
    '****************************************

    FOR I = 0 TO 3

        SPEED 15
        MOVE G6A, 100,  66, 145, 103, 100, 100
        MOVE G6D,100,  86, 145,  83, 101, 100
        MOVE G6B,165, 15,  55, 100, 160, 100
        MOVE G6C,165,  15,  55, 100, 120, 100
        WAIT

        SPEED 15
        MOVE G6A,106,  76, 145,  93, 106, 100
        MOVE G6D,100,  86, 125, 103, 100, 100
        MOVE G6B,165, 15,  55, 100, 160, 100
        MOVE G6C,165,  15,  55, 100, 120, 100
        WAIT

        SPEED 15
        MOVE G6D,100,  66, 145, 103, 100, 100
        MOVE G6A,100,  86, 145,  83, 101, 100
        MOVE G6B,165, 15,  55, 100, 160, 100
        MOVE G6C,165,  15,  55, 100, 120, 100
        WAIT

        SPEED 15
        MOVE G6D,106,  76, 145,  93, 106, 100
        MOVE G6A,100,  86, 125, 103, 100, 100
        MOVE G6B,165, 15,  55, 100, 160, 100
        MOVE G6C,165,  15,  55, 100, 120, 100
        WAIT

    NEXT I

    '****************************************

    SPEED 15
    MOVE G6A, 100,  66, 145, 103, 100, 100
    MOVE G6D,100,  86, 145,  83, 101, 100
    MOVE G6B,165, 15,  55, 100, 160, 100
    MOVE G6C,165,  15,  55, 100, 120, 100
    WAIT

    SPEED 15
    MOVE G6A,106,  76, 145,  93, 106, 100
    MOVE G6D,100,  86, 125, 103, 100, 100
    MOVE G6B,165, 15,  55, 100, 160, 100
    MOVE G6C,165,  15,  55, 100, 120, 100
    WAIT

    SPEED 15
    MOVE G6D,100,  66, 145, 103, 100, 100
    MOVE G6A,100,  86, 145,  83, 101, 100
    MOVE G6B,165, 15,  55, 100, 160, 100
    MOVE G6C,165,  15,  55, 100, 120, 100
    WAIT

    SPEED 15
    MOVE G6D,106,  76, 145,  91, 106, 100
    MOVE G6A,100,  86, 125,  97, 100, 100
    MOVE G6B,165, 15,  55, 100, 160, 100
    MOVE G6C,165,  15,  55, 100, 120, 100
    WAIT

    '****************************************

    SPEED 15
    MOVE G6A,100,  76, 145,  93, 100, 100
    MOVE G6D,100,  76, 145,  93, 100, 100
    MOVE G6B,165, 15,  55, 100, 160, 100
    MOVE G6C,165,  15,  55, 100, 120, 100
    WAIT

    GOSUB 자이로OFF

    DELAY 500

    RETURN
    '****************************************
jiwondown:

    GOSUB 자이로OFF
    GOSUB leg_motor_mode1

    SPEED 5
    MOVE G6A,100, 150,  28, 140, 100, 100
    MOVE G6D,100, 150,  28, 140, 100, 100
    MOVE G6B,165, 15,  55, 100, 160, 100
    MOVE G6C,165,  15,  55, 100, 120, 100
    WAIT
    DELAY 100

    SPEED 5
    MOVE G6A,100, 150,  28, 140, 100, 100
    MOVE G6D,100, 150,  28, 140, 100, 100
    MOVE G6B,190, 15,  55, 100, 160, 100
    MOVE G6C,190,  15,  55, 100, 120, 100
    WAIT

    SPEED 5
    MOVE G6A, 60, 150,  28, 155, 140, 100
    MOVE G6D, 60, 150,  28, 155, 140, 100
    MOVE G6B,190, 15,  55, 100, 160, 100
    MOVE G6C,190,  15,  55, 100, 120, 100
    WAIT

    SPEED 5
    MOVE G6A, 60, 162,  30, 162, 145, 100
    MOVE G6D, 60, 162,  30, 162, 145, 100
    MOVE G6B,190, 15,  55, 100, 160, 100
    MOVE G6C,190,  15,  55, 100, 120, 100
    WAIT

    SPEED 3
    MOVE G6A, 65, 157,  40, 162, 155, 100
    MOVE G6D, 65, 157,  40, 162, 155, 100
    MOVE G6B,190,  25, 80, 100, 160, 100
    MOVE G6C,190,  25, 80, 100, 120, 100
    WAIT

    '****************************************************************
    SPEED 5
    MOVE G6A, 60, 162,  30, 162, 145, 100
    MOVE G6D, 60, 162,  30, 162, 145, 100
    MOVE G6B,190,  25, 80, 100, 160, 100
    MOVE G6C,190,  25, 80, 100, 120, 100
    WAIT

    SPEED 5
    MOVE G6A, 60, 150,  28, 155, 140, 100
    MOVE G6D, 60, 150,  28, 155, 140, 100
    MOVE G6B,190,  25, 80, 100, 160, 100
    MOVE G6C,190,  25, 80, 100, 120, 100
    WAIT

    SPEED 5
    MOVE G6A,100, 150,  28, 140, 100, 100
    MOVE G6D,100, 150,  28, 140, 100, 100
    MOVE G6B,190,  25, 80, 100, 160, 100
    MOVE G6C,190,  25, 80, 100, 120, 100
    WAIT
    DELAY 100


    SPEED 7
    MOVE G6A,100,  76, 145,  93, 100, 100
    MOVE G6D,100,  76, 145,  93, 100, 100
    MOVE G6B,190,  25, 80, 100, 160, 100
    MOVE G6C,190,  25, 80, 100, 120, 100
    WAIT

    SPEED 7
    MOVE G6A,100,  76, 145,  93, 100, 100
    MOVE G6D,100,  76, 145,  93, 100, 100
    MOVE G6B,100,  35,  80, 100, 160, 100
    MOVE G6C,100,  35,  80, 100, 120, 100
    WAIT

    DELAY 100
    RETURN
    '**************************************************************
SWalk:

    GOSUB 자이로OFF

    GOSUB Leg_motor_mode2
    SPEED 10
    MOVE G6A,100,  76, 145, 102, 100, 100
    MOVE G6D,100,  76, 145,  92, 100, 100
    MOVE G6B,100,  35,  80, 100, 100, 100
    MOVE G6C,100,  35,  80, 100, 120, 100
    WAIT

    MOVE G6A,100,  76, 145,  92, 100, 100
    MOVE G6D,100,  76, 145, 102, 100, 100
    MOVE G6B,100,  35,  80, 100, 100, 100
    MOVE G6C,100,  35,  80, 100, 120, 100
    WAIT

    MOVE G6A,100,  76, 145, 102, 100, 100
    MOVE G6D,100,  76, 145,  92, 100, 100
    MOVE G6B,100,  35,  80, 100, 100, 100
    MOVE G6C,100,  35,  80, 100, 120, 100
    WAIT

    MOVE G6A,100,  76, 145,  92, 100, 100
    MOVE G6D,100,  76, 145, 102, 100, 100
    MOVE G6B,100,  35,  80, 100, 100, 100
    MOVE G6C,100,  35,  80, 100, 120, 100
    WAIT


    SPEED 6
    MOVE G6A,100,  76, 145, 102, 100, 100
    MOVE G6D,100,  76, 145,  92, 100, 100
    MOVE G6B,100,  35,  80, 100, 100, 100
    MOVE G6C,100,  35,  80, 100, 120, 100
    WAIT

    MOVE G6A,100,  76, 145,  92, 100, 100
    MOVE G6D,100,  76, 145, 102, 100, 100
    MOVE G6B,100,  35,  80, 100, 100, 100
    MOVE G6C,100,  35,  80, 100, 120, 100
    WAIT

    MOVE G6A,100,  76, 145, 102, 100, 100
    MOVE G6D,100,  76, 145,  92, 100, 100
    MOVE G6B,100,  35,  80, 100, 100, 100
    MOVE G6C,100,  35,  80, 100, 120, 100
    WAIT

    MOVE G6A,100,  76, 145,  92, 100, 100
    MOVE G6D,100,  76, 145, 102, 100, 100
    MOVE G6B,100,  35,  80, 100, 100, 100
    MOVE G6C,100,  35,  80, 100, 120, 100
    WAIT

    GOSUB 기본자세
    GOSUB 자이로ON
    '3.5번 줄임
    RETURN
    '************************************************

dooropen:

    GOSUB 자이로ON
    HIGHSPEED SETOFF
    GOSUB All_motor_mode3

    SPEED 10
    MOVE G6A,100,  76, 145,  95, 100, 100
    MOVE G6D,100,  76, 145,  95, 100, 100
    MOVE G6B,100,  35,  80, 100, 100, 100
    MOVE G6C,100,  35,  80, 100, 117, 100
    WAIT

    SPEED 10
    MOVE G6A,100,  76, 145,  95, 100, 100
    MOVE G6D,100,  76, 145,  95, 100, 100
    MOVE G6B,180,  35,  80, 100, 100, 100
    MOVE G6C,180,  35,  80, 100, 117, 100
    WAIT

    SPEED 10
    MOVE G6D,108,  76, 145,  80, 104, 100
    MOVE G6A,100,  86, 125, 109, 100, 100
    MOVE G6B,180,  10,  50, 100, 100, 100
    MOVE G6C,180,  10,  60, 100, 117, 100
    WAIT



    '****************************************

    FOR I = 0 TO 10

        SPEED 10
        MOVE G6A, 99,  66, 145, 103, 100, 100
        MOVE G6D,100,  86, 145,  83, 100, 100
        MOVE G6B,180,  10,  50, 100, 100, 100
        MOVE G6C,180,  10,  60, 100, 117, 100
        WAIT

        SPEED 10
        MOVE G6A,108,  76, 145,  93, 104, 100
        MOVE G6D,100,  86, 125, 103, 100, 100
        MOVE G6B,180,  10,  50, 100, 100, 100
        MOVE G6C,180,  10,  60, 100, 117, 100
        WAIT

        SPEED 10
        MOVE G6D,101,  66, 145, 103, 100, 100
        MOVE G6A,100,  86, 145,  83, 100, 100
        MOVE G6B,180,  10,  50, 100, 100, 100
        MOVE G6C,180,  10,  60, 100, 117, 100
        WAIT

        SPEED 10
        MOVE G6D,108,  76, 145,  93, 104, 100
        MOVE G6A,100,  86, 125, 103, 100, 100
        MOVE G6B,180,  10,  50, 100, 100, 100
        MOVE G6C,180,  10,  60, 100, 117, 100
        WAIT

    NEXT I

    '****************************************

    SPEED 10
    MOVE G6A, 99,  66, 145, 103, 100, 100
    MOVE G6D,100,  86, 145,  83, 100, 100
    MOVE G6B,180,  10,  50, 100, 100, 100
    MOVE G6C,180,  10,  60, 100, 117, 100
    WAIT

    SPEED 10
    MOVE G6A,108,  76, 145,  93, 104, 100
    MOVE G6D,100,  86, 125, 103, 100, 100
    MOVE G6B,180,  10,  50, 100, 100, 100
    MOVE G6C,180,  10,  60, 100, 117, 100
    WAIT

    SPEED 10
    MOVE G6D,101,  66, 145, 103, 100, 100
    MOVE G6A,100,  86, 145,  83, 100, 100
    MOVE G6B,180,  10,  50, 100, 100, 100
    MOVE G6C,180,  10,  60, 100, 117, 100
    WAIT

    SPEED 10
    MOVE G6D,108,  76, 145,  91, 104, 100
    MOVE G6A,100,  86, 125,  97, 100, 100
    MOVE G6B,180,  10,  50, 100, 100, 100
    MOVE G6C,180,  10,  60, 100, 117, 100
    WAIT

    '****************************************

    SPEED 10
    MOVE G6A,100,  76, 145,  93, 100, 100
    MOVE G6D,100,  76, 145,  93, 100, 100
    MOVE G6B,180,  10,  50, 100, 100, 100
    MOVE G6C,180,  10,  60, 100, 117, 100
    WAIT

    '***************'''''''''''''''''''''''''    '뒷걸음질 반복
    FOR I=0 TO 2

        '오른쪽기울기
        SPEED 4
        MOVE G6A, 88,  71, 152,  91, 110
        MOVE G6D,108,  76, 146,  93,  94
        MOVE G6B,100,50
        MOVE G6C,100,50
        WAIT

        '왼발들기
        SPEED 10
        MOVE G6A, 90, 95, 115, 105, 114
        MOVE G6D,113,  78, 146,  93,  94
        MOVE G6B,100,50
        MOVE G6C,100,50
        WAIT
        '*************************************************
        GOSUB Leg_motor_mode2
        '오른발중심이동
        SPEED 10
        MOVE G6D,110,  76, 144, 100,  93
        MOVE G6A, 90, 93, 155,  71, 112
        MOVE G6B,100,50
        MOVE G6C,100,50
        WAIT

        GOSUB Leg_motor_mode3
        '오른발뻣어착지
        SPEED 4
        MOVE G6D,90,  46, 163, 110, 114
        MOVE G6A,110,  77, 147,  90,  94
        MOVE G6B,100,50
        MOVE G6C,100,50
        WAIT

        '오른발들기10
        SPEED 10
        MOVE G6A,112,  77, 147,  93, 94
        MOVE G6D,90, 100, 105, 110, 114
        MOVE G6B,100,50
        MOVE G6C,100,50
        WAIT

        GOSUB Leg_motor_mode3

        '왼쪽기울기2
        SPEED 5
        MOVE G6A, 106,  76, 146,  93,  96		
        MOVE G6D,  88,  71, 152,  91, 106
        MOVE G6B, 100,50
        MOVE G6C, 100,50
        WAIT	

    NEXT I
    '****************''''''''''''''''''''''''''''''''''


    SPEED 3
    GOSUB 기본자세

    DELAY 500

    RETURN

    '*****************************************
    '**********************************************
armheaddown:

    SPEED 7
    MOVE G6A,100,  76, 145,  93, 100, 100
    MOVE G6D,100,  76, 145,  93, 100, 100
    MOVE G6B,165, 15,  55, 100, 160, 100
    MOVE G6C,165,  15,  55, 100, 120, 100
    WAIT

    DELAY 100
    RETURN
    '****************************************************************
backstepleft:

    GOSUB 자이로ON
    HIGHSPEED SETOFF
    GOSUB Leg_motor_mode3

    '오른쪽기울기
    SPEED 4
    MOVE G6A, 88,  71, 152,  91, 110
    MOVE G6D,108,  76, 146,  93,  94
    MOVE G6B,100,35
    MOVE G6C,100,35
    WAIT

    '왼발들기
    SPEED 10
    MOVE G6A, 90, 95, 115, 105, 114
    MOVE G6D,113,  78, 146,  93,  94
    MOVE G6B,90
    MOVE G6C,110
    WAIT
    '*************************************************
    GOSUB Leg_motor_mode2
    '오른발중심이동
    SPEED 10
    MOVE G6D,110,  76, 144, 100,  93
    MOVE G6A, 90, 93, 155,  71, 112
    WAIT

    GOSUB Leg_motor_mode3
    '오른발뻣어착지
    SPEED 4
    MOVE G6D,90,  46, 163, 110, 114
    MOVE G6A,110,  77, 147,  90,  94
    WAIT

    '오른발들기10
    SPEED 10
    MOVE G6A,112,  77, 147,  93, 94
    MOVE G6D,90, 100, 105, 110, 114
    MOVE G6B,110
    MOVE G6C,90
    WAIT

    GOSUB Leg_motor_mode3

    '왼쪽기울기2
    SPEED 5
    MOVE G6A, 106,  76, 146,  93,  96		
    MOVE G6D,  88,  71, 152,  91, 106
    MOVE G6B, 100,35
    MOVE G6C, 100,35
    WAIT	


    SPEED 3
    GOSUB 기본자세

    DELAY 500

    RETURN

    '************************************************
backstepright:

    GOSUB 자이로ON
    HIGHSPEED SETOFF
    GOSUB Leg_motor_mode3


    SPEED 4
    MOVE G6D, 88,  71, 152,  91, 110
    MOVE G6A,108,  76, 146,  93,  94
    MOVE G6B,100,35
    MOVE G6C,100,35
    WAIT


    SPEED 10
    MOVE G6D, 90, 95, 115, 105, 114
    MOVE G6A,113,  78, 146,  93,  94
    MOVE G6B,90
    MOVE G6C,110
    WAIT
    '*************************************************
    GOSUB Leg_motor_mode2

    SPEED 10
    MOVE G6A,110,  76, 144, 100,  93
    MOVE G6D, 90, 93, 155,  71, 112
    WAIT

    GOSUB Leg_motor_mode3

    SPEED 4
    MOVE G6A,90,  46, 163, 110, 114
    MOVE G6D,110,  77, 147,  90,  94
    WAIT


    SPEED 10
    MOVE G6D,112,  77, 147,  93, 94
    MOVE G6A,90, 100, 105, 110, 114
    MOVE G6B,110
    MOVE G6C,90
    WAIT

    GOSUB Leg_motor_mode3


    SPEED 5
    MOVE G6D, 106,  76, 146,  93,  96		
    MOVE G6A,  88,  71, 152,  91, 106
    MOVE G6B, 100,35
    MOVE G6C, 100,35
    WAIT	


    SPEED 3
    GOSUB 기본자세

    DELAY 500

    RETURN

    '************************************************
GO_FRONT2:

    GOSUB 자이로ON

    GOSUB All_motor_mode3

    SPEED 4
    '왼쪽기울기
    MOVE G6D, 90,  73, 152,  88, 105
    MOVE G6A,104,  79, 146,  90, 100
    MOVE G6C,100,  35,  80, 100
    MOVE G6B,100,  35,  80, 100, 100, 100
    WAIT

    SPEED 12'보행속도
    '오른발 들기
    MOVE G6D, 83, 98, 115, 104, 111
    MOVE G6A,108,  84, 140,  90,  96
    MOVE G6C,90
    MOVE G6B,110
    WAIT

    SPEED 13
    '오른발뻣어착지
    MOVE G6D, 94,  53, 153, 112,  102
    MOVE G6A,106,  84, 142,  90,  100
    WAIT

    SPEED 5
    '오른발 중심이동
    MOVE G6D,103,  74, 137, 104,  105
    MOVE G6A,95, 88, 150,  75, 100
    WAIT

    SPEED 7
    '왼발들기10
    MOVE G6D,106,  75, 145,  96, 98
    MOVE G6A,95, 87, 118, 110, 103
    MOVE G6C,110
    MOVE G6B,90
    WAIT

    SPEED 5
    MOVE G6A,100,  76, 145,  93, 100, 100
    MOVE G6D,100,  76, 145,  93, 100, 100
    MOVE G6B,100,  35,  80, 100
    MOVE G6C,100,  35,  80, 100
    WAIT

    GOSUB 자이로OFF

    RETURN
    '************************************************
hyunleft: '나중에 다리부분 수정
    MOVE G6A,100,  76, 145,  93, 100, 100
    MOVE G6D,100,  76, 145,  93, 100, 100
    MOVE G6B,100,  35,  80, 100, 100, 60
    MOVE G6C,100,  35,  80, 100, 140, 100
    WAIT
    mode = 0
    RETURN
    '*********************************************
hyunright:
    MOVE G6A,100,  76, 145,  93, 100, 100
    MOVE G6D,100,  76, 145,  93, 100, 100
    MOVE G6B,100,  35,  80, 100, 100, 140
    MOVE G6C,100,  35,  80, 100, 140, 100
    WAIT
    mode = 0
    RETURN
    '**********************************************
kyeongleft: '머리완전 팍 숙인채로 45도 왼쪽
    MOVE G6A,100,  76, 145,  93, 100, 100
    MOVE G6D,100,  76, 145,  93, 100, 100
    MOVE G6B,100,  35,  80, 100, 100, 60
    MOVE G6C,100,  35,  80, 100, 180, 100
    WAIT
    mode = 0
    RETURN
    '*********************************************
kyeongright:
    MOVE G6A,100,  76, 145,  93, 100, 100
    MOVE G6D,100,  76, 145,  93, 100, 100
    MOVE G6B,100,  35,  80, 100, 100, 140
    MOVE G6C,100,  35,  80, 100, 180, 100
    WAIT
    mode = 0
    RETURN
    '*********************************************
hyunfront:
	MOVE G6A,100,  76, 145,  93, 100, 100
    MOVE G6D,100,  76, 145,  93, 100, 100
    MOVE G6B,100,  35,  80, 100, 100, 100
    MOVE G6C,100,  35,  80, 100, 140, 100
    WAIT
    mode = 0
    RETURN
    '*********************************************
kyeongfront:
	MOVE G6A,100,  76, 145,  93, 100, 100
    MOVE G6D,100,  76, 145,  93, 100, 100
    MOVE G6B,100,  35,  80, 100, 100, 100
    MOVE G6C,100,  35,  80, 100, 180, 100
    WAIT
    mode = 0
    RETURN
'************************************************
headright:
    MOVE G6A,100,  76, 145,  93, 100, 100
    MOVE G6D,100,  76, 145,  93, 100, 25
    MOVE G6B,100,  35,  80, 100, 100, 115
    MOVE G6C,100,  35,  80, 100, 110, 100
    WAIT
    mode = 0

    RETURN
    '*********************************************
milkwalkleft:

    SPEED 10
    MOVE G6A, 90,  90, 120, 105, 110, 100
    MOVE G6D,100,  76, 146,  93, 107, 100
    MOVE G6B,190,  15,  55, 100, 160, 100
    MOVE G6C,190,  15,  55, 100, 160, 100
    WAIT

    SPEED 12
    MOVE G6A, 102,  76, 147, 93, 100, 100
    MOVE G6D,83,  78, 140,  96, 115, 100
    MOVE G6B,190,  15,  55, 100, 160, 100
    MOVE G6C,190,  15,  55, 100, 160, 100
    WAIT

    SPEED 10
    MOVE G6A,98,  76, 146,  93, 100, 100
    MOVE G6D,98,  76, 146,  93, 100, 100
    MOVE G6B,190,  15,  55, 100, 160, 100
    MOVE G6C,190,  15,  55, 100, 160, 100
    WAIT


    GOTO MAIN
    '**************************************************
milkwalkright:
    SPEED 10
    MOVE G6D, 90,  90, 120, 105, 110, 100
    MOVE G6A,100,  76, 146,  93, 107, 100
    MOVE G6B,190,  15,  55, 100, 160, 100
    MOVE G6C,190,  15,  55, 100, 160, 100
    WAIT

    SPEED 12
    MOVE G6D, 102,  76, 147, 93, 100, 100
    MOVE G6A,83,  78, 140,  96, 115, 100
    MOVE G6B,190,  15,  55, 100, 160, 100
    MOVE G6C,190,  15,  55, 100, 160, 100
    WAIT

    SPEED 10
    MOVE G6D,98,  76, 146,  93, 100, 100
    MOVE G6A,98,  76, 146,  93, 100, 100
    MOVE G6B,190,  15,  55, 100, 160, 100
    MOVE G6C,190,  15,  55, 100, 160, 100
    WAIT



    GOTO MAIN
    '************************************************
milkSWalk:

    GOSUB 자이로OFF

    GOSUB Leg_motor_mode2
    SPEED 10
    MOVE G6A,100,  76, 145, 102, 100, 100
    MOVE G6D,100,  76, 145,  92, 100, 100
    MOVE G6B,190,  15,  55, 100, 160, 100
    MOVE G6C,190,  15,  55, 100, 160, 100

    MOVE G6A,100,  76, 145,  92, 100, 100
    MOVE G6D,100,  76, 145, 102, 100, 100
    MOVE G6B,190,  15,  55, 100, 160, 100
    MOVE G6C,190,  15,  55, 100, 160, 100
    WAIT

    MOVE G6A,100,  76, 145, 102, 100, 100
    MOVE G6D,100,  76, 145,  92, 100, 100
    MOVE G6B,190,  15,  55, 100, 160, 100
    MOVE G6C,190,  15,  55, 100, 160, 100
    WAIT

    MOVE G6A,100,  76, 145,  92, 100, 100
    MOVE G6D,100,  76, 145, 102, 100, 100
    MOVE G6B,190,  15,  55, 100, 160, 100
    MOVE G6C,190,  15,  55, 100, 160, 100
    WAIT


    SPEED 6
    MOVE G6A,100,  76, 145, 102, 100, 100
    MOVE G6D,100,  76, 145,  92, 100, 100
    MOVE G6B,190,  15,  55, 100, 160, 100
    MOVE G6C,190,  15,  55, 100, 160, 100
    WAIT

    MOVE G6A,100,  76, 145,  92, 100, 100
    MOVE G6D,100,  76, 145, 102, 100, 100
    MOVE G6B,190,  15,  55, 100, 160, 100
    MOVE G6C,190,  15,  55, 100, 160, 100
    WAIT

    MOVE G6A,100,  76, 145, 102, 100, 100
    MOVE G6D,100,  76, 145,  92, 100, 100
    MOVE G6B,190,  15,  55, 100, 160, 100
    MOVE G6C,190,  15,  55, 100, 160, 100
    WAIT

    MOVE G6A,100,  76, 145,  92, 100, 100
    MOVE G6D,100,  76, 145, 102, 100, 100
    MOVE G6B,190,  15,  55, 100, 160, 100
    MOVE G6C,190,  15,  55, 100, 160, 100
    WAIT

    GOSUB 기본자세
    GOSUB 자이로ON
    '3.5번 줄임
    RETURN
    '*****************************************************
woosturnleft: 'JLturn10 수정한것

    GOSUB 자이로OFF

    GOSUB Leg_motor_mode1

    SPEED 15
    MOVE G6D,100,  76, 145,  93, 100, 100
    MOVE G6A,100,  76, 145,  93, 98, 100
    WAIT

    SPEED 8
    MOVE G6D,100,  61, 145,  93, 100, 100
    MOVE G6A,100,  86, 155,  88, 100, 100
    WAIT


    MOVE G6D,100,  76, 145,  93, 100, 100
    MOVE G6A,100,  76, 145,  93, 100, 100
    WAIT

    DELAY 200



    RETURN
    '***************************************************
TurnLeft60:
    SPEED 15
    MOVE G6A,95,  116, 145,  53, 105, 100
    MOVE G6D,95,  36, 145,  133, 105, 100
    WAIT

    SPEED 15
    MOVE G6A,90,  116, 145,  53, 105, 100
    MOVE G6D,90,  36, 145,  133, 105, 100
    WAIT

    SPEED 10
    GOSUB 기본자세
    GOTO MAIN
    '***************************************************
TurnRight60:
    SPEED 15
    MOVE G6A,95,  36, 145,  133, 105, 100
    MOVE G6D,95,  116, 145,  53, 105, 100
    WAIT

    SPEED 15
    MOVE G6A,90,  36, 145,  133, 105, 100
    MOVE G6D,90,  116, 145,  53, 105, 100

    WAIT

    SPEED 10
    GOSUB 기본자세
    GOTO MAIN
    '***************************************************
LWalk:

    GOSUB 자이로OFF

    GOSUB Leg_motor_mode2

    SPEED 12
    MOVE G6A, 93,  88, 125, 104, 104, 100
    MOVE G6D,103,  76, 145,  96, 104, 100
    WAIT

    SPEED 12
    MOVE G6A, 102,  78, 145, 94, 100, 100
    MOVE G6D,90,  80, 140,  96, 107, 100
    WAIT

    SPEED 15
    MOVE G6A,98,  76, 145,  93, 102, 100
    MOVE G6D,98,  76, 145,  93, 102, 100
    WAIT

    SPEED 8
    MOVE G6A,100,  76, 145,  93, 100, 100
    MOVE G6D,100,  76, 145,  93, 100, 100
    WAIT
    RETURN

    '**********************************************
RWalk:
    GOSUB 자이로OFF

    GOSUB Leg_motor_mode2

    SPEED 12
    MOVE G6D, 93,  86, 125, 102, 104, 100
    MOVE G6A,103,  76, 145,  96, 103, 100
    WAIT

    SPEED 12
    MOVE G6D, 102,  78, 145, 94, 100, 100
    MOVE G6A,90,  80, 140,  96, 107, 100
    WAIT

    SPEED 15
    MOVE G6D,98,  76, 145,  93, 102, 100
    MOVE G6A,98,  76, 145,  93, 102, 100
    WAIT

    SPEED 8
    MOVE G6D,100,  76, 145,  93, 100, 100
    MOVE G6A,100,  76, 145,  93, 100, 100
    WAIT

    RETURN
    '**********************************************



MAIN: '라벨설정

    '**** 입력된 A값이 0 이면 MAIN 라벨로 가고
    '**** 1이면 KEY1 라벨, 2이면 key2로... 가는문

    'GOSUB 전압체크
    ' GOSUB 앞뒤기울기측정
    '  GOSUB 좌우기울기측정

    IF 모터ONOFF = 1  THEN
        DELAY 200
        OUT 52,0
        DELAY 200
    ENDIF

    ERX 4800,A,MAIN	'
    'A = REMOCON(1)

    A_old = A

MAIN2:

    ON A GOTO MAIN,KEY1,KEY2,KEY3,KEY4,KEY5,KEY6,KEY7,KEY8,KEY9,KEY10,KEY11,KEY12,KEY13,KEY14,KEY15,KEY16,KEY17,KEY18 ,KEY19,KEY20,KEY21,KEY22,KEY23,KEY24,KEY25,KEY26,KEY27, KEY28, KEY29, KEY30, KEY31, KEY32, KEY33, KEY34, KEY35, KEY36, KEY37, KEY38, KEY39, KEY40, KEY41, KEY42, KEY43

    GOTO MAIN	
    '*******************************************
    '		MAIN 라벨로 가기
    '*******************************************

KEY1:
    ETX  4800,1
    GOSUB EAST
    GOTO RX_EXIT
KEY2:
    ETX  4800,2
    GOSUB WEST
    GOTO RX_EXIT

KEY3:
    ETX  4800,3
    GOSUB SOUTH
    GOTO RX_EXIT

KEY4:
    ETX  4800,4
    GOSUB NORTH
    GOTO RX_EXIT

KEY5:
    ETX  4800,5
    GOSUB 기본자세
    GOTO RX_EXIT

KEY6:
    ETX  4800,6
    GOSUB MinWalk1
    GOTO RX_EXIT

KEY7:
    ETX  4800,7
    GOSUB jiwon
    GOTO RX_EXIT

KEY8:
    ETX  4800,8
    GOSUB milkwalkfront
    GOTO RX_EXIT

KEY9:
    ETX  4800,9
    GOSUB jiwondown
    GOTO RX_EXIT

KEY10: '0
    ETX  4800,10
    GOSUB dooropen
    GOTO RX_EXIT

KEY11: ' ▲
    ETX  4800,11
    GOSUB WooWalk2
    GOTO RX_EXIT

KEY12: ' ▼
    ETX  4800,12
    GOSUB backstepleft
    GOTO RX_EXIT
KEY13: '▶
    ETX  4800,13
    GOSUB Rwalk
    GOTO RX_EXIT

KEY14: ' ◀
    ETX  4800,14
    GOSUB Lwalk
    GOTO RX_EXIT

KEY15: ' A
    ETX  4800,15
    GOSUB TurnLeft60
    GOTO RX_EXIT

KEY16: ' POWER
    ETX  4800,16
    GOSUB hyunleft
    GOTO RX_EXIT

KEY17: ' C
    ETX  4800,17
    GOSUB hyunright	
    GOTO RX_EXIT

KEY18: ' E
    ETX  4800,18	
    GOSUB kyeongleft
    GOTO RX_EXIT

KEY19: ' P2
    ETX  4800,19
    GOSUB kyeongright
    GOTO RX_EXIT

KEY20: ' B	
    ETX  4800,20
    GOSUB TurnRight60
    GOTO RX_EXIT

KEY21: ' △
    ETX  4800,21
    GOSUB milkwalkright
    GOTO RX_EXIT

KEY22: ' *
    ETX  4800,22
    GOSUB milkSWalk
    GOTO RX_EXIT

KEY23: ' G
    ETX  4800,23
    GOSUB woosturnleft
    GOTO RX_EXIT

KEY24: ' #
    ETX  4800,24
    GOSUB armheaddown
    GOTO RX_EXIT

KEY25: ' P1
    ETX  4800,25
    GOSUB TurnRight60
    GOTO RX_EXIT

KEY26: ' ■
    ETX  4800,26
    GOSUB GO_FRONT2
    GOTO RX_EXIT

KEY27: ' D
    ETX  4800,27
    GOSUB Woowalk2
    GOTO RX_EXIT

KEY28: ' ◁
    ETX  4800,28
    GOSUB SWalk
    GOTO RX_EXIT

KEY29: ' □
    ETX  4800,29
    GOSUB Lturn90
    GOTO RX_EXIT

KEY30: ' ▷
    ETX  4800,30
    GOSUB TurnRight60
    GOTO RX_EXIT

KEY31: ' ▽
    ETX  4800,31
    GOSUB Lwalk
    GOTO RX_EXIT

KEY32: ' F
    ETX  4800,32
    GOSUB Rwalk
    GOTO RX_EXIT

KEY33: '
    ETX  4800,33
    GOSUB hyunfront
    GOTO RX_EXIT

KEY34: '
    ETX  4800,34
    GOSUB kyeongfront
    GOTO RX_EXIT

KEY35: '
    ETX  4800,35
    GOSUB SWalk
    GOTO RX_EXIT

KEY36: '
    ETX  4800,36
    GOSUB SWalk
    GOTO RX_EXIT

KEY37: '
    ETX  4800,37
    GOSUB SWalk
    GOTO RX_EXIT

KEY38: '
    ETX  4800,38
    GOSUB SWalk
    GOTO RX_EXIT

KEY39: '
    ETX  4800,39
    GOSUB SWalk
    GOTO RX_EXIT

KEY40: '
    ETX  4800,40
    GOSUB SWalk
    GOTO RX_EXIT

KEY41: '
    ETX  4800,41
    GOSUB SWalk
    GOTO RX_EXIT

KEY42: '
    ETX  4800,42
    GOSUB SWalk
    GOTO RX_EXIT

KEY43: '
    ETX  4800,43
    GOSUB SWalk
    GOTO RX_EXIT


    END
