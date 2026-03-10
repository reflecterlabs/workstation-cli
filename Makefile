.PHONY: install uninstall test clean lint

PREFIX ?= /usr/local
BINDIR = $(PREFIX)/bin

install:
	@echo "Installing Workstation CLI..."
	@mkdir -p $(BINDIR)
	@cp bin/workstation $(BINDIR)/
	@chmod +x $(BINDIR)/workstation
	@echo "Installed to $(BINDIR)/workstation"

uninstall:
	@echo "Uninstalling Workstation CLI..."
	@rm -f $(BINDIR)/workstation
	@echo "Uninstalled"

test:
	@./tests/run-tests.sh

clean:
	@rm -rf tests/tmp.*

lint:
	@shellcheck bin/workstation || echo "Install shellcheck for linting"
