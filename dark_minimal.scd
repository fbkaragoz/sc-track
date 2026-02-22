(
s.waitForBoot({
    var clock = TempoClock.new(118/60);

    // --- SynthDefs ---

    SynthDef(\dk_kick, { |out=0, amp=0.8|
        var env = EnvGen.kr(Env.perc(0.001, 0.45, 1, -8), doneAction: 2);
        var pitchEnv = EnvGen.kr(Env([120, 45, 42], [0.01, 0.08], [-4, -2]));
        var sig = SinOsc.ar(pitchEnv) * env;
        sig = (sig * 1.4).tanh;
        sig = sig * amp;
        Out.ar(out, sig ! 2);
    }).add;

    SynthDef(\dk_hat, { |out=0, amp=0.25, ffreq=7500, decay=0.04|
        var env = EnvGen.kr(Env.perc(0.001, decay, 1, -12), doneAction: 2);
        var sig = HPF.ar(WhiteNoise.ar, ffreq) * env * amp;
        Out.ar(out, sig ! 2);
    }).add;

    SynthDef(\dk_metal, { |out=0, freq=800, amp=0.12|
        var env = EnvGen.kr(Env.perc(0.001, 0.18, 1, -6), doneAction: 2);
        var sig = SinOsc.ar(freq) * SinOsc.ar(freq * 1.71);
        sig = BPF.ar(sig, freq * 0.8, 0.3) * env * amp;
        Out.ar(out, Pan2.ar(sig, LFNoise1.kr(0.5).range(-0.6, 0.6)));
    }).add;

    SynthDef(\dk_drone, { |out=0, freq=42, amp=0.2, gate=1|
        var env = EnvGen.kr(Env.asr(2, 1, 3), gate, doneAction: 2);
        var mod = LFNoise1.kr(0.07).range(0.98, 1.02);
        var sig = LFSaw.ar([freq * mod, freq * 1.002], 0, amp);
        sig = LPF.ar(sig, LFNoise1.kr(0.12).exprange(60, 350));
        sig = sig * env;
        Out.ar(out, sig);
    }).add;

    SynthDef(\dk_stab, { |out=0, freq=900, amp=0.08|
        var env = EnvGen.kr(Env.perc(0.01, 0.6, 1, -4), doneAction: 2);
        var sig = BPF.ar(PinkNoise.ar, freq, 0.05) * env * amp * 20;
        sig = FreeVerb.ar(sig, 0.85, 0.9, 0.4);
        Out.ar(out, sig ! 2);
    }).add;

    s.sync;

    // --- Patterns ---

    // Kick: four on the floor with rare ghost hits
    Pbind(
        \instrument, \dk_kick,
        \dur, Pwrand([1, Pseq([0.75, 0.25])], [0.9, 0.1], inf),
        \amp, Pwrand([0.8, 0.45], [0.88, 0.12], inf),
    ).play(clock);

    // Hat: 16ths with shifting density
    Pbind(
        \instrument, \dk_hat,
        \dur, 0.25,
        \amp, Pif(Pfunc({ 0.55.coin }), Pwhite(0.12, 0.28), 0),
        \ffreq, Pwhite(6500, 9500),
        \decay, Pwhite(0.025, 0.06),
    ).play(clock);

    // Metallic percussion: sparse off-beat pings
    Pbind(
        \instrument, \dk_metal,
        \dur, Pwrand([0.5, 0.75, 1, 1.5], [0.3, 0.25, 0.3, 0.15], inf),
        \freq, Pxrand([620, 680, 740, 810, 900], inf),
        \amp, Pwhite(0.06, 0.15) * Pwrand([1, 0], [0.4, 0.6], inf),
    ).play(clock);

    // Sub drone: slow wandering bass
    Pbind(
        \instrument, \dk_drone,
        \freq, Pxrand([38, 42, 46], inf),
        \dur, Pwhite(8, 16),
        \amp, 0.18,
        \legato, 1.1,
    ).play(clock);

    // Textural stab: rare distant bursts
    Pbind(
        \instrument, \dk_stab,
        \dur, Pwhite(3, 8),
        \freq, Pwhite(500, 2200),
        \amp, Pwhite(0.04, 0.1),
    ).play(clock);

    "--- dark minimal running at 118 BPM ---".postln;
    "--- Ctrl+. to stop ---".postln;
});
)
