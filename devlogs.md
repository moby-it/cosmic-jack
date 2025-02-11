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

## 7/2 14:26

After some thought, it's clear that the prototype has to have music. Enemy spawns have to be on-beat, and fruit explosions are also on-beat. I have to implement both
so that I can then focus on level design, which in this game and every puzzle game, is where I _should_ spend most of my time.

## 8/2 01:05

I think fruits working with beats is going to be extremely tough for the average player, if it's tough for me. You either have to sync the explosions to also start ON beat,
or consider sticking with second timers on fruits. You want to create a game, not a whiplash song.

## 8/2 01:50

It's late, I have to sleep. The current state has some issues:
	- When pausing, the spawning gets messed up. It's probably due to the next_beat being all messed up after the pause.
	- Animation does not work for enemies. Check croc.gd
	
## 8/2 - 16:08

Managed to sync adequetly the beats of the song to both animations and fruit explosions.
	- I have to explain the game better in the tutorial.
	- I have to work on level design.

## 11/2 - 13:13

There's a weird issue with audio sync. Sometime the time delay works and sometimes it just ruins the sync. It makes sense to need the time delay, as per [docs](https://docs.godotengine.org/en/stable/tutorials/audio/sync_with_audio.html), but it does not work consistently.
I introduced the cherry fruit. The goal of this fruit is to give a really fast trigger on watermelons, so that the player has another mechanic to trigger it.
I fear that the enemies moving continously instead of discreetly makes the game increadibly more complex.