SinOsc s => dac;
for (0 => int note; note < 16; note++) {
    Math.randomf(48,72) => float note;
    Std.mtof(note) => s.freq;
    volume => s.gain;
    0.5::second => now;
}