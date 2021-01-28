TLNET=http://texlive.texjp.org/2020/tlnet
KETTEXTEMP=$(shell pwd)/Work

all:
	@egrep -h "^[-_A-z0-9]*:" Makefile | sort

clean:
	rm -rf $(KETTEXTEMP)

macos: macos/KeTTeX.app
	TLNET=$(TLNET) KETTEXTEMP=$(KETTEXTEMP) ./Build-kettex.sh

.PHONY: macos/KeTTeX.app
macos/KeTTeX.app: macos/appbundler.sh macos/runketcindy.sh
	./macos/appbundler.sh

windows:
	WITH_WINDOWS=1 TLNET=$(TLNET) KETTEXTEMP=$(KETTEXTEMP) ./Build-kettex.sh

linux:
	WITH_LINUX=1 TLNET=$(TLNET) KETTEXTEMP=$(KETTEXTEMP) ./Build-kettex.sh

.PHONY: clean macos windows linux

## end of file
