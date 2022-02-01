# Worklog

Keeping track of the work done each week. This worklog is best viewed in a text editor that can interpret the Markdown (.md) format. For those not viewing on GitHub already, [here is a link to this file on GitHub.](https://github.com/chbkull/mus499c-sp22/blob/main/worklog.md)

## 1/27

This week was spent putting together a sound library to use as a starting point for the composition. Some of the library was recently recorded (candle jar, ice, gingersnap box, etc.), and the rest of the library was from the recordings I took for Music 409 about a year ago. This sound library is by no means complete, and if I encounter any sonically interesting objects I'll be sure to record them and add them in as well. I may also continue to scour my 409 library as there are a lot of files in there that may come of use.

One other thing of note- I was using Audacity to record the sounds and it turns out I made an error with some of my recordings. When I was exporting the chopped up audio I was mistakenly using "Export as WAV" rather than "Export Selected Audio," which causes some of the recordings I did to hold the entire track rather than the portion cut down to the sample itself. Objects affected by this include: candle jar, cardboard tube, gingersnap box, ice, salt shaker, Yeti bottle, and rubber band. I'll spend some time the following week cutting these samples back down to what I had originally intended.

## 1/31

Took time today to correct the mistake I made last week around saving entire tracks of samples instead of individual samples. Huge credit to the [Nyquist Effect Audacity plugin Trim Silence](https://wiki.audacityteam.org/wiki/Nyquist_Effect_Plug-ins#Trim_Silence) for speeding up this process immensely. Trim silence takes an audio clip and removes silence below a certain threshold from *only* the start and the end of the clip. Perfect for cleaning up the tracks that were relatively clean and only had silence between them. I ended up running all of my samples through trim silence to get rid of any extra silence. The settings I used were a threshold of -48 dB with 0 sec of silence left at both the start and end.

An interesting way to put it is, prior to clean up, the `SoundLibrary` folder was ~170 MB, and after it was ~67 MB, so that's just over 100 MB of silence removed. Even then this estimate is slightly conservative as I went back through my raw recordings and added in a few more samples from the gingersnap box, ice, rubberband, salt shaker, and Yeti bottle.