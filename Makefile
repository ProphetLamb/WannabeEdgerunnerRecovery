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

DEPLOY_SCRIPTS_DIR = $(DEPLOY_DIR)\bin\r6\scripts
DEPLOY_TWEAKS_DIR = $(DEPLOY_DIR)\bin\r6\tweaks
DEPLOY_ARCHIVE_DIR = $(DEPLOY_DIR)\archive\pc\mod

# ----------------------------------------
# Targets
# ----------------------------------------
# Clean builds the mod
all: clean build

# Build the mod to .\build\bin
build: build-scripts build-tweaks build-archive

build-scripts: .\scripts\*
	MKDIR "$(BUILD_SCRIPTS_DIR)"
	COPY ".\scripts\" "$(BUILD_SCRIPTS_DIR)\" || CMD /d/c

build-tweaks: .\tweaks\*
  MKDIR "$(BUILD_TWEAKS_DIR)\"
	COPY ".\tweaks\" "$(BUILD_TWEAKS_DIR)\" || CMD /d/c

build-archive: .\archive\*
	MKDIR ".\build\obj\$(PRODUCT)\"
	WolvenKit.CLI.exe cr2w .\archive\ -o .\build\obj\$(PRODUCT)\ -d

	MKDIR "$(BUILD_ARCHIVE_DIR)\"
	COPY ".\archive\$(PRODUCT).yml" "$(BUILD_ARCHIVE_DIR)\$(PRODUCT).archive.xl"

	WolvenKit.CLI.exe pack .\build\obj\$(PRODUCT)\ -o $(BUILD_ARCHIVE_DIR)

# Deploy the mod to the game
deploy: deploy-scripts deploy-tweaks deploy-archive

deploy-scripts: build-scripts
	RMDIR /S /Q "$(DEPLOY_DIR)\r6\scripts\$(PRODUCT)" || CMD /d/c
  MKDIR "$(DEPLOY_DIR)\r6\scripts\$(PRODUCT)"
	COPY "$(BUILD_SCRIPTS_DIR)" "$(DEPLOY_SCRIPTS_DIR(\$(PRODUCT)" || CMD /d/c

deploy-tweaks: build-tweaks
	RMDIR /S /Q "$(DEPLOY_DIR)\r6\scripts\$(PRODUCT)" || CMD /d/c
  MKDIR "$(DEPLOY_DIR)\r6\tweaks\$(PRODUCT)"
	COPY "$(BUILD_TWEAKS_DIR)" "$(DEPLOY_TWEAKS_DIR)\$(PRODUCT)" || CMD /d/c

deploy-archive: build-archive
	COPY /Y /B $(BUILD_ARCHIVE_DIR)\$(PRODUCT).archive $(DEPLOY_ARCHIVE_DIR)\$(PRODUCT).archive
	COPY /Y /B $(BUILD_ARCHIVE_DIR)\$(PRODUCT).archive.xl $(DEPLOY_ARCHIVE_DIR)\$(PRODUCT).archive.xl

# Removes all build files
clean:
	RMDIR /S /Q ".\build" || CMD /d/c
