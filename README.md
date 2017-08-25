# xrdp-builder-on-RASPBIAN-STRETCH
The shell script that build xrdp on RASPBIAN STRETCH with pulseaudio sink module.

If you got no audio, restart pulseaudio daemon.

`pulseaudio --kill`
`pulseaudio --start`

## TinkerOS
Also available on TinkerOS v1.8 but adds some packages before.

`sudo apt install git automake libltdl-dev libpulse-dev`
