```
(c)도경구 version 1.0 (2022/10/04)
```

## 6. 소리 합성 및 다듬기 - `UGen`의 활용

지금까지 사용해본 `dac`, `SinOsc`, `TriOsc`, `SqrOsc`, `SawOsc`, `Noise`, `Gain`, `SndBuf`와 같이 소리를 내는데 필요한 장치를 <b>유닛 제너레이터(Unit Generator)</b>라고 하는데, ChucK 프로그래밍 언어에 준비되어 있는 유닛 제너레이터인 `UGen`을 본격적으로 알아보고, 이를 활용하여 새로운 소리를 합성하고 다듬는 방법을 공부한다.

### 6-1. 특수 내장 `UGen`

다음은 항상 준비되어 있어 언제든지 사용 가능한 내장 `UGen` 이다.

| 내장 `UGen` | 설명 |
|:----:|:----:|
| `dac` | digital-analog converter, 스피커 또는 오디오 아웃풋 장치에 연결되어 외부로 소리를 내보냄 |
| `adc` | analog-digital converter, 마이크 또는 오디오 인풋 장치에 연결되어 외부에서 소리를 받아들임 |
| `blackhole` | 소리 정보를 받긴 하지만 스피커로 보내지 않음 |

#### 인풋, 아웃풋 연결

다음 같이 인풋과 아웃풋을 연결할 수 있다.

```
adc => Gain g => dac;
10::second => now;
```
이 경우 실행하면 컴퓨터 마이크와 스피커가 연결되어, 마이크로 들어가는 소리가 `Gain`을 통과하여 컴퓨터 스피커로 들린다. 이미 써본 적이 있는 `Gain`은 연결되어 있는 `UGen`의 볼륨을 통합하여 조정할 수 있다. 위 프로그램을 실행하면 마이크와 스피커 간의 거리가 짧아서 스피커에서 나오는 소리가 다시 마이크로 들어가면서 피드백이라는 현상이 발생하여 귀를 찢을 듯한 견디기 힘든 소리가 날 수 있다. 따라서 실행하기 전 스피커 볼륨을 최대한 낮추기를 권한다. 이 연결은 10초 동안 지속되다 프로그램 실행 종료와 함께 끊긴다. 중간 다리 역할을 하는 `Gain`은 소리 크기를 조절하는 것 이외에 특별히 할 일은 없지만 두지 않을 수 없는 이유가 있다. 만약 다음과 같이 인풋과 아웃풋을 직접 연결하면 10초가 지나서 프로그램의 실행이 끝난 이후에도 연결된 상태가 지속된다. 왜냐하면, `adc`와 `dac`는 프로그램의 실행과 상관없이 항상 존재하기 때문이다.

```
adc => dac;
10::second => now;
```
따라서 다음과 같이 프로그램으로 명시적으로 끊어주어야 연결이 끊긴다.
```
adc =< dac;
```
따라서 `adc`와 `dac`의 직접 연결은 하지 않는게 좋다.
대신 위와 같이 `Gain`을 가운데 두고 연결하면, 프로그램이 끝남과 동시에 `Gain`도 사라지므로 연결이 저절로 끊긴다.


#### 인풋만 사용

인풋을 받아야 하지만 스피커로 내보내고 싶지 않다면, 다음과 같이 `dac` 대신 `blackhole`에 연결하면 된다.

```
adc => Gain g => blackhole;
while (true) {
    if (g.last() > 0.9)
        <<< "Loud!!", g.last() >>>;
    samp => now;
}
```
이 경우, 인풋으로 들어오는 샘플은 프로그램에서 사용 가능하지만 스피커로는 들리지 않게 된다. 위 프로그램을 실행하면, 마이크로 들어오는 소리 중에서 소리 크기가 `0.9` 이상이면 그 소리 크기를 `Loud!!`와 함께 콘솔 모니터에 프린트 한다. `g.last()`는 `Gain` `UGen` `g`를 통과한 가장 최근 샘플을 알려준다. `0.9`를 아주 낮은 값인 `0.01`로 바꾸어 실행해보자. 아주 작은 소리에도 반응을 함을 볼 수 있다. 외부 소리에 반응하여 프로그램을 작동시키고 싶을 때 유용하게 쓸 수 있다.



### 6-2. `PulseOsc`

`PulseOsc`는 파형의 모양이 아래 그림과 같이 `SqrOsc`와 동일하다. 하지만 파형의 너비를 조절할 수 있다는 점이 `SqrOsc`와 다르다.

<img src="https://i.imgur.com/Ce2MozF.png" width="400">

너비는 `.width` 변수가 기억하고, 기본값은 `0.5`로 설정되어 있다. 따라서 이 변수 값을 바꾸지 않으면 `SqrOsc`와 같다.  `0.5`의 의미는 파형에서 올라간 부분과 내려간 부분의 너비가 반반씩으로 같다는 의미이다. 따라서 `0.1`로 설정하면, 파형 한 주기의 길이는 변화없이 올라간 부분의 너비가 10%, 내려간 부분의 너비가 90%가 된다. `0.9`로 설정하면, 올라간 부분이 90%, 내려간 부분이 10%가 되어 파형의 모양은 달라 보이지만 소리는 동일하다. 소리는 너비의 비율 차이에 따라서만 다르게 들리기 때문이다. 따라서 사실상 다른 소리가 나는 `.width` 값의 범위는 `0.0~0.5` 이다. 다음 프로그램에서 `.width` 변수 값을 바꾸어가며 실행하여 소리가 어떻게 달라지는지 들어보자.

```
PulseOsc p => dac;
0.0 => p.width;
while (true) {
    if (Math.random2(0,1))
        84.0 => p.freq; // E2
    else
        100.0 => p.freq; // G2
    1 => p.gain;
    0.09::second => now;
    0 => p.gain;
    0.06::second => now;
}
```

#### 테크노 댄스 베이스라인

`PulseOsc`만 가지고 재미있는 음악을 만들 수 있다. 다음 프로그램을 실행하여 들어보자.

```
PulseOsc p => dac;
while (true) {
    Math.random2f(0.01,0.5) => p.width;
    if (Math.random2(0,1))
        84.0 => p.freq; // E2
    else
        100.0 => p.freq; // G2
    1 => p.gain;
    0.09::second => now;
    0 => p.gain;
    0.06::second => now;
}
```

### 6-3. `Envelope`


#### 6-3-1. `SqrOsc`와 `Envelope` 활용하여 클라리넷 소리 만들기

지금까지 소리는 처음부터 끝까지가 균일한 볼륨으로 들린다. 연이어 들리는 소리가 끊겨 들리게 하기 위해서 소리의 뒷 부분을 죽이기도 했다. 그런데 자연에서 나는 소리는 시작 부분에서 점진적으로 커지고, 끝 부분에서 점진적으로 작아진다. 노래할 때나, 악기를 불거나, 켜거나, 칠때도 마찬가지다. 우리가 프로그램으로 만드는 소리를 바깥 세상에서 나는 소리와 마찬가지로 자연스럽게 낼 수 있도록 해주는 `UGen`이 `Envelope` 이다.

다음 프로그램을 실행하여 `Envelope`을 적용하기 전의 소리를 먼저 들어보자.

```
SqrOsc clarinet => dac;
[48,50,52,53,55,57,59,60] @=> int scale[];
for (0 => int i; i < scale.size(); i++) {
    Std.mtof(scale[i]) => clarinet.freq;
    0.5::second => now;
}
```

이 소리를 파형으로 표현하면 다음과 같다.

<img src="https://i.imgur.com/0bvTlps.png" width="300">

이번엔 `Envelope`을 사용한 다음 프로그램을 실행하여 소리를 들어보자.
```
SqrOsc clarinet => Envelope env => dac;
[48,50,52,53,55,57,59,60] @=> int scale[];
for (0 => int i; i < scale.size(); i++) {
    Std.mtof(scale[i]) => clarinet.freq;
    1 => env.keyOn;  
    0.25::second => now;
    1 => env.keyOff;
    0.25 :: second => now;
}
```
훨씬 더 실제 클라리넷 소리와 가까운 소리가 난다.

`Envelope`을 적용한 소리를 파형으로 표현하면 다음과 같다.

<img src="https://i.imgur.com/2ftwoWp.png" width="400">

`Envelope`의 시작과 끝의 신호는 각각 다음 두 변수를 1로 설정하여 보낸다.

| `Envelope` | 의미 | 값 | 타입 |
|:----:|:----:|:----:|:----:|
| `.keyOn` | 소리의 크기를 점진적으로 `target()` 까지 올리라는 신호 | 1 | `int` |
| `.keyOff` | 소리의 크기를 점진적으로 `0.0` 까지 내리라는 신호 | 1 | `int` |


그리고 다음 `Envelope` 변수 값을 변경하여 소리의 처음과 끝 부분의 경사 및 소리 크기를 원하는대로 조정할 수 있다.

| `Envelope` | 의미 | 기본 설정값 | 타입 |
|:----:|:----:|:----:|:----:|
| `.target` | 최대 소리 크기 | 1.0 | `float` |
| `.time` | 목표에 도달하는 시간 | 0.022676(초) | `float` |
| `.duration` | 목표에 도달하는 시간 | 1000(샘플) | `dur` |
| `.value` | 소리 크기 일시 설정 | 0.0 | `float` |


#### 6-3-2. `SawOsc`와 `ADSR` 활용하여 바이올린 소리 만들기

`ADSR`은 좀 특별한 형태의 `Envelope`으로 다음 그림과 같이 네 구간으로 나누어진다.

<img src="https://i.imgur.com/OcNOqAJ.png" width="400">

각 구간의 이름은 Attack, Decay, Sustain, Release 인데,
- Attack은 설정된 소리 크기(기본 1.0)까지 점진적으로 올라가는 구간이고,
- Decay는 정점에서 일정 소리 크기까지 내려가는 구간이고,
- Sustain은 일정 소리 크기로 유지하는 구간이고,
- Release는 소리를 점진적으로 끄는 구간이다.

이 구간 길이와 소리 크기 정보는 다음의 `ADSR` 변수에 지정하여 설정한다.

```
SawOsc violin => ADSR env => dac;
0.1::second => env.attackTime; // Attack 구간
0.1::second => env.decayTime; // Decay 구간
0.5 => env.sustainLevel; // Sustain 소리 크기
0.1::second => env.releaseTime; // Release 구간
```

또는 다음과 같이 `.set` 메소드 호출 한번으로 모두 한꺼번에 간편하게 설정할 수도 있다.

```
SawOsc violin => ADSR env => dac;
env.set(0.1::second, 0.1::second, 0.5, 0.1::second)
```

다음 프로그램을 실행하여 소리를 들어보자.

```
SawOsc violin => ADSR env => dac;
env.set(0.1::second, 0.1::second, 0.5, 0.1::second);

[62,64,66,67,69,71,73,74] @=> int scale[];  // D major Scale
for (0 => int i; i < scale.size(); i++) {
    Std.mtof(scale[i]) => violin.freq;
    1 => env.keyOn;
    0.3::second => now;
    1 => env.keyOff;
    0.1::second => now;
}
```

Attack, Decay 하는데 합하여 0.2초로 설정되어 있는데, `.keyOn`을 시작하고 0.3초를 보내므로 Sustain 하는 기간은 0.1초이다. Sustain하는 기간 중의 소리 크기는 설정한 대로 `0.5` 이다. `.keyOff`를 시작하고 보내는 시간인 0.1초는 설정된 Release 기간과 일치한다.


바이올린 소리와 비슷해졌지만 바이올린 특유의 떨림음인 비브라토(vibrato) 효과가 나도록 소리를 변조할 수도 있다. 아래 그림과 같이 비브라토 효과를 전담할 `SinOsc`을 연결하고,

<img src="https://i.imgur.com/HJkPXog.png" width="400">

연결한 `SinOsc vibrato`를 `SawOsc violin`의 주파수 변조용으로 사용하도록 다음과 같이 `.sync` 변수를 `2`로 설정한다. 그리고 `SinOsc vibrato`의 주파수를 매우 낮게 `6.0` 설정한다. 이 프로그램을 실행해보면 약간의 비브라토가 추가되었음을 들을 수 있다.

```
SinOsc vibrato => SawOsc violin => ADSR env => dac;
2 => violin.sync;   
6.0 => vibrato.freq;
env.set(0.1::second, 0.1::second, 0.5, 0.1::second);

[62,64,66,67,69,71,73,74] @=> int scale[];  // D major Scale
for (0 => int i; i < scale.size(); i++) {
    Std.mtof(scale[i]) => violin.freq;
    1 => env.keyOn;
    0.3::second => now;
    1 => env.keyOff;
    0.1::second => now;
}
1 => env.keyOn;
10.0 => vibrato.gain;
1.0::second => now;
1 => env.keyOff;
0.2::second => now;
```

이 프로그램의 마지막 부분에 `SinOsc vibrato`의 소리 크기를 매우 높은 값인 `10.0`
으로 설정하고 1초 정도 소리를 내어 비브라토를 확실히 구별하여 들을 수 있게 하였다.


### 6-4. 주파수 변조로 소리 합성

비브라토 효과를 내는 것과 같은 방식으로 두 개의 `SinOsc`를 연결하여 다양한 소리를 합성할 수 있다. 이를 주파수 변조(Frequence Modulation, 줄여서 FM)를 이용한 소리 합성 이라고 한다. 연결한 두 개의 진동기 중에서 주는 진동기를 변조기(modulator)라고 하고, 받는 진동기를 운반기(carrier)라고 한다.

<img src="https://i.imgur.com/ZQrunZ8.png" width="400">

다음 프로그램은 주파수 변조로 소리를 합성한 사례이다. 실행하여 소리를 들어보자.

```
SinOsc modulator => SinOsc carrier => ADSR env => dac;
2 => carrier.sync;   
1000 => modulator.gain;
env.set(0.1::second, 0.1::second, 0.5, 0.1::second);

[62,64,66,67,69,71,73,74] @=> int scale[];  // D major Scale
for (0 => int i; i < scale.size(); i++) {
    Std.mtof(scale[i]) => carrier.freq => modulator.freq;
    1 => env.keyOn;
    0.4::second => now;
    1 => env.keyOff;
    0.1::second => now;
}
```
운반기 `carrier`의 `.sync`를 주파수 변조 모드인 `2`로 설정하고, 변조기 `modulator`의 `.gain`을 매우 높은 값인 `1000`으로 설정하였다. `modulator.gain` 값을 바꾸어 실행하여 어느 정도의 다양한 소리가 나는지 확인해보자.

이어서 다음 프로그램을 실행하여 변조기와 운반기의 주파수에 따라서 소리가 어떻게 바뀌는지 들어보자.

```
SinOsc modulator => SinOsc carrier => ADSR env => dac;
2 => carrier.sync;   
1000 => modulator.gain;
env.set(0.1::second, 0.1::second, 0.5, 0.1::second);

while (true) {
    Math.random2f(300.0,1000.0) => carrier.freq;
    Math.random2f(300.0,1000.0) => modulator.freq;
    1 => env.keyOn;
    0.4::second => now;
    1 => env.keyOff;
    0.1::second => now;
}
```

주파수의 비율이 정수(1:2, 2:1, 2:3, 1:3, ...)인 경우에만 화음이 맞고, 그렇지 않으면 불협화음 이다.

사인파형(`SinOsc`)만 가지고도 주파수 변조를 활용하면 다양한 소리를 합성할 수 있다. ChucK에서는 주파수 변조로 만든 STK(Synthesis Tool Kit)라고 하는 다양한 악기 소리를 가진 내장 `UGen`를 갖추고 있다.

모든 STK 악기에서 공통으로 사용할 수 있는 메소드는 다음과 같다.

| `StkInstrument` | 설명 |
|:----:|:----:|
| `.noteOn(float velocity)` | 1로 설정하면 악기 켜짐   |
| `.noteOff(float velocity)` | 1로 설정하면 악기를 꺼짐 |
| `.freq(float frequency)` | 주파수 설정 |
| `.controlChange(int number, float value)` | 소리 조절용 메소드로 악기에 따라 다름 |


예를 들어 전기 피아노 소리는 `Rhodey`와 `Wurley` 두 가지가 있는데 테스트 삼아 다음 프로그램을 실행하여 소리를 들어보자.

```
Wurley epiano => dac;
while (true) {
    Math.random2f(100.0,300.0) => epiano.freq;    
    1 => epiano.noteOn;
    Math.random2f(0.2,0.5)::second => now;
    1 => epiano.noteOff;
    Math.random2f(0.05,0.1)::second => now;
}
```

ChucK이 제공하는 `FM`으로 만든 내장 STK 악기를 나열하면 다음과 같다.

- `Rhodey`
- `Wurley`
- `BeeThree`
- `PercFlut`
- `TubeBell`
- `HevyMetl`
- `FMVoices`
- `VoicForm`

### 6-5. 물리적 모델링으로 소리 합성

소리를 내는 실물의 물리적 구조 정보로 수학적 모델을 만들어 소리를 합성하는 방식을 물리적 모델링(Physical Modelling, PM)이라고 한다. 이 절에서는 Karplus와 Strong이 고안한 알고리즘으로 줄 튕기는 소리를 합성해본다.

#### 6-5-1. 줄 튕기는 소리 합성 - `Impulse`에 `Delay` 적용

`Impulse`에서 시작한다. 다음 프로그램을 실행하여 펄스 소리를 들어보자.

```
Impulse imp => dac;
while (true) {
    1.0 => imp.next;
    0.1::second => now;
}
```

펄스 소리가 0.1초 간격으로 난다.

| `Impulse` | 기본 설정 값 | 타입 | 설명 |
|:----:|:----:|:----:|:----:|
| `.next` | `0.0` | `float` | 다음 펄스의 소리 크기 설정 |

이번에는 펄스 소리가 나는 간격을 다르게 설정하여 소리를 들어보자.

```
Impulse imp => dac;
while (true) {
    1.0 => imp.next;
    Math.random2f(0.01,0.1)::second => now;
}
```

`Delay`는 소리 신호를 지연 통과시키는 역할을 하는 `UGen` 이다. 다음 프로그램을 실행하여 소리를 들어보자.

```
Impulse imp => Delay str => dac;
str => str;
1.0 => imp.next;
2::second => now;
```

`Delay`의 `.delay` 변수 기본 값이 `0.0`으로 설정되어 있기 때문에 그냥 놔두면 전혀 지연이 없다. 바로 펄스 소리가 난다. `str => str`은 피드백 루프(feedback loop)라고 하는데 나가는 소리가 자신에게 다시 들어가는 구조이다. 이 경우 지연이 전혀 없기 때문에 다시 들어가더라도 모두 동시에 나가므로 펄스 소리가 한 번만 난다. 단, 시간이 다 지나가면 피드백한 소리가 있으므로 이를 한 번 내주고 끝난다.

| `Delay` | 기본 설정 값 | 타입 | 설명 |
|:----:|:----:|:----:|:----:|
| `.delay` | `0.0` | `dur` | 지연 시간 |

다음 프로그램과 같이 `.delay` 변수 값을 다른 값으로 설정하면 어떤 소리가 나는지 실행하여 들어보자.

```
Impulse imp => Delay str => dac;
str => str;
441.0::samp => str.delay; // 1/100  
1.0 => imp.next;
2::second => now;
```

0.01초 지연되여 소리가 나가는데, 피드백 루프 때문에 0.01초에 한번씩 지속적으로 소리가 난다. 총 2초 동안 200번 펄스 소리가 연속하여 난 것이다.

그런데 다음 프로그램과 같이 `.gain`을 `1.0` 보다 작게 설정하면, 피드백 루프로 되돌아 들어가면서 그 만큼 소리 크기가 줄어든다. 이 프로그램을 실행하여 소리에 어떤 변화가 있는지 들어보자.

```
Impulse imp => Delay str => dac;
str => str;
441.0::samp => str.delay;
0.98 => str.gain;
1.0 => imp.next;
2::second => now;
```

줄을 튕기면 바로 소리가 나지만 시간이 지나면서 서서히 소리가 사라진다. 아직 소리가 좀 어설프긴 하지만 소리가 점차 사라지는 효과는 얻었다.

#### 6-5-2. 줄 튕기는 소리 합성 - `Noise`에 `Delay` 적용하여 개선

그런데 사실 이 소리를 최초로 합성한 연구자는 `Noise`에 `Delay`를 적용하였으므로 그렇게 해보자. `Impulse`는 소리가 한 번 짧게 나고 말기 때문에 피드백 루프 효과를 쉽게 얻을 수 있지만, `Noise`는 연속해서 소리가 나기 때문에 짧게 자르는 작업을 해야 한다. 길이는 지연 시간만큼으로 하고 바로 소리를 끈다. 다음 프로그램을 이해하고 실행하여 소리를 들어보자.

```
Noise noise => Delay str => dac;
str => str;
441.0::samp => str.delay;
0.98 => str.gain;

1.0 => noise.gain;
441.0::samp => now;
0.0 => noise.gain;

3.0 :: second => now;
```

#### 6-5-3. 줄 튕기는 소리 합성 - 필터를 통과시켜 소리 개선

소리는 사라지면서 높은 주파수가 낮은 주파수에 비해 빨리 사라지는 현상을 감안하여 적용한 `OneZero` 필터를 다음과 같이 피드백 루프에 끼우면 소리를 더 실제와 가깝게 개선할 수 있다. 다음 프로그램을 실행하여 소리를 들어보자.

```
Noise noise => Delay str => dac;
str => OneZero filter => str;
441.0::samp => str.delay;
0.98 => str.gain;

1.0 => noise.gain;
441.0::samp => now;
0.0 => noise.gain;

3.0 :: second => now;
```

지금까지 사용한 `Delay`는 주파수의 크고 작음에 따라서 오차가 발생할 가능성이 있다. 이를 보정(튜닝)하기 위해서 보간법을 적용한 `DelayA`와 `DelayL`이 있다. 이를 활용하면 소리가 얼마나 개선되는지 각각 들어보자.

여기에서도 `ADSR`을 적용할 수 있다. 마찬가지로 실행하여 소리를 들어보자.

```
Noise noise => ADSR pluck => Delay str => dac;
str => OneZero filter => str;
441.0::samp => str.delay;
0.98 => str.gain;
pluck.set(0.002::second, 0.002::second, 0.0, 0.01::second);

1 => pluck.keyOn;
3.0 :: second => now;
```

완성한 Karplus와 Strong의 합성 모델의 개념도는 다음 그림과 같다.

<img src="https://i.imgur.com/dihdxk9.png" width="400">

다음 예제 프로그램은 지연 시간에 따라서 음이 다르게 들림을 보여주는 사례이다. 실행하여 소리를 들어보자.

```
Noise noise => ADSR pluck => DelayA str => dac;
str => OneZero lowPass => str;
pluck.set(0.002::second, 0.002::second, 0.0, 0.01::second);

while (true) {
    Math.random2f(110.0, 440.0)::samp => str.delay;
    1 => pluck.keyOn;
    0.3 :: second => now;
}
```

### 6-6. 필터

필터를 몇 개 더 알아보자.

#### 6-6-1. `ResonZ`

`ResonZ` 필터는 소리에 공명(resonance, echo)을 더해주는 역할을 한다.

필터를 끼우기 전의 다음 프로그램을 실행하여 소리를 들어본 다음,

```
Impulse imp => dac;

while (true) {
    10.0 => imp.next;
    0.1 :: second => now;
}
```

`ResonZ` 필터를 끼운 다음 프로그램의 소리를 들어보자.

```
Impulse imp => ResonZ filter => dac;
100.0 => filter.Q; // Quality, amount of resonance

while (true) {
    Math.random2f(500.0,2500.0) => filter.freq;
    100.0 => imp.next;
    0.1 :: second => now;
}
```

`.Q` 값을 바꾸어 가며 소리가 어떻게 변하는지 들어보자.


#### 6-6-2. 소리 다듬기 또는 특수효과용 필터

| 필터 | 값의 범위 | 설명 |
|:----:|:----:|:----:|
| `HPF` | high-pass | `.freq` 이상 통과 |
| `LPF` | low-pass | `.freq` 이하 통과 |
| `BPF` | band-pass|  |
| `BRF` | band-reject | |

다음 프로그램을 실행하여 소리를 들어보자. 필터 별로 어떤 소리가 나는지 확인하고, `.filter`와 `.Q` 값에 따라서 소리가 어떻게 변하는지 들어보자.

```
Noise nz => HPF lp => dac;
500.0 => lp.freq;
100.0 => lp.Q;
0.2 => lp.gain;
second => now;
```

### 6-7. 소리에 특수효과 추가하기


소리는 생기면 사방으로 퍼져나간다. 그러다 벽이나 천장, 바닥 같은 물체에 부딛치면 반사를 하여 다시 퍼져 나간다. 예를 들어 방에서 어떤 소리를 듣는다면 그 소리는 직접 귀에 도달한 소리와 반사된 소리를 동시에 듣게 된다. 그런데 직접 도달한 소리와 물체에 반사되어 도달한 소리는 미소하지만 시차가 있으므로 울림(메아리, reverberation, echo)로 들린다. `Delay`를 사용하면 이러한 울림 소리를 합성할 수 있다.

다음 그림과 같은 규격의 방을 상상해보자.

<img src="https://i.imgur.com/EoXsqf8.png" width="400">

다음 프로그램은 이 방에서 나는 소리가 우리 귀에 어떻게 들릴지 합성한 프로그램이다.
울림 효과는 소리 속도와 듣는자의 위치, 방의 규모를 감안하여 계산하였다.

```
// connect mic to speaker
adc => Gain input => dac;
1.0 => input.gain;
// walls and ceiling
input => Delay d1 => dac;
input => Delay d2 => dac;
input => Delay d3 => dac;
// delay loop
d1 => d1;
d2 => d2;
d3 => d3;
// set feedback/loss on all delay lines
0.6 => d1.gain => d2.gain => d3.gain;
// allocate memory and set delay lengths
0.06::second => d1.max => d1.delay;
0.08::second => d2.max => d2.delay;
0.10::second => d3.max => d3.delay;
// sit back and enjoy the room
while (true)
    1.0 :: second => now;
```

이 프로그램에서 지연 시간을 1.0 미만 한도 내에서 조절하여 소리가 어떻게 변하는지 들어보자. 그리고 피드백 루프에 `OneZero` 같은 필터를 끼워 소리가 어떻게 달라지는지도 들어보자. 값을 바꾸어 가며 들어보면 느끼겠지만 만족할 만한 소리를 만들어내는 것이 쉬운 일이 아니다. 이 작업이 소리공학자의 몫이니 다행이다. ChucK에서 제공해주는 괜찮은 메아리 전용 내장 `UGen`이 있어서 필요하면 가져다 쓰면 된다.

| 내장 메아리 `UGen` | 설명 |
|:----:|:----:|
| `PRCRev` | Perry R. Cook 제작 |
| `JCRev` | FM 발견자 이름의 약자 |
| `NRev` | New Reverberation의 약자 |

다음 프로그램을 실행하여 3개의 메아리 소리의 차이를 들어보자.

```
// Beware Feedback!
// Turn down the volume.
adc => NRev rev => dac;
// set reverb/dry mixture
0.05 => rev.mix;
// kick back and enjoy the space
while (true)
    1.0 :: second => now;
```

이 외에도 `Chorus`, `PitShift` 같은 특수 효과를 낼 수 있는 `UGen`이 있으니 매뉴얼을 참고하여 필요한 대로 사용하면 된다.


### [실습] 학교종

```
// note length
0.5::second => dur beat;
beat / 4 => dur rest;
beat - rest => dur qn; // quarter note
beat * 2 - rest => dur hn; // half note
beat * 3 - rest => dur dhn; // dotted half note

[ // melody
67,67,69,69, 67,67,64,
67,67,64,64, 62,-1,
67,67,69,69, 67,67,64,
67,64,62,64, 60,-1
] @=> int melody[];

[ // bassline
48,48,41,41, 48,48,48,
48,48,45,45, 43,-1,
48,48,41,41, 48,48,48,  
48,48,43,47, 48,-1
] @=> int bassline[];

[ // tempo
qn,qn,qn,qn, qn,qn,hn,
qn,qn,qn,qn, dhn,qn,
qn,qn,qn,qn, qn,qn,hn,
qn,qn,qn,qn, dhn,qn
] @=> dur durs[];

// play
SinOsc song => dac;
TriOsc bass => dac;
for (0 => int n; n < 2; n++)
    for (0 => int i; i < melody.size(); i++) {
        if (melody[i] == -1)
            0.0 => song.gain => bass.gain;
        else
            0.5 => song.gain => bass.gain;
        Std.mtof(melody[i]) => song.freq;
        Std.mtof(bassline[i]) => bass.freq;
        durs[i] => now;
        0 => song.gain => bass.gain;
        rest => now;
    }
```

- 이 프로그램은 학교종을 연주하는 프로그램이다. 음원는 모두 `SqrOsc`로 하고, `Envelope` UGen을 통과시키도록 프로그램을 재작성하자. `.gain` 대신 `Envelope`의 `.target`, `.keyOn`, `.keyOff`를 활용해야 한다.

- 이번에는 `ADSR` UGen을 사용하여 재작성하자. 음원은 모두 `SawOsc`로 바꾼다. 그리고 가장 마음에 드는 소리가 날때까지 파라미터를 조정해보자. 그리고 나서 추가로 멜로디에 비브라토를 넣어보자.

- 이번에는 주파수 변조를 시도해보자. 두 음원 모두 `SinOsc` 2개를 각각 Carrier와 Modulator로 사용하여 주파수를 변조하고 `ADSR`를 활용하여 `학교종`을 연주하는 프로그램을 재작성하고, Modulator의 `.gain`과 Carrier와 Modulator의 주파수 비율에 따라서 소리가 어떻게 달라지는지 들어보고, 값을 조정하여 가장 마음에 드는 소리를 찾아보자.

- 이번에는 `FM`으로 만든 ChucK 내장 STK 악기로 연주하도록 프로그램을 재작성하자. 다음의 다양한 악기 소리를 모두 들어보자.

    - `Rhodey`
    - `Wurley`
    - `BeeThree`
    - `PercFlut`
    - `TubeBell`
    - `HevyMetl`
    - `FMVoices`
    - `VoicForm`

- 이번에는 `Impulse`와 `Resonz` 필터를 사용하여 `학교종`을 연주하도록 프로그램을 재작성해보자.

- 마지막으로 다음 프로그램의 소리 효과를 활용하여 `학교종`의 멜로디 파트만 연주하도록 프로그램을 재작성해보자.

```
// Musical fun with a resonant filter and three delay lines
Impulse imp => ResonZ rez => Gain input => dac;
100 => rez.Q;
100 => rez.gain;
1.0 => input.gain;

Delay del[3];
input => del[0] => dac.left;
input => del[1] => dac;
input => del[2] => dac.right;

for (0 => int i; i < 3; i++) {
    del[i] => del[i];
    0.6 => del[i].gain;
    (0.8 + i*0.3)::second => del[i].max => del[i].delay;
}

[60, 64, 65, 67, 70, 72] @=> int notes[];
notes.cap() - 1 => int numNotes;
while (true) {
    Std.mtof(notes[Math.random2(0,numNotes)]) => rez.freq;
    1.0 => imp.next;
    0.4::second => now;
}
```


### [숙제] 햇볕은 쨍쟁 + 반달 소리 개선하기

실습으로 완성한 `햇볕은 쨍쨍`과 숙제#3으로 작성한 `반달` 연주 프로그램을 다음 요구 사항에 맞추어 각각 재작성하자. 

- 버전 1: `SawOsc` 또는 `SqrOsc`를 기본으로 하여 배운 소리 합성, 소리다듬기 기술을 원하는 대로 총동원하여 본인이 가장 마음에 드는 소리가 나도록 연주를 개선하자.

- 버전 2: ChucK 라이브러리에서 제공하는 StkInstrument 중에서 가장 마음에 드는 악기를 하나 골라 연주하도록 프로그램을 수정하자.

4개의 완성한 프로그램을 하나의 파일로 zip으로 압축하여 제출한다.




