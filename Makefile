PRODUCT = WannabeEdgerunnerRecovery

all: clean build-archive build-scripts build-tweaks

.\build\obj\$(PRODUCT): archive/$(PRODUCT)/
	MKDIR ".\build\obj\$(PRODUCT)\"
	WolvenKit.CLI.exe cr2w .\archive\ -o .\build\obj\$(PRODUCT)\ -d
.\build\bin\$(PRODUCT).archive.xl: .\archive\$(PRODUCT).yml:
	COPY ".\archive\$(PRODUCT).yml" ".\build\bin\$(PRODUCT).archive.xl"
build-archive: .\build\obj\$(PRODUCT) .\build\$(PRODUCT).archive.xl
	MKDIR ".\build\bin\" || CMD /d/c
	WolvenKit.CLI.exe pack .\build\obj\$(PRODUCT)\ -o .\build\bin\archive

build-scripts: .\scripts
	MKDIR ".\build\bin\r6\$(PRODUCT)\scripts\" || CMD /d/c
	COPY ".\scripts\" ".\build\bin\r6\$(PRODUCT)\scripts\" || CMD /d/c

build-tweaks: .\tweaks
  MKDIR ".\build\bin\r6\$(PRODUCT)\tweaks\" || CMD /d/c
	COPY ".\tweaks\" ".\build\bin\r6\$(PRODUCT)\tweaks\" || CMD /d/c

clean:
	RMDIR /S /Q ".\build"
