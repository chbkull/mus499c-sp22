(
s.waitForBoot({

	"synths.scd".loadRelative;

	Buffer.freeAll;

	~dir = PathName(thisProcess.nowExecutingPath).parentPath ++ "../SoundLibrary/BigMetalBowl";
	~bowls = (1..5).collect({
		arg n;
		Buffer.readChannel(s, ~dir ++ "/Resonate" ++ n ++ ".wav", channels:[0])
	});

	~dir = PathName(thisProcess.nowExecutingPath).parentPath ++ "../SoundLibrary/Cafe";
	~cafe = (1..3).collect({
		arg n;
		Buffer.readChannel(s, ~dir ++ "/Murmurs" ++ n ++ ".wav", channels:[0, 1])
	});

	s.sync;

	~trickleIn = Pbind(
		\instrument, \raindrop,
		\amp, 0.95,
		\dur, Pgeom(2, 0.95, 40),
		\pan, Pwhite(-0.5, 0.5),
	);

	~trickleOut = Pbind(
		\instrument, \raindrop,
		\amp, Pgeom(0.95, 0.97, 30),
		\dur, Pexprand(0.33, 1.5, 30),
		\pan, Pwhite(-0.5, 0.5),
	);

	~singingBowls = Pbind(
		\instrument, \sampler,
		\numevents, Pseq([0], 30),
		\buf, Pxrand(~bowls, inf),
		\spos, Pwhite(500, 41400),
		\rate, Prand(Scale.mixolydian.degrees, inf).midiratio,
		\sus, 1.0,
		\rel, 4.0,
		\dur, Plprand(0.75, 1.5, inf),
		\pan, Pwhite(-0.5, 0.5),
		\lp, 2500,
		\amp, 1.0
	);

	~scale = Scale.mixolydian;
	~buildEvents = 15;
	~upcounter = 0;
	~buildInsertRate = 2;
	~maxResonators = ~buildEvents * ~buildInsertRate;

	~ringzBuild = Pbind(
		\instrument, \sampleRingz,
		\numevents, Pseq([0], ~buildEvents),
		#[\buf, \spos], Pfunc({
			var buf = ~cafe.choose;
			[buf, rrand(0, buf.numFrames - 1)];
		}),
		\rate, Pgauss(0.0, 3.0),
		#[\degree, \octave, \bankamp, \ringtime], Pfunc({
			var selectedPitches;
			~upcounter = ~upcounter + 1;
			selectedPitches = ~scale.at(Array.rand(~maxResonators, 0, ~scale.size - 1)).at(Array.series(min(ceil(~upcounter * ~buildInsertRate), ~maxResonators)));
			[
				selectedPitches.sort.reverse,
				[3, 4, 5, 6, 7].at(Array.rand(selectedPitches.size, 0, 4)), // randomize octave
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
		\amp, Pwhite(0.20, 0.35),
	);

	~descendEvents = 15;
	~downcounter = ~descendEvents;
	~descendRemoveRate = 2;

	~ringzDescend = Pbind(
		\instrument, \sampleRingz,
		\numevents, Pseq([0], ~descendEvents),
		#[\buf, \spos], Pfunc({
			var buf = ~cafe.choose;
			[buf, rrand(0, buf.numFrames - 1)];
		}),
		\rate, Pgauss(0.0, 3.0),
		#[\degree, \octave, \bankamp, \ringtime], Pfunc({
			var selectedPitches;
			~downcounter = ~downcounter - 1;
			selectedPitches = ~scale.at(Array.rand(~maxResonators, 0, ~scale.size - 1)).at(Array.series(max(ceil(~downcounter * ~descendRemoveRate), 1)));
			[
				selectedPitches.sort.reverse,
				[3, 4, 5, 6, 7].at(Array.rand(selectedPitches.size, 0, 4)), // randomize octave
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
		\amp, Pwhite(0.20, 0.35),
	);

	~patterns = [];
	~synths = [];

	r = Routine {
		~patterns = ~patterns.add(~trickleIn.play);

		15.wait;

		~patterns = ~patterns.add(~trickleIn.play);
		~rainmaker = Synth(\rainmaker, [\atk, 30, \sus, 100, \rel, 75, \amp, 0.25]);
		~synths = ~synths.add(~rainmaker);

		10.wait;

		~patterns = ~patterns.add(~trickleIn.play);

		10.wait;
		~patterns = ~patterns.add(~trickleOut.play);
		5.wait;
		~patterns = ~patterns.add(~trickleOut.play);
		5.wait;
		~patterns = ~patterns.add(~trickleOut.play);

		35.wait;
		"Bowls".postln;
		~rainmaker.set(\amp, 0.2);
		~synths = ~synths.add(Synth(\sampler, [\buf, ~bowls[0], \spos, 500, \sus, 5.0, \rel, 1.0, \pan, 0, \amp, 1.0]));

		10.wait;
		~rainmaker.set(\amp, 0.15);
		~synths = ~synths.add(Synth(\sampler, [\buf, ~bowls[1], \spos, 500, \sus, 5.0, \rel, 1.0, \pan, -0.2, \amp, 1.0]));

		10.wait;
		~rainmaker.set(\amp, 0.1);
		~synths = ~synths.add(Synth(\sampler, [\buf, ~bowls[2], \spos, 500, \sus, 5.0, \rel, 1.0, \pan, 0.2, \amp, 1.0]));

		10.wait;
		~rainmaker.set(\amp, 0.05);
		~patterns = ~patterns.add(~singingBowls.play);

		30.wait;
		"Ringz".postln;
		~ringz = Pseq([~ringzBuild, ~ringzDescend]);
		~patterns = ~patterns.add(~ringz.play);

	}.play;
});
)

(
r.stop;
~patterns.do({
	arg n;
	n.stop;
});
~synths.do({
	arg n;
	n.free;
});
)

