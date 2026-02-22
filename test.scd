{
	var freq = LFNoise0.kr(4).exprange(200, 800);
    SinOsc.ar(freq, 0, 0.2)
}.play