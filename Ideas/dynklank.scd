s.boot;

Buffer.freeAll;

(
var audiopath;
audiopath = PathName(thisProcess.nowExecutingPath).parentPath ++ "../SoundLibrary/";
b = Buffer.read(s, audiopath ++ "Cafe/Murmurs2.wav"); // 1, 2, 3
)

x = b.play;
x.free;

// thinking of trying to maybe layer a couple of these DynKlank's on top of each other to make an extremely lush, dense sound
// beware of clipping if you try and run multiple of the examples below simultaneously


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
		PlayBuf.ar(2, b, loop:1) * 0.005,
	);
}.play;
)

~test2.release(5);

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
			fMinorPentatonic,
			Array.exprand(fMinorPentatonic.size, 0.2, 0.3).sort.reverse,
			Array.exprand(fMinorPentatonic.size, 0.6, 2).sort.reverse
		],
		PlayBuf.ar(2, b, loop:1) * 0.005,
	);
}.play;
)

~test4.release(5);

