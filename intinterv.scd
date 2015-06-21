s.reboot;
TempoClock.default.tempo = 11

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
	buzz = Pulse.ar(freq * 2, mul: edge);
	scratch = PinkNoise.ar(fuzz);
	signal = (tone + buzz + scratch) * 0.3;
	Out.ar(outBus, signal);
}).add;

[~sources, ~effects, ~melodyBus].free;

~sources = Group.new;
~effects = Group.after(~sources);
~melodyBus = Bus.audio(s, 1);
~bassBus = Bus.audio(s, 1);
)

(
~driver = Synth(\chime, [\outBus, ~melodyBus, \edge, 0.5, \fuzz, 0.2], ~sources);
~harmony = Synth(\chime, [\outBus, ~melodyBus, \edge, 0.5, \fuzz, 0.1], ~sources);
~bass = Synth(\chime, [\outBus, ~bassBus, \edge, 0.4, \fuzz, 0.0], ~sources)
)
~driver.free; ~harmony.free; ~bass.free;

(
var notes, bassNotes;

notes = Pseq([
	[64, 60, 2.67], [64, 60, 1.33], [62, 59, 2], [64, 60, 4], [64, 60, 2], [62, 59, 2], [64, 60, 2],
	[69, 64, 2.67], [64, 60, 1.33], [62, 59, 2], [64, 60, 4], [64, 60, 2], [62, 59, 2], [60, 55, 2]
	],inf).asStream;

bassNotes = Pseq([
	[48, 4], [48, 4], [48, 4], [48, 4],
	[45, 4], [45, 4], [45, 4], [45, 4],
	[41, 4], [41, 4], [40, 4], [40, 4],
	[45, 4], [45, 4], [45, 4], [45, 4],
],inf).asStream;

g = Routine({
	var note;
	while { note = notes.next; note.notNil; }
	{
		~driver.set(\freq, note[0].midicps);
		~harmony.set(\freq, note[1].midicps);
		Synth(\stac, [\inBus, ~melodyBus, \sustain, 0.1, \release, 0.05], ~effects);
		note[2].yield;
	}
}).play(TempoClock.default, quant: TempoClock.default.beats);

h = Routine({
	var note;
	while { note = bassNotes.next; note.notNil; }
	{
		~bass.set(\freq, (note[0]).midicps);
		Synth(\stac, [\inBus, ~bassBus, \sustain, 0.5, \release, 0.1], ~effects);
		note[1].yield;
	}
}).play(TempoClock.default, quant: TempoClock.default.beats);
)
g.stop; h.stop;