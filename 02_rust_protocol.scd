// RUST PROTOCOL — industrial dub techno, 120 BPM
// Cavernous delays, corroded textures, mechanical rhythm
(
s.waitForBoot({
    var clock = TempoClock.new(120/60);
    var delayBus = Bus.audio(s, 2);

    SynthDef(\rp_delay, { |in=0, out=0|
        var sig = In.ar(in, 2);
        var del = CombL.ar(sig, 1, [0.375, 0.5], 6);
        del = LPF.ar(del, LFNoise1.kr(0.1).exprange(600, 3000));
        del = HPF.ar(del, 80);
        Out.ar(out, del * 0.35);
    }).add;

    SynthDef(\rp_kick, { |out=0, amp=0.85|
        var env = EnvGen.kr(Env.perc(0.001, 0.5, 1, -6), doneAction: 2);
        var penv = EnvGen.kr(Env([150, 48, 44], [0.012, 0.1], [-5, -2]));
        var sig = SinOsc.ar(penv);
        sig = sig + (SinOsc.ar(penv * 2) * EnvGen.kr(Env.perc(0.001, 0.03)));
        sig = (sig * 1.5).tanh * env * amp;
        Out.ar(out, sig ! 2);
    }).add;

    SynthDef(\rp_snare, { |out=0, amp=0.3, sendBus=0|
        var env = EnvGen.kr(Env.perc(0.001, 0.2, 1, -5), doneAction: 2);
        var sig = SinOsc.ar(180) * EnvGen.kr(Env.perc(0.001, 0.05));
        sig = sig + (HPF.ar(WhiteNoise.ar, 1200) * EnvGen.kr(Env.perc(0.001, 0.12, 1, -6)));
        sig = sig * amp;
        Out.ar(sendBus, sig ! 2 * 0.3);
        Out.ar(out, sig ! 2);
    }).add;

    SynthDef(\rp_rim, { |out=0, amp=0.2, sendBus=0|
        var env = EnvGen.kr(Env.perc(0.001, 0.015, 1, -10), doneAction: 2);
        var sig = SinOsc.ar(1200) * env * amp;
        sig = sig + (BPF.ar(WhiteNoise.ar, 3000, 0.1) * env * amp * 0.5);
        Out.ar(sendBus, sig ! 2 * 0.5);
        Out.ar(out, sig ! 2);
    }).add;

    SynthDef(\rp_chord, { |out=0, freq=120, amp=0.06, gate=1, sendBus=0|
        var env = EnvGen.kr(Env.asr(3, 1, 4), gate, doneAction: 2);
        var detune = LFNoise2.kr(0.03).range(0.99, 1.01);
        var sig = LFPulse.ar([freq, freq*1.5*detune, freq*2.003], 0, LFNoise1.kr(0.06).range(0.3, 0.7));
        sig = LPF.ar(sig.sum * 0.33, LFNoise1.kr(0.05).exprange(300, 1500));
        sig = sig * env * amp;
        Out.ar(sendBus, sig ! 2 * 0.4);
        Out.ar(out, sig ! 2);
    }).add;

    SynthDef(\rp_corrode, { |out=0, freq=400, amp=0.08, sendBus=0|
        var env = EnvGen.kr(Env.perc(0.01, 0.5, 1, -4), doneAction: 2);
        var sig = Crackle.ar(1.7, 0.3) * BPF.ar(Saw.ar(freq), freq * 1.5, 0.15);
        sig = sig * env * amp;
        Out.ar(sendBus, sig ! 2 * 0.6);
        Out.ar(out, Pan2.ar(sig, LFNoise1.kr(3).range(-0.7, 0.7)));
    }).add;

    s.sync;

    // Global dub delay
    Synth(\rp_delay, [\in, delayBus, \out, 0], addAction: \addToTail);

    // Kick: heavy four-on-the-floor
    Pbind(
        \instrument, \rp_kick,
        \dur, 1,
        \amp, Pseq([0.85, 0.75, 0.85, 0.78], inf),
    ).play(clock);

    // Snare: 2 and 4 with ghost hits
    Pbind(
        \instrument, \rp_snare,
        \dur, Pseq([Rest(1), 1], inf),
        \amp, Pwhite(0.22, 0.32),
        \sendBus, delayBus,
    ).play(clock);

    // Rimshot: syncopated 16th patterns, feeds delay
    Pbind(
        \instrument, \rp_rim,
        \dur, 0.25,
        \amp, Pif(Pfunc({ 0.3.coin }), Pwhite(0.12, 0.22), 0),
        \sendBus, delayBus,
    ).play(clock);

    // Dub chord: slow evolving
    Pbind(
        \instrument, \rp_chord,
        \freq, Pxrand([52, 55, 57, 60].midicps, inf),
        \dur, Pwhite(8, 20),
        \amp, 0.06,
        \legato, 1.15,
        \sendBus, delayBus,
    ).play(clock);

    // Corroded texture: rust and static
    Pbind(
        \instrument, \rp_corrode,
        \dur, Pwrand([0.5, 1, 1.5, 2], [0.2, 0.35, 0.25, 0.2], inf),
        \freq, Pwhite(200, 1600),
        \amp, Pwhite(0.03, 0.1) * Pwrand([1, 0], [0.3, 0.7], inf),
        \sendBus, delayBus,
    ).play(clock);

    "--- RUST PROTOCOL :: 120 BPM ---".postln;
    "--- Ctrl+. to stop ---".postln;
});
)
