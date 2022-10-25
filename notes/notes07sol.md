```
(c)도경구 version 1.0 (2022/10/18)
```

### 7. 실습 - 완성 프로그램

#### 1. 반달

```
// tempo
0.5::second => dur beat;
beat => dur n1; // 1/6
beat * 2 => dur n2; // 2/6
beat * 3 => dur n3; // 3/6
beat * 5 => dur n5; // 5/6

[ // halfmoon melody
67,69,67,64,  67,64,60,55,  57,60,62,67,     64,-1,
67,69,67,64,  67,64,60,55,  57,60,55,62,     60,-1,
64,64,64,62,  64,   69,67,  64,62,64,69,     67,-1,
72,   67,67,  64,64,69,69,  67,64,60,55,62,  60,-1
] @=> int melody[];

[ // halfmoon melody time
n2,n1,n2,n1,  n1,n1,n1,n3,  n2,n1,n2,n1,     n5,n1,
n2,n1,n2,n1,  n1,n1,n1,n3,  n2,n1,n2,n1,     n5,n1,
n2,n1,n2,n1,  n2,   n1,n3,  n2,n1,n2,n1,     n5,n1,
n3,   n2,n1,  n2,n1,n2,n1,  n1,n1,n1,n2,n1,  n5,n1
] @=> dur melody_len[];

// C = 48,52,55
// F = 48,53,57
// G7 = 47,50,53
// Am = 45,48,52

[ // halfmoon harmony
48,52,55, 48,52,55, 48,52,55, 48,52,55,
48,53,57, 47,50,53, 48,52,55, 48,52,55,
48,52,55, 48,52,55, 48,52,55, 48,52,55,
48,53,57, 47,50,53, 48,52,55, 48,52,55,
48,52,55, 48,52,55, 45,48,52, 47,50,53,
48,52,55, 48,52,55, 47,50,53, 47,50,53,
48,52,55, 48,52,55, 48,52,55, 48,53,57,
48,52,55, 47,50,53, 48,52,55, 48,52,55
] @=> int harmony[];

[ // halfmoon harmony time
n1,n1,n1, n1,n1,n1, n1,n1,n1, n1,n1,n1,
n1,n1,n1, n1,n1,n1, n1,n1,n1, n1,n1,n1,
n1,n1,n1, n1,n1,n1, n1,n1,n1, n1,n1,n1,
n1,n1,n1, n1,n1,n1, n1,n1,n1, n1,n1,n1,
n1,n1,n1, n1,n1,n1, n1,n1,n1, n1,n1,n1,
n1,n1,n1, n1,n1,n1, n1,n1,n1, n1,n1,n1,
n1,n1,n1, n1,n1,n1, n1,n1,n1, n1,n1,n1,
n1,n1,n1, n1,n1,n1, n1,n1,n1, n1,n1,n1
] @=> dur harmony_len[];

// play
Wurley righthand => dac;
Wurley lefthand => dac;
spork ~ play(righthand, melody, melody_len);
spork ~ play(lefthand, harmony, harmony_len);
96 * beat => now;

fun void play(StkInstrument instrument, int note[], dur length[]) {
    for (0 => int i; i < note.size(); i++) {
        if (note[i] != -1) {
            Std.mtof(note[i]) => instrument.freq;
            1 => instrument.noteOn;
        }
        length[i] => now;
        1 => instrument.noteOff;
    }
}
```


#### 2. 돌림노래 Row-Row-Row-Your-Boat

```
// tempo
0.2::second => dur beat;
beat => dur n1; // 1/6
beat * 2 => dur n2; // 2/6
beat * 3 => dur n3; // 3/6
beat * 6 => dur n6; // 6/6

[ // melody
60,60,             60,62,64,          64,62,64,65, 67,
72,72,72,67,67,67, 64,64,64,60,60,60, 67,65,64,62, 60
] @=> int melody[];

[ // time
n3,n3,             n2,n1,n3,          n2,n1,n2,n1, n6,
n1,n1,n1,n1,n1,n1, n1,n1,n1,n1,n1,n1, n2,n1,n2,n1, n6
] @=> dur length[];

Rhodey piano[4];
piano[0] => dac;
piano[1] => dac;
piano[2] => dac;
piano[3] => dac;
spork ~ play(piano[0], melody, length);
n6 * 2 => now;
spork ~ play(piano[1], melody, length);
n6 * 2 => now;
spork ~ play(piano[2], melody, length);
n6 * 2 => now;
spork ~ play(piano[3], melody, length);
n6 * 8 => now;

fun void play(StkInstrument instrument, int note[], dur length[]) {
    for (0 => int i; i < note.size(); i++) {
        if (note[i] != -1) {
            Std.mtof(note[i]) => instrument.freq;
            1 => instrument.noteOn;
        }
        length[i] => now;
        1 => instrument.noteOff;
    }
}
```

#### 3. Bach의 Crab Canon

```
// tempo
0.4::second => dur beat;
beat => dur qn; // quarter note (1/4)
beat / 2 => dur en; // eighth note (1/8)
beat * 2 => dur hn; // half note (1/2)

[ // score
60,         63,         67,         68,
59,         -1,   67,         66,         65,
      64,         63,         62,   61,   60,
59,   55,   62,   65,   63,         62,
60,         63,         67,65,67,72,67,63,62,63,
65,67,69,71,72,63,65,67,68,62,63,65,67,65,63,62,
63,65,67,68,70,68,67,65,67,68,70,72,73,70,68,67,
69,71,72,74,75,72,71,69,71,72,74,75,77,74,67,74,
72,74,75,77,75,74,72,71,72,   67,   63,   60
] @=> int note[];

[ // time
hn,         hn,         hn,         hn,    
hn,         qn,   hn,         hn,         hn,     
      hn,         hn,         qn,   qn,   qn,
qn,   qn,   qn,   qn,   hn,         hn,   
hn,         hn,         en,en,en,en,en,en,en,en,
en,en,en,en,en,en,en,en,en,en,en,en,en,en,en,en,
en,en,en,en,en,en,en,en,en,en,en,en,en,en,en,en,      
en,en,en,en,en,en,en,en,en,en,en,en,en,en,en,en,      
en,en,en,en,en,en,en,en,qn,   qn,   qn,   qn
] @=> dur length[];

// play
Rhodey piano1 => dac;
Rhodey piano2 => dac;

<<< "Play Crab Canon", "forward" >>>;
play(piano1, note, length);

<<< "Play Crab Canon", "backward" >>>;
retrograde(piano2, note, length);

<<< "Play Crab Canon", "forward and backward together" >>>;
spork ~ play(piano1, note, length);
spork ~ retrograde(piano2, note, length);
hn * 36 => now;

fun void play(StkInstrument instrument, int note[], dur length[]) {
    for (0 => int i; i < note.size(); i++) {
        if (note[i] != -1) {
            Std.mtof(note[i]) => instrument.freq;
            1 => instrument.noteOn;
        }
        length[i] => now;
        1 => instrument.noteOff;
    }
}

fun void retrograde(StkInstrument instrument, int note[], dur length[]) {
    for (note.size() - 1 => int i; i >= 0; i--) {
        if (note[i] != -1) {
            Std.mtof(note[i]) => instrument.freq;
            1 => instrument.noteOn;
        }
        length[i] => now;
        1 => instrument.noteOff;
    }
}
```

#### 4. J.S. Bach, Canon a 2 perpetuus (BWV 1075)

```
// tempo
0.4::second => dur beat;
beat => dur n1;
beat * 2 => dur n2;
beat * 6 => dur n6;

[ // score
67,72,67,69,67,65,
64,   76,77,76,74,
72,67,72,71,72,74,
76,   64,62,64,65
] @=> int melody[];

[ // time
n1,n1,n1,n1,n1,n1,
n2,   n1,n1,n1,n1,
n1,n1,n1,n1,n1,n1,
n2,   n1,n1,n1,n1
] @=> dur length[];

// set up instruments
Rhodey hand1 => dac;
Rhodey hand2 => dac;

// play duo
spork ~ play1();
spork ~ play2();
n6 * 11 => now;

fun void play1() { // total = n6 * 11
    play(hand1, melody, length); // n6 * 4
    play(hand1, melody, length); // n6 * 4
    play(hand1, melody, length, 11); // n6 * 2
    playnote(hand1, 72, n6); // n6 * 1
}

fun void play2() { // total = n6 * 11
    n6 => now; // n6 * 1
    play(hand2, melody, length); // n6 * 4
    play(hand2, melody, length); // n6 * 4
    play(hand2, melody, length, 6); // n6 * 1
    playnote(hand2, 64, n6); // n6 * 1
}

fun void play(StkInstrument instrument, int note[], dur length[]) {
    for (0 => int i; i < note.size(); i++)
        playnote(instrument, note[i], length[i]);
}

fun void play(StkInstrument instrument, int note[], dur length[], int upto) {
    for (0 => int i; i < upto; i++)
        playnote(instrument, note[i], length[i]);
}

fun void playnote(StkInstrument instrument, int note, dur length) {
    if (note != -1) {
        Std.mtof(note) => instrument.freq;
        1 => instrument.noteOn;
    }
    length => now;
    1 => instrument.noteOff;
}
```

### 숙제 : J.S. Bach, Trias Harmonica Canon (BWV 1072)

```

```
