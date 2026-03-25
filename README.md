# Acheron

A SKSE64 Death Alternative Framework for TESV Skyrim, allowing custom game over events to play in place of the vanilla "die and reload save" behaviour.

Concretely, Acheron sits on top of the game's native damage calculations, allowing it to intercept and negate damage sources such as spell, weapon or physics damage. Should the player - or any NPC (configurable) - take lethal damage, Acheron will attempt to start a unique game over event and - if such an event is found and successfully started - negate any damage from the current source and end combat.  
The concrete implementation of the game over is then handled by the started event, allowing a dynamic and open ended consequence system which can be freely expanded by independent authors.

NPC's can also be processed by Acheron, which puts them into a special bleedout state (defeat). Interacting with such NPCs opens a menu which allows for special interactions with that NPC (such as resqueing or executing them). This system too can be freely expanded by independent authors. 

For documentation on how to interact with this plugin see the [wiki](https://github.com/Scrabx3/Acheron-SKSE/wiki).  
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
