TLNET=http://texlive.texjp.org/2023/tlnet
KETTEXTEMP=$(shell pwd)/Work

SRCS=\
	Build-kettex.sh \
	$(MACOSSRCS) \
	$(WINDOWSSRCS)
MACOSSRCS=\
	macos/appbundler.sh \
	macos/runketcindy.sh
WINDOWSSRCS=\
	windows/kettex.cmd \
	windows/kettexinst.cmd.in

all:
	@egrep -h "^[-_A-z0-9]*:" Makefile | sort

.PHONY: clean
clean:
	rm -rf $(KETTEXTEMP)
	rm -f install-tl-unx.tar.gz
	find . -name "*~" -delete

.PHONY: distclean
distclean: clean
	rm -rf macos/KeTTeX.app
	# rm -f texinstwin.zip
	rm -f KeTTeX-{macos,windows,linuxfreebsd}-20*.{dmg,zip,tar.zst}

.PHONY: macos
macos: macos/KeTTeX.app $(SRCS)
	TLNET=$(TLNET) KETTEXTEMP=$(KETTEXTEMP) ./Build-kettex.sh

.PHONY: macos/KeTTeX.app
macos/KeTTeX.app: $(MACOSSRCS)
	./macos/appbundler.sh

.PHONY: windows
windows: $(SRCS)
	WITH_WINDOWS=1 TLNET=$(TLNET) KETTEXTEMP=$(KETTEXTEMP) ./Build-kettex.sh

.PHONY: linuxfreebsd
linuxfreebsd: $(SRCS)
	WITH_LINUX=1 TLNET=$(TLNET) KETTEXTEMP=$(KETTEXTEMP) ./Build-kettex.sh

.PHONY: kettex-macos kettex-windows kettex-linuxfreebsd
kettex-%: %
KeTTeX-macos-$(shell date +%Y%m%d).dmg:         kettex-macos
KeTTeX-windows-$(shell date +%Y%m%d).zip:       kettex-windows
KeTTeX-linuxfreebsd-$(shell date +%Y%m%d).tar.zst:     kettex-linuxfreebsd

## end of file
