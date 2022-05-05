// The Eye by Christopher Kull (~10:26 length)
(
s.waitForBoot({
	"synths.scd".loadRelative;

	Buffer.freeAll;

	// recursive sound library loading code from Prof. Fieldsteel
	~makeBuffers = { arg path, event, mono=true;
		var dir = PathName.new(path);
		var contents = dir.entries;

		if (contents.select({ |n| n.isFile }).size > 0)
		{
			var files, bufArray;
			files = contents.select({ |n| n.isFile });
			files = files.select({ |n|
				["aif", "aiff", "wav"].includesEqual(n.extension)
			});

			if (event[dir.folderName.asSymbol] != nil)
			{ "duplicate subfolder name ignored".warn; }
			{
				bufArray = files.collect({ |n|
					if(mono)
					{Buffer.readChannel(s, n.fullPath, channels:[0])}
					{Buffer.read(s, n.fullPath)}
				});
				event[dir.folderName.asSymbol] = bufArray;
			};
		};

		if (contents.select({ |n| n.isFolder }).size > 0)
		{
			var folders = contents.select({ |n| n.isFolder });
			folders.do({ |n| ~makeBuffers.(n.fullPath, event, mono) });
		};

		event;
	};

	b = ~makeBuffers.(PathName(thisProcess.nowExecutingPath).parentPath ++ "../SoundLibrary", ());

	Pbindef.clear;

	s.sync;

	s.newBusAllocators;
	~bus = ();
	~bus.rev = Bus.audio(s, 2);
	~bus.master = Bus.audio(s, 2);

	~cleanup = {
		ServerTree.removeAll;
		ServerQuit.removeAll;
	};

	~makeNodes = {
		~groups = ();
		~groups.fx = Group.new;

		~rev = Synth(\reverb, [\in, ~bus.rev, \out, ~bus.master, \fb, 0.1, \mix, 0.3], ~groups.fx);
		~master = Synth(\master, [\in, ~bus.master, \out, 0], ~groups.fx, addAction: \addToTail);
	};

	ServerQuit.add(~cleanup);
	ServerTree.add(~makeNodes);
	ServerTree.run;

	Pbindef.clear;

	~scale = Scale.phrygian;

	Pbindef.new(\rain,
		\instrument, \sampler,
		#[\buf, \spos], Pfunc({
			var buf;
			buf = b.at(\Rain99Sounds).choose;
			[buf, rrand(0, 0.5) * buf.numFrames]
		}),
		\dur, 2.5,
		\rate, 1.0,
		\atk, 2.0,
		\sus, 5,
		\rel, 2.0,
		\lpf, 15000,
		\hpf, 200,
		\amp, Env([0.01, 1.0, 0.5, 0.25, 0], [32, 32, 56, 32]).asPseg,
		\pan, Pwhite(-0.25, 0.25),
		\out, ~bus.master
	);

	Pbindef(\typing,
		\instrument, \sampler,
		#[\buf, \spos], Pfunc({
			var buf;
			buf = b.at(\Typing).choose;
			[buf, rrand(0, 0.9) * buf.numFrames]
		}),
		\dur, Pmeanrand(2.5, 10),
		\rate, Pwhite(0.25, 0.75),
		\atk, 2.5,
		\sus, 5.0,
		\rel, 2.5,
		\lpf, 1000,
		\hpf, 200,
		\amp, Pseq([Env([0.01, 0.3], 16).asPseg, Pseq([0.3], inf)]),
		\pan, Pwhite(-0.2, 0.2),
		\out, ~bus.rev
	);

	Pbindef.new(\panSizzle,
		\instrument, \sampler,
		#[\buf, \spos], Pfunc({
			var buf;
			buf = b.at(\PanSizzle)[0];
			[buf, rrand(0, 0.8) * buf.numFrames]
		}),
		\dur, Plprand(5, 15),
		\rate, 1.0,
		\atk, 4,
		\sus, 2,
		\rel, 4,
		\lpf, 20000,
		\hpf, 200,
		\amp, Pseq([Env([0.01, 0.1], 16).asPseg, Pseq([0.1], inf)]),
		\pan, Pwhite(-0.5, 0.5),
		\out, ~bus.master
	);

	Pbindef.new(\ice,
		\instrument, \sampler,
		#[\buf, \spos], Pfunc({
			var buf;
			buf = b.at(\Ice).choose;
			[buf, 0]
		}),
		\dur, Prand([Pdup(2, Pwhite(0.25, 0.75, 1)), 5], inf),
		\rate, 1.0,
		\atk, 0.05,
		\sus, 5,
		\rel, 0.5,
		\lpf, 1000,
		\hpf, 200,
		\amp, Pseq([Env([0.01, 0.2], 16).asPseg, Pseq([0.2], inf)]),
		\pan, Pwhite(-0.75, 0.75),
		\out, ~bus.rev
	);

	Pbindef.new(\salt,
		\instrument, \sampler,
		#[\buf, \spos], Pfunc({
			var buf;
			buf = b.at(\SaltShaker).choose;
			[buf, 0]
		}),
		\dur, 2.5,
		\rate, 0.5,
		\atk, 0.25,
		\sus, 5,
		\rel, 0.5,
		\lpf, 15000,
		\hpf, 200,
		\amp, Pseq([Env([0.01, 0.05], 16).asPseg, Pseq([0.05], inf)]),
		\pan, Pwhite(-0.5, 0.5),
		\out, ~bus.rev,
	);

	Pbindef(\leadplucks,
		\instrument, \plucky,
		\type, Pwrand([\note, \rest], [0.65, 0.35], inf),
		\midinote, Pfunc({ Array.fill(8, { rrand(60, 72) }).nearestInScale(~scale.degrees) }),
		\strum, Pwrand([2, 4, 8, 16], [2, 4, 8, 16].reciprocal.normalizeSum, inf).reciprocal,
		\taps, Prand([0.0, 0.5, 1.0, 1.5, 2.0, 2.5, 3.0, 3.5, 4.0], inf),
		\pan, Pwhite(-0.5, 0.5),
		\atk, 0.25,
		\sus, 1.0,
		\rel, 0.1,
		\dur, 0.5,
		\amp, Env([0, 1.5, 2.0, 0], [24, 56, 40]).asPseg,
		\coef, 0.9,
		\out, ~bus.master
	);

	Pbindef(\chordpad,
		\instrument, \plucky,
		\midinote, Pfunc({(rrand(36, 48) +.x #[-12, 0, 5, 7, 10, 12]).nearestInScale(~scale.degrees).scramble.at((0..rrand(1, 5))) ++ Array.fill(rrand(2, 5), { rrand(36, 48) })}),
		\taps, 100,
		\pan, Pwhite(-0.25, 0.25, inf),
		\atk, 6.0,
		\sus, 0.0,
		\rel, 2.0,
		\lpf, 1000,
		\dur, 6.0,
		\amp, Env([0.01, 1.0, 0.5, 0], [56, 32, 32], [3, 0, 0]).asPseg,
		\coef, 0.8,
		\out, ~bus.rev
	);

	Pbindef.new(\beads,
		\instrument, \sampler,
		#[\buf, \spos], Pfunc({
			var buf;
			buf = b.at(\CurtainBeads).choose;
			[buf, rrand(0, buf.numFrames * 0.2)]
		}),
		\dur, Env([5.0, 1.0, 1.0], [56, 72]).asPseg,
		\rate, Pwhite(0.05, 0.1),
		\atk, 0.01,
		\sus, 5.0,
		\rel, 0.1,
		\lpf, 300,
		\hpf, 20,
		\amp, Env([0, 0.2, 0.2, 0], [32, 72, 24]).asPseg,
		\pan, Pwhite(-0.15, 0.15),
		\out, ~bus.rev
	);

	Pbindef(\ringers,
		\instrument, \sampleRingz,
		\type, Pseq([\rest, Pwrand([\rest, \note], [0.6, 0.4], inf)]),
		#[\buf, \spos], Pfunc({
			var buf = b.at(\Rain99Sounds).choose;
			[buf, rrand(0, buf.numFrames - 1)];
		}),
		\rate, Pwhite(-1.0, 1.0),
		\degree, Prand(Scale.phrygian, inf),
		\octave, Pwrand([3, 4, 5], [0.125, 0.75, 0.125], inf),
		\bankamp, 1.0,
		\ringtime, 0.5,
		\atk, 0.10,
		\sus, 2.5,
		\rel, 0.5,
		\dur, 0.5,
		\pan, Pwhite(-0.5, 0.5),
		\amp, 3.0,
		\out, ~bus.rev
	);

	Pbindef(\thunderbeads,
		\instrument, \thunderbeads,
		\buf, Pfunc({b.at(\CurtainBeads).choose}),
		\pan, Pwhite(-0.25, 0.25),
		\dur, Pseq([Pwhite(4.0, 8.0, 10), Pwhite(2.5, 5.0, 5), Pwhite(1.5, 2.5, inf)]),
		\amp, 0.8,
		\out, ~bus.rev
	);

	Pbindef(\intensepad,
		\instrument, \plucky,
		\midinote, Pfunc({(rrand(36, 48) +.x #[-12, 0, 5, 7, 10, 12]).nearestInScale(~scale.degrees).scramble.at((0..rrand(3, 5))) ++ Array.fill(rrand(3, 5), { rrand(36, 60) })}),
		\taps, Pgeom(5, 1.15, 30),
		\pan, Pwhite(-0.125, 0.125, inf),
		\atk, 6.0,
		\sus, 2.0,
		\rel, 4.0,
		\hpf, 200,
		\lpf, Env([1000, 5000, 10000], [54, 54], [4, 0]).asPseg,
		\dur, Pwhite(3.5, 4.5),
		\amp, Env([0.01, 0.2, 1.7], [32, 76], [0, 5]).asPseg,
		\coef, 0.8,
		\out, ~bus.rev
	);

	Pbindef.new(\heavythunder,
		\instrument, \sampler,
		\buf, Pfunc({b.at(\HeavyThunder99Sounds).choose}),
		\rate, Pwhite(0.8, 1.2),
		\dur, Pwhite(5.0, 10.0),
		\atk, 0.01,
		\sus, 5,
		\rel, 5.0,
		\amp, Pseq([Env([0.01, 0.6], [76], [3]).asPseg, Pseq([0.6], inf)]),
		\pan, Pwhite(-0.1, 0.1),
		\out, ~bus.rev,
	);

	Pbindef.new(\wind,
		\instrument, \wind,
		\filtmod, Pexprand(0.05, 0.5),
		\rqmod, Pexprand(0.5, 0.05),
		\dur, Pwhite(2.0, 8.0),
		\atk, Pmeanrand(3.0, 7.0),
		\sus, Pmeanrand(3.0, 7.0),
		\rel, Pmeanrand(3.0, 7.0),
		\amp, Pseq([Env([0.01, 0.2, 0.05], [60, 30]).asPseg, Pseq([0.05], inf)]),
		\pan, Pwhite(-0.75, 0.75),
		\out, ~bus.rev,
	);

	~buildEvents = 30;
	~upcounter = 0;
	~buildInsertRate = 3;
	~maxResonators = ~buildEvents * ~buildInsertRate;

	~ringzBuild = Pbind(
		\instrument, \sampleRingz,
		\numevents, Pseq([0], ~buildEvents),
		#[\buf, \spos], Pfunc({
			var buf = (b.at(\Cafe)).choose;
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
		\freqscale, Pwrand([2/3, 1.0, 1.5, 2.0], [0.05, 0.7, 0.2, 0.05], inf),
		\decayscale, Prand([Phprand(0.5, 2.5), Pmeanrand(2.5, 7.5), Plprand(7.5, 10.0)], inf),
		\atk, Pexprand(2.5, 10),
		\sus, Pexprand(5.0, 10),
		\rel, Pexprand(2.5, 5),
		\dur, 3.0,
		\pan, Pwhite(-0.5, 0.5),
		\amp, Pseq([Env([0.025, 0.75], [16]).asPseg, Pwhite(0.05, 0.1)]),
		\out, ~bus.master
	);

	~descendEvents = 30;
	~downcounter = ~descendEvents;
	~descendRemoveRate = 3;

	~ringzDescend = Pbind(
		\instrument, \sampleRingz,
		\numevents, Pseq([0], ~descendEvents),
		#[\buf, \spos], Pfunc({
			var buf = (b.at(\Cafe)).choose;
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
		\freqscale, Pwrand([2/3, 1.0, 1.5, 2.0], [0.05, 0.7, 0.2, 0.05], inf),
		\decayscale, Prand([Phprand(0.5, 2.5), Pmeanrand(2.5, 7.5), Plprand(7.5, 10.0)], inf),
		\atk, Pexprand(2.5, 10),
		\sus, Pexprand(5.0, 10),
		\rel, Pexprand(2.5, 5),
		\dur, 3.0,
		\pan, Pwhite(-0.5, 0.5),
		\amp, Pwhite(0.05, 0.1),
		\out, ~bus.master
	);

	Pbindef.new(\windramp,
		\instrument, \wind,
		\filtmod, Pexprand(0.05, 0.5),
		\rqmod, Pexprand(0.5, 0.05),
		\dur, Pwhite(2.0, 4.0),
		\atk, Pmeanrand(3.0, 7.0),
		\sus, Pmeanrand(3.0, 7.0),
		\rel, Pmeanrand(3.0, 7.0),
		\amp, Pseq([Env([0.01, 0.6], [90], [3]).asPseg, Pseq([0.6], inf)]),
		\pan, Pwhite(-0.75, 0.75),
		\out, ~bus.rev,
	);

	Pbindef.new(\heavythunder2,
		\instrument, \sampler,
		\buf, Pfunc({b.at(\HeavyThunder99Sounds).choose}),
		\rate, Pwhite(0.8, 1.2),
		\dur, Pwhite(2.50, 5.0),
		\atk, 0.01,
		\sus, 5,
		\rel, 5.0,
		\amp, Pseq([Env([0.1, 0.6], [32], [3]).asPseg, Pseq([0.6], inf)]),
		\pan, Pwhite(-0.1, 0.1),
		\out, ~bus.rev,
	);

	s.sync;

	r = Routine {
		// 0
		"rain".postln;
		Pbindef(\rain).play;

		16.wait;
		// 16
		"typing".postln;
		Pbindef(\typing).play;

		8.wait;
		"panSizzle".postln;
		Pbindef(\panSizzle).play;

		8.wait;
		// 32
		"ice".postln;
		Pbindef(\ice).play;

		8.wait;
		"salt".postln;
		Pbindef(\salt).play;

		8.wait;
		// 48
		"leadplucks".postln;
		Pbindef(\leadplucks).play;

		16.wait;
		// 64
		"chordpad".postln;
		Pbindef(\chordpad).play;

		48.wait;
		// 80
		// 96
		// 112
		"beads / rain stop".postln;
		Pbindef(\beads).play;

		32.wait;
		// 128
		// 144
		"ringers / ice stop".postln;
		Pbindef(\ringers).play;
		Pbindef(\ice).stop;

		16.wait;
		// 160
		"thunderbeads, panSizzle and salt stop".postln;
		Pbindef(\thunderbeads).play;
		Pbindef(\panSizzle).stop;
		Pbindef(\salt).stop;

		32.wait;
		// 176
		// 192
		"intensepad".postln;
		Pbindef(\intensepad).play;

		32.wait;
		// 208
		// 224
		"heavy thunder".postln;
		Pbindef(\heavythunder).play;

		80.wait;
		// 240
		// 256
		// 272
		// 288
		// 304
		"typing, ringers, intense pad, thunderbeads, and heavythunder stop".postln;
		Pbindef(\typing).stop;
		Pbindef(\ringers).stop;
		Pbindef(\thunderbeads).stop;
		Pbindef(\intensepad).stop;
		Pbindef(\heavythunder).stop;

		// (310)
		6.wait;
		"strike!".postln;
		Synth(\sampler, [\buf, b.at(\HeavyThunder99Sounds)[2], \atk, 0.01, \sus, 1.0, \rel, 4.0, \amp, 0.8, \out, ~bus.rev]);

		10.wait;
		// 320
		"wind".postln;
		Pbindef(\wind).play;

		32.wait;
		// 336
		// 352
		~upcounter = 0;
		~downcounter = ~descendEvents;
		"ringz build".postln;
		~ringzBuild.play;

		90.wait;
		// 368
		// 384
		// 400
		// 416
		// 432
		// (442)
		"ringz descend, windramp / wind stop".postln;
		Pbindef(\wind).stop;
		~ringzDescend.play;
		Pbindef(\windramp).play;

		60.wait;
		// 448
		// 464
		// 480
		// 496
		// (502)
		"heavythunder2, rain, typing, panSizzle, ice, salt, thunderbeads".postln;
		Pbindef(\heavythunder2).play;
		Pbindef(\rain).play;
		Pbindef(\typing).play;
		Pbindef(\panSizzle).play;
		Pbindef(\ice).play;
		Pbindef(\salt).play;
		Pbindef(\thunderbeads).play;

		36.wait;
		// 512
		// 528
		// (538)
		"stop heavythunder2".postln;
		Pbindef(\heavythunder2).stop;

		32.wait;
		// 544
		// 560
		// (570)
		"stop thunderbeads + wind".postln;
		Pbindef(\thunderbeads).stop;
		Pbindef(\windramp).stop;

		32.wait;
		// 576
		// 592
		// (602)
		"stop typing, panSizzle, ice, salt".postln;
		Pbindef(\typing).stop;
		Pbindef(\panSizzle).stop;
		Pbindef(\ice).stop;
		Pbindef(\salt).stop;

		16.wait;
		// 608
		// (618)
		"stop rain".postln;
		Pbindef(\rain).stop;
	}.play;
});
)
