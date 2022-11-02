```
(c)도경구 version 1.0 (2022/11/2)
```

## 9. 이벤트 구동 프로그래밍

특정 이벤트가 발생했을 때 반응하는 장치를 활용한 프로그래밍

- 외부 기기(키보드, 마우스)를 통한 입력 신호에 반응
- 프로그램 내부의 다른 쉬레드가 보내는 신호에 반응

### 9-1. 이벤트와 신호

#### 이벤트 객체 만들어 신호 기다리기

`Event` 객체는 자신을 부르는 신호를 받을 때까지 자신이 속한 쉬레드의 실행을 멈추고 기다리게할 수 있다.
어떤 쉬레드에서 `e` 라는 이름의 이벤트 객체를 다음과 같이 만들고
```
Event e;
```
다음과 같이 쓰면
```
e => now;
```
다른 쉬레드 또는 외부에서 이벤트 `e`에게 신호를 보낼 때까지 이 쉬레드는 실행을 멈추고 무한정 기다린다.

예를 들어 다음 함수는 이벤트 객체를 인수로 받아서 그 이벤트 신호를 기다리다가, 신호를 받으면 즉시 콘솔모니터에 `Bingo!`를 프린트 하는 함수이다.
```
fun int bingo(Event e) {
    e => now;
    <<< "Bingo!", "" >>>;
}
```
이제 다음 선언을 실행하면
```
Event game;
```
`game` 이라는 이름의 이벤트 객체를 만드는데, 이 상황을 그림으로 그려보면 다음과 같다.

<img src="https://i.imgur.com/lh3AyfE.png" width="500">

이어서 `game` 이벤트를 인수로 받아 `bingo` 함수를 실행하는 자식 쉬레드를 다음과 같이 만들면, 이제 두 개의 쉬레드가 실행할 준비가 된다.
```
spork ~ bingo(game);
```
그런데 자식 쉬레드는 부모 쉬레드가 실행해야 (동기화 하여) 따라 실행하므로, 다음과 같이 잠시라도 시간을 보내야 한다.
```
samp => now;
```
그러면 자식 쉬레드인 `bingo` 함수가 바로 실행한다. 그런데 첫 문장이 `game => now` 이므로,  `game` 이벤트 신호를 기다리며 실행을 멈춘다. 아울러 자신이 `game` 이벤트 신호를 대기하고 있다고 등록한다.

이 시점의 상황을 그림으로 그려보면 다음과 같다.

<img src="https://i.imgur.com/hEQwMlI.png" width="500">

**잠깐** : 여기서 시간을 전혀 보내지 않고 자식 쉬레드가 실행하도록 풀어주는 방법은 없을까? 있다. 부모 쉬레드가 `samp => now;` 대신 `me.yield();`를 실행하면 자신이 낳은 모든 쉬레드가 바로 실행을 개시한다.


#### 이벤트 신호 보내기

그러면 신호를 기다리고 있는 `game` 이벤트에 신호를 보내고 싶은 쉬레드는 다음과 같은 형식으로 신호를 보낸다.
```
game.signal();
```
그러면 `game` 이벤트 객체는 신호가 왔음을 등록된 쉬레드에 알려주어 실행을 재개할 수 있도록 한다.

이 시점의 상황을 그림으로 그려보면 다음과 같다.

<img src="https://i.imgur.com/LjFvSNZ.png" width="500">

이제 신호를 기다리던 쉬레드는 실행을 재개할 준비가 되었다. 이 사례에서 기다리던 쉬레드는 자식 쉬레드이므로 부모 쉬레드는 `samp => now;`와 같이 시간을 보내주든지, `me.yield()`와 같이 풀어주면, 자식 쉬레드는 남은 코드를 실행하여 콘솔 모니터에 `Bingo!`를 프린트 한다.

설명한 대로 실행하여 실행 결과를 확인해보자.

### 9-2. 이벤트 구동으로 쉬레드 동기화

#### 9-2-1. 두 쉬레드 동기화

```
Event game;

spork ~ play(game,60);

while (true) {
    game.signal();
    second => now;
}

fun void play(Event e, int note) {
    Mandolin guitar => dac;
    while (true) {
        e => now;
        Std.mtof(note) => guitar.freq;
        0.5 => guitar.noteOn;
    }
}
```

#### 9-2-2. 여러 쉬레드 차례로 하나씩 동기화

```
Event game;

spork ~ play(game,60);
spork ~ play(game,64);
spork ~ play(game,67);

while (true) {
    game.signal();
    second => now;
}
```

<img src="https://i.imgur.com/rimD4fI.png" width="1000">


#### 9-2-3. 여러 쉬레드 한꺼번에 동기화

```
Event game;

spork ~ play(game,60);
spork ~ play(game,64);
spork ~ play(game,67);

while (true) {
    game.signal();
    game.signal();
    game.signal();
    second => now;
}
```

<img src="https://i.imgur.com/uyxH6FT.png" width="500">


#### `broadcast()` 사용


```
Event game;

spork ~ play(game,60);
spork ~ play(game,64);
spork ~ play(game,67);

while (true) {
    game.broadcast();
    second => now;
}
```

<img src="https://i.imgur.com/eVryhyk.png" width="500">



- 주의: 키보드를 누를 때, miniAudicle 편집기 바깥으로 나가기

### 9-3. 키보드 입력 이벤트

이벤트를 활용하여 외부 기기에서의 비동기적 실시간 입력을 프로그램이 바로 반응하게 할 수 있다.

컴퓨터 키보드를 누르는 이벤트를 기다리고 있다가, 키보드를 누르면 반응하는 프로그램을 만들어보자. 키보드, 마우스 등과 같은 외부 기기에 반응하려면 `Hid`(Human interface device) 객체를 만들어 활용한다.

#### 9-3-1. 키보드 연결

```
Hid hid;   // Hid 객체 생성
HidMsg msg;  // 이벤트가 전달하는 메시지
0 => int device; // 장치 번호
// 키보드에서 신호받기 위해서 Hid 객체를 키보드에 연결
if (! hid.openKeyboard(device)) { // 연결 실패 처리         
    <<< "Can't open this device!! ", "Sorry." >>>;  
    me.exit();
}
// 연결 상태 확인
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

- 주의: 키보드를 누르기 전에,  miniAudicle 편집창 바깥을 클릭하여 비활성창으로 만드는게 좋다. 그렇지 않으면 누르는 키가 모두 편집기에 기록된다.

#### 9-3-2. 사례 학습 : 키보드 오르간 만들기

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

#### 9-3-2. 마우스 드럼 만들기

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

### 실습 9-1. Gamelan Orchestra

1. 다름 코드를 일고 이해한 다음, 실행하여 이해한 대로 작동하는지 확인한다.
2. 악보을 원하는 대로 변경하고, 적절한 악기 및 드럼을 추가하여 나름대로 마음에 드는 합주 음악을 창작해본다.

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




### 실습 9-2. 진도아리랑

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





### 숙제 - 키보드 드럼 (마감 11월 9일 오후 3시)

- 프로그램을 완성한 다음, 실행에 필요한 샘플 파일과 함께 폴더에 넣어 zip으로 묶어서 제출한다.
- 압축을 풀면 바로 실행할 수 있어야 한다.
- 외부기기(키보드)의 어떤 키를 누르면 어떤 북 소리가 나는지 프로그램 상단에 주석으로 달아놓아야 한다.
