```
(c)도경구 version 1.0 (2022/09/24)
```

## 5. 소리 파일과 소리 다듬기

채집한 아날로그 소리를 컴퓨터 프로그램으로 처리하려면 디지털 데이터로 변환해야 한다. 소리 데이터는 다양한 형식의 파일에 기록할 수 있는데, 이 장에서는 파일로 저장되어 있는 소리 데이터를 ChucK 프로그램에서 활용하는 방법을 공부한다.

### 5-1. 샘플

컴퓨터 프로그램에서 소리(음파, sound waveform)를 처리하려면, 아날로그 소리를 이진수로 표현한 디지털 데이터로 변환해야 한다. 이 변환 장치를 <b>ADC(Analog-to-Digital Converter, 아날로그/디지털 변환기)</b>라고 하고, 변환한 디지털 데이터를 <b>샘플(sample)</b>이라고 한다.

<img src="https://i.imgur.com/fBmg7y1.png" width="800">

#### 샘플 비율, 샘플 크기

샘플 비율(sampling rate)은 얼마나 빈번하게 소리 데이터를 채취하는지에 따라 결정되는데, 보통 초당 44,100개의 샘플을 채취한다. 샘플 비율이 높아져서 초당 샘플을 더 많이 채취할수록, 음질은 좋아지고 저장공간의 부담은 증가한다. 샘플 하나를 저장하는 공간의 크기는 보통 8비트(일반), 16비트(음악), 24비트(고음질 음악) 중 하나를 선택한다. 저장 공간이 클수록 음질이 좋아진다. 그런데 사람의 귀가 음질을 구별하는데 한계가 있는데다가 음질을 높일수록 공간비용이 증가하기 때문에, 무조건 샘플 비율을 높이고 샘플 크기를 늘리는게 능사는 아니다. CD 음반의 경우 16비트, 44,100 샘플 비율을 표준으로 채택하고 있다.


### 5-2. 샘플을 담는 장치 [SndBuf](https://chuck.cs.princeton.edu/doc/program/ugen_full.html#sndbuf)

<b>단위생성기(unit generator)</b>는 음파를 생성하는 장치인데, ChucK에서 제공하는 모든 단위생성기를 통칭하여 `UGen` 라고 한다. 앞서 공부한 `SinOsc`, `SqrOsc`, `TriOsc`, `SawOsc`는 모두 `UGen`의 일종이다. 소리 샘플을 담을 수 있는 `UGen`은 `SndBuf`(sound buffer) 이다.

`SndBuf`가 제공하는 제어 파라미터는 다음과 같다.

| 제어 파라미터 | 값의 범위 | 설명 |
|:----:|:----:|:----:|
| `.read` | | 소리 파일을 `SndBuf`에 올림(로딩) |
| `.samples` | `int` | 샘플의 개수 |
| `.length` | `dur` | 샘플의 연주 시간 |
| `.pos` | `0` \~ `.samples()` | 플레이 헤드의 위치|
| `.gain` | `0.0` \~ `1.0` | 소리 크기 |
| `.rate` | `float` | 1.0이 정상 진행 속도, 음수는 거꾸로 진행 |

<img src="https://i.imgur.com/QfT6Bov.png" width="600">

`SndBuf`에 담을 수 있는 소리 파일의 형식은 다양한데, 대표적인 두 가지만 살펴보면 다음과 같다.
- `.wav` (wave or waveform)
- `.aif` (audio interchange file or format)


#### 모노

```
SndBuf sample => dac;
me.dir() + "/audio/snare_01.wav" => string filename;
filename => sample.read;
0.5 => sample.gain;
0 => sample.pos;
second => now;
```

####  스테레오

```
SndBuf sample1 => dac.left;
SndBuf sample2 => dac.right;
me.dir() + "/audio/snare_01.wav" => sample1.read;
me.dir() + "/audio/hihat_01.wav" => sample2.read;
0.5 => sample1.gain => sample2.gain;
0 => sample1.pos => sample2.pos;
second => now;
```

#### 패닝 [Pan2](https://chuck.cs.princeton.edu/doc/program/ugen_full.html#pan2)

`Pan2`는 모노를 스테레오로 펴주는 작업을 하는 단위생성기이다.

<img src="https://i.imgur.com/aKLrtbW.png" width="300">


```
Noise n => Pan2 p => dac;
0.2 => n.gain;
float position;
while (true) {
    Math.sin(now/second) => position;
    <<< position >>>;
    position => p.pan;
    ms => now;
}
```

```
SndBuf sample => Pan2 p => dac;
0.5 => sample.gain;
me.dir() + "/audio/snare_01.wav" => sample.read;
-0.1 => float position;
while (position < 1.0) {
    0 => sample.pos;
    position => p.pan;
    <<< position >>>;
    0.02 +=> position;
    100::ms => now;
}
```

#### 재생 속도 변화

```
SndBuf sample => Pan2 p => dac;
0.5 => sample.gain;
me.dir() + "/audio/cowbell_01.wav" => sample.read;
while (true) {
    Math.random2f(0.1,1.0) => sample.gain; // volume
    Math.random2f(-0.1,1.0) => p.pan; // panning
    Math.random2f(0.2,1.8) => sample.rate; // speed
    0 => sample.pos;
    500::ms => now;
}
```

#### 거꾸로 재생


```
SndBuf sample => dac;
0.5 => sample.gain;
me.dir() + "/audio/hihat_04.wav" => sample.read;

0 => sample.pos;  // move the play head to the front
sample.length() => now; // play

sample.samples() => sample.pos; // move the play head to the end
-1.0 => sample.rate; // set the play direction backward
sample.length() => now; // play
```

#### 배열 활용

```
SndBuf sample => dac;
string snare_samples[3];
me.dir() + "/audio/snare_01.wav" => snare_samples[0];
me.dir() + "/audio/snare_02.wav" => snare_samples[1];
me.dir() + "/audio/snare_03.wav" => snare_samples[2];

while (true)
    for (0 => int i; i < snare_samples.size(); i++) {
        snare_samples[i] => sample.read;
        0.5::second => now;
    }

```

```
SndBuf sample[3];
sample[0] => dac.left;
sample[1] => dac;
sample[2] => dac.right;
me.dir() + "/audio/snare_01.wav" => sample[0].read;
me.dir() + "/audio/snare_02.wav" => sample[1].read;
me.dir() + "/audio/snare_03.wav" => sample[2].read;

while (true)
    for (0 => int i; i < sample.size(); i++) {
        0 => sample[i].pos;
        0.5::second => now;
    }

```

```
SndBuf sample[3];
sample[0] => dac.left;
sample[1] => dac;
sample[2] => dac.right;
me.dir() + "/audio/snare_01.wav" => sample[0].read;
me.dir() + "/audio/snare_02.wav" => sample[1].read;
me.dir() + "/audio/snare_03.wav" => sample[2].read;

while (true) {
    Math.random2(0, sample.size()-1) => int which;
    0 => sample[which].pos;
    0.5::second => now;
}
```

#### 스테레오 소리 파일 재생 - `SndBuf2`

```
SndBuf2 stereo_sample => dac;
me.dir() + "/audio/stereo_fx_01.wav" => stereo_sample.read;
stereo_sample.length() => now;
```

```
SndBuf2 stereo_sample;
me.dir() + "/audio/stereo_fx_01.wav" => stereo_sample.read;
Gain bal[2];
stereo_sample.chan(0) => bal[0] => dac.left;
stereo_sample.chan(1) => bal[1] => dac.right;
stereo_sample.length() => now;
```

```
SndBuf2 stereo_sample;
me.dir() + "/audio/stereo_fx_01.wav" => stereo_sample.read;
Gain bal[2];
stereo_sample.chan(0) => bal[0] => dac.left;
stereo_sample.chan(1) => bal[1] => dac.right;
stereo_sample.length() => now;

0 => stereo_sample.pos; // set the playhead position to 0
float balance, volume_right;
-1.0 => balance;
stereo_sample.length() / 21 => dur length;
while (balance <= 1.0 ) {
    (balance + 1) / 2.0 => volume_right;
    volume_right => bal[0].gain;
    1 - volume_right => bal[1].gain;
    length  => now;
    0.1 +=> balance;
}
```

```
SndBuf2 stereo_sample;
me.dir() + "/audio/stereo_fx_03.wav" => stereo_sample.read;
Gain bal[2];
stereo_sample.chan(0) => bal[0] => dac.left;
stereo_sample.chan(1) => bal[1] => dac.right;
1 => stereo_sample.loop; // automatically set .pos to 0 after play

float balance, volume_right;
while (true) {
    Math.random2f(0.2, 1.8) => stereo_sample.rate;
    Math.random2f(-1.0, 1.0) => balance;
    (balance + 1) / 2.0 => volume_right;
    volume_right => bal[0].gain;
    1 - volume_right => bal[1].gain;
    0.3::second => now;
}
```

####  `Std` 타입 변환 메소드

| 메소드 | 설명 |
|:----:|:----:|
| `int Std.ftoi(float value)` | 실수를 정수로 변환 (소수점 아래 버림) |
| `int Std.atoi(string value)` | ASCII(`string`)를 정수로 변환 |
| `float Std.atof(string value)` | SCII(`string`)를 실수로 변환 |
| `string Std.itoa(string value)` | 정수를 ASCII(`string`)로 변환 |
| `string Std.ftoa(string value)` | 실수를 ASCII(`string`)로 변환 |


####  기타 `Std` 메소드

| 메소드 | 설명 |
|:----:|:----:|
| `int Std.abs(int value)` | 정수의 절대값 (음수 부호를 버림) |
| `float Std.fabs(float value)` | 실수의 절대값 (음수 부호를 버림) |
| `float Std.sgn(float value)` | 부호를 바꿈 (양수는 음수로, 음수는 양수로) |


### 5.3 사례 학습 : 드럼 머신

#### 드럼 머신 1호

```
Gain master => dac;
SndBuf kick => master;
SndBuf snare => master;
me.dir() + "/audio/kick_01.wav" => kick.read;
me.dir() + "/audio/snare_01.wav" => snare.read;
kick.samples() => kick.pos; // move the head to the end
snare.samples() => snare.pos;// move the head to the end

0.5::second => dur TEMPO;
second => now; // no sound for a second
while (true) {
    0 => kick.pos;
    TEMPO => now;
    0 => snare.pos;
    TEMPO => now;
}
```

#### 드럼 머신 2호

```
Gain master => dac;
SndBuf kick => master;
SndBuf snare => master;
me.dir() + "/audio/kick_01.wav" => kick.read;
me.dir() + "/audio/snare_01.wav" => snare.read;
kick.samples() => kick.pos;
snare.samples() => snare.pos;

0.2::second => dur TEMPO;
while (true) {
    for (0 => int beat; beat < 16; beat++) {
        <<< beat >>>;
        if (beat == 0 || beat == 4 || beat == 8 || beat == 12)
            0 => kick.pos;
        if (beat == 2 || beat == 5 || beat == 7 ||
            beat == 9 || beat == 10 || beat == 11 ||
            beat == 13 || beat == 14)
            0 => snare.pos;
        TEMPO => now;
    }
}
```

#### 드럼 머신 2호 (개선)

```
Gain master => dac;
SndBuf kick => master;
SndBuf snare => master;
me.dir() + "/audio/kick_01.wav" => kick.read;
me.dir() + "/audio/snare_01.wav" => snare.read;
kick.samples() => kick.pos;
snare.samples() => snare.pos;

0.2::second => dur TEMPO;
[1,0,0,0, 1,0,0,0, 1,0,0,0, 1,0,0,0] @=> int kick_hits[];
[0,0,1,0, 0,1,0,1, 0,1,1,1, 0,1,1,0] @=> int snare_hits[];

while (true) {
    for (0 => int beat; beat < kick_hits.size(); beat++) {
        <<< beat >>>;
        if (kick_hits[beat])
            0 => kick.pos;
        if (snare_hits[beat])
            0 => snare.pos;
        TEMPO => now;
    }
}
```

#### 드럼 머신 3호 (하이햇 추가)


```
Gain master => dac;
SndBuf kick => master;
SndBuf snare => master;
SndBuf hihat => master;
me.dir() + "/audio/kick_01.wav" => kick.read;
me.dir() + "/audio/snare_01.wav" => snare.read;
me.dir() + "/audio/hihat_01.wav" => hihat.read;
kick.samples() => kick.pos;
snare.samples() => snare.pos;
hihat.samples() => hihat.pos;
0.3 => hihat.gain;

0.2::second => dur TEMPO;
[1,0,0,0, 1,0,0,0, 1,0,0,0, 1,0,0,0] @=> int kick_hits[];
[0,0,1,0, 0,1,0,1, 0,1,1,1, 0,1,1,0] @=> int snare_hits[];
[0,1,0,1, 0,0,1,1, 0,0,1,1, 0,1,1,1] @=> int hihat_hits[];

while (true) {
    for (0 => int beat; beat < kick_hits.size(); beat++) {
        <<< beat >>>;
        if (kick_hits[beat])
            0 => kick.pos;
        if (snare_hits[beat])
            0 => snare.pos;
        if (hihat_hits[beat])
            0 => hihat.pos;
        TEMPO => now;
    }
}
```

#### 나머지 `%` 연산 활용


```
Gain master => dac;
SndBuf clickhi => master;
SndBuf clicklo => master;
me.dir() + "/audio/click_02.wav" => clickhi.read;
me.dir() + "/audio/click_01.wav" => clicklo.read;

0.5::second => dur TEMPO;
4 => int MOD;
for (0 => int beat; beat < 24; beat++) {
    <<< beat, beat % MOD >>>;
    0 => clickhi.pos;
    if (beat % MOD == 0)
        0 => clicklo.pos;
    TEMPO => now;
}
```

#### 드럼 머신 4호

```
Gain master[3];
master[0] => dac.left;
master[1] => dac;
master[2] => dac.right;

SndBuf kick => master[1];
SndBuf snare => master[1];
SndBuf cowbell => master[0];
SndBuf hihat => master[2];

SndBuf claps => Pan2 p;
p.chan(0) => master[0];
p.chan(1) => master[1];

me.dir() + "/audio/kick_01.wav" => kick.read;
me.dir() + "/audio/snare_01.wav" => snare.read;
me.dir() + "/audio/hihat_01.wav" => hihat.read;
me.dir() + "/audio/cowbell_01.wav" => cowbell.read;
me.dir() + "/audio/clap_01.wav" => claps.read;

[1,0,1,0, 1,0,0,1, 0,1,0,1, 0,1,1,1] @=> int cow_hits[];
cow_hits.size() => int MAX_BEAT;
4 => int MOD;
0.2::second => dur TEMPO;

0 => int beat;
0 => int measure;
while (true) {
    if (beat % 4 == 0)
        0 => kick.pos;
    if (beat % 4 == 2 && measure % 2 == 1)
        0 => snare.pos;
    if (measure > 1) {
        if (cow_hits[beat])
            0 => cowbell.pos;
        else {
            Math.random2f(0.0,1.0) => hihat.gain;
            0 => hihat.pos;
        }
    }
    if (beat > 11 && measure > 3) {
        Math.random2f(-1.0,1.0) => p.pan;
        0 => claps.pos;
    }
    TEMPO => now;
    (beat + 1) % MAX_BEAT => beat;
    if (beat == 0)
        measure++;
}
```

### 실습 5.1 소리 샘플 파일 들어보기

다운 받은 `audio` 폴더에는 소리 파일 샘플이 들어있다. 각 샘플의 소리를 차례로 모두 들어볼 수 있도록 프로그램을 만들어보자. 각 샘플이 내는 소리의 길이는 다양하다. 샘플의 길이는 `samples()`(샘플의 개수를 `int` 값으로 리턴) 또는 `length()`(샘플의 길이를 `dur` 값으로 리턴) 메소드를 호출하여 알아낼 수 있다. 샘플의 끝까지 소리내야 하고 (방법은 아래 예 참조), 각 샘플 사이에 1초의 간격을 둔다.

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

### 실습 5.2

아래 프로그램을 다음 요구 사항에 맞추어 수정해보자.

- `hihat_01.wav` 소리 샘플을 2, 5, 6 박자에 소리나도록 추가한다.
- `Gain` `UGen`으로 세 개의 소리를 믹스하는 대신, 스테레오 스피커에서 하나는 중앙, 다른 하나는 오른쪽, 또 다른 하나는 왼쪽에서 소리나도록 분리한다.

```
Gain master => dac;
SndBuf kick => master;
SndBuf snare => master;
me.dir() + "/audio/kick_01.wav" => kick.read;
me.dir() + "/audio/snare_01.wav" => snare.read;
kick.samples() => kick.pos;
snare.samples() => snare.pos;

0.2::second => dur TEMPO;
while (true) {
    for (0 => int beat; beat < 16; beat++) {
        <<< beat >>>;
        if (beat == 0 || beat == 4 || beat == 8 || beat == 12)
            0 => kick.pos;
        if (beat == 4 || beat == 10 || beat == 13 || beat == 14)
            0 => snare.pos;
        TEMPO => now;
    }
}
```


### 실습 5.3

아래 프로그램에 다음 기능을 추가해보자.

- `hihat`를 `beat` 마다 항상 치지 않고, 1/2 확률로 랜덤하게 치도록 한다.
- 비트 박자와 같이 맞추어 `SawOsc` 소리를 1/3 확률로 랜덤하게 낸다.
- 계명은 MIDI 60~72 범위에서 무작위로 낸다.
- 소리의 볼륨은 0.5로 한다.

```
Gain master => dac;
SndBuf kick => master;
SndBuf snare => master;
SndBuf hihat => master;
me.dir() + "/audio/kick_01.wav" => kick.read;
me.dir() + "/audio/snare_01.wav" => snare.read;
me.dir() + "/audio/hihat_01.wav" => hihat.read;
kick.samples() => kick.pos;
snare.samples() => snare.pos;
hihat.samples() => hihat.pos;
0.3 => hihat.gain;

0.2::second => dur TEMPO;
[1,0,0,0, 1,0,0,0, 1,0,0,0, 1,0,0,0] @=> int kick_hits[];
[0,0,1,0, 0,0,1,0, 0,0,0,0, 1,1,1,1] @=> int snare_hits[];

while (true) {
    for (0 => int beat; beat < kick_hits.size(); beat++) {
        <<< beat >>>;
        if (kick_hits[beat])
            0 => kick.pos;
        if (snare_hits[beat])
            0 => snare.pos;
        0 => hihat.pos;
        TEMPO => now;
    }
}
```


### 실습 5.4 드럼 머신 4호 수정

수업 시간에 공부한 드럼 머신 4호 프로그램에 다음을 추가해보자.
- 8째 마디에서 시작하여 비트 박자와 같이 맞추어 `SqrOsc` 소리를 1/3 확률로 랜덤하게 낸다.
- 계명은 MIDI 60\~72 범위에서 무작위로 낸다.
- 소리의 볼륨은 0.5로 한다.


### 숙제. 나의 드럼 머신 (제출 마감: 10월 5일 오후 3시)

지금까지 배운 지식을 총 동원하여 드럼 머신을 하나 만들어 소스 파일을 제출한다. 연주 시간은 1분을 넘을 수 없다.
