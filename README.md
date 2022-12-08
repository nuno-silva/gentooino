# Gentooino

[![Docker Pulls](https://img.shields.io/docker/pulls/nuno351/gentooino.svg?maxAge=604800)][nuno351/gentooino]

[Gentoo](https://www.gentoo.org/)-based image containing:

* the [Arduino Core for AVR](https://github.com/arduino/ArduinoCore-avr)
* [avr-gcc](https://gcc.gnu.org/wiki/avr-gcc) compiled using [crossdev](https://wiki.gentoo.org/wiki/Crossdev)
* git, make, etc

Image is published as [nuno351/gentooino].

[![nuno351/gentooino](https://dockeri.co/image/nuno351/gentooino)](https://hub.docker.com/r/nuno351/gentooino)

## Why

You can use this image to:

- build Arduino sketches using you own Makefile(s) (see also [arduino-cli](https://github.com/arduino/arduino-cli))
- compile code to run on [AVR microcontrollers](https://en.wikipedia.org/wiki/AVR_microcontrollers)
- ...

## Building the image

```bash
nice bash build.sh
```

[nuno351/gentooino]: https://hub.docker.com/r/nuno351/gentooino/
