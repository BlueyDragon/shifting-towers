FERAL TALES: THE SHIFTING TOWERS
===============

FERAL Tales: The Shifting Towers is a role-playing dungeon crawler set in a land called Aysic. The player takes the role of a *cipher*, a traveling adventurer seeking fortune. The player is tasked with destroying an archmage named Mersenne that is terrorizing a local town. In order to do so, the player must brave the Shifting Towers, a labyrinth of interconnected dungeons that are constantly twisting, turning, and transforming, a maelstrom that makes cartography impossible, and the setting that gives the game its name.

The Shifting Towers is a roguelike written in FreeBasic, following the [Let's Build a Roguelike](https://users.freebasic-portal.de/rdc/tutorials.html#mozTocId58846) tutorial written by Richard D. Clark.

## Compiling
To compile the source code with extended error checking (development mode), run the following command (assuming that you have the FreeBasic compiler in your system path).

`fbc -exx towers.bas towers.rc`

To compile the source code for distribution, the command is thus:

`fbc towers.bas towers.rc -s gui`

