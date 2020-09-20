---
layout: page

title: 실습
---

## Lab#3

![MusicalNotes](https://i.imgur.com/wBRfkeW.png) 
![RegularNotes](https://i.imgur.com/IAUOPIY.png) 
![DottedNotes](https://i.imgur.com/gTJM0Ir.png)

### 1. C major Scale

![Cmajor Scale](https://i.imgur.com/8lPX0lP.png)

MIDI 음번호와 배열을 사용하여 C major Scale을 
위 악보와 같이 연주하는 ChucK 프로그램을 아래와 같이 작성하였다.
코드를 이해한 다음 실행해보자.

```
SinOsc s => dac;

// volume
0.6 => float on;
0.0 => float off;

// note length
0.5::second => dur beat; // quarter (1/4) note duration
beat / 5 => dur rest; // duration of no sound after each note
beat - rest => dur qn; // quarter (1/4) note sound

// MIDI notes
[60, 62, 64, 65, 67, 69, 71, 72, 
     71, 69, 67, 65, 64, 62, 60] @=> int scaleNotes[];

// play
for (0 => int i; i < scaleNotes.cap(); i++) {
    Std.mtof(scaleNotes[i]) => s.freq;
    on => s.gain;
    qn => now;
    off => s.gain;
    rest => now;
}
```

### 2. 학교종

다음 곡을 악보대로 연주하는 프로그램을 MIDI와 배열을 사용하여 작성하자.

![SchoolBells](https://i.imgur.com/4maIvOY.png)

### 3. Where Is Thumbkin?

다음 곡을 악보대로 연주하는 프로그램을 MIDI와 배열을 사용하여 작성하자.

![Where Is Thumbkin?](https://i.imgur.com/qFoAyA5.png)


### 4. Theme from Beverly Hill Cops

다음은 Beverly Hill Cops 영화 주제곡 도입 부분의 악보를 MIDI 계명과 음표 배열로 작성한 것이다.

```
// Harold Faltermeyer's Theme from the film Beverly Hills Cop (1984)
[65, -1, 68, -1, 65, 65, 70, 65, 63,
 65, -1, 72, -1, 65, 65, 73, 72, 68,
 65, 72, 77, 65, 63, 63, 60, 67, 65] @=> int bhcopNotes[];

[qn, qn, qn, en, qn, en, qn, qn, qn,
 qn, qn, qn, en, qn, en, qn, qn, qn,
 qn, qn, qn, en, qn, en, qn, qn, hn] @=> dur bhcopDurs[];
```

MIDI 음 배열의 -1은 쉼표를 나타낸다. 이 악보를 `TriOsc`로 연주하도록 프로그램을 완성해보자. 같은 음이 연속되는 경우 음이 이어지는 것을 방지하기 위할 용도로 `rest` 변수를 활용하자.

### 5. For Elise

다음은 베토벤의 `엘리제를 위하여`의 도입 부분의 악보이다. 
이를 연주하는 프로그램을 MIDI와 배열을 사용하여 작성해보자.

![forElise](https://i.imgur.com/Gsed2sv.png)

```
// note length
0.3::second => dur sn; // sixteenth (1/16)
0.6::second => dur en; // eighth (1/8)

// For Elise by Beethoven
[76, 75, 76, 75, 76, 71, 74, 72, 69] @=> int forEliseNotes1[];
[sn, sn, sn, sn, sn, sn, sn, sn, en] @=> dur forEliseDurs1[];
[60, 64, 69, 71] @=> int forEliseNotes2[];
[sn, sn, sn, en] @=> dur forEliseDurs2[];
[64, 68, 71, 72] @=> int forEliseNotes3[];
[sn, sn, sn, en] @=> dur forEliseDurs3[];
[64, 72, 71, 69] @=> int forEliseNotes4[];
[sn, sn, sn, en] @=> dur forEliseDurs4[];
```

악보에 표시된 대로 두 번 반복해야 한다.

그리고 악보에 연속 이어지는 음이 없으므로,
이번엔 음의 끝 부분의 소리를 죽이지 말고 박자 전체를 소리나게 해보자.






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
하단 음은 C4# C4 C4b 이다.

![57233](https://i.imgur.com/B4BhpyZ.jpg)

- 악보 하단을 1/4의 확률로 랜덤하게 선택하여 연주하도록 프로그램을 수정하자.
다시 말하면, 악보 상단은 쉬지않고 되풀이 하지만, 악보 하단은 4번에 1번 정도만 연주하게 한다.






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
