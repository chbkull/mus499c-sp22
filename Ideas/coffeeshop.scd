s.boot;

Buffer.freeAll;

(
var audiopath;
audiopath = PathName(thisProcess.nowExecutingPath).parentPath ++ "../SoundLibrary/Cafe";
~buf = (1..3).collect({
	arg n;
	Buffer.readChannel(s, audiopath ++ "/Murmurs" ++ n ++ ".wav", channels:[0, 1])
})
)

x = ~buf[2].play;
x.free;

(
SynthDef.new(\sampler2, {
	arg buf=0, rate=1, spos=0, loop=0, atk=0.01, sus=1, rel=0.01,
	lp=20000, hp=20, pan=0, amp=1, out=0, auxamp=1, auxout=nil;
	var sig, env;
	sig = PlayBuf.ar(
		2, buf, BufRateScale.ir(buf) * rate,
		startPos: spos, loop: loop
	);
	sig = LPF.ar(sig, lp);
	sig = HPF.ar(sig, hp);

	env = EnvGen.ar(
		Env.new([0,1,1,0],[atk,sus,rel],[1,0,-1]),
		doneAction:2
	);
	sig = sig * env;
	sig = Balance2.ar(sig[0], sig[1], pan);
	Out.ar(out, sig * amp);
	Out.ar(auxout, sig * auxamp);
}).add;

SynthDef.new(\chainRingz, {
	var in = \in.kr(nil);
	var freq = \freq.kr(440), bankamp = \bankamp.kr(0.1), ringtime = \ringtime.kr(0.5);
	var freqscale = \freqscale.kr(1.0, \freqscalelag.kr(1.0)), freqoffset = \freqoffset.kr(0.0, \freqoffsetlag.kr(1.0)), decayscale = \decayscale.kr(1.0);
	var atk = \atk.kr(0.1), sus = \sus.kr(1.0), rel = \rel.kr(0.1);
	var pan = \pan.kr(0), amp = \amp.kr(1.0), out = \out.kr(0);
	var sig, env;
	sig = Ringz.ar(
		In.ar(in, 2) * 0.005,
		freq * freqscale + freqoffset,
		ringtime * VarLag.kr(decayscale, \decayscalelag.kr(1.0), \decayscalecurve.kr(0)),
		bankamp
	);
	env = Env.linen(atk, sus, rel).ar(Done.freeSelf);
	sig = sig * env;
	sig = Balance2.ar(sig[0], sig[1], pan, amp);
	sig = sig * (44100 / SampleRate.ir);
	Out.ar(out, sig);
}).add;

SynthDef.new(\sampleRingz, {
	var buf = \buf.kr(0), rate = \rate.kr(1), spos = \spos.kr(0);
	var freq = \freq.kr(440), bankamp = \bankamp.kr(0.1), ringtime = \ringtime.kr(0.5);
	var freqscale = \freqscale.kr(1.0, \freqscalelag.kr(1.0)), freqoffset = \freqoffset.kr(0.0, \freqoffsetlag.kr(1.0)), decayscale = \decayscale.kr(1.0);
	var atk = \atk.kr(0.1), sus = \sus.kr(1.0), rel = \rel.kr(0.1);
	var pan = \pan.kr(0), amp = \amp.kr(1.0), out = \out.kr(0);
	var sig, env;
	sig = Ringz.ar(
		PlayBuf.ar(2, buf, BufRateScale.ir(buf) * rate, startPos: spos) * 0.005,
		freq * freqscale + freqoffset,
		ringtime * VarLag.kr(decayscale, \decayscalelag.kr(1.0), \decayscalecurve.kr(0)),
		bankamp
	);
	env = Env.linen(atk, sus, rel).ar(Done.freeSelf);
	sig = sig * env;
	sig = Balance2.ar(sig[0], sig[1], pan, amp);
	sig = sig * (44100 / SampleRate.ir); // See Ringz's documentation, but amplitude is dependent on sample rate
	Out.ar(out, sig);
}).add;

// Credit: Jonatan Liljedahl - https://sccode.org/1-e
SynthDef.new(\rainmaker, {
	var amp = \amp.kr(1.0), out = \out.kr(0);
	var auxamp = \auxamp.kr(0.0), auxout = \auxout.kr(nil);
	var sig;
	sig = tanh(
            3 * GVerb.ar(
                HPF.ar(
                    PinkNoise.ar(0.08+LFNoise1.kr(0.3,0.02))+LPF.ar(Dust2.ar(LFNoise1.kr(0.2).range(40,50)),7000),
                    400
                ),
                250,100,0.25,drylevel:0.3
            ) * Line.kr(0,1,10)
        );
	sig = sig + (
            GVerb.ar(
                LPF.ar(
                    10 * HPF.ar(PinkNoise.ar(LFNoise1.kr(3).clip(0,1)*LFNoise1.kr(2).clip(0,1) ** 1.8), 20)
                    ,LFNoise1.kr(1).exprange(100,2500)
                ).tanh,
               270,30,0.7,drylevel:0.5
            ) * Line.kr(0,0.7,30)
        );
	sig = sig * EnvGen.ar(Env([0.0, 1.0, 1.0, 0.4, 0.4, 0.2, 0.2, 0.0], [10, 49, 1, 50, 10, 150, 30]), doneAction: Done.freeSelf);
	sig = LPF.ar(sig, 5000);
	Out.ar(out, sig * amp);
	Out.ar(auxout, sig * auxamp);
}).add;
)

x = Synth(\rainmaker, [\amp, 0.5]);
x.free;

// 5 minutes, blending rain and the coffeeshop with resonators
(
var rain, ringz, coffeeshop, build, descend;
var degrees = Scale.minorPentatonic;
var counter = 0, maxEvents = 150;
var buildEvents = 30, upcounter = 0, buildInsertRate = 1;
var descendEvents = 30, downcounter = descendEvents, descendRemoveRate = 1;
var maxResonators = buildEvents / buildInsertRate;

s.newBusAllocators;

~sendGroup = Group.new(s, \addToTail);
~receiveGroup = Group.new(s, \addToTail);
~rawSend = Bus.audio(s, 2);

rain = Pbind(
	\instrument, \rainmaker,
	\numevents, Pseq([0], 1),
	\amp, 0.125,
	\auxamp, 1.25,
	\auxout, ~rawSend,
	\group, ~sendGroup,
	\addAction, \addToTail
);

ringz = Pbind(
	\instrument, \chainRingz,
	\type, Pwrand([\rest, \note], [0.5, 0.5], inf),
	\numevents, Pseq([0], 120),
	\in, ~rawSend,
	\degree, Prand(Scale.minorPentatonic, inf),
	\root, 5,
	\octave, Pwrand([4, 5, 6], [0.125, 0.75, 0.125], inf),
	\bankamp, 1.0,
	\ringtime, Env([0.0, 0.5, 0.0], [30, 30], [4, -4]).asPseg(),
	\atk, 2.5,
	\sus, 1.0,
	\rel, 0.5,
	\dur, 0.5,
	\pan, Pwhite(-0.5, 0.5),
	\amp, 0.75,
	\group, ~receiveGroup,
	\addAction, \addToTail
);

coffeeshop = Pbind(
	\instrument, \sampler2,
	\numevents, Pseq([0], 1),
	\buf, ~buf[2],
	\atk, 5,
	\sus, 50,
	\rel, 5,
	\amp, 0.2,
	\auxamp, 1.25,
	\auxout, ~rawSend,
	\group, ~sendGroup,
	\addAction, \addToTail
);

build = Pbind(
	\instrument, \sampleRingz,
	\numevents, Pseq([0], buildEvents),
	#[\buf, \spos], Pfunc({
		var buf = ~buf.choose;
		[buf, rrand(0, buf.numFrames - 1)];
	}),
	\rate, Pgauss(0.0, 3.0),
	#[\degree, \octave, \bankamp, \ringtime], Pfunc({
		var selectedPitches;
		upcounter = upcounter + 1;
		upcounter.postln;
		selectedPitches = Scale.minorPentatonic.at(Array.rand(maxResonators, 0, Scale.minorPentatonic.size - 1)).at(Array.series(min(ceil(upcounter / buildInsertRate), maxResonators)));
		selectedPitches.postln;
		[
			selectedPitches.sort.reverse,
			[3, 4, 5, 6, 7].at(Array.rand(selectedPitches.size, 0, degrees.size - 1)), // randomize octave
			Array.exprand(selectedPitches.size, 0.2, 0.3).sort.reverse,
			Array.exprand(selectedPitches.size, 0.6, 2).sort.reverse
		];
	}),
	\root, 5, // F
	\freqscale, Pwrand([2/3, 1.0, 1.5, 2.0], [0.05, 0.7, 0.2, 0.05], inf),
	\decayscale, Prand([Phprand(0.5, 2.5), Pmeanrand(2.5, 7.5), Plprand(7.5, 10.0)], inf),
	\atk, Pexprand(2.5, 10),
	\sus, Pexprand(5.0, 10),
	\rel, Pexprand(2.5, 5),
	\dur, 3.0,
	\pan, Pwhite(-0.5, 0.5),
	\amp, Pwhite(0.15, 0.35),
);

descend = Pbind(
	\instrument, \sampleRingz,
	\numevents, Pseq([0], descendEvents),
	#[\buf, \spos], Pfunc({
		var buf = ~buf.choose;
		[buf, rrand(0, buf.numFrames - 1)];
	}),
	\rate, Pgauss(0.0, 3.0),
	#[\degree, \octave, \bankamp, \ringtime], Pfunc({
		var selectedPitches;
		downcounter = downcounter - 1;
		downcounter.postln;
		selectedPitches = Scale.major.at(Array.rand(maxResonators, 0, Scale.major.size - 1)).at(Array.series(max(ceil(downcounter / descendRemoveRate), 1)));
		selectedPitches.postln;
		[
			selectedPitches.sort.reverse,
			[3, 4, 5, 6, 7].at(Array.rand(selectedPitches.size, 0, degrees.size - 1)), // randomize octave
			Array.exprand(selectedPitches.size, 0.2, 0.3).sort.reverse,
			Array.exprand(selectedPitches.size, 0.6, 2).sort.reverse
		];
	}),
	\root, 0, // C
	\freqscale, Pwrand([2/3, 1.0, 1.5, 2.0], [0.05, 0.7, 0.2, 0.05], inf),
	\decayscale, Prand([Phprand(2.5, 7.5), Pmeanrand(7.5, 10.0)], inf),
	\atk, Pexprand(2.5, 10),
	\sus, Pexprand(5.0, 10),
	\rel, Pexprand(2.5, 5),
	\dur, 3.0,
	\pan, Pwhite(-0.5, 0.5),
	\amp, Pwhite(0.15, 0.35),
);

~stream = Pseq([
	Ppar([rain, ringz]),
	Ppar([coffeeshop, ringz]),
	Ppar([build, ringz]),
	Ppar([descend, ringz]),
]).play;
)

// Best way to stop everything is to just Control + Period
~stream.stop;
