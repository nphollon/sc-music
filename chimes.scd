(

var fatfinger, note;

SynthDef("decay", {
	arg inBus, beat = 1;
    var source = Decay2.ar(Impulse.ar(beat, 0.25), 0.1, 1, In.ar(inBus));
    Out.ar(outBus, source);
}).add;

fatfinger = { arg degree, freq = 440, mod = 1, mul = 1;
	var pitch, offset, mix, weight;
	mix = 0.7;
	weight = -0.1;

	offset = Rand(-1,1) * weight * mod;
	pitch = note.value(degree + offset, freq);


	Saw.ar(pitch, mix * mul) + SinOsc.ar(pitch, Rand.new, (1 - mix) * mul);
};

note = { arg degree, fundamental=440;
	2 ** (degree/12) * fundamental;
};

SynthDef("interval", { arg outBus = 0, degree, freq = 440;
	Out.ar(outBus, { fatfinger.value(0, freq, 1.5, 0.5) + fatfinger.value(degree, freq, 1.5, 0.5) });
}).add;

b = Bus.audio(s);
c = Bus.audio(s);
d = Bus.audio(s);

x = Synth.new("interval", [\outBus, b, \degree, -10]);
Synth.after(x, "decay", [\inBus, b, \beat, 2]);

y = Synth.new("interval", [\outBus, c, \degree, 3, \freq, note.value(-5)]);
Synth.after(y, "decay", [\inBus, c, \outBus, 1, \beat, 2.1]);

z = Synth.new("interval", [\outBus, d, \degree, -7, \freq, note.value(19)]);
Synth.after(z, "decay", [\inBus, d, \outBus, 1, \beat, 0.47 ]);
)
