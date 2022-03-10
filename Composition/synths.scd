SynthDef.new(\rain, {
	var lowBubble, highBubble, noise, sig;
	lowBubble = { WhiteNoise.ar }!2;
	lowBubble = BPF.ar(lowBubble, 5000, 1);
	lowBubble = BPF.ar(lowBubble, LFNoise0.ar(100, 2000, 3000), 0.2);

	highBubble = { PinkNoise.ar }!2;
	highBubble = RHPF.ar(highBubble, 200);
	highBubble = RLPF.ar(highBubble, 1000);
	highBubble = BPF.ar(highBubble, LFNoise0.ar(100, 400, 600), 0.2);

	noise = { PinkNoise.ar }!10;
	noise = RHPF.ar(noise, 100);
	noise = RLPF.ar(noise, 7500);
	noise = Splay.ar(noise);

	sig = lowBubble * \lowBubbleAmp.kr(0.1) + highBubble * \highBubbleAmp.kr(0.02) + noise * \noiseAmp.kr(0.1);
	Out.ar(\out.kr(0), sig);
}).add;

SynthDef.new(\rainmaker, {
	var amp = \amp.kr(1.0, 5.0), out = \out.kr(0);
	var auxamp = \auxamp.kr(0.0), auxout = \auxout.kr(nil);
	var sig;
	sig = tanh(
            3 * GVerb.ar(
                HPF.ar(
                    PinkNoise.ar(0.08+LFNoise1.kr(0.3,0.02))+LPF.ar(Dust2.ar(LFNoise1.kr(0.2).range(40,50)),7000),
                    400
                ),
                250,100,0.25,drylevel:0.3
            ) * Line.kr(0,1,10)
        );
	sig = sig + (
            GVerb.ar(
                LPF.ar(
                    10 * HPF.ar(PinkNoise.ar(LFNoise1.kr(3).clip(0,1)*LFNoise1.kr(2).clip(0,1) ** 1.8), 20)
                    ,LFNoise1.kr(1).exprange(100,2500)
                ).tanh,
               270,30,0.7,drylevel:0.5
            ) * Line.kr(0,0.7,30)
        );
	sig = sig * Env([0.0, 1.0, 1.0, 0.0], [\atk.ar(10), \sus.ar(10), \rel.ar(10)], [4, 0, 4]).ar(doneAction: Done.freeSelf);
	sig = LPF.ar(sig, 5000);
	Out.ar(out, sig * amp);
	Out.ar(auxout, sig * auxamp);
}).add;

SynthDef.new(\raindrop, {
	var sig;
	sig = { WhiteNoise.ar }!2;
	sig = RLPF.ar(sig, 100 + 1000 * Env([0, 1, 0.4, 1, 0], [0.09, 0.01, 0.09, 0.01], [0, 0, 2, 0]).ar, 0.005);
	sig = HPF.ar(sig, 100);
	sig = HPF.ar(sig, 100);
	sig = sig * Env([0, 1, 0], [0.01, 0.2], [4, 2]).ar(doneAction: Done.freeSelf);
	sig = sig * 0.15;
	sig = sig * \amp.kr(1.0);
	sig = Balance2.ar(sig[0], sig[1], \pan.ar(0));
	Out.ar(\out.kr(0), sig);
}).add;

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

SynthDef.new(\sampler2, {
	arg buf=0, rate=1, spos=0, loop=0, atk=0.01, sus=1, rel=0.01,
	lp=20000, hp=20, pan=0, amp=1, out=0, auxamp=1, auxout=nil;
	var sig, env;
	sig = PlayBuf.ar(
		2, buf, BufRateScale.ir(buf) * rate,
		startPos: spos, loop: loop
	);
	sig = LPF.ar(sig, lp);
	sig = HPF.ar(sig, hp);

	env = EnvGen.ar(
		Env.new([0,1,1,0],[atk,sus,rel],[1,0,-1]),
		doneAction:2
	);
	sig = sig * env;
	sig = Balance2.ar(sig[0], sig[1], pan);
	Out.ar(out, sig * amp);
	Out.ar(auxout, sig * auxamp);
}).add;

SynthDef.new(\sampleRingz, {
	var buf = \buf.kr(0), rate = \rate.kr(1), spos = \spos.kr(0);
	var freq = \freq.kr(440), bankamp = \bankamp.kr(0.1), ringtime = \ringtime.kr(0.5);
	var freqscale = \freqscale.kr(1.0, \freqscalelag.kr(1.0)), freqoffset = \freqoffset.kr(0.0, \freqoffsetlag.kr(1.0)), decayscale = \decayscale.kr(1.0);
	var atk = \atk.kr(0.1), sus = \sus.kr(1.0), rel = \rel.kr(0.1);
	var pan = \pan.kr(0), amp = \amp.kr(1.0), out = \out.kr(0);
	var sig, env;
	sig = Ringz.ar(
		PlayBuf.ar(2, buf, BufRateScale.ir(buf) * rate, startPos: spos) * 0.005,
		freq * freqscale + freqoffset,
		ringtime * VarLag.kr(decayscale, \decayscalelag.kr(1.0), \decayscalecurve.kr(0)),
		bankamp
	);
	env = Env.linen(atk, sus, rel).ar(Done.freeSelf);
	sig = sig * env;
	sig = Balance2.ar(sig[0], sig[1], pan, amp);
	sig = sig * (44100 / SampleRate.ir); // See Ringz's documentation, but amplitude is dependent on sample rate
	Out.ar(out, sig);
}).add;