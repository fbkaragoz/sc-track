// NEON DISTRICT — acid-laced cyberpunk, 126 BPM
// Squelchy 303 bass, glitchy percussion, dystopian pads
(
s.boot;
g = Group.basicNew(s); // create without sending
s.queryAllNodes;
g.free;

s.waitForBoot({
	var clock = TempoClock.new(126/90);

	SynthDef(\nd_kick, { |out=0, amp=0.85|
		var env = EnvGen.kr(Env.perc(0.001, 0.35, 1, -7), doneAction: 2);
		var penv = EnvGen.kr(Env([200, 52, 48], [0.008, 0.07], [-6, -3]));
		var sig = SinOsc.ar(penv) + SinOsc.ar(penv * 0.5, 0, 0.3);
		sig = (sig * 1.6).tanh * env * amp;
		Out.ar(out, sig ! 2);
	}).add;

	SynthDef(\nd_acid, { |out=0, freq=60, amp=0.3, cutoff=800, res=0.35, decay=0.2|
		var env = EnvGen.kr(Env.perc(0.001, decay, 1, -5), doneAction: 2);
		var fenv = EnvGen.kr(Env.perc(0.001, decay * 0.6, 1, -4));
		var sig = LFSaw.ar(freq, 0, amp);
		sig = RLPF.ar(sig, cutoff + (fenv * cutoff * 3), res);
		sig = (sig * 2).tanh * env;
		Out.ar(out, Pan2.ar(sig, LFNoise1.kr(2).range(-0.3, 0.3)));
	}).add;

	SynthDef(\nd_hat, { |out=0, amp=0.2, decay=0.035|
		var env = EnvGen.kr(Env.perc(0.001, decay, 1, -14), doneAction: 2);
		var sig = HPF.ar(ClipNoise.ar, 8000) * env * amp;
		Out.ar(out, sig ! 2);
	}).add;

	SynthDef(\nd_glitch, { |out=0, freq=1200, amp=0.1|
		var env = EnvGen.kr(Env.perc(0.001, 0.04, 1, -8), doneAction: 2);
		var sig = Pulse.ar(freq, LFNoise0.kr(30).range(0.1, 0.9));
		sig = BPF.ar(sig, freq * 1.2, 0.2) * env * amp;
		sig = sig + (CombL.ar(sig, 0.1, Rand(0.02, 0.06), 0.08) * 0.3);
		Out.ar(out, Pan2.ar(sig, Rand(-0.8, 0.8)));
	}).add;

	SynthDef(\nd_pad, { |out=0, freq=120, amp=0.07, gate=1|
		var env = EnvGen.kr(Env.asr(4, 1, 5), gate, doneAction: 2);
		var mod = LFNoise2.kr(0.05).range(0.995, 1.005);
		var sig = LFTri.ar([freq * mod, freq * 1.003, freq * 2.001], 0, amp/3).sum;
		sig = LPF.ar(sig, LFNoise1.kr(0.08).exprange(200, 900));
		sig = FreeVerb.ar(sig, 0.7, 0.85, 0.3);
		sig = sig * env;
		Out.ar(out, sig ! 2);
	}).add;

	SynthDef(\nd_clap, { |out=0, amp=0.25|
		var env = EnvGen.kr(Env.new([0, 1, 0.3, 0.8, 0], [0.001, 0.01, 0.002, 0.15], [-4, -2, -4, -6]), doneAction: 2);
		var sig = BPF.ar(WhiteNoise.ar, 1800, 0.6) * env * amp;
		sig = sig + (CombL.ar(sig, 0.1, 0.03, 0.06) * 0.15);
		Out.ar(out, sig ! 2);
	}).add;

	s.sync;

	// Kick: four on the floor
	Pbind(
		\instrument, \nd_kick,
		\dur, 1,
		\amp, Pseq([0.85, Pwrand([0.7, 0.85], [0.3, 0.7], 1), 0.85, 0.8], inf),
	).play(clock);

	// Acid bass: squelchy 303 line
	Pbind(
		\instrument, \nd_acid,
		\dur, Pwrand([0.25, 0.5, Pseq([0.125, 0.125])], [0.5, 0.3, 0.2], inf),
		\freq, Pxrand([48, 48, 52, 55, 60, 64].midicps, inf),
		\cutoff, Pseg(Pwhite(400, 3500), Pwhite(4, 16), \exp, inf),
		\res, Pwhite(0.15, 0.4),
		\decay, Pwhite(0.08, 0.35),
		\amp, Pwhite(0.2, 0.35),
	).play(clock);

	// Hats: jittery 16ths
	Pbind(
		\instrument, \nd_hat,
		\dur, 0.25,
		\amp, Pif(Pfunc({ 0.65.coin }), Pwhite(0.08, 0.22), 0),
		\decay, Pwhite(0.02, 0.07),
	).play(clock);

	// Clap on 2 and 4
	Pbind(
		\instrument, \nd_clap,
		\dur, Pseq([Rest(1), 1, Rest(1), 1], inf),
		\amp, Pwhite(0.2, 0.3),
	).play(clock);

	// Glitch hits: scattered digital debris
	Pbind(
		\instrument, \nd_glitch,
		\dur, Pwrand([0.25, 0.5, 0.75, 1.5], [0.2, 0.3, 0.3, 0.2], inf),
		\freq, Pwhite(800, 4000),
		\amp, Pwhite(0.04, 0.12) * Pwrand([1, 0], [0.35, 0.65], inf),
	).play(clock);

	// Dystopian pad: slow shifting
	Pbind(
		\instrument, \nd_pad,
		\freq, Pxrand([55, 58, 62, 65].midicps, inf),
		\dur, Pwhite(12, 24),
		\amp, 0.07,
		\legato, 1.2,
	).play(clock);

	"--- NEON DISTRICT :: 126 BPM ---".postln;
	"--- Ctrl+. to stop ---".postln;
});
)
