ARG DATE=latest
FROM gentoo/portage:$DATE as portage
FROM gentoo/stage3:$DATE

COPY --from=portage /var/db/repos/gentoo /var/db/repos/gentoo

ARG MAKEOPTS=-j1
ENV MAKEOPTS=$MAKEOPTS

# install git and crossdev
RUN --mount=type=tmpfs,target=/var/tmp/portage \
	echo "dev-vcs/git -perl -cgi -cvs -tk" >> /etc/portage/package.use/git \
	&& eselect news read > /dev/null \
	&& emerge -q dev-vcs/git crossdev \
	&& rm -vf /var/cache/distfiles/*.tar.*

ARG GCC=~7.5.0

# install avr-gcc with C++ support
# XXX: removing this mount in Github CI since it does not have enough RAM
# and tmpfs-size opt does not work there
RUN --mount=type=tmpfs,target=/var/tmp/portage/ \
	set -x \
	&& df -h /var/tmp/portage \
	&& mkdir -p /etc/portage/repos.conf \
	&& echo "cross-avr/gcc cxx" >> /etc/portage/package.use/cross-avr-cxx \
	&& crossdev --gcc $GCC --target avr --ov-output /usr/local/portage-crossdev \
	&& emerge --changed-use -pv cross-avr/gcc \
	&& emerge --changed-use -q cross-avr/gcc \
	&& rm -vf /var/cache/distfiles/*.tar.* \
	&& rm -vf /var/tmp/portage/* \
	&& rm -vf /var/log/portage/cross-avr-*.log \
	&& rm -vfr /usr/share/*/avr/*/locale/* \
	|| { echo Something failed, dumping logs; \
	tail -n 300 /var/log/portage/cross-avr-*.log ; \
	free -h; df -h; \
	exit 2; }

ARG ARDUINO=1.8.4
ENV ARDUINO_TAR=$ARDUINO.tar.gz

# install arduino core
RUN curl https://github.com/arduino/ArduinoCore-avr/archive/refs/tags/$ARDUINO_TAR \
	-o $ARDUINO_TAR -L \
	&& tar -C / -xf $ARDUINO_TAR \
	&& rm -v $ARDUINO_TAR \
	&& mkdir -p /usr/share/arduino/hardware/arduino \
	&& ln -s /ArduinoCore-avr-* /usr/share/arduino/hardware/arduino/avr \
	&& ls /usr/share/arduino/hardware/arduino/avr/{,cores,variants}
