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
    '****************************************
    
backstep:
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
    
    
