HOMEDIRFILES=\
	.config/i3 \
	.fonts \
	.gtkrc-2.0 \
	.gvimrc \
	.vim \
	.vimrc \

SYSTEMFILES=\
	/usr/share/X11/xorg.conf.d/50-leopold.conf \
	/usr/share/X11/xorg.conf.d/50-marble.conf \

VIMCOLDIR=home/.vim/colors
FONTDIR=home/.fonts

.PHONY: all
all: downloads

# Use symlinks for files in the home directory. Allow existing symlinks to be
# overwritten.
#
# Copy system wide files. Backup existing files.
.PHONY: install
install: all
	@for f in $(HOMEDIRFILES) ; do \
		if [ -h $(HOME)/$$f ] ; then \
			ln -snf $(PWD)/home/$$f $(HOME)/$$f ; \
		elif [ -e $(HOME)/$$f ] ; then \
			echo "Target exists:" ; \
			ls -ld $(HOME)/$$f ; \
		else \
			ln -sn $(PWD)/home/$$f $(HOME)/$$f ; \
		fi ; \
	done

	@for f in $(SYSTEMFILES) ; do \
		if ! diff -q $(PWD)$$f $$f ; then \
			if [ -e $$f ] ; then \
				echo "Backup to .backup$$f" ; \
				mkdir -p $$(dirname $(PWD)/.backup$$f) ; \
				cp $$f $(PWD)/.backup$$f ; \
			fi ; \
			sudo install -m 0644 $(PWD)$$f $$f ; \
		fi ; \
	done

BREEZY_COMMIT=1918c99e3e0e28a8940982257e49c3b874863953
SPRING_NIGHT_COMMIT=589b7822388dc4a265de325ad55036e3ddbcad62

VIM_COLOURS = \
		$(VIMCOLDIR)/lilydjwg_dark.vim;http://www.vim.org/scripts/download_script.php?src_id=17645;ff8b7caef2d110a5c230877c809d5aa9de10641876493a81bb747b9ef40ef96e \
		$(VIMCOLDIR)/breezy.vim;https://raw.githubusercontent.com/fneu/breezy/$(BREEZY_COMMIT)/colors/breezy.vim;0b3111d20d82e1894faa9793815bddb98fc3105449ba98beb4e2524faa6ce4eb \
		$(VIMCOLDIR)/spring-night.vim;https://github.com/rhysd/vim-color-spring-night/raw/$(SPRING_NIGHT_COMMIT)/colors/spring-night.vim;174775ef5aa93f6b0cd095ff66aae575bb60b1dfd47da347a0b01de9bb32ec01 \

INCONSOLATA_COMMIT=d0056392ff35d675b135a57c769256b5e6212f7a
HACK_VERSION=v2.020
HACK_URL=https://raw.githubusercontent.com/chrissimpkins/Hack/$(HACK_VERSION)/build/ttf/

FONTS = \
		$(FONTDIR)/Inconsolata-Bold.ttf;https://github.com/google/fonts/raw/$(INCONSOLATA_COMMIT)/ofl/inconsolata/Inconsolata-Bold.ttf;0db9dc0cf39efef147a7b368c98e1b7588afd2bc4d30e4c9e313f5511e599a87 \
		$(FONTDIR)/Inconsolata-Regular.ttf;https://github.com/google/fonts/raw/$(INCONSOLATA_COMMIT)/ofl/inconsolata/Inconsolata-Regular.ttf;346eff8b8292ef2b8026cf1dbea3fc0c79eba444270d38d73da895ddcba74e15 \
		$(FONTDIR)/Hack-Bold.ttf;$(HACK_URL)Hack-Bold.ttf;bb4348085a17574ea9b0977761570fe588c7ec194391b2c6691ccf291936a348 \
		$(FONTDIR)/Hack-BoldItalic.ttf;$(HACK_URL)Hack-BoldItalic.ttf;72f2fb3ea93404542089ae2fe51a9acc346d8ebc69348947be34a9fef96e3dd0 \
		$(FONTDIR)/Hack-Italic.ttf;$(HACK_URL)Hack-Italic.ttf;712b4063b07497975178b2d44ed874d687d9d68b89ac3d7788177d3dea37fb9a \
		$(FONTDIR)/Hack-Regular.ttf;$(HACK_URL)Hack-Regular.ttf;1d68825eb16e8a06efbf5017d730f3d58761c2d974fe065cb302797b4cc31422 \
		$(FONTDIR)/gohufont-2.1.tar.gz;http://font.gohu.org/gohufont-2.1.tar.gz;758d62c9350d51ae3738aff4bbcefa9ea6d173baf5b169232c895b6de3a1ba81 \

DOWNLOADS = \
		$(VIM_COLOURS) \
		$(FONTS) \

.PHONY: FORCE
FORCE:

define FETCH-AND-VERIFY =

ifeq ($$(strip $3),)
$$(error $1 missing SHA256 checksum)
endif

downloads/$$(notdir $1):
	@mkdir -p $$(dir $$@)
	@wget --quiet -O - -- $2 > $$@

downloads/.checksum_$$(notdir $1): downloads/$$(notdir $1) FORCE
	@echo "$3 $$<" > $$@

downloads/.verified_$$(notdir $1): downloads/.checksum_$$(notdir $1)
	@sha256sum -c $$< || exit 1
	@touch $$@

$1: downloads/.verified_$$(notdir $1)
	@mkdir -p $$(dir $$@)
	@cp downloads/$$(notdir $1) $$@
endef

$(foreach dl,$(DOWNLOADS),$(eval $(call FETCH-AND-VERIFY,$(word 1,$(subst ;, ,$(dl))),$(word 2,$(subst ;, ,$(dl))),$(word 3,$(subst ;, ,$(dl))))))

.PHONY: downloads
downloads: $(foreach dl,$(DOWNLOADS),$(firstword $(subst ;, ,$(dl))))
