class findline(cap):
    # Fine Line 변수------------------------------------
    cnt = 0
    yellow = [1, 0]  # [0]=노란색이 있을 경우:0 노란색이 없을 경우:1  [1]=노란색이 없었을경우 모션에 따른 순서
    x = 0
    y = 0  # 대각선의 방향 판별을 위한 엣지의 x,y값 저장해 놓을 변수
    y_right = 0
    y_left = 0
    count_yellow = 0
    num = 5  # 대각선 확인을 위한 좌우 픽셀 차이값
    mid = 120  # 중심 예상값
    start = 0
    end = 0
    prev = 0
    count = 0  # toggle되는 구간인 start와 end를 구하기 위한 카운트 값 count=0이면 start count=1이면 end값
    # ----------------------------------------
    
    while True:
        ret, img = cap.read()
        if not ret:
            break
        if cnt < 20:
            cnt += 1
            continue;

        img_hsv = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)
        H = img_hsv[:, :, 0]
        S = img_hsv[:, :, 1]
        _, H_upper = cv2.threshold(H, 60, 255, cv2.THRESH_BINARY_INV)
        _, H_lower = cv2.threshold(H, 15, 255, cv2.THRESH_BINARY)
        _, S_lower = cv2.threshold(S, 100, 255, cv2.THRESH_BINARY)

        H = cv2.bitwise_and(H_upper, H_lower)
        H = cv2.bitwise_and(H, S_lower)

        kernel = np.ones((3, 3), np.uint8)
        result = cv2.morphologyEx(H, cv2.MORPH_OPEN, kernel)
        canny = cv2.Canny(result, 100, 255)

        for yy in range(240):
            for xx in range(320):
                if canny[yy, xx] != 0:
                    count_yellow += 1
                    if count_yellow == 30:
                        yellow[0] = 0
                        x = xx
                        y = yy
                        count_yellow = 0
                        break;
                else:
                    yellow[0] = 1
            if yellow[0] == 0:
                break;

        if yellow[0] == 0:  # 노란색 발견!
            if yellow[1] == 1 or yellow[1] == 4:  # 왼쪽 보고 있을때 발견한 경우
                if yellow[1] == 4:
                    print("go forward")
                print("go left")
            elif yellow[1] == 2 or yellow[1] == 5:  # 오른쪽 보고 있을때 발견한 경우
                if yellow[1] == 5:
                    print("go forward")
                print("go right")
            elif yellow[1] == 0 or yellow[1] == 3:
                if yellow[1] == 3:
                    print("go forward")
                else:
                    for n in range(240):
                        if int(x - num) <= 0:
                            if canny[n, 1] != 0:
                                y_left = n
                            if canny[n, int(x + num)] != 0:
                                y_right = n
                        elif int(x + num) >= 320:
                            if canny[n, int(x - num)] != 0:
                                y_left = n
                            if canny[n, 319] != 0:
                                y_right = n
                        else:
                            if canny[n, int(x - num)] != 0:
                                y_left = n
                            if canny[n, int(x + num)] != 0:
                                y_right = n
                    if y_left == 0 or y_right == 0:
                        for n in range(320):
                            if canny[120, n] != 0:
                                if prev == 0 and count == 1:
                                    end = n
                                    prev = 1
                                elif prev == 0:
                                    count += 1
                                    start = n
                                    prev = 1
                            else:
                                if prev == 1:
                                    prev = 0
                        count = 0
                        if mid >= start and mid <= end:
                            print("찾았다!")
                            break;
                        elif mid < start:
                            print("오른쪽으로 걷기!")
                        elif mid > end:
                            print("왼쪽으로 걷기!")
                        else:
                            print("Error!")
                        count_yellow = 0
                    elif y_left > y_right:
                        print("왼쪽으로 회전")
                    elif y_right > y_left:
                        print("오른쪽으로 회전")
                    else:
                        continue
                    y_left = 0
                    y_right = 0
            else:
                continue

            yellow[1] = 0
        elif yellow[0] == 1:  # 노란색 발견X!
            if yellow[1] == 0:  # 고개 숙이고 봤었을때 없었을 경우
                print("Not Y_1-1")
                yellow[1] += 1
                # 왼쪽으로 고개 돌리기
            elif yellow[1] == 1:  # 고개 숙인채 왼쪽으로 돌리고도 없었을 경우
                print("Not Y_1-2")
                yellow[1] += 1
                # 오른쪽으로 고개 돌리기
            elif yellow[1] == 2:  # 고개 숙인채 오른쪽으로 돌리고도 없었을 경우
                print("Not Y_1-3")
                yellow[1] += 1
                # 고개 살짝 들기
                # 정면 보기
            elif yellow[1] == 3:  # 고개 든채 정면으로 돌리고도 없었을 경우
                print("Not Y_2-1")
                yellow[1] += 1
                # 왼쪽으로 고개 돌리기
            elif yellow[1] == 4:  # 고개 든채 왼쪽으로 돌리고도 없었을 경우
                print("Not Y_2-2")
                yellow[1] += 1
                # 오른쪽으로 고개 돌리기
            elif yellow[1] == 5:  # 고개 든채 오른쪽으로 돌리고도 없었을 경우
                print("Not Y_2-3")
                yellow[1] = 0
                # 뒤돌기
                # 고개 숙이기

