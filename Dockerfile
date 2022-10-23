from debian:bullseye

RUN apt update
RUN apt install -y build-essential libcurl4-openssl-dev liblzma-dev git python3 python3-pip git-lfs python-dev-is-python3 libssl-dev
RUN apt install -y gcc g++
RUN cd /tmp \
 && git clone -b r5.3.2 --depth=1 https://github.com/mongodb/mongo

RUN cd /tmp/mongo \
 && python3 -m pip install -r etc/pip/compile-requirements.txt

RUN cd /tmp/mongo \
 && export flags='' \
 && case "$(dpkg --print-architecture)" in \
		amd64) flags='' ;; \
		# arm64) flags='CCFLAGS="-march=armv8-a+fp+simd" CFLAGS="-march=armv8-a+fp+simd" --use-hardware-crc32=off' ;; \
		arm64) flags='CCFLAGS="-march=armv8-a" CFLAGS="-march=armv8-a" --use-hardware-crc32=off' ;; \
	esac \
 && echo ${flags} \
 && python3 buildscripts/scons.py ${flags} install-all
