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
		ServerBoot.removeAll;
	};

	~makeNodes = {
		~groups = ();
		~groups.fx = Group.new;

		~rev = Synth(\reverb, [\in, ~bus.rev, \out, ~bus.master, \fb, 0, \mix, 0.3], ~groups.fx);
		~master = Synth(\master, [\in, ~bus.master, \out, 0], ~groups.fx, addAction: \addToTail);
	};

	ServerQuit.add(~cleanup);
	ServerTree.add(~makeNodes);
	ServerTree.run;
});
)

b.keys.asArray.sort.do(_.postln);\

Synth(\sampler, [\buf, b.at(\Rain99Sounds).choose, \sus, 30]);
Synth(\sampler, [\buf, b.at(\Typing).choose, \sus, 30, \hpf, 200]);
Synth(\sampler, [\buf, b.at(\PanSizzle).choose, \sus, 30, \amp, 0.05]);
Synth(\sampler, [\buf, b.at(\Ice)[0], \sus, 30, \amp, 0.5, \lpf, 1000]);
Synth(\sampler, [\buf, b.at(\SaltShaker).choose, \sus, 30, \amp, 0.2]);
Synth(\sampler, [\buf, b.at(\CurtainBeads).choose, \sus, 30, \amp, 0.2]);
Synth(\sampler, [\buf, b.at(\CurtainBeads).choose, \rate, 0.1, \sus, 30, \amp, 0.2]);

(
Pbindef.clear;

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
	\amp, 1.0,
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
	\dur, Phprand(2.5, 10),
	\rate, Pwhite(0.25, 0.75),
	\atk, 2.5,
	\sus, 5.0,
	\rel, 2.5,
	\lpf, 1000,
	\hpf, 200,
	\amp, 0.3,
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
	\amp, 0.1,
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
	\amp, 0.2,
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
	\amp, 0.1,
	\pan, Pwhite(-0.5, 0.5),
	\out, ~bus.rev,
);

Pbindef(\leadplucks,
	\instrument, \plucky,
	\type, Pwrand([\note, \rest], [0.75, 0.25], inf),
	\midinote, Pfunc({ Array.fill(8, { rrand(48, 60) }).nearestInScale(Scale.minor.degrees) }),
	\strum, Pwrand([2, 4, 8, 16], [2, 4, 8, 16].reciprocal.normalizeSum, inf).reciprocal,
	\taps, Prand([0.0, 0.5, 1.0, 1.5, 2.0, 2.5, 3.0, 3.5, 4.0], inf),
	\pan, Pwhite(-0.5, 0.5),
	\atk, 0.25,
	\sus, 1.0,
	\rel, 0.1,
	\dur, 0.5,
	\amp, Env([0, 1.0, 1.0, 0], [32, 64, 80]).asPseg,
	\coef, 0.9,
	\out, ~bus.rev
);

Pbindef(\chordpad,
	\instrument, \plucky,
	\midinote, Pfunc({(rrand(36, 48) +.x #[0, 5, 7, 10, 12]).nearestInScale(Scale.minor.degrees)}),
	\taps, 400,
	\pan, Pwhite(-0.25, 0.25, inf),
	\atk, 6.0,
	\sus, 0.0,
	\rel, 2.0,
	\lpf, 1000,
	\dur, 6.0,
	\amp, Env([0, 0.35, 0.35, 0], [56, 32, 64]).asPseg,
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
	\atk, 0.5,
	\sus, 2.0,
	\rel, 0.5,
	\lpf, 300,
	\hpf, 20,
	\amp, Env([0, 1.25, 1.25, 0], [32, 72, 24]).asPseg,
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
	\degree, Prand(Scale.minor, inf),
	\octave, Pwrand([2, 3, 4], [0.125, 0.75, 0.125], inf),
	\bankamp, 1.0,
	\ringtime, 0.5,
	\atk, 0.10,
	\sus, 2.5,
	\rel, 0.5,
	\dur, 0.5,
	\pan, Pwhite(-0.5, 0.5),
	\amp, 2.0,
	\out, ~bus.rev
);
)

Pbindef(\rain).play;
Pbindef(\typing).play;
Pbindef(\panSizzle).play;
Pbindef(\ice).play;
Pbindef(\salt).play;
Pbindef(\leadplucks).play;
Pbindef(\chordpad).play;
Pbindef(\beads).play;
Pbindef(\ringers).play;

// 4.5 minute sequence
(
~master.set(\amp, 1.25);
~rev.set(\fb, 0.1);
Pbindef(\rain, \amp, 1.0);

r = Routine {
	"rain".postln;
	Pbindef(\rain).play;

	16.wait;
	"typing".postln;
	Pbindef(\typing).play;

	16.wait;
	"panSizzle".postln;
	Pbindef(\panSizzle).play;

	16.wait;
	"ice".postln;
	Pbindef(\ice).play;

	16.wait;
	"salt".postln;
	Pbindef(\salt).play;

	16.wait;
	"leadplucks".postln;
	Pbindef(\leadplucks).play;

	16.wait;
	"rain amp 0.5".postln;
	Pbindef(\rain, \amp, 0.5);

	16.wait;
	"rain amp 0.25, chordpad".postln;
	Pbindef(\rain, \amp, 0.25);
	Pbindef(\chordpad).play;

	16.wait;
	"rain stop".postln;
	Pbindef(\rain).stop;

	16.wait;
	"beads".postln;
	Pbindef(\beads).play;

	16.wait;
	"ringers".postln;
	Pbindef(\ringers).play;

	112.wait;
	"all stop".postln;
	Pbindef(\panSizzle).stop;
	Pbindef(\ice).stop;
	Pbindef(\salt).stop;
	Pbindef(\typing).stop;
	Pbindef(\ringers).stop;
}.play;
)

(
r.stop;
Pbindef(\rain).stop;
Pbindef(\typing).stop;
Pbindef(\panSizzle).stop;
Pbindef(\ice).stop;
Pbindef(\salt).stop;
Pbindef(\leadplucks).stop;
Pbindef(\chordpad).stop;
Pbindef(\beads).stop;
Pbindef(\ringers).stop;
)
