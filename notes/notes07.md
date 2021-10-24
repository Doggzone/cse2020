```
(c)도경구 version 0.1 (2021/10/24)
```

## 7. 멀티스레드와 동시 계산

- <b>동시 계산 (concurrency)</b> : 다른 계산을 동시에 수행함
- <b>동시 계산 프로그램 (concurrent programs)</b> : 상호 연관성이 있는 독립적인 두 개 이상의 코드가 동시에 서로 동기화를 하면서 실행하는 프로그램
- ChucK은 시간(`time`)을 중심으로 박자에 맞추어 동기화를 하는 동시 계산 프로그램을 작성하도록 설계, 구현된 프로그래밍 언어

| 용어 | 설명 | ChucK | 
|:----:|:----:|:----:|
| 쓰레드(thread) | 프로그램 실행 흐름 줄기 | shred = strand + thread |
| 멀티쓰레드(multithread) | 실행중 동시에 여러 독립적인 쓰레드가 존재 (서로를 알 필요가 없음) | multishred|
| 포크(fork) | 부모 쓰레드가 자식 쓰레드를 만들어 냄 | `spork` |
| 스케줄러(scheduler) | 부모(선조) 쓰레드와 자식(자손) 쓰레드를 동기화 시키는 장치 | shreduler |


```
// Tempo
0.25::second => dur BEAT;
BEAT => dur QN; // Quarter Note
BEAT * 4 => dur WN; // Whole Note

fun void ping() {
    Impulse pin => ResonZ rez => dac;
    700 => rez.freq;
    50 => rez.Q;
    while (true) {
        <<< "ping!", "" >>>;
        100 => pin.next;
        WN => now;
    }
}

fun void pong() {
    Impulse pon => ResonZ rez => dac;
    800 => rez.freq;
    50 => rez.Q;
    while (true) {
        <<< "pong!", "" >>>;
        100 => pon.next;
        QN => now;
    }
}

// create two children shreds
spork ~ ping();
spork ~ pong();

// a parent shred
while (true) 
    WN => now;
```

- 쉬레드(shred)는 시간에 맞추어 동기화하며, 동기화 시기는 프로그램으로 결정한다. 
- `spork ~ <함수 호출>` 로 새로운 자식 쉬레드를 만든다.
- 자식 쉬레드 수에는 제한이 없다.
- 부모가 없어지면 자식을 포함한 자손은 모두 없어진다.


### 7-1. 동시 계산 프로그램 사례 1 : 드럼 머신

<img src="image07/drumshredule.png" width="400">

```
// Drum Machine

// Tempo
0.25::second => dur BEAT;
BEAT => dur QN; // Quarter Note
BEAT * 2 => dur HN; // Half Note
BEAT * 4 => dur WN; // Whole Note

fun void kick() {
    SndBuf kick => dac;
    me.dir()+"/audio/kick_01.wav" => kick.read;
    while (true) {
        WN => now;
        0 => kick.pos;
    }
}

fun void snare() {
    SndBuf snare => dac;
    me.dir()+"/audio/snare_01.wav" => snare.read;
    while (true) {
        HN => now;
        0 => snare.pos;
    }
}

fun void hihat() {
    SndBuf hihat => dac;
    me.dir()+"/audio/hihat_01.wav" => hihat.read;
    0.2 => hihat.gain;
    while (true) {
        QN => now;
        0 => hihat.pos;
    }
}

spork ~ kick();
WN * 2 => now;
spork ~ hihat(); 
WN * 2 => now;
QN => now;
spork ~ snare();
WN * 4 => now;
```


### 7-2. 동시 계산 프로그램 사례 2 : 반달



#### 사례 : 반달 멜로디를 반주와 함께 연주하기

앞에서 공부한 `반달`의 첫 네 마디를 연주하는 프로그램을 만들어보자.
이번엔 멜로디와 반주를 독립적인 쉬레드로 만들어 동시에 따로 연주하도록 해보자. 

```
fun void righthand() {
    Rhodey piano => dac;
    [67,69, 67,64, 67,64,60, 55] @=> int MELODY[];
    [2,1,   2,1,   1,1,1,    3] @=> int LEN[];
    for (0 => int i; i < MELODY.size(); i++) {
        Std.mtof(MELODY[i]) => piano.freq;
        1 => piano.noteOn;
        LEN[i]::second / 2 => now;
        0 => piano.noteOff;
    }
}
```

```
fun void lefthand() {
    Wurley piano => dac;
    [48,52,55, 48,52,55, 48,52,55, 48,52,55] @=> int HARMONY[];
    [1,1,1,    1,1,1,    1,1,1,    1,1,1] @=> int LEN[];
    for (0 => int i; i < HARMONY.size(); i++) {
        Std.mtof(HARMONY[i]) => piano.freq;
        1 => piano.noteOn;
        LEN[i]::second / 2 => now;
        0 => piano.noteOff;
    }
}
```

```
righthand();
lefthand();
```

```
spork ~ righthand();
spork ~ lefthand();
6::second => now;
```

### 7-3. 동시 계산 활용 사례 : 여러 쉬레드가 공동으로 `UGen` 제어

먼저 STK 악기 `StkInstrument` 중에서 타악기 류를 알아보자.

#### `ModalBar`

<img src="image07/modalbar.png" width="500">

```
// Demo of modal bar presets
ModalBar bar => dac;

[62, 64, 66, 67, 69, 71, 73, 74] @=> int scale[];

for (0 => int i; i <= 8; i++) {
    i => bar.preset;
    for (0 => int j; j < scale.cap(); j++) {
        Std.mtof(scale[j]) => bar.freq;
        1 => bar.noteOn;
        0.4 :: second => now;
    }
}
```

이 타악기를 활용하여 재미있는 소리를 내는 프로그램을 공부해보자.

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

<img src="image07/machinecommand.png" width="500">

```
Machine.add(me.dir()+"/pingpong.ck") => int pingpong;
2.0 :: second => now;
Machine.add(me.dir()+"/drummachine.ck") => int drum;
6.0 :: second => now;
Machine.add(me.dir()+"/modalbar.ck") => int modal;
4.0 :: second => now;             
Machine.remove(modal);
2.0 :: second => now;
Machine.replace(pingpong,me.dir()+"/modalbar.ck") => modal;
4.0 :: second => now;
Machine.remove(modal);
```

### 7-5. 사례 학습 : Jazz Quartet Band

- 관악기 : `Flute`
- 피아노 : `Rhodey`
- 베이스 : `Mandolin`
- 드럼 : `SndBuf`

#### `piano.ck`

```
Rhodey piano[4];
piano[0] => dac;
piano[1] => dac;
piano[2] => dac;             
piano[3] => dac;

[[53,57,60,64],[51,55,60,63]] @=> int chord[][]; 

while( true ) {
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

#### `bass.ck`

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


#### `drums.ck`

```
SndBuf hihat => dac; 
me.dir(-1) + "/audio/hihat_01.wav" => hihat.read;

while (true) {
    Math.random2f(0.1,.3) => hihat.gain;
    Math.random2f(.9,1.2) => hihat.rate;
    (Math.random2(1,2) * 0.2)::second => now;
    0 => hihat.pos;
}
```


#### `flute.ck`

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


#### `score.ck`

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

Machine.add(drumsPath) => drumsID;
```

#### `initialize.ck`

```
me.dir() + "/score.ck" => string scorePath;

Machine.add(scorePath);
```


### [실습] Bach의 Canon














