# snake_arm9
Snake game coded in ARM9 assembly language.

![snake_arm9](images/snake.gif)

## How to setup
Download the savefile located in the /save directory.
[save](save/)
> [!NOTE]
> Make sure you download the correct savefile for your game's region. Also, you'll notices that at the end of each filename, there are *melon_PC* or *melon_android*. *melon_PC* is for the desktop version of melonDS emulator (Windows, Mac, Linux, etc.) and *melon_android* is for the android port of melonDS emulator.

> [!WARNING]
> If you have an existing savefile, be sure to backup that first by either renaming it or make a copy of it. This is so that you can go back to your original savefile after you're done messing around with the modified savefile provided here.
Place your savefile in the same directory as your Nintendo DS ROMs (most likley, depending on the setup/emulator). Next, rename your downloaded savefile the same as your Nintendo DS ROM filename.

Run melonDS emulator and select the game with the modified savefile.
At the "titlescreen" where you see New Game and Continue, select Continue.

If it works, you should see this screen:

![snake_info_arm9](images/snake_info.png)

## Controls
D-Pad - Play / Change Snake direction

START - Start Game / Pause / Un-Pause / Play Again

## Tested and working
* melonDS emulator v0.9.5 win_x64 (Windows)

* melonDS-android

* desmume emulator v0.9.13-win64 (Windows)

## Credits
1. This whole project was based on this information.
[https://cturt.github.io/DS-exploit-finding.html](https://cturt.github.io/DS-exploit-finding.html)

2. Programming for the Nintendo DS in ARM assembly language.
[https://www.chibialiens.com/arm/nds.php](https://www.chibialiens.com/arm/nds.php)

3. CheatSheet for all the ARM commands.
[https://www.chibialiens.com/arm/CheatSheet.pdf](https://www.chibialiens.com/arm/CheatSheet.pdf)

4. 8x8 Font used.
[https://www.coranac.com/tonc/img/tonc_font.png](https://www.coranac.com/tonc/img/tonc_font.png)

5. devkitPro to compile code for the Nintendo DS.
[https://devkitpro.org/](https://devkitpro.org/)
