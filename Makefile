TLNET=http://texlive.texjp.org/2023/tlnet
KETTEXTEMP=$(shell pwd)/Work

all:
	@egrep -h "^[-_A-z0-9]*:" Makefile | sort

.PHONY: clean
clean:
	rm -rf $(KETTEXTEMP)
	rm -f install-tl-unx.tar.gz
	rm -f installation.profile
	find . -name "*~" -delete

.PHONY: distclean
distclean: clean
	rm -f windows/texinstwin.zip

.PHONY: macos
macos: macos/KeTTeX.app
	TLNET=$(TLNET) KETTEXTEMP=$(KETTEXTEMP) ./Build-kettex.sh

.PHONY: macos/KeTTeX.app
macos/KeTTeX.app: macos/appbundler.sh macos/runketcindy.sh
	./macos/appbundler.sh

.PHONY: windows
windows:
	WITH_WINDOWS=1 TLNET=$(TLNET) KETTEXTEMP=$(KETTEXTEMP) ./Build-kettex.sh

.PHONY: linux
linux:
	WITH_LINUX=1 TLNET=$(TLNET) KETTEXTEMP=$(KETTEXTEMP) ./Build-kettex.sh

.PHONY: freebsd
freebsd:
	WITH_FREEBSD=1 TLNET=$(TLNET) KETTEXTEMP=$(KETTEXTEMP) ./Build-kettex.sh

.PHONY: kettex-macos kettex-windows kettex-linux kettex-freebsd
kettex-%: %
KeTTeX-macos-$(shell date +%Y%m%d).dmg:         kettex-macos
KeTTeX-windows-$(shell date +%Y%m%d).zip:       kettex-windows
KeTTeX-linux-$(shell date +%Y%m%d).tar.zst:     kettex-linux
KeTTeX-freebsd-$(shell date +%Y%m%d).tar.zst:   kettex-freebsd

## end of file
