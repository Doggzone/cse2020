```
(c)도경구 version 1.0 (2022/10/18)
```

## 7. 멀티스레드와 동시 계산

- <b>동시 계산 (concurrency)</b> : 두 개 이상의 프로세서가 하나의 계산을 서로 소통을 하면서 동시에 수행함
- <b>동시 계산 프로그램 (concurrent programs)</b> : 상호 연관성이 있는 독립적인 두 개 이상의 코드가 동시에 서로 동기화(synchronization)를 하면서 실행하는 프로그램
- ChucK은 시간(`time`)을 중심으로 박자에 맞추어 동기화를 하는 동시 계산 프로그램을 작성하도록 설계, 구현된 프로그래밍 언어

| 용어 | 설명 | ChucK |
|:----:|:----:|:----:|
| 쓰레드 (thread) | 프로그램 실행 흐름 줄기 | **shred** = strand + thread |
| 멀티쓰레드 (multithread) | 실행중 동시에 여러 독립적인 쓰레드가 존재 (서로를 알 필요가 없음) | **multishred** |
| 포크 (fork) | 부모 쓰레드가 자식 쓰레드를 만들어 냄 | **`spork`** |
| 스케줄러 (scheduler) | 부모(선조) 쓰레드와 자식(자손) 쓰레드를 동기화 시키는 장치 | **shreduler** |


##### `pingpong.ck`

```
// tempo
0.25::second => dur beat;
beat => dur qn; // quarter note (4분음, 1박자)
beat * 4 => dur wn; // whole note (온음, 4박자)

fun void ping() {
    Impulse pin => ResonZ rez => dac;
    700 => rez.freq;
    50 => rez.Q;
    while (true) {
        <<< "ping!", "" >>>;
        100 => pin.next;
        wn => now;
    }
}

fun void pong() {
    Impulse pon => ResonZ rez => dac;
    800 => rez.freq;
    50 => rez.Q;
    while (true) {
        <<< "  pong!", "" >>>;
        100 => pon.next;
        qn => now;
    }
}

// create two children shreds
spork ~ ping();
spork ~ pong();

// a parent shred
while (true)
    wn => now;
```

- `spork ~ <함수 호출>` 로 새로운 자식 쉬레드를 만든다.
- 자식 쉬레드 수에는 제한이 없다.
- 부모가 없어지면 자식을 포함한 자손은 모두 없어진다.
- 자식 쉬레드는 시간에 맞추어 동기화할 수 있으며, 동기화 시기는 프로그램으로 결정한다.


### 7-1. 동시 계산 프로그램 사례 1 : 드럼 머신

<img src="https://i.imgur.com/RKsGTH3.png" width="500">

##### `drummachine.ck`

```
// tempo
0.25::second => dur beat;
beat => dur qn; // quarter note (1/4)
beat * 2 => dur hn; // half note (2/4)
beat * 4 => dur wn; // whole note (4/4)

fun void kick() {
    SndBuf kick => dac;
    me.dir()+"/audio/kick_01.wav" => kick.read;
    while (true) {
        wn => now;
        0 => kick.pos;
    }
}

fun void snare() {
    SndBuf snare => dac;
    me.dir()+"/audio/snare_01.wav" => snare.read;
    while (true) {
        hn => now;
        0 => snare.pos;
    }
}

fun void hihat() {
    SndBuf hihat => dac;
    me.dir()+"/audio/hihat_01.wav" => hihat.read;
    0.2 => hihat.gain;
    while (true) {
        qn => now;
        0 => hihat.pos;
    }
}

// create three children shreds
spork ~ kick();
wn * 2 => now;
spork ~ hihat();
wn * 2 => now;
qn => now;
spork ~ snare();
wn * 4 => now;

// a parent shred that runs forever
while (true)
    wn => now;
```


### 7-2. 동시 계산 프로그램 사례 2 : 반달

#### 사례 : 반달 멜로디를 반주와 함께 연주하기

앞에서 공부한 `반달`의 첫 네 마디를 연주하는 프로그램을 만들어보자.
이번엔 멜로디와 반주를 독립적인 쉬레드로 만들어 동시에 따로 연주하도록 해보자.

연주 함수

```
fun void play(StkInstrument instrument, int notes[], dur durs[]) {
    for (0 => int i; i < notes.size(); i++) {
        Std.mtof(notes[i]) => instrument.freq;
        1 => instrument.noteOn;
        durs[i] => now;
        1 => instrument.noteOff;
    }
}
```

멜로디와 반주 악보

```
// tempo
0.5::second => dur beat;
beat => dur n1; //  (1/6)
beat * 2 => dur n2; // (2/6)
beat * 3 => dur n3; // (3/6)

[67,69,    67,64,    67,64,60, 55      ] @=> int melody[];
[n2,n1,    n2,n1,    n1,n1,n1, n3      ] @=> dur melody_len[];
[48,52,55, 48,52,55, 48,52,55, 48,52,55] @=> int harmony[];
[n1,n1,n1, n1,n1,n1, n1,n1,n1, n1,n1,n1] @=> dur harmony_len[];
```

멜로디와 반주를 따로 이어서 연주하기

```
Rhodey righthand => dac;
Rhodey lefthand => dac;
play(righthand, melody, melody_len);
play(lefthand, harmony, harmony_len);
```

멜로디와 반주를 동시에 연주하기

```
Rhodey righthand => dac;
Rhodey lefthand => dac;
spork ~ play(righthand, melody, melody_len);
spork ~ play(lefthand, harmony, harmony_len);
12 * beat => now;
```

### 7-3. 동시 계산 프로그램 사례 3 : 여러 쉬레드가 공동으로 `UGen` 제어

먼저 STK 악기 `StkInstrument` 중에서 타악기 류를 알아보자.

#### `ModalBar`

<img src="https://i.imgur.com/VGT41J5.png" width="500">

| `n` | `.preset(int n)` |
|:----:|:----:|
| 0 | Marimba |
| 1 | Vibraphone |
| 2 | Agogo |
| 3 | Wood1 |
| 4 | Reso |
| 5 | Wood2 |
| 6 | Beats |
| 7 | Two Fixed |
| 8 | Clump |


```
ModalBar bar => dac;

[62, 64, 66, 67, 69, 71, 73, 74] @=> int scale[];

for (0 => int i; i <= 8; i++) {
    i => bar.preset;
    for (0 => int j; j < scale.size(); j++) {
        Std.mtof(scale[j]) => bar.freq;
        1 => bar.noteOn;
        0.4 :: second => now;
    }
}
```

이 타악기를 활용하여 재미있는 소리를 내는 프로그램을 공부해보자.

##### `modalbar.ck`

```
ModalBar modal => NRev reverb => dac;
.1 => reverb.mix;
7 => modal.preset;
.9 => modal.strikePosition;

// spork detune() as a child shred
// note: must do this before entering into infinite loop below!
spork ~ detune();  

// infinite time loop
while (true) {
    1 => modal.strike;
    250::ms => now;
    .7 => modal.strike;
    250::ms => now;
    .9 => modal.strike;
    250::ms => now;
    repeat (4) {
        .5 => modal.strike;
        62.5::ms => now;
    }
}

// function to vary tuning over time
fun void detune() {
    while (true) {
        // update frequency sinusoidally
        84 + Math.sin(now/second*.25*Math.PI) * 2 => Std.mtof => modal.freq;
        // advance time (controls update rate)
        5::ms => now;
    }
}
```

### 7-4. ChucK 프로그램 파일을 쉬레드로 추가 - `Machine`

<img src="https://i.imgur.com/1KYaVwn.png" width="800">

##### `conductor.ck`

```
Machine.add(me.dir()+"/pingpong.ck") => int pingpong;
2.0 :: second => now;
Machine.add(me.dir()+"/drummachine.ck") => int drum;
6.0 :: second => now;
Machine.add(me.dir()+"/modalbar.ck") => int modal;
4.0 :: second => now;             
Machine.remove(modal);
4.0 :: second => now;
Machine.replace(drum,me.dir()+"/modalbar.ck") => modal;
4.0 :: second => now;
Machine.remove(modal);
4.0 :: second => now;
Machine.remove(pingpong);
```

### 7-5. 동시 계산 프로그램 사례 4 : Jazz Quartet Band

- 관악기 : `Flute`
- 피아노 : `Rhodey`
- 베이스 : `Mandolin`
- 드럼 : `SndBuf`

##### `piano.ck`

```
Rhodey piano[4];
piano[0] => dac;
piano[1] => dac;
piano[2] => dac;             
piano[3] => dac;

[[53,57,60,64],[51,55,60,63]] @=> int chord[][];

while (true) {
    for (0 => int i; i < 4; i++)  {
        Std.mtof(chord[0][i]) => piano[i].freq;
        Math.random2f(0.3,.7) => piano[i].noteOn;
    }
    1.0 :: second => now;
    for (0 => int i; i < 4; i++) {
        Math.mtof(chord[1][i]) => piano[i].freq;
        Math.random2f(0.3,.7) => piano[i].noteOn;
    }
    1.4 :: second => now;
}
```

##### `bass.ck`

```
Mandolin bass => NRev r => dac;
0.1 => r.mix;
0.0 => bass.stringDamping; // makes strings ring a long time.
0.02 => bass.stringDetune;
0.05 => bass.bodySize; // gives a huge body size.
.5 => bass.gain;

[41,43,45,48,50,51,53,60,63] @=> int scale[];
4 => int walkPos;
scale.size() => int size;

while (true) {
    Math.random2(-1,1) +=> walkPos;
    if (walkPos < 0)
        1 => walkPos;
    if (walkPos >= size)
        size - 2 => walkPos;
    Std.mtof(scale[walkPos]-12) => bass.freq;
    Math.random2f(0.05,0.5) => bass.pluckPos;
    1 => bass.noteOn;
    0.55 :: second => now;
    1 => bass.noteOff;
    0.05 :: second => now;
}
```


##### `drums.ck`

```
SndBuf hihat => dac;
me.dir() + "/audio/hihat_01.wav" => hihat.read;

while (true) {
    Math.random2f(0.1,.3) => hihat.gain;
    Math.random2f(.9,1.2) => hihat.rate;
    (Math.random2(1,2) * 0.2)::second => now;
    0 => hihat.pos;
}
```


##### `flute.ck`

```
Flute solo => JCRev rev => dac;
0.1 => rev.mix;
solo => Delay d => d => rev;
0.8::second => d.max => d.delay;
0.5 => d.gain;
0.5 => solo.gain;

[41,43,45,48,50,51,53,60,63] @=> int scale[];

while (true) {
    (Math.random2(1,5)*0.2)::second => now; // 0.2, 0.4, 0.6, 0.8, 1.0
    if (Math.random2(0,3) > 1) { // 50%
        Math.random2(0,scale.size()-1) => int note;
        Math.mtof(scale[note]+24)=> solo.freq;
        Math.random2f(0.3,1.0) => solo.noteOn;
    }
    else // 50%
        1 => solo.noteOff;
}
```


##### `score.ck`

```
Machine.add(me.dir()+"/piano.ck") => int pianoID;
4.8::second => now;
me.dir()+"/drums.ck" => string drumsPath;
Machine.add(drumsPath) => int drumsID;
4.8::second => now;
Machine.add(me.dir()+"/bass.ck") => int bassID;
4.8::second => now;
Machine.add(me.dir()+"/flute.ck") => int fluteID;
4.8::second => now;
Machine.remove(drumsID);
4.8::second => now;
Machine.remove(fluteID);
4.8::second => now;
Machine.remove(bassID);
4.8::second => now;
Machine.remove(pianoID);
```


### 실습

#### 1. 반달 - 멜로디와 반주를 동시에 모두 연주하기

<img src="https://i.imgur.com/K0f0bUI.png" width="600">

##### 박자

```
0.5::second => dur beat;
beat => dur n1; // 1/6
beat * 2 => dur n2; // 2/6
beat * 3 => dur n3; // 3/6
beat * 5 => dur n5; // 5/6
```

##### 멜로디 악보


```
[ // halfmoon melody
67,69,67,64,  67,64,60,55,  57,60,62,67,     64,-1,
67,69,67,64,  67,64,60,55,  57,60,55,62,     60,-1,
64,64,64,62,  64,   69,67,  64,62,64,69,     67,-1,
72,   67,67,  64,64,69,69,  67,64,60,55,62,  60,-1
] @=> int melody[];

[ // halfmoon melody time
n2,n1,n2,n1,  n1,n1,n1,n3,  n2,n1,n2,n1,     n5,n1,
n2,n1,n2,n1,  n1,n1,n1,n3,  n2,n1,n2,n1,     n5,n1,
n2,n1,n2,n1,  n2,   n1,n3,  n2,n1,n2,n1,     n5,n1,
n3,   n2,n1,  n2,n1,n2,n1,  n1,n1,n1,n2,n1,  n5,n1
] @=> dur melody_len[];
```

##### `play` 함수

멜로디 악보를 보면 쉼표는 -1로 표시했다. 이 경우 앞에서 만든 다음 `play` 함수를 사용할 수 없다. 쉼표는 소리를 내지 않도록 이 함수를 수정하자.

```
fun void play(StkInstrument instrument, int notes[], dur durs[]) {
    for (0 => int i; i < notes.size(); i++) {
        Std.mtof(notes[i]) => instrument.freq;
        1 => instrument.noteOn;
        durs[i] => now;
        1 => instrument.noteOff;
    }
}
```

##### 반주 악보

코드 별 반주 음은 다음과 같다.

```
// C = 48,52,55
// F = 48,53,57
// G7 = 47,50,53
// Am = 45,48,52
```

이 음에 맞추어 다음 두 반주 연주 악보 배열을 완성하자.

```
[ // halfmoon harmony








] @=> int harmony[];

[ // halfmoon harmony time
n1,n1,n1, n1,n1,n1, n1,n1,n1, n1,n1,n1,
n1,n1,n1, n1,n1,n1, n1,n1,n1, n1,n1,n1,
n1,n1,n1, n1,n1,n1, n1,n1,n1, n1,n1,n1,
n1,n1,n1, n1,n1,n1, n1,n1,n1, n1,n1,n1,
n1,n1,n1, n1,n1,n1, n1,n1,n1, n1,n1,n1,
n1,n1,n1, n1,n1,n1, n1,n1,n1, n1,n1,n1,
n1,n1,n1, n1,n1,n1, n1,n1,n1, n1,n1,n1,
n1,n1,n1, n1,n1,n1, n1,n1,n1, n1,n1,n1
] @=> dur harmony_len[];
```

##### 연주

이제 연주 코드를 작성할 준비가 되었다. 멜로디와 반주를 동시에 연주하도록 프로그램을 짜보자.

```
Wurley righthand => dac;
Wurley lefthand => dac;



```


#### 2. 돌림노래

이번엔 다음 곡을 돌림노래로 연주해보자.

![Row-Row-Row-Your-Boat](https://i.imgur.com/rvB5d4E.png)

4개의 개별 개체를 만들어 차례로 2 마디씩 늦게 연주를 시작하도록 하면 돌림노래가 완성된다.
악기는 자유로이 선택한다.

```
// tempo
0.2::second => dur beat;
beat => dur n1; // 1/6
beat * 2 => dur n2; // 2/6
beat * 3 => dur n3; // 3/6
beat * 6 => dur n6; // 6/6

[ // melody
60,60,             60,62,64,          64,62,64,65, 67,
72,72,72,67,67,67, 64,64,64,60,60,60, 67,65,64,62, 60
] @=> int melody[];

[ // time
n3,n3,             n2,n1,n3,          n2,n1,n2,n1, n6,
n1,n1,n1,n1,n1,n1, n1,n1,n1,n1,n1,n1, n2,n1,n2,n1, n6
] @=> dur durs[];
```


#### 3. Bach의 Crab Canon

- [Crab Canon?](https://www.youtube.com/watch?v=DAIc1XvnPkI)

다음 악보는 바하의 The Musical Offering에 포함되어 있는 Crab Canon으로 음악적 팰린드롬이다.

<img src="https://i.imgur.com/6FoCkEb.png" width="500">


그냥 순서대로 또는 거꾸로 한방향으로 연주해도 되고, 순서대로와 거꾸로를 동시에 양방향으로 연주해도 된다. 들어보자.

- [Bach’s Crab Canon 연주](https://www.youtube.com/watch?v=jdWUZqhd21A)

이 곡을 두개의 악기를 사용하여 정방향과 역방향으로 동시에 연주하는 프로그램을 아래 MIDI 악보 코드를 활용하여 만들어보자. 힌트: 악보를 거꾸로 연주하는 함수 `retrograde`를 따로 작성하여 사용하자.

```
// tempo
0.4::second => dur beat;
beat => dur qn; // quarter note (1/4)
beat / 2 => dur en; // eighth note (1/8)
beat * 2 => dur hn; // half note (1/2)

[ // score
60,         63,         67,         68,
59,         -1,   67,         66,         65,
      64,         63,         62,   61,   60,
59,   55,   62,   65,   63,         62,
60,         63,         67,65,67,72,67,63,62,63,
65,67,69,71,72,63,65,67,68,62,63,65,67,65,63,62,
63,65,67,68,70,68,67,65,67,68,70,72,73,70,68,67,
69,71,72,74,75,72,71,69,71,72,74,75,77,74,67,74,
72,74,75,77,75,74,72,71,72,   67,   63,   60
] @=> int notes[];

[ // time
hn,         hn,         hn,         hn,    
hn,         qn,   hn,         hn,         hn,     
      hn,         hn,         qn,   qn,   qn,
qn,   qn,   qn,   qn,   hn,         hn,   
hn,         hn,         en,en,en,en,en,en,en,en,
en,en,en,en,en,en,en,en,en,en,en,en,en,en,en,en,
en,en,en,en,en,en,en,en,en,en,en,en,en,en,en,en,      
en,en,en,en,en,en,en,en,en,en,en,en,en,en,en,en,      
en,en,en,en,en,en,en,en,qn,   qn,   qn,   qn
] @=> dur durs[];
```

#### 5. J.S. Bach, Canon a 2 perpetuus (BWV 1075)

다음 프로그램은 아래 악보의 테마 멜로디를 연주한다. 실행하여 멜로디를 들어보자.

```
// tempo
0.4::second => dur beat;
beat => dur n1;
beat * 2 => dur n2;

[ // score
67,72,67,69,67,65,
64,   76,77,76,74,
72,67,72,71,72,74,
76,   64,62,64,65
] @=> int melody[];

[ // time
n1,n1,n1,n1,n1,n1,
n2,   n1,n1,n1,n1,
n1,n1,n1,n1,n1,n1,
n2,   n1,n1,n1,n1
] @=> dur durs[];

// play
Rhodey hand => dac;
play(hand, melody, durs);

fun void play(StkInstrument instrument, int notes[], dur durs[]) {
    for (0 => int i; i < notes.size(); i++) {
        if (notes[i] != -1) {
            Std.mtof(notes[i]) => instrument.freq;
            1 => instrument.noteOn;
        }
        durs[i] => now;
        1 => instrument.noteOff;
    }
}
```

<img src="https://i.imgur.com/AYbGQeA.png" width="600">

아래 악보는 위 악보의 테마 멜로디 주제를 시간 차를 두고 두 악기가 반복 연주하도록 만든 캐논이다.
이 악보를 연주하는 프로그램을 작성하자.
악보의 끝 부분에서 같이 끝나도록 하기 위해서 멜로디 주제를 일부만 연주함에 유의하여 작성하자.


<img src="https://i.imgur.com/ffTyHng.png" width="600">



### 숙제 : J.S. Bach, Trias Harmonica Canon (BWV 1072) [마감: 10월 26일]

다음 악보는 바하의 캐논 BWV 1072의 기본 테마 멜로디 악보이다.

<img src="https://i.imgur.com/io5HqQg.png" width="400">

장3화음인 도-미-솔과 단3화음인 레-파-라의 음을 하나씩 교대로 나열하여 만들 간단한 멜로디이다. 계명으로 읽으면 도-레-미-파-솔-파-미-레 이다. 장3화음 음의 길이는 한박자반으로 절대자 신을, 단3화음 음의 길이는 반박자로 인간을 나타낸다고 한다. 음의 길이가 3:1로 신과 인간의 삼위일체 관계를 의미한다고 한다. 아마도 신과 인간과의 관계를 음악으로 표현하려 한 것으로 보인다.

이 캐논은 이 테마 멜로디와 테마의 앞 뒤 마디를 뒤집은 멜로디를 교대로 4번씩 조금씩의 시차를 두고 돌림으로 연주한다.
다음 영상의 구체적인 악보 패턴 진행을 참고하여, 이와 똑같이 연주하도록 프로그램을 작성하자.

- [Trias Harmonica Canon의 작곡 원리](https://www.youtube.com/watch?v=AE3SW3wwP0s)

- [연주](https://www.youtube.com/watch?v=sjfN4iV0cqA)

```
// tempo
0.5::second => dur beat;
beat * 1.5 => dur n3; // 3/8
beat * 0.5 => dur n1; // 1/8

// the theme for choir 1
[60,62,64,65, 67,65,64,62] @=> int theme1[];
[n3,n1,n3,n1, n3,n1,n3,n1] @=> dur durs1[];
// the inverted theme for choir 2
[67,65,64,62, 60,62,64,65] @=> int theme2[];
[n3,n1,n3,n1, n3,n1,n3,n1] @=> dur durs2[];
```
