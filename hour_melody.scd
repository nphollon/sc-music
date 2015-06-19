(
// the arg direct will control the proportion of direct to processed signal
SynthDef("tutorial-DecayPink", { arg outBus = 0, effectBus, direct = 0.5;
    var source;
    // Decaying pulses of PinkNoise. We'll add reverb later.
    source = Decay2.ar(Impulse.ar(1, 0.25), 0.01, 0.2, PinkNoise.ar);
    // this will be our main output
    Out.ar(outBus, source * direct);
    // this will be our effects output
    Out.ar(effectBus, source * (1 - direct));
}).add;

SynthDef("tutorial-DecaySin", { arg outBus = 0, effectBus, direct = 0.5, freq, beat;
    var source;
    // Decaying pulses of a modulating sine wave. We'll add reverb later.
	    source = Decay2.ar(Impulse.ar(beat, 0.25), 0.3, 1, SinOsc.ar(freq, mul:0.5));
    // this will be our main output
    Out.ar(outBus, source * direct);
    // this will be our effects output
    Out.ar(effectBus, source * (1 - direct));
}).add;

SynthDef("tutorial-Reverb", { arg outBus = 0, inBus;
    var input;
    input = In.ar(inBus, 1);

    // a low-rent reverb
    // aNumber.do will evaluate its function argument a corresponding number of times
    // {}.dup(n) will evaluate the function n times, and return an Array of the results
    // The default for n is 2, so this makes a stereo reverb
    16.do({ input = AllpassC.ar(input, 0.04, { Rand(0.001,0.04) }.dup, 3)});

    Out.ar(outBus, input);
}).add;

b = Bus.audio(s,1); // this will be our effects bus
)

(
var dingDong, note;
dingDong = { |freq,beat| Synth("tutorial-DecaySin", [\effectBus, b, \freq, freq, \beat, beat]); };
note = { |degree| 2**(degree/12) * 400; };

x = Synth.new("tutorial-Reverb", [\inBus, b]);
dingDong.value(note.value(0), 0.6);
dingDong.value(note.value(5), 0.2703);
dingDong.value(note.value(-5), 0.43);
dingDong.value(note.value(-10), 0.67);
dingDong.value(note.value(-15), 0.273);
dingDong.value(note.value(10), 0.41);

dingDong.value(note.value(0), 0.16);
dingDong.value(note.value(5), 0.12703);
dingDong.value(note.value(-5), 0.143);
dingDong.value(note.value(-10), 0.167);
dingDong.value(note.value(-15), 0.1273);
dingDong.value(note.value(10), 0.141);
)

