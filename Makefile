PRODUCT = WannabeEdgerunnerRecovery

all: clean build-archive build-scripts build-tweaks

build-archive:
	MKDIR ".\build\obj\$(PRODUCT)\"
	WolvenKit.CLI.exe cr2w .\archive\ -o .\build\obj\$(PRODUCT)\ -d

	COPY ".\archive\$(PRODUCT).yml" ".\build\bin\archive\$(PRODUCT).archive.xl"

	MKDIR ".\build\bin\" || CMD /d/c
	WolvenKit.CLI.exe pack .\build\obj\$(PRODUCT)\ -o .\build\bin\archive

build-scripts: .\scripts
	MKDIR ".\build\bin\r6\$(PRODUCT)\scripts\"
	COPY ".\scripts\" ".\build\bin\r6\$(PRODUCT)\scripts\" || CMD /d/c

build-tweaks: .\tweaks
  MKDIR ".\build\bin\r6\$(PRODUCT)\tweaks\"
	COPY ".\tweaks\" ".\build\bin\r6\$(PRODUCT)\tweaks\" || CMD /d/c

clean:
	RMDIR /S /Q ".\build" || CMD /d/c
