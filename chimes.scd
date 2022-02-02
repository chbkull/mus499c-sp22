s.boot;

Buffer.freeAll;

(
var dir = PathName(thisProcess.nowExecutingPath).parentPath ++ "SoundLibrary/SwellBottle";
~buf = (1..3).collect({
	arg n;
	Buffer.readChannel(s, dir ++ "/Resonate" ++ n ++ ".wav", channels:[0])
})
)

(
// Synth for playing back samples.
// Source: Prof. Fieldsteel's 10/7 class notes
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

(
p = Pbind(
	\instrument, \sampler,
	\buf, Pxrand(~buf, inf),
	\rate, Prand((-12..24), inf).midiratio,
	\atk, Pexprand(0.25, 1),
	\sus, 1.5,
	\dur, Plprand(0.125, 0.5, inf),
	\pan, Pwhite(-0.5, 0.5)
);

~stream = p.play;
)

~stream.stop;
