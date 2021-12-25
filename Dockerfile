ARG DATE=latest
FROM gentoo/portage:$DATE as portage
FROM gentoo/stage3:$DATE

COPY --from=portage /var/db/repos/gentoo /var/db/repos/gentoo

ARG MAKEOPTS=-j1
ENV MAKEOPTS=$MAKEOPTS

# install git and crossdev
RUN --mount=type=tmpfs,target=/var/tmp/portage \
	echo "dev-vcs/git -perl -cgi -cvs -tk" >> /etc/portage/package.use/git \
	&& emerge -q dev-vcs/git crossdev \
	&& rm -vf /var/cache/distfiles/*.tar.*

ARG GCC=~7.5.0

# install avr-gcc with C++ support
RUN --mount=type=tmpfs,target=/var/tmp/portage \
	mkdir -p /etc/portage/repos.conf \
	&& echo "cross-avr/gcc cxx" >> /etc/portage/package.use/cross-avr-cxx \
	&& crossdev --gcc $GCC --target avr --ov-output /usr/local/portage-crossdev \
	&& emerge --changed-use -pv cross-avr/gcc \
	&& emerge --changed-use -q cross-avr/gcc \
	&& rm -vf /var/cache/distfiles/*.tar.*

ARG ARDUINO=1.8.3
ENV ARDUINO_TAR=ArduinoCore-avr-$ARDUINO.tar.xz

# install arduino core
RUN curl https://github.com/arduino/ArduinoCore-avr/releases/download/$ARDUINO/$ARDUINO_TAR -o $ARDUINO_TAR -L \
	&& tar -C / -xf $ARDUINO_TAR \
	&& rm -v $ARDUINO_TAR \
	&& mkdir -p /usr/share/arduino/hardware/arduino \
	&& ln -s /ArduinoCore-avr-* /usr/share/arduino/hardware/arduino/avr
