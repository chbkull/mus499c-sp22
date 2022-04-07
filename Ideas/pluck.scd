(
s.waitForBoot({

	s.newBusAllocators;
	~bus = ();
	~bus.rev = Bus.audio(s, 2);
	~bus.main = 0;

	SynthDef.new(\plucky, {
		var freq = \freq.kr(440);
		var sig;
		sig = Pluck.ar(
			WhiteNoise.ar(0.1!2),
			Dust.kr(\taps.kr(0)),
			freq.reciprocal,
			freq.reciprocal,
			\decaytime.kr(1.0),
			\coef.kr(0.5),
		);
		sig = RLPF.ar(sig, \lpf.kr(20000), 1.0);
		sig = RHPF.ar(sig, \hpf.kr(20), 1.0);
		sig = sig * Env([0, 1, 1, 0], [\atk.kr(0.01), \sus.kr(0.5), \rel.kr(0.01)], [\sine, \lin, \sine]).ar(doneAction: Done.freeSelf);
		sig = Balance2.ar(sig[0], sig[1], \pan.kr(0));
		sig = sig * \amp.kr(1.0);

		Out.ar(\out.ar(0), sig);
	}).add;

	// reverb from Prof. Fieldsteel
	SynthDef(\reverb, {
		arg in=0, out=0, mix=1, fb=0.8;
		var sig, wet;
		sig = In.ar(in, 2);
		wet = LocalIn.ar(2) + sig; //read from local bus
		wet = DelayN.ar(wet, 0.03, 0.03);
		5.do({ |n|
			var del, coef, dec;
			del = {Rand(0.1/(n+2), 0.1/(n+1))}!2;
			coef = Rand(0.6, 0.75);
			dec = del / (log10(coef)/3.neg);
			wet = AllpassN.ar(wet, 0.1, del, dec);
		});
		LocalOut.ar(wet * fb); //apply feedback coefficient write to local bus
		wet = LPF.ar(wet, \lpf.kr(20000));
		sig = sig.blend(wet, mix.varlag(0.3));
		Out.ar(out, sig);
	}).add;

	s.sync;

	~cleanup = {
		ServerTree.removeAll;
		ServerQuit.removeAll;
		ServerBoot.removeAll;
	};

	~makeNodes = {
		~groups = ();
		~groups.fx = Group.new;

		~rev = Synth(\reverb, [\in, ~bus.rev, \out, ~bus.main, \fb, 0, \mix, 0.3], ~groups.fx);
	};

	ServerQuit.add(~cleanup);
	ServerTree.add(~makeNodes);
	ServerTree.run;
});
)

x = Synth(\plucky, [\coef, 0.25]);

(
Pbindef(\leadplucks,
	\instrument, \plucky,
	\type, Pwrand([\note, \rest], [0.25, 0.75], inf),
	\midinote, Pfunc({ Array.fill(8, { rrand(60, 72) }).nearestInScale(Scale.minor.degrees) }),
	\strum, Pwrand([2, 4, 8, 16], [2, 4, 8, 16].reciprocal.normalizeSum, inf).reciprocal,
	\taps, 4.0,
	\pan, Pwhite(-0.5, 0.5),
	\atk, 0.01,
	\rel, 0.1,
	\dur, 0.5,
	\amp, 1.5,
	\coef, 0.9,
	\out, 0,
);

Pbindef(\bassarp,
	\instrument, \plucky,
	\midinote, Pfunc({ ((Array.fill(4, { rrand(28, 56) }).nearestInScale(Scale.minorPentatonic.degrees).sort.reverse)!(rrand(1, 4))).flat }),
	\strum, Prand([2, 4, 8], inf).reciprocal,
	\dur, 2.0,
	\decay, 0.1,
	\amp, 1.5,
	\coef, 0.9,
	\lpf, 1000,
	\out, 0,
);

Pbindef(\chordpad,
	\instrument, \plucky,
	\midinote, Pfunc({(rrand(36, 48) +.x #[0, 5, 7, 10, 12]).nearestInScale(Scale.minor.degrees)}),
	\taps, 400,
	\pan, Pwhite(-0.25, 0.25, inf),
	\atk, 2.0,
	\sus, 4.0,
	\rel, 2.0,
	\lpf, 1000,
	\dur, 7.0,
	\amp, 0.25,
	\coef, 0.8,
	\out, 0,
);
)

Pbindef(\leadplucks).play;
Pbindef(\leadplucks).stop;

Pbindef(\bassarp).play;
Pbindef(\bassarp).stop;

Pbindef(\chordpad).play;
Pbindef(\chordpad).stop;
