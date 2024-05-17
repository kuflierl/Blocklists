# deployment config
project_online_home := https://github.com/kuflierl/Blocklists
project_rawonline_root := https://kuflierl.github.io/Blocklists/resources

# folder locations
BUILD_DIR := ./build
SRC_DIR := ./src

COMBINELIST_DIR := $(SRC_DIR)/combinelists
TEMPLATE_DIR := $(SRC_DIR)/templates
TEXTSOURCE_DIR := $(SRC_DIR)/textsource
WEBSOURCE_DIR := $(SRC_DIR)/websource

# dynamic data
update_date := $(shell date -u +"%D")

# get combinelist files
DOMAIN_COMBINELISTS := $(shell find $(COMBINELIST_DIR) -name '*.host')
EASYLIST_COMBINELISTS := $(shell find $(COMBINELIST_DIR) -name '*.easylist')
UBLOCK_COMBINELISTS := $(shell find $(COMBINELIST_DIR) -name '*.ublocklist')

DOMAIN_COMBINEFINALS := $(patsubst $(COMBINELIST_DIR)/%,$(BUILD_DIR)/%,$(DOMAIN_COMBINELISTS))

define deploader_template =
 $(patsubst $(COMBINELIST_DIR)/%,$(BUILD_DIR)/combineobj/%.deploader,$(1)): $(shell sh tools/getdeps-host.sh $(1))
endef

.PHONY: all
all: build_hostfiles build_site

$(foreach dcl,$(DOMAIN_COMBINELISTS),$(eval $(call deploader_template,$(dcl))))

$(BUILD_DIR)/%.host: $(BUILD_DIR)/combineobj/%.host.header $(BUILD_DIR)/combineobj/%.host.o
	mkdir -p $(dir $@)
	cat $< > $@
	cat $(filter-out $<,$^) | \
	awk -F "." '{for(i=NF; i > 1; i--) printf "%s.", $$i; print $$1}' | \
  sort | \
  awk -F "." '{for(i=NF; i > 1; i--) printf "%s.", $$i; print $$1}' | \
	sed -e 's/^/0.0.0.0 /' >> $@

$(BUILD_DIR)/combineobj/%.host.header: $(BUILD_DIR)/combineobj/%.host.o
	mkdir -p $(dir $@)
	cat $(TEMPLATE_DIR)/host | \
	title="$(@F:%.header=%)" \
	update_date="$(update_date)" \
	update_url="$(project_rawonline_root)/$(*).host" \
	project_home="$(project_online_home)" \
	uniq_domains=`cat $< | wc -l` \
	envsubst > $@

$(BUILD_DIR)/combineobj/%.host.o: $(COMBINELIST_DIR)/%.host $(BUILD_DIR)/combineobj/%.host.deploader
	mkdir -p $(dir $@)
	touch $@
	regex='^domain(black|white)list (text|web)source [\w-]+(\/[\w-]+)*$$'; \
        sed '1!G;h;$$!d' "$<" | \
	while IFS="" read -r p || [ -n "$$p" ]; \
	do \
	  echo "$$p" | grep -oPq "$$regex" || continue; \
	  p1=`echo $$p | awk '{print $$1;}'`; \
	  p2=`echo $$p | awk '{print $$2;}'`; \
	  p3=`echo $$p | awk '{print $$3;}'`; \
	  out="$(BUILD_DIR)/$$p2/$$p3.$$p1.o"; \
	  if [ "$$p1" = 'domainblacklist' ]; \
	    then sort -mu $@ $$out > $@.tmp; \
	  elif [ "$$p1" = 'domainwhitelist' ]; \
	    then comm -23 $@ $$out > $@.tmp; \
	  fi; \
	  mv $@.tmp $@; \
	done
	# sed reverses the lines

#todo autogen deploader using eval!!
#https://www.gnu.org/software/make/manual/html_node/Eval-Function.html
$(BUILD_DIR)/combineobj/%.host.deps: $(COMBINELIST_DIR)/%.host
	while IFS="" read -r p || [ -n "$$p" ] \
	do \
	  [[ "$$p" =~ ^domain(black|white)list (text|web)source \w+(\/\w+)*$$ ]] || continue \
	  p1=`echo $$p | awk '{print $$1;}')` \
	  p2=`echo $$p | awk '{print $$2;}')` \
	  p3=`echo $$p | awk '{print $$3;}')` \
	  out="$(BUILD_DIR)/$$p2/$$p3.$$p1.o" \
	  echo "$$out" >> $@ \
	done < $<

# textsource domainlists extract domains
$(BUILD_DIR)/textsource/%.domainblacklist.o: $(TEXTSOURCE_DIR)/%/domainblacklist
	mkdir -p $(dir $@)
	# filter out everything but the domains especialy comments and spaces
	grep -sh -o '^[^#!\/ ]*' $^ $<.* | sort -u > $@
$(BUILD_DIR)/textsource/%.domainwhitelist.o: $(TEXTSOURCE_DIR)/%/domainwhitelist
	mkdir -p $(dir $@)
	# filter out everything but the domains especialy comments and spaces
	grep -sh -o '^[^#!\/ ]*' $^ $<.* | sort -u > $@

# websource get contents
$(BUILD_DIR)/websource-orig/%: $(WEBSOURCE_DIR)/%
	mkdir -p $(dir $@)
	# filter out comments and download into the file
	grep -o '^[^#!\/ ].*' $< | xargs -r -n1 wget -O - -q > $@

# websource domainlists extract domains
# todo use Canned Recipes
# filter out everything but the domains especialy comments and spaces
# awk cleans up the delimiters, strips the string and prints everythin in a new line
# xargs -n1 would work but uses a crazy amount of cpu cycles
$(BUILD_DIR)/websource/%.domainblacklist.o: $(BUILD_DIR)/websource-orig/%.domainblacklist
	mkdir -p $(dir $@)
	grep -oP '^[ \t]*\d{1,3}(\.\d{1,3}){3}\K([ \t]+[^#!\/ \t\n]*)+' $< | awk 'OFS="\n" {if($$NF > 0) {$$1=$$1;print $$0}}' | sort -u > $@
$(BUILD_DIR)/websource/%.domainwhitelist.o: $(BUILD_DIR)/websource-orig/%.domainwhitelist
	mkdir -p $(dir $@)
	grep -oP '^[ \t]*\d{1,3}(\.\d{1,3}){3}\K([ \t]+[^#!\/ \t\n]*)+' $< | awk 'OFS="\n" {if($$NF > 0) {$$1=$$1;print $$0}}' | sort -u > $@

.PHONY: generate_site
generate_site: build_hostfiles
	mkdir -p pages/resources
	cp -r $(BUILD_DIR)/Hosts pages/resources/
	make -C pages generate

.PHONY: build_site
build_site: generate_site
	make -C pages build

.PHONY: build_hostfiles
build_hostfiles: $(DOMAIN_COMBINEFINALS)

.PHONY: clean_build
clean_build:
	rm -rf $(BUILD_DIR)

.PHONY: clean_pages
clean_pages:
	make -C pages clean

.PHONY: clean
clean: clean_build clean_pages

.PHONY: dumpvar
dumpvar:
	@echo "DOMAIN_COMBINELISTS: $(DOMAIN_COMBINELISTS)"
	@echo "DOMAIN_COMBINEFINALS: $(DOMAIN_COMBINEFINALS)"
	@echo "$(call deploader_template,./src/combinelists/Hosts/all.host)"
	@echo '$(foreach dcl,$(DOMAIN_COMBINELISTS),$(call deploader_template,$(dcl)))'
