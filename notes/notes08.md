```
(c)도경구 version 1.0 (2022/10/21)
```

## 8. 객체와 클래스

### 8-1. 모두가 객체

ChucK 프로그래밍언어는 객체지향 프로그래밍 언어(object-oriented programming language)이다. 계산의 대상이 되는 데이터를 객체(object)로 보고, 객체를 필요한 대로 실행 중에 만들어 계산을 수행한다. 메모리에 거주하는 객체는 각자 고유의 특징과 상태를 필드변수(field)에 기억하고 있으며, 고유의 기능을 메소드(method)라는 함수로 갖추고 있어서 객체들끼리 메소드 호출 메시지를 주고 받으며 상태를 참고하거나 변경하면서 계산을 수행한다.

우리가 쓰고 있는 진동기도 객체이다. 예를 들어 다음과 같이 `SinOsc` 진동기를 하나 설치하고 이름을 붙이면,

```
SinOsc s1;
```

메모리에 객체가 다음 그림과 같은 모양으로 생긴다고 상상할 수 있다.

<img src="https://i.imgur.com/z6wXk3g.png" width="300">

`s1` 이름으로 언제든지 이 `SinOsc` 진동기 객체에 접근할 수 있다.
다음과 같은 형식으로 메소드 호출 메시지를 보내서 주파수 정보를 알아볼 수도 있다.

```
<<< s1.freq() >>>;
```

이 객체의 주파수 변경은 다음과 같은 두 가지 형식으로 가능하다.

```
s1.freq(440.0);
440.0 => s1.freq;
```

변경 후 `SinOsc` 진동기 객체는 다음과 같다.

<img src="https://i.imgur.com/HyffFfY.png" width="300">

`SinOsc` 진동기를 필요한 대로 몇개든 설치할 수 있다.
각 진동기는 이름을 다르게 붙여서 구별한다.

```
SinOsc s2;
```

그러면 메모리에 똑 같은 `SinOsc` 객체가 새로 또 하나 생긴다.

<img src="https://i.imgur.com/JeEnQhh.png" width="300">

사실 `UGen`은 모두 객체이다. 심지어는 버철머신 `Machine`도 객체이다.

배열도 객체이다.
다음과 같이 배열을 만들어 선언하면,
```
[0,0,1,1,0,1,0,1] @=> int nums[];
```

메모리에 배열 객체가 다음 그림과 같은 모양으로 생긴다고 상상할 수 있다.

<img src="https://i.imgur.com/zucmZmc.png" width="450">


### 8-2. 클래스 만들기

클래스(class)는 객체를 만드는 일종의 형틀(template) 프로그램 이다.

#### 8-2-1. 클래스 정의와 객체 생성

#### 사례 1

```
// 클래스 정의
class PianoKey {
    60 => int note;
    1.0 => float gain;

    fun int changeOctave() {
        return note + 12;
    }

    fun int changeOctave(int n) {
        return note + n * 12;
    }
}

// 객체 생성
PianoKey key;

<<< key.note, key.gain, key.changeOctave() >>>;

2 +=> key.note;
0.3 -=> key.gain;
<<< key.note, key.gain, key.changeOctave(-1) >>>;
```

#### 사례 2

```
class ResonantPop {
    Impulse imp => ResonZ filt => dac;
    100.0 => filt.Q => filt.gain;
    1000.0 => filt.freq;

    fun void freq(float freq) {
        freq => filt.freq;
    }

    fun void setQ(float Q) {
        Q => filt.Q;
    }

    fun void setGain(float gain) {
        filt.Q() * gain => imp.gain;
    }

    fun void noteOn(float volume) {
        volume => imp.next;
    }
}

ResonantPop pop;

while (true) {
    Std.rand2f(1100.0,1200.0) => pop.freq;
    1 => pop.noteOn;
    0.1 :: second => now;
}
```

#### 8-2-2. 중복

#### 메소드의 중복 정의

클래스 내부에 파라미터의 타입 또는 개수를 차별화하여 같은 이름의 메소드를 몇 개라도 중복(overload)하여 정의할 수 있다. 아래 사례에서는 주파수를 설정하는 `freq` 메소드를 중복하여 정의하고 있다. 인수가 `float` 타입이면 받은대로 주파수를 설정하고, `int` 타입이면 MIDI 번호로 간주하여 해당 주파수로 변환하여 설정하고, `string` 타입이면 계명으로 간주하여 해당 주파수로 변환하여 설정한다.

```
class ResonantPop {
    Impulse imp => ResonZ filt => dac;
    100.0 => filt.Q => filt.gain;
    1000.0 => filt.freq;

    fun void freq(float freq) {
        freq => filt.freq;
    }

    fun void freq(int note) {
        Std.mtof(note) => filt.freq;
    }

    fun void freq(string name) {
        [21,23,12,14,16,17,19] @=> int notes[]; // A0,B0,C0,D0,E0,F0,G0
        name.charAt(0) - 65 => int base; // A=0,B=1,C=2,D=3,E=4,F=5,G=7
        notes[base] => int note;
        if (0 <= base && base <= 6) {
            if (name.charAt(1) == '#' || name.charAt(1) == 's') // sharp
                notes[base] + 1 => note;
            if (name.charAt(1) == 'b' || name.charAt(1) == 'f') // flat
                notes[base] - 1 => note;
        }
        else
            <<< "Illegal Note Name!" >>>;
        name.charAt(name.length()-1) - 48 => int oct; // 0, 1, 2, ..., 9
        if (0 <= oct && oct <= 9) {
            12 * oct +=> note;
            this.freq(note);
        }
        else
            <<< "Illegal Octave!" >>>;
    }

    fun void setQ(float Q) {
        Q => filt.Q;
    }

    fun void setGain(float gain) {
        filt.Q() * gain => imp.gain;
    }

    fun void noteOn(float volume) {
        volume => imp.next;
    }
}
```

<img src="https://i.imgur.com/c5RGAX9.png" width="450">


#### 연산자의 중복

<img src="https://i.imgur.com/8tJkDKm.png" width="500">


#### 8-2-3. `public` 클래스

정의한 클래스를 다른 파일에서 사용할 수 있도록 하려면, `class` 키워드 앞에 `public`을 명시하여 공개 의사를 밝혀야 한다. `public` 키워드를 붙이고 실행하면, 선언한 클래스가 버철 머신에 공개 등록되면서 다른 프로그램 파일에서 접근하여 사용할 수 있게 된다. 버철 머신에 공개용으로 일단 등록이 되면, 동일 이름의 `public` 클래스의 재실행은 불가능하다. 클래스의 수정이 필요하다면, `clearVM` 단추를 눌러 버철머신을 청소하여 초기 상태로 되돌려 놓은 다음 재실행하는 수밖에 없다.

<img src="https://i.imgur.com/hphd7Se.png" width="500">

#### 사례

아래 `BPM` 클래스는 템포 설정을 편리하게 할 용도로 제작하였다. 이 클래스의 `tempo` 메소드는 기준 박자를 받아서 1박자, 반박자, 1/4박자, 1/8박자를 한꺼번에 설정해준다.

##### `BPM.ck`

```
public class BPM { // Beats Per Minute
    dur quarter; // 1/4
    dur one_eighth; // 1/8
    dur one_sixteenth; // 1/16
    dur one_thirtysecond; // 1/32

    fun void tempo(float beat) { // beat in BPM
        60.0 / beat => float spb; // seconds per beat  
        spb::second => quarter;
        quarter / 2.0 => one_eighth;
        quarter / 4.0 => one_sixteenth;
        quarter / 8.0 => one_thirtysecond;
    }
}
```

위의 `BPM` 클래스는 `public`으로 정의되었으니, 실행하면 버철머신에 공개 등록된다. 따라서 아래와 같이 다른 파일에서 자유로이 `BPM` 객체를 생성하여 활용할 수 있다.

##### `useBPM1.ck`

```
SinOsc s => dac;
0.3 => s.gain;
BPM bpm;
bpm.tempo(300);

for (400 => int freq; freq < 900; 50 +=> freq) {
    freq => s.freq;
    bpm.quarter => now;
}
```

##### `useBPM2.ck`

```
SinOsc s => dac;
0.3 => s.gain;
BPM bpm;
bpm.tempo(200);

for (900 => int freq; freq > 400; 50 -=> freq) {
    freq => s.freq;
    bpm.quarter => now;
}
```



#### 8-2-4. `static` 변수

필드 변수를 아래와 같이 `static` 으로 선언하면 어떤 차이점이 있나?
- `static`이 아닌 필드 변수는 객체 소속으로, 설정한 값은 생성한 객체가 살아있는 동안만 유효하고 실행이 끝나면 객체와 함께 사라진다.
- `static` 필드 변수는 클래스 소속으로, 객체의 생사 여부와 상관없이 영구히 존재한다. 따라서 필드 변수 값은 버철 머신 전체에서 공유된다.

##### `BPM.ck`

```
public class BPM { // Beats Per Minute
    static dur quarter; // 1/4
    static dur one_eighth; // 1/8
    static dur one_sixteenth; // 1/16
    static dur one_thirtysecond; // 1/32

    fun void tempo(float beat) { // beat in BPM
        60.0 / beat => float spb; // seconds per beat  
        spb::second => quarter;
        quarter / 2.0 => one_eighth;
        quarter / 4.0 => one_sixteenth;
        quarter / 8.0 => one_thirtysecond;
    }
}
```

아래 `useBPM1.ck`를 실행하면 `bpm.tempo(300)` 메소드 호출로 `BPM` 클래스 소속 4개의 `static` 필드 변수 값이 각각 설정된다. 이후 이 파일의 실행이 끝난 이후에도 이 필드 변수 값은 그대로 살아있어서, 아래 `useBPM2.ck`를 실행하면 별도로 다른 템포를 설정하지 않으면 기존에 설정된 값으로 프로그램을 실행한다. 직접 실행하여 확인해보자.

##### `useBPM1.ck`

```
SinOsc s => dac;
0.3 => s.gain;
BPM bpm;
bpm.tempo(300);

for (400 => int freq; freq < 900; 50 +=> freq) {
    freq => s.freq;
    bpm.quarter => now;
}
```

##### `useBPM2.ck`

```
SinOsc s => dac;
0.3 => s.gain;
BPM bpm;
// bpm.tempo(200);

for (900 => int freq; freq > 400; 50 -=> freq) {
    freq => s.freq;
    bpm.quarter => now;
}
```

####  8-2-5. 합주 활용 사례 1

위의 3 파일과 아래 3 파일을 같은 폴더에 넣고 `starter.ck` 파일을 실행시키면 다음과 같은 순서로 `score.ck`의 쉬레줄에 따라 시간에 맞추어 다음과 같은 순서로 쉬레드가 생긴다. 실행하여 버철머신 모니터를 관찰해보자.

- shred 1 - `starter.ck` at 0:00
- shred 2 - `BPM.ck`  at 0:00
- shred 3 - `score.ck` at 0:00
- shred 4 - `useBPM1.ck` at 0:00
- shred 5 - `useBPM2.ck` at 2:00
- shred 6 - `useBPM2.ck` at 7:00
- shred 7 - `useBPM3.ck` at 8:00
- shred 8 - `useBPM2.ck` at 10:00
- shred 9 - `useBPM3.ck` at 11:00
- shred 10 - `useBPM2.ck` at 13:00
- shred 11 - `useBPM3.ck` at 14:00
- ...

##### `starter.ck`

```
Machine.add(me.dir()+"BPM.ck");
Machine.add(me.dir()+"score.ck");
```

##### `UseBPM3.ck`

```
SinOsc s => dac;
0.3 => s.gain;
BPM bpm;
Math.random2f(300.0,1000.0) => bpm.tempo;

for (900 => int freq; freq > 400; 50 -=> freq) {
    freq => s.freq;
    bpm.quarter => now;
}
```

##### `score.ck`

```
Machine.add(me.dir()+"useBPM1.ck");
2.0::second => now;
Machine.add(me.dir()+"useBPM2.ck");
3.0::second => now;
// rest
2.0::second => now;
while (true) {
    Machine.add(me.dir()+"useBPM2.ck");
    1.0 :: second => now;
    Machine.add(me.dir()+"useBPM3.ck");
    2.0 :: second => now;
}
```


#### 8-2-6. 합주 활용 사례 2 : 드럼 머신

#### `BPM` 클래스로 합주 박자 동기화하기


##### `kick.ck`

```
SndBuf kick => dac;
1 => kick.gain;
me.dir() + "audio/kick_01.wav" => kick.read;  

BPM bpm;
while (true) {
    // Oxxx|Oxxx|Oxxx|Oxxx
    for (0 => int beat; beat < 4; beat++) {
        0 => kick.pos;
        bpm.quarter => now;
    }
}
```

##### `snare.ck`

```
SndBuf snare => dac;
0.5 => snare.gain;
me.dir() + "audio/snare_01.wav" => snare.read;
snare.samples() => snare.pos;

BPM bpm;
while (true) {
    // xxxxOxxxxxxxOOxx
    bpm.quarter => now;
    0 => snare.pos;
    2.0 * bpm.quarter => now;
    0 => snare.pos;
    bpm.quarter / 4.0 => now;
    0 => snare.pos;
    3.0 * bpm.quarter / 4.0 => now;
}
```

##### `cowbell.ck`

```
SndBuf cow => dac;
0.3 => cow.gain;
me.dir() + "audio/cowbell_01.wav" => cow.read;

BPM bpm;
while (true) {
    // xxxx|xxxx|xxxx|xxOx
    for (0 => int beat; beat < 8; beat++) {
        if (beat == 7)
            0 => cow.pos;
        bpm.one_eighth => now;
    }
}
```

##### `hihat.ck`

```
SndBuf hat => dac;
0.3 => hat.gain;
me.dir() + "audio/hihat_02.wav" => hat.read;

BPM bpm;
while (true) {
    // OxOx|OxOx|OxOx|Oxxx
    for (0 => int beat; beat < 8; beat++) {
        if (beat != 7)
            0 => hat.pos;
        bpm.one_eighth => now;
    }
}
```

##### `clap.ck`

```
SndBuf clap => dac;
0.3 => clap.gain;
me.dir() + "audio/clap_01.wav" => clap.read;

BPM bpm;
while (true) {
    // ????|????|????|???? (3/8 probability random)
    for (0 => int beat; beat < 16; beat++) {
        if (Math.random2(0,7) < 3) {
            0 => clap.pos;
        }
        bpm.one_sixteenth => now;
    }
}
```

##### `score.ck`

```
BPM bpm;
bpm.tempo(120.0);

Machine.add(me.dir()+"kick.ck") => int kickID;
8.0 * bpm.quarter => now;
Machine.add(me.dir()+"snare.ck") => int snareID;
8.0 * bpm.quarter => now;
Machine.add(me.dir()+"hihat.ck") => int hatID;
Machine.add(me.dir()+"cowbell.ck") => int cowID;
8.0 * bpm.quarter => now;
Machine.add(me.dir()+"clap.ck") => int clapID;
8.0 * bpm.quarter => now;

<<< "Play with tempo" >>>;
80.0 => float new_tempo;
bpm.tempo(new_tempo);
8.0 * bpm.quarter => now;
2 *=> new_tempo;
bpm.tempo(new_tempo);
8.0 * bpm.quarter => now;

<<< "Gradually decrease tempo" >>>;
while (new_tempo > 60.0) {
    20 -=> new_tempo;
    bpm.tempo(new_tempo);
    <<< "tempo = ", new_tempo >>>;
    4.0 * bpm.quarter => now;
}

// pulls out instruments, one at a time
Machine.remove(kickID);
8.0 * bpm.quarter => now;
Machine.remove(snareID);
Machine.remove(hatID);
8.0 * bpm.quarter => now;
Machine.remove(cowID);
8.0 * bpm.quarter => now;
Machine.remove(clapID);
```

##### `starter.ck`

```
Machine.add(me.dir()+"BPM.ck");
Machine.add(me.dir()+"score.ck");
```


### 8-3.  상속

기존 클래스의 속성과 기능을 그대로 상속(inheritance)받아 재사용하면서 새로운 클래스를 손쉽게 만들 수 있다.

```
class Child extends Parent
```

위와 같이 `extends` 키워드를 사용하여 상속관계를 언급하면, `Parent` 클래스의 모든 것을 물려받아 `Child` 클래스를 작성한다는 뜻이 된다. 다시 말해, `Parent` 클래스에 작성되어 있는 코드는 `Child` 클래스에서 언급하지 않아도 모두 있는 것으로 간주한다는 말이다. `Child` 클래스에는 새로운 코드를 추가하거나, 중복시키거나(overload), 물려받은 코드를 무효화하고 새로 만들 수 있다(override).

#### 8-3-1. 상속 사례 1 : 악기 개인화

<img src="https://i.imgur.com/Z7lJSFT.png" width="200">

##### `MyClarinet.ck`

```
public class MyClarinet extends Clarinet {
    // override
    fun void noteOn(int note, float volume) {
        Std.mtof(note) => this.freq;
        volume => this.noteOn;
    }
}
```

##### `play.ck`

```
MyClarinet clarinet => dac;

[60,62,64,65,67,69,71,72] @=> int scale[];

for (0 => int i; i < scale.size(); i++) {
    clarinet.noteOn(scale[i], 0.2);
    0.5::second => now;
    1 => clarinet.noteOff;
}
```

##### `starter.ck`

```
Machine.add(me.dir()+"myclarinet.ck");
Machine.add(me.dir()+"play.ck");
```

#### 상속 사례 2 : 다형 (Polymorphism)

Parent 클래스의 변수에는 Child 객체를 담을 수 있다.
예를 들어 `Osc`은 `SinOsc`, `TriOsc`, `SqrOsc`, `SawOsc`의 Parent 클래스이다. 따라서 다음 사례와 같이 `Osc` 타입의 파라미터 변수 `osc`는 이 네 종류의 진동기를 모두 수용할 수 있다.

####

```
TriOsc s => dac;
swell(s, 0.0, 1.0, 0.01);

fun void swell(Osc osc, float begin, float end, float step) {

    // swell up volume
    for (begin => float v; v < end; step +=> v) {
        v => osc.gain;
        0.02 :: second => now;
    }
    // swell down volume
    for (end => float v; v >= begin; step -=> v) {
        v => osc.gain;
        0.02:: second => now;
    }
}
```

`StkInstrument`는 아래 그림에서 볼 수 있듯이 다양한 악기의 Parent 클래스이다. 따라서 아래 코드 사례에서 볼 수 있듯이,  `StkInstrument` 배열은 소속의 어떤 악기 객체도 담을 수 있다.

<img src="https://i.imgur.com/mbTrqiH.png" width="400">


```
StkInstrument inst[4];
Sitar inst0 @=> inst[0] => dac;
Mandolin inst1 @=> inst[1] => dac;
Clarinet inst2 @=> inst[2] => dac;
BlowBotl inst3 @=> inst[3] => dac;

for (0 => int i; i < 4; i++) {
    500.0 - (i*100.0) => inst[i].freq;
    1 => inst[i].noteOn;
    second => now;
    1 => inst[i].noteOff;
}
```

### 실습

#### 1. 스마트 `Mandolin`

다음 코드 이해하고, 실행하여 소리를 들어보자.

##### `MandoPlayer.ck`

```
// Listing 9.20 Smart mandolin instrument and player class
// Four Mando "strings", plus some smarts
// by Perry R. Cook, March 2013

public class MandoPlayer {
    Mandolin m[4];
    m[0] => JCRev rev => dac;
    m[1] => rev;
    m[2] => rev;
    m[3] => rev;
    0.25 => rev.gain;
    0.02 => rev.mix;

    // set all four string frequencies in one function
    fun void freqs(float g, float d, float a, float e) {
        m[0].freq(g);
        m[1].freq(a);
        m[2].freq(d);
        m[3].freq(e);
    }

    // set all four string notes in one function
    fun void notes(int g, int d, int a, int e) {
        m[0].freq(Std.mtof(g));
        m[1].freq(Std.mtof(d));
        m[2].freq(Std.mtof(a));
        m[3].freq(Std.mtof(e));
    }

    // a few named chords to get you started, add your own!!
    fun void chord(string which) {
        if (which == "G") this.notes(55,62,71,79);   // G3, D4, B4, G5.
        else if (which == "C") this.notes(55,64,72,79);
        else if (which == "D") this.notes(57,62,69,78);
        else <<< "I don't know this chord: ", which >>>;
    }

    // roll a chord from lowest note to highest at rate
    fun void roll(string chord, dur rate) {
        this.chord(chord);
        for (0 => int i; i < 4; i++) {
            1 => m[i].noteOn;
            rate => now;
        }
    }

    // Archetypical tremolo strumming
    fun void strum(int note, dur howLong) {
        int whichString;
        if (note < 62) 0 => whichString;
        else if (note < 69) 1 => whichString;
        else if (note < 76) 2 => whichString;
        else 3 => whichString;
        Std.mtof(note) => m[whichString].freq;
        now + howLong => time stop;
        while (now < stop) {
            Std.rand2f(0.5,1.0) => m[whichString].noteOn;
            Std.rand2f(0.06,0.09)::second => now;
        }
    }

    // Damp all strings by amount
    // 0.0 = lots of damping, 1.0 = none
    fun void damp(float amount) {
        for (0 => int i; i < 4; i++) {
            amount => m[i].stringDamping;
        }
    }
}
```




##### `score.ck`

```
MandoPlayer m;

["G","C","G","D","D","D","D","G"] @=> string chords[];
[0.4,0.4,0.4,0.1,0.1,0.1,0.1,0.01] @=> float durs[];
[79,81,83] @=> int strums[];

// roll
0 => int i;
while (i < chords.cap()) {
    m.roll(chords[i], durs[i]::second);
    i++;
}

// now strum a few notes
0 => i;
while (i < strums.cap()) {
    m.strum(strums[i++], 1.0::second);
}

// then end up with a big open G chord
m.damp(1.0);
m.roll("G", 0.02::second);
2.0::second => now;

// damp it to silence, letting it ring a little
m.damp(0.01);
1.0::second => now;
```



##### `starter.ck`

```
Machine.add(me.dir()+"mandolin.ck");
Machine.add(me.dir()+"score.ck");
```

#### 2. 합창

지난 실습 시간에 만든 프로그램을 이번엔 음별로 파일을 따로 만든 다음 `Machine`을 활용하여 합주하는 방식으로 개선해보자.
그리고 필요한 대로 클래스를 만들어서 활용하자.


다음 악보는 멜로디의 뒤 두 마디에 높은 음이 화음으로 추가되고, 아래에 베이스 음이 추가되어 있다.

![Where Is Thumbkin 2](https://i.imgur.com/ajiw85k.png)

멜로디 2중창을 파일 하나에, 베이스를 다른 파일에 따로 두고 합창하도록 작성하자.

```
[
"F4","G4","A4","F4",            "F4","G4","A4","F4",
"A4","Bb4","C5",                "A4","Bb4","C5",
"C5","D5","C5","Bb4","A4","F4", "C5","D5","C5","Bb4","A4","F4",
"F4","C4","F4",                 "F4","C4","F4"
] @=> string melody[];

[
"F4","G4","A4","F4",            "F4","G4","A4","F4",
"A4","Bb4","C5",                "A4","Bb4","C5",
"C5","D5","C5","Bb4","A4","F4", "C5","D5","C5","Bb4","A4","F4",
"A4","E4","A4",                 "A4","E4","A4"
] @=> string melody_high[];

[
 qn,  qn,  qn,  qn,              qn,  qn,  qn,  qn,
 qn,  qn,  hn,                   qn,  qn,  hn,
 en,  en,  en,  en,   qn,  qn,   en,  en,  en,  en,   qn,  qn,
 qn,  qn,  hn,                   qn,  qn,  hn
] @=> dur durs[];

[
"F3","C4","F3", "F3","C4","F3", "F3","C4","F3", "F3","C4","F3",
"F3","C4","F3", "F3","C4","F3", "F3","C4","F3", "F3","C4","F3"
] @=> string bass[];

[
 qn,  qn,  hn,   qn,  qn,  hn,   qn,  qn,  hn,   qn,  qn,  hn,
 qn,  qn,  hn,   qn,  qn,  hn,   qn,  qn,  hn,   qn,  qn,  hn
] @=> dur durs_bass[];
```

#### 3. 돌림노래

이번엔 다음 곡을 돌림노래로 연주해보자.

![Row-Row-Row-Your-Boat](https://i.imgur.com/rvB5d4E.png)

```
[
"C4",          "C4",             "C4",     "D4","E4",       
"E4",     "D4","E4",     "F4",   "G4",
"C5","C5","C5","G4","G4","G4",   "E4","E4","E4","C4","C4","C4",
"G4",     "F4","E4",     "D4",   "C4"
] @=> string melody[];

[
 n3,            n3,               n2,       n1,  n3,       
 n2,       n1,  n2,       n1,     n6,
 n1,  n1,  n1,  n1,  n1,  n1,     n1,  n1,  n1,  n1,  n1,  n1,
 n2,       n1,  n2,       n1,     n6
] @=> dur durs[];
```

4개의 개별 개체를 만들어 차례로 2 마디씩 늦게 연주를 시작하도록 하면 돌림노래가 완성된다.
악기는 자유로이 선택한다.

```
public class BPM { // Beats Per Minute

    static dur n1, n2, n3, n6;

    fun void tempo(float beat) { // beat in BPM
        60.0 / beat => float spb; // seconds per beat  
        spb::second => n1;
        n1 * 2 => n2;
        n1 * 3 => n3;
        n1 * 6 => n6;
    }
}
```

```
public class Play {

    fun void play(StkInstrument instrument, string notes[], dur durs[]) {
        for (0 => int i; i < notes.size(); i++)
            playnote(instrument, notes[i], durs[i]);
    }

    fun void playnote(StkInstrument instrument, string note, dur duration) {
        Std.mtof(s2n(note)) => instrument.freq;
        if (note != "REST")
            1 => instrument.noteOn;
        duration => now;
        1 => instrument.noteOff;
    }

    fun int s2n(string name) {
        [21,23,12,14,16,17,19] @=> int notes[]; // A0,B0,C0,D0,E0,F0,G0
        name.charAt(0) - 65 => int base; // A=0,B=1,C=2,D=3,E=4,F=5,G=7
        notes[base] => int note;
        if (0 <= base && base <= 6) {
            if (name.charAt(1) == '#' || name.charAt(1) == 's') // sharp
                notes[base] + 1 => note;
            if (name.charAt(1) == 'b' || name.charAt(1) == 'f') // flat
                notes[base] - 1 => note;
        }
        else
            <<< "Illegal Note Name!" >>>;
        name.charAt(name.length()-1) - 48 => int oct; // 0, 1, 2, ..., 9
        if (0 <= oct && oct <= 9) {
            12 * oct +=> note;
            return note;
        }
        else
            <<< "Illegal Octave!" >>>;
    }

}
```

### 숙제 (마감 11월 2일)

지난 숙제로 만든 드럼 머신 음악을 개선하는 과제이다. 소리 별로 파일을 별도로 작성하고 `score.ck` 파일에서 `Machine`을 활용하여 연주를 지휘하여 좀 더 역동적으로 음악을 연주할 수 있도록 프로그램을 개선하자. 그리고 `BPM.ck`를 포함하여 필요한만큼 클래스도 추가하여 작성해야 한다.

-   `initialize.ck`에서 연주가 시작할 수 있도록 해야한다.
-   지금까지 공부한 지식을 최대한 활용하여 코딩해야 한다.
-   모든 프로그램 파일의 맨 상단에 본인의 학번과 이름을 영어로 기입한다.
-   파일은 zip으로 압축하여 묶어서 파일명을 학번으로 하여 LMS에 제출한다.
