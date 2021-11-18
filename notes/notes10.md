```
(c)도경구 version 0.2 (2021/11/17)
```

## 10. MIDI, OSC

- 라이브 연주를 위한 도구
- 프로그램으로 외부 MIDI 기기 실시간 제어하기
- OSC 프로토콜로 프로그램끼리 우무선 네트워크로 소통하기

#### 가상 MIDI 포트 만들기

- 가상 MIDI 포트 만들기
  - Mac OS
    - `Applications/Utilities`(응용 프로그램/유틸리티)에서 `Audio Midi Setup`실행 
    - 메뉴바에서 `Window` > `Show MIDI Studio`
    - `IAC 드라이버` 아이콘 클릭
    - `Device is online` 체크박스 선택
  - Windows
    - [loopMIDI(virtualMIDI)](https://www.tobias-erichsen.de/software/loopmidi.html) 다운 받아 설치
    - 좌하단 `+` 버튼 클릭
  - 주의: miniAudicle이 한글을 처리하지 못하므로 이름은 모두 영어로 붙일 것

- miniAudicle에서 가상 MIDI 포트 번호 확인
  - miniAudicle의  `Windows` 메뉴에서 `Device Browser`을 찾아 창을 띄운다.
  - `Device Browser`의 `Source` 메뉴에서 `MIDI`를 선택한다.
  - 버스 별 연결 포트(port) 번호를 확인한다.

### 10-1. MIDI (Musical Instrument Digital Interface)

- MIDI 표준 제정 (1980년 대)
- 음악을 다루는 기기들끼리 소통 목적

<img src="image10/midiconnection.png" width="600">

#### MIDI 메시지

<img src="image10/midimessage.png" width="600">


- Status Byte : `msg.data1` = `1xxxxxxx` (128\~255)
  - `NoteOff` = `1000xxxx` (128\~143)
  - `NoteOn` = `1001xxxx` (144\~159)
  - `Control` = `1011xxxx` (176\~191)  
  - `AfterTouch` = `1101xxxx` (208\~223)
  - `PitchBend` = `1110xxxx` (224\~239)
  - ...
- MIDI Number : `msg.data2` = `0xxxxxxx` (0\~127)
- Velocity : `msg.data3` = `0xxxxxxx` (0\~127)


#### Virtual MIDI Piano Keyboard 설치

- [VMPK](https://vmpk.sourceforge.io/) 내려 받아 컴퓨터에 설치한다.


#### 10-1-1. 프로그램에서 MIDI 메시지 보내 외부 키보드를 연주하기 (`MidiOut`)

- 키보드 건반을 마우스로 눌러서 소리가 나는지 확인한다.
- VMPK 메뉴에서 `Edit` > `MIDI Connections` 선택한다.
- `MIDI Setup`에서 
  - 맨 아래 `Show Advanced Connections`를 선택
  - `MIDI IN Driver`를 `CoreMIDI`로 선택
  - `Input MIDI Connection`에서 Input 연결 버스 선택

- `miniAudicle`의 `Device Browser`를 열어 VMPK에서 설정한 버스의 포트 번호 확인한다. 

다음 프로그램을 실행하여 무작위로 보내는 MIDI 메시지로 연주하여 키보드에서 소리가 나는지 확인한다.

```
MidiOut mout;
MidiMsg msg;
0 => int port;
if (!mout.open(port)) {
    <<< "Error: MIDI port did not open on port: ", port >>>;
    me.exit();
}

fun void sendOutMIDInote(int on, int note, int velocity) {
    if (on == 0) 128 => msg.data1; // 10000000 NoteOff
    else 144 => msg.data1; // 10010000 NoteOn
    note => msg.data2;
    velocity => msg.data3;
    <<< msg.data1, msg.data2, msg.data3 >>>;
    mout.send(msg);
}

int note, velocity;
while (true) {
    Math.random2(60,100) => note;
    Math.random2(30,127) => velocity;
    sendOutMIDInote(1, note, velocity);
    .5::second => now;
    sendOutMIDInote(0, note, velocity);
    .5::second => now;
}
```

#### 10-1-2. 외부 키보드에서 MIDI 메시지를 프로그램으로 보내 연주하기 (`MidiIn`)

- VMPK 메뉴바에서 `Edit` > `MIDI Connections` 선택한다.
- `MIDI Setup`에서 
  - 맨 아래 `Show Advanced Connections`를 선택
  - `MIDI OUT Driver`를 `CoreMIDI`로 변경
  - `Output MIDI Connection`에서 Output 연결 버스 선택 (Input 포트와 다른 버스 선택)
- 이제 건반을 누르면 키보드에서 소리가 나는 대신, 해당 MIDI 메시지를 밖으로 내보낸다.

- `miniAudicle`의 `Device Browser`를 열어 VMPK에서 설정한 버스의 포트 번호 확인한다. 

다음 프로그램을 실행하여 VMPK의 건반을 눌러 ChucK의 `StkInstrument` 악기 소리가 나는지  확인한다.

```
MidiIn min;
MidiMsg msg;     
1 => int port; // if port number is 1
if (!min.open(port)) {
    <<< "Error: MIDI port did not open on port: ", port >>>;
    me.exit();
}

Mandolin piano => dac; 

while (true) {
    min => now; 
    while (min.recv(msg)) {
        <<< msg.data1, msg.data2, msg.data3 >>>;
        if (msg.data1 == 144) { // noteOn (144)
            Std.mtof(msg.data2) => piano.freq;
            msg.data3 / 127.0 => piano.gain;
            1 => piano.noteOn;
        }
        else { // noteOff (128)
            1 => piano.noteOff;
        }
    }
}
```

#### 10-1-3. 쉬레드 끼리 MIDI 메시지를 주고 받기

- 프로그램의 한 쉬레드에서 다른 쉬레드에 MIDI 메시지를 전달할 수 있다.
- 메시지 보내는 프로그램과 메시지 받는 프로그램의 포트 번호를 일치시킨다.
- 메시지 받는 쉬레드를 먼저 실행시키고, 보내는 쉬레드를 실행시킨다.
- 위 프로그램을 실행하여 결과를 확인하자.

#### 10-1-4. MIDI 메시지로 로봇 악기 제어하기

<img src="image10/robot.png" width="600">

#### Yamaha Disklavier

<img src="image10/robotpiano.png" width="600">


### 10-2. OSC (Open Sound Control)

- 지휘자(sender) => 연주자(receiver)

- OSC는 컴퓨터 유무선 네트워크를 통해서 디지털 미디어 소프트웨어끼리 음악 정보를 주고 받을 수 있는 프로코콜이다. 
- MIDI 보다 앞선 기술이라 할 수 있으며 1997년에 처음 소개되었다.
- 지휘자(sender)가 연주자(receiver)에게 OSC 메시지를 보낸다.
- 응용 사례 : 랩탑 오케스트라, 모바일 오케스트라, 인터랙티브 아트 등

#### 송수신 메시지의 구조
  
- 주소(address): `/bass/play`, `/piano/key/high`
- 인수(argument): 세 종류 가능, 차례로 나열
  - `int`
  - `float`
  - `string`

#### 포드 번호 (port number)

- 1024\~65535 범위에서 임의로 선택
- 송신자, 수신자 포트 번호가 동일해야 함

#### 메시지 보내기

- 예: `/bass/play 60 0.9 "C4"`

```
OscOut oout;
1979 => int port;
oout.dest("localhost", port);
oout.start("/bass/play").add(60).add(0.9).add("C4").send();
```

다음과 같이 써도 마찬가지이다.

```
OscOut oout;
2021 => int port;
oout.dest("localhost", port);
oout.start("/bass/play");
oout.add(60)
oout.add(0.9)
oout.add("C4")
oout.send();
```

#### 메시지 받기

```
OscIn oin;
2021 => oin.port;
"/bass/play" => oin.addAddress;
OscMsg msg;
while (true) {
    oin => now;
    while (oin.recv(msg)) {
        <<< msg.address, msg.typetag >>>;
        <<< msg.getInt(0), msg.getFloat(1), msg.getString(2) >>>;
    }
}
```

#### 사례 학습

- 지휘자(sender)

```
OscOut oout;
1979 => int port;
oout.dest("localhost", port);

while (true) {
    oout.start("/chuckie/osctest");    
    Math.random2(48,80) => int note; 
    Math.random2f(0.1,1.0) => float velocity;
    "Oh, Happy day!" => string message;
    note => oout.add; 
    velocity => oout.add;
    message => oout.add;
    oout.send(); 
    second => now;
}
```


- 연주자(receiver)

```
OscIn oin;
1979 => oin.port;
oin.addAddress("/chuckie/osctest");
OscMsg msg;

Rhodey piano => dac;

while (true) {
    oin => now;
    while (oin.recv(msg) != 0) {
        msg.getInt(0) => int note;
        msg.getFloat(1) => float velocity;
        msg.getString(2) => string message;
        Std.mtof(note) => piano.freq;
        velocity => piano.gain;
        velocity => piano.noteOn;
        <<< message, note, velocity >>>;
    }
}
```



## 숙제 (마감: 11월 23일 (화) 오전 9시)

지난 주 실습 시간에 작성한 `진도 아리랑 변주곡`을 `Event` 객체를 활용하는 대신 다음 둘 중 하나의 소통 방식으로 재작성해보자.

- 한 파일에서 하나의 쉬레드를 만들도록 프로그램을 여러 파일로 분리하고, `MidiOut`과 `MidiIn`을 활용하여 쉬레드 간에 MIDI 메시지를 보내서 연주하게 한다.

- 한 파일에서 하나의 쉬레드를 만들도록 프로그램을 여러 파일로 분리하고, `OscOut`과 `OscIn`을 활용하여 쉬레드 간에 메시지를 보내서 연주하게 한다.


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

class TheEvent extends Event {
    int note;
    float velocity;
}

TheEvent e1, e2, e3;
Event e4, e5, e6;

NRev global_reverb => dac;
0.1 => global_reverb.mix;

fun void poly(StkInstrument instrument, TheEvent e, string notes[], float durs[]) {
    instrument => global_reverb;
    while (true) {
        e => now;
        for (0 => int i; i < notes.size(); i++) {
            Std.mtof(midi(notes[i])) => instrument.freq;
            e.velocity => instrument.noteOn;
            durs[i]::second / 4.5 => now;
            1 => instrument.noteOff;
        }
    }
}

fun void buk(string sample, Event e, float durs[], int n) {
    SndBuf drum => dac;
    sample => drum.read;
    drum.samples() => drum.pos;
    while (true) {
        e => now;
        <<< n , "" >>>;
        for (0 => int i; i < durs.size(); i++) {
            0 => drum.pos;
            durs[i]::second / 4.5 => now;
        }
    }
}

spork ~ poly(new StifKarp, e1, ["B3","B3","E4","E4"], [3.0,2.0,1.0,3.0]);
spork ~ poly(new StifKarp, e1, ["B3","E4","B3","E4","E4"], [2.0,1.0,2.0,1.0,3.0]);
spork ~ poly(new PercFlut, e2, ["B4","G4","G4","F#4","E4"], [1.0,2.0,1.0,2.0,3.0]);
spork ~ poly(new PercFlut, e3, ["G4","G4"], [3.0,6.0]);

spork ~ buk(me.dir()+"audio/snare_02.wav", e4, [1.0,2.0,1.0,3.0,2.0], 1);
spork ~ buk(me.dir()+"audio/hihat_02.wav", e5, [3.0,2.0,1.0,1.0,2.0], 2);
spork ~ buk(me.dir()+"audio/kick_02.wav", e6, [6.0,3.0], 3);

int dice;
0.5 => e1.velocity;
0.8 => e2.velocity;
0.8 => e3.velocity;
while (true) {
    Math.random2(1,6) => dice;
    if (dice == 1) e2.signal();
    else if (dice == 6) e3.signal();
    else e1.signal();
    if (dice <= 3) e5.signal();
    else if (dice == 6) e6.signal();
    else e4.signal();
    2::second => now;
}
```

