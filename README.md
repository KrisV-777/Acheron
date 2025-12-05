# Acheron

SKSE64 plugin to alter and expand death in Skyrim by adding various alternative condition to "die" and replace "dying" with custom events.

For documentation on how to interact with this plugin see the [wiki](https://github.com/Scrabx3/Acheron-SKSE/wiki).  
Download mirror on [Nexus Mods](https://www.nexusmods.com/skyrimspecialedition/mods/108159).

## Core Features
* Native interception of health damaging code and conditional damage nullification
* Additional, customizable ways of going game over fluently integrated into native code
* Expandable event system to create new game-over events, other than the default "reload save" approach
* NPCs may be put in a similar "near death" state and can be interacted with using a custom made, expandable user interface

## Requirements
* [xmake](https://xmake.io/#/)
	* Add this to your `PATH`
* [PowerShell](https://github.com/PowerShell/PowerShell/releases/latest)
* [Visual Studio Community 2022](https://visualstudio.microsoft.com/)
	* Desktop development with C++
* [CommonLibSSE](https://github.com/powerof3/CommonLibSSE/tree/dev)
	* You need to build from the powerof3/dev branch
* Create Environment Variables:
  * `XSE_TES5_MODS_PATH`: Path to your MO2/Vortex `mods` folder
  * `XSE_TES5_GAME_PATH`: Path to your SSE install directory

## Building
```
git clone https://github.com/KrisV-777/Acheron.git
cd Acheron
git submodule update --init --recursive
xmake f -m release [
	--skyrim_ae=(y/n)		# build 1.5 or 1.6
	--compile=(y/n)			# compile papyrus scripts & package a release.zip
	--copy_to_papyrus=(y/n)		# create/update a mod instance
]
xmake
```

