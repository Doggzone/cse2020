---
layout: page

title: 실습
---

## Lab#2

### 1. 반음계 연주 (소요 예상시간: 25분, 제출할 필요 없음)

![chromaticscale](https://i.imgur.com/oAMq9Jq.png)

반음계(chromatic scale)를 위 악보와 같이 연주하는 프로그램을 다음과 같이 작성할 수 있다.

```
SqrOsc scale => dac;

// note length
0.3::second => dur quarter_note;
quarter_note => dur qn; // quarter note (1/4)
quarter_note * 2 => dur hn; // half note (1/2)

// volume
0.5 => scale.gain;

// play
for (48 => int i; i <= 60; i++) {
    Std.mtof(i) => scale.freq;
    if (i == 60)
        hn => now;
    else
        qn => now;
}
for (60 => int i; i >= 48; i--) {
    Std.mtof(i) => scale.freq;
    if (i == 48)
        hn => now;
    else
        qn => now;
}
```

이 프로그램을 실행하여 소리를 들어보자. 
음과 음 사이에 간격이 전혀 없어 같은 음이 연속으로 나는 경우 이어서 들린다. 
음의 뒷 부분의 일부(4분음표 길이의 1/6)를 소리를 나지 않게 하여, 
이어지는 음 사이 끊어서 들리도록 다음 코드를 활용하여 위 프로그램을 수정해보자.

```
// note length
0.3::second => dur quarter_note;
quarter_note * (5.0/6) => dur qn; // quarter note sound (1/4)*(5/6)
quarter_note / 6 => dur qn_rest; // quarter note no sound (1/4)*(1/6)
qn * 2 => dur hn; // half note sound 
qn_rest * 2 => dur hn_rest; // half note no sound

// volume
0.5 => float on;
0.0 => float off;
```

주의: `5/6`과 `5.0/6`의 차이점을 확인하고 넘어가자.


### 2. A Random Love Supreme (소요 예상시간: 75분, 제출할 필요 없음)

- 아래 악보를 `SinOsc`로 무한 반복하여 연주하는 프로그램을 만들자. 
첫 음은 A3로 MIDI 번호로 57이다.
각 음을 소리내는 요령은 앞 문제와 동일하게 한다. (음당 소리의 on:off 비율이 5:1) 

![97878](https://i.imgur.com/MAGrxzH.jpg)

- 마디를 반복할 때마다 각 음을 MIDI 번호 기준 `-12 ~ +12` 범위에서 랜덤하게
높이거나 낮추어서 연주하도록 프로그램을 수정하자.

- `Pan2` 객체를 활용하여 마디를 반복할 때마다 랜덤하게 소리가 나는 위치가 변하도록
프로그램을 수정하자.

- 듀엣으로 화음에 맞추어 연주하기 위하여 다음 악보와 같이 하단을 추가하였다.
악보 하단을 `TriOsc`로 악보 상단과 함께 듀엣으로 연주하도록 프로그램을 확장하자.
하단 음은 D3이다.

![73192](https://i.imgur.com/oJbjS86.jpg)

- 악보 하단을 1/8의 확률로 랜덤하게 선택하여 연주하도록 프로그램을 수정하자.
다시 말하면, 악보 상단은 쉬지않고 되풀이 하지만, 악보 하단은 8번에 1번 정도만 연주하게 한다.





## Lab#1


### 1. 나의 첫 ChucK 프로그램

-	`SinOsc` 발진기(oscillator)로 아래 나열한 주파수(frequency, pitch)와 소리크기(loudness, gain, volume)를 바꾸어 가며 소리의 차이를 들어보자.
	-	주파수: 220, 330, 440, 660Hz
	-	소리크기: 0.25, 0.5, 0.75, 1.0
-	이번엔 발진기를 `TriOsc`, `SqrOsc`, `SawOsc`로 각각 바꾸어 소리의 차이를 들어보자.

### 2. 학교종

주파수 표를 참고하여 다음 `학교종` 곡을 연주하는 프로그램을 작성하자.

![School Bells](https://i.imgur.com/y7zaem9.png)

![Frequency Table](https://i.imgur.com/9yx6sau.png)

![Cmajor](https://i.imgur.com/hFYouk4.png)

![piano](https://i.imgur.com/wQ5z43X.png)

-	먼저 진동기를 선택하여 `dac`에 연결하자. `SinOsc`를 선택하였다면 다음과 같이 연결한다.

```
SinOsc s => dac;
```

-	사용할 음의 계명에 해당하는 주파수를 표에서 찾아 변수로 지정하자. 주파수는 소수점 첫째 자리까지만 써도 충분하다. 이 곡에서 쓰는 계명은 도(C), 레(D), 미(E), 솔(G), 라(A) 이다. 예를 들어 솔(G)은 다음과 같이 선언하고 지정한다.

```
391.0 => float G;
```

-	한 박자를 0.5초로 하자. 그런데 각 음사이에 약간의 끊김이 필요하니 실제 소리는 반인 0.25초만 나게하고, 남은 0.25초는 소리가 나지 않게 한다. 이 정보를 다음과 같이 두 변수를 지정하여 기억하게 한다.

```
0.25::second => dur beat;
```

-	이제 악보의 앞에서 부터 계명대로 소리를 내게 한다. 즉, 솔(G) 한 박자를 소리나게 하려면 다음과 같이 한다.

```
G => s.freq;
1 => s.gain;
beat => now;
0 => s.gain;
beat => now;
```

-	한 음씩 코드를 만들 다음, 실행 버튼을 눌러 수시로 제대로 박자에 맞게 소리가 나는지 확인한다.
-	완성하면 `schoolbells.ck` 이름으로 파일로 저장해둔다. 제출할 필요는 없다.

### 3. Where Is Thumbkin?

주파수 표를 참고하여 다음 곡을 연주하는 프로그램을 작성하자. 

![WhereIsThumbkin](https://i.imgur.com/XkKuqjm.png)

완성하면 `thumbkin.ck` 이름으로 파일로 저장하고, 파일을 제출한다.
