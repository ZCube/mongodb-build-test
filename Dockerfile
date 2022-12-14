# syntax=docker/dockerfile:1.3-labs
from ghcr.io/zcube/mongodb-build-test:builder-${TARGETARCH}

ARG MONGO_MAJOR_VERSION=v5
ARG MONGO_VERSION=5.3.2

RUN mkdir -p /opt/work

RUN --mount=type=cache,id=mongo-${MONGO_MAJOR_VERSION},target=/opt/work/,sharing=locked \
    cd /opt/work \
 && git -C "mongo" pull https://github.com/mongodb/mongo r${MONGO_VERSION} || git clone -b r${MONGO_VERSION} --depth=1 https://github.com/mongodb/mongo mongo

RUN --mount=type=cache,id=mongo-${MONGO_MAJOR_VERSION},target=/opt/work/,sharing=locked \
    cd /opt/work/mongo \
 && python3 -m pip install -r etc/pip/compile-requirements.txt

# raspberrypi 4 :fp asimd evtstrm crc32 cpuid
# nanopi r4s :fp asimd evtstrm aes pmull sha1 sha2 crc32 cpuid
# apple m1 :fp asimd evtstrm aes pmull sha1 sha2 crc32 atomics fphp asimdhp cpuid asimdrdm jscvt fcma
#           lrcpc dcpop sha3 asimddp sha512 asimdfhm dit uscat ilrcpc flagm ssbs sb paca pacg dcpodp f
#           lagm2 frint
# odroid m1 : fp asimd evtstrm aes pmull sha1 sha2 crc32 atomics fphp asimdhp cpuid asimdrdm lrcpc dcpop asimddp

RUN --mount=type=cache,id=mongo-${MONGO_MAJOR_VERSION},target=/opt/work/,sharing=locked \
    cd /opt/work/mongo \
 && export flags='' \
 && case "$(dpkg --print-architecture)" in \
		amd64) flags='' ;; \
		# arm64) flags='CCFLAGS="-march=armv8-a+fp+simd" CFLAGS="-march=armv8-a+fp+simd" --use-hardware-crc32=off' ;; \
		# arm64) flags='CCFLAGS="-march=armv8-a" CFLAGS="-march=armv8-a" --use-hardware-crc32=off' ;; \
		arm64) flags='CCFLAGS="-march=armv8-a+fp+crc+simd" CFLAGS="-march=armv8-a+fp+crc+simd"' ;; \
	esac \
 && echo ${flags} \
 && python3 buildscripts/scons.py ${flags} install-servers
