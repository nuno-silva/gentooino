ARG DATE=latest
FROM gentoo/portage:$DATE as portage
FROM gentoo/stage3:$DATE
# https://docs.docker.com/engine/reference/builder/#understand-how-arg-and-from-interact
ARG DATE

COPY --from=portage /var/db/repos/gentoo /var/db/repos/gentoo

ARG MAKEOPTS=-j1
ENV MAKEOPTS=$MAKEOPTS

# install git and crossdev
RUN --mount=type=tmpfs,target=/var/tmp/portage \
	echo "dev-vcs/git -perl -cgi -cvs -tk" >> /etc/portage/package.use/git \
	&& eselect news read > /dev/null \
	&& emerge -q dev-vcs/git crossdev \
	&& rm -vf /var/cache/distfiles/*.tar.*

# gcc major version to install
ARG GCC=9

# install avr-gcc with C++ support
# XXX: removing this mount in Github CI since it does not have enough RAM
# and tmpfs-size opt does not work there
RUN --mount=type=tmpfs,target=/var/tmp/portage/ \
	set -x \
	&& df -h /var/tmp/portage \
	&& mkdir -p /etc/portage/repos.conf \
	&& echo "cross-avr/gcc cxx" >> /etc/portage/package.use/cross-avr-cxx \
	&& echo "<cross-avr/gcc-$GCC" >> /etc/portage/package.mask/cross-avr-gcc \
	&& echo ">=cross-avr/gcc-$((GCC+1))" >> /etc/portage/package.mask/cross-avr-gcc \
	&& crossdev --target avr --ov-output /usr/local/portage-crossdev \
	&& emerge --changed-use -pv cross-avr/gcc \
	&& emerge --changed-use -q cross-avr/gcc \
	&& rm -vf /var/cache/distfiles/*.tar.* \
	&& rm -vf /var/tmp/portage/* \
	&& rm -vf /var/log/portage/cross-avr-*.log \
	&& rm -fr /usr/share/*/avr/*/locale/* \
	|| { echo Something failed, dumping logs; \
	tail -n 300 /var/log/portage/cross-avr-*.log ; \
	free -h; df -h; \
	exit 2; }

ARG ARDUINO=1.8.6
ENV ARDUINO_TAR=$ARDUINO.tar.gz

ARG VERSION=dev

# install arduino core
RUN curl https://github.com/arduino/ArduinoCore-avr/archive/refs/tags/$ARDUINO_TAR \
	-o $ARDUINO_TAR -L \
	&& echo "$VERSION" >> /version \
	&& echo "gcc $GCC" >> /version \
	&& echo "arduino $ARDUINO" >> /version \
	&& echo "date $DATE" >> /version \
	&& date -u >> /version \
	&& tar -C / -xf $ARDUINO_TAR \
	&& rm -v $ARDUINO_TAR \
	&& mkdir -p /usr/share/arduino/hardware/arduino \
	&& ln -s /ArduinoCore-avr-* /usr/share/arduino/hardware/arduino/avr \
	&& ls /usr/share/arduino/hardware/arduino/avr/{,cores,variants}

# check that everything is installed
RUN git --version \
	&& sha1sum /usr/avr/include/stdlib.h \
	&& qlist -Iv cross-avr \
	&& avr-gcc --version \
	&& ls /usr/share/arduino/hardware/arduino/avr/{,cores,variants} \
	&& tail -n+1 /version
