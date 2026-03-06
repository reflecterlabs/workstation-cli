.PHONY: install uninstall test clean

PREFIX ?= /usr/local
BINDIR = $(PREFIX)/bin

install:
	@echo "Installing Workstation CLI..."
	@mkdir -p $(BINDIR)
	@cp bin/workstation $(BINDIR)/
	@chmod +x $(BINDIR)/workstation
	@echo "Installed to $(BINDIR)/workstation"
	@echo ""
	@echo "Next steps:"
	@echo "  1. Ensure $(BINDIR) is in your PATH"
	@echo "  2. Run 'workstation doctor' to verify"
	@echo "  3. Run 'workstation init MyOrg' to get started"

uninstall:
	@echo "Uninstalling Workstation CLI..."
	@rm -f $(BINDIR)/workstation
	@echo "Uninstalled"

test:
	@./tests/run-tests.sh

clean:
	@rm -rf tests/tmp.*

lint:
	@shellcheck bin/workstation

.PHONY: all
all: lint test
