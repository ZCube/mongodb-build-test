from debian:bullseye

RUN apt update
RUN apt install -y build-essential libcurl4-openssl-dev liblzma-dev git python3 python3-pip git-lfs python-dev-is-python3 libssl-dev
RUN apt install -y gcc g++
RUN mkdir -p /opt/work \
 && cd /opt/work \
 && git clone -b r5.3.2 --depth=1 https://github.com/mongodb/mongo

RUN cd /opt/work/mongo \
 && python3 -m pip install -r etc/pip/compile-requirements.txt

# raspberrypi 4 :fp asimd evtstrm crc32 cpuid
# nanopi r4s :fp asimd evtstrm aes pmull sha1 sha2 crc32 cpuid
# apple m1 :fp asimd evtstrm aes pmull sha1 sha2 crc32 atomics fphp asimdhp cpuid asimdrdm jscvt fcma
#           lrcpc dcpop sha3 asimddp sha512 asimdfhm dit uscat ilrcpc flagm ssbs sb paca pacg dcpodp f
#           lagm2 frint
# odroid m1 : fp asimd evtstrm aes pmull sha1 sha2 crc32 atomics fphp asimdhp cpuid asimdrdm lrcpc dcpop asimddp

RUN cd /opt/work/mongo \
 && export flags='' \
 && case "$(dpkg --print-architecture)" in \
		amd64) flags='' ;; \
		# arm64) flags='CCFLAGS="-march=armv8-a+fp+simd" CFLAGS="-march=armv8-a+fp+simd" --use-hardware-crc32=off' ;; \
		# arm64) flags='CCFLAGS="-march=armv8-a" CFLAGS="-march=armv8-a" --use-hardware-crc32=off' ;; \
		arm64) flags='CCFLAGS="-march=armv8-a+fp+crc+simd" CFLAGS="-march=armv8-a+fp+crc+simd"' ;; \
	esac \
 && echo ${flags} \
 && python3 buildscripts/scons.py ${flags} install-all
