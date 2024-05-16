BUILD_DIR := ./_generated
$(BUILD_DIR)/resources.md:
	mkdir -p _generated
	sh _make/generate_resources.sh > $(BUILD_DIR)/resources.md

.PHONY: clean
clean:
	rm -r $(BUILD_DIR)
