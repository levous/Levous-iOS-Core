default:
  # Set default make action here

# If you need to clean a specific target/configuration: $(COMMAND) -target $(TARGET) -configuration DebugOrRelease -sdk $(SDK) clean
clean:
	-rm -rf build/*

test:
	GHUNIT_CLI=1 xcodebuild -target LevousCoreTests -configuration Debug -sdk iphonesimulator4.3 build


