s.boot;

Buffer.freeAll;

(
var dir = PathName(thisProcess.nowExecutingPath).parentPath ++ "../SoundLibrary/BigMetalBowl";
~buf = (1..5).collect({
	arg n;
	Buffer.readChannel(s, dir ++ "/Resonate" ++ n ++ ".wav", channels:[0])
})
)

// Synth for playing back samples.
// Adapted from Prof. Fieldsteel's 10/7 lecture code
(
SynthDef.new(\sampler, {
	arg buf=0, rate=1, spos=0, loop=0, atk=0.01, sus=1, rel=0.01,
	lp=20000, hp=20, pan=0, amp=1, out=0;
	var sig, env;
	sig = PlayBuf.ar(
		1, buf, BufRateScale.ir(buf) * rate,
		startPos: spos, loop: loop
	);
	sig = LPF.ar(sig, lp);
	sig = HPF.ar(sig, hp);

	env = EnvGen.ar(
		Env.new([0,1,1,0],[atk,sus,rel],[1,0,-1]),
		doneAction:2
	);
	sig = sig * env;
	sig = Pan2.ar(sig, pan, amp);
	Out.ar(out, sig);
}).add;
)

Synth(\sampler, [\buf, ~buf[0], \spos, 500, \atk, 0.1, \sus, 1.0, \rel, 4.0, \lp, 2500]);

Scale.directory;

Scale.enigmatic.degrees;

(
var p1, p2;
p1 = Pbind(
	\instrument, \sampler,
	\buf, Pxrand(~buf, inf),
	\spos, Pwhite(500, 41400),
	\rate, Prand(Scale.enigmatic.degrees, inf).midiratio,
	\sus, 1.0,
	\rel, 4.0,
	\dur, Plprand(0.5, 1.0, inf),
	\pan, Pwhite(-0.5, 0.5),
	\lp, 2500,
	\amp, 1
);

p2 = Pbind(
	\instrument, \sampler,
	\buf, Pxrand(~buf, inf),
	\spos, Pwhite(500, 41400),
	\rate, Prand(Scale.enigmatic.degrees + 12, inf).midiratio,
	\sus, 1.0,
	\rel, 4.0,
	\dur, Plprand(0.5, 1.0, inf),
	\pan, Pwhite(-0.5, 0.5),
	\lp, 2500,
	\amp, 1
);

p = Ppar([p1, p2]);

~stream = p.play;
)

~stream.stop;
