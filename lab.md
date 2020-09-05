---
layout: page

title: 실습
---

## Lab#1

#### 1. 나의 첫 ChucK 프로그램

- `SinOsc` 발진기(oscillator)로 아래 나열한 주파수(frequency, pitch)와 소리크기(loudness, gain, volume)를 바꾸어 가며 소리의 차이를 들어보자.
  - 주파수: 220, 330, 440, 660Hz
  - 소리크기: 0.25, 0.5, 0.75, 1.0
- 이번엔 발진기를 `TriOsc`, `SqrOsc`, `SawOsc`로 각각 바꾸어 소리의 차이를 들어보자.

#### 2. 학교종

주파수 표를 참고하여 다음 `학교종` 곡을 연주하는 프로그램을 작성하자. 

![학교종](https://i.imgur.com/FcCZKh0.png)

![Cmajor](https://i.imgur.com/hFYouk4.png)

![piano](https://i.imgur.com/wQ5z43X.png)

- 먼저 진동기를 선택하여 `dac`에 연결하자. `SinOsc`를 선택하였다면 다음과 같이 연결한다.
```
SinOsc s => dac;
```
- 사용할 음의 계명에 해당하는 주파수를 표에서 찾아 변수로 지정하자. 주파수는 소수점 첫째 자리까지만 써도 충분하다. 이 곡에서 쓰는 계명은 도(C), 레(D), 미(E), 솔(G), 라(A) 이다. 예를 들어 솔(G)은 다음과 같이 선언하고 지정한다.
```
391.0 => float G;
```
- 한 박자를 0.5초로 하자. 그런데 각 음사이에 약간의 끊김이 필요하니 실제 소리가 나는 시간은 0.45초, 남은 0.05초는 소리가 나지 않게 한다.
이 정보를 다음과 같이 두 변수를 지정하여 기억하게 한다. 
```
0.45::second => dur on;
0.05::second => dur off;
``` 
- 이제 악보의 앞에서 부터 계명대로 소리를 내게 한다. 즉, 솔(G) 한 박자를 소리나게 하려면 다음과 같이 한다.
```
G => s.freq;
1 => s.gain;
on => now;
0 => s.gain;
off => now;
``` 
- 한 음씩 코드를 만들 다음, 실행 버튼을 눌러 수시로 제대로 박자에 맞게 소리가 나는지 확인한다.
- 완성하면 `schoolbells.ck` 이름으로 파일로 저장하여, 파일을 제출한다.


#### 3. Where Is Thumbkin?

주파수 표를 참고하여 다음 곡을 연주하는 프로그램을 작성하자.

![WhereIsThumbkin](https://i.imgur.com/74f4Bif.png)


