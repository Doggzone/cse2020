---
layout: page
title: 실습
---

## Lab#5

#### 1

함수를 활용하여 Lab#4-1에서 작성한 프로그램을 개선해보자.

주어진 `audio` 폴더에 있는 12개의 샘플의 소리를 차례로 모두 들어볼 수 있도록 작성한 프로그램은 같은 패턴의 코드가 12번 반복되어 코드가 길어지고 가독성이 낮다.

Lab#4-1에서 작성한 코드와 똑같이 작동하도록 아래 코드의 `......` 부분을 채워서 `hearSample` 함수를 완성해보자.

```
SndBuf sample => dac;

me.dir() => string path; 

hearSample(sample, path + "audio/clap_01.wav"); 
hearSample(sample, path + "audio/click_01.wav"); 
hearSample(sample, path + "audio/click_02.wav"); 
hearSample(sample, path + "audio/cowbell_01.wav"); 
hearSample(sample, path + "audio/hihat_01.wav"); 
hearSample(sample, path + "audio/hihat_04.wav"); 
hearSample(sample, path + "audio/kick_01.wav"); 
hearSample(sample, path + "audio/snare_01.wav"); 
hearSample(sample, path + "audio/snare_02.wav"); 
hearSample(sample, path + "audio/snare_03.wav"); 
hearSample(sample, path + "audio/stereo_fx_01.wav"); 
hearSample(sample, path + "audio/stereo_fx_03.wav"); 

fun void hearSample(SndBuf sample, string where) {
	......
}
```

#### 2

다음의 5개의 파라미터를 인수로 받아서 소리를 내는 프로시저 함수 `playNote` 함수를 작성해보자.
- `Osc osc` : 소리 진동기
- `int note` : MIDI 음계
- `dur duration` : 	`note` 음의 재생 시간
- `float gain` : `note` 음의 음량 (`0.0~1.0`)
- `dur tail` : 여러 음을 연속 재생하는 경우 연결음을 구분하기 위하여 끝 부분에서 소음하는 시간의 길이

이 함수를 호출하면 `osc` 진동기로 `note` 음을 `gain`의 크기로 `duration` 길이 만큼 재생한다. 단, 음 뒷 부분의 `tail` 길이 만큼은 소음한다. 즉, 실제로 소리나는 시간은 `duration - tail` 이다.

```
fun void playNote(Osc osc, int note, dur duration, float gain, dur tail) {
    ...
}
```

#### 3

다음의 5개의 파라미터를 인수로 받아서 소리를 내는 프로시저 함수 `playNotes` 함수를 작성해보자.
- `Osc osc` : 소리 진동기
- `int notes[]` : MIDI 음계 배열 (`-1`은 쉼표를 나타낸다.)
- `dur durs[]` : 음의 재생 시간 배열
- `float gain` : 음량 (`0.0~1.0`)
- `dur tail` : 여러 음을 연속 재생하는 경우 연결음을 구분하기 위하여 소음하는 시간의 길이

이 함수를 호출하면 `osc` 진동기로 `notes` 배열에 나열된 음을 `gain`의 크기로 `duration` 배열에 나열된 길이 만큼 앞에서부터 차례로 재생한다. 단, 각 음 뒷 부분의 `tail` 길이 만큼은 소음한다.

```
fun void playNotes(Osc osc, int notes[], dur durs[], float gain, dur tail) {
    ...
}
```

#### 4

Lab#5-3에서 작성한 `playNotes` 함수를 활용하여 Lab#3-2에서 작성한 Beverly Hill Cops 영화 주제곡 프로그램을 개선해보자.


#### 5

Lab#5-2에서 작성한 `playNote` 함수와 Lab#5-3에서 작성한 `playNotes` 함수를 활용하여 Lab#3-3에서 작성한 베토벤의 `엘리제를 위하여` 프로그램을 개선해보자.


#### 6

Lab#4-3에서 작성한 프로그램을 다음 함수 2개를 활용하여 재작성해보자.

```
fun void playDrum(SndBuf drum, int hits[], int beat) {
    if (hits[beat])
        0 => drum.pos;
}
```


```
fun void leadVoice(Osc sound, int distance, float volume, int low, int high) {
    Math.random2(0,distance-1) => int play;
    Math.random2(low,high) => int note;
    if (play == 0) {
        Std.mtof(note) => sound.freq;
        volume => sound.gain;
    }
    else
        0.0 => sound.gain;
}
```





## Lab#4

#### 1

교재에서 주어진 `audio` 폴더에는 12개의 소리 파일 샘플이 들어있다. 각 샘플의 소리를 차례로 모두 들어볼 수 있도록 프로그램을 만들어보자. 각 샘플이 내는 소리의 길이는 다양하다. 샘플의 길이는 `samples()`(샘플의 개수를 `int` 값으로 리턴) 또는 `length()`(샘플의 길이를 `dur` 값으로 리턴) 메소드를 호출하여 알아낼 수 있다. 샘플의 끝까지 소리내야 하고 (방법은 아래 예 참조), 각 샘플 사이에 1초의 간격을 둔다. 

```
SndBuf sample => dac;
... 
sample.samples() :: samp => now;
```

또는 

```
SndBuf sample => dac;
... 
sample.length() => now;
```

아울러 각 소리 샘플의 파일 명과 소리 샘플의 길이를 초 단위로 콘솔 모니터에 프린트한다.

#### 2

`Listing4.9.sk` 파일의 프로그램을 다음과 같이 수정해보자.
- `hihat_01.wav` 소리 샘플을 2, 5, 6 박자에 소리나도록 추가한다.
- `Gain` `UGen`으로 세 개의 소리를 믹스하는 대신, 스테레오 스피커에서 하나는 중앙, 다른 하나는 오른쪽, 또 다른 하나는 왼쪽에서 소리나도록 분리한다. (좌우 채널 분리 방법은 `Listing4.5.ck` 참고)  

#### 3

`Listing4.10.sk` 파일의 프로그램에서 다음을 추가해보자.
- 비트 박자와 같이 맞추어 `SawOsc` 소리를 1/3 확률로 랜덤하게 낸다.
- 계명은 MIDI 60~72 범위에서 무작위로 낸다. 
- 소리의 볼륨은 0.3으로 한다.

#### 4

`Listing4.12.sk` 파일의 프로그램에서 다음을 추가해보자.
- 8째 마디에서 시작하여 비트 박자와 같이 맞추어 `SqrOsc` 소리를 1/3 확률로 랜덤하게 낸다.
- 계명은 MIDI 60~72 범위에서 무작위로 낸다. 
- 소리의 볼륨은 0.5로 한다.


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

#### 4

Lab#1.3~4에서 작성한 다음 곡을 연주하는 프로그램을 MIDI와 배열을 사용하여 재작성해보자.

![학교종](https://i.imgur.com/FcCZKh0.png)

#### 5

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

