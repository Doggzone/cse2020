
## 실습 - 반달

이번엔 `반달`을 다음 두 가지 소통 방식으로 각각 재작성해보자.

- 멜로디와 반주 연주를 두 파일로 분리하고, 한 파일에서 하나의 쉬레드를 만들도록 프로그램을 여러 파일로 분리하고, `MidiOut`과 `MidiIn`을 활용하여 쉬레드 간에 MIDI 메시지를 보내서 연주하게 한다.

- 한 파일에서 하나의 쉬레드를 만들도록 프로그램을 여러 파일로 분리하고, `OscOut`과 `OscIn`을 활용하여 쉬레드 간에 메시지를 보내서 연주하게 한다.

힌트 : 지휘 역할을 하는 파일과 연주 역할을 하는 파일을 분리하여, 지휘 역할을 하는 파일에서 연주 역할을 하는 파일로 메시지를 보내서 연주하게 만든다.


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
