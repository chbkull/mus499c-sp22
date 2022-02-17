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

// Week of 2/17 -------------------------------------------------------------------------------------------------------------------------------
// CK: another oddity of DynKlank- seems to be expecting at least an array of size 2 or more otherwise it gets confused when it tries to call 'sum'.

(
var maxresonators = 25;
~fMinorPentatonic = (Scale.minorPentatonic.degrees +.x [41, 53, 65, 77, 89]).midicps.sort.reverse;

SynthDef.new(\sampleKlank, {
	var buf = \buf.kr(0), rate = \rate.kr(1), spos = \spos.kr(0);
	var klankfreqs = \klankfreqs.kr(0!maxresonators), klankamps = \klankamps.kr(0!maxresonators), ringtimes = \ringtimes.kr(0!maxresonators);
	var freqscale = \freqscale.kr(1.0, \freqscalelag.kr(1.0)), freqoffset = \freqoffset.kr(0.0, \freqoffsetlag.kr(1.0)), decayscale = \decayscale.kr(1.0);
	var atk = \atk.kr(0.1), sus = \sus.kr(1.0), rel = \rel.kr(0.1);
	var pan = \pan.kr(0), amp = \amp.kr(1.0), out = \out.kr(0);
	var sig, env;
	sig = DynKlank.ar(
		`[klankfreqs, klankamps, ringtimes],
		PlayBuf.ar(2, buf, BufRateScale.ir(buf) * rate, startPos: spos) * 0.01,
		freqscale.value,
		freqoffset,
		VarLag.kr(decayscale, \decayscalelag.kr(1.0), \decayscalecurve.kr(0))
	);
	env = Env.linen(atk, sus, rel).ar(Done.freeSelf);
	sig = sig * env;
	sig = Balance2.ar(sig[0], sig[1], pan, amp);
	Out.ar(out, sig);
}).add;
)

x = Synth(\sampleKlank, [\buf, ~buf[0], \klankfreqs, [440], \klankamps, [0.2], \ringtimes, [0.6], \atk, 1, \sus, 5, \rel, 1, \amp, 0.5]);
x.free;

// Pbind from last week using the new SynthDef
(
var p1;
var klankfreqs = ~fMinorPentatonic;
p1 = Pbind(
	\instrument, \sampleKlank,
	#[\buf, \spos], Pfunc({
		var buf = ~buf.choose;
		[buf, rrand(0, buf.numFrames - 1)];
	}),
	\rate, Pgauss(0.0, 3.0),
	// need to wrap DynKlank ref array arguments in arrays so they spawn as just one unified event
	\klankfreqs, [klankfreqs],
	\klankamps, [Array.exprand(klankfreqs.size, 0.2, 0.3).sort.reverse],
	\ringtimes, [Array.exprand(klankfreqs.size, 0.6, 2).sort.reverse],
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

~stream.stop;

// baseline
(
x = Synth(\sampleKlank, [
	\buf, ~buf[0], \rate, 1.0, \spos, 0,
	\klankfreqs, ~fMinorPentatonic,
	\klankamps, Array.exprand(~fMinorPentatonic.size, 0.2, 0.3).sort.reverse,
	\ringtimes, Array.exprand(~fMinorPentatonic.size, 0.6, 2).sort.reverse,
	\freqscale, 1.0, \freqoffset, 0.0, \decayscale, 1.0,
	\atk, 2.5, \sus, 5.0, \rel, 5.0,
	\amp, 0.6
]);
)

// reversed -> has more "swishing"
(
x = Synth(\sampleKlank, [
	\buf, ~buf[0], \rate, -1.0, \spos, ~buf[0].numFrames - 1,
	\klankfreqs, ~fMinorPentatonic,
	\klankamps, Array.exprand(~fMinorPentatonic.size, 0.2, 0.3).sort.reverse,
	\ringtimes, Array.exprand(~fMinorPentatonic.size, 0.6, 2).sort.reverse,
	\freqscale, 1.0, \freqoffset, 0.0, \decayscale, 1.0,
	\atk, 2.5, \sus, 5.0, \rel, 5.0,
	\amp, 0.6
]);
)

// sped up -> voices add a jittery texture
(
x = Synth(\sampleKlank, [
	\buf, ~buf[0], \rate, 3.0, \spos, 0,
	\klankfreqs, ~fMinorPentatonic,
	\klankamps, Array.exprand(~fMinorPentatonic.size, 0.2, 0.3).sort.reverse,
	\ringtimes, Array.exprand(~fMinorPentatonic.size, 0.6, 2).sort.reverse,
	\freqscale, 1.0, \freqoffset, 0.0, \decayscale, 1.0,
	\atk, 2.5, \sus, 5.0, \rel, 5.0,
	\amp, 0.6
]);
)

// long ringtimes -> more sustained, chord-like
(
x = Synth(\sampleKlank, [
	\buf, ~buf[0], \rate, 1.0, \spos, 0,
	\klankfreqs, ~fMinorPentatonic,
	\klankamps, Array.exprand(~fMinorPentatonic.size, 0.2, 0.3).sort.reverse,
	\ringtimes, Array.exprand(~fMinorPentatonic.size, 10, 20).sort.reverse,
	\freqscale, 1.0, \freqoffset, 0.0, \decayscale, 1.0,
	\atk, 2.5, \sus, 5.0, \rel, 5.0,
	\amp, 0.6
]);
)

// short ringtimes -> sample "leaks" through in addition to sparce pitch content
(
x = Synth(\sampleKlank, [
	\buf, ~buf[0], \rate, 1.0, \spos, 0,
	\klankfreqs, ~fMinorPentatonic,
	\klankamps, Array.exprand(~fMinorPentatonic.size, 0.6, 0.8).sort.reverse,
	\ringtimes, Array.exprand(~fMinorPentatonic.size, 0.05, 0.4).sort.reverse,
	\freqscale, 1.0, \freqoffset, 0.0, \decayscale, 1.0,
	\atk, 2.5, \sus, 5.0, \rel, 5.0,
	\amp, 0.6
]);
)

// higher freqscale multiplies resonator frequencies appropriately
// lagging freqscale allows for a cool record slow-down effect
(
x = Synth(\sampleKlank, [
	\buf, ~buf[0], \rate, 1.0, \spos, 0,
	\klankfreqs, ~fMinorPentatonic,
	\klankamps, Array.exprand(~fMinorPentatonic.size, 0.2, 0.3).sort.reverse,
	\ringtimes, Array.exprand(~fMinorPentatonic.size, 0.6, 2).sort.reverse,
	\freqscale, 4.0, \freqoffset, 0.0, \decayscale, 1.0,
	\atk, 2.5, \sus, 10.0, \rel, 5.0,
	\amp, 0.6
]);
)

x.set(\freqscale, 1.0, \freqscalelag, 2.0);


// higher freqoffset raises resonator frequencies appropriately
// changing freqoffset has a detune effect
(
x = Synth(\sampleKlank, [
	\buf, ~buf[0], \rate, 1.0, \spos, 0,
	\klankfreqs, ~fMinorPentatonic,
	\klankamps, Array.exprand(~fMinorPentatonic.size, 0.2, 0.3).sort.reverse,
	\ringtimes, Array.exprand(~fMinorPentatonic.size, 0.6, 2).sort.reverse,
	\freqscale, 1.0, \freqoffset, 0.0, \decayscale, 1.0,
	\atk, 2.5, \sus, 10.0, \rel, 5.0,
	\amp, 0.6
]);
)

x.set(\freqoffset, 100, \freqoffsetlag, 5.0);


// changing decayscale is equivalent to changing ringtimes multiplicatively
// allows for a nice transition from raw sample to resonators
(
x = Synth(\sampleKlank, [
	\buf, ~buf[0], \rate, 1.0, \spos, 0,
	\klankfreqs, ~fMinorPentatonic,
	\klankamps, Array.exprand(~fMinorPentatonic.size, 0.2, 0.3).sort.reverse,
	\ringtimes, Array.exprand(~fMinorPentatonic.size, 0.6, 2).sort.reverse,
	\freqscale, 1.0, \freqoffset, 0.0, \decayscale, 0.01,
	\atk, 2.5, \sus, 30.0, \rel, 5.0,
	\amp, 0.6
]);
)

x.set(\decayscale, 5.0, \decayscalelag, 30.0, \decayscalecurve, 4.0);


// slowly adding more and more frequencies to the resonator bank
// additional tweaks to other parameters based on above experimentation
(
var p1, klankfreqs = ~fMinorPentatonic;
var counter = 0, maxEvents = 150;
p1 = Pbind(
	\instrument, \sampleKlank,
	\numevents, Pseq([0], maxEvents),
	#[\buf, \spos], Pfunc({
		var buf = ~buf.choose;
		[buf, rrand(0, buf.numFrames - 1)];
	}),
	\rate, Pgauss(0.0, 3.0),
	#[\klankfreqs, \klankamps, \ringtimes], Pfunc({
		var selectedPitches;
		counter = counter + 1;
		counter.postln;
		selectedPitches = klankfreqs.scramble.at(Array.series(min(ceil(counter / 5), 25)));
		selectedPitches.postln;
		[
			[selectedPitches.sort.reverse],
			[Array.exprand(selectedPitches.size, 0.2, 0.3).sort.reverse],
			[Array.exprand(selectedPitches.size, 0.6, 2).sort.reverse]
		];
	}),
	\freqscale, Pwrand([2/3, 1.0, 1.5, 2.0], [0.05, 0.7, 0.2, 0.05], inf),
	\decayscale, Prand([Phprand(0.5, 2.5), Pmeanrand(2.5, 7.5), Plprand(7.5, 10.0)], inf),
	\atk, Pexprand(2.5, 10),
	\sus, Pexprand(5.0, 10),
	\rel, Pexprand(2.5, 5),
	\dur, 2.5,
	\pan, Pwhite(-0.5, 0.5),
	\amp, Pwhite(0.4, 0.55),
);

~stream = p1.play;
)

~stream.stop;


// Week of 2/10 -------------------------------------------------------------------------------------------------------------------------------
// CK: I ran into a lot of issues trying to get DynKlank to work with arguments inside of a SynthDef
// Planning on bringing it to class today to try and troubleshoot, see if this is even possible or if there are any workarounds

(
SynthDef.new(\sampleKlank, {
	arg buf=0, filtfreqs=[110, 220, 440], filtamps=[0.2, 0.2, 0.2], ringtimes=[1.0, 1.0, 1.0], out=0;
	var sig;
	sig = DynKlank.ar(
		// `[filtfreqs, filtamps, ringtimes],
		// `[filtfreqs, filtamps, [1.0, 1.0, 1.0]],
		`[[110, 220, 440], [0.2, 0.2, 0.2], [1.0, 1.0, 1.0]],
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


x = Synth(\sampleKlank2, [\buf, ~buf[1], \rate, rrand(-12, 12).midiratio, \spos, rrand(0, ~buf[1].numFrames-1), \atk, 5, \sus, 10, \rel, 10]);
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

~stream.stop;


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
