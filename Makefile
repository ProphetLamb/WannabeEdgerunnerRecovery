# ----------------------------------------
# Parameters
# ----------------------------------------
PRODUCT = WannabeEdgerunnerRecovery
DEPLOY_DIR = D:\Program Files\Steam\steamapps\common\Cyberpunk 2077

# ----------------------------------------
# Fields
# ----------------------------------------
BUILD_SCRIPTS_DIR = .\build\bin\r6\scripts\$(PRODUCT)
BUILD_TWEAKS_DIR = .\build\bin\r6\tweaks\$(PRODUCT)
BUILD_ARCHIVE_DIR = .\build\bin\archive\pc\mod

DEPLOY_SCRIPTS_DIR = $(DEPLOY_DIR)\r6\scripts\$(PRODUCT)
DEPLOY_TWEAKS_DIR = $(DEPLOY_DIR)\r6\tweaks\$(PRODUCT)
DEPLOY_ARCHIVE_DIR = $(DEPLOY_DIR)\archive\pc\mod

# ----------------------------------------
# Targets
# ----------------------------------------
# Clean builds the mod
all: clean build

# Build the mod to .\build\bin
build: build-scripts build-tweaks build-archive

build-scripts: .\scripts\*
	:: ----------------------------------------
	:: Build "$(BUILD_SCRIPTS_DIR)"
	:: ----------------------------------------
	MKDIR "$(BUILD_SCRIPTS_DIR)"
	XCOPY ".\scripts\" "$(BUILD_SCRIPTS_DIR)\" /S /Q

build-tweaks: .\tweaks\*
	:: ----------------------------------------
	:: Build "$(BUILD_TWEAKS_DIR)"
	:: ----------------------------------------
  MKDIR "$(BUILD_TWEAKS_DIR)\"
	XCOPY ".\tweaks\" "$(BUILD_TWEAKS_DIR)\" /S /Q

build-archive: .\archive\*
	:: ----------------------------------------
	:: Build "$(BUILD_ARCHIVE_DIR)"
	:: ----------------------------------------
	MKDIR ".\build\obj\$(PRODUCT)\"
	WolvenKit.CLI.exe cr2w .\archive\ -o .\build\obj\$(PRODUCT)\ -d

	MKDIR "$(BUILD_ARCHIVE_DIR)\"
	COPY ".\archive\$(PRODUCT).yml" "$(BUILD_ARCHIVE_DIR)\$(PRODUCT).archive.xl"

	WolvenKit.CLI.exe pack .\build\obj\$(PRODUCT)\ -o $(BUILD_ARCHIVE_DIR)

# Deploy the mod to the game
deploy: deploy-scripts deploy-tweaks deploy-archive

deploy-scripts: build-scripts
	:: ----------------------------------------
	:: Deploy "$(BUILD_SCRIPTS_DIR)" to "$(DEPLOY_SCRIPTS_DIR)"
	:: ----------------------------------------
	RMDIR /S /Q "$(DEPLOY_SCRIPTS_DIR)" || CMD /d/c
  MKDIR "$(DEPLOY_SCRIPTS_DIR)" || CMD /d/c
	XCOPY "$(BUILD_SCRIPTS_DIR)" "$(DEPLOY_SCRIPTS_DIR)" /S /Q

deploy-tweaks: build-tweaks
	:: ----------------------------------------
	:: Deploy "$(BUILD_TWEAKS_DIR)" to "$(DEPLOY_TWEAKS_DIR)"
	:: ----------------------------------------
	RMDIR /S /Q "$(DEPLOY_TWEAKS_DIR)" || CMD /d/c
  MKDIR "$(DEPLOY_TWEAKS_DIR)" || CMD /d/c
	XCOPY "$(BUILD_TWEAKS_DIR)" "$(DEPLOY_TWEAKS_DIR)" /S /Q

deploy-archive: build-archive
	:: ----------------------------------------
	:: Deploy "$(BUILD_ARCHIVE_DIR)" to "$(DEPLOY_ARCHIVE_DIR)"
	:: ----------------------------------------
	COPY /Y /B "$(BUILD_ARCHIVE_DIR)\$(PRODUCT).archive" "$(DEPLOY_ARCHIVE_DIR)\$(PRODUCT).archive"
	COPY /Y /B "$(BUILD_ARCHIVE_DIR)\$(PRODUCT).archive.xl" "$(DEPLOY_ARCHIVE_DIR)\$(PRODUCT).archive.xl"

# Removes all build files
clean:
	RMDIR /S /Q ".\build" || CMD /d/c
