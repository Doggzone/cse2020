```
(c)도경구 version 0.21 (2021/09/21)
```

### 3. 함수 요약

### 3-1. 함수의 선언과 호출

ChucK에서 여러번 재사용하고 싶은 코드에 이름을 붙여두고 불러 쓰도록 하는 구조를 <strong>함수(function)</strong>라고 한다. 이름을 붙이는 구조를 <strong>함수 선언(function declaration)</strong>이라고 하고, 이름을 부르는 구조를 <strong>함수 호출(function call)</strong>이라고 한다. 예를 들어, MIDI 음을 담는 변수를 다음과 같이 선언하고 초기값을 지정했다고 하자.

```
60 => int mynote;
<<< mynote >>>;
```

그리고 나서 한 옥타브 올린 음으로 이 변수의 값을 수정하고 싶으면 다음과 같이 한다.

```
12 +=> mynote;
<<< mynote >>>;
```

이어서 세 옥타브를 내리고 싶은 경우에는 다음과 같이 세 옥타브에 해당하는 36을 빼야 하고

```
36 -=> mynote;
<<< mynote >>>;
```

다시 두 옥타브를 올리고 싶은 경우에는 다음과 같이 두 옥타브에 해당하는 24를 더해야 할 것이다.

```
24 +=> mynote;
```

옥타브 단위로 MIDI 음을 조정하는 경우가 많으리라 예상되므로 옥타브 단위로 음을 올리거나 내릴 수 있는 기능을 갖춘 함수를 다음과 같이 선언해두고 호출해 쓰면 코드가 훨씬 간결하고 읽기 쉬워진다.

```
fun int upOctave(int note, int step) {
    return note + (step * 12);
}

60 => int mynote;
<<< mynote >>>;
upOctave(mynote,1) => mynote;
<<< mynote >>>;
upOctave(mynote,-3) => mynote;
<<< mynote >>>;
upOctave(mynote,2) => mynote;
<<< mynote >>>;
```

함수 선언은 `fun`이라는 키워드로 시작한다. 이 함수의 이름은 `upOctave`라고 지었다. 이어서 괄호(`()`) 안에 쉼표를 가운데 두고 나열한 것들을 <strong>형식 파라미터(formal parameter)</strong> 또는 그냥 <strong>파라미터(parameter)</strong> 라고 한다. 필요없는 경우에는 비워두어도 되고, 필요한만큼 몇개든지 나열 가능하다. 각 파라미터는 변수 선언과 마찬가지로 타입과 변수를 빈칸을 사이에 두고 적는다. 이 예의 경우, 두 파라미터 모두 `int` 타입이며 변수 이름은 각각 `note`와 `step` 이다. `note`는 MIDI 음을 나타내며, `step`은 조정할 옥타브 단위를 나타내도록 이름을 지었다. `step` 변수 값이 양수이면 그만큼 옥타브를 올리고, 음수이면 그만큼 옥타브를 내린다. `fun` 키워드 바로 뒤에 함수를 호출하면 리턴해줄(돌려줄) 값의 타입을 기술한다. 위 함수의 경우 `int` 타입의 값을 리턴한다. 중괄호(`{}`)로 둘러싸인 부분에는 코드가 들어가는데 함수의 몸체(body)라고 한다. 위 함수의 경우 코드가 단 한 문장인데, 리턴문이다. 리턴문은 `return` 이라는 키워드로 시작하며, 이어서 식을 기술한다. 함수를 호출하면 이 식을 계산한 결과를 리턴 값으로 돌려준다.

함수 호출은 호출할 함수 이름에 이어서 괄호를 사이에 두고 식을 나열한다. 이를 <strong>실제 파라미터(actual parameter)</strong> 또는 <strong>인수(argument)</strong> 라고 한다. 인수는 반드시 해당 함수의 형식 파라미터와 개수와 타입이 일치해야 한다. 함수를 호출하면 이 인수들을 하나씩 차례로 계산하여 그 결과값이 형식 파라미터 변수에 전달되어 지정된다. 그리고 나서 함수의 몸체를 실행한다. 몸체 실행 중에 리턴문을 만나면 그 식의 계산 결과값을 리턴한다. 위 함수 호출의 경우, 인수인 `mynote`의 값과 이어서 언급한 정수 값이 각각 파라미터 변수 `note`와 `step`에 지정되고, 이어서 `note + (step * 12)` 식을 계산한 결과값을 리턴해준다.





#### 3-2. 프로시저 함수

앞 장에서 공부한 무한 루프 (무한 시간 진행) 코드를 다시 살펴보자.

```
SinOsc s => dac;
220 => int pitch => s.freq;
0.6 => float volume => s.gain;
0.0 => float off;
0.5::second => dur beat;
// 1. the original pitch
<<< "Pitch =", s.freq(), ", Volume =", s.gain() >>>;
beat * 4 / 5  => now;
off => s.gain;
beat / 5 => now;
while (true) {
    // 2. double the pitch
    pitch * 2 => s.freq;
    volume / 2 => s.gain;
    <<< "Pitch =", s.freq(), ", Volume =", s.gain() >>>;
    beat * 4 / 5 => now;
    off => s.gain;
    beat / 5 => now;
    // 2+. 1.5 times the pitch or the original randomly
    Math.random2(0,1) => int choice;
    if (choice == 1) {
        pitch * 1.5 => s.freq;
        volume / 1.5 => s.gain;
        <<< "Pitch =", s.freq(), ", Volume =", s.gain() >>>;
        beat * 4 / 5 => now;
        off => s.gain;
        beat / 5 => now;
    }
    else {
        pitch => s.freq;
        volume => s.gain;
        <<< "Pitch =", s.freq(), ", Volume =", s.gain() >>>;
        beat * 4 / 5 => now;
        off => s.gain;
        beat / 5 => now;
    }
    // 3. return to the original
    pitch => s.freq;
    volume => s.gain;
    <<< "Pitch =", s.freq(), ", Volume =", s.gain() >>>;
    beat * 4 / 5 => now;
    off => s.gain;
    beat / 5 => now;
}
```

이 코드를 잘 살펴보면 다음과 유사한 코드블록 패턴이 여러번 반복된다.

```
pitch => s.freq;
volume => s.gain;
<<< "Pitch =", s.freq(), ", Volume =", s.gain() >>>;
beat * 4 / 5 => now;
off => s.gain;
beat / 5 => now;
```

이런 패턴의 코드블록을 여러 번 쓰므로 함수로 만들어 쓰면 좋다. 이 코드블록 패턴에서 어떤 부분이 변하는지 찾아보자. 바로 눈의 띄는 것은 소리 내기 전에 세팅하는 주파수와 소리크기의 값이다. 이 둘을 파라미터로 정하고 다음과 같이 함수를 선언할 수 있다.

```
fun void makeSound(float pit, float vol) {
    pit => s.freq;
    vol => s.gain;
    <<< "Pitch =", s.freq(), ", Volume =", s.gain() >>>;
    beat * 4 / 5 => now;
    off => s.gain;
    beat / 5 => now;
}
```

이 함수는 라턴문이 없다. 따라서 리턴하는 값의 타입은 아무것도 없음을 나타내는 `void`로 명시한다. 이와 같이 리턴하는 값이 없는 함수를 <strong>프로시저(procedure)</strong> 라고 따로 구별하여 부른다.

일단 이 프로시저를 정의했으니, 다음 코드블록을

```
pitch => s.freq;
volume => s.gain;
<<< "Pitch =", s.freq(), ", Volume =", s.gain() >>>;
beat * 4 / 5 => now;
off => s.gain;
beat / 5 => now;
```
다음과 같은 프로시저 호출로 대체할 수 있다.
```
makeSound(pitch, volume);
```

이 함수를 호출하도록 하여 프로그램 전체를 재작성하면 다음과 같다.

```
SinOsc s => dac;
220 => int pitch;
0.6 => float volume;
0.0 => float off;
0.5::second => dur beat;
// 1. the original pitch
makeSound(pitch, volume);
while (true) {
    // 2. double the pitch
    makeSound(pitch * 2, volume / 2);
    // 2+. 1.5 times the pitch or the original randomly
    Math.random2(0,1) => int choice;
    if (choice == 1) {
        makeSound(pitch * 1.5, volume / 1.5);
    }
    else {
        makeSound(pitch, volume);
    }
    // 3. return to the original
    makeSound(pitch, volume);
}
```

프로그램에서 중복을 제거하여 줄수가 많이 줄었다. 아울러 프로그램의 의미도 한 눈에 들어올만큼 훨씬 명확해졌다. 이 시점에서는 다음과 같이 주석을 모두 없애도 가독성에 크게 차이가 없다.

```
SinOsc s => dac;
220 => int pitch;
0.6 => float volume;
0.0 => float off;
0.5::second => dur beat;
makeSound(pitch, volume);
while (true) {
    makeSound(pitch * 2, volume / 2);
    Math.random2(0,1) => int choice;
    if (choice == 1) {
        makeSound(pitch * 1.5, volume / 1.5);
    }
    else {
        makeSound(pitch, volume);
    }
    makeSound(pitch, volume);
}
```

그런데 이 프로그램을 잘 살펴보면, `s`와 `beat` 변수는 이 프로그램에서는 값이 변하지 않았지만 다른 진동기를 사용할 수도 있고 실행중에 소리 내는 기간을 바꿀 수도 있다. 따라서 프로시저 함수의 파라미터로 추가해야 프로시저를 훨씬 더 유연하게 사용할 수 있다. 이 두 파라미터를 추가하여 프로시저를 다시 정의하면 다음과 같다.

```
fun void makeSound(Osc osc, float pit, float vol, dur len) {
    pit => osc.freq;
    vol => osc.gain;
    <<< "Pitch =", osc.freq(), ", Volume =", osc.gain() >>>;
    len * 4 / 5 => now;
    0 => osc.gain;
    len / 5 => now;
}
```

여기서 `Osc`는 여러 진동기 `SinOsc`, `SqrOsc`, `TriOsc`, `SawOsc`를 모두 대표하는 타입의 이름이다. 따라서 어떤 진동기를 인수로 전달해도 문제없이 작동한다. 이제 이 프로시저 함수는 진동기, 주파수, 소리크기, 시간이 주어지면 소리를 내준다. 이 프로시저를 활용하여 위 코드를 다음과 같이 다시 작성할 수 있다. 


```
SinOsc s => dac;
220 => int pitch;
0.6 => float volume;
0.5::second => dur beat;
makeSound(s, pitch, volume, beat);
while (true) {
    makeSound(s, pitch * 2, volume / 2, beat);
    Math.random2(0,1) => int choice;
    if (choice == 1) {
        makeSound(s, pitch * 1.5, volume / 1.5, beat);
    }
    else {
        makeSound(s, pitch, volume, beat);
    }
    makeSound(s, pitch, volume, beat);
}
```

(off 변수 제거한 이유 설명)
함수를 잘 활용하여 함수를 재작성해보니 코드가 훨씬 깔끔하고 가독성이 훨씬 좋아졌다. 이제 이 프로그램을 앞 장에서 공부한 다음 두 코드가 함수를 활용하여 재작성 해보았다. 코드를 관찰하여 어떤 점이 좋아졌는지 효과를 스스로 판단해보자.

##### 주파수는 2배씩 늘리고, 소리크기는 반씩 줄이기

```
SinOsc s => dac;
220 => int pitch;
0.6 => float volume;
0.5::second => dur beat;
makeSound(s, pitch, volume, beat);
while (true) {
    makeSound(s, pitch * 2, volume / 2, beat);
    Math.random2(0,1) => int choice;
    if (choice == 1) {
        makeSound(s, pitch * 1.5, volume / 1.5, beat);
    }
    else {
        makeSound(s, pitch, volume, beat);
    }
    makeSound(s, pitch, volume, beat);
    2 *=> pitch;
    2 /=> volume;
}
```

##### 소리크기 조금씩 증가시키기

```
SinOsc s => dac;
220 => int pitch;
0.0 => float volume;
0.5::second => dur beat;
makeSound(s, pitch, volume, beat);
while (true) {
    0.1 +=> volume;
    makeSound(s, pitch * 2, volume / 2, beat);
    Math.random2(0,1) => int choice;
    if (choice == 1) {
        makeSound(s, pitch * 1.5, volume / 1.5, beat);
    }
    else {
        makeSound(s, pitch, volume, beat);
    }
    makeSound(s, pitch, volume, beat);
}
```



### 3-3. 중복 함수

앞에서 공부한 `upOctave` 함수는 둘째 인수 `step`으로 몇 옥타브를 올릴지 내릴지 정하게 하였다. 한 옥타브만 올리는 경우가 아주 잦다고 가정하면, `step`의 기본값을 `1`로 정하고 이 인수를 명시하지 않아도 되게 하면 편리하다. 다시 말해 `step`이 1이 아닌 경우는 `upOctave(60,-1)`과 같이 호출하고, `step`이 1인 경우에 한해서 `upOctave(60)`과 같이 둘째 인수를 생략하고 호출해도 한 옥타브만 올려서 `72`를 리턴하게 해주면 편하겠다는 뜻이다. 그러기 위해서는 이 함수는 다음과 같이 작성하면 된다.

```
fun int upOctave(int note) {
    return note + 12;
}
```

그런데 같은 이름의 함수를 두 개 작성해도 괜찮을까? 다행히도 이런 경우를 고려하여 ChucK 프로그래밍 언어는 <strong>함수 이름의 중복(overloading)</strong>을 허용한다. (각주: 사실 대부분의 프로그래밍 언어가 이러한 유형의 함수 이름 중복을 허용하고 있다.) 같은 이름을 가진 함수의 중복 사용을 가능하게 하려면 함수의 파라미터의 개수를 다르게 하거나, 개수가 같더라도 파라미터의 타입이 최소한 하나 다르게 하면 된다. 그러면 프로그래밍 시스템이 파라미터의 개수와 타입을 검사하여 같은 이름의 함수 중에서 가장 적합한 함수를 찾아서 호출 해준다. 따라서 `upOctave` 함수를 두 개 모두 정의 해놓고 필요에 따라 둘 중 하나를 적절히 호출해 써도 전혀 문제가 없다.

###### 함수를 호출하는 두 가지 방법

ChucK은 함수에 파라미터가 하나만 있는 경우, 함수 호출을 다음과 같이 하는 대신

```
upOctave(60) => mynote;
```

다음과 같이 호출하는 것을 허용한다.

```
60 => upOatave => mynote;
```


#### 사례 학습 : `makeSound` 함수의 유연성 확대


```
fun void makeSound(Osc osc, float pit, float vol, dur len) {
    pit => osc.freq;
    vol => osc.gain;
    <<< "Pitch =", osc.freq(), ", Volume =", osc.gain() >>>;
    len * 4 / 5 => now;
    0 => osc.gain;
    len / 5 => now;
}
```

```
fun void makeSound(Osc osc, float pit, float vol, dur len, float rest) {
    pit => osc.freq;
    vol => osc.gain;
    <<< "Pitch =", osc.freq(), ", Volume =", osc.gain() >>>;
    len * (1 - rest) => now;
    0 => osc.gain;
    len * rest => now;
}
```

#### 사례 학습 : 여러 발진기 동시 소리내기 

이번에는 두 개의 발진기를 설치하여 동시에 소리를 내보자.

`makeSound` 함수는 소리 내는 기간을 인수로 받아 함수 내부에서 시간을 보낸다. 따라서 여러 개의 진동기의 파라미터를 설정을 해둔 다음 동시에 소리를 내는 용도로 사용하기는 적절하지 않다. 대신 다음과 같이 주파수와 소리 크기만 설정하는 함수 `setOsc`를 만들어 활용하면 좋다.

```
fun void setOsc(Osc osc, float pit, float vol) {
    pit => osc.freq;
    vol => osc.gain;
    <<< osc.freq(), osc.gain() >>>;
}
```

그러면 다음 프로그램과 같이, 각 진동기의 주파수와 소리 크기를 이 함수를 호출하여 설정한 다음, 동시에 소리나도록 시간을 보내면 되다.

```
SinOsc s => dac;
SinOsc s2 => dac;
s.freq() => float pitch;
s.gain() => float volume;
0.5 *=> volume;
setOsc(s, pitch, volume);
setOsc(s2, pitch * 3, volume);
second => now;


```

앞 장에서 공부한 세 개의 발진기로 동시에 소리를 내는 코드도 같은 요령으로 다음과 같이 코드를 재작성할 수 있다.

```
SinOsc s => dac;
SinOsc s2 => dac;
SinOsc s3 => dac;
s.freq() => float pitch;
s.gain() => float volume;
3 /=> volume;
setOsc(s, pitch, volume);
setOsc(s2, pitch * 1.5, volume);
setOsc(s3, pitch * 2, volume);
second => now;
```

실행하여 소리를 들어보자.






연습 문제
---------

### 3-1. 반음계 올리고 내리기

##### 함수 사용 전

```
SqrOsc scale => dac;

// note length
0.3::second => dur beat;
beat * (5.0/6) => dur qn; // quarter note sound (1/4)*(5/6)
beat / 6 => dur qn_rest; // quarter note no sound (1/4)*(1/6)
qn * 2 => dur hn; // half note sound
qn_rest * 2 => dur hn_rest; // half note no sound

// volume
0.5 => float on;
0.0 => float off;

// play
for (48 => int i; i <= 60; i++) {
    Std.mtof(i) => scale.freq;
    if (i == 60) {
        on => scale.gain;
        <<< scale.freq(), scale.gain() >>>;
        hn => now;
        off => scale.gain;
        hn_rest => now;
    }
    else {
        on => scale.gain;
        <<< scale.freq(), scale.gain() >>>;
        qn => now;
        off => scale.gain;
        qn_rest => now;
    }
}
for (60 => int i; i >= 48; i--) {
    Std.mtof(i) => scale.freq;
    if (i == 48) {
        on => scale.gain;
        <<< scale.freq(), scale.gain() >>>;
        hn => now;
        off => scale.gain;
        hn_rest => now;
    }
    else {
        on => scale.gain;
        <<< scale.freq(), scale.gain() >>>;
        qn => now;
        off => scale.gain;
        qn_rest => now;
    }
}
```

##### 함수 사용 후

```
SqrOsc scale => dac;

// note length
0.3::second => dur beat;
beat => dur qn; // quarter note
qn * 2 => dur hn; // half note

// volume
0.5 => float volume;

// play
for (48 => int i; i <= 60; i++) {
    if (i == 60)
        makeSound(scale, Std.mtof(i), volume, hn);
    else
        makeSound(scale, Std.mtof(i), volume, qn);
}
for (60 => int i; i >= 48; i--) {
    if (i == 48)
        makeSound(scale, Std.mtof(i), volume, hn);
    else
        makeSound(scale, Std.mtof(i), volume, qn);
}

fun void makeSound(Osc osc, float pit, float vol, dur len) {
    pit => osc.freq;
    vol => osc.gain;
    <<< "Pitch =", osc.freq(), ", Volume =", osc.gain() >>>;
    len * 4 / 5 => now;
    0 => osc.gain;
    len / 5 => now;
}
```

### 3-2. A Love Supreme

##### 함수 사용 전

```
SinOsc love => dac;
TriOsc supreme => dac;

// note length
0.5::second => dur beat;
beat * (5.0/6.0) => dur qn; // quarter note sound (1/4)*(5/6)
beat / 6 => dur qn_rest; // quarter note no sound (1/4)*(1/6)
qn / 2 => dur hqn; // half quarter note sound (1/8)*(5/6)
qn_rest / 2 => dur hqn_rest; // half quarter note no sound (1/8)*(1/6)

// volume
0.5 => float on;
0.0 => float off;
off => supreme.gain;

// note
57 => int start_note;
int note;

// play a love supreme
while (true) {
    Math.random2(start_note-12,start_note+12) => note;
    // A3 57
    Std.mtof(note) => love.freq;
    on => love.gain;
    <<< love.freq(), love.gain() >>>;
    hqn => now;
    off => love.gain;
    hqn_rest => now;
    // C4 60
    Std.mtof(note+3) => love.freq;
    on => love.gain;
    <<< love.freq(), love.gain() >>>;
    qn => now;
    off => love.gain;
    qn_rest => now;
    // A3 57
    Std.mtof(note) => love.freq;
    on => love.gain;
    <<< love.freq(), love.gain() >>>;
    hqn => now;
    off => love.gain;
    hqn_rest => now;
    // D4 62
    Std.mtof(note+5) => love.freq;
    on => love.gain;
    <<< love.freq(), love.gain() >>>;
    hqn => now;
    off => love.gain;
    hqn_rest => now;
    // rest
    if (Math.random2(1,4) == 1) {
        Std.mtof(note+4) => supreme.freq;
        on / 4 => supreme.gain;
        <<< supreme.freq(), supreme.gain() >>>;
        hqn => now;
        off => supreme.gain;
        hqn_rest => now;
        Std.mtof(note+3) => supreme.freq;
        on / 4 => supreme.gain;
        <<< supreme.freq(), supreme.gain() >>>;
        hqn => now;
        off => supreme.gain;
        hqn_rest => now;
        Std.mtof(note+2) => supreme.freq;
        on / 4 => supreme.gain;
        <<< supreme.freq(), supreme.gain() >>>;
        hqn => now;
        off => supreme.gain;
        hqn_rest => now;
    }
    else
        beat * 1.5 => now;
}
```

##### 함수 사용 후

```
SinOsc love => dac;
TriOsc supreme => dac;

// note length
0.5::second => dur beat;
beat => dur qn; // quarter note
qn / 2 => dur hqn; // half quarter note

// volume
0.5 => float volume;
0 => supreme.gain;

// play a love supreme: A3 57, C4 60, A3 57, D4 62
57 => int centernote;
int note;
while (true) {
    Math.random2(centernote-12, centernote+12) => note;
    makeSound(love, Std.mtof(note), volume, hqn);
    makeSound(love, Std.mtof(note+3), volume, qn);
    makeSound(love, Std.mtof(note), volume, hqn);
    makeSound(love, Std.mtof(note+5), volume, hqn);
    if (Math.random2(1,4) == 1) {
        makeSound(supreme, Std.mtof(note+4), volume/4, hqn);
        makeSound(supreme, Std.mtof(note+3), volume/4, hqn);
        makeSound(supreme, Std.mtof(note+2), volume/4, hqn);
    }
    else
        beat * 1.5 => now;
}

fun void makeSound(Osc osc, float pit, float vol, dur len) {
    pit => osc.freq;
    vol => osc.gain;
    <<< "Pitch =", osc.freq(), ", Volume =", osc.gain() >>>;
    len * 4 / 5 => now;
    0 => osc.gain;
    len / 5 => now;
}
```

### 실습 : Random Walk Music

##### 1. [5분] 다음 프로그램은 MIDI음 72에서 시작하여 반음 또는 온음을 올리거나 내리거나 그대로 유지하기를 무작위로 선택하여 무한 반복하는 프로그램이다. 이 프로그램을 이해하고 실행하여 소리를 들어보자.

```
SinOsc s => dac;
72 => int note;
0.5 => float volume;
while (true) {
    <<< "MIDI =", note >>>;
    Std.mtof(note) => s.freq;
    volume => s.gain;
    0.3::second => now;
    Math.random2(-2,2) +=> note;
}
```

##### 2. [10분] 위 프로그램은 어느 정도 시간이 지나면 MIDI 번호가 가청 주파수 범위를 벗어나게 되어 소리가 들리지 않게 되는 경우가 생긴다. 따라서 MIDI 번호의 상한과 하한을 두어 그 범위를 벗어나지 않게 다음과 같이 프로그램을 수정하였다. 수정한 프로그램을 이해하고 실행하여 소리를 들어보자.

```
SinOsc s => dac;
72 => int note;
0.5 => float volume;
while (true) {
    <<< "MIDI =", note >>>;
    Std.mtof(note) => s.freq;
    volume => s.gain;
    0.3::second => now;
    Math.random2(-2,2) +=> note;
    if (note < 60) 60 => note;
    if (note > 84) 84 => note;
}
```

##### 3. [15분] 위 프로그램은 1/5의 확률로 MIDI 음이 변하지 않는 경우가 있다. 같은 음에 머물지 않고 항상 음이 변하도록 프로그램을 수정하자. 무작위 수가 0이 나오지 않도록 해야 한다.

##### 4. [15분] 무작위 수로 0이 나오지 않게 하더라고, 상한 또는 하한에 다다랐을 때 같은 음이 반복된다. 이 경우에도 같은 음에 머물지 않도록 프로그램을 보완하자.

##### 5. [10분] 3번에서 완성한 프로그램은 상한과 하한이 고정되어 있다. 상한과 하한을 자신이 제일 마음에 드는 범위로 수정하자.

##### 6. [15분] 지금까지 작성한 프로그램에서 다음 음을 무작위로 정하는 작업을 하는 코드를 따로 함수로 분리하여 작성해보자. 변하는 부분은 MIDI 음(`note` 변수), 상한, 하한로 하여 함수는 다음과 같이 정의한다.

```
fun int moveNoteRandomly(int note, int min, int max) {
    // ...
}
```

##### 7. [15분] 지금까지는 음이 변화하는 폭이 기껏해야 온음(MIDI 수로 2에 해당)이었다. 음 변화의 폭을 조정하면 3 이상으로 조정하여 소리가 어떻게 달라지는지 관찰해보자. 그리고 변화 폭의 너비도 `moveNoteRandomly`의 파라미터로 다음과 같이 추가하여 프로그램을 재작성하자.

```
fun int moveNoteRandomly(int note, int min, int max, int stride) {
    // ...
}
```

##### 8. [15분] 완성한 프로그램은 각 음의 길이가 일정하다. 무작위로 음의 길이 기준을 정한 다음 반에서 두배 사이로 길이를 무작위로 선택하여 음의 길이가 항상 다르게 들리도록 프로그램을 수정하자.

