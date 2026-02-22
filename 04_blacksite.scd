// BLACKSITE — hard minimal, 132 BPM
// Pounding kick, distorted loops, relentless machine rhythm
(
s.waitForBoot({
    var clock = TempoClock.new(132/60);

    SynthDef(\bs_kick, { |out=0, amp=0.9|
        var env = EnvGen.kr(Env.perc(0.0005, 0.3, 1, -8), doneAction: 2);
        var penv = EnvGen.kr(Env([300, 55, 48], [0.006, 0.06], [-8, -3]));
        var click = BPF.ar(WhiteNoise.ar, 3000, 0.5) * EnvGen.kr(Env.perc(0.0005, 0.003));
        var body = SinOsc.ar(penv);
        var sig = body + (click * 0.7);
        sig = (sig * 2).clip2(0.9) * env * amp;
        Out.ar(out, sig ! 2);
    }).add;

    SynthDef(\bs_hat, { |out=0, amp=0.2, decay=0.03|
        var env = EnvGen.kr(Env.perc(0.0005, decay, 1, -15), doneAction: 2);
        var sig = HPF.ar(WhiteNoise.ar, 9000);
        sig = sig + (Pulse.ar(6000, 0.5) * 0.05);
        sig = sig * env * amp;
        Out.ar(out, sig ! 2);
    }).add;

    SynthDef(\bs_open, { |out=0, amp=0.15|
        var env = EnvGen.kr(Env.perc(0.001, 0.18, 1, -4), doneAction: 2);
        var sig = HPF.ar(WhiteNoise.ar, 7000) * env * amp;
        Out.ar(out, sig ! 2);
    }).add;

    SynthDef(\bs_tom, { |out=0, freq=100, amp=0.3|
        var env = EnvGen.kr(Env.perc(0.001, 0.15, 1, -6), doneAction: 2);
        var penv = EnvGen.kr(Env([freq * 2.5, freq, freq * 0.9], [0.01, 0.1], [-4, -2]));
        var sig = SinOsc.ar(penv) * env * amp;
        sig = (sig * 1.8).tanh;
        Out.ar(out, sig ! 2);
    }).add;

    SynthDef(\bs_stab, { |out=0, freq=200, amp=0.2|
        var env = EnvGen.kr(Env.perc(0.001, 0.08, 1, -10), doneAction: 2);
        var sig = Saw.ar([freq, freq * 1.01]) + Pulse.ar([freq * 0.5, freq * 0.503], 0.3);
        sig = RLPF.ar(sig.sum * 0.25, freq * 4, 0.3);
        sig = (sig * 3).tanh * env * amp;
        Out.ar(out, sig ! 2);
    }).add;

    SynthDef(\bs_noise, { |out=0, amp=0.06|
        var env = EnvGen.kr(Env.perc(0.01, 0.4, 1, -3), doneAction: 2);
        var sig = BPF.ar(BrownNoise.ar, LFNoise0.kr(12).exprange(200, 4000), 0.05) * 20;
        sig = sig * env * amp;
        sig = FreeVerb.ar(sig, 0.5, 0.6, 0.5);
        Out.ar(out, Pan2.ar(sig, Rand(-0.9, 0.9)));
    }).add;

    s.sync;

    // Kick: punishing four-on-the-floor
    Pbind(
        \instrument, \bs_kick,
        \dur, 1,
        \amp, 0.9,
    ).play(clock);

    // Closed hat: driving 16ths with accent pattern
    Pbind(
        \instrument, \bs_hat,
        \dur, 0.25,
        \amp, Pseq([0.08, 0.18, 0.12, 0.2, 0.08, 0.18, 0.1, 0.22], inf)
            * Pif(Pfunc({ 0.8.coin }), 1, 0),
        \decay, Pwhite(0.015, 0.04),
    ).play(clock);

    // Open hat: off-beat
    Pbind(
        \instrument, \bs_open,
        \dur, Pseq([Rest(0.5), 0.5], inf),
        \amp, Pwhite(0.1, 0.17),
    ).play(clock);

    // Toms: machine gun fills every 8 bars
    Pbind(
        \instrument, \bs_tom,
        \dur, Pseq([
            Pseq([Rest(1)], 31),
            Pseq([0.25], 4)
        ], inf),
        \freq, Pxrand([80, 100, 130, 160], inf),
        \amp, Pwhite(0.2, 0.35),
    ).play(clock);

    // Distorted stab: syncopated machine riff
    Pbind(
        \instrument, \bs_stab,
        \dur, Pseq([0.25, 0.25, Rest(0.25), 0.5, Rest(0.25), 0.25, Rest(0.25), 0.5, 0.5], inf),
        \freq, Pxrand([48, 48, 51, 53, 55, 58].midicps, inf),
        \amp, Pwhite(0.12, 0.22) * Pseg(Pseq([0.5, 1, 0.5], inf), Pwhite(8, 16), \sin),
    ).play(clock);

    // Industrial noise sweeps
    Pbind(
        \instrument, \bs_noise,
        \dur, Pwrand([0.5, 1, 2], [0.3, 0.4, 0.3], inf),
        \amp, Pwhite(0.02, 0.07) * Pwrand([1, 0], [0.25, 0.75], inf),
    ).play(clock);

    "--- BLACKSITE :: 132 BPM ---".postln;
    "--- Ctrl+. to stop ---".postln;
});
)
