---
layout: page
title: 실습
---

### Lab#1

#### 1 
콘솔 모니터에 아래 문장을 프린트하는 프로그램을 작성하자.
```
Hello, Computer Music!
```

#### 2 
다음의 네 가지 발진기(oscillator)로 소리크기(loudness, gain) 0-1 범위와 주파수(frequency, pitch) 200-800 Hz 범위에서 2초간 소리를 내는 프로그램을 작성하여 발진기와 소리크기, 주파수 별로 어떤 소리가 나는지 시험해보자.
- `SinOsc`
- `SqrOsc`
- `TriOsc`
- `SawOsc`

#### 음계별 주파수

![PianoKeys](https://i.imgur.com/lrf0W0b.png)

음의 기준은 피아노의 4옥타브의 라(A)이며 이음의 주파수는 440Hz이다.
인접하는 음계 사이의 주파수는 2^(1/12)배 만큼 차이가 나며,
같은 음계에서 옥타브가 올라갈 때마다 2배씩 주파수가 증가한다.

계산 결과는 다음과 같다.

![FrequencyTable](https://i.imgur.com/Nu8Bq6j.png)


![Cmajor](https://i.imgur.com/hFYouk4.png)

![piano](https://i.imgur.com/wQ5z43X.png)

#### 3

위 표의 주파수를 참고하여 다음 `학교종` 곡을 연주하는 프로그램을 작성하자. 

![학교종](https://i.imgur.com/FcCZKh0.png)

#### 4

계명 별로 변수를 선언하여 위의 `학교종` 프로그램을 재작성하자.

#### 5

위 표의 주파수를 참고하여 다음 곡을 연주하는 프로그램을 작성하자.

![WhereIsThumbkin](https://i.imgur.com/74f4Bif.png)

#### 6

