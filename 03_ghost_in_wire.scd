// GHOST IN THE WIRE — glitchy ambient techno, 116 BPM
// Granular ghosts, broken transmissions, spectral drones
(
s.waitForBoot({
    var clock = TempoClock.new(116/60);

    SynthDef(\gw_kick, { |out=0, amp=0.7|
        var env = EnvGen.kr(Env.perc(0.001, 0.6, 1, -5), doneAction: 2);
        var penv = EnvGen.kr(Env([100, 44, 40], [0.015, 0.12], [-4, -2]));
        var sig = SinOsc.ar(penv) * env;
        sig = LPF.ar((sig * 1.3).tanh, 200) * amp;
        Out.ar(out, sig ! 2);
    }).add;

    SynthDef(\gw_grain, { |out=0, freq=800, amp=0.08, pan=0|
        var env = EnvGen.kr(Env.perc(0.005, Rand(0.02, 0.12), 1, -6), doneAction: 2);
        var sig = SinOsc.ar(freq * LFNoise2.kr(40).range(0.98, 1.02));
        sig = sig * env * amp;
        Out.ar(out, Pan2.ar(sig, pan));
    }).add;

    SynthDef(\gw_spectral, { |out=0, freq=200, amp=0.05, gate=1|
        var env = EnvGen.kr(Env.asr(6, 1, 8), gate, doneAction: 2);
        var freqs = Array.fill(6, { |i| freq * (i + 1) * LFNoise2.kr(Rand(0.01, 0.04)).range(0.99, 1.01) });
        var amps = Array.fill(6, { |i| amp / (i + 1).squared });
        var sig = Mix(SinOsc.ar(freqs, 0, amps));
        sig = LPF.ar(sig, LFNoise1.kr(0.03).exprange(150, 2000));
        sig = sig * env;
        Out.ar(out, sig ! 2);
    }).add;

    SynthDef(\gw_radio, { |out=0, freq=3000, amp=0.06|
        var env = EnvGen.kr(Env.linen(0.1, Rand(0.3, 1.5), 0.3, 1, -3), doneAction: 2);
        var sig = BPF.ar(Crackle.ar(1.85), freq, 0.02) * 30;
        sig = sig + (SinOsc.ar(freq * LFNoise0.kr(8).range(0.95, 1.05)) * 0.1);
        sig = sig * env * amp;
        sig = FreeVerb.ar(sig, 0.9, 0.95, 0.2);
        Out.ar(out, Pan2.ar(sig, LFNoise2.kr(0.3).range(-1, 1)));
    }).add;

    SynthDef(\gw_hat, { |out=0, amp=0.15|
        var env = EnvGen.kr(Env.perc(0.001, 0.02, 1, -16), doneAction: 2);
        var sig = BPF.ar(GrayNoise.ar, 10000, 0.3) * env * amp;
        Out.ar(out, sig ! 2);
    }).add;

    SynthDef(\gw_pulse, { |out=0, freq=60, amp=0.15|
        var env = EnvGen.kr(Env.perc(0.001, 0.25, 1, -8), doneAction: 2);
        var sig = Pulse.ar(freq, 0.5) + Pulse.ar(freq * 1.005, 0.5);
        sig = LPF.ar(sig * 0.5, 300) * env * amp;
        Out.ar(out, sig ! 2);
    }).add;

    s.sync;

    // Kick: muffled, deep, slightly irregular
    Pbind(
        \instrument, \gw_kick,
        \dur, Pwrand([1, Pseq([0.75, 1.25])], [0.85, 0.15], inf),
        \amp, Pwhite(0.6, 0.75),
    ).play(clock);

    // Sub pulse: octave below kick, intermittent
    Pbind(
        \instrument, \gw_pulse,
        \dur, Pseq([1, 1, Rest(1), 1], inf),
        \freq, Pxrand([36, 38, 40].midicps, inf),
        \amp, Pwhite(0.1, 0.18) * Pwrand([1, 0], [0.6, 0.4], inf),
    ).play(clock);

    // Hat: sparse and dry
    Pbind(
        \instrument, \gw_hat,
        \dur, 0.5,
        \amp, Pif(Pfunc({ 0.4.coin }), Pwhite(0.08, 0.18), 0),
    ).play(clock);

    // Grain cloud: scattered digital particles
    Pbind(
        \instrument, \gw_grain,
        \dur, Pwhite(0.05, 0.2),
        \freq, Pwhite(1200, 8000),
        \amp, Pwhite(0.01, 0.07) * Pif(Pfunc({ 0.25.coin }), 1, 0),
        \pan, Pwhite(-1.0, 1.0),
    ).play(clock);

    // Spectral drone: harmonic series ghost
    Pbind(
        \instrument, \gw_spectral,
        \freq, Pxrand([80, 90, 100, 120], inf),
        \dur, Pwhite(16, 32),
        \amp, 0.04,
        \legato, 1.2,
    ).play(clock);

    // Broken radio transmissions
    Pbind(
        \instrument, \gw_radio,
        \dur, Pwhite(4, 12),
        \freq, Pwhite(1500, 6000),
        \amp, Pwhite(0.03, 0.07),
    ).play(clock);

    "--- GHOST IN THE WIRE :: 116 BPM ---".postln;
    "--- Ctrl+. to stop ---".postln;
});
)
