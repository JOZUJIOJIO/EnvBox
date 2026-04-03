APP_NAME = EnvBox
BUILD_DIR = .build/release
APP_BUNDLE = $(APP_NAME).app

.PHONY: build release clean install

build:
	swift build

release:
	swift build -c release
	mkdir -p $(APP_BUNDLE)/Contents/MacOS
	mkdir -p $(APP_BUNDLE)/Contents/Resources
	cp $(BUILD_DIR)/$(APP_NAME) $(APP_BUNDLE)/Contents/MacOS/
	cp AppIcon.icns $(APP_BUNDLE)/Contents/Resources/
	@echo '<?xml version="1.0" encoding="UTF-8"?>' > $(APP_BUNDLE)/Contents/Info.plist
	@echo '<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">' >> $(APP_BUNDLE)/Contents/Info.plist
	@echo '<plist version="1.0"><dict>' >> $(APP_BUNDLE)/Contents/Info.plist
	@echo '<key>CFBundleExecutable</key><string>EnvBox</string>' >> $(APP_BUNDLE)/Contents/Info.plist
	@echo '<key>CFBundleIdentifier</key><string>com.envbox.app</string>' >> $(APP_BUNDLE)/Contents/Info.plist
	@echo '<key>CFBundleName</key><string>EnvBox</string>' >> $(APP_BUNDLE)/Contents/Info.plist
	@echo '<key>CFBundleVersion</key><string>1.0</string>' >> $(APP_BUNDLE)/Contents/Info.plist
	@echo '<key>CFBundleIconFile</key><string>AppIcon</string>' >> $(APP_BUNDLE)/Contents/Info.plist
	@echo '<key>LSUIElement</key><true/>' >> $(APP_BUNDLE)/Contents/Info.plist
	@echo '<key>LSMinimumSystemVersion</key><string>13.0</string>' >> $(APP_BUNDLE)/Contents/Info.plist
	@echo '</dict></plist>' >> $(APP_BUNDLE)/Contents/Info.plist
	@echo "Built: $(APP_BUNDLE)"

install: release
	cp -r $(APP_BUNDLE) /Applications/
	@echo "Installed to /Applications/$(APP_BUNDLE)"

clean:
	swift package clean
	rm -rf $(APP_BUNDLE)
