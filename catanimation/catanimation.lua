
--import pygame, sys
--from pygame.locals import *

require "love" -- or: local love = require "love"
require "love.graphics"
require "love.event"
require "love.timer"

--pygame.init()
function love.load()
	FPS = 30 -- frames per second setting
	--fpsClock = pygame.time.Clock()

	-- DISPLAYSURF = pygame.display.set_mode((400, 300), 0, 32)
	love.window.setMode( 400, 300, {} )

	-- pygame.display.set_caption('Animation')
	love.window.setTitle('Animation')

	-- WHITE = (255, 255, 255)
	WHITE = {255, 255, 255}
	WHITE = {255, 135, 135} -- not reallly white :p

	-- catImg = pygame.image.load('cat.png')
	catImg = love.graphics.newImage("cat.png")

	catx = 10
	caty = 10
	direction = 'right'
end


--while True: # the main game loop
--    DISPLAYSURF.fill(WHITE)
function love.update(dt)

	-- if direction == 'right':
	-- 	catx += 5
	-- 	if catx == 280:
	-- 		direction = 'down'
	if direction == 'right' then
		catx = catx + 5
		if catx == 280 then
			direction = 'down'
		end

	-- elif direction == 'down':
	-- 	caty += 5
	-- 	if caty == 220:
	-- 		direction = 'left'
	elseif direction == 'down' then
		caty = caty + 5
		if caty == 220 then
			direction = 'left'
		end

	-- etc.
	elseif direction == 'left' then
		catx = catx - 5
		if catx == 10 then
			direction = 'up'
		end
	elseif direction == 'up' then
		caty = caty - 5
		if caty == 10 then
			direction = 'right'
		end
	end

	fps(dt)
end

function love.draw()
	-- DISPLAYSURF.blit(catImg, (catx, caty))
	love.graphics.draw(catImg, catx, caty)
end

-- 	for event in pygame.event.get():
-- 		if event.type == QUIT:
-- 			pygame.quit()
-- 			sys.exit()

function love.quit() -- see: https://love2d.org/wiki/love.quit
	-- custom on-quit stuff
end

function love.keypressed(key)
	-- press escape to quit
	if key == 'escape' then
		love.event.quit()
		return
	end
end



-- 	pygame.display.update()
-- 	fpsClock.tick(FPS)

function fps(dt)
	-- see: https://love2d.org/wiki/love.timer

	-- <code from https://love2d.org/wiki/love.timer.sleep>
	-- Use sleep to cap FPS at 30
	if dt < 1/FPS then
		love.timer.sleep(1/FPS - dt)
	end
	-- </code>
end
