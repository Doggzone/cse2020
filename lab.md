---
layout: page
title: 실습
---

## Lab#2

#### 1

Listing 2.1 코드를 `for` 루프 대신 `while` 루프를 사용하여 똑같이 작동하도록 재작성하자. 그리고 실행하여 자신이 들을 수 있는 주파수 영역을 찾아보자.

#### 2

![MusicalNotes](https://i.imgur.com/uOZUoEy.png)

반음계(chromatic scale)를 위와 같이 연주하는 프로그램을 다음과 같이 작성할 수 있다.

![chromaticscale](https://i.imgur.com/oAMq9Jq.png)

```
SqrOsc scale => dac;

// note length
0.3::second => dur qn; // quarter note (1/4)
0.6::second => dur hn; // half note (1/2)

1.0 => scale.gain;

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

이 프로그램을 실행하여 소리를 들어보자. 음과 음 사이에 간격이 전혀 없어 같은 음이 연속으로 나는 경우 이어져 들린다. 음의 뒷 부분의 일부(4분음표 길이의 1/6)를 소리를 나지 않게 하여, 이어지는 음 사이 끊어서 들리게 다음 코드를 활용하여 위 프로그램을 수정해보자.

```
// note length
0.25::second => dur qn; // quarter (1/4 박자)
0.55::second => dur hn; // half note (1/2 박)
0.05::second => dur rest; // 무음 : qn의 1/6

// volume
1.0 => float onGain;
0.0 => float offGain;
```

#### 3

Listing 2.8 코드를 Math.srandom() 함수를 사용하여 seed를 지정하고 실행해보자. 그리고 가장 마음에 드는 음악을 만들어내는 seed 값을 찾아보자.

#### 4

`SinOsc`와 `Pan2` 진동기를 사용하여 다음 조건을 만족하면서 소리를 랜덤하게 무한히 반복하여 만들어내는 프로그램을 만들어보자.

-	음은 MIDI 60~72 사이의 음을 랜덤하게 선택
-	각 음의 음량(소리 크기)은 0.2~0.8 범위에서 랜덤하게 선택
-	각 음의 패닝 위치는 -0.1~1.0 범위에서 랜덤하게 선택
-	각 음의 길이는 0.2~0.6초 범위에서 랜덤하게 선택





## Lab#3

![MusicalNotes](https://i.imgur.com/wBRfkeW.png) ![RegularNotes](https://i.imgur.com/IAUOPIY.png) ![DottedNotes](https://i.imgur.com/gTJM0Ir.png)

#### 1

![Cmajorscale](https://i.imgur.com/fxL4hiB.png)

C major scale을 위의 악보와 같이 연주하는 프로그램을 MIDI 음 배열을 사용하여 작성해보자.

#### 2

다음은 Beverly Hill Cops 영화 주제곡 도입 부분의 악보를 MIDI 계명과 음표 배열로 작성한 것이다.

```
0.1 :: second => dur en; // eighth (1/8)
0.25 :: second => dur qn; // quarter (1/4)
0.55 :: second => dur hn; // half (1/2)
0.05 :: second => dur rest;

// Harold Faltermeyer's Theme from the film Beverly Hills Cop (1984)
[65, -1, 68, -1, 65, 65, 70, 65, 63,
 65, -1, 72, -1, 65, 65, 73, 72, 68,
 65, 72, 77, 65, 63, 63, 60, 67, 65] @=> int bhcopNotes[];

[qn, qn, qn, en, qn, en, qn, qn, qn,
 qn, qn, qn, en, qn, en, qn, qn, qn,
 qn, qn, qn, en, qn, en, qn, qn, hn] @=> dur bhcopDurs[];
```

MIDI 음 배열의 -1은 쉼표를 나타낸다. 이 악보를 `TriOsc`로 연주하도록 프로그램을 완성해보자. 같은 음이 연속되는 경우 음이 이어지는 것을 방지하기 위할 용도로 `rest` 변수를 활용하자.

#### 3

다음은 베토벤의 `엘리제를 위하여`의 도입 부분의 악보이다. 이를 연주하는 프로그램을 MIDI와 배열을 사용하여 작성해보자.

![forElise](https://i.imgur.com/Gsed2sv.png)

```
0.3::second => dur s; // sixteenth (1/16)
0.6::second => dur e; // eighth (1/8)

// For Elise by Beethoven
[76, 75, 76, 75, 76, 71, 74, 72, 69] @=> int forEliseNotes1[];
[ s,  s,  s,  s,  s,  s,  s,  s,  e] @=> dur forEliseDurs1[];
[60, 64, 69, 71] @=> int forEliseNotes2[];
[ s,  s,  s,  e] @=> dur forEliseDurs2[];
[64, 68, 71, 72] @=> int forEliseNotes3[];
[ s,  s,  s,  e] @=> dur forEliseDurs3[];
[64, 72, 71, 69] @=> int forEliseNotes4[];
[ s,  s,  s,  e] @=> dur forEliseDurs4[];
```

악보에 표시된 대로 두 번 반복해야 한다.

#### 4 (Option)

Lab#1.3~4애서 작성한 다음 곡을 연주하는 프로그램을 MIDI와 배열을 사용하여 재작성해보자.

![학교종](https://i.imgur.com/FcCZKh0.png)

#### 5 (Option)

Lab#1.6에서 작성한 곡을 다음 악보대로 화음으로 연주하는 프로그램을 MIDI와 배열을 사용하여 재작성해보자.

![Where Is Thumbkin 2](https://i.imgur.com/ajiw85k.png)



## Lab#1

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

음의 기준은 피아노의 4옥타브의 라(A)이며 이 음의 주파수는 440Hz이다.
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

이번에는 같은 곡을 다음 악보대로 화음으로 연주하는 프로그램을 작성하자.

![Where Is Thumbkin 2](https://i.imgur.com/ajiw85k.png)

발진기는 배운 네 가지 중에서 어떤 것을 사용해도 좋다.

