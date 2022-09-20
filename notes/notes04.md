```
(c)도경구 version 1.0 (2022/09/20)
```

## 4. 배열

### 4-1. 배열의 선언과 지정

#### 배열의 표현

배열(array)은 같은 타입의 값들을 나란히 이어붙여 나열한 데이터 구조이다. 예를 들어 "학교종" 노래의 첫 두 마디의 MIDI 음을 ChucK의 배열로 표현하면 다음과 같다.

```
[67, 67, 69, 69, 67, 67, 64]
```

음을 차례로 쉼표로 구분하여 나열하고, 전체를 대괄호로 둘러싼다. 이 배열을 프린트 해보면

```
<<< [67, 67, 69, 69, 67, 67, 64] >>>;
```

다음과 같이 실행창에 나타난다.

```
0x600003a6df80 :(int[])
```

배열을 프린트해보니 정체 불명의 값이 나타난다. 무엇일까? 만든 배열이 저장되어 있는 메모리 주소를 프린트 해준 것이다. 옆에 이어서 나타난 `int[]`는 그 주소에 저장되어 있는 배열의 타입을 나타내고, 읽을 때는 `int 배열`이라고 읽으면 되겠다.  이 배열을 그림으로 요약하여 표현하면 다음과 같다.

<img src="https://i.imgur.com/3BXZ5aq.png" width="300">

원소 값들을 메모리에 차례로 나란히 저장해두고 정수 인덱스가 0부터 6까지 차례로 붙어있다.

#### 배열의 선언

배열에 나란히 저장되어 있는 원소에 접근하려면, 변수를 선언하여 이름을 붙여두고 인덱스를 활용하여 개별 접근해야 한다.
배열 변수는 다음과 같은 형식으로 선언한다.

```
int notes[7];
```

배열 원소의 타입을 앞에 명시하고, 이어서 선언할 배열 변수의 이름을 적고, 대괄호 안에 배열 규모를 나타내는 자연수를 적는다. 위와 같이 선언하면 아래 그림과 같이 정수 7개를 나란히 저장할 수 있는 배열이 만들어진다. 배열의 내부는 선언한 타입의 기본값으로 채워진다. `int` 타입은 `0`, `float` 타입은 `0.0`, `string` 타입은 `""`이 기본값이다.

<img src="https://i.imgur.com/ieJnFhe.png" width="300">

#### 배열의 참조

이 배열 원소 값은 다음과 같은 형식으로 인덱스를 명시하여 읽어올 수 있다.

```
for (0 => int i; i < 7; i++)
    <<< "notes[", i , "] =", notes[i] >>>;
```

실행하면 다음과 같이 실행창에서 확인해준다.

```
notes[ 0 ] = 0
notes[ 1 ] = 0
notes[ 2 ] = 0
notes[ 3 ] = 0
notes[ 4 ] = 0
notes[ 5 ] = 0
notes[ 6 ] = 0
```

#### 배열의 수정

배열의 원소 값은 개별적으로 다음과 같이 수정할 수 있다.

```
67 => notes[4];
```

수정한 다음, 위의 `for` 루프를 다시 실행해보면 다음과 같이 수정되었음을 확인할 수 있다.

```
notes[ 0 ] = 0
notes[ 1 ] = 0
notes[ 2 ] = 0
notes[ 3 ] = 0
notes[ 4 ] = 67
notes[ 5 ] = 0
notes[ 6 ] = 0
```

#### 배열의 지정

배열은 다음과 같은 형식으로 한꺼번에 지정할 수 있다.

```
[67, 67, 69, 69, 67, 67, 64] @=> notes;
```

배열을 한꺼번에 지정할 때는 `@` 기호를 반드시 붙여야 함을 주의하자. 위의 `for` 루프로 또 다시 읽어보면 다음과 같이 수정되었음을 확인할 수 있다.

```
notes[ 0 ] = 67
notes[ 1 ] = 67
notes[ 2 ] = 69
notes[ 3 ] = 69
notes[ 4 ] = 67
notes[ 5 ] = 67
notes[ 6 ] = 64
```

다음과 같은 형식으로 배열의 선언과 지정을 한꺼번에 할 수도 있다.

```
[67, 67, 69, 69, 67, 67, 64] @=> int notes[];
```

이 경우 만든 배열을 보면 크기를 알 수 있으므로 배열의 크기를 굳이 명시하지 않는다.
(명시하는 경우, 오류가 발생하면서 비정상 종료하는 현상이 발생한다. 왜인지 규명이 필요하다.)

#### 배열 참조 오류

다음과 같이 배열의 인덱스 범위 바깥의 인덱스 값을 사용하면 `ArrayOutofBounds` 실행 오류가 발생하므로 주의해야 한다.

```
<<< notes[7] >>>;
```

#### 배열 보조 함수

##### 1. 배열 길이 계산 함수 : `int size()`

배열 `notes`의 길이는 다음과 같은 형식으로 알아낼 수 있다.

```
<<< "The length of notes =", notes.size() >>>;
```

실행하여 확인해보자.

##### 2. 배열 길이 조정 함수 : `int size(int n)`

이 함수를 활용하면 배열의 길이를 줄이거나 늘릴 수 있다.

다음과 같이 하면 배열의 앞부분을 원하는 만큼만 추릴 수 있고,

```
notes.size(4);
<<< "After notes.size(4)" >>>;
for (0 => int i; i < notes.size(); i++)
    <<< "notes[", i , "] =", notes[i] >>>;
```

다음과 같이 하면 배열의 길이를 원하는 만큼 늘릴 수 있다.

```
notes.size(12);
<<< "After notes.size(12)" >>>;
for (0 => int i; i < notes.size(); i++)
    <<< "notes[", i , "] =", notes[i] >>>;
```

추가된 뒷부분은 모두 `0`으로 설정된다. 실행하여 확인해보자.

##### 3. 배열 뒤에서 원소 하나 제거하기 : `void popBack()`

```
notes.popBack();
<<< "After notes.popBack()" >>>;
for (0 => int i; i < notes.size(); i++)
    <<< "notes[", i , "] =", notes[i] >>>;
```

실행하여 확인해보자.

##### 4. 배열 뒤에 원소 하나 추가하기 : `<<`

```
notes << 62;
<<< "After notes << 62" >>>;
for (0 => int i; i < notes.size(); i++)
    <<< "notes[", i , "] =", notes[i] >>>;
notes << 60;
<<< "After notes << 60" >>>;
for (0 => int i; i < notes.size(); i++)
    <<< "notes[", i , "] =", notes[i] >>>;
```

실행하여 확인해보자.

아래와 같이 여러 값을 한 줄에 이어붙일 수도 있다.

```
notes << 62 << 60;
<<< "After notes << 62  << 60" >>>;
for (0 => int i; i < notes.size(); i++)
    <<< "notes[", i , "] =", notes[i] >>>;
```

##### 5. 배열 지우기 : `void clear()`

```
notes.clear();
<<< "After notes.clear()" >>>;
<<< "The length of notes =", notes.size() >>>;
```

실행하여 확인해보자.


### 4-2. 배열 활용 사례 : 학교종 (솔로)

<img src="https://i.imgur.com/Xp2yvQG.png" width="600">

이 악보대로 연주하는 프로그램을 만들어보자. 우선 악보에서 음표의 계명과 박자 정보를 분리하여 각각 따로 배열로 만든 다음, 이를 연주하는 프로그램을 만든다.


#### 계명

- 계명은 MIDI 번호로 표현한다.
- 쉼표는 MIDI 번호로 할당되어 있지 않은 `-1`로 표현한다.
- 음표별 계명과 쉼표를 정수로 나열하여 배열 `melody`를 다음과 같이 만든다.

```
[ // melody
67,67,69,69, 67,67,64, 67,67,64,64, 62,-1,
67,67,69,69, 67,67,64, 67,64,62,64, 60,-1
] @=> int melody[];
```

<img src="https://i.imgur.com/AR0COxu.png" width="600">

#### 박자

박자는 `dur` 타입의 값으로 표현한다.

```
0.5::second => dur beat;
beat / 4 => dur rest;
beat - rest => dur qn; // quarter note
beat * 2 - rest => dur hn; // half note
beat * 3 - rest => dur dhn; // dotted half note
```
위 프로그램의 실행의미를 살펴보면 다음과 같다.
- 위와 같이 기본 템포 `beat` 값을 먼저 설정하고,
- 그 값을 기준으로 필요한 음표별로 박자를 정하여 이름을 부여한다.
- 위 악보에는 1박자(quarter note), 2박자(half note), 1박자반(dotted half note)이 있으므로, 각각 `qn`, `hn`, `dhn`으로 이름을 정한다.
- 악보에 이어지는 음표가 많으므로 음 사이에 약간의 소리 공백을 둘 필요가 있어서, 공백의 길이를 정하여 변수 `rest`에 기억한다.
- 그리고 음표마다 뒷부분에 그만큼의 소리 공백을 두기 위해서, 음표의 길이를 그만큼 미리 빼둔다.
- 음표별로 박자를 차례로 기술한 배열 `durs`를 다음과 같이 따로 만든다.

```
[ // time
qn,qn,qn,qn, qn,qn,hn, qn,qn,qn,qn, dhn,qn,
qn,qn,qn,qn, qn,qn,hn, qn,qn,qn,qn, dhn,qn
] @=> dur durs[];
```

- `melody`와 `durs` 배열의 원소 값은 각 음표별 계명과 박자 정보이므로, 두 배열의 길이는 반드시 같아야 한다.

#### MIDI음 번호와 소리크기 설정 프로시저 `setMIDInote` 만들기

다음 함수는 진동기 `osc`와 MIDI음 번호 `note`, 소리크기 `vol`을 받아서, `osc`의 주파수와 소리크기을 설정해주는 프로시저 이다. `note` 값이 MIDI 음 범위를 벗어나면 소리를 꺼서 소리가 나지 않게 한다. 쉼표 음표를 처리하는 효과적인 방법이다.  

```
fun void setMIDInote(Osc osc, int note, float vol) {
    if (0 <= note <= 127) {
        Std.mtof(note) => osc.freq;
        vol => osc.gain;
    } else
        0.0 => osc.gain;
}
```

이 함수를 활용하면 진동기의 계명과 소리크기를 편리하게 변경할 수 있다.


#### 연주하기

아래 프로그램을 추가하고 실행하여 연주를 들어보자.

```
SinOsc s => dac;
for (0 => int i; i < melody.size(); i++) {
    setMIDInote(s, melody[i], 0.6);
    durs[i] => now;
    0 => s.gain;
    rest => now;
}
```
이 코드의 실행의미를 살펴보면 다음과 같다.
- 진동기를 하나 설치하고 이름은 `s`라 한다.
- `for` 루프를 활용하여 악보를 음표별로 차례로 박자에 맞추어 연주한다.
- 소리를 낼때마다 진동기의 주파수와 소리길이를 `melody`와 `durs` 배열에 기록되어 있는 해당 음표의 값대로 설정한다. 소리크기는 중간 정도인 `0.6`으로 한다.
- 기획한 대로 음표마다 뒷부분에 소리를 끄고 `rest` 만큼 시간을 보낸다.


### 4-3. [실습#1] For Elise

다음 악보는 베토벤의 `엘리제를 위하여`의 도입 부분이다.
이를 연주하는 프로그램을 MIDI와 배열을 사용하여 작성해보자.

<img src="https://i.imgur.com/Gsed2sv.png" width="800">

악보와 템포는 다음 코드를 활용한다.

```
// tempo
0.3::second => dur beat;
beat => dur sn; // sixteenth (1/16)
beat * 2 => dur en; // eighth (1/8)

// For Elise by Beethoven
[
76, 75, 76, 75, 76, 71, 74, 72, 69, -1,
60, 64, 69, 71, -1, 64, 68, 71, 72, -1, 64,
76, 75, 76, 75, 76, 71, 74, 72, 69, -1,
60, 64, 69, 71, -1, 64, 72, 71, 69, -1
] @=> int melody[];
[
sn, sn, sn, sn, sn, sn, sn, sn, en, sn,
sn, sn, sn, en, sn, sn, sn, sn, en, sn, sn,
sn, sn, sn, sn, sn, sn, sn, sn, en, sn,
sn, sn, sn, en, sn, sn, sn, sn, en, en
] @=> dur durs[];
```

악보에 표시된 대로 두 번 반복해야 한다.

그리고 악보에 연속 이어지는 음이 없으므로,
음의 끝 부분의 소리를 죽이지 말고 박자 전체를 소리나게 한다.

### 4-4. [실습#2] Theme from Beverly Hill Cops

Beverly Hill Cops 영화 주제곡 도입 부분을 `TriOsc`로 연주하는 프로그램을 작성하자.
악보와 템포는 다음 코드를 활용한다.

```
// tempo
0.25::second => dur beat; // basic duration
beat => dur qn; // quarter (1/4) note sound
beat * 2 => dur hn; // half (1/2) note sound
beat / 2 => dur en; // eighth (1/8) note sound
beat / 5 => dur rest; // duration of no sound after each note

// Harold Faltermeyer's Theme from the film Beverly Hills Cop (1984)
[
65, -1, 68, -1, 65, 65, 70, 65, 63,
65, -1, 72, -1, 65, 65, 73, 72, 68,
65, 72, 77, 65, 63, 63, 60, 67, 65] @=> int melody[];
[
qn, qn, qn, en, qn, en, qn, qn, qn,
qn, qn, qn, en, qn, en, qn, qn, qn,
qn, qn, qn, en, qn, en, qn, qn, hn] @=> dur durs[];
```

MIDI 음 배열의 `-1`은 쉼표를 나타낸다.
같은 음이 이어지는 경우에만 두 음이 끊어져 들리도록 `rest` 변수를 활용하고, 다른 음은 음이 이어져 들리도록 한다.

### 4-5. 배열 활용 사례 : 학교종 (화음 추가)

<img src="https://i.imgur.com/Xp2yvQG.png" width="600">

이번에는 학교종 멜로디에 코드(chord)를 화음으로 추가하여 연주해보자.

#### 코드 추가

악보에는 코드가 세 종류, `C`, `F`, `G7`,가 있다. 각 코드에 해당하는 MIDI 음 4개로 구성한 배열을 아래와 같이 만들 수 있다.

```
[48,51,55,60] @=> int C[];
[48,53,57,60] @=> int F[];
[50,53,55,59] @=> int G7[];
```

이 코드를 음표마다 붙여서 멜로디와 동일 크기의 배열로 다음과 같이 만들 수 있다.

```
[ // chords
C,C,F,F, C,C,C, C,C,C,C,   G7,G7,
C,C,F,F, C,C,C, C,C,G7,G7, C,C
] @=> int chords[][];
```

#### 화음용 진동기 배열 만들기

반주 코드는 네 음을 동시에 내야하기 때문에 진동기 4개가 추가로 필요하다. 4개의 다른 음을 함께 내므로, 4개의 진동기를 새로 연결하고 모두 묶어서 다음과 같이 하나의 배열로 관리하면 편리하다.

```
SinOsc s1 => dac;
SinOsc s2 => dac;
SinOsc s3 => dac;
SinOsc s4 => dac;
[s1,s2,s3,s4] @=> SinOsc quartet[];
```

#### 코드의 4 화음을 4개의 진동기에 각각 설정하는 함수 만들기

각 화음 소리를 낼 때마다 4개의 음을 각각 소리크기와 함께 설정해주는데, 다음과 같이 함수로 만들어 쓰면 편리하다.  

```
fun void setChord(Osc osc[], int chord[], float vol) {
    setMIDInote(osc[0], chord[0], vol/4);
    setMIDInote(osc[1], chord[1], vol/4);
    setMIDInote(osc[2], chord[2], vol/4);
    setMIDInote(osc[3], chord[3], vol/4);
}
```

이 함수는 진동기 배열과 코드의 배열을 받아서 코드의 각 음을 각기 다른 진동기에 설정한다. 셋째 인수는 소리크기 값인데 4등분하여 각 진동기에 배분한다.

#### 화음과 함께 멜로디 연주하기

```
for (0 => int i; i < melody.size(); i++) {
    setMIDInote(s, melody[i], 0.6);
    setChord(quartet, chords[i], 0.6);
    durs[i] => now;
    0 => s.gain;
    rest => now;
}  
```

이 코드의 실행의미를 살펴보면 다음과 같다.
- `for` 루프는 악보의 멜로디 음표를 차례로 박자에 맞추어 연주한다.
- 멜로디 소리 박자에 맞추어, 화음 소리도 같이 나도록 `setChord` 함수를 호출하여  진동기 배열 `quartet`을 `chords[i]` 배열에 기록되어 있는 해당 코드로 설정한다. 화음 소리크기는 멜로디와 같이 `0.6`으로 한다.
- 기획한 대로 멜로디는 음표마다 뒷부분에 소리를 끄고 `rest` 만큼 시간을 보낸다. 멜로디 소리가 나지 않는 이 기간 동안도, 다른 진동기는 소리를 끄지 않았으므로 화음 소리는 계속 들린다.


### 4-6. 배열 활용 사례 : 학교종 (가사 추가)

#### 가사 만들기

음을 연주하면서 가사를 콘솔 모니터에 프린트하여 보여줄 수 있다. 소리를 내면서 해당가사를 바로 프린트하기 위해서, 음별 가사를 동일 크기의 배열에 아래와 같이 준비한다. 2절까지 있으므로 악보를 두 번 반복하도록 하고, 처음에는 1절을, 다음에는 2절을 프린트하도록 한다.

```
// lyrics 1
[
"Hak","Gyo","Jong","I", "Ddaeng","Ddaeng","Ddaeng", "Eo","Seo","Mo","I", "Ja","",
"Seon","Saeng","Nim","I", "U","Ri","Reul", "Gi","Da","Ri","Sin", "Da",""
] @=> string lyrics1[];

[ // lyrics 2
"Hak","Gyo","Jong","I", "Ddaeng","Ddaeng","Ddaeng", "Eo","Seo","Mo","I", "Ja","",
"Sa","I","Jot","Ge", "O","Neul","Do", "Gong","Bu","Jal","Ha", "Ja",""
] @=> string lyrics2[];
```

#### 가사 보여주면서 연주하기

화음과 가사를 추가하여 연주를 하게하는 프로그램은 다음과 같다.

```
for (1 => int n; n <= 2; n++)
    for (0 => int i; i < melody.size(); i++) {
        setMIDInote(s, melody[i], 0.6);
        setChord(quartet, chords[i], 0.6);
        if (n == 1)
            <<< lyrics1[i] >>>;
        else
            <<< lyrics2[i] >>>;
        durs[i] => now;
        0 => s.gain;
        rest => now;
    }
```

이 코드의 실행의미를 살펴보면 다음과 같다.
- 악보를 두 번 반복하도록 `for` 루프로 바깥을 감싼다.
- 안쪽 `for` 루프는 악보의 음표를 차례로 박자에 맞추어 연주한다.
- 음표 하나 소리낼 때마다, 해당 가사를 콘솔 모니터에 프린트한다. 바깥 `for` 루프의 반복변수 `n`의 값이 `1`일때는 1절 가사를 `2`일때는 2절 가사를 프린트한다.


#### 추가로 코드 다듬기

위 코드를 실행하면 콘솔 모니터에 가사를 보여주면서 다음과 같이 타입을 같이 보여준다.

```
"Hak" : (string)
```

프린트할 대상 식이 하나만 있는 경우, 식의 계산 결과를 타입과 같이 보여주기 때문이다.
그런데 식을 쉼표로 구분하여 두 개 이상 나열하여 프린트하면 타입 정보 없이 값만 보여준다.
예를 들어 다음과 같이 두 개 이상의 문자열을 나열하여 프린트하면,

```
<<< "Hak", "Gyo" >>>;
```

콘솔 모니터에는 다음과 같이 나타난다.

```
Hak Gyo
```

그러면 위 프로그램에서 가사만 나타나도록 할 방법은 없을까?

가사를 프린트하는 부분을 다음과 같이 고치면 된다.

```
        if (n == 1)
            <<< lyrics1[i], "" >>>;
        else
            <<< lyrics2[i], "" >>>;
```

### 4-7. [실습#3] 햇볕은 쨍쨍 (멜로디 + 화음 반주)

다음 악보 멜로디에 화음을 추가하여 같이 연주하는 프로그램을 작성하자.

<img src="https://i.imgur.com/jRArGzp.png" width="600">

악보의 음표 배열은 다음과 같다.

```
// melody for sunshine
[
60,64,67,    67,67,       64,65,67,64, 60,60,
72,71,72,69, 67,69,67,64, 72,71,72,69, 67,69,67,64,
69,69,67,67, 64,64,67,67, 62,60,62,64, 60,60
] @=> int melody[];

// chord for sunshine
[
C,C,C,    C,C,      C,C,C,C,      C,C,
F,F,F,F,  C,C,C,C,  F,F,F,F,      C,C,C,C,
F,F,C,C,  C,C,C,C,  G7,G7,G7,G7,  C,C
] @=> int chords[][];

// tempo for sunshine
[
dqn,en,hn,    hn,hn,       qn,qn,qn,qn,  hn,hn,
qn,qn,qn,qn,  qn,qn,qn,qn, qn,qn,qn,qn,  qn,qn,qn,qn,
qn,qn,qn,qn,  qn,qn,qn,qn, dqn,en,qn,qn, hn,hn
] @=> dur durs[];
```

### 4-8. [숙제] 반달 (멜로디 + 반주)

아래 악보를 두번 이어서 연주하는 프로그램을 작성하자.

1. 첫 연주에서는 악보에 표시된 대로 멜로디와 반주를 화음으로 연주한다.

2. 둘째 연주에서는 코드를 한꺼번에 소리내지 않고, 코드에서 서로 다른 3음을 선택하여 한박자에 한 음씩 차례로 반주를 하도록 프로그램을 작성하자. 6/8 박자이므로 8분음표가 한 박자이다. 다시 말해, 한 마디에 3음 연주를 두 번 반복한다.

<img src="https://i.imgur.com/K0f0bUI.png" width="600">
