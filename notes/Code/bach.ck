// MIDI
36 => int C2; 48 => int C3; 60 => int C4; 72 => int C5; 84 => int C6; 
38 => int D2; 50 => int D3; 62 => int D4; 74 => int D5; 86 => int D6;
40 => int E2; 52 => int E3; 64 => int E4; 76 => int E5; 88 => int E6;
41 => int F2; 53 => int F3; 65 => int F4; 77 => int F5; 89 => int F6;
43 => int G2; 55 => int G3; 67 => int G4; 79 => int G5; 91 => int G6;
45 => int A2; 57 => int A3; 69 => int A4; 81 => int A5; 93 => int A6;
47 => int B2; 59 => int B3; 71 => int B4; 83 => int B5; 95 => int B6;

// note length
0.5::second => dur beat;
beat / 5 => dur REST;
beat - REST => dur QN; // quarter note (1/4)
beat * 1.5 - REST => dur DQN; // dotted quarter note (3/8)
beat / 2 - REST => dur EN; // eighth note (1/8)
beat * 2 - REST => dur HN; // half note (1/2)
beat * 3 - REST => dur DHN; // dotted half note (3/4)



BeeThree organ => dac;

// J.S. Bach - Goldberg
[G3,F3+1,E3,D3,B2,C3,D3,G2] @=> int GOLDBERG[];
[QN,QN,QN,QN,QN,QN,QN,QN] @=> dur GOLDBERGDUR[];

for (0 => int i; i < GOLDBERG.size(); i++) {
    Std.mtof(GOLDBERG[i]) => organ.freq;
    1 => organ.noteOn;
    GOLDBERGDUR[i] => now;
    1 => organ.noteOff;
    REST => now;
}


// J.S. Bach - TriasHarmonica BWV 1072 Canon
// The theme for choir 1
[C4,D4,E4,F4, G4,F4,E4,D4] @=> int THEME1[];
[DQN,EN,DQN,EN, DQN,EN,DQN,EN] @=> dur DUR1[];
// The inverted theme for choir 2
[G4,F4,E4,D4, C4,D4,E4,F4] @=> int THEME2[];
[DQN,EN,DQN,EN, DQN,EN,DQN,EN] @=> dur DUR2[];

for (0 => int i; i < THEME1.size(); i++) {
    Std.mtof(THEME1[i]) => organ.freq;
    1 => organ.noteOn;
    DUR1[i] => now;
    1 => organ.noteOff;
    REST => now;
}
    
for (0 => int i; i < THEME2.size(); i++) {
    Std.mtof(THEME2[i]) => organ.freq;
    1 => organ.noteOn;
    DUR2[i] => now;
    1 => organ.noteOff;
    REST => now;
}