```
(c)도경구 version 1.0 (2022/11/06)
```

## 10. MIDI, OSC

- 라이브 연주를 위한 도구
- 프로그램으로 외부 MIDI 기기 실시간 제어하기
- OSC 프로토콜로 프로그램끼리 우무선 네트워크로 소통하기


### 10-1. MIDI (Musical Instrument Digital Interface)

- MIDI 표준 제정 (1980년 대)
- 음악을 다루는 기기들끼리 소통 목적

<img src="https://i.imgur.com/dFdFxrb.png" width="600">

#### MIDI 메시지

MIDI 메시지는 총 3 바이트(byte)로 구성

<img src="https://i.imgur.com/62EEQK7.png" width="600">

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

#### 가상 MIDI 포트 만들기

- 가상 MIDI 포트 만들기
  - Mac OS
    - `Applications/Utilities`(응용 프로그램/유틸리티)에서 `Audio Midi Setup`실행
    - 메뉴바에서 `Window` > `Show MIDI Studio` 선택
    - `IAC 드라이버` 아이콘 더블 클릭
    - `Device is online` 체크박스 선택
  - Windows
    - [loopMIDI(virtualMIDI)](https://www.tobias-erichsen.de/software/loopmidi.html) 다운 받아 설치
    - 좌하단 `+` 버튼 클릭
  - 주의: miniAudicle이 한글을 처리하지 못하므로 이름은 모두 영어로 붙일 것

- miniAudicle에서 가상 MIDI 포트 번호 확인
  - miniAudicle의  `Windows` 메뉴에서 `Device Browser`을 찾아 창을 띄운다.
  - `Device Browser`의 `Source` 메뉴에서 `MIDI`를 선택한다.
  - 버스 별 연결 포트(port) 번호를 확인한다.


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
0 => int port; // 번호는 상황에 따라 달라서 확인 필요
if (!mout.open(port)) {
    <<< "Error: MIDI port did not open on port: ", port >>>;
    me.exit();
}

fun void sendOutMIDInote(int on, int note, int velocity) {
    if (on == 0)
        128 => msg.data1; // 10000000 NoteOff
    else // on == 1
        144 => msg.data1; // 10010000 NoteOn
    note => msg.data2;
    velocity => msg.data3;
    <<< msg.data1, msg.data2, msg.data3 >>>;
    mout.send(msg);
}

int note, volume;
while (true) {
    Math.random2(60,100) => note;
    Math.random2(30,127) => volume;
    sendOutMIDInote(1, note, volume);
    second => now;
    sendOutMIDInote(0, note, volume);
    second => now;
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
1 => int port; // 번호는 상황에 따라 달라서 확인 필요
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

<img src="https://i.imgur.com/fLniaiE.png" width="600">

#### Yamaha Disklavier

<img src="https://i.imgur.com/nWrzCad.png" width="600">


### 10-2. OSC (Open Sound Control)

- 지휘자(sender) => 연주자(receiver)

- OSC는 컴퓨터 유무선 네트워크를 통해서 디지털 미디어 소프트웨어끼리 음악 정보를 주고 받을 수 있는 프로코콜이다.
- MIDI 보다 앞선 기술이라 할 수 있으며 1997년에 처음 소개되었다.
- 지휘자가 연주자에게 OSC 메시지를 보낸다.
- 응용 사례 : 랩탑 오케스트라, 모바일 오케스트라, 인터랙티브 아트, 등

#### 송수신 메시지의 구조

- 주소(address): `/bass/play`, `/piano/key/high`
- 인수(argument): 세 종류 가능, 차례로 나열
  - `int`
  - `float`
  - `string`

#### 포드 번호 (port number)

- `1024`\~`65535` 범위에서 임의로 선택
- 송신자, 수신자 포트 번호가 동일해야 함

#### 메시지 보내기

- 예: `/bass/play 60 0.9 "C4"`

```
OscOut oout;
2022 => int port;
oout.dest("localhost", port);
oout.start("/bass/play").add(60).add(0.9).add("C4").send();
```

다음과 같이 써도 마찬가지이다.

```
OscOut oout;
2022 => int port;
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
2022 => oin.port;
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
