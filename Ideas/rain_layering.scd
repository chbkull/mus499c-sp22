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
});
)


b.keys.asArray.sort.do(_.postln);\


Synth(\sampler, [\buf, b.at(\Rain99Sounds).choose, \sus, 30]);
Synth(\sampler, [\buf, b.at(\Typing).choose, \sus, 30, \hpf, 200]);
Synth(\sampler, [\buf, b.at(\PanSizzle).choose, \sus, 30, \amp, 0.05]);
Synth(\sampler, [\buf, b.at(\Ice).choose, \sus, 30, \amp, 0.5, \lpf, 1000]);
Synth(\sampler, [\buf, b.at(\SaltShaker).choose, \sus, 30, \amp, 0.2]);


(
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
	\out, 0
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
	\atk, 1.0,
	\sus, 5,
	\rel, 1.0,
	\lpf, 1000,
	\hpf, 200,
	\amp, 0.7,
	\pan, Pwhite(-0.2, 0.2),
	\out, 0
);

Pbindef.new(\panSizzle,
	\instrument, \sampler,
	#[\buf, \spos], Pfunc({
		var buf;
		buf = b.at(\PanSizzle)[0];
		[buf, rrand(0, 0.8) * buf.numFrames]
	}),
	\dur, Pwhite(10, 20),
	\rate, 1.0,
	\atk, 4,
	\sus, 0,
	\rel, 4,
	\lpf, 20000,
	\hpf, 200,
	\amp, 0.25,
	\pan, Pwhite(-0.5, 0.5),
	\out, 0
);

Pbindef.new(\ice,
	\instrument, \sampler,
	#[\buf, \spos], Pfunc({
		var buf;
		buf = b.at(\Ice).choose;
		[buf, 0]
	}),
	\dur, Prand([Pdup(2, Pwhite(0.25, 0.75, 1)), 10], inf),
	\rate, 1.0,
	\atk, 0.05,
	\sus, 5,
	\rel, 0.5,
	\lpf, 1000,
	\hpf, 200,
	\amp, 0.2,
	\pan, Pwhite(-0.75, 0.75),
	\out, 0
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
	\atk, 0.01,
	\sus, 5,
	\rel, 0.5,
	\lpf, 15000,
	\hpf, 200,
	\amp, 0.05,
	\pan, Pwhite(-0.5, 0.5),
	\out, 0
);

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
	\amp, Env([0, 1.5, 1.5, 0], [16, 80, 16]).asPseg,
	\coef, 0.9,
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
	\amp, Env([0, 0.5, 0.5, 0], [56, 16, 8]).asPseg,
	\coef, 0.8,
	\out, 0,
);
)

Pbindef(\rain).play;
Pbindef(\typing).play;
Pbindef(\panSizzle).play;
Pbindef(\ice).play;
Pbindef(\salt).play;
Pbindef(\leadplucks).play;

(
r = Routine {
	Pbindef(\rain).play;

	16.wait;

	Pbindef(\typing).play;

	16.wait;

	Pbindef(\panSizzle).play;

	16.wait;

	Pbindef(\ice).play;

	16.wait;

	Pbindef(\salt).play;

	16.wait;

	Pbindef(\leadplucks).play;

	16.wait;

	Pbindef(\rain, \amp, 0.5);

	16.wait;

	Pbindef(\rain).stop;
	Pbindef(\chordpad).play;

	16.wait;

	Pbindef(\ice).stop;

	16.wait;

	Pbindef(\salt).stop;

	16.wait;

	Pbindef(\panSizzle).stop;

	16.wait;

	Pbindef(\typing).stop;
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
)