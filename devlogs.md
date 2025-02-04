## 27/12 00:30

Today was a good day. I set up the basic structure for the levels 
	- rivers are the paths,
	- convoys are the paths + enemies + speed + spawn_interval + count, 
	- waves and a list of convoys.

I really like this. It seems you can set up levels this way and really fiddle with the puzzle concept and remove the noise from the program.

I need to implement 
	- the wave preview,
	- the wave resolution,
	- the hp reduction,
	- and the game end
	
	Cheers
	
## 27/12 17:41

SO HYPED. Seems most things work. 
	- I create the sequence of waves to work. 
	- You can easily modify rivers, speeds etc to create levels.
	- It's very easy to add new waves and convoys and rivers to the infra.

Before demo I have to:
	- Create a game over and retry screen.
	- Create a level won screen with a score. For now, we can go with, fruits left + hp
	- Create a time travel mechanism. Give the player the option to open a menu and travel back to a specific wave and replay it.

## 27/12 23:03

Seems to be working. It's ugly, it's true. But it might make a good game, while still being as ugly as it is. I have to gather emails to send the demo over next week.

## 4/2/2025 13:35

I'm working towards integrating music. Music is very important. I should sync some basic enemy animation with the beat. 
I've managed to get the beat time for each wave and now I have to sync this with an animation. Due to the fact that enemy colliders will change on animation, this **should**
be something the player can leverage.
