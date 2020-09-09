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

SPEED 5
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
    MOVE G6D,100,  76, 145,  93, 100, 100
    MOVE G6B,100,  35,  80, 100, 100, 100
    MOVE G6C,100,  35,  80, 100, 110, 100
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
youngjin:

    GOSUB 자이로OFF
    GOSUB leg_motor_mode1




    SPEED 5
    MOVE G6A,100, 150,  28, 140, 100, 100
    MOVE G6D,100, 150,  28, 140, 100, 100
    MOVE G6B,12,  185,  85, 100, 100, 100
    MOVE G6C,12,  185,  85, 100, 100, 100
    WAIT
    DELAY 100

    SPEED 5
    MOVE G6A, 60, 150,  28, 155, 140, 100
    MOVE G6D, 60, 150,  28, 155, 140, 100
    MOVE G6B,12,  185,  90, 100, 100, 100
    MOVE G6C,12,  185,  90, 100, 100, 100
    WAIT

    SPEED 5
    MOVE G6A, 60, 162,  30, 162, 145, 100
    MOVE G6D, 60, 162,  30, 162, 145, 100
    MOVE G6B,12,  185, 90, 100, 100, 100
    MOVE G6C,12,  185, 90, 100, 100, 100
    WAIT

    SPEED 1
    MOVE G6A, 65, 157,  40, 162, 155, 100
    MOVE G6D, 65, 157,  40, 162, 155, 100
    MOVE G6B,12,  185, 140, 100, 100, 100
    MOVE G6C,12,  185, 140, 100, 100, 100
    WAIT

    '****************************************************************
    SPEED 5
    MOVE G6A, 60, 162,  30, 162, 145, 100
    MOVE G6D, 60, 162,  30, 162, 145, 100
    MOVE G6B,12,  185, 140, 100, 100, 100
    MOVE G6C,12,  185, 140, 100, 100, 100
    WAIT

    SPEED 5
    MOVE G6A, 60, 150,  28, 155, 140, 100
    MOVE G6D, 60, 150,  28, 155, 140, 100
    MOVE G6B,12,  185,  140, 100, 100, 100
    MOVE G6C,12,  185,  140, 100, 100, 100
    WAIT

    SPEED 5
    MOVE G6A,100, 150,  28, 140, 100, 100
    MOVE G6D,100, 150,  28, 140, 100, 100
    MOVE G6B,12,  185,  140, 100, 100, 100
    MOVE G6C,12,  185,  140, 100, 100, 100
    WAIT
    DELAY 100


    SPEED 7
    MOVE G6A,100,  76, 145,  93, 100, 100
    MOVE G6D,100,  76, 145,  93, 100, 100
    MOVE G6B,12,  185,  140, 100, 160, 100
    MOVE G6C,12,  185,  140, 100, 160, 100
    WAIT

    SPEED 7
    MOVE G6A,100,  76, 145,  93, 100, 100
    MOVE G6D,100,  76, 145,  93, 100, 100
    MOVE G6B,90,  185,  140, 100, 160, 100
    MOVE G6C,90,  185,  140, 100, 160, 100
    WAIT

    DELAY 100
    RETURN
    '****************************************************************
milkdown: '걸어간 다음

    SPEED 7
    MOVE G6A,100,  150, 28,  140, 100, 100
    MOVE G6D,100,  150, 28,  140, 100, 100
    MOVE G6B,90,  185,  140, 100, 160, 100
    MOVE G6C,90,  185,  140, 100, 160, 100   'sit
    WAIT

    SPEED 7
    MOVE G6A,100,  150, 28,  140, 100, 100
    MOVE G6D,100,  150, 28,  140, 100, 100
    MOVE G6B,12,  185,  140, 100, 160, 100
    MOVE G6C,12,  185,  140, 100, 160, 100
    WAIT


    SPEED 7
    MOVE G6A,100,  150, 28,  140, 100, 100
    MOVE G6D,100,  150, 28,  140, 100, 100
    MOVE G6B,65,  95,  140, 100, 160, 100    'throw
    MOVE G6C,65,  95,  140, 100, 160, 100
    WAIT

    MOVE G6A,100,  150, 28,  140, 100, 100
    MOVE G6D,100,  150, 28,  140, 100, 100
    MOVE G6B,100,  35,  80, 100, 100, 100
    MOVE G6C,100,  35,  80, 100, 117, 100   'arm 정상응
    WAIT

    MOVE G6A,100,  76, 145,  93, 100, 100
    MOVE G6D,100,  76, 145,  93, 100, 100
    MOVE G6B,100,  35,  80, 100, 100, 100   'standup
    MOVE G6C,100,  35,  80, 100, 117, 100
    WAIT

    DELAY 100
    RETURN
    '**********************************************`
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

    FOR I = 0 TO 12

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

    GOSUB 자이로OFF

    DELAY 500

    RETURN
    '**********************************************
    '**********************************************
집고왼쪽턴10:

    SPEED 5
    MOVE G6A,97,  86, 145,  75, 103, 100
    MOVE G6D,97,  66, 145,  95, 103, 100
    WAIT

    SPEED 12
    MOVE G6A,94,  86, 145,  75, 101, 100
    MOVE G6D,94,  66, 145,  95, 101, 100
    WAIT

    SPEED 6
    MOVE G6A,101,  76, 146,  85, 98, 100
    MOVE G6D,101,  76, 146,  85, 98, 100
    WAIT

    MOVE G6A,100,  76, 145,  85, 100
    MOVE G6D,100,  76, 145,  85, 100
    WAIT
    GOTO RX_EXIT
    '**********************************************
집고오른쪽턴10:

    SPEED 5
    MOVE G6A,97,  66, 145,  95, 103, 100
    MOVE G6D,97,  86, 145,  75, 103, 100
    WAIT

    SPEED 12
    MOVE G6A,94,  66, 145,  95, 101, 100
    MOVE G6D,94,  86, 145,  75, 101, 100
    WAIT
    SPEED 6
    MOVE G6A,101,  76, 146,  85, 98, 100
    MOVE G6D,101,  76, 146,  85, 98, 100
    WAIT

    MOVE G6A,100,  76, 145,  85, 100
    MOVE G6D,100,  76, 145,  85, 100
    WAIT
    GOTO RX_EXIT
    '**********************************************
    '**********************************************
집고왼쪽턴20:

    GOSUB Leg_motor_mode2
    SPEED 8
    MOVE G6A,95,  96, 145,  65, 105, 100
    MOVE G6D,95,  56, 145,  105, 105, 100
    WAIT

    SPEED 12
    MOVE G6A,93,  96, 145,  65, 105, 100
    MOVE G6D,93,  56, 145,  105, 105, 100
    WAIT
    SPEED 6
    MOVE G6A,101,  76, 146,  85, 98, 100
    MOVE G6D,101,  76, 146,  85, 98, 100
    WAIT

    MOVE G6A,100,  76, 145,  85, 100
    MOVE G6D,100,  76, 145,  85, 100
    WAIT
    GOSUB Leg_motor_mode1
    GOTO RX_EXIT
    '**********************************************
집고오른쪽턴20:

    GOSUB Leg_motor_mode2
    SPEED 8
    MOVE G6A,95,  56, 145,  105, 105, 100
    MOVE G6D,95,  96, 145,  65, 105, 100
    WAIT

    SPEED 12
    MOVE G6A,93,  56, 145,  105, 105, 100
    MOVE G6D,93,  96, 145,  65, 105, 100
    WAIT

    SPEED 6
    MOVE G6A,101,  76, 146,  85, 98, 100
    MOVE G6D,101,  76, 146,  85, 98, 100
    WAIT

    MOVE G6A,100,  76, 145,  85, 100
    MOVE G6D,100,  76, 145,  85, 100
    WAIT

    GOSUB Leg_motor_mode1
    GOTO RX_EXIT
    '**********************************************
집고왼쪽턴45:

    GOSUB Leg_motor_mode2
    SPEED 8
    MOVE G6A,95,  106, 145,  55, 105, 100
    MOVE G6D,95,  46, 145,  115, 105, 100
    WAIT

    SPEED 10
    MOVE G6A,93,  106, 145,  55, 105, 100
    MOVE G6D,93,  46, 145,  115, 105, 100
    WAIT

    SPEED 8
    MOVE G6A,100,  76, 145,  85, 100
    MOVE G6D,100,  76, 145,  85, 100
    WAIT
    GOSUB Leg_motor_mode1
    GOTO RX_EXIT

    '**********************************************
집고오른쪽턴45:

    GOSUB Leg_motor_mode2
    SPEED 8
    MOVE G6A,95,  46, 145,  115, 105, 100
    MOVE G6D,95,  106, 145,  55, 105, 100
    WAIT

    SPEED 10
    MOVE G6A,93,  46, 145,  115, 105, 100
    MOVE G6D,93,  106, 145,  55, 105, 100
    WAIT

    SPEED 8
    MOVE G6A,100,  76, 145,  85, 100
    MOVE G6D,100,  76, 145,  85, 100
    WAIT
    GOSUB Leg_motor_mode1
    GOTO RX_EXIT
    '**********************************************
집고왼쪽턴60:

    SPEED 15
    MOVE G6A,95,  116, 145,  45, 105, 100
    MOVE G6D,95,  36, 145,  125, 105, 100
    WAIT

    SPEED 15
    MOVE G6A,90,  116, 145,  45, 105, 100
    MOVE G6D,90,  36, 145,  125, 105, 100
    WAIT

    SPEED 10
    MOVE G6A,100,  76, 145,  85, 100
    MOVE G6D,100,  76, 145,  85, 100
    WAIT
    GOTO RX_EXIT

    '**********************************************
집고오른쪽턴60:

    SPEED 15
    MOVE G6A,95,  36, 145,  125, 105, 100
    MOVE G6D,95,  116, 145,  45, 105, 100
    WAIT

    SPEED 15
    MOVE G6A,90,  36, 145,  125, 105, 100
    MOVE G6D,90,  116, 145,  45, 105, 100
    WAIT

    SPEED 10
    MOVE G6A,100,  76, 145,  85, 100
    MOVE G6D,100,  76, 145,  85, 100
    WAIT
    GOTO RX_EXIT

    '************************************************
    '**********************************************************
    '한쪽다리 들기
    SPEED 10
    MOVE G6A,102,  40, 170, 155, 100, 100
    MOVE G6D,100,  56, 124,  26, 100, 100
    MOVE G6B,182,  37,  72                   ''
    MOVE G6C,180,  37,  72,    ,  190  '구를때 방향
    WAIT

    DELAY 200
    DELAY 200


    '**********************************************************
    '양쪽다리들기
    SPEED 10
    MOVE G6D,100,  40, 110,  20, 100, 100
    MOVE G6A,100,  35, 110,  20, 100, 100     '16
    MOVE G6B,188,  37,  72                     ''
    MOVE G6C,187,  37,  72,    ,  190  '구를때 방향
    WAIT

    DELAY 150

    '팔뒤로 뻣어서 일어나려고 노력하기

    SPEED 10
    MOVE G6A,100, 108, 75,  55, 100, 100
    MOVE G6D,100, 109, 70,  56, 100, 100
    MOVE G6B,188, 174, 118
    MOVE G6C,185, 174, 118
    WAIT

    DELAY 400

    '*******



    ''일어나기

    SPEED 8
    MOVE G6A,100, 108, 85,  58, 100, 100
    MOVE G6D,100, 108, 85,  58, 100, 100
    MOVE G6B,188, 174, 118
    MOVE G6C,188, 174, 118
    WAIT

    SPEED 10
    MOVE G6A,100, 170,  73, 15, 100, 100
    MOVE G6D,100, 170,  73, 15, 100, 100
    MOVE G6B,188, 178, 120
    MOVE G6C,188, 178, 120,   , 190
    WAIT

    SPEED 10
    MOVE G6A,100, 170,  72, 15, 100, 100
    MOVE G6D,100, 170,  72, 15, 100, 100
    MOVE G6B,188,  40,  60
    MOVE G6C,188,  40,  60
    WAIT

    SPEED 8
    MOVE G6A,100, 162,  32,  115, 100, 100
    MOVE G6D,100, 162,  32,  115, 100, 100
    MOVE G6B,188,  40,  60
    MOVE G6C,188,  40,  60
    WAIT

    SPEED 7
    GOSUB 기본자세

    DELAY 500

    HIGHSPEED SETOFF
    GOSUB 자이로OFF
    GOSUB All_motor_mode2



    GOSUB All_motor_mode3

    SPEED 5
    MOVE G6A,100,  76, 145,  93, 100, 100
    MOVE G6D,100,  76, 145,  93, 100, 100
    MOVE G6B,100,  35,  80, 100
    MOVE G6C,100,  35,  80, 100
    WAIT

    '***************Turn*******************

    GOSUB 자이로OFF

    DELAY 500

    GOSUB Leg_motor_mode1

    SPEED 15
    MOVE G6A,95,  103, 145,  66, 105, 100
    MOVE G6D,95,  49, 145,  120, 105, 100
    WAIT

    SPEED 15
    MOVE G6A,90,  103, 145,  66, 105, 100
    MOVE G6D,90,  49, 145,  120, 105, 100
    WAIT

    SPEED 10
    GOSUB 기본자세


    DELAY 500

    GOSUB Leg_motor_mode1

    SPEED 15
    MOVE G6A,95,  103, 145,  66, 105, 100
    MOVE G6D,95,  49, 145,  120, 105, 100
    WAIT

    SPEED 15
    MOVE G6A,90,  103, 145,  66, 105, 100
    MOVE G6D,90,  49, 145,  120, 105, 100
    WAIT

    SPEED 10
    GOSUB 기본자세


    RETURN
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
    '**********************************************
CamTurn:
    HIGHSPEED SETON

    GOSUB 자이로OFF

    SPEED 15
    MOVE G6A,100,  76, 145,  93, 100, 100
    MOVE G6D,100,  76, 145,  93, 100, 100
    MOVE G6B,100,  35,  80, 100, 100, 190
    MOVE G6C, 10,  35,  80, 100, 135, 100
    WAIT
    HIGHSPEED SETOFF
    RETURN
    '**********************************************
CamDown:
    SPEED 15
    MOVE G6A,100,  76, 145,  93, 100, 100
    MOVE G6D,100,  76, 145,  93, 100, 100
    MOVE G6B,100,  35,  80, 100, 100, 100
    MOVE G6C,100,  35,  80, 100, 180, 100
    WAIT
    RETURN
    '**********************************************
CamDown2:
    GOSUB 자이로OFF

    SPEED 15
    MOVE G6A,100,  76, 145,  93, 100, 100
    MOVE G6D,100,  76, 145,  93, 100, 100
    MOVE G6B,100,  35,  80, 100, 100, 100
    MOVE G6C,100,  35,  80, 100, 145, 100
    WAIT
    RETURN
    '**********************************************
CamDown_Blue:
    GOSUB 자이로OFF

    SPEED 15
    MOVE G6A,100,  76, 145,  93, 100, 100
    MOVE G6D,100,  76, 145,  93, 100, 100
    MOVE G6B,100,  35,  80, 100, 100, 100
    MOVE G6C,100,  35,  80, 100, 132, 100
    WAIT
    RETURN
    '**********************************************
CamDown_Orange:
    GOSUB 자이로OFF

    SPEED 15
    MOVE G6A,100,  76, 145,  93, 100, 100
    MOVE G6D,100,  76, 145,  93, 100, 100
    MOVE G6B,100,  35,  80, 100, 100, 100
    MOVE G6C,100,  35,  80, 100, 155, 100
    WAIT
    RETURN
    '**********************************************
CamDown_Bomb:
    GOSUB 자이로OFF

    SPEED 15
    MOVE G6A,100,  76, 145,  93, 100, 100
    MOVE G6D,100,  76, 145,  93, 100, 100
    MOVE G6B,100,  35,  80, 100, 100, 100
    MOVE G6C,100,  35,  80, 100, 160, 100
    WAIT
    RETURN
    '**********************************************
ReturnCam:
    HIGHSPEED SETON
    SPEED 15
    MOVE G6A,100,  76, 145,  93, 100, 100
    MOVE G6D,100,  76, 145,  93, 100, 100
    MOVE G6B,100,  35,  80, 100, 100, 100
    MOVE G6C,100,  35,  80, 100, 117, 100
    WAIT
    HIGHSPEED SETOFF
    RETURN
    '******************************************
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
    '**********************************************
WooWalk3:
    GOSUB 자이로ON
    HIGHSPEED SETOFF
    GOSUB All_motor_mode3

    SPEED 15
    MOVE G6A,100,  76, 145,  95, 100, 100
    MOVE G6D,100,  76, 145,  95, 100, 100
    MOVE G6B,100,  35,  80, 100, 100, 100
    MOVE G6C,100,  35,  80, 100, 117, 100
    WAIT

    SPEED 15
    MOVE G6D,108,  76, 145,  95, 104, 100
    MOVE G6A,100,  86, 125, 109, 100, 100
    MOVE G6B,100,  35,  80, 100, 100, 100
    MOVE G6C,100,  35,  80, 100, 117, 100
    WAIT

    '****************************************

    FOR I = 0 TO 4

        SPEED 15
        MOVE G6A, 99,  66, 145, 103, 100, 100
        MOVE G6D,100,  86, 145,  83, 100, 100
        MOVE G6B,100,  35,  80, 100, 100, 100
        MOVE G6C,100,  35,  80, 100, 117, 100
        WAIT

        SPEED 15
        MOVE G6A,108,  76, 145,  93, 104, 100
        MOVE G6D,100,  86, 125, 103, 100, 100
        MOVE G6B,100,  35,  80, 100, 100, 100
        MOVE G6C,100,  35,  80, 100, 117, 100
        WAIT

        SPEED 15
        MOVE G6D,101,  66, 145, 103, 100, 100
        MOVE G6A,100,  86, 145,  83, 100, 100
        MOVE G6B,100,  35,  80, 100, 100, 100
        MOVE G6C,100,  35,  80, 100, 117, 100
        WAIT

        SPEED 15
        MOVE G6D,108,  76, 145,  93, 104, 100
        MOVE G6A,100,  86, 125, 103, 100, 100
        MOVE G6B,100,  35,  80, 100, 100, 100
        MOVE G6C,100,  35,  80, 100, 117, 100
        WAIT

    NEXT I

    '****************************************

    SPEED 15
    MOVE G6A, 99,  66, 145, 103, 100, 100
    MOVE G6D,100,  86, 145,  83, 100, 100
    MOVE G6B,100,  35,  80, 100, 100, 100
    MOVE G6C,100,  35,  80, 100, 117, 100
    WAIT

    SPEED 15
    MOVE G6A,108,  76, 145,  93, 104, 100
    MOVE G6D,100,  86, 125, 103, 100, 100
    MOVE G6B,100,  35,  80, 100, 100, 100
    MOVE G6C,100,  35,  80, 100, 117, 100
    WAIT

    SPEED 15
    MOVE G6D,101,  66, 145, 103, 100, 100
    MOVE G6A,100,  86, 145,  83, 100, 100
    MOVE G6B,100,  35,  80, 100, 100, 100
    MOVE G6C,100,  35,  80, 100, 117, 100
    WAIT

    SPEED 15
    MOVE G6D,108,  76, 145,  91, 104, 100
    MOVE G6A,100,  86, 125,  97, 100, 100
    MOVE G6B,100,  35,  80, 100, 100, 100
    MOVE G6C,100,  35,  80, 100, 117, 100
    WAIT

    '****************************************

    SPEED 15
    MOVE G6A,100,  76, 145,  93, 100, 100
    MOVE G6D,100,  76, 145,  93, 100, 100
    MOVE G6B,100,  35,  80, 100, 100, 100
    MOVE G6C,100,  35,  80, 100, 117, 100
    WAIT

    GOSUB 자이로OFF

    DELAY 700

    RETURN
    '**********************************************
WooWalk4:
    GOSUB 자이로ON
    HIGHSPEED SETOFF
    GOSUB All_motor_mode3

    SPEED 15
    MOVE G6A,100,  76, 145,  95, 100, 100
    MOVE G6D,100,  76, 145,  95, 100, 100
    MOVE G6B,100,  35,  80, 100, 100, 100
    MOVE G6C,100,  35,  80, 100, 117, 100
    WAIT

    SPEED 15
    MOVE G6D,108,  76, 145,  95, 104, 100
    MOVE G6A,100,  86, 125, 109, 100, 100
    MOVE G6B,100,  35,  80, 100, 100, 100
    MOVE G6C,100,  35,  80, 100, 117, 100
    WAIT

    '****************************************

    FOR I = 0 TO 6

        SPEED 15
        MOVE G6A, 99,  66, 145, 103, 100, 100
        MOVE G6D,100,  86, 145,  83, 100, 100
        MOVE G6B,100,  35,  80, 100, 100, 100
        MOVE G6C,100,  35,  80, 100, 117, 100
        WAIT

        SPEED 15
        MOVE G6A,108,  76, 145,  93, 104, 100
        MOVE G6D,100,  86, 125, 103, 100, 100
        MOVE G6B,100,  35,  80, 100, 100, 100
        MOVE G6C,100,  35,  80, 100, 117, 100
        WAIT

        SPEED 15
        MOVE G6D,101,  66, 145, 103, 100, 100
        MOVE G6A,100,  86, 145,  83, 100, 100
        MOVE G6B,100,  35,  80, 100, 100, 100
        MOVE G6C,100,  35,  80, 100, 117, 100
        WAIT

        SPEED 15
        MOVE G6D,108,  76, 145,  93, 104, 100
        MOVE G6A,100,  86, 125, 103, 100, 100
        MOVE G6B,100,  35,  80, 100, 100, 100
        MOVE G6C,100,  35,  80, 100, 117, 100
        WAIT

    NEXT I

    '****************************************

    SPEED 15
    MOVE G6A, 99,  66, 145, 103, 100, 100
    MOVE G6D,100,  86, 145,  83, 100, 100
    MOVE G6B,100,  35,  80, 100, 100, 100
    MOVE G6C,100,  35,  80, 100, 117, 100
    WAIT

    SPEED 15
    MOVE G6A,108,  76, 145,  93, 104, 100
    MOVE G6D,100,  86, 125, 103, 100, 100
    MOVE G6B,100,  35,  80, 100, 100, 100
    MOVE G6C,100,  35,  80, 100, 117, 100
    WAIT

    SPEED 15
    MOVE G6D,101,  66, 145, 103, 100, 100
    MOVE G6A,100,  86, 145,  83, 100, 100
    MOVE G6B,100,  35,  80, 100, 100, 100
    MOVE G6C,100,  35,  80, 100, 117, 100
    WAIT

    SPEED 15
    MOVE G6D,108,  76, 145,  91, 104, 100
    MOVE G6A,100,  86, 125,  97, 100, 100
    MOVE G6B,100,  35,  80, 100, 100, 100
    MOVE G6C,100,  35,  80, 100, 117, 100
    WAIT

    '****************************************

    SPEED 15
    MOVE G6A,100,  76, 145,  93, 100, 100
    MOVE G6D,100,  76, 145,  93, 100, 100
    MOVE G6B,100,  35,  80, 100, 100, 100
    MOVE G6C,100,  35,  80, 100, 117, 100
    WAIT

    GOSUB 자이로OFF

    DELAY 700

    RETURN
    '*********************************************
Woo_Slide:
    HIGHSPEED SETOFF
    GOSUB 자이로OFF
    GOSUB All_motor_mode2

    FOR I = 0 TO 4

        SPEED 7
        MOVE G6A,100,  76, 145,  96, 103, 100
        MOVE G6D,100,  76, 140, 101, 100, 100
        MOVE G6B,100,  35,  80, 100
        MOVE G6C,100,  35,  80, 100
        WAIT

        SPEED 7
        MOVE G6A,100,  81, 145,  91, 101, 100
        MOVE G6D,100,  71, 145, 101, 100, 100
        MOVE G6B,100,  35,  80, 100
        MOVE G6C,100,  35,  80, 100
        WAIT

        SPEED 7
        MOVE G6D,100,  76, 145,  96, 102, 100
        MOVE G6A,100,  76, 140, 101, 101, 100
        MOVE G6B,100,  35,  80, 100
        MOVE G6C,100,  35,  80, 100
        WAIT

        SPEED 7
        MOVE G6D,100,  81, 145,  91, 100, 100
        MOVE G6A,100,  71, 145, 101, 101, 100
        MOVE G6B,100,  35,  80, 100
        MOVE G6C,100,  35,  80, 100
        WAIT

    NEXT I

    GOSUB 기본자세

    DELAY 150

    GOSUB All_motor_mode3

    RETURN
    '******************************************
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
GO_FRONT4:

    GOSUB 자이로ON

    GOSUB All_motor_mode3

    SPEED 4
    '오른쪽기울기
    MOVE G6A, 88,  71, 152,  91, 110
    MOVE G6D,106,  76, 146,  93,  96
    MOVE G6B,100,  35,  80, 100
    MOVE G6C,100,  35,  80, 100
    WAIT

    SPEED 10'보행속도
    '왼발들기
    MOVE G6A, 90, 97, 115, 105, 114
    MOVE G6D,110,  79, 146,  93,  90
    MOVE G6B,90
    MOVE G6C,110
    WAIT

    SPEED 12
    '왼발뻣어착지
    MOVE G6A, 85,  47, 163, 113, 114
    MOVE G6D,110,  77, 146,  93,  94
    WAIT

    SPEED 5
    '왼발중심이동
    MOVE G6A,110,  76, 144, 100,  93
    MOVE G6D,85, 93, 155,  71, 112
    WAIT

    SPEED 12
    '오른발들기10
    MOVE G6A,111,  78, 145,  93, 94
    MOVE G6D,90, 105, 105, 110, 114
    MOVE G6B,110
    MOVE G6C,90
    WAIT

    SPEED 12
    '오른발뻣어착지
    MOVE G6D,86,  37, 163, 113, 114
    MOVE G6A,110,  77, 146,  93,  93
    WAIT

    SPEED 5
    '오른발중심이동
    MOVE G6D,110,  76, 144, 100,  93
    MOVE G6A, 85, 93, 155,  71, 112
    WAIT

    SPEED 12
    '왼발들기10
    MOVE G6A, 90, 102, 105, 110, 114
    MOVE G6D,110,  75, 146,  93,  94
    MOVE G6B, 90
    MOVE G6C,110
    WAIT

    SPEED 12
    '왼발뻣어착지
    MOVE G6A, 85,  43, 163, 113, 114
    MOVE G6D,110,  77, 146,  93,  94
    WAIT

    SPEED 5
    '왼발중심이동
    MOVE G6A,110,  76, 144, 100,  93
    MOVE G6D,85, 93, 155,  71, 112
    WAIT

    SPEED 5
    '오른발들기10
    MOVE G6A,114,  77, 146,  93, 90
    MOVE G6D,93, 100, 105, 110, 114
    MOVE G6B,110
    MOVE G6C,90
    WAIT

    SPEED 5
    MOVE G6A,100,  78, 145,  93, 100, 100
    MOVE G6D,100,  78, 145,  93, 100, 100
    MOVE G6B,100,  35,  80, 100
    MOVE G6C,100,  35,  80, 100
    WAIT

    RETURN
    '**********************************************
GO_FAST4:

    GOSUB 자이로OFF
    HIGHSPEED SETOFF
    GOSUB All_motor_mode3

    SPEED 10
    MOVE G6A,100,  78, 145,  93, 100, 100
    MOVE G6D,100,  78, 145,  93, 100, 100
    MOVE G6B,100,  35,  80
    MOVE G6C,100,  35,  80
    WAIT


    SPEED 15
    MOVE G6A,100,  80, 125,  113, 100, 100
    MOVE G6D,106,  78, 145,  95, 100, 100
    MOVE G6B,100,  35,  80
    MOVE G6C,100,  35,  80
    WAIT

    SPEED 15
    MOVE G6A,100,  85, 125,  113 100, 100
    MOVE G6D,106,  87, 145,  80, 100, 100
    MOVE G6B,100,  35,  80
    MOVE G6C,100,  35,  80
    WAIT

    SPEED 15
    MOVE G6A,103,  80, 135,  104, 102, 100
    MOVE G6D,100,  100, 145,  73, 100, 100
    MOVE G6B,100,  35,  80
    MOVE G6C,100,  35,  80
    WAIT


    SPEED 15
    MOVE G6D,100,  75, 125,  113, 100, 100
    MOVE G6A,106,  80, 145,  93, 100, 100
    MOVE G6B,100,  35,  80
    MOVE G6C,100,  35,  80
    WAIT

    SPEED 15
    MOVE G6D,100,  75, 128,  113, 100, 100
    MOVE G6A,106,  90, 145,  76, 97, 100
    MOVE G6B,100,  35,  80
    MOVE G6C,100,  35,  80
    WAIT

    SPEED 15
    MOVE G6D,103,  75, 137,  105, 100, 100
    MOVE G6A,100,  100, 145,  73, 100, 100
    MOVE G6B,100,  35,  80
    MOVE G6C,100,  35,  80
    WAIT

    '********************************
    SPEED 15
    MOVE G6A,100,  80, 125,  113, 100, 100
    MOVE G6D,106,  78, 145,  95, 100, 100
    MOVE G6B,100,  35,  80
    MOVE G6C,100,  35,  80
    WAIT

    SPEED 15
    MOVE G6A,100,  85, 125,  113 100, 100
    MOVE G6D,106,  87, 145,  80, 100, 100
    MOVE G6B,100,  35,  80
    MOVE G6C,100,  35,  80
    WAIT

    SPEED 15
    MOVE G6A,103,  80, 135,  104, 102, 100
    MOVE G6D,100,  100, 145,  73, 100, 100
    MOVE G6B,100,  35,  80
    MOVE G6C,100,  35,  80
    WAIT


    SPEED 15
    MOVE G6D,100,  75, 125,  113, 100, 100
    MOVE G6A,106,  80, 145,  93, 100, 100
    MOVE G6B,100,  35,  80
    MOVE G6C,100,  35,  80
    WAIT

    SPEED 15
    MOVE G6D,100,  75, 128,  113, 100, 100
    MOVE G6A,106,  90, 145,  76, 97, 100
    MOVE G6B,100,  35,  80
    MOVE G6C,100,  35,  80
    WAIT

    SPEED 15
    MOVE G6D,103,  75, 137,  105, 100, 100
    MOVE G6A,100,  100, 145,  73, 100, 100
    MOVE G6B,100,  35,  80
    MOVE G6C,100,  35,  80
    WAIT

    SPEED 12
    '왼발들기10
    MOVE G6D,109  78, 145,  93, 100
    MOVE G6A,92, 94, 118, 104 105

    WAIT
    GOSUB 자이로ON	


    SPEED 12
    MOVE G6A,100,  78, 145,  93, 100, 100
    MOVE G6D,100,  78, 145,  93, 100, 100
    MOVE G6B,100,  35,  80, 100, 100, 100
    MOVE G6C,100,  35,  80, 100, 180, 100
    WAIT

    RETURN
    '**********************************************
SWalk_last:

    GOSUB 자이로OFF

    GOSUB Leg_motor_mode2
    SPEED 10
    MOVE G6A,100,  76, 145, 102, 100, 100
    MOVE G6D,100,  76, 145,  92, 100, 100
    WAIT

    MOVE G6A,100,  76, 145,  92, 100, 100
    MOVE G6D,100,  76, 145, 102, 100, 100
    WAIT

    MOVE G6A,100,  76, 145, 102, 100, 100
    MOVE G6D,100,  76, 145,  92, 100, 100
    WAIT

    MOVE G6A,100,  76, 145,  92, 100, 100
    MOVE G6D,100,  76, 145, 102, 100, 100
    WAIT


    SPEED 6
    MOVE G6A,100,  76, 145, 102, 100, 100
    MOVE G6D,100,  76, 145,  92, 100, 100
    WAIT

    MOVE G6A,100,  76, 145,  92, 100, 100
    MOVE G6D,100,  76, 145, 102, 100, 100
    WAIT

    MOVE G6A,100,  76, 145, 102, 100, 100
    MOVE G6D,100,  76, 145,  92, 100, 100
    WAIT

    MOVE G6A,100,  76, 145,  92, 100, 100
    MOVE G6D,100,  76, 145, 102, 100, 100
    WAIT

    '기본 자세
    MOVE G6A,100,  76, 145,  93, 100, 100
    MOVE G6D,100,  76, 145,  93, 100, 100
    WAIT


    GOSUB 자이로ON
    '3.5번 줄임
    RETURN
    '**********************************************
SWalk_CamDown:

    GOSUB 자이로OFF

    GOSUB Leg_motor_mode2

    FOR I = 0 TO 3

        '**1
        SPEED 10
        MOVE G6A,100,  79, 143, 103, 100, 100
        MOVE G6D,100,  76, 145,  92, 100, 100
        MOVE G6B,100,  35,  80, 100, 100, 100
        MOVE G6C,100,  35,  80, 100, 180, 100
        WAIT

        MOVE G6A,100,  76, 145,  92, 100, 100
        MOVE G6D,100,  76, 145, 102, 100, 100
        MOVE G6B,100,  35,  80, 100, 100, 100
        MOVE G6C,100,  35,  80, 100, 180, 100
        WAIT

    NEXT I

    '기본 자세
    MOVE G6A,100,  76, 145,  93, 100, 100
    MOVE G6D,100,  76, 145,  93, 100, 100
    MOVE G6B,100,  35,  80, 100, 100, 100
    MOVE G6C,100,  35,  80, 100, 180, 100
    WAIT

    RETURN
    '************************************************
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
Chung_Lturn:

    GOSUB Leg_motor_mode1
    GOSUB 자이로OFF

    HIGHSPEED SETOFF

    SPEED 14
    MOVE G6D,100,  57,  145,  95, 100, 100
    MOVE G6A, 99  108,  142,  90 100, 100
    WAIT

    SPEED 14
    MOVE G6A,100,  78, 145,  93, 100, 100
    MOVE G6D,100,  78, 145,  93, 100, 100
    WAIT

    DELAY 100

    RETURN
    '**********************************************
Chung_Rturn:

    GOSUB Leg_motor_mode1
    GOSUB 자이로OFF

    HIGHSPEED SETOFF

    SPEED 14
    MOVE G6A,99,  57,  145,  95, 100, 100
    MOVE G6D,100,  108, 142,  90, 100, 100
    WAIT

    SPEED 14
    MOVE G6A,100,  78, 145,  93, 100, 100
    MOVE G6D,100,  78, 145,  93, 100, 100
    WAIT

    DELAY 100

    RETURN
    '**********************************************
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
LWalks:

    GOSUB 자이로OFF

    GOSUB Leg_motor_mode2

    SPEED 12
    MOVE G6A, 95,  91, 120, 103, 104, 100	
    MOVE G6D, 99,  76, 146,  93, 101, 100	
    WAIT

    SPEED 15
    MOVE G6A,98,  76, 146,  94, 100, 100
    MOVE G6D,99,  76, 146,  94,  99, 100
    WAIT

    SPEED 8
    MOVE G6A,100,  76, 145,  93, 100, 100
    MOVE G6D,100,  76, 145,  93, 100, 100
    WAIT

    RETURN
    '*****************************************
RWalks:

    GOSUB 자이로OFF

    GOSUB Leg_motor_mode2

    SPEED 12
    MOVE G6D, 95,  91, 120, 103, 105, 100	
    MOVE G6A,100,  76, 146,  93, 101, 100	
    WAIT

    SPEED 15
    MOVE G6D,98,  76, 146,  94, 100, 100
    MOVE G6A,98,  76, 146,  94, 100, 100
    WAIT

    SPEED 8
    MOVE G6D,100,  76, 145,  93, 100, 100
    MOVE G6A,100,  76, 145,  93, 100, 100
    WAIT

    RETURN
    '**********************************************
LSWalk:

    GOSUB 자이로OFF

    GOSUB Leg_motor_mode2

    SPEED 12
    MOVE G6A, 91,  91, 120, 103, 102, 100	
    MOVE G6D, 99,  76, 146,  93, 101, 100	
    WAIT

    SPEED 15
    MOVE G6A,98,  76, 146,  94, 100, 100
    MOVE G6D,99,  76, 146,  94,  99, 100
    WAIT

    SPEED 8
    MOVE G6A,100,  76, 145,  93, 100, 100
    MOVE G6D,100,  76, 145,  93, 100, 100
    WAIT

    RETURN
    '**********************************************
RSWalk:

    GOSUB 자이로OFF

    GOSUB Leg_motor_mode2

    SPEED 12
    MOVE G6D, 91,  91, 120, 103, 102, 100	
    MOVE G6A,100,  76, 146,  93, 101, 100	
    WAIT

    SPEED 15
    MOVE G6D,98,  76, 146,  94, 100, 100
    MOVE G6A,98,  76, 146,  94, 100, 100
    WAIT

    SPEED 8
    MOVE G6D,100,  76, 145,  93, 100, 100
    MOVE G6A,100,  76, 145,  93, 100, 100
    WAIT

    RETURN
    '**********************************************
LWalk_S:

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

    DELAY 300

    SPEED 10
    MOVE G6A,100,  76, 145, 103, 100, 100
    MOVE G6D,100,  76, 145,  93, 100, 100
    MOVE G6B,100,  35,  80, 100, 100, 100
    MOVE G6C,100,  35,  80, 100, 120, 100
    WAIT

    MOVE G6A,100,  76, 145,  93, 100, 100
    MOVE G6D,100,  76, 145, 103, 100, 100
    MOVE G6B,100,  35,  80, 100, 100, 100
    MOVE G6C,100,  35,  80, 100, 120, 100
    WAIT

    MOVE G6A,100,  76, 145, 103, 100, 100
    MOVE G6D,100,  76, 145,  93, 100, 100
    MOVE G6B,100,  35,  80, 100, 100, 100
    MOVE G6C,100,  35,  80, 100, 120, 100
    WAIT

    MOVE G6A,100,  76, 145,  93, 100, 100
    MOVE G6D,100,  76, 145, 103, 100, 100
    MOVE G6B,100,  35,  80, 100, 100, 100
    MOVE G6C,100,  35,  80, 100, 120, 100
    WAIT

    MOVE G6A,100,  76, 145,  93, 100, 100
    MOVE G6D,100,  76, 145,  93, 100, 100
    MOVE G6B,100,  35,  80, 100, 100, 100
    MOVE G6C,100,  35,  80, 100, 117, 100
    WAIT

    RETURN
    '**********************************************
RWalk_S:

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


    DELAY 300

    SPEED 10
    MOVE G6A,100,  76, 145, 103, 100, 100
    MOVE G6D,100,  76, 145,  93, 100, 100
    MOVE G6B,100,  35,  80, 100, 100, 100
    MOVE G6C,100,  35,  80, 100, 120, 100
    WAIT

    MOVE G6A,100,  76, 145,  93, 100, 100
    MOVE G6D,100,  76, 145, 103, 100, 100
    MOVE G6B,100,  35,  80, 100, 100, 100
    MOVE G6C,100,  35,  80, 100, 120, 100
    WAIT

    MOVE G6A,100,  76, 145, 103, 100, 100
    MOVE G6D,100,  76, 145,  93, 100, 100
    MOVE G6B,100,  35,  80, 100, 100, 100
    MOVE G6C,100,  35,  80, 100, 120, 100
    WAIT

    MOVE G6A,100,  76, 145,  93, 100, 100
    MOVE G6D,100,  76, 145, 103, 100, 100
    MOVE G6B,100,  35,  80, 100, 100, 100
    MOVE G6C,100,  35,  80, 100, 120, 100
    WAIT

    MOVE G6A,100,  76, 145,  93, 100, 100
    MOVE G6D,100,  76, 145,  93, 100, 100
    MOVE G6B,100,  35,  80, 100, 100, 100
    MOVE G6C,100,  35,  80, 100, 117, 100
    WAIT

    RETURN
    '******************************************
LSWalk_S:

    GOSUB 자이로OFF

    GOSUB Leg_motor_mode2

    SPEED 12
    MOVE G6A, 93,  88, 122, 105, 105, 100
    MOVE G6D,103,  78, 145,  93, 103, 100
    WAIT

    SPEED 12
    MOVE G6A, 102,  80, 145, 93, 100, 100
    MOVE G6D,94,  80, 140,  95, 105, 100
    WAIT

    SPEED 15
    MOVE G6A,98,  76, 145,  93, 102, 100
    MOVE G6D,98,  76, 145,  93, 102, 100
    WAIT

    DELAY 300

    SPEED 10
    MOVE G6A,100,  76, 145, 103, 100, 100
    MOVE G6D,100,  76, 145,  93, 100, 100
    MOVE G6B,100,  35,  80, 100, 100, 100
    MOVE G6C,100,  35,  80, 100, 120, 100
    WAIT

    MOVE G6A,100,  76, 145,  93, 100, 100
    MOVE G6D,100,  76, 145, 103, 100, 100
    MOVE G6B,100,  35,  80, 100, 100, 100
    MOVE G6C,100,  35,  80, 100, 120, 100
    WAIT

    MOVE G6A,100,  76, 145, 103, 100, 100
    MOVE G6D,100,  76, 145,  93, 100, 100
    MOVE G6B,100,  35,  80, 100, 100, 100
    MOVE G6C,100,  35,  80, 100, 120, 100
    WAIT

    MOVE G6A,100,  76, 145,  93, 100, 100
    MOVE G6D,100,  76, 145, 103, 100, 100
    MOVE G6B,100,  35,  80, 100, 100, 100
    MOVE G6C,100,  35,  80, 100, 120, 100
    WAIT

    GOSUB 기본자세

    RETURN
    '**********************************************
RSWalk_S:

    GOSUB 자이로OFF

    GOSUB Leg_motor_mode2

    SPEED 12
    MOVE G6D, 93,  86, 120, 105 105, 100
    MOVE G6A,103,  76, 145,  93, 103, 100
    WAIT

    SPEED 12
    MOVE G6D, 102,  80, 145, 93, 100, 100
    MOVE G6A,94,  82, 140,  97, 105, 100
    WAIT

    SPEED 15
    MOVE G6D,98,  76, 145,  93, 102, 100
    MOVE G6A,98,  76, 145,  93, 102, 100
    WAIT

    DELAY 300

    SPEED 10
    MOVE G6A,100,  76, 145, 103, 100, 100
    MOVE G6D,100,  76, 145,  93, 100, 100
    MOVE G6B,100,  35,  80, 100, 100, 100
    MOVE G6C,100,  35,  80, 100, 120, 100
    WAIT

    MOVE G6A,100,  76, 145,  93, 100, 100
    MOVE G6D,100,  76, 145, 103, 100, 100
    MOVE G6B,100,  35,  80, 100, 100, 100
    MOVE G6C,100,  35,  80, 100, 120, 100
    WAIT

    MOVE G6A,100,  76, 145, 103, 100, 100
    MOVE G6D,100,  76, 145,  93, 100, 100
    MOVE G6B,100,  35,  80, 100, 100, 100
    MOVE G6C,100,  35,  80, 100, 120, 100
    WAIT

    MOVE G6A,100,  76, 145,  93, 100, 100
    MOVE G6D,100,  76, 145, 103, 100, 100
    MOVE G6B,100,  35,  80, 100, 100, 100
    MOVE G6C,100,  35,  80, 100, 120, 100
    WAIT

    GOSUB 기본자세

    RETURN
    '**********************************************
Walk_Mine1:
    GOSUB 자이로ON
    HIGHSPEED SETOFF
    GOSUB All_motor_mode3

    SPEED 15
    MOVE G6A,100,  76, 145,  95, 100, 100
    MOVE G6D,100,  76, 145,  95, 100, 100
    MOVE G6B,100,  35,  80
    MOVE G6C,100,  35,  80
    WAIT

    SPEED 15
    MOVE G6D,108,  76, 145,  95, 104, 100
    MOVE G6A,100,  86, 125, 109, 100, 100
    MOVE G6B,100,  35,  80
    MOVE G6C,100,  35,  80
    WAIT

    '****************************************

    SPEED 15
    MOVE G6A, 99,  66, 145, 103, 100, 100
    MOVE G6D,100,  86, 145,  83, 100, 100
    MOVE G6B,100,  35,  80
    MOVE G6C,100,  35,  80
    WAIT

    SPEED 15
    MOVE G6A,108,  76, 145,  93, 104, 100
    MOVE G6D,100,  86, 125, 103, 100, 100
    MOVE G6B,100,  35,  80
    MOVE G6C,100,  35,  80
    WAIT

    SPEED 15
    MOVE G6D,101,  66, 145, 103, 100, 100
    MOVE G6A,100,  86, 145,  83, 100, 100
    MOVE G6B,100,  35,  80
    MOVE G6C,100,  35,  80
    WAIT

    SPEED 15
    MOVE G6D,108,  76, 145,  93, 104, 100
    MOVE G6A,100,  86, 125, 103, 100, 100
    MOVE G6B,100,  35,  80
    MOVE G6C,100,  35,  80
    WAIT

    '****************************************


    '****************************************

    SPEED 15
    MOVE G6A,100,  76, 145,  93, 100, 100
    MOVE G6D,100,  76, 145,  93, 100, 100
    MOVE G6B,100,  35,  80
    MOVE G6C,100,  35,  80, 100, 160
    WAIT

    GOSUB 자이로OFF

    DELAY 500

    RETURN
    '******************************************
Walk_Mine2:
    GOSUB 자이로ON
    HIGHSPEED SETOFF
    GOSUB All_motor_mode3

    SPEED 15
    MOVE G6A,100,  76, 145,  95, 100, 100
    MOVE G6D,100,  76, 145,  95, 100, 100
    MOVE G6B,100,  35,  80
    MOVE G6C,100,  35,  80
    WAIT

    SPEED 15
    MOVE G6D,108,  76, 145,  95, 104, 100
    MOVE G6A,100,  86, 125, 109, 100, 100
    MOVE G6B,100,  35,  80
    MOVE G6C,100,  35,  80
    WAIT

    '****************************************

    FOR I = 0 TO 1

        SPEED 15
        MOVE G6A, 99,  66, 145, 103, 100, 100
        MOVE G6D,100,  86, 145,  83, 100, 100
        MOVE G6B,100,  35,  80
        MOVE G6C,100,  35,  80
        WAIT

        SPEED 15
        MOVE G6A,108,  76, 145,  93, 104, 100
        MOVE G6D,100,  86, 125, 103, 100, 100
        MOVE G6B,100,  35,  80
        MOVE G6C,100,  35,  80
        WAIT

        SPEED 15
        MOVE G6D,101,  66, 145, 103, 100, 100
        MOVE G6A,100,  86, 145,  83, 100, 100
        MOVE G6B,100,  35,  80
        MOVE G6C,100,  35,  80
        WAIT

        SPEED 15
        MOVE G6D,108,  76, 145,  93, 104, 100
        MOVE G6A,100,  86, 125, 103, 100, 100
        MOVE G6B,100,  35,  80
        MOVE G6C,100,  35,  80
        WAIT

    NEXT I

    '****************************************

    SPEED 15
    MOVE G6A, 99,  66, 145, 103, 100, 100
    MOVE G6D,100,  86, 145,  83, 100, 100
    MOVE G6B,100,  35,  80
    MOVE G6C,100,  35,  80
    WAIT

    SPEED 15
    MOVE G6A,108,  76, 145,  93, 104, 100
    MOVE G6D,100,  86, 125, 103, 100, 100
    MOVE G6B,100,  35,  80
    MOVE G6C,100,  35,  80
    WAIT



    '****************************************

    SPEED 15
    MOVE G6A,100,  76, 145,  93, 100, 100
    MOVE G6D,100,  76, 145,  93, 100, 100
    MOVE G6B,100,  35,  80
    MOVE G6C,100,  35,  80, 100, 160
    WAIT

    GOSUB 자이로OFF

    DELAY 500

    RETURN
    '******************************************
Walk_Mine3:
    GOSUB 자이로ON
    HIGHSPEED SETOFF
    GOSUB All_motor_mode3

    SPEED 15
    MOVE G6A,100,  76, 145,  95, 100, 100
    MOVE G6D,100,  76, 145,  95, 100, 100
    MOVE G6B,100,  35,  80
    MOVE G6C,100,  35,  80
    WAIT

    SPEED 15
    MOVE G6D,108,  76, 145,  95, 104, 100
    MOVE G6A,100,  86, 125, 109, 100, 100
    MOVE G6B,100,  35,  80
    MOVE G6C,100,  35,  80
    WAIT

    '****************************************

    FOR I = 0 TO 3

        SPEED 15
        MOVE G6A, 99,  66, 145, 103, 100, 100
        MOVE G6D,100,  86, 145,  83, 100, 100
        MOVE G6B,100,  35,  80
        MOVE G6C,100,  35,  80
        WAIT

        SPEED 15
        MOVE G6A,108,  76, 145,  93, 104, 100
        MOVE G6D,100,  86, 125, 103, 100, 100
        MOVE G6B,100,  35,  80
        MOVE G6C,100,  35,  80
        WAIT

        SPEED 15
        MOVE G6D,101,  66, 145, 103, 100, 100
        MOVE G6A,100,  86, 145,  83, 100, 100
        MOVE G6B,100,  35,  80
        MOVE G6C,100,  35,  80
        WAIT

        SPEED 15
        MOVE G6D,108,  76, 145,  93, 104, 100
        MOVE G6A,100,  86, 125, 103, 100, 100
        MOVE G6B,100,  35,  80
        MOVE G6C,100,  35,  80
        WAIT

    NEXT I

    '****************************************



    '****************************************

    SPEED 15
    MOVE G6A,100,  76, 145,  93, 100, 100
    MOVE G6D,100,  76, 145,  93, 100, 100
    MOVE G6B,100,  35,  80
    MOVE G6C,100,  35,  80, 100, 160
    WAIT

    GOSUB 자이로OFF

    DELAY 700

    RETURN
    '******************************************
Walk_Mine4:
    GOSUB 자이로ON
    HIGHSPEED SETOFF
    GOSUB All_motor_mode3

    SPEED 15
    MOVE G6A,100,  76, 145,  95, 100, 100
    MOVE G6D,100,  76, 145,  95, 100, 100
    MOVE G6B,100,  35,  80
    MOVE G6C,100,  35,  80
    WAIT

    SPEED 15
    MOVE G6D,108,  76, 145,  95, 104, 100
    MOVE G6A,100,  86, 125, 109, 100, 100
    MOVE G6B,100,  35,  80
    MOVE G6C,100,  35,  80
    WAIT

    '****************************************

    FOR I = 0 TO 4

        SPEED 15
        MOVE G6A, 99,  66, 145, 103, 100, 100
        MOVE G6D,100,  86, 145,  83, 100, 100
        MOVE G6B,100,  35,  80
        MOVE G6C,100,  35,  80
        WAIT

        SPEED 15
        MOVE G6A,108,  76, 145,  93, 104, 100
        MOVE G6D,100,  86, 125, 103, 100, 100
        MOVE G6B,100,  35,  80
        MOVE G6C,100,  35,  80
        WAIT

        SPEED 15
        MOVE G6D,101,  66, 145, 103, 100, 100
        MOVE G6A,100,  86, 145,  83, 100, 100
        MOVE G6B,100,  35,  80
        MOVE G6C,100,  35,  80
        WAIT

        SPEED 15
        MOVE G6D,108,  76, 145,  93, 104, 100
        MOVE G6A,100,  86, 125, 103, 100, 100
        MOVE G6B,100,  35,  80
        MOVE G6C,100,  35,  80
        WAIT

    NEXT I

    '****************************************

    '****************************************

    SPEED 15
    MOVE G6A,100,  76, 145,  93, 100, 100
    MOVE G6D,100,  76, 145,  93, 100, 100
    MOVE G6B,100,  35,  80
    MOVE G6C,100,  35,  80, 100, 160
    WAIT

    GOSUB 자이로OFF

    DELAY 700

    RETURN
    '******************************************
Lturn:
    GOSUB Leg_motor_mode2

    SPEED 8
    MOVE G6A,96,  94, 145,  76, 104, 100
    MOVE G6D,95,  58, 145,  105, 104, 100
    WAIT

    SPEED 12
    MOVE G6A,93,  94, 145,  73, 104, 100
    MOVE G6D,93,  57, 145,  105, 104, 100
    WAIT

    SPEED 6
    MOVE G6A,101,  76, 146,  93, 98, 100
    MOVE G6D,101,  76, 146,  93, 98, 100
    WAIT

    RETURN
    '******************************************
Rturn:
    GOSUB Leg_motor_mode2

    SPEED 8
    MOVE G6D,95,  98, 145,  73, 105, 100
    MOVE G6A,95,  54, 145,  114, 105, 100
    WAIT

    SPEED 12
    MOVE G6D,93,  96, 145,  73, 105, 100
    MOVE G6A,93,  56, 145,  113, 105, 100
    WAIT

    SPEED 6
    MOVE G6D,101,  76, 146,  93, 98, 100
    MOVE G6A,101,  76, 146,  93, 98, 100
    WAIT

    RETURN
    '******************************************
LSturn:

    GOSUB 자이로OFF

    GOSUB Leg_motor_mode1

    SPEED 5
    MOVE G6D, 97,  66, 145, 110, 103, 100
    MOVE G6A, 97,  86, 145,  83, 103, 100
    WAIT

    SPEED 12
    MOVE G6D,94,  66, 145, 110, 101, 100
    MOVE G6A,94,  86, 145,  83
    WAIT

    SPEED 6
    MOVE G6D,101,  76, 146,  93, 98, 100
    MOVE G6A,101,  76, 146,  93, 98, 100
    WAIT

    MOVE G6A,100,  76, 145,  93, 100, 100
    MOVE G6D,100,  76, 145,  93, 100, 100
    WAIT

    DELAY 100

    RETURN
    '**********************************************
RSturn:

    GOSUB 자이로OFF

    GOSUB Leg_motor_mode1

    SPEED 5
    MOVE G6A,97,  66, 145,  105, 103, 100
    MOVE G6D,97,  86, 145,  83, 101, 100
    WAIT

    SPEED 12
    MOVE G6A,94,  66, 145,  105, 101, 100
    MOVE G6D,94,  86, 145,  83, 101, 100
    WAIT

    SPEED 6
    MOVE G6A,101,  76, 146,  93, 98, 100
    MOVE G6D,101,  76, 146,  93, 98, 100
    WAIT

    MOVE G6A,100,  76, 145,  93, 100, 100
    MOVE G6D,100,  76, 145,  93, 100, 100
    WAIT

    DELAY 100

    RETURN
    '**********************************************
LSSturn:

    GOSUB 자이로OFF

    GOSUB Leg_motor_mode1

    SPEED 5
    MOVE G6D, 98,  69, 145, 100, 102, 100
    MOVE G6A, 99,  84, 145,  83, 97, 100
    WAIT

    SPEED 6
    MOVE G6D,101,  76, 145,  93, 98, 100
    MOVE G6A,101,  76, 145,  93, 98, 100
    WAIT

    MOVE G6A,100,  76, 145,  93, 100, 100
    MOVE G6D,100,  76, 145,  93, 100, 100
    WAIT

    DELAY 200

    RETURN
    '*******************************************
RSSturn:

    GOSUB 자이로OFF

    GOSUB Leg_motor_mode1

    SPEED 5
    MOVE G6A,100,  70, 145,   95, 100, 100
    MOVE G6D,99,  84, 145,  83, 98, 100
    WAIT

    SPEED 6
    MOVE G6A,101,  76, 146,  93, 98, 100
    MOVE G6D,101,  76, 146,  93, 98, 100
    WAIT

    MOVE G6A,100,  76, 145,  93, 100, 100
    MOVE G6D,100,  76, 145,  93, 100, 100
    WAIT

    DELAY 100

    RETURN
    '******************************************
Red:

    GOSUB 자이로OFF

    GOSUB leg_motor_mode1

    '다리위에 올라가기
    SPEED 8
    MOVE G6A,100,  60, 160, 146, 100, 100   '76  -60
    MOVE G6D,100,  63, 159, 150, 100, 100   '76  -63
    MOVE G6B,170,  13, 100
    MOVE G6C,175,  13, 100,    ,  190        '181
    WAIT

    DELAY 200

    '자세맞추기
    SPEED 10
    MOVE G6A,102,  96, 185, 143, 100, 100
    MOVE G6D,100,  97, 185, 145,  99, 100
    MOVE G6B,158,  13, 100
    MOVE G6C,158,  13, 100,     ,  190
    WAIT

    '한쪽다리 들기
    SPEED 15
    MOVE G6D,102,  71, 177, 162, 100, 100
    MOVE G6A,100,  56, 110,  26, 100, 100
    MOVE G6B,188,  37,  70                   ''
    MOVE G6C,188,  37,  74,    ,  190
    WAIT

    '양쪽다리들기
    SPEED 15
    MOVE G6D,100,  52, 112,  10, 100, 100
    MOVE G6A,100,  50, 110,  16, 100, 100     '16
    MOVE G6B,188,  37,  72                     ''
    MOVE G6C,188,  37,  72,    ,  190
    WAIT

    DELAY 150

    '팔뒤로 뻣어서 일어나려고 노력하기
    SPEED 15
    MOVE G6A,100, 108, 75,  57, 100, 100
    MOVE G6D,100, 109, 70,  60, 100, 100
    MOVE G6B,184, 173, 118
    MOVE G6C,190, 175, 118
    WAIT

    SPEED 10
    MOVE G6A,100, 170,  77, 12, 100, 100
    MOVE G6D,100, 170,  68, 18, 100, 100
    MOVE G6B,185, 178, 120
    MOVE G6C,190, 178, 120,   , 190
    WAIT

    SPEED 10
    MOVE G6A,100, 170,  75, 12, 100, 100
    MOVE G6D,100, 170,  69, 18, 100, 100
    MOVE G6B,186,  40,  60
    MOVE G6C,190,  40,  60
    WAIT

    SPEED 10
    MOVE G6A,100, 170,  35,  115, 100, 100
    MOVE G6D,100, 170,  30,  115, 100, 100
    MOVE G6B,186,  40,  60
    MOVE G6C,190,  40,  60
    WAIT

    DELAY 300

    ''''''새로운
    SPEED 5
    MOVE G6A,100, 175,  65,  170, 100, 100
    MOVE G6D,100, 175,  60,  170, 100, 100
    MOVE G6B,176,  40,  60
    MOVE G6C,180,  40,  60
    WAIT
    '********************

    SPEED 10
    MOVE G6A,102,  112, 185, 93, 100, 100
    MOVE G6D,98,  112, 185, 93,  99, 100
    MOVE G6B,183,  19, 92
    MOVE G6C,190,  17, 94 ,    ,  190
    WAIT

    SPEED 10
    MOVE G6A,100,  97, 53, 113, 100, 100
    MOVE G6D,100,  97, 50, 113,  99, 100
    MOVE G6B,183,  19, 92
    MOVE G6C,190,  17, 94 ,    ,  190
    WAIT

    DELAY 300

    SPEED 10
    MOVE G6A,102,  96, 185, 113, 100, 100
    MOVE G6D,100,  97, 185, 115,  99, 100
    MOVE G6B,183,  19, 92
    MOVE G6C,190,  17, 94 ,    ,  190
    WAIT

    '*******************
    SPEED 15

    MOVE G6D, 80, 173,  45, 159,  150, 100
    WAIT

    MOVE G6A, 80, 170,  45, 158,  150, 100
    MOVE G6B,182,  14, 92
    WAIT

    MOVE G6A, 60, 160,  45, 150,  148, 100
    MOVE G6D, 60, 160,  45, 150,  148, 100
    WAIT

    MOVE G6A, 60, 165,  45, 140,  140, 100
    MOVE G6D, 60, 165,  45, 140,  140, 100
    WAIT

    MOVE G6A, 70, 166,  40, 120,  128, 100  '
    MOVE G6D, 70, 166,  40, 120,  128, 100
    WAIT

    MOVE G6A, 75, 175,  40, 110,  120, 100
    MOVE G6D, 72, 175,  40, 110,  120, 100
    WAIT

    MOVE G6A, 90, 175,  40, 102,  110, 100
    MOVE G6D, 89, 175,  40, 102,  110, 100
    WAIT

    MOVE G6A, 90, 170,  45, 100,  110, 100
    MOVE G6D, 89, 170,  45, 100,  110, 100
    WAIT

    SPEED 10
    MOVE G6A,100, 147,  27, 140, 100, 100
    MOVE G6D,100, 145,  25, 143, 100, 100
    MOVE G6B,186,  40,  60
    MOVE G6C,190,  40,  60
    WAIT

    DELAY 500

    SPEED 7
    GOSUB 기본자세
    RETURN
    '************************************************
Red2:
    GOSUB 자이로OFF
    GOSUB All_motor_mode2

    SPEED 10
    MOVE G6A,100,  76, 145,  93, 100, 100
    MOVE G6D,100,  76, 145,  93, 100, 100
    MOVE G6B,100,  35,  80, 100, 100, 100
    MOVE G6C,100,  35,  80, 100, 117, 100
    WAIT

    SPEED 10
    MOVE G6A,100,  56, 182,  76, 100, 100
    MOVE G6D,100,  56, 182,  76, 100, 100
    MOVE G6B,180,  25,  80, 100, 100, 100
    MOVE G6C,180,  25,  80, 100, 190, 100
    WAIT

    SPEED 10
    MOVE G6A,100,  76, 182,  76, 100, 100
    MOVE G6D,100,  76, 182,  75, 100, 100
    MOVE G6B,180,  25,  80, 100, 100, 100
    MOVE G6C,180,  25,  80, 100, 190, 100
    WAIT

    DELAY 100

    SPEED 6
    MOVE G6A,100,  56, 182,  76, 100, 100
    MOVE G6D,100,  56, 182,  75, 100, 100
    MOVE G6B,160,  25,  80, 100, 100, 100
    MOVE G6C,160,  25,  80, 100, 190, 100
    WAIT

    SPEED 15
    MOVE G6A,100,  56, 182,  16, 100, 100
    MOVE G6D,100,  56, 182,  76, 100, 100
    MOVE G6B,160,  25,  80, 100, 100, 100
    MOVE G6C,160,  25,  80, 100, 190, 100
    WAIT

    SPEED 15
    MOVE G6A,100,  146, 22, 126, 100, 100
    MOVE G6D,100,  56, 182,  76, 100, 100
    MOVE G6B,160,  25,  80, 100, 100, 100
    MOVE G6C,160,  25,  80, 100, 190, 100
    WAIT

    SPEED 10
    MOVE G6A,100,  76, 182, 116, 100, 100
    MOVE G6D,100,  76, 182,  76, 100, 100
    MOVE G6B,160,  25,  80, 100, 100, 100
    MOVE G6C,160,  25,  80, 100, 190, 100
    WAIT

    SPEED 15
    MOVE G6A,100,  46, 122,  66, 100, 100
    MOVE G6D,100,  46, 122,  64, 100, 100
    MOVE G6B,160,  25,  80, 100, 100, 100
    MOVE G6C,160,  25,  80, 100, 190, 100
    WAIT

    SPEED 15
    MOVE G6A,100,  46, 122,  66, 100, 100
    MOVE G6D,100,  46, 122,  64, 100, 100
    MOVE G6B,190,  25,  80, 100, 100, 100
    MOVE G6C,190,  25,  80, 100, 190, 100
    WAIT

    DELAY 50

    SPEED 15
    MOVE G6A,100, 100, 180, 165, 100, 100
    MOVE G6D,100, 100, 180, 165, 100, 100
    MOVE G6B,100,  90,  10, 100, 100, 100
    MOVE G6C,100,  90,  10, 100, 190, 100
    WAIT

    DELAY 500

    SPEED 15
    MOVE G6A,100, 100, 180, 165, 100, 100
    MOVE G6D,100, 100, 180, 165, 100, 100
    MOVE G6B,120,  10,  95, 100, 100, 100
    MOVE G6C,120,  10,  95, 100, 190, 100
    WAIT

    SPEED 3
    MOVE G6A,100, 100, 180, 165, 100, 100
    MOVE G6D,100, 100, 180, 165, 100, 100
    MOVE G6B,100,  10,  95, 100, 100, 100
    MOVE G6C,100,  10,  95, 100, 190, 100
    WAIT

    SPEED 10
    MOVE G6A,100,  50, 160,  38, 100, 100
    MOVE G6D,100,  50, 160,  36, 100, 100
    MOVE G6B, 15,  10, 100, 100, 100, 100
    MOVE G6C, 15,  10, 100, 100, 190, 100
    WAIT

    SPEED 10
    MOVE G6A,100, 108,  85,  58, 100, 100
    MOVE G6D,100, 108,  85,  56, 100, 100
    MOVE G6B, 15,  10, 100, 100, 100, 100
    MOVE G6C, 15,  10, 100, 100, 190, 100
    WAIT

    SPEED 10
    MOVE G6A,100, 170,  77,  15, 100, 100
    MOVE G6D,100, 170,  75,  13, 100, 100
    MOVE G6B, 15,  10, 100, 100, 100, 100
    MOVE G6C, 15,  10, 100, 100, 190, 100
    WAIT

    SPEED 10
    MOVE G6A,100, 170,  77,  15, 100, 100
    MOVE G6D,100, 170,  75,  13, 100, 100
    MOVE G6B, 15, 180, 100, 100, 100, 100
    MOVE G6C, 15, 180, 100, 100, 190, 100
    WAIT

    SPEED 10
    MOVE G6A,100, 160,  35, 115, 100, 100
    MOVE G6D,100, 160,  35, 115, 100, 100
    MOVE G6B, 15, 180, 100, 100, 100, 100
    MOVE G6C, 15, 180, 100, 100, 190, 100
    WAIT

    SPEED 10
    MOVE G6A,100,  76, 145,  93, 100, 100
    MOVE G6D,100,  76, 145,  93, 100, 100
    MOVE G6B,100,  35,  80, 100, 100, 100
    MOVE G6C,100,  35,  80, 100, 117, 100
    WAIT

    RETURN
    '******************************************
    '*************************************
UPSTAIR:

    GOSUB 자이로OFF

    GOSUB All_motor_mode3


    SPEED 5
    MOVE G6D, 70, 100, 110, 100, 114
    MOVE G6A,113,  78, 146,  93,  94
    MOVE G6B,100, 100, 100
    MOVE G6C,100, 100, 100
    WAIT

    GOSUB Leg_motor_mode2

    SPEED 9
    MOVE G6D, 90, 140, 35, 130, 114
    MOVE G6A,113,  71, 155,  90,  94
    MOVE G6B,100, 100, 100
    MOVE G6C,100, 100, 100
    WAIT


    SPEED 13
    MOVE G6D,  80, 55, 130, 145, 114
    MOVE G6A,113,  70, 155,  90,  94
    MOVE G6B,100, 100, 100
    MOVE G6C,100, 100, 100
    WAIT


    GOSUB Leg_motor_mode3

    SPEED 8
    MOVE G6D, 103, 45, 128, 156, 100
    MOVE G6A,  96, 93, 165,  70, 100
    MOVE G6B,100, 100, 100
    MOVE G6C,100, 100, 100
    WAIT


    GOSUB 자이로ON
    SPEED 7
    MOVE G6D, 114,  95,  93, 148, 100
    MOVE G6A,  96,  85, 165,  42, 105
    MOVE G6B,100, 100, 100
    MOVE G6C,100, 100, 100
    WAIT


    '**********************************



    GOSUB Leg_motor_mode2	
    SPEED 7
    MOVE G6D, 114, 95, 97, 141, 95
    MOVE G6A,96,   120, 160,  50, 108
    MOVE G6B,100, 100, 100
    MOVE G6C,100, 100, 100
    WAIT

    SPEED 11
    MOVE G6D, 114, 92, 97, 140,95,
    MOVE G6A,90,  120, 40,  140, 108
    MOVE G6B,100, 100, 100
    MOVE G6C,100, 100, 100
    WAIT

    SPEED 9
    MOVE G6D, 113, 92, 110, 123,95,
    MOVE G6A,90,  95, 90,  142, 108
    MOVE G6B,100, 100, 100
    MOVE G6C,100, 100, 100
    WAIT

    SPEED 9
    MOVE G6D, 110, 93, 110, 115,97,
    MOVE G6A,90,  95, 110,  122, 104
    MOVE G6B,100, 100, 100
    MOVE G6C,100, 100, 100
    WAIT


    SPEED 6
    MOVE G6A,100,  76, 145,  92, 100, 100
    MOVE G6D,100,  76, 145,  92, 100, 100
    MOVE G6B,100, 100, 100
    MOVE G6C,100, 100, 100
    WAIT



    SPEED 4
    MOVE G6A,100,  76, 145,  93, 100, 100
    MOVE G6D,100,  76, 145,  93, 100, 100
    MOVE G6B,100, 100, 100
    MOVE G6C,100, 100, 100
    WAIT

    GOSUB All_motor_Reset


    DELAY 200

    RETURN
    '**********************************************
DOWNSTAIR:

    GOSUB 자이로ON

    GOSUB All_motor_mode3

    SPEED 6
    MOVE G6A,100,  76, 145,  93, 100, 100
    MOVE G6D,100,  76, 145,  93, 100, 100
    MOVE G6B,100, 100, 100
    MOVE G6C,100, 100, 100
    WAIT

    SPEED 6
    MOVE G6A, 55,  97, 115, 105, 114
    MOVE G6D,112,  76, 145,  93,  90
    MOVE G6B,100, 100, 100
    MOVE G6C,100, 100, 100
    WAIT


    GOSUB Leg_motor_mode2


    SPEED 10
    MOVE G6A,  80, 30, 155, 150, 114,
    MOVE G6D,113,  68, 155,  90,  94
    MOVE G6B,100, 100, 100
    MOVE G6C,100, 100, 100
    WAIT

    GOSUB Leg_motor_mode2

    SPEED 9
    MOVE G6A,  90, 30, 175, 150, 114,
    MOVE G6D,115,  115, 65,  140,  92
    MOVE G6B,100, 100, 100
    MOVE G6C,100, 100, 100
    WAIT

    '다리 내려놓기
    GOSUB Leg_motor_mode3
    SPEED 7
    MOVE G6A,85, 20, 142, 155, 110
    MOVE G6D,109,  165, 45, 115,92
    MOVE G6B,100, 100, 100
    MOVE G6C,100, 100, 100
    WAIT



    DELAY 400

    SPEED 7
    MOVE G6A,97, 30, 150, 150, 100
    MOVE G6D,100, 155, 70,  100,100
    MOVE G6B,100, 100, 100
    MOVE G6C,100, 100, 100
    WAIT

    SPEED 9
    MOVE G6A,108, 70, 130, 130, 94
    MOVE G6D,80,  115, 140,  85,114
    MOVE G6B,100, 100, 100
    MOVE G6C,100, 100, 100
    WAIT

    GOSUB Leg_motor_mode2
    SPEED 9
    MOVE G6A,110, 68, 130, 135, 94
    MOVE G6D,80,  135, 70,  142,114
    MOVE G6B,100, 100, 100
    MOVE G6C,100, 100, 100
    WAIT

    SPEED 8
    MOVE G6A,110, 75, 130, 120, 94
    MOVE G6D,80,  85, 100,  150,114
    MOVE G6B,100, 100, 100
    MOVE G6C,100, 100, 100
    WAIT

    SPEED 7
    MOVE G6A,108, 80, 128, 110, 100
    MOVE G6D,90,  75,130,  120,108
    MOVE G6B,100, 100, 100
    MOVE G6C,100, 100, 100
    WAIT

    SPEED 5
    MOVE G6D, 98, 80, 130, 105,106,
    MOVE G6A,98,  80, 130,  105, 99
    MOVE G6B,100, 100, 100
    MOVE G6C,100, 100, 100
    WAIT

    SPEED 5
    GOSUB 기본자세


    DELAY 300

    HIGHSPEED SETOFF
    GOSUB 자이로OFF
    GOSUB All_motor_mode2

    FOR I = 0 TO 4

        SPEED 7
        MOVE G6D,100,  81, 145,  91, 100, 100
        MOVE G6A,100,  76, 145,  96, 101, 100
        MOVE G6B,100,  35,  80, 100
        MOVE G6C,100,  35,  80, 100
        WAIT

        SPEED 7
        MOVE G6D,100,  76, 145,  96, 102, 100
        MOVE G6A,100,  81, 140, 96, 101, 100
        MOVE G6B,100,  35,  80, 100
        MOVE G6C,100,  35,  80, 100
        WAIT

        SPEED 7
        MOVE G6A,100,  81, 145,  91, 101, 100
        MOVE G6D,100,  76, 145,  96, 100, 100
        MOVE G6B,100,  35,  80, 100
        MOVE G6C,100,  35,  80, 100
        WAIT

        SPEED 7
        MOVE G6A,100,  76, 145,  96, 103, 100
        MOVE G6D,100,  81, 140, 96, 100, 100
        MOVE G6B,100,  35,  80, 100
        MOVE G6C,100,  35,  80, 100
        WAIT

    NEXT I

    GOSUB 기본자세

    DELAY 200

    GOSUB All_motor_Reset

    RETURN
    '**********************************************
LOTTO:

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

    DELAY 300
    '-------------------------

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

    '------------------------Rturn

    DELAY 500

    GOSUB Leg_motor_mode1

    SPEED 15
    MOVE G6D,90,  118, 145,  53, 108, 100
    MOVE G6A,90,  36, 145,  133, 108, 100
    WAIT

    SPEED 15
    MOVE G6D,90,  118, 145,  53, 108, 100
    MOVE G6A,90,  36, 145,  133, 108, 100
    WAIT

    SPEED 10
    MOVE G6D,100,  76, 145,  93, 100, 100
    MOVE G6A,100,  76, 145,  93, 100, 100
    MOVE G6C,100,  35,  80, 100, 145, 100
    MOVE G6B,100,  35,  80, 100, 100, 100
    WAIT

    DELAY 200

    RETURN
    '************************************************
KICK:
    GOSUB Leg_motor_mode3

    HIGHSPEED SETOFF
    GOSUB 자이로ON
    DELAY 500

    SPEED 4
    MOVE G6A,105, 76, 145, 93, 100	
    MOVE G6D, 95, 76, 145, 93, 100
    WAIT

    SPEED 7
    MOVE G6A,111,  75, 145,  100,  95	
    MOVE G6D, 90, 100, 122,  105, 114
    WAIT

    GOSUB 자이로OFF
    GOSUB Leg_motor_mode2

    HIGHSPEED SETON

    SPEED 9
    MOVE G6A,112,  72, 153,  85,  95
    MOVE G6D, 90,  30, 165,  118, 114
    MOVE G6C,50
    MOVE G6B,150
    WAIT

    HIGHSPEED SETOFF

    DELAY 100

    GOSUB 자이로ON

    SPEED 8
    MOVE G6A,111,  76, 145,  97,  99
    MOVE G6D, 90,  58, 122,  124, 114
    MOVE G6C,100,  40,  80, , , ,
    MOVE G6B,100,  50,  80, , , ,	
    WAIT	


    SPEED 8
    MOVE G6A,110,  80, 145,  93,  93, 100	
    MOVE G6D, 85,  71, 152,  91, 114, 120
    WAIT


    SPEED 3
    GOSUB 기본자세	
    GOSUB Leg_motor_mode3

    DELAY 400

    GOSUB 자이로OFF

    RETURN
    '**********************************************
Yellow:
    GOSUB 자이로OFF

    GOSUB leg_motor_mode1

    SPEED 6
    MOVE G6A,100, 143,  28, 141, 100, 100
    MOVE G6D,100, 143,  25, 141, 100, 100
    MOVE G6B,148,  57,  70
    MOVE G6C,150,  58,  70,	   , 190
    WAIT

    SPEED 6
    MOVE G6A,100, 143,  113, 141, 100, 100
    MOVE G6D,100, 143,  113, 141, 100, 100
    MOVE G6B,178,  57,  70
    MOVE G6C,178,  58,  70
    WAIT

    DELAY 500

    '한쪽다리들기
    SPEED 15
    MOVE G6A,102,  71, 177, 162, 100, 100
    MOVE G6D,100,  56, 110,  26, 100, 100
    MOVE G6B,170,  61,  70
    MOVE G6C,178,  61,  70,    ,  190
    WAIT

    '양쪽다리들기
    SPEED 15
    MOVE G6A,100,  74, 84,  14, 100, 100   '92
    MOVE G6D,100,  74, 84,  14, 100, 100   '90
    MOVE G6B,180,  47,  70
    MOVE G6C,190,  47,  70,    ,  190
    WAIT

    DELAY 1500

    '''''''''이제부터 일어나기
    SPEED 15
    MOVE G6A,100, 108, 75,  56, 100, 100
    MOVE G6D,100, 109, 75,  56, 100, 100
    MOVE G6B,168, 173, 115
    MOVE G6C,168, 173, 115
    WAIT

    DELAY 300


    SPEED 10
    MOVE G6A,100, 108, 75,  56, 100, 100
    MOVE G6D,100, 109, 75,  56, 100, 100
    MOVE G6B,188, 173, 115
    MOVE G6C,188, 173, 115
    WAIT

    SPEED 10
    MOVE G6A,100, 170,  75, 15, 100, 100
    MOVE G6D,100, 170,  70, 15, 100, 100
    MOVE G6B,188, 173, 120
    MOVE G6C,188, 173, 120,   , 190
    WAIT


    SPEED 10
    MOVE G6A,100, 170,  75, 15, 100, 100
    MOVE G6D,100, 170,  69, 15, 100, 100
    MOVE G6B,188,  37,  60
    MOVE G6C,188,  37,  60
    WAIT

    SPEED 10
    MOVE G6A,100, 170,  30,  110, 100, 100
    MOVE G6D,100, 170,  30,  110, 100, 100
    MOVE G6B,190,  40,  60
    MOVE G6C,190,  40,  60
    WAIT

    DELAY 500

    SPEED 13
    MOVE G6A,100, 145,  20, 145, 100, 100
    MOVE G6D,100, 145,  25, 145, 100, 100
    MOVE G6B,184,  35,  60
    MOVE G6C,190,  40,  60
    WAIT

    SPEED 7
    GOSUB 기본자세

    DELAY 500
    GOSUB All_motor_Reset
    RETURN
    '******************************************
HodadakLong:
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
    MOVE G6D,108,  76, 145,  95, 104, 100
    MOVE G6A,100,  86, 125, 109, 100, 100
    MOVE G6B,100,  35,  80, 100
    MOVE G6C,100,  35,  80, 100
    WAIT

    '****************************************

    FOR I = 0 TO 3

        SPEED 15
        MOVE G6A, 99,  66, 145, 103, 100, 100
        MOVE G6D,100,  86, 145,  83, 100, 100
        MOVE G6B,100,  35,  80, 100
        MOVE G6C,100,  35,  80, 100
        WAIT

        SPEED 15
        MOVE G6A,108,  76, 145,  93, 104, 100
        MOVE G6D,100,  86, 125, 103, 100, 100
        MOVE G6B,100,  35,  80, 100
        MOVE G6C,100,  35,  80, 100
        WAIT

        SPEED 15
        MOVE G6D,101,  66, 145, 103, 100, 100
        MOVE G6A,100,  86, 145,  83, 100, 100
        MOVE G6B,100,  35,  80, 100
        MOVE G6C,100,  35,  80, 100
        WAIT

        SPEED 15
        MOVE G6D,108,  76, 145,  93, 104, 100
        MOVE G6A,100,  86, 125, 103, 100, 100
        MOVE G6B,100,  35,  80, 100
        MOVE G6C,100,  35,  80, 100
        WAIT

    NEXT I

    '****************************************

    SPEED 15
    MOVE G6A, 99,  66, 145, 103, 100, 100
    MOVE G6D,100,  86, 145,  83, 100, 100
    MOVE G6B,100,  35,  80, 100
    MOVE G6C,100,  35,  80, 100
    WAIT

    SPEED 15
    MOVE G6A,108,  76, 145,  93, 104, 100
    MOVE G6D,100,  86, 125, 103, 100, 100
    MOVE G6B,100,  35,  80, 100
    MOVE G6C,100,  35,  80, 100
    WAIT

    SPEED 15
    MOVE G6D,101,  66, 145, 103, 100, 100
    MOVE G6A,100,  86, 145,  83, 100, 100
    MOVE G6B,100,  35,  80, 100
    MOVE G6C,100,  35,  80, 100
    WAIT

    SPEED 15
    MOVE G6D,108,  76, 145,  91, 104, 100
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
    '****************************************
HodadakShort:
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
    MOVE G6D,108,  76, 145,  95, 104, 100
    MOVE G6A,100,  86, 125, 109, 100, 100
    MOVE G6B,100,  35,  80, 100
    MOVE G6C,100,  35,  80, 100
    WAIT

    '****************************************

    '****************************************

    SPEED 15
    MOVE G6A, 99,  66, 145, 103, 100, 100
    MOVE G6D,100,  86, 145,  83, 100, 100
    MOVE G6B,100,  35,  80, 100
    MOVE G6C,100,  35,  80, 100
    WAIT

    SPEED 15
    MOVE G6A,108,  76, 145,  93, 104, 100
    MOVE G6D,100,  86, 125, 103, 100, 100
    MOVE G6B,100,  35,  80, 100
    MOVE G6C,100,  35,  80, 100
    WAIT

    SPEED 15
    MOVE G6D,101,  66, 145, 103, 100, 100
    MOVE G6A,100,  86, 145,  83, 100, 100
    MOVE G6B,100,  35,  80, 100
    MOVE G6C,100,  35,  80, 100
    WAIT

    SPEED 15
    MOVE G6D,108,  76, 145,  93, 104, 100
    MOVE G6A,100,  86, 125,  99, 100, 100
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
    '****************************************
JLturn10:

    GOSUB 자이로OFF

    GOSUB Leg_motor_mode1

    SPEED 8
    MOVE G6D,100,  57, 145,  98, 100, 100
    MOVE G6A,100,  85, 155,  93, 102, 100

    '76
    '71

    MOVE G6D,100,  76, 145,  93, 100, 100
    MOVE G6A,100,  76, 145,  93, 100, 100

    WAIT

    DELAY 200



    RETURN
    '*******************************************

JRturn10:

    GOSUB 자이로OFF

    GOSUB Leg_motor_mode1

    SPEED 8
    MOVE G6A,100,  57, 145,  93, 102, 100
    MOVE G6D,100,  85, 155,  88, 100, 100

    '76
    '71

    MOVE G6A,100,  76, 145,  93, 100, 100
    MOVE G6D,100,  76, 145,  93, 100, 100

    WAIT

    DELAY 200


    RETURN
    '*******************************************
JLWalk:

    GOSUB 자이로OFF

    GOSUB Leg_motor_mode2

    SPEED 12
    MOVE G6A, 93,  88, 125, 104, 112, 100
    MOVE G6D,103,  76, 145,  96, 105, 100
    WAIT

    SPEED 12
    MOVE G6A,102,  78, 145,  94, 100, 100
    MOVE G6D, 90,  80, 140,  96, 108, 100
    WAIT

    SPEED 15
    MOVE G6A, 98,  76, 145,  93, 102, 100
    MOVE G6D, 98,  76, 145,  93, 103, 100
    WAIT

    SPEED 8
    MOVE G6A,100,  76, 145,  93, 100, 100
    MOVE G6D,100,  76, 145,  93, 101, 100
    WAIT
    RETURN
    '******************************************
JRWalk:
    GOSUB 자이로OFF

    GOSUB Leg_motor_mode2

    SPEED 12
    MOVE G6D, 93,  86, 125, 104, 112, 100
    MOVE G6A,103,  76, 145,  96, 105, 100
    WAIT

    SPEED 12
    MOVE G6D, 102,  78, 145, 94, 100, 100
    MOVE G6A,  90,  80, 140, 96, 108, 100
    WAIT

    SPEED 15
    MOVE G6D,98,  76, 145,  93, 103, 100
    MOVE G6A,98,  76, 145,  93, 102, 100
    WAIT

    SPEED 8
    MOVE G6D,100,  76, 145,  93, 101, 100
    MOVE G6A,100,  76, 145,  93, 100, 100
    WAIT

    RETURN
    '******************************************

JLSWalk:

    GOSUB 자이로OFF

    GOSUB Leg_motor_mode2

    SPEED 12
    MOVE G6A, 93,  88, 125, 104, 104, 100
    MOVE G6D,103,  76, 145,  96, 105, 100
    WAIT

    SPEED 12
    MOVE G6A, 102,  78, 145, 94, 100, 100
    MOVE G6D,90,  80, 140,  96, 108, 100
    WAIT

    SPEED 15
    MOVE G6A,98,  76, 145,  93, 102, 100
    MOVE G6D,98,  76, 145,  93, 103, 100
    WAIT

    SPEED 8
    MOVE G6A,100,  76, 145,  93, 100, 100
    MOVE G6D,100,  76, 145,  93, 101, 100
    WAIT
    RETURN
    '******************************************
JRSWalk:
    GOSUB 자이로OFF

    GOSUB Leg_motor_mode2

    SPEED 12
    MOVE G6D, 93,  86, 125, 104, 105, 100
    MOVE G6A,103,  76, 145,  96, 104, 100
    WAIT

    SPEED 12
    MOVE G6D, 102,  78, 145, 94, 100, 100
    MOVE G6A,90,  80, 140,  96, 108, 100
    WAIT

    SPEED 15
    MOVE G6D,98,  76, 145,  93, 103, 100
    MOVE G6A,98,  76, 145,  93, 102, 100
    WAIT

    SPEED 8
    MOVE G6D,100,  76, 145,  93, 101, 100
    MOVE G6A,100,  76, 145,  93, 100, 100
    WAIT

    RETURN
    '******************************************
Yellow2:

    GOSUB 자이로OFF
    GOSUB All_motor_mode2


    SPEED 10
    MOVE G6A,100,  76, 145,  93, 100, 100
    MOVE G6D,100,  76, 145,  93, 100, 100
    MOVE G6B,100,  35,  80, 100, 100, 100
    MOVE G6C,100,  35,  80, 100, 117, 100
    WAIT


    SPEED 10
    MOVE G6A,100, 145,  40, 145, 100, 100
    MOVE G6D,100, 145,  40, 145, 100, 100
    MOVE G6B,185,  15, 100, 100, 100, 100
    MOVE G6C,185,  15, 100, 100, 100, 100	
    WAIT

    SPEED 10
    MOVE G6A,100, 145, 130, 100, 100, 100
    MOVE G6D,100, 145, 130, 100, 100, 100
    MOVE G6B,185,  15,  100,
    MOVE G6C,185,  15,  100,    , 190
    WAIT

    SPEED 10
    MOVE G6A,100,  65, 145, 100, 100, 100
    MOVE G6D,100,  65, 145, 100, 100, 100
    MOVE G6B,120,  55,  55,
    MOVE G6C,120,  55,  55,    , 190
    WAIT

    SPEED 10
    MOVE G6A,100,  65, 145, 100, 100, 100
    MOVE G6D,100,  65, 145, 100, 100, 100
    MOVE G6B,120, 100, 100,
    MOVE G6C,120, 100, 100,    , 190
    WAIT

    SPEED 10
    MOVE G6A,100,  65, 145, 100, 100, 100
    MOVE G6D,100,  65, 145, 100, 100, 100
    MOVE G6B,190, 100, 100,
    MOVE G6C,190, 100, 100,    , 190
    WAIT

    SPEED 10
    MOVE G6A,100,  56, 182,  76, 100, 100
    MOVE G6D,100,  56, 182,  76, 100, 100
    MOVE G6B,190,  80,  40, 100, 100, 100
    MOVE G6C,190,  80,  40, 100, 190, 100
    WAIT

    SPEED 10
    MOVE G6A,100,  76, 182,  76, 100, 100
    MOVE G6D,100,  76, 182,  75, 100, 100
    MOVE G6B,190,  80,  40, 100, 100, 100
    MOVE G6C,190,  80,  40, 100, 190, 100
    WAIT

    DELAY 100

    SPEED 10
    MOVE G6A,100, 145, 145,  25, 100, 100
    MOVE G6D,100,  76, 182,  75, 100, 100
    MOVE G6B,190,  80,  40, 100, 100, 100
    MOVE G6C,190,  80,  40, 100, 190, 100
    WAIT

    SPEED 10
    MOVE G6A,100, 155, 145,  85, 100, 100
    MOVE G6D,100,  76, 182,  75, 100, 100
    MOVE G6B,190,  80,  40, 100, 100, 100
    MOVE G6C,190,  80,  40, 100, 190, 100
    WAIT

    SPEED 10
    MOVE G6A,100, 155, 145,  85, 100, 100
    MOVE G6D,100, 145, 145,  25, 100, 100
    MOVE G6B,190,  80,  40, 100, 100, 100
    MOVE G6C,190,  80,  40, 100, 190, 100
    WAIT

    SPEED 10
    MOVE G6A,100, 155, 145,  85, 100, 100
    MOVE G6D,100, 155, 145,  85, 100, 100
    MOVE G6B,190,  80,  40, 100, 100, 100
    MOVE G6C,190,  80,  40, 100, 190, 100
    WAIT

    SPEED 5
    MOVE G6A,100, 155, 145,  85, 100, 100
    MOVE G6D,100, 155, 145,  85, 100, 100
    MOVE G6B,100,  80,  40, 100, 100, 100
    MOVE G6C,100,  80,  40, 100, 190, 100
    WAIT

    SPEED 5
    MOVE G6A,100, 165, 185, 155, 100, 100
    MOVE G6D,100, 165, 185, 155, 100, 100
    MOVE G6B,100, 100, 100, 100, 100, 100
    MOVE G6C,100, 100, 100, 100, 190, 100
    WAIT

    SPEED 5
    MOVE G6A,100, 165, 185, 155, 100, 100
    MOVE G6D,100,  25, 145,  15, 100, 100
    MOVE G6B,100, 100, 100, 100, 100, 100
    MOVE G6C,100, 100, 100, 100, 190, 100
    WAIT

    DELAY 1000

    SPEED 5
    MOVE G6A,100,  56, 182,  74, 100, 100
    MOVE G6D,100,  56, 182,  74, 100, 100
    MOVE G6B,100, 100, 100, 100, 100, 100
    MOVE G6C,100, 100, 100, 100, 190, 100
    WAIT

    GOSUB Arm_motor_mode1

    SPEED 5
    MOVE G6A,100,  56, 182,  74, 100, 100
    MOVE G6D,100,  56, 182,  74, 100, 100
    MOVE G6B,100, 140, 140, 100, 100, 100
    MOVE G6C,100, 140, 140, 100, 190, 100
    WAIT

    SPEED 5
    MOVE G6A,100,  56, 182,  74, 100, 100
    MOVE G6D,100,  56, 182,  74, 100, 100
    MOVE G6B,115, 140, 140, 100, 100, 100
    MOVE G6C,115, 140, 140, 100, 190, 100
    WAIT

    DELAY 100

    GOSUB All_motor_mode3

    SPEED 15
    MOVE G6A,100, 100, 180, 165, 100, 100
    MOVE G6D,100, 100, 180, 165, 100, 100
    MOVE G6B,110, 140, 140, 100, 100, 100
    MOVE G6C,110, 140, 140, 100, 190, 100
    WAIT

    SPEED 15
    MOVE G6A,100, 100, 180, 165, 100, 100
    MOVE G6D,100, 100, 180, 165, 100, 100
    MOVE G6B,100,  90,  10, 100, 100, 100
    MOVE G6C,100,  90,  10, 100, 190, 100
    WAIT

    SPEED 15
    MOVE G6A,100, 100, 180, 165, 100, 100
    MOVE G6D,100, 100, 180, 165, 100, 100
    MOVE G6B,120,  10,  95, 100, 100, 100
    MOVE G6C,120,  10,  95, 100, 190, 100
    WAIT

    SPEED 3
    MOVE G6A,100, 100, 180, 165, 100, 100
    MOVE G6D,100, 100, 180, 165, 100, 100
    MOVE G6B,100,  10,  95, 100, 100, 100
    MOVE G6C,100,  10,  95, 100, 190, 100
    WAIT

    SPEED 10
    MOVE G6A,100,  50, 160,  38, 100, 100
    MOVE G6D,100,  50, 160,  36, 100, 100
    MOVE G6B, 15,  10, 100, 100, 100, 100
    MOVE G6C, 15,  10, 100, 100, 190, 100
    WAIT

    SPEED 10
    MOVE G6A,100, 108,  85,  58, 100, 100
    MOVE G6D,100, 108,  85,  56, 100, 100
    MOVE G6B, 15,  10, 100, 100, 100, 100
    MOVE G6C, 15,  10, 100, 100, 190, 100
    WAIT

    SPEED 10
    MOVE G6A,100, 170,  77,  15, 100, 100
    MOVE G6D,100, 170,  75,  13, 100, 100
    MOVE G6B, 15,  10, 100, 100, 100, 100
    MOVE G6C, 15,  10, 100, 100, 190, 100
    WAIT

    SPEED 10
    MOVE G6A,100, 170,  77,  15, 100, 100
    MOVE G6D,100, 170,  75,  13, 100, 100
    MOVE G6B, 15, 180, 100, 100, 100, 100
    MOVE G6C, 15, 180, 100, 100, 190, 100
    WAIT

    SPEED 10
    MOVE G6A,100, 160,  35, 115, 100, 100
    MOVE G6D,100, 160,  35, 115, 100, 100
    MOVE G6B, 15, 180, 100, 100, 100, 100
    MOVE G6C, 15, 180, 100, 100, 190, 100
    WAIT

    SPEED 10
    MOVE G6A,100,  76, 145,  93, 100, 100
    MOVE G6D,100,  76, 145,  93, 100, 100
    MOVE G6B,100,  35,  80, 100, 100, 100
    MOVE G6C,100,  35,  80, 100, 117, 100
    WAIT

    RETURN
    '******************************************
JLturn20:

    GOSUB 자이로OFF

    GOSUB Leg_motor_mode1

    SPEED 8
    MOVE G6D,100,  54, 145,  98, 100, 100
    MOVE G6A,100,  88, 155,  93, 102, 100

    '76
    '71

    MOVE G6D,100,  76, 145,  93, 100, 100
    MOVE G6A,100,  76, 145,  93, 100, 100

    WAIT

    DELAY 200



    RETURN
    '*******************************************

JRturn20:

    GOSUB 자이로OFF

    GOSUB Leg_motor_mode1

    SPEED 8
    MOVE G6A,100,  54, 145,  93, 102, 100
    MOVE G6D,100,  88, 155,  88, 100, 100

    '76
    '71

    MOVE G6A,100,  76, 145,  93, 100, 100
    MOVE G6D,100,  76, 145,  93, 100, 100

    WAIT

    DELAY 200


    RETURN
    '*******************************************
JLturn05:

    GOSUB 자이로OFF

    GOSUB Leg_motor_mode1

    SPEED 5
    MOVE G6D,100,  76, 145,  93, 100, 100
    MOVE G6A,100,  76, 145,  93, 100, 100

    SPEED 5
    MOVE G6D,102,  76, 145,  93, 102, 100
    MOVE G6A,100,  83, 145,  86, 100, 100

    MOVE G6D,100,  76, 145,  93, 100, 100
    MOVE G6A,100,  76, 145,  93, 100, 100

    WAIT

    DELAY 200



    RETURN
    '*******************************************
JRturn05:

    GOSUB 자이로OFF

    GOSUB Leg_motor_mode1

    SPEED 5
    MOVE G6D,100,  76, 145,  93, 100, 100
    MOVE G6A,100,  76, 145,  93, 100, 100

    SPEED 5
    MOVE G6D,102,  76, 145,  95, 103, 100
    MOVE G6A,100,  69, 145, 102, 100, 100

    MOVE G6D,100,  76, 145,  93, 100, 100
    MOVE G6A,100,  76, 145,  93, 100, 100

    WAIT

    DELAY 200



    RETURN
    '******************************************
JLSWalk2:
    GOSUB 자이로OFF

    GOSUB Leg_motor_mode2

    SPEED 12
    MOVE G6A, 91,  91, 120, 103, 103, 100	
    MOVE G6D, 99,  76, 146,  93, 101, 100	
    WAIT

    SPEED 15
    MOVE G6A,98,  76, 146,  94, 100, 100
    MOVE G6D,99,  76, 146,  94,  99, 100
    WAIT

    SPEED 8
    MOVE G6A,100,  76, 145,  93, 100, 100
    MOVE G6D,100,  76, 145,  93, 100, 100
    WAIT

    RETURN
    '******************************************	
JRSWalk2:
    GOSUB 자이로OFF

    GOSUB Leg_motor_mode2

    SPEED 12
    MOVE G6D, 91,  91, 120, 103, 103, 100	
    MOVE G6A,100,  76, 146,  93, 101, 100	
    WAIT

    SPEED 15
    MOVE G6D,98,  76, 146,  94, 100, 100
    MOVE G6A,98,  76, 146,  94, 100, 100
    WAIT

    SPEED 8
    MOVE G6D,100,  76, 145,  93, 100, 100
    MOVE G6A,100,  76, 145,  93, 100, 100
    WAIT

    RETURN
    '******************************************
CamDown_bridge:
    SPEED 15
    MOVE G6A,100,  76, 145,  93, 100, 100
    MOVE G6D,100,  76, 145,  93, 100, 100
    MOVE G6B,100,  35,  80, 100, 100, 100
    MOVE G6C,100,  35,  80, 100, 170, 100
    WAIT
    RETURN
    '******************************************
Last:
    GOSUB 자이로OFF

    SPEED 5
    MOVE G6A,100,  145, 50, 120, 100, 100   '76  -60
    MOVE G6D,100,  145, 50, 120, 100, 100   '76  -63
    MOVE G6B,190,  13, 100
    MOVE G6C,190,  13, 100,    ,  190        '181
    WAIT

    SPEED 5
    MOVE G6A,100,  150, 55, 120, 100, 100   '76  -60
    MOVE G6D,100,  150, 55, 120, 100, 100   '76  -63
    MOVE G6B,190,  40, 100
    MOVE G6C,185,  40, 90,    ,  190        '181
    WAIT

    DELAY 400


    SPEED 10
    MOVE G6A,100,  150, 55, 120, 100, 100   '76  -60
    MOVE G6D,100,  150, 55, 120, 100, 100   '76  -63
    MOVE G6B,190,  13, 100
    MOVE G6C,185,  13, 90,    ,  190        '181
    WAIT

    GOSUB leg_motor_mode1


    '다리위에 올라가기
    SPEED 5
    MOVE G6A,100,  40, 160, 120, 100, 100   '76  -60
    MOVE G6D,100,  40, 160, 120, 100, 100   '76  -63
    MOVE G6B,190,  13, 100
    MOVE G6C,185,  13, 100,    ,  190        '181
    WAIT


    DELAY 200


    '**********************************************************
    '한쪽다리 들기
    SPEED 15
    MOVE G6A,102,  40, 170, 155, 100, 100
    MOVE G6D,100,  56, 124,  26, 100, 100
    MOVE G6B,183,  37,  72                   ''
    MOVE G6C,183,  37,  72,    ,  190  '구를때 방향
    WAIT

    DELAY 100


    '**********************************************************
    '양쪽다리들기
    SPEED 15
    MOVE G6D,100,  40, 120,  24, 100, 100
    MOVE G6A,100,  35, 120,  26, 100, 100     '16
    MOVE G6B,179,  37,  72                     ''
    MOVE G6C,179,  37,  72,    ,  190  '구를때 방향
    WAIT

    DELAY 150

    '팔뒤로 뻣어서 일어나려고 노력하기

    SPEED 15
    MOVE G6A,100, 108, 75,  53, 100, 100
    MOVE G6D,100, 109, 70,  56, 100, 100
    MOVE G6B,188, 174, 118
    MOVE G6C,186, 174, 118
    WAIT

    DELAY 400

    '*******



    ''일어나기

    SPEED 8
    MOVE G6A,100, 108, 85,  58, 100, 100
    MOVE G6D,100, 108, 85,  58, 100, 100
    MOVE G6B,188, 174, 118
    MOVE G6C,188, 174, 118
    WAIT

    SPEED 10
    MOVE G6A,100, 170,  73, 15, 100, 100
    MOVE G6D,100, 170,  73, 15, 100, 100
    MOVE G6B,188, 178, 120
    MOVE G6C,188, 178, 120,   , 190
    WAIT

    SPEED 10
    MOVE G6A,100, 170,  72, 15, 100, 100
    MOVE G6D,100, 170,  72, 15, 100, 100
    MOVE G6B,188, 100,  60
    MOVE G6C,188, 100,  60
    WAIT

    SPEED 8
    MOVE G6A,100, 162,  32,  115, 100, 100
    MOVE G6D,100, 162,  32,  115, 100, 100
    MOVE G6B,188, 100,  60
    MOVE G6C,188, 100,  60
    WAIT

    SPEED 7
    GOSUB 기본자세

    DELAY 500

    HIGHSPEED SETOFF
    GOSUB 자이로OFF
    GOSUB All_motor_mode2



    GOSUB All_motor_mode3

    SPEED 5
    MOVE G6A,100,  76, 145,  93, 100, 100
    MOVE G6D,100,  76, 145,  93, 100, 100
    MOVE G6B,100,  35,  80, 100
    MOVE G6C,100,  35,  80, 100
    WAIT

    RETURN
    '******************************************	

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
    GOSUB WooWalk2
    GOTO RX_EXIT

KEY7:
    ETX  4800,7
    GOSUB youngjin
    GOTO RX_EXIT

KEY8:
    ETX  4800,8
    GOSUB milkdown
    GOTO RX_EXIT

KEY9:
    ETX  4800,9
    GOSUB dooropen
    GOTO RX_EXIT

KEY10: '0
    ETX  4800,10
    GOSUB Last
    GOTO RX_EXIT

KEY11: ' ▲
    ETX  4800,11
    GOSUB UPSTAIR
    GOTO RX_EXIT

KEY12: ' ▼
    ETX  4800,12
    GOSUB DOWNSTAIR
    GOTO RX_EXIT
KEY13: '▶
    ETX  4800,13
    GOSUB JRWalk
    GOTO RX_EXIT

KEY14: ' ◀
    ETX  4800,14
    GOSUB JLWalk
    GOTO RX_EXIT

KEY15: ' A
    ETX  4800,15
    GOSUB jrwalk
    GOTO RX_EXIT

KEY16: ' POWER
    ETX  4800,16
    GOSUB CamDown_Orange
    GOTO RX_EXIT

KEY17: ' C
    ETX  4800,17
    GOSUB LWalks
    GOTO RX_EXIT

KEY18: ' E
    ETX  4800,18	
    GOSUB UPSTAIR
    GOTO RX_EXIT

KEY19: ' P2
    ETX  4800,19
    GOSUB JRturn05
    GOTO RX_EXIT

KEY20: ' B	
    ETX  4800,20
    GOSUB RSWalk
    GOTO RX_EXIT

KEY21: ' △
    ETX  4800,21
    GOSUB RWalk
    GOTO RX_EXIT

KEY22: ' *
    ETX  4800,22
    GOSUB JRturn05
    GOTO RX_EXIT

KEY23: ' G
    ETX  4800,23
    GOSUB DOWNSTAIR
    GOTO RX_EXIT

KEY24: ' #
    ETX  4800,24
    GOSUB JRturn20
    GOTO RX_EXIT

KEY25: ' P1
    ETX  4800,25
    GOSUB LAST
    GOTO RX_EXIT

KEY26: ' ■
    ETX  4800,26
    GOSUB SWalk
    GOTO RX_EXIT

KEY27: ' D
    ETX  4800,27
    GOSUB Walk_Mine3
    GOTO RX_EXIT

KEY28: ' ◁
    ETX  4800,28
    GOSUB jlwalk
    GOTO RX_EXIT

KEY29: ' □
    ETX  4800,29
    GOSUB lwalk
    GOTO RX_EXIT

KEY30: ' ▷
    ETX  4800,30
    GOSUB lsWalk
    GOTO RX_EXIT

KEY31: ' ▽
    ETX  4800,31
    GOSUB RWalks
    GOTO RX_EXIT

KEY32: ' F
    ETX  4800,32
    GOSUB Yellow
    GOTO RX_EXIT

KEY33: '
    ETX  4800,33
    GOSUB LWalk
    GOTO RX_EXIT

KEY34: '
    ETX  4800,34
    GOSUB RWalk
    GOTO RX_EXIT

KEY35: '
    ETX  4800,35
    GOSUB GO_FRONT2
    GOTO RX_EXIT

KEY36: '
    ETX  4800,36
    GOSUB SWalk
    GOTO RX_EXIT

KEY37: '
    ETX  4800,37
    GOSUB Chung_Rturn
    GOTO RX_EXIT

KEY38: '
    ETX  4800,38
    GOSUB Chung_Rturn
    GOTO RX_EXIT

KEY39: '
    ETX  4800,39
    GOSUB LSWalk
    GOTO RX_EXIT

KEY40: '
    ETX  4800,40
    GOSUB RSWalk
    GOTO RX_EXIT

KEY41: '
    ETX  4800,41
    GOSUB Chung_Rturn
    GOTO RX_EXIT

KEY42: '
    ETX  4800,42
    GOSUB Chung_Rturn
    GOTO RX_EXIT

KEY43: '
    ETX  4800,43
    GOSUB Chung_Rturn
    GOTO RX_EXIT


    END
