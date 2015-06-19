(
s.reboot;
t = TempoClock.default;
)
(
SynthDef(\stac, {
	arg outBus = 0, inBus, sustain = 1, release = 1;
	var signal, envelope;
	envelope = Env.linen(sustainTime: sustain, releaseTime: release);
	signal = In.ar(inBus) * EnvGen.kr(envelope, doneAction: 2);
    Out.ar(outBus, signal ! 2);
}).add;

SynthDef(\chime, {
	arg freq = 440, outBus = 0, edge = 0.5, fuzz = 0.05;
	var signal, tone, buzz, scratch;
	tone = SinOsc.ar(freq, mul: 1 - fuzz - edge);
	buzz = Saw.ar(freq * 2, mul: edge);
	scratch = PinkNoise.ar(fuzz);
	signal = tone + buzz + scratch;
	Out.ar(outBus, signal);
}).add;

[~driver, ~sources, ~effects, ~bus].free;

~sources = Group.new;
~effects = Group.after(~sources);
~bus = Bus.audio(s, 1);
~driver = Synth(\chime, [\outBus, ~bus, \edge, 0.2, \fuzz, 0.05], ~sources);
t.tempo = 4
)

(
var midi, dur, melody;

midi = Pseq([60, 60, 72, 71, 67]).asStream;
dur = Pseq([1, 1, 1, 1, 1]).asStream;

melody = Routine({
	var delta;
	while { delta = dur.next; delta.notNil; }
	{
		~driver.set(\freq, midi.next.midicps);
		Synth(\stac, [\inBus, ~bus, \sustain, 0.2, \release, 0.5], ~effects);
		delta.yield;
	}
}).loop(t, quant: 1);
)
