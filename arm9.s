@#+++++++++++++++++++++++++++++++++++++++++++++++++++
@#  Snake Game v1.2
@#  Payload (ARM9)
@#  by Azure                            15/11/2025
@#+++++++++++++++++++++++++++++++++++++++++++++++++++

#include "font.s"
#include "string.s"


@#-----------------------------------------------------
@# Address:
@#-----------------------------------------------------
@# USA
@# 0x02124960		ADDRESS_FONT
@# 0x02125540		ADDRESS_STRING
@# 0x021255BC		ACE
@#
@# Europe
@# 0x0212487C		ADDRESS_FONT
@# 0x0212545C		ADDRESS_STRING
@# 0x021254D8		ACE
@#
@# Japan
@# 0x02124868		ADDRESS_FONT
@# 0x02125448		ADDRESS_STRING
@# 0x021254C4		ACE



#define ADDRESS_VRAM_A				0x06800000
#define ADDRESS_IO					0x04000000
#define ADDRESS_STORE				0x02300000
#define ADDRESS_FONT				0x02124868
#define ADDRESS_STRING				0x02125448
#define SCREEN_WIDTH				256
#define SCREEN_HEIGHT				192
#define GRID_SIZE					8

#define SNAKE_GRID_BUFFER			0xC00
#define SNAKE_GRID_BUFFER_START		0x60
#define DELAY						0x05

#define SNAKE_SIZE_START			7

#define GAME_WAIT					0
#define GAME_PLAY					1
#define GAME_OVER					2
#define GAME_PAUSE					3

#define DIR_UP						0
#define DIR_DOWN					1
#define DIR_LEFT					2
#define DIR_RIGHT					3

#define COLOR_BG					0x0000
#define COLOR_WALL					0x4000
#define COLOR_SNAKE					0x03E0
#define COLOR_TRAIL					0x0200
#define COLOR_FRUIT					0x7FFF


.global _start
_start:

@# init screen

mov r0, #ADDRESS_IO                     @ I/O space offset
ldr r1, = #0x3							@ Screen on
@#ldr r1, = #0x8203                       @ Use this instead to swap screen

mov r2, #0x00020000                     @ Use VRAM_A as framebuffer
mov r3, #0x80                           @ VRAM bank A enabled in LCD mode
mov r4, #0                              @ Screen brightness (top screen)

str r1, [r0, #0x304]                    @ Set POWERCNT
str r2, [r0]                            @ DISPCNT
str r3, [r0, #0x240]                    @ VRAMCNT_A
str r4, [r0, #0x6C]                     @ MASTER BRIGHT (screen A)

@#ldr r0, = #0x04001000
@#str r4, [r0, #0x6C]                     @ MASTER BRIGHT (screen B)





game_start:



bl reset_variables

ldr r0, = #ADDRESS_STORE

ldr r1, = #1
strb r1, [r0, #0x00]		@# game_info ENABLE

@#ldr r1, = #GAME_WAIT
@#strb r1, [r0, #0x01]

ldrb r6, = #5				@#int fruit_x = 5;
ldrb r7, = #5				@#int fruit_y = 5;
strb r6, [r0, #0x08]
strb r7, [r0, #0x09]

@#int random_seed = 1;
ldrb r8, = #1
strb r8, [r0, #0x03]

ldr r1, = #0
str r1, [r0, #0x14]	@# set score = 0
str r1, [r0, #0x18]	@# set fruit_respawn_count = 0
str r1, [r0, #0x1C]	@# set best = 0
str r1, [r0, #0x24]	@# set score:XXX to 0
str r1, [r0, #0x2C]	@# set best:XXX to 0


bl game_setup



@#---------------------------------------
whileLoop:
@#---------------------------------------


@# if (game_info == 1)
ldr r0, = #ADDRESS_STORE
ldrb r1, [r0, #0x00]	@# game_info
cmp r1, #1
bne game_info_page


@# Classic Snake Game
ldr r4, = #0x7FFF					@# color
ldr r5, = #(GRID_SIZE * 1) * 2		@# x
ldr r6, = #(GRID_SIZE * 1) * 2		@# y
ldr r7, = #0x34						@# start
ldr r8, = #0x45						@# end
bl printf

@# By Azure
ldr r4, = #0x7FFF					@# color
ldr r5, = #(GRID_SIZE * 1) * 2		@# x
ldr r6, = #(GRID_SIZE * 3) * 2		@# y
ldr r7, = #0x46						@# start
ldr r8, = #0x4D						@# end
bl printf

@# Press START to play
ldr r4, = #0x7FFF					@# color
ldr r5, = #(GRID_SIZE * 6) * 2		@# x
ldr r6, = #(GRID_SIZE * 13) * 2		@# y
ldr r7, = #0x1B						@# start
ldr r8, = #0x2D						@# end
bl printf

@# https://github.com/azureknight76
ldr r4, = #0x7C1F					@# color
ldr r5, = #(GRID_SIZE * 0) * 2		@# x
ldr r6, = #(GRID_SIZE * 22) * 2		@# y
ldr r7, = #0x4E						@# start
ldr r8, = #0x6D						@# end
bl printf

@# 04/snake_arm9
ldr r4, = #0x7C1F					@# color
ldr r5, = #(GRID_SIZE * 0) * 2		@# x
ldr r6, = #(GRID_SIZE * 23) * 2		@# y
ldr r7, = #0x6E						@# start
ldr r8, = #0x7B						@# end
bl printf




@# Press START button to play snake
ldr r0, = #ADDRESS_STORE
ldr r1, = #ADDRESS_IO
ldrb r12, [r1, #0x130]
cmp r12, #0xF7
bne exitGameInfoPage
  ldr r1, = #0
  strb r1, [r0, #0x00]
  bl game_setup
exitGameInfoPage:

b game_info_page_end
game_info_page:


@#if (game_mode == GAME_WAIT) {
ldr r0, = #ADDRESS_STORE
ldrb r1, [r0, #0x01]	@# game_mode
cmp r1, #GAME_WAIT
bne game_mode_wait


@#// Press ANY Direction to START GAME
ldr r0, = #ADDRESS_STORE
ldr r1, = #ADDRESS_IO
ldrb r12, [r1, #0x130]
strb r12, [r0, #0x38]	@# debug (to know the button press value)

cmp r12, #0xBF
bne start_dir_up
  ldrb r2, = #DIR_UP
  ldrb r3, = #GAME_PLAY
  strb r2, [r0, #0x06]	@# store snake_dir
  strb r3, [r0, #0x01]	@# store game_mode
start_dir_up:

cmp r12, #0x7F
bne start_dir_down
  ldrb r2, = #DIR_DOWN
  ldrb r3, = #GAME_PLAY
  strb r2, [r0, #0x06]	@# store snake_dir
  strb r3, [r0, #0x01]	@# store game_mode
start_dir_down:

cmp r12, #0xDF
bne start_dir_left
  ldrb r2, = #DIR_LEFT
  ldrb r3, = #GAME_PLAY
  strb r2, [r0, #0x06]	@# store snake_dir
  strb r3, [r0, #0x01]	@# store game_mode
start_dir_left:

cmp r12, #0xEF
bne start_dir_right
  ldrb r2, = #DIR_RIGHT
  ldrb r3, = #GAME_PLAY
  strb r2, [r0, #0x06]	@# store snake_dir
  strb r3, [r0, #0x01]	@# store game_mode
start_dir_right:


game_mode_wait:



@# if (game_mode == GAME_PLAY) {
ldr r0, = #ADDRESS_STORE
ldrb r1, [r0, #0x01]	@# game_mode
cmp r1, #GAME_PLAY
bne game_mode_play

@# Change Snake Direction
ldr r1, = #ADDRESS_IO
ldrb r12, [r1, #0x130]
strb r12, [r0, #0x38]	@# debug (to know the button press value)

ldrb r3, [r0, #0x07]	@# load snake_dir_prev

cmp r12, #0xBF
bne change_dir_up_button
  cmp r3, #DIR_DOWN
  beq change_dir_up
    ldrb r2, = #DIR_UP
    strb r2, [r0, #0x06]	@# store snake_dir
  change_dir_up:
change_dir_up_button:

cmp r12, #0x7F
bne change_dir_down_button
  cmp r3, #DIR_UP
  beq change_dir_down
    ldrb r2, = #DIR_DOWN
    strb r2, [r0, #0x06]	@# store snake_dir
  change_dir_down:
change_dir_down_button:

cmp r12, #0xDF
bne change_dir_left_button
  cmp r3, #DIR_RIGHT
  beq change_dir_left
    ldrb r2, = #DIR_LEFT
    strb r2, [r0, #0x06]	@# store snake_dir
  change_dir_left:
change_dir_left_button:

cmp r12, #0xEF
bne change_dir_right_button
  cmp r3, #DIR_LEFT
  beq change_dir_right
    ldrb r2, = #DIR_RIGHT
    strb r2, [r0, #0x06]	@# store snake_dir
  change_dir_right:
change_dir_right_button:


@# step++;
ldr r4, [r0, #0x20]		@# load step
add r4, r4, #1
str r4, [r0, #0x20]		@# store step

@# if (step >= delay) {
cmp r4, #DELAY
blt delay

@# Move Snake
ldrb r2, [r0, #0x06]	@# load snake_dir

cmp r2, #DIR_UP
bne move_up
  ldrb r3, = #DIR_UP
  strb r3, [r0, #0x07]	@# store snake_dir_prev
  ldrb r5, [r0, #0x05]	@# load snake_y
  sub r5, r5, #1
  strb r5, [r0, #0x05]	@# store snake_y
move_up:

cmp r2, #DIR_DOWN
bne move_down
  ldrb r3, = #DIR_DOWN
  strb r3, [r0, #0x07]	@# store snake_dir_prev
  ldrb r5, [r0, #0x05]	@# load snake_y
  add r5, r5, #1
  strb r5, [r0, #0x05]	@# store snake_y
move_down:

cmp r2, #DIR_LEFT
bne move_left
  ldrb r3, = #DIR_LEFT
  strb r3, [r0, #0x07]	@# store snake_dir_prev
  ldrb r5, [r0, #0x04]	@# load snake_x
  sub r5, r5, #1
  strb r5, [r0, #0x04]	@# store snake_x
move_left:

cmp r2, #DIR_RIGHT
bne move_right
  ldrb r3, = #DIR_RIGHT
  strb r3, [r0, #0x07]	@# store snake_dir_prev
  ldrb r5, [r0, #0x04]	@# load snake_x
  add r5, r5, #1
  strb r5, [r0, #0x04]	@# store snake_x
move_right:

@# Set Snake
ldr r2,  = #SNAKE_GRID_BUFFER_START		@# snake_grid buffer (first)
ldr r3, [r0, #0x10]		@# load snake_size
ldrb r4, [r0, #0x04]	@# load snake_x
ldrb r5, [r0, #0x05]	@# load snake_y

ldr r12, = #0			@# h
ldr r11, = #0			@# w

fl_snakeGrid2_h_s:
cmp r12, #24
bge fl_snakeGrid2_h_e
  
  fl_snakeGrid2_w_s:
  cmp r11, #32
  bge fl_snakeGrid2_w_e
    
    @# if (w == snake_x && h == snake_y) {
    cmp r11, r4
	bne w_eq_snakeX2
	  cmp r12, r5
	  bne h_eq_snakeY2
	    @# snake_grid[snake_grid_count] += snake_size;
		ldr r6, [r0, r2]
		add r6, r6, r3
		str r6, [r0, r2]

		@# if (snake_grid[snake_grid_count] > snake_size) {
		cmp r6, r3
		ble game_over
		  ldrb r7, = #GAME_OVER
		  strb r7, [r0, #0x01]	@# game_mode
		game_over:

	  h_eq_snakeY2:
	w_eq_snakeX2:


	add r2, r2, #0x04		@# snake_grid_count++

    add r11, r11, #1	@# w++
	b fl_snakeGrid2_w_s


  fl_snakeGrid2_w_e:

  ldr r11, = #0		@# w = 0
  add r12, r12, #1	@# h++
  b fl_snakeGrid2_h_s


fl_snakeGrid2_h_e:



@# step = 0;
ldr r4, = #0			@# set step
str r4, [r0, #0x20]		@# store step

delay:
@# End of  if (step >= delay) {



@# Press START to pause game
@#ldr r1, = #ADDRESS_IO
ldrb r12, [r1, #0x130]
ldrb r3, [r0, #0x0F]
cmp r3, #0
bne notTogglePauseButton
cmp r12, #0xF7
bne togglePauseButton
  ldr r2, = #GAME_PAUSE
  strb r2, [r0, #0x01]		@# game_mode = GAME_PAUSE
  ldr r3, = #1
  strb r3, [r0, #0x0F]

  @# Paused:
  ldr r4, = #0x7FE0						@# color
  ldr r5, = #(GRID_SIZE * 13) * 2		@# x
  ldr r6, = #(GRID_SIZE * 0) * 2		@# y
  ldr r7, = #0x0B						@# start
  ldr r8, = #0x10						@# end
  bl printf

togglePauseButton:
notTogglePauseButton:


game_mode_play:




@#// Draw Snake
ldr r0, = #ADDRESS_STORE
ldr r5, = #SNAKE_GRID_BUFFER_START		@# snake_grid buffer (first)
ldr r6, [r0, #0x10]		@# load snake_size
@# r3 = draw_x
@# r4 = draw_y
@# r7 = snake_grid[i]
ldr r8, [r0, #0x20]		@# load step
@#ldrb r9,  [r0, #0x08]	@# load fruit_x
@#ldrb r10, [r0, #0x09]	@# load fruit_y

ldrb r12, = #0		@# snake_grid_w
ldrb r11, = #0		@# snake_grid_h
@#----------------------------------------------------------------------------

@# only draw snake when NOT GAME_PAUSE
ldrb r1, [r0, #0x01]
cmp r1, #GAME_PAUSE
beq notGamePause

@# only draw snake if UPDATE_ONCE = 0 (NOT GAME_OVER but allow draw ONCE)
ldrb r1, [r0, #0x0E]
cmp r1, #0
bne notUpdateOnce


fl_drawSnake_h_s:
cmp r11, #24
bge fl_drawSnake_h_e
  
  fl_drawSnake_w_s:
  cmp r12, #32
  bge fl_drawSnake_w_e
    
    @# if (snake_grid[i] > 0) {
    ldr r7, [r0, r5]
    cmp r7, #0
    ble snakeGrid_gt0

      @# store registers before draw_pixel8x8
      str r12, [r0, #0x30]	@# store snake_grid_w
      str r11, [r0, #0x34]	@# store snake_grid_h
	  str r8,  [r0, #0x20]	@# store step
	  str r6,  [r0, #0x10]	@# store snake_size
	  str r7,  [r0, #0x28]	@# store snake_grid[i]
      @# if (snake_grid[i] >= snake_size) {
      cmp r7, r6
      blt drawSnake
        @# Draw Snake
        ldr r2, = #COLOR_SNAKE
        mov r3, r12				@# draw_x = snake_grid_w
        mov r4, r11				@# draw_y = snake_grid_h
        bl draw_pixel8x8
		@#bl debug	@# debugging/printf
        b drawSnake_e
      drawSnake:
        @# Draw Snake Trail
        ldr r2, = #COLOR_TRAIL
        mov r3, r12				@# draw_x = snake_grid_w
        mov r4, r11				@# draw_y = snake_grid_h
        bl draw_pixel8x8
      drawSnake_e:
      @# load registers after draw_pixel8x8
      ldr r0, = #ADDRESS_STORE
	  ldr r6,  [r0, #0x10]		@# load snake_size
	  ldr r7,  [r0, #0x28]		@# load snake_grid[i]
	  ldr r8,  [r0, #0x20]		@# load step
      ldr r12, [r0, #0x30]		@# load snake_grid_w
      ldr r11, [r0, #0x34]		@# load snake_grid_h

      @# if (step == delay - 1)
      cmp r8, #DELAY - 1
      bne step_eq_delay
        sub r7, r7, #1				@# snake_grid[i]--;
		str r7, [r0, r5]			@# store snake_grid[i]
		@#bl debug	@# debugging/printf
      step_eq_delay:

    snakeGrid_gt0:
    @# End of  if (snake_grid[i] > 0) {


	@# Prevent Fruit from Flickering
	@# if (w != fruit_x && h != fruit_y)
	ldrb r9,  [r0, #0x08]	@# load fruit_x
	ldrb r10, [r0, #0x09]	@# load fruit_y

	ldrb r2, = #0
	strb r2, [r0, #0x0D]

	cmp r12, r9
	bne not_draw_fruitX
	cmp r11, r10
	bne not_draw_fruitY
	  ldrb r2, = #1			@# Do NOT draw fruit
	  strb r2, [r0, #0x0D]
	not_draw_fruitY:
	not_draw_fruitX:

    @# if (snake_grid[i] == 0) {
    cmp r7, #0
    bne snakeGrid_eq0
      @# if (snake_grid_w > 0)
      cmp r12, #0
      ble snakeGridW_gt0
        @# if (snake_grid_h > 0)
        cmp r11, #0
	    ble snakeGridH_gt0
	      @# if snake_grid_w < (SCREEN_WIDTH / GRID_SIZE) - 1)
	      cmp r12, #32 - 1
	      bge snakeGridW_geW
	        @# if (snake_grid_h < (SCREEN_HEIGHT / GRID_SIZE) - 1)
		    cmp r11, #24 - 1
		    bge snakeGridH_geH

			  cmp r2, #0
			  bne draw_fruit_safe

		      @# store registers before draw_pixel8x8
		      str r12, [r0, #0x30]	@# store snake_grid_w
		      str r11, [r0, #0x34]	@# store snake_grid_h
			  str r8,  [r0, #0x20]	@# store step
			  str r7,  [r0, #0x28]	@# store snake_grid[i]
			  str r6,  [r0, #0x10]	@# store snake_size

		      @#// Draw Background Color
		      ldr r2, = #COLOR_BG
              mov r3, r12				@# draw_x = snake_grid_w
              mov r4, r11				@# draw_y = snake_grid_h
              bl draw_pixel8x8

		      @# load snake_grid_w and snake_grid_h after drawing
		      ldr r0, = #ADDRESS_STORE
			  ldr r6,  [r0, #0x10]	@# load snake_size
			  ldr r7,  [r0, #0x28]	@# load snake_grid[i]
			  ldr r8,  [r0, #0x20]	@# load step
		      ldr r12, [r0, #0x30]	@# load snake_grid_w
		      ldr r11, [r0, #0x34]	@# load snake_grid_h

			  draw_fruit_safe:

		    snakeGridH_geH:
	      snakeGridW_geW:
	    snakeGridH_gt0:
      snakeGridW_gt0:
    snakeGrid_eq0:

	


	add r5, r5, #0x04		@# snake_grid_count++

    add r12, r12, #1		@# snake_grid_w++;
    b fl_drawSnake_w_s
  fl_drawSnake_w_e:

  ldr r12, = #0			@# snake_grid_w = 0;
  add r11, r11, #1		@# snake_grid_h++;
  b fl_drawSnake_h_s

fl_drawSnake_h_e:
@# End of  for (int i = 0; i < (SCREEN_WIDTH / GRID_SIZE) * (SCREEN_HEIGHT / GRID_SIZE); i++) {


notUpdateOnce:
notGamePause:




@#// GAME OVER if Snake collides with a wall
@#if (game_mode == GAME_PLAY) {
ldrb r2, [r0, #0x01]	@# load game_mode
ldrb r3, [r0, #0x04]	@# load snake_x
ldrb r4, [r0, #0x05]	@# load snake_y

cmp r2, #GAME_PLAY
bne gameOver_wall
@# if (snake_x == 0)
  cmp r3, #0
  bne snakeX_eq0
    ldrb r5, = #GAME_OVER
	strb r5, [r0, #0x01]	@# store game_mode
  snakeX_eq0:

  @# if (snake_y == 0)
  cmp r4, #0
  bne snakeY_eq0
	ldrb r5, = #GAME_OVER
    strb r5, [r0, #0x01]	@# store game_mode
  snakeY_eq0:

  @# if (snake_x == (SCREEN_WIDTH / GRID_SIZE) - 1)
  cmp r3, #32 - 1
  bne snakeX_eqW
    ldrb r5, = #GAME_OVER
    strb r5, [r0, #0x01]	@# store game_mode
  snakeX_eqW:

  @# if (snake_y == (SCREEN_HEIGHT / GRID_SIZE) - 1)
  cmp r4, #24 - 1
  bne snakeY_eqH
    ldrb r5, = #GAME_OVER
    strb r5, [r0, #0x01]	@# store game_mode
  snakeY_eqH:

gameOver_wall:


@# if (game_mode == GAME_OVER) {
ldr r0, = #ADDRESS_STORE
ldrb r1, [r0, #0x01]	@# game_mode
cmp r1, #GAME_OVER
bne game_mode_over


@# update highscore once
ldrb r1, [r0, #0x0E]	@# update GAME_OVER best score once
cmp r1, #0
bne refreshBestOnce

ldr r1, = #1
strb r1, [r0, #0x0E]	@# update GAME_OVER best score once

@# New high score ?
ldr r1, [r0, #0x14]		@# load score
ldr r2, [r0, #0x1C]		@# load highscore
cmp r1, r2
ble newRecord
mov r2, r1				@# highscore = score
str r2, [r0, #0x1C]		@# store highscore

ldrb r3, [r0, #0x27]	@# score:00X
ldrb r4, [r0, #0x26]	@# score:0X0
ldrb r5, [r0, #0x25]	@# score:X00
strb r3, [r0, #0x2F]	@# best:00X
strb r4, [r0, #0x2E]	@# best:0X0
strb r5, [r0, #0x2D]	@# best:X00

@#// Draw Boarder Color (Best:XXX)
ldr r12, = #28
bestRefresh_s:
cmp r12, #30
bgt bestRefresh
  ldr r2, = #COLOR_WALL
  mov r3, r12
  mov r4, #0
  bl draw_pixel8x8
  add r12, r12, #1
  b bestRefresh_s
bestRefresh:

newRecord:


@# Game Over!
ldr r4, = #0x001F					@# color
ldr r5, = #(GRID_SIZE * 11) * 2		@# x
ldr r6, = #(GRID_SIZE * 9) * 2		@# y
ldr r7, = #0x11						@# start
ldr r8, = #0x1A						@# end
bl printf

@# Press START to play again
ldr r4, = #0x001F					@# color
ldr r5, = #(GRID_SIZE * 4) * 2		@# x
ldr r6, = #(GRID_SIZE * 14) * 2		@# y
ldr r7, = #0x1B						@# start
ldr r8, = #0x33						@# end
bl printf


refreshBestOnce:



ldr r0, = #ADDRESS_STORE
ldr r1, = #ADDRESS_IO
ldrb r12, [r1, #0x130]
@# Press START to restart game
cmp r12, #0xF7
bne game_restart

  @#ldrb r1, = #GAME_WAIT
  @#strb r1, [r0, #0x01]

  @# fruit_x = random_x
  ldrb r1, [r0, #0x0A]
  strb r1, [r0, #0x08]

  @# fruit_y = random_y
  ldrb r1, [r0, #0x0B]
  strb r1, [r0, #0x09]

  @#ldr r1, = #0
  @#str r1, [r0, #0x14]	@# set score = 0
  @#str r1, [r0, #0x18]	@# set fruit_respawn_count = 0
  @#str r1, [r0, #0x24]	@# set score:XXX to 0

  bl reset_variables
  bl game_setup			@# to redraw the wall
  b whileLoop
game_restart:

game_mode_over:






@# While game is paused
ldr r0, = #ADDRESS_STORE
ldr r1, = #ADDRESS_IO
ldrb r2, [r0, #0x01]	@# game_mode
ldrb r3, [r0, #0x0F]	@# START button pressed
ldrb r12, [r1, #0x130]
cmp r2, #GAME_PAUSE
bne game_paused

@# Press START to unpause game (after first releasing the button)
cmp r3, #0
bne pauseNotPress
  cmp r12, #0xF7
  bne pausePress
    
    ldrb r2, = #GAME_PLAY
	strb r2, [r0, #0x01]

	ldrb r3, = #1
	strb r3, [r0, #0x0F]

	@#// Draw Boarder Color (Paused)
    ldr r12, = #13
    pausedRefresh_s:
    cmp r12, #18
    bgt pausedRefresh
      ldr r2, = #COLOR_WALL
      mov r3, r12
      mov r4, #0
      bl draw_pixel8x8
      add r12, r12, #1
      b pausedRefresh_s
    pausedRefresh:
    
  pausePress:
pauseNotPress:

game_paused:



@# Release the START button to disable the check
@#ldr r1, = #ADDRESS_IO
ldrb r12, [r1, #0x130]
cmp r12, #0xF7
beq notStartButton
  ldr r1, = #0
  strb r1, [r0, #0x0F]
notStartButton:






@# // Snake eats a fruit
ldr r0, = #ADDRESS_STORE
ldrb r1, [r0, #0x04]	@# load snake_x
ldrb r2, [r0, #0x05]	@# load snake_y
ldrb r3, [r0, #0x08]	@# load fruit_x
ldrb r4, [r0, #0x09]	@# load fruit_y
@#ldrb r5, [r0, #0x0A]	@# load random_x
@#ldrb r6, [r0, #0x0B]	@# load random_y
@# if (snake_x == fruit_x && snake_y == fruit_y) {
cmp r1, r3
bne snake_eat_fruitX
cmp r2, r4
bne snake_eat_fruitY

@# // Increase the snake size
ldr r1, [r0, #0x10]		@# snake_size++
add r1, r1, #1
str r1, [r0, #0x10]
ldr r1, [r0, #0x14]		@# score++
add r1, r1, #1
str r1, [r0, #0x14]

@# add score:XXX
ldrb r1, [r0, #0x27]	@# score:00X
ldrb r7, [r0, #0x26]	@# score:0X0
ldrb r8, [r0, #0x25]	@# score:X00
add r1, r1, #1
cmp r1, #9
ble score0X0
  ldr r1, = #0
  add r7, r7, #1
score0X0:
cmp r7, #9
ble scoreX00
  ldr r7, = #0
  add r8, r8, #1
scoreX00:
strb r1, [r0, #0x27]	@# score:00X
strb r7, [r0, #0x26]	@# score:0X0
strb r8, [r0, #0x25]	@# score:X00


@#// Draw Boarder Color (Score:XXX)
ldr r12, = #7
scoreRefresh_s:
cmp r12, #9
bgt scoreRefresh
  ldr r2, = #COLOR_WALL
  mov r3, r12
  mov r4, #0
  bl draw_pixel8x8
  add r12, r12, #1
  b scoreRefresh_s
scoreRefresh:


ldr r0, = #ADDRESS_STORE
@#ldrb r1, [r0, #0x04]	@# load snake_x
@#ldrb r2, [r0, #0x05]	@# load snake_y
ldrb r3, [r0, #0x08]	@# load fruit_x
ldrb r4, [r0, #0x09]	@# load fruit_y
ldrb r5, [r0, #0x0A]	@# load random_x
ldrb r6, [r0, #0x0B]	@# load random_y


ldrb r1, = #0			@# fruit_respawn (false)
wl_fruitRespawn_s:
cmp r1, #0
bne wl_fruitRespawn_e

@# // Respawn another Fruit
mov r3, r5		@# fruit_x = random_x
mov r4, r6		@# fruit_y = random_y
strb r3, [r0, #0x08]
strb r4, [r0, #0x09]

ldr r2, [r0, #0x18]		@# fruit_respawn_count++
add r2, r2, #1
str r2, [r0, #0x18]

@# // Check to see if the Fruit Respawn inside the Snake Trail,
@# // If Yes, then Respawn the Fruit again
ldr r2,  = #SNAKE_GRID_BUFFER_START		@# snake_grid_count / snake_grid[i];
@#ldr r7, [r0, r2]	@# snake_grid
ldr r12, = #0		@# w
ldr r11, = #0		@# h

fl_snakeEat_h_s:
cmp r11, #24
bge fl_snakeEat_h_e
fl_snakeEat_w_s:
cmp r12, #32
bge fl_snakeEat_w_e


@# if (fruit_x == w && fruit_y == h) {
cmp r3, r12
bne fruitx_w
cmp r4, r11
bne fruity_h

ldr r7, [r0, r2]	@# snake_grid
@# if (snake_grid[snake_grid_count] == 0) {
cmp r7, #0
bne fruitRespawnSuccess
  ldrb r1, = #1		@# fruit_respawn (true);
  strb r1, [r0, #0x02]
  b fruitRespawnFail
fruitRespawnSuccess:

@# // Random Number Generator
@# // Used to randomly placed the Fruit
add r5, r5, #1		@# random_x++;
@# if (random_x >= (SCREEN_WIDTH / GRID_SIZE) - 2) {
cmp r5, #30
blt randomx_reset
  add r6, r6, #1	@# random_y++
  ldrb r5, = #1		@# random_x = 1
randomx_reset:

@# if (random_y >= (SCREEN_HEIGHT / GRID_SIZE) - 2) {
cmp r6, #22
blt randomy_reset
  ldrb r5, = #1		@# random_x = 1
  ldrb r6, = #1		@# random_y = 1
randomy_reset:


fruitRespawnFail:

fruity_h:
fruitx_w:


add r2, r2, #0x04	@# snake_grid_count++;

add r12, r12, #1	@# w++
b fl_snakeEat_w_s
fl_snakeEat_w_e:

add r11, r11, #1	@# h++
ldr r12, = #0		@# w = 0
b fl_snakeEat_h_s
fl_snakeEat_h_e:


b wl_fruitRespawn_s
wl_fruitRespawn_e:


@# // random_seed++
ldrb r8, [r0, #0x03]
add r8, r8, #1
cmp r8, #7
ble randSeed_reset
  ldrb r8, = #1
randSeed_reset:
strb r8, [r0, #0x03]

snake_eat_fruitY:
snake_eat_fruitX:




@# // Random Number Generator
@# // Used to randomly placed the Fruit
ldr r0, = #ADDRESS_STORE
ldrb r5, [r0, #0x0A]	@# load random_x
ldrb r6, [r0, #0x0B]	@# load random_y
ldrb r8, [r0, #0x03]	@# load random_seed

add r5, r5, r8		@# random_x += random_seed
@# if (random_x >= (SCREEN_WIDTH / GRID_SIZE) - 2) {
cmp r5, #30
blt randx_ge_w
  add r6, r6, #1		@# random_y++
  sub r5, r5, #30		@# random_x -= (SCREEN_WIDTH / GRID_SIZE) - 2

  @# if (random_x == 0) random_x += random_seed;
  cmp r5, #0
  bne randx_eq_0
    add r5, r5, r8
  randx_eq_0:
randx_ge_w:
@# if (random_y >= (SCREEN_HEIGHT / GRID_SIZE) - 2) {
cmp r6, #22
blt randy_ge_h
  ldrb r5, = #1		@# random_x = 1
  ldrb r6, = #1		@# random_y = 1
randy_ge_h:

strb r5, [r0, #0x0A]	@# store random_x
strb r6, [r0, #0x0B]	@# store random_y
strb r8, [r0, #0x03]	@# store random_seed


@# // Draw Fruit
ldr r0, = #ADDRESS_STORE
ldrb r1, [r0, #0x01]
cmp r1, #GAME_OVER
beq drawFruit
ldr r2, = #COLOR_FRUIT
ldrb r3, [r0, #0x08]			@# draw_x = fruit_x
ldrb r4, [r0, #0x09]			@# draw_y = fruit_y
bl draw_pixel8x8
drawFruit:





@# Score:
ldr r4, = #0x7FFF					@# color
ldr r5, = #(GRID_SIZE * 1) * 2		@# x
ldr r6, = #(GRID_SIZE * 0) * 2		@# y
ldr r7, = #0x00						@# start
ldr r8, = #0x05						@# end
bl printf




@# Score:X00
ldr r4, = #0x7FFF					@# color
ldr r5, = #(GRID_SIZE * 7) * 2		@# x
ldr r6, = #(GRID_SIZE * 0) * 2		@# y
ldr r7, = #ADDRESS_STORE + 0x25		@# byte address
bl printf_byte
@# Score:0X0
ldr r4, = #0x7FFF					@# color
ldr r5, = #(GRID_SIZE * 8) * 2		@# x
ldr r6, = #(GRID_SIZE * 0) * 2		@# y
ldr r7, = #ADDRESS_STORE + 0x26		@# byte address
bl printf_byte
@# Score:00X
ldr r4, = #0x7FFF					@# color
ldr r5, = #(GRID_SIZE * 9) * 2		@# x
ldr r6, = #(GRID_SIZE * 0) * 2		@# y
ldr r7, = #ADDRESS_STORE + 0x27		@# byte address
bl printf_byte





@# Best:
ldr r4, = #0x03FF					@# color
ldr r5, = #(GRID_SIZE * 23) * 2		@# x
ldr r6, = #(GRID_SIZE * 0) * 2		@# y
ldr r7, = #0x06						@# start
ldr r8, = #0x0A						@# end
bl printf
@# Best:X00
ldr r4, = #0x03FF					@# color
ldr r5, = #(GRID_SIZE * 28) * 2		@# x
ldr r6, = #(GRID_SIZE * 0) * 2		@# y
ldr r7, = #ADDRESS_STORE + 0x2D		@# byte address
bl printf_byte
@# Best:0X0
ldr r4, = #0x03FF					@# color
ldr r5, = #(GRID_SIZE * 29) * 2		@# x
ldr r6, = #(GRID_SIZE * 0) * 2		@# y
ldr r7, = #ADDRESS_STORE + 0x2E		@# byte address
bl printf_byte
@# Best:00X
ldr r4, = #0x03FF					@# color
ldr r5, = #(GRID_SIZE * 30) * 2		@# x
ldr r6, = #(GRID_SIZE * 0) * 2		@# y
ldr r7, = #ADDRESS_STORE + 0x2F		@# byte address
bl printf_byte





game_info_page_end:




b whileLoop







game_setup:
  
  @# Draw Wall Color

  ldr r0, = #ADDRESS_VRAM_A		@ Address Screen
  ldr r2, = #ADDRESS_STORE

  ldrb r3, [r2, #0x00]
  cmp r3, #1
  bne setupBlackBG
    ldr r1, = #COLOR_BG
	b setupBGEnd
  setupBlackBG:
    ldr r1, = #COLOR_WALL
  setupBGEnd:

  ldr r12, = #0					@ WhileLoop counter
  loop_screenFill_start:
  cmp r12, #(SCREEN_WIDTH * SCREEN_HEIGHT)
  bge loop_screenFill_end
    strh r1, [r0]				@# Store Pixel Color to Address
    add r0, r0, #2				@# Add 2 to VRAM_A Address
    add r12, r12, #1			@# WhileLoop counter++
    b loop_screenFill_start
  loop_screenFill_end:

  bx lr





@# Draw 8x8 Pixel
@#
@# r2 = color
@# r3 = pos x
@# r4 = pos y

draw_pixel8x8:


ldr r0, = #ADDRESS_VRAM_A		@ Address Screen
ldr r1, = #ADDRESS_STORE
@#ldr r2, = #0x7FFF

@#ldrb r3, [r1, #0x04]		@# load snake_x
@#ldrb r4, [r1, #0x05]		@# load snake_y

mov r8, r3			@# ForLoop drawX start counter
mov r9, r4			@# ForLoop drawY start counter

mov r10, r8			@# ForLoop drawX end counter
mov r11, r9			@# ForLoop drawY end counter
add r10, r10, #GRID_SIZE
add r11, r11, #GRID_SIZE



@# Correct the 8x8 Pixel Position for Drawing
@# X
mov r6, #GRID_SIZE
mul r7, r8, r6
add r7, r7, r7
add r0, r0, r7
@# Y
ldr r7, = #SCREEN_WIDTH * GRID_SIZE
mul r6, r9, r7
add r7, r6, r6
add r0, r0, r7



loop_block_drawY_start:
cmp r9, r11
bge loop_block_drawY_end


	loop_block_drawX_start:
	cmp r8, r10
	bge loop_block_drawX_end

		strh r2, [r0]		@# Store Pixel Color to Address
		add r0, r0, #2		@# Add 2 to VRAM_A Address
		add r8, r8, #1		@# ForLoop drawX start counter ++
		b loop_block_drawX_start

	loop_block_drawX_end:
		

		sub r0, r0, #(GRID_SIZE * 2)
		add r0, r0, #(SCREEN_WIDTH * 2)

		mov r8, r3
		add r9, r9, #1		@# ForLoop drawY start counter ++


	b loop_block_drawY_start
loop_block_drawY_end:


bx lr




@# Reset Variables used for Snake
@#
@# This should be called at the start of the program
@# Or when resetting the game
reset_variables:

ldr r0, = #ADDRESS_STORE

ldrb r1, = #GAME_WAIT
strb r1, [r0, #0x01]

ldr r1, = #0
str r1, [r0, #0x14]	@# set score = 0
str r1, [r0, #0x18]	@# set fruit_respawn_count = 0
str r1, [r0, #0x24]	@# set score:XXX to 0

strb r1, [r0, #0x0E]	@# reset update GAME_OVER best score once
strb r1, [r0, #0x0F]	@# set start button toggle OFF

@#int snake_x = (SCREEN_WIDTH / GRID_SIZE) / 2;
@#int snake_y = (SCREEN_HEIGHT / GRID_SIZE) / 2;
ldrb r1, = #16
ldrb r2, = #12
strb r1, [r0, #0x04]	@# store snake_x
strb r2, [r0, #0x05]	@# store snake_y

@#int snake_size = SNAKE_SIZE_START;
ldr r3, = #SNAKE_SIZE_START
str r3, [r0, #0x10]		@# store snake_size




@#for (int i = 0; i < (SCREEN_WIDTH / GRID_SIZE) * (SCREEN_HEIGHT / GRID_SIZE); i++) {
	@#snake_grid[i] = 0;
@#}
ldr r1, = #0		@# set value
ldr r2, = #SNAKE_GRID_BUFFER_START		@# snake_grid buffer (first)

ldr r12, = #0		@# i = 0
fl_snakeGrid_s:
cmp r12, #SNAKE_GRID_BUFFER
bge fl_snakeGrid_e
  str r1, [r0, r2]
  add r2, r2, #0x04
  add r12, r12, #0x04
  b fl_snakeGrid_s
fl_snakeGrid_e:


@# Set Snake
ldr r2,  = #SNAKE_GRID_BUFFER_START		@# snake_grid buffer (first)
ldr r3, [r0, #0x10]		@# load snake_size
ldrb r4, [r0, #0x04]	@# load snake_x
ldrb r5, [r0, #0x05]	@# load snake_y

ldr r12, = #0			@# h
ldr r11, = #0			@# w

fl_snakeGrid_h_s:
cmp r12, #24
bge fl_snakeGrid_h_e
  
  fl_snakeGrid_w_s:
  cmp r11, #32
  bge fl_snakeGrid_w_e
    
    cmp r11, r4
	bne w_eq_snakeX
	  cmp r12, r5
	  bne h_eq_snakeY
	    str r3, [r0, r2]
	  h_eq_snakeY:
	w_eq_snakeX:


	add r2, r2, #0x04		@# snake_grid_count++

    add r11, r11, #1	@# w++
	b fl_snakeGrid_w_s


  fl_snakeGrid_w_e:

  ldr r11, = #0		@# w = 0
  add r12, r12, #1	@# h++
  b fl_snakeGrid_h_s


fl_snakeGrid_h_e:



bx lr





@# printf (debug)
@# making sure that this part of the code has been executed
debug:

ldr r0, = #ADDRESS_STORE

@#ldrb r12, = #0x48
ldrb r12, [r0, #0x0C]	@# load debug value
add r12, r12, #1
strb r12, [r0, #0x0C]	@# store debug value

bx lr







@#-----------------------------------
@# Draw text message on screen
@#-----------------------------------
@# r4 = color
@# r5 = x
@# r6 = y
@# r7 = start
@# r8 = end
printf:

ldr r0, = #ADDRESS_VRAM_A
ldr r1, = #ADDRESS_FONT
ldr r2, = #ADDRESS_STRING
ldr r3, = #ADDRESS_STORE
@#ldr r7, = #0	@# drawPixel_x
@#ldr r8, = #0	@# drawPixel_y
ldr r9, = #0	@# padding
@# r10 = calculation
@# r11 = font[i] to check (then draw)
@# r12 = for loop i



strh r4, [r3, #0x40]		@# store color
strh r5, [r3, #0x44]		@# store x
strh r6, [r3, #0x46]		@# store y
str  r7, [r3, #0x4C]		@# store start
str  r8, [r3, #0x50]		@# store end
str  r9, [r3, #0x48]		@# store padding



@#ldr r7, = #0	@# drawPixel_x
@#ldr r8, = #0	@# drawPixel_y



@#---------------------------------------------------------------


fl_drawString_s:

cmp r7, r8
bgt fl_drawString_e


@# load string[i]
ldrb r11, [r2, r7]
ldr r6, = #0x20
sub r11, r11, r6
@#str r11, [r3, #0x18]


ldrb r4, = #(4 * 8)
mul r5, r4, r11
add r6, r5, r4

str r6, [r3, #0x54]		@# store result






ldr r7, = #0	@# drawPixel_x
ldr r8, = #0	@# drawPixel_y





@# for (int i = 0; i < 4 * 8; i++) {
mov r12, r5
fl_drawFont_s:

ldr r6, [r3, #0x54]		@# load result

cmp r12, r6
bge fl_drawFont_i_e

ldrb r11, [r1, r12]




ldrh r4, [r3, #0x40]	@# load color
ldrh r5, [r3, #0x44]	@# load x
ldrh r6, [r3, #0x46]	@# load y




@# if (font8x8_v2[i] == 00) {
cmp r11, #0x00
bne drawPixel_00
  add r7, r7, #2		@# drawPixel_x++;
drawPixel_00:

@# if (font8x8_v2[i] == 01) {
cmp r11, #0x01
bne drawPixel_01
  
  add r7, r7, #2		@# drawPixel_x++;

  @# draw
  @# x
  add r10, r5, r7
  @# y
  ldr r9, = #SCREEN_WIDTH
  mul r4, r9, r6
  mul r5, r9, r8
  add r10, r10, r4
  add r10, r10, r5
  
  @# padding
  ldrh r9, [r3, #0x48]		@# load padding
  ldr r4, = #8 * 2
  mul r5, r9, r4
  add r10, r10, r5

  ldrh r4, [r3, #0x40]		@# load color
  strh r4, [r0, r10]
drawPixel_01:

@# if (font8x8_v2[i] == 10) {
cmp r11, #0x10
bne drawPixel_10
  
  @# draw
  @# x
  add r10, r5, r7
  @# y
  ldr r9, = #SCREEN_WIDTH
  mul r4, r9, r6
  mul r5, r9, r8
  add r10, r10, r4
  add r10, r10, r5

  @# padding
  ldrh r9, [r3, #0x48]		@# load padding
  ldr r4, = #8 * 2
  mul r5, r9, r4
  add r10, r10, r5

  ldrh r4, [r3, #0x40]		@# load color
  strh r4, [r0, r10]
  
  add r7, r7, #2		@# drawPixel_x++;
drawPixel_10:

@# if (font8x8_v2[i] == 11) {
cmp r11, #0x11
bne drawPixel_11
  
  @# draw
  @# x
  add r10, r5, r7
  @# y
  ldr r9, = #SCREEN_WIDTH
  mul r4, r9, r6
  mul r5, r9, r8
  add r10, r10, r4
  add r10, r10, r5

  @# padding
  ldrh r9, [r3, #0x48]		@# load padding
  ldr r4, = #8 * 2
  mul r5, r9, r4
  add r10, r10, r5

  ldrh r4, [r3, #0x40]		@# load color
  strh r4, [r0, r10]
  

  add r7, r7, #2		@# drawPixel_x++;


  @# draw
  @# x
  add r10, r10, #2
  
  strh r4, [r0, r10]
drawPixel_11:



add r7, r7, #2			@# drawPixel_x++;

cmp r7, #8 * 2
blt drawPixel_x_reset
  add r8, r8, #2		@# drawPixel_y++
  ldr r7, = #0			@# drawPixel_x = 0
drawPixel_x_reset:
cmp r8, #8 * 2
blt drawPixel_y_reset
  ldr r7, = #0			@# drawPixel_x = 0
  ldr r8, = #0			@# drawPixel_y = 0

  add r9, r9, #1		@# padding
  strh r9, [r3, #0x48]	@# store padding
drawPixel_y_reset:




@#ldrh r4, [r3, #0x40]	@# load color
@#ldrh r5, [r3, #0x44]	@# load x
@#ldrh r6, [r3, #0x46]	@# load y



add r12, r12, #1	@# for loop i
b fl_drawFont_s

fl_drawFont_i_e:




ldr r7, [r3, #0x4C]		@# load start
ldr r8, [r3, #0x50]		@# load end

add r7, r7, #1			@# next string[i]

str r7, [r3, #0x4C]		@# store start
str r8, [r3, #0x50]		@# store end


b fl_drawString_s

fl_drawString_e:


bx lr










@#-----------------------------------
@# Draw text byte on screen
@#-----------------------------------
@# r4 = color
@# r5 = x
@# r6 = y
@# r7 = address
printf_byte:

ldr r0, = #ADDRESS_VRAM_A
ldr r1, = #ADDRESS_FONT
ldr r2, = #ADDRESS_STRING
ldr r3, = #ADDRESS_STORE
@#ldr r7, = #0	@# drawPixel_x
@#ldr r8, = #0	@# drawPixel_y
ldr r9, = #0	@# padding
@# r10 = calculation
@# r11 = font[i] to check (then draw)
@# r12 = for loop i


strh r4, [r3, #0x40]		@# store color
strh r5, [r3, #0x44]		@# store x
strh r6, [r3, #0x46]		@# store y
str  r7, [r3, #0x58]		@# store address
str  r9, [r3, #0x48]		@# store padding



@#---------------------------------------------------------------



@# load byte
ldrb r11, [r7, #0]
ldr r6, = #0x10
add r11, r11, r6
@#str r11, [r3, #0x20]	@# store (test)


ldrb r4, = #(4 * 8)
mul r5, r4, r11
add r6, r5, r4

str r6, [r3, #0x5C]		@# store result






ldr r7, = #0	@# drawPixel_x
ldr r8, = #0	@# drawPixel_y





@# for (int i = 0; i < 4 * 8; i++) {
mov r12, r5
fl_drawByte_s:

ldr r6, [r3, #0x5C]		@# load result

cmp r12, r6
bge fl_drawByte_i_e

ldrb r11, [r1, r12]




ldrh r4, [r3, #0x40]	@# load color
ldrh r5, [r3, #0x44]	@# load x
ldrh r6, [r3, #0x46]	@# load y




@# if (font8x8_v2[i] == 00) {
cmp r11, #0x00
bne drawPixelB_00
  add r7, r7, #2		@# drawPixel_x++;
drawPixelB_00:

@# if (font8x8_v2[i] == 01) {
cmp r11, #0x01
bne drawPixelB_01
  
  add r7, r7, #2		@# drawPixel_x++;

  @# draw
  @# x
  add r10, r5, r7
  @# y
  ldr r9, = #SCREEN_WIDTH
  mul r4, r9, r6
  mul r5, r9, r8
  add r10, r10, r4
  add r10, r10, r5
  
  @# padding
  ldrh r9, [r3, #0x48]		@# load padding
  ldr r4, = #8 * 2
  mul r5, r9, r4
  add r10, r10, r5

  ldrh r4, [r3, #0x40]		@# load color
  strh r4, [r0, r10]
drawPixelB_01:

@# if (font8x8_v2[i] == 10) {
cmp r11, #0x10
bne drawPixelB_10
  
  @# draw
  @# x
  add r10, r5, r7
  @# y
  ldr r9, = #SCREEN_WIDTH
  mul r4, r9, r6
  mul r5, r9, r8
  add r10, r10, r4
  add r10, r10, r5

  @# padding
  ldrh r9, [r3, #0x48]		@# load padding
  ldr r4, = #8 * 2
  mul r5, r9, r4
  add r10, r10, r5

  ldrh r4, [r3, #0x40]		@# load color
  strh r4, [r0, r10]
  
  add r7, r7, #2		@# drawPixel_x++;
drawPixelB_10:

@# if (font8x8_v2[i] == 11) {
cmp r11, #0x11
bne drawPixelB_11
  
  @# draw
  @# x
  add r10, r5, r7
  @# y
  ldr r9, = #SCREEN_WIDTH
  mul r4, r9, r6
  mul r5, r9, r8
  add r10, r10, r4
  add r10, r10, r5

  @# padding
  ldrh r9, [r3, #0x48]		@# load padding
  ldr r4, = #8 * 2
  mul r5, r9, r4
  add r10, r10, r5

  ldrh r4, [r3, #0x40]		@# load color
  strh r4, [r0, r10]
  

  add r7, r7, #2		@# drawPixel_x++;


  @# draw
  @# x
  add r10, r10, #2
  
  strh r4, [r0, r10]
drawPixelB_11:



add r7, r7, #2			@# drawPixel_x++;

cmp r7, #8 * 2
blt drawPixelB_x_reset
  add r8, r8, #2		@# drawPixel_y++
  ldr r7, = #0			@# drawPixel_x = 0
drawPixelB_x_reset:
cmp r8, #8 * 2
blt drawPixelB_y_reset
  ldr r7, = #0			@# drawPixel_x = 0
  ldr r8, = #0			@# drawPixel_y = 0

  add r9, r9, #1		@# padding
  strh r9, [r3, #0x48]	@# store padding
drawPixelB_y_reset:



add r12, r12, #1	@# for loop i
b fl_drawByte_s

fl_drawByte_i_e:


bx lr
