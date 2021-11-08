```
(c)도경구 version 0.1 (2021/11/7)
```

## 9. 이벤트 구동 프로그래밍

이벤트 참고 매뉴얼 - [클릭](https://chuck.cs.princeton.edu/doc/language/event.html)


- 키보드와 마우스를 사용하여 실시간으로 소리 내기
- 이벤트(event)
  - 외부로 부터 신호와 정보를 받음
  - 쉬레드끼리 실시간 상호 소통


### 9-1. 이벤트

- 이벤트(event)는 어떤 일이 발생했을 때 쉬레드에게 알려주는 메카니즘이다.
따라서 특정 이벤트를 기다리는 쉬레드는 그 이벤트가 발생하기를 무한정 기다린다.
그러다가 그 이벤트가 발생하면 기다리고 있던 쉬레드에게 알려준다.
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

<img src="image09/event.png" width="500">

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

<img src="image09/intershred1.png" width="300">

`Event` 객체는 이벤트를 발생했음을 기다리던 오른쪽 쉬레드에 다음 그림과 같이 알려서 깨우는 식으로 작동한다.

<img src="image09/intershred2.png" width="300">

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

<img src="image09/signal.png" width="500">

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

<img src="image09/broadcast.png" width="300">


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

위의 Gamelan 프로그램을 국악 음계를 연주하는 프로그램으로 수정하자.
그리고 `SndBuf`를 활용하여 북 소리를 추가하자.

#### 평조

```
[63,65,68,70,72] @=> int notes1[];
```

#### 계면조

```
[63,66,68,70,73] @=> int notes2[];
```

#### 평조, 계면조 들어보기

```
SinOsc s => dac;

[63,65,68,70,72] @=> int notes1[]; // Eb4, F4, Ab4, Bb4, C5
for (0 => int i; i < notes1.size(); i++) {
    Std.mtof(notes1[i]) => s.freq;
    second => now;
}
[63,66,68,70,73] @=> int notes2[]; // Eb4, Gb4, Ab4, Bb4, Db5
for (0 => int i; i < notes2.size(); i++) {
    Std.mtof(notes2[i]) => s.freq;
    second => now;
}
```


### 숙제 - 키보드 드럼 (마감 11월 16일 오전 9시)













