```
(c)도경구 version 0.12 (2021/11/11)
```

## 9. 이벤트 구동 프로그래밍

- 외부 연결 기기와 프로그램의 소통
- 프로그램 내부 쉬레드끼리의 소통

### 9-1. 이벤트

- 이벤트(event)는 어떤 일이 발생했을 때 쉬레드에게 알려주는 메카니즘이다.
따라서 특정 이벤트를 기다리는 쉬레드는 그 이벤트가 발생하기를 무한정 기다린다.
그 이벤트가 발생하면 기다리고 있던 쉬레드에게 신호를 보내 다음 작업을 진행하게 한다.
- 이벤트의 사례
  - 키보드나 마우스 버튼, MIDI 기기 키 누르기
  - 네트워크를 통해 다른 컴퓨터로부터 메시지 오기를 기다리기
  - 동시 실행 중인 다른 쉬레드의 특정 액션 기다리기

다음과 같이 `Event` 객체를 만들고 시간을 보내면,
```
Event event;
event => now;
```
해당 이벤트가 발생할 때까지 무작정 실행을 멈춘채 기다린다.
이벤트가 발생하면 다음 줄 부터 실행을 재개한다.

<img src="https://i.imgur.com/69ehPSh.png" width="500">

- 주의: 키보드를 칠 때, miniAudicle 바깥으로 나가기

### 9-2. 이벤트 구동 프로그래밍 - 키보드 입력

이벤트를 활용하여 외부 기기에서의 비동기적 실시간 입력을 프로그램이 바로 반응하게 할 수 있다.

컴퓨터 키보드를 누르는 이벤트를 기다리고 있다가, 키보드를 누르면 반응하는 프로그램을 만들어보자. 키보드, 마우스 등과 같은 외부 기기에 반응하려면 `Hid`(Human interface device) 객체를 만들어 활용한다.

```
Hid hid;   // Hid 객체 생성
HidMsg msg;  // 이벤트가 전달하는 메시지
0 => int device; // 장치 번호
// 키보드에서 신호받기 위해서 Hid 객체를 키보드에 연결
if (! hid.openKeyboard(device)) { // 연결 실패 처리         
    <<< "Can't open this device!! ", "Sorry." >>>;  
    me.exit();
}
// 연결 상태 프린트
<<< "keyboard '" + hid.name() + "' ready", "" >>>;

// 키보드 Hid 연결 테스트
Impulse imp => dac;
while (true) {
    hid => now;  // 키 누름 이벤트 발생하기를 기다림
    // 메시지 접수
    while (hid.recv(msg)) {
        // 키 누름 이벤트 처리
        if (msg.isButtonDown()) {
            // 키의 ascii 값 프린트하고,
            <<< "key DOWN:", msg.ascii >>>;
            // 클릭 소리 냄
            5 => imp.next;
        }
        else { // 키 올림 이벤트 처리
            // 아무 것도 하지 않음
        }
    }
}
```

#### 키보드 오르간 만들기

```
Hid hi;
HidMsg msg;
0 => int device;
if (! hi.openKeyboard(device)) me.exit();
<<< "keyboard '" + hi.name() + "' ready", "" >>>;

BeeThree organ => JCRev r => dac;
while (true) {
    hi => now;
    while (hi.recv(msg)) {
        if (msg.isButtonDown()) {
            <<< "Button Down:", msg.ascii >>>;
            Std.mtof(msg.ascii) => float freq;
            if (freq > 20000) continue; // 고음 스킵
            freq => organ.freq;
            1 => organ.noteOn;
            80::ms => now;
        }
        else {
            <<< "Button Up:", msg.ascii >>>;
            1 => organ.noteOff;
        }
    }
}
```

#### 마우스 드럼 만들기

```
Hid hi;
HidMsg msg;
0 => int device;
if (! hi.openMouse(device)) me.exit();
<<< "mouse '" + hi.name() + "' ready", "" >>>;

SndBuf snare => dac;
me.dir() + "/audio/snare_01.wav" => snare.read;
snare.samples() => snare.pos;
while (true) {
    hi => now;
    while (hi.recv(msg)) {
        if (msg.isButtonDown()) {
            <<< "Button down" >>>;
            0 => snare.pos;
        }
        else if (msg.isMouseMotion()) {
            if (msg.deltaX != 0) {
                <<< "Mouse delta X:", msg.deltaX >>>;
                msg.deltaX / 20.0 => snare.rate;
            }
        }
    }
}
```

### 9-3. 이벤트를 활용한 쉬레드 끼리의 통신

이벤트 발생을 프로그램으로 할 수 있도록 하면, 쉬레드 끼리의 소통이 가능해진다. 다음 그림과 같이 오른쪽 쉬레드가 이벤트를 기다리고 있고, 왼쪽 쉬레드는 `signal()` 메시지를 `Event` 객체에 보내면,

<img src="https://i.imgur.com/JpUxKrZ.png" width="300">

`Event` 객체는 이벤트를 발생하기를 기다리던 오른쪽 쉬레드에 다음 그림과 같이 알려서 깨우는 식으로 작동한다.

<img src="https://i.imgur.com/WRJyyqI.png" width="300">

### 9-3-1. `signal()`로 두 쉬레드 동기화 하기

```
Event e;

// 이벤트가 발생하기를 기다리는 함수
fun void foo(Event e) {
    Impulse imp => dac;
    while (true) {
        e => now; // 대기
        // 행동 개시
        <<< "Foo!!!", now / second >>>;
        5 => imp.next;
    }
}

spork ~ foo(e);

while (true) {
    e.signal();
    1::second => now;
}
```


### 9-3-2. `signal()`로 여러 쉬레드 동기화 하기

<img src="https://i.imgur.com/xA1avAd.png" width="500">

#### `signal()`로 이벤트 하나씩 발생시켜 차례로 하나씩 동기화

```
Event e;

// 이벤트가 발생하기를 기다리는 함수
fun void bar(Event event, string msg, float freq) {
    Impulse imp => ResonZ rez => dac;
    50 => rez.Q;
    while (true) {
        // 대기
        event => now;
        // 행동 개시
        <<< msg, freq, now / second >>>;
        freq => rez.freq;
        50 => imp.next;
    }
}

spork ~ bar(e, "Do ", 500.0);
spork ~ bar(e, "Mi ", 700.0);
spork ~ bar(e, "Sol ", 900.0);

while (true) {
    // 이벤트 발생 시그널을 하나 보냄
    e.signal();
    1::second => now;
}
```

#### `signal()`로 이벤트 모두 발생시켜 한꺼번에 같이 동기화

```
Event e;

// 이벤트가 발생하기를 기다리는 함수
fun void bar(Event event, string msg, float freq) {
    Impulse imp => ResonZ rez => dac;
    50 => rez.Q;
    while (true) {
        // 대기
        event => now;
        // 행동 개시
        <<< msg, freq, now / second >>>;
        freq => rez.freq;
        50 => imp.next;
    }
}

spork ~ bar(e, "Do ", 500.0);
spork ~ bar(e, "Mi ", 700.0);
spork ~ bar(e, "Sol ", 900.0);

while (true) {
    // 기다리던 세 쉬레드 모두에게 이벤트 발생 시그널 보냄
    e.signal();
    e.signal();
    e.signal();
    1::second => now;
}
```

#### `broadcast()`로 여러 쉬레드 한꺼번에 같이 동기화 하기

<img src="https://i.imgur.com/ALSEJTg.png" width="300">


```
Event e;

// 이벤트가 발생하기를 기다리는 함수
fun void bar(Event event, string msg, float freq) {
    Impulse imp => ResonZ rez => dac;
    50 => rez.Q;
    while (true) {
        // 대기
        event => now;
        // 행동 개시
        <<< msg, freq, now / second >>>;
        freq => rez.freq;
        50 => imp.next;
    }
}

spork ~ bar(e, "Do ", 500.0);
spork ~ bar(e, "Mi ", 700.0);
spork ~ bar(e, "Sol ", 900.0);

while (true) {
    // 기다리는 쉬레드 모두에게 발생 시그널 한꺼번에 보냄
    e.broadcast();
    1::second => now;
}

```

### 9-4. 사용자 정의 이벤트

다음과 같이 `Event`를 상속받아 사용자가 원하는 클래스를 정의할 수 있다.

```
class TheEvent extends Event {
    // 이벤트 데이터 기억
    int value;
}

// 이벤트 객체 생성
TheEvent e;

// 이벤트 처리 함수
fun int hello(TheEvent event) {
    while (true) {
        // 대기
        event => now;
        // 이벤트 데이터 사용
        <<< event.value >>>;
    }
}

// 쉬레드 생성
spork ~ hello(e);
spork ~ hello(e);
spork ~ hello(e);
spork ~ hello(e);

while (true) {
    1::second => now;
    Math.random2(0,5) => e.value;
    // 이벤트 발생
    e.signal();
}
```

### 사례 학습 - Gamelan Orchestra

```
class TheEvent extends Event {
    int note;
    float velocity;
}

TheEvent e1, e2;

NRev globalReverb => dac;
.1 => globalReverb.mix;

// instrument function to spork
fun void poly(StkInstrument instrument, TheEvent event, string name) {
    instrument => globalReverb; // 스피커 연결
    while (true) {
        // 대기
        event => now;
        // 연주
        <<< "Play", name >>>;
        event.note => Std.mtof => instrument.freq;
        event.velocity => instrument.noteOn;
    }
}

// "e1" 이벤트 대기 쉬레드
spork ~ poly(new StifKarp, e1, "StifKarp");                           
spork ~ poly(new Mandolin, e1, "Mandolin");
spork ~ poly(new Wurley, e1, "Wurley");

// "e2" 이벤트 대기 쉬레드
spork ~ poly(new Rhodey, e2, "Rhodey");

[60,62,64,67,69,72,74,76,79] @=> int notes[];

while (true) {
    Math.random2(1,6) => int dice;
    if (dice != 1) { // 5/6 확률로 선택
        notes[Math.random2(0,notes.size()-1)] => e1.note;
        Math.random2f(.2, .9) => e1.velocity;
        e1.signal();
        0.25::second => now;
    }
    else { // 1/6 확률로 선택
        notes[Math.random2(0,notes.size()-1)] - 24 => e2.note;
        notes[0] - 12 => e1.note;
        1.0 => e2.velocity;
        e1.broadcast();
        e2.signal();
        second => now;
    }
}
```


### 실습 - Gamelan 악보 변경, 악기추가 및 드럼 추가

아래에 첨부한 진도아리랑 악보에서 마음에 드는 마디 몇 개를 골라서 여러 악기로 무작위 순서로 연주하는 프로그램을 이벤트 구동 방식으로 작성하자.
그리고 장단을 맞추는 북 소리를 `SndBuf`를 활용하여 추가하자.
북 소리 샘플은 `audio.zip` 샘플을 활용한다.

진도아리랑과 장단을 맞출 타악기 박자를 9/8 박자 마디 기준으로 몇 개 사례를 들어보면 다음과 같다.

```
[1.0,2.0,1.0,3.0,2.0]
[3.0,2.0,1.0,1.0,2.0]
[6.0,3.0]
```

#### 진도 아리랑 악보

<img src="https://i.imgur.com/IzUKKK0.png" width="600">

```
[
"B3","E4","B3","E4","E4",       "B3","E4","B3","E4","E4",
"E4","E4","E4","F#4","F#4",     "E4","E4","B4","G4","B4",
"B3","B3","E4","E4",            "E4","E4","F#4",
"E4","G4","B4","G4","F#4","B3", "E4","E4",
"G4","G4",                      "G4","G4","B4","F#4",
"E4","G4","B4","F#4",           "E4","B3",
"E4","E4","E4","F#4",           "B4","G4","G4","F#4","E4",
"E4","G4","F#4","E4","B3",      "E4","E4"
] @=> string notes[];

[
2.0,1.0,2.0,1.0,3.0,     2.0,1.0,2.0,1.0,3.0,
1.0,2.0,1.0,2.0,3.0,     3.0,2.0,1.0,1.0,2.0,
3.0,2.0,1.0,3.0,         3.0,3.0,3.0,
2.0,1.0,2.0,0.5,0.5,3.0, 3.0,6.0,
3.0,6.0,                 3.0,2.0,1.0,3.0,
3.0,2.0,1.0,3.0,         3.0,6.0,
1.0,2.0,3.0,3.0,         1.0,2.0,1.0,2.0,3.0,
2.0,1.0,2.0,1.0,3.0,     3.0,6.0
] @=> float durs[];

StifKarp s => dac;
for (0 => int i; i < notes.size(); i++) {
    Std.mtof(midi(notes[i])) => s.freq;
    0.5 => s.noteOn;
    durs[i]::second / 5 => now;
}
```

#### `midi` 함수

- 다음 문자차례로 나열 조합하여 만든 MIDI음의 이름을 문자열로 받아서 MIDI음 번호를 리턴하는 함수
  - `C`, `D`, `E`, `F`, `G`, `A`, `B`
  - `#` 또는 `s`, `b` 또는 `f` (옵션)
  - `0`, ..., `9`

```
fun int midi(string name) {
    [21,23,12,14,16,17,19] @=> int notes[]; // A0,B0,C0,D0,E0,F0,G0
    name.charAt(0) - 65 => int base; // A=0,B=1,C=2,D=3,E=4,F=5,G=7
    notes[base] => int note;
    if (0 <= base && base <= 6) {
        if (name.charAt(1) == '#' || name.charAt(1) == 's') // sharp
            notes[base] + 1 => note;
        if (name.charAt(1) == 'b' || name.charAt(1) == 'f') // flat
            notes[base] - 1 => note;
    }
    else {
        <<< "Illegal Note Name!" >>>;
        return 0;
    }
    name.charAt(name.length()-1) - 48 => int oct; // 0, 1, 2, ..., 9
    if (0 <= oct && oct <= 9) {
        12 * oct +=> note;
        return note;
    }
    else {
        <<< "Illegal Octave!" >>>;
        return 0;
    }
}
```





### 숙제 - 키보드 드럼 (마감 11월 16일 오전 9시)

- 프로그램을 완성한 다음, 실행에 필요한 샘플 파일과 함께 폴더에 넣어 zip으로 묶어서 제출한다.
- 압축을 풀면 바로 실행할 수 있어야 한다.
- 외부기기(키보드)의 어떤 키를 누르면 어떤 북 소리가 나는지 프로그램 상단에 주석으로 달아놓아야 한다.
