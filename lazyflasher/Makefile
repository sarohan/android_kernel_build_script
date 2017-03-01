NAME ?= enigma

KERNEL ?= kernel

VERSION ?= rX

DEVICE ?= athene

ZIP := $(NAME)-$(KERNEL)-$(DEVICE)-$(VERSION).zip

EXCLUDE := Makefile README.md *.git* "$(NAME)-"*.zip*

all: $(ZIP)

$(ZIP):
	@echo "Creating ZIP: $(ZIP)"
	@zip -r9 "$@" . -x $(EXCLUDE)
	@echo "Done."

clean:
	@rm -vf "$(NAME)-"*.zip*
	@echo "Done."
