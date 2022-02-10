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

// Week of 2/10 -------------------------------------------------------------------------------------------------------------------------------
// CK: I ran into a lot of issues trying to get DynKlank to work with arguments inside of a SynthDef
// Planning on bringing it to class today to try and troubleshoot, see if this is even possible or if there are any workarounds

(
var filtfreqs=[110, 220, 440]
)

(
SynthDef.new(\sampleKlank, {
	arg buf=0, filtfreqs=[110, 220, 440], filtamps=[0.2, 0.2, 0.2], ringtimes=[1.0, 1.0, 1.0], out=0;
	var sig;
	sig = DynKlank.ar(
		`[filtfreqs, filtamps, ringtimes],
		// `[filtfreqs, filtamps, [1.0, 1.0, 1.0]],
		// `[[110, 220, 440], [0.2, 0.2, 0.2], [1.0, 1.0, 1.0]],
		PlayBuf.ar(2, buf, loop:1) * 0.005,
	);
	Out.ar(out, sig);
}).add;
)

x = Synth(\sampleKlank, [\buf, ~buf[1]]);
x.free;

(
SynthDef.new(\sampleKlank2, {
	arg buf=0, rate=1, spos=0, freqscale=1.0, freqoffset=0.0, decayscale=1.0, atk=0.01, sus=1, rel=0.01, pan=0, amp=1, out=0;
	var fMinorPentatonic, sig, env;
	fMinorPentatonic = Scale.minorPentatonic.degrees +.x [41, 53, 65, 77, 89];
	sig = DynKlank.ar(
		`[
			fMinorPentatonic.midicps.sort.reverse,
			Array.exprand(fMinorPentatonic.size, 0.2, 0.3).sort.reverse,
			Array.exprand(fMinorPentatonic.size, 0.6, 2).sort.reverse],
		PlayBuf.ar(2, buf, BufRateScale.ir(buf) * rate, startPos: spos) * 0.01,
		freqscale,
		freqoffset,
		decayscale
	);
	env = EnvGen.ar(
		Env.new([0,1,1,0],[atk,sus,rel],[1,0,-1]),
		doneAction:2
	);
	sig = sig * env;
	sig = Balance2.ar(sig[0], sig[1], pan, amp);
	Out.ar(out, sig);
}).add;
)


x = Synth(\sampleKlank2, [\buf, b, \rate, rrand(-12, 12).midiratio, \spos, rrand(0, b.numFrames-1), \atk, 5, \sus, 10, \rel, 10]);
x.free;

(
var p1;
p1 = Pbind(
	\instrument, \sampleKlank2,
	\buf, Prand(~buf, inf),
	\rate, Pgauss(0.0, 3.0),
	\spos, Pwhite(0, ~buf[0].numFrames * 0.9), // not sure how to use Pkey to determine numFrames from the selected buffer
	\freqscale, Pwrand([1.0, 1.5], [0.8, 0.2], inf),
	\decayscale, Pmeanrand(0.5, 1.5),
	\atk, Pexprand(2.5, 10),
	\sus, Pexprand(5.0, 10),
	\rel, Pexprand(1.0, 5),
	\dur, 2.5,
	\pan, Pwhite(-0.5, 0.5),
	\amp, 0.6,
);

~stream = p1.play;
)

~stream.stop(5);


// Week of 2/3 --------------------------------------------------------------------------------------------------------------
// thinking of trying to maybe layer a couple of these DynKlank's on top of each other to make an extremely lush, dense sound
// beware of clipping if you try and run multiple of the examples below simultaneously

(
var audiopath;
audiopath = PathName(thisProcess.nowExecutingPath).parentPath ++ "../SoundLibrary/";
b = Buffer.read(s, audiopath ++ "Cafe/Murmurs2.wav"); // 1, 2, 3
)

x = b.play;
x.free;

// sharp frequencies + traces of speech
(
var testArr = [800, 1600, 3200, 6400, 12800];

~test1 = {
	var sig;
	sig = DynKlank.ar(
		`[
			testArr,
			Array.exprand(testArr.size, 0.2, 0.3).sort.reverse,
			Array.exprand(testArr.size, 0.6, 2).sort.reverse
		],
		PlayBuf.ar(2, b, loop:1) * 0.005,
	);
}.play;
)

~test1.release(5);


// low rumble with pitches that poke out
(
var testArr = [100, 200, 300, 400, 500];

~test2 = {
	var sig;
	sig = DynKlank.ar(
		`[
			testArr,
			Array.exprand(testArr.size, 0.2, 0.3).sort.reverse,
			Array.exprand(testArr.size, 0.6, 2).sort.reverse
		],
		PlayBuf.ar(2, b, loop:1) * 0.005
	);
}.play;
)

~test2.free;

// passing in a major scale + Reverb
(
var cMajor = Scale.major.degrees.collect({
	arg val;
	val + 72;
}).midicps;

~test3 = {
	var sig;
	sig = DynKlank.ar(
		`[
			cMajor,
			Array.exprand(cMajor.size, 0.2, 0.3).sort.reverse,
			Array.exprand(cMajor.size, 0.6, 2).sort.reverse
		],
		PlayBuf.ar(2, b, loop:1) * 0.005,
	);
	FreeVerb2.ar(sig[0], sig[1], 0.6, 0.75, 0.5);
}.play;
)

~test3.release(5);

// passing in a minor pentatonic scale
(
var fMinorPentatonic = Scale.minorPentatonic.degrees.collect({
	arg val;
	val + 53;
}).midicps;

~test4 = {
	var sig;
	sig = DynKlank.ar(
		`[
			fMinorPentatonic.sort.reverse,
			Array.exprand(fMinorPentatonic.size, 0.2, 0.3).sort.reverse,
			Array.exprand(fMinorPentatonic.size, 0.6, 2).sort.reverse
		],
		PlayBuf.ar(2, b, loop:1) * 0.005
	);
}.play;
)

~test4.release(5);
