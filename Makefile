BUILD_DIR := ./build
SRC_DIR := ./src

project_online_home := https://github.com/kuflierl/Blocklists
project_rawonline_root := https://raw.githubusercontent.com/kuflierl/Blocklists/main

update_date := $(shell date -u +"%D")

# get source files

DOMAINSRCS := $(shell find $(SRC_DIR) -name 'domainlist')
EASYLISTSRCS := $(shell find $(SRC_DIR) -name 'easylist')
UBLOCKSRCS := $(shell find $(SRC_DIR) -name 'ublocklist')

DOMAINOBJS := $(DOMAINSRCS:./%=$(BUILD_DIR)/%.o)
EASYLISTOBJS := $(EASYLISTSRCS:%=$(BUILD_DIR)/%.o)
UBLOCKOBJS := $(UBLOCKSRCS:%=$(BUILD_DIR)/%.o)

N_SP_DOMAINOBJS := $(filter-out $(BUILD_DIR)/src/Special/%,$(DOMAINOBJS))
N_SP_EASYLISTOBJS := $(filter-out $(BUILD_DIR)/src/Special/%,$(EASYLISTOBJS))
N_SP_UBLOCKOBJS := $(filter-out $(BUILD_DIR)/src/Special/%,$(UBLOCKOBJS))

HOSTFILES := $(DOMAINSRCS:$(SRC_DIR)/%/domainlist=$(BUILD_DIR)/Host/%.host)
EASYLISTFILES := $(EASYLISTSRCS:$(SRC_DIR)/%/easylist=$(BUILD_DIR)/Easylist/%.easylist)
UBLOCKFILES := $(UBLOCKSRCS:$(SRC_DIR)/%/ublock=$(BUILD_DIR)/Ublock/%.ublock)

.PHONY: all
all: build-hosts
$(BUILD_DIR)/%easylist.o: %easylist
	mkdir -p $(dir $@)
	grep -o '^[^!#][^#]*' $< | \
  awk '!a[$$0]++' |

$(BUILD_DIR)/%easydomainlist.o: $(BUILD_DIR)/%domainlist.o
	mkdir -p $(dir $@)
	sed 's/^.*$/||&^/' $< > $@

#.SECONDARY: $(BUILD_DIR)/%domainlist.o
$(BUILD_DIR)/%domainlist.o: %domainlist
	mkdir -p $(dir $@)
  #	grep -o '^[^!#][^#]*' $<
	grep -o '^[^#! ]*' $< | \
	awk '!a[$$0]++' | \
	awk -F "." '{for(i=NF; i > 1; i--) printf "%s.", $$i; print $$1}' | \
  sort | \
  awk -F "." '{for(i=NF; i > 1; i--) printf "%s.", $$i; print $$1}' > $@

#.SECONDARY: $(BUILD_DIR)/header/Host/%.host.header
$(BUILD_DIR)/header/Host/%.host.header: $(BUILD_DIR)/src/%/domainlist.o
	mkdir -p $(dir $@)
	cat templates/host | \
	title="$(@F:%.header=%)" \
	update_date="$(update_date)" \
	update_url="$(project_rawonline_root)/$(BUILD_DIR:./%=%)/Host/$(*).host" \
	project_home="$(project_online_home)" \
	uniq_domains=`cat $^ | wc -l` \
	envsubst > $@

#.SECONDARY: $(BUILD_DIR)/header/all.host.header
$(BUILD_DIR)/header/all.host.header: $(N_SP_DOMAINOBJS)
	mkdir -p $(dir $@)
	cat templates/host | \
	title="$(@F:%.header=%)" \
	update_date="$(update_date)" \
	update_url="$(project_rawonline_root)/$(BUILD_DIR:./%=%)/all.host)" \
	project_home="$(project_online_home)" \
	uniq_domains=`cat $^ | wc -l` \
	envsubst > $@

# Build hostfiles (standard)
$(BUILD_DIR)/Host/%.host: $(BUILD_DIR)/header/Host/%.host.header $(BUILD_DIR)/src/%/domainlist.o
	mkdir -p $(dir $@)
	cat $< > $@
	sed -e 's/^/0.0.0.0 /' $(filter-out $<,$^) >> $@

$(BUILD_DIR)/all.host: $(BUILD_DIR)/header/all.host.header $(N_SP_DOMAINOBJS)
	mkdir -p $(dir $@)
	cat $< > $@
	cat $(filter-out $<,$^) | awk '!a[$$0]++' | \
	sed -e 's/^/0.0.0.0 /' >> $@

.PHONY: build-hosts
build-hosts: $(HOSTFILES) $(BUILD_DIR)/all.host

.PHONY: clean
clean:
	rm -r $(BUILD_DIR)
.PHONY: dumpvar
dumpvar:
	@echo "N_SP_DOMAINOBJS: $(N_SP_DOMAINOBJS)"
