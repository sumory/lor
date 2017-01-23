TO_INSTALL = lib/* resty spec bin
LOR_HOME ?= /usr/local
LORD_BIN ?= /usr/local/bin

.PHONY: test install

test:
	busted spec/*

install_lor:
	@mkdir -p ${LOR_HOME}/lor
	@mkdir -p ${LOR_HOME}
	@rm -rf ${LOR_HOME}/lor/*

	@echo "install lor runtime files to "${LOR_HOME}/lor

	@for item in $(TO_INSTALL) ; do \
		cp -a $$item ${LOR_HOME}/lor/; \
	done;

	@echo "lor runtime files installed."


install_lord: install_lor
	@mkdir -p ${LORD_BIN}
	@echo "install lord cli to "${LORD_BIN}"/"

	@echo "#!/usr/bin/env resty" > tmp_lor_bin
	@echo "package.path=\""${LOR_HOME}/lor"/?.lua;;\"" >> tmp_lor_bin
	@echo "if arg[1] and arg[1] == \"path\" then" >> tmp_lor_bin
	@echo "    print(\"${LOR_HOME}/lor\")" >> tmp_lor_bin
	@echo "    return" >> tmp_lor_bin
	@echo "end" >> tmp_lor_bin
	@echo "require('bin.lord')(arg)" >> tmp_lor_bin

	@mv tmp_lor_bin ${LORD_BIN}/lord
	@chmod +x ${LORD_BIN}/lord

	@echo "lord cli installed."

install: install_lord
	@echo "lor framework installed successfully."

version:
	@lord -v

help:
	@lord -h

