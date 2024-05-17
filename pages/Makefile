GENERATE_DIR := ./_generated
BUILD_DIR := ./_site

.PHONY: all
all: generate build

.PHONY: generate
generate: $(GENERATE_DIR)/resources.md

.PHONY: build
build: generate install_deps
	bundle exec jekyll build

.PHONY: install_deps
install_deps:
	bundle install

$(GENERATE_DIR)/resources.md:
	mkdir -p _generated
	sh _make/generate_resources.sh > $(GENERATE_DIR)/resources.md

.PHONY: clean_generated
clean_generated:
	rm -rf $(GENERATE_DIR)

.PHONY: clean_site
clean_site:
	rm -rf $(BUILD_DIR) .jekyll-cache

.PHONY: clean_resources
clean_resources:
	rm -rf resources

.PHONY: clean
clean: clean_generated clean_site clean_resources

# for development
.PHONY: interactive_serve
interactive_serve:
	bundle exec jekyll serve -l
