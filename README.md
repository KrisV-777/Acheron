# Acheron

A SKSE64 Death Alternative Framework for TESV Skyrim, sitting on top of native damage calcuations to create custom and extensible game over events, reducing the need to reload game saves upon losing in combat and adding new ways to interact with NPCs.

For documentation on how to interact with this plugin see the [wiki](https://krisv-777.github.io/Acheron/).  
Alternative download mirror on [Nexus Mods](https://www.nexusmods.com/skyrimspecialedition/mods/108159).

## Requirements
* [xmake](https://xmake.io/#/)
	* Add this to your `PATH`
* [PowerShell](https://github.com/PowerShell/PowerShell/releases/latest)
* [Visual Studio Community 2022](https://visualstudio.microsoft.com/)
	* Desktop development with C++
* [Creation Kit](https://store.steampowered.com/app/1946180/Skyrim_Special_Edition_Creation_Kit/)
* [Spriggit CLI](https://github.com/Mutagen-Modding/Spriggit)
* Papyrus Sources
    * SkyUI SDK 5.1: [GitHub][SUI-GitHub]

## Building

### Clone
```
git clone https://github.com/KrisV-777/Acheron.git
cd Acheron
git submodule update --init --recursive
```

### Configure
Before building you must provide the following options: **spriggit_path**, **papyrus_path**, **papyrus_include**, and **papyrus_gamesource**.
These can be provided using either:

1. Environment variables (optionally loaded from `.env`)
   - See `.env.example` for variables/descriptions.
   - Copy to `.env` and edit the values.
   - Run `xmake f -c` after making changes to load the new values.
   - Alternate files can be loaded with `xmake f -c --dotenv=.env.other`

2. Command-line configure
   - Set options when configuring with `xmake f`:
```sh
xmake f -m release \
	--spriggit_path="path\to\Spriggit.CLI" \
	--papyrus_path="path\to\Papyrus Compiler" \
	--papyrus_include="path\to\ModOrganizer\mods" \
	--papyrus_gamesource="path\to\Skyrim Special Edition\Data"
```

### Build

```sh
# Create the Papyrus Project (.ppj) & Build
./bootstrap.bat
# Build the project directly
xmake
```

### Install

If `install_path` and `auto_install` are configured, files will be automatically coppied to `install_path` after a successful build. Otherwise install can be run manually using:
```sh
xmake install -o INSTALLDIR
```

## Packaging
Package the project into a `.7z` distribution using:
```
xmake pack
```
The file will be located in `build\xpack\`.

## Papyrus Project Generation

Generate a papyrus project file for IDE integration using:
```sh
xmake papyrus.project papyrus
```
