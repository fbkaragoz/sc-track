(
// IMPERIAL MINIMAL (no 'var' anywhere) — 128 BPM
// Evaluate whole block. Ctrl+. stops.

s.waitForBoot({

    s.latency = 0.05;

    ~bpm   = 128;
    ~clock = TempoClock.new(~bpm/60);
    ~fxBus = Bus.audio(s, 2);

    // ---- FX ----
    SynthDef(\impx, { |in=0, out=0|
        ~sig = In.ar(in, 2);

        ~del = CombL.ar(~sig, 1.0, [0.375, 0.5], 5.5);
        ~del = LPF.ar(~del, LFNoise1.kr(0.08).exprange(700, 5000));
        ~del = HPF.ar(~del, 90);

        ~verb = FreeVerb2.ar(~sig[0], ~sig[1], mix: 0.18, room: 0.55, damp: 0.35);
        ~verb = HPF.ar(~verb, 120);

        ~mix = (~sig * 0.85) + (~del * 0.38) + (~verb * 0.35);
        ~mix = Compander.ar(~mix, ~mix, 0.35, 1, 0.35, 0.01, 0.12);

        Out.ar(out, Limiter.ar(~mix, 0.95));
    }).add;

    // ---- DRUMS ----
    SynthDef(\impKick, { |out=0, amp=0.9|
        ~env  = EnvGen.kr(Env.perc(0.001, 0.42, 1, -6), doneAction: 2);
        ~penv = EnvGen.kr(Env([150, 52, 45], [0.012, 0.11], [-6, -2]));
        ~body = SinOsc.ar(~penv) * 1.2;
        ~click = HPF.ar(WhiteNoise.ar, 6500) * EnvGen.kr(Env.perc(0.001, 0.02, 1, -8)) * 0.25;
        ~sig2 = (~body + ~click).tanh * ~env * amp;
        Out.ar(out, ~sig2 ! 2);
    }).add;

    SynthDef(\impHat, { |out=0, amp=0.15, tone=9000, decay=0.07, sendBus=0|
        ~env  = EnvGen.kr(Env.perc(0.001, decay, 1, -10), doneAction: 2);
        ~sig2 = HPF.ar(WhiteNoise.ar, tone) * ~env;
        ~sig2 = BPF.ar(~sig2, tone * 0.8, 0.25) + (~sig2 * 0.35);
        ~sig2 = ~sig2 * amp;
        Out.ar(sendBus, ~sig2!2 * 0.35);
        Out.ar(out, ~sig2!2);
    }).add;

    SynthDef(\impClap, { |out=0, amp=0.22, sendBus=0|
        ~env  = EnvGen.kr(Env([0,1,0.6,0],[0.005,0.06,0.22],[-6,-2,-8]), doneAction:2);
        ~n    = HPF.ar(WhiteNoise.ar, 1200);
        ~sig2 = (BPF.ar(~n, 2000, 0.7) + BPF.ar(~n, 3600, 0.5)) * ~env * amp;
        Out.ar(sendBus, ~sig2!2 * 0.45);
        Out.ar(out, ~sig2!2);
    }).add;

    SynthDef(\impRim, { |out=0, amp=0.16, sendBus=0|
        ~env  = EnvGen.kr(Env.perc(0.001, 0.03, 1, -10), doneAction: 2);
        ~sig2 = (SinOsc.ar(1500) * 0.55 + BPF.ar(WhiteNoise.ar, 4200, 0.15) * 0.35) * ~env * amp;
        Out.ar(sendBus, ~sig2!2 * 0.6);
        Out.ar(out, ~sig2!2);
    }).add;

    // ---- BASS ----
    SynthDef(\impBass, { |out=0, freq=55, amp=0.16, gate=1, sendBus=0, cut=120, res=0.2|
        ~env  = EnvGen.kr(Env.asr(0.01, 1, 0.15), gate, doneAction: 2);
        ~aenv = EnvGen.kr(Env.perc(0.001, 0.12, 1, -4));
        ~sig2 = (Saw.ar(freq * [1, 1.005]).sum * 0.35) + (SinOsc.ar(freq) * 0.55);
        ~sig2 = RLPF.ar(~sig2, (cut + (~aenv * 900)).clip(60, 6000), res.clip(0.05, 0.95));
        ~sig2 = HPF.ar(~sig2, 28);
        ~sig2 = (~sig2 * 1.6).tanh * ~env * amp;
        Out.ar(sendBus, ~sig2!2 * 0.18);
        Out.ar(out, ~sig2!2);
    }).add;

    // ---- IMPERIAL STAB ----
    SynthDef(\impStab, { |out=0, freq=220, amp=0.08, gate=1, sendBus=0, bright=1800|
        ~env  = EnvGen.kr(Env.perc(0.003, 0.55, 1, -5), gate, doneAction: 2);
        ~sig2 = (VarSaw.ar(freq * [0.997, 1.0, 1.006, 2.0], 0, 0.22).sum * 0.22)
              + (Pulse.ar(freq * [0.5, 1.0], 0.45).sum * 0.12);
        ~sig2 = BPF.ar(~sig2, freq * 2.6, 0.25) + (~sig2 * 0.55);
        ~sig2 = LPF.ar(~sig2, bright.clip(600, 9000));
        ~sig2 = ~sig2 * ~env * amp;
        ~sig2 = Splay.ar([~sig2, DelayC.ar(~sig2, 0.02, 0.012)], 0.25);
        Out.ar(sendBus, ~sig2 * 0.55);
        Out.ar(out, ~sig2);
    }).add;

    // ---- DUST ----
    SynthDef(\impDust, { |out=0, amp=0.05, sendBus=0|
        ~trig = Dust.kr(2);
        ~env  = EnvGen.kr(Env.perc(0.001, 0.18, 1, -7), ~trig);
        ~sig2 = Crackle.ar(1.8) * ~env;
        ~sig2 = BPF.ar(~sig2, TExpRand.kr(250, 4500, ~trig), 0.12);
        ~sig2 = Pan2.ar(~sig2, LFNoise1.kr(0.7).range(-0.6, 0.6)) * amp;
        Out.ar(sendBus, ~sig2 * 0.9);
        Out.ar(out, ~sig2 * 0.35);
    }).add;

    s.sync;

    Synth.tail(s, \impx, [\in, ~fxBus, \out, 0]);

    // section clock (16 bars per section)
    ~bars = 0; ~sec = 0;

    Pbind(\type, \rest, \dur, 4, \do, Pfunc({
        ~bars = ~bars + 1;
        ~sec = (~bars / 16).floor % 5;
    })).play(~clock);

    // Kick
    Pbind(
        \instrument, \impKick,
        \dur, 1,
        \amp, Pfunc({ if(~sec == 3) { (0.22.coin).if(0.9, 0.0) } { 0.9 } }) * Pseq([1.0, 0.92, 1.0, 0.95], inf)
    ).play(~clock);

    // Hats (16ths)
    Pbind(
        \instrument, \impHat,
        \dur, 0.25,
        \decay, Pwhite(0.03, 0.08),
        \tone, Pwhite(7000, 10500),
        \amp, Pfunc({
            ~base = if(~sec == 0) { 0.06 } { if(~sec == 1) { 0.11 } { if(~sec == 2) { 0.13 } { if(~sec == 3) { 0.07 } { 0.12 }}}};
            ((~base * (0.75 + 0.5.rand)) * (0.75.coin).if(1,0))
        }),
        \sendBus, ~fxBus
    ).play(~clock);

    // Off hats
    Pbind(
        \instrument, \impHat,
        \dur, 0.5,
        \decay, Pwhite(0.09, 0.16),
        \tone, Pwhite(6000, 9000),
        \amp, Pfunc({ if(~sec == 0) { 0.0 } { (0.55.coin).if(0.14, 0.0) } }),
        \sendBus, ~fxBus
    ).play(~clock);

    // Clap
    Pbind(
        \instrument, \impClap,
        \dur, Pseq([Rest(1), 1], inf),
        \amp, Pfunc({ if(~sec == 0) { 0.0 } { if(~sec == 3) { 0.12 } { 0.22 } } }),
        \sendBus, ~fxBus
    ).play(~clock);

    // Rim
    Pbind(
        \instrument, \impRim,
        \dur, 0.25,
        \amp, Pfunc({
            ~p = if(~sec == 2) { 0.32 } { if(~sec == 1) { 0.22 } { if(~sec == 4) { 0.26 } { 0.16 }}};
            (~p.coin).if(rrand(0.08, 0.16), 0.0)
        }),
        \sendBus, ~fxBus
    ).play(~clock);

    // Bass
    Pbind(
        \instrument, \impBass,
        \dur, Pseq([0.5, 0.5, 1, 1, 0.5, 0.5], inf),
        \freq, Pfunc({
            ~root = [43, 45, 47, 50].choose.midicps;
            if((~sec == 2) and: {0.18.coin}) { ~root * 2 } { ~root }
        }),
        \cut, Pfunc({ if(~sec == 3) { rrand(80, 140) } { rrand(110, 220) } }),
        \res, Pwhite(0.12, 0.35),
        \amp, Pfunc({ if(~sec == 0) { 0.0 } { if(~sec == 3) { (0.35.coin).if(0.12, 0.0) } { 0.16 } } }),
        \sendBus, ~fxBus,
        \legato, Pwhite(0.7, 1.05)
    ).play(~clock);

    // Imperial stabs
    Pbind(
        \instrument, \impStab,
        \dur, Pwrand([2, 4, 8], [0.55, 0.35, 0.10], inf),
        \freq, Pfunc({ [50, 53, 55, 57].choose.midicps }),
        \bright, Pfunc({ if(~sec == 2) { rrand(1400, 2600) } { rrand(900, 1900) } }),
        \amp, Pfunc({
            if(~sec == 2) { (0.55.coin).if(rrand(0.06, 0.10), 0.0) }
            { if(~sec == 4) { (0.25.coin).if(rrand(0.05, 0.08), 0.0) } { 0.0 } }
        }),
        \sendBus, ~fxBus
    ).play(~clock);

    // Dust
    Pbind(
        \instrument, \impDust,
        \dur, 1,
        \amp, Pfunc({ if(~sec == 3) { rrand(0.04, 0.07) } { rrand(0.02, 0.05) } }),
        \sendBus, ~fxBus
    ).play(~clock);

    ("--- IMPERIAL MINIMAL :: " ++ ~bpm ++ " BPM ---").postln;
    "--- Ctrl+. to stop ---".postln;
});
)