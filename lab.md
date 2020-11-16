---
layout: page

title: 실습
---

## Lab#10

### 1. `Listing 10.2`를 수정하여
키보드의 `1` `2` `3` `4` `5` 키를 누르면 
각각 `도` `레` `미` `파` `솔` 음이 나도록 만들어보자.
문자 '1'의 아스키코드 번호는 `31`이다.

### 2. 9장에서 공부한 Drum Machine을 이벤트를 활용하여 똑같이 작동하도록 재작성해보자. 



## Lab#9

### 1. `Player` 클래스 만들기

`Lab#8`에서 작성한 `playNote`, `play` 함수 메소드를 가진 클래스 `Player`를 정의하고, 이 클래스를 활용하여 Lab#8-3에 주어진 테스트 케이스를 실행해보자. 악기는 `Mandolin` 사용을 권장한다.

### 2. `BPM` 클래스 활용하여 Lab#8-3 코드를 객체지향으로 재작성하기

Listing 9.4에 정의된 `BPM` 클래스를 `dur` 타입의 `halfNote` 변수를 추가하여 재작성하고, 이를 활용하여 위 Lab#9-1에서 만든 코드를 재작성해보자.

### 3. Lab#8-4 코드를 객체지향으로 재작성하기

Lab#8-4 코드를 `Player`, `BPM` 클래스를 활용하여 재작성해보자. 이 문제를 풀기 위해서 추가로 필요한 1/6, 1/3, 온 박자를 처리할 수 있도록 `BPM` 클래스는 확장해야 한다. 

### 4. Lab#9-3 코드를 여러 파일로 나누어 구성하기

이번에는 `Player` 클래스는 `player.ck` 파일에 저장하고, `BPM` 클래스는 `BPM.ck` 파일에 저장하고, 나머지 부분은 `initialize.ck`, `score.ck` 파일로 나누어 작성하여 똑같이 작동하도록 해보자.

### 5. `Clarinet`을 상속하여 작성한 Listing 9.18의 `MyClarinet` 에 중복 메소드 추가하기

Listing 9.18의 `noteOn` 메소드는 MIDI 음에만 작동한다. 문자열로 표현한 계명과 실수 주파수 인수에도 작동하도록 두 개의 중복(overloading) 메소드를 추가해보자.


## Lab#8

### 1. `playNote` 함수 만들기

`StkInstrument` 악기, `int` 타입의 MIDI 음, `dur` 타입의 재생시간을 인수로 받아서, 주어진 악기로 주어진 재생시간동안 주어진 음을 스피커로 출력하는 프로시저 함수 `playNote`를 작성하자.

```
fun void playNote(StkInstrument instrument, int note, dur duration)
```

### 2. `play` 함수 만들기

`StkInstrument` 악기, `int` 타입의 MIDI 음 배열, `dur` 타입의 재생시간 배열을 인수로 받아서, 주어진 악기로 주어진 음 배열을 차례대로 주어진 재생시간 배열의 시간에 맞추어 스피커로 출력하는 프로시저 함수 `play`를 작성해보자. 각 음은 앞에서 작성한 `playNote` 함수를 사용해야 한다.

```
fun void play(StkInstrument instrument, int note[], dur duration[])
```

아래 코드를 테스트 케이스로 사용하여 실행해보자.

```
0.2::second => dur en; // eighth notes (1/8)
en * 2 => dur qn; // quarter notes (1/4)
qn * 2 => dur hn; // half notes (1/2)

[
65, 67, 69, 65,  65, 67, 69, 65,  69, 70, 72,  69, 70, 72,
72, 74, 72, 70, 69, 65, 72, 74, 72, 70, 69, 65, 65, 60, 65, 65, 60, 65
]
@=> int melody[];

[
qn, qn, qn, qn,  qn, qn, qn, qn, qn, qn, hn,  qn, qn, hn,
en, en, en, en, qn, qn, en, en, en, en, qn, qn, qn, qn, hn, qn, qn, hn
]
@=> dur melodyDur[];
```


### 3. 여러 음 동시에 내기

다음 악보는 Lab#1-3과 Lab#3-3에서 작성해본 적이 있는 곡이다.

![Where Is Thumbkin 2](https://i.imgur.com/ajiw85k.png)

2-3개의 다른 음을 동시에 내어 화음을 이룬다. 이번엔 `spork`를 사용하여 서로 다른 3개의 `shread`가 동시에 다른 소리를 내어 화음이 나도록 아래 코드를 참고하여 프로그램을 작성해보자. 악기는 자유로이 선택하고, 위에서 작성한 `play` 함수를 활용해도 좋다.

```
0.2::second => dur en; // eighth notes (1/8)
en * 2 => dur qn; // quarter notes (1/4)
qn * 2 => dur hn; // half notes (1/2)

[
65, 67, 69, 65,  65, 67, 69, 65,  69, 70, 72,  69, 70, 72,
72, 74, 72, 70, 69, 65, 72, 74, 72, 70, 69, 65, 65, 60, 65, 65, 60, 65
]
@=> int melody[];

[
65, 67, 69, 65,  65, 67, 69, 65,  69, 70, 72,  69, 70, 72, 
72, 74, 72, 70, 69, 65, 72, 74, 72, 70, 69, 65, 69, 64, 69, 69, 64, 69
]
@=> int high[];

[
qn, qn, qn, qn,  qn, qn, qn, qn, qn, qn, hn,  qn, qn, hn,
en, en, en, en, qn, qn, en, en, en, en, qn, qn, qn, qn, hn, qn, qn, hn
]
@=> dur melodyDur[];

[
53, 60, 53,  53, 60, 53,  53, 60, 53,  53, 60, 53,
53, 60, 53,  53, 60, 53,  53, 60, 53,  53, 60, 53
]
@=> int low[];

[
qn, qn, hn,  qn, qn, hn,  qn, qn, hn,  qn, qn, hn,
qn, qn, hn,  qn, qn, hn,  qn, qn, hn,  qn, qn, hn
]
@=> dur lowDur[];

```

### 4. 돌림노래

이번엔 다음 곡을 돌림노래로 연주해보자. 

![Row-Row-Row-Your-Boat](https://i.imgur.com/rvB5d4E.png)

4개의 개별 개체를 만들어 차례로 2 마디씩 늦게 연주를 시작하도록 하면 돌림노래가 완성된다. 악기는 자유로이 선택하고, 아래 코드와 위에서 작성한 `play` 함수를 활용해도 좋다.

```
// 6/8 박자
0.2::second => dur sn; // sixth note (1/6)
sn * 2 => dur tn; // third note (1/3)
sn * 3 => dur hn; // half note (1/2)
sn * 6 => dur wn; // whole note (1)

[
60, 60, 60, 62, 64,
64, 62, 64, 65, 67,
72, 72, 72, 67, 67, 67, 64, 64, 64, 60, 60, 60,
67, 65, 64, 62, 60
]
@=> int melody[];

[
hn, hn, tn, sn, hn, 
tn, sn, tn, sn, wn,
sn, sn, sn, sn, sn, sn, sn, sn, sn, sn, sn, sn,
tn, sn, tn, sn, wn
]
@=> dur melodyDur[];

```

### 5. Bach의 Crab Canon

[Bach’s Crab Canon](https://www.youtube.com/watch?v=xUHQ2ybTejU)

바하의 The Musical Offering에 포함되어 있는 Crab Canon은 음악적 팰린드롬이다. 그냥 순서대로 또는 거꾸로 한방향으로 연주해도 되고, 순서대로와 거꾸로를 동시에 양방향으로 연주해도 된다.

![CrabCanon](https://i.imgur.com/XBUxfWQ.png)

이 곡을 두개의 다른 악기를 사용하여 정방향과 역방향으로 동시에 연주하는 프로그램을 아래 MIDI 악보 코드를 활용하여 만들어보자. 힌트: 악보를 거꾸로 연주하는 함수를 따로 작성하여 사용하면 편리하다.

```
0.2::second => dur en; // eighth note (1/8)
en * 2 => dur qn; // quarter note (1/4)
en * 4 => dur hn; // half note (1/2)

// Bach Canon Score
[
60, 63, 67, 68, 59, -1, 
67, 66, 65, 64, 63, 62, 61, 60,
59, 55, 62, 65, 63, 62, 60, 63,
67, 65, 67, 72, 67, 63, 62, 63, 65, 67, 69, 71, 
72, 63, 65, 67, 68, 62, 63, 65, 67, 65, 63, 62,
63, 65, 67, 68, 70, 68, 67, 65, 67, 68, 70, 72,
73, 70, 68, 67, 69, 71, 72, 74, 75, 72, 71, 69, 
71, 72, 74, 75, 77, 74, 67, 74, 72, 74, 75, 77,
75, 74, 72, 71, 72, 67, 63, 60
]
@=> int notes[];

[
hn, hn, hn, hn, hn, qn, 
hn, hn, hn, hn, hn, qn, qn, qn,
qn, qn, qn, qn, hn, hn, hn, hn,
en, en, en, en, en, en, en, en, en, en, en, en,
en, en, en, en, en, en, en, en, en, en, en, en,
en, en, en, en, en, en, en, en, en, en, en, en,
en, en, en, en, en, en, en, en, en, en, en, en,
en, en, en, en, en, en, en, en, en, en, en, en, 
en, en, en, en, qn, qn, qn, qn
]
@=> dur durs[];

```





## Lab#7

### 1

다음 스케일을 STK UGen `BlowHole`, `BlowBotl`, `Saxofony`로 연주하는 프로그램을 만들어서 각각 어떤 소리가 나는지 들어 보자.

```
[60, 62, 64, 65, 67, 69, 71, 72, 71, 69, 67, 65, 64, 62, 60] 
@=> int scale[];
```

### 2

다음 스케일을 STK UGen `Mandolin`으로 연주하는 프로그램을 만들고,

```
[60, 62, 64, 65, 67, 69, 71, 72, 71, 69, 67, 65, 64, 62, 60] 
@=> int scale[];
```

0.1과 0.9 범위 내에서 `.bodySize`, `.pluckPos`, `.stringDamping`, `.stringDetune` 파라미터 값을 각각 변경하면서 소리가 어떻게 변화하는지 들어보자. 각 파라미터가 소리에 어떤 영향을 미치는지 느낄 수 있을 때까지 실험을 반복하자.

### 3

다음 스케일을 STK UGen `Bowed`로 연주하는 프로그램을 만들고,

```
[60, 62, 64, 65, 67, 69, 71, 72, 71, 69, 67, 65, 64, 62, 60] 
@=> int scale[];
```

0.1과 0.9 범위 내에서 `.bowPressure`, `.bowPosition`, `.vibratoGain`, `.volume` 파라미터 값을 각각 변경하면서 소리가 어떻게 변화하는지 들어보자. 각 파라미터가 소리에 어떤 영향을 미치는지 느낄 수 있을 때까지 실험을 반복하자.


### 4

```
Moog mog => dac;
200.0 => mog.freq;

while (true) {
    Math.random2f(0.1,1.0) => mog.filterQ;
    Math.random2f(0.01,1.0) => mog.filterSweepRate;
    1 => mog.noteOn;
    if (Math.random2(0,10) == 0) {
        Math.random2f(1.0,20.0) => mog.vibratoFreq;
        0.5 => mog.vibratoGain;
        second => now;
    }
    else {
        0.01 => mog.vibratoGain;
        0.0125::second => now;
    }
    1 => mog.noteOff;
    0.125::second => now;
}

```

위 프로그램을 실행하여 소리를 들어본 다음, 아래 파라미터 값에 따라서 소리가 어떻게 달라지는지 프로그램을 수정하여 각각 들어보자.
- `filterQ` 
- `filterSweepRate` 
- `vibratoFreq` 
- `vibratoGain` 



## Lab#6

### 1
`Lab#3-2`에서 작성한 `학교종`을 연주하는 프로그램을 `SqrOsc`와 `Envelope` UGen을 사용하여 재작성해보자. 

### 2
`학교종`을 연주하는 프로그램을 `SawOsc`와 `ADSR` UGen을 사용하여 재작성해보자. 가장 마음에 드는 소리가 날때까지 파라미터를 조정해보자.


### 3
`SinOsc` 2개를 각각 Carrier와 Modulator로 사용하여 주파수를 변조하고 `ADSR`를 활용하여 `학교종`을 연주하는 프로그램을 재작성해보자. 

### 4
교재의 `Listing 6.15`와 같은 효과가 나도록 `Resonz` 필터를 사용하여 `학교종`을 연주하는 프로그램을 재작성해보자. 

## Lab#5

### 1

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

### 2

다음의 5개의 파라미터를 인수로 받아서 소리를 내는 프로시저 함수 `playNote` 함수를 작성해보자.
- `Osc osc` : 소리 진동기
- `int note` : MIDI 음계
- `dur duration` :  `note` 음의 재생 시간
- `float gain` : `note` 음의 음량 (`0.0~1.0`)
- `dur tail` : 여러 음을 연속 재생하는 경우 연결음을 구분하기 위하여 끝 부분에서 소음하는 시간의 길이

이 함수를 호출하면 `osc` 진동기로 `note` 음을 `gain`의 크기로 `duration` 길이 만큼 재생한다. 단, 음 뒷 부분의 `tail` 길이 만큼은 소음한다. 즉, 실제로 소리나는 시간은 `duration - tail` 이다.

```
fun void playNote(Osc osc, int note, dur duration, float gain, dur tail) {
    ...
}
```

### 3

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

### 4

Lab#5-3에서 작성한 `playNotes` 함수를 활용하여 Lab#3-4에서 작성한 Beverly Hill Cops 영화 주제곡 프로그램을 개선해보자.


### 5

Lab#5-2에서 작성한 `playNote` 함수와 Lab#5-3에서 작성한 `playNotes` 함수를 활용하여 Lab#3-5에서 작성한 베토벤의 `엘리제를 위하여` 프로그램을 개선해보자.


### 6

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

### 1

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

### 2

`Listing4.9.ck` 파일의 프로그램을 다음과 같이 수정해보자.
- `hihat_01.wav` 소리 샘플을 2, 5, 6 박자에 소리나도록 추가한다.
- `Gain` `UGen`으로 세 개의 소리를 믹스하는 대신, 스테레오 스피커에서 하나는 중앙, 다른 하나는 오른쪽, 또 다른 하나는 왼쪽에서 소리나도록 분리한다. (좌우 채널 분리 방법은 `Listing4.5.ck` 참고)  

### 3

`Listing4.10.ck` 파일의 프로그램에서 다음 기능을 추가해보자.
- `hihat`를 `beat` 마다 항상 치지 않고, 1/2 확률로 랜덤하게 치도록 한다.
- 비트 박자와 같이 맞추어 `SawOsc` 소리를 1/3 확률로 랜덤하게 낸다.
- 계명은 MIDI 60~72 범위에서 무작위로 낸다. 
- 소리의 볼륨은 0.5로 한다.

### 4

`Listing4.12.ck` 파일의 프로그램에서 다음을 추가해보자.
- 8째 마디에서 시작하여 비트 박자와 같이 맞추어 `SqrOsc` 소리를 1/3 확률로 랜덤하게 낸다.
- 계명은 MIDI 60~72 범위에서 무작위로 낸다. 
- 소리의 볼륨은 0.5로 한다.


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
