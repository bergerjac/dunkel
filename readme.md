# dunkel

Berlin, DE | Fr 05.12.14

arduino, processing (Java) code for [dunkel launch party](https://www.facebook.com/events/298331117031627/).

## authors

[Stephen Bontly](http://www.stephenbontly.com/) | video production | interface | electronics | idea

[Jacob Berger](https://careers.stackoverflow.com/jberger) | code | other nerdy shit

### summary

 - 20-minute, 5½-minute, 15-sec custom-made videos
    - images and pictures shot and edited by Stephen Bontly
    - video concept and production via Adobe After Effects by Stephen Bontly
 - human interface (see /[content](content)/ folder)
    - user can adjust video playback speed
    - user can press one of 6 buttons; each button press triggers the DJ's name to scroll across the screen
    - (keyboard keys 1-6 mapped to each DJ; up/down arrows mapped to movie playback speed)
 - arduino
    - inputs: 1 POT, 6 buttons wired as human interface inputs
    - output: data via serial port every 100ms
 - processing
    - movie playback on a loop
    - accepts input from arduino, keyboard

### development

 warning: coded over a 3-day hack attack -- it just works

 - arduino: `./arduino/arduino.ino`
 - processing: `./processing_start/processing_start.pde`
    1. set config variables near top of file
    1. expected video: `./processing_start/data/test2.mp4` (great name, eh)
