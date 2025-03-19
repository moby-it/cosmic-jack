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

## 13/2 - 20:24

I did some basic playtesting with Panos and Nekti. It seems that the game is not entirely too hard for everyone. 
For Nekti, an experienced puzzle-games player that was also a singer, the game seems pretty straightforward and rewarding! I can build on that.
However, I do not want the game to be for experienced puzzle players with an affinity for music. I want the game to have a casual vibe and, potentially, have hidden gems for those who want to get better and improve.
I'm working on a refactor so that each wave has a specific set of fruits available. This pushes the game in the puzzle-aspect more. It limits the possibility space. Makes the game more tight.

Thoughts regarding this path:
	- If the puzzles are to be tight, there has to be a hinting system 100%
	- I have to reward players that manage to beat a wave by spending less resources than allocated. Maybe a star reward system, or maybe reward HP.

But mostly, I have to consider - do I want to make a tight game, or do I want to create a casual game? Should the game be hard, in any way?

## 14/2 1:29

It seems that most stuff works, and the puzzles can be actually tough, which is nice. I have a bug with timings when pausing and unpausing on a wave
that is never rendered compeltely once.

## 20/2 12:29

Wokring on wave design.
Each wave should serve a purpose. I intend to create 10 waves for the prototype. Waves should also have "hacks". 
A player can finish the wave with using less than suggested resources, rewarding a hidden score.
1st wave is a simple apple puzzle.
2nd is a harder apple puzzle.
3rd introduces the watermelon, but CAN be solved with an apple, if placed correctly.
4th level, you are forced to use a watermelon.
5th level introduces chain-reaction watermelons.
6th level introduces the cherry.
7th level combines cherries with watermelons.
8th, 9th, 10th should be challenges for the player.

## 20/2 16:00

Working on wave design.
1st introducing the apple - simple puzzle based on a circular movement.
2nd challenge on apple - fast moving enemies that have a path in which they return to the trigger spot.
3rd introducting watermelon - simple pattern that forces watermelon resolution.
4th challenge on the watermelon - chain explosions with an apple as trigger.
5th introducting the cherry - linear movement, simple puzzle.
6th small challenge on cherry - enemies cross paths.
7th cherry as watermelon activator
8th, 9th, 10th, challenge levels

## 21/2 12:25

It's getting better. 
I added a wave intro screen. Seems to work fine. However, the issue is that a music track is tied to a wave, meaning that it starts abruptly after you close the wave announcer.
We could do multiple things here - we can consider adding a separate song for each wave. I think it would be awesome to have each wave song split into layers. I want to give
hints in coordination with fruits.
For example, drum 'n' bass could mean that the level can be solved exclusively with apples. Drum 'n' bass + guitar could mean that the watermelon is mandatory.
In addition, if everything is split into phrases, I can mix & match phrases more easily.

## 22/2 20:08

I intend to make the following loop in the 1st leveld design:
	- teach something new
	- challenge the player with it
The 1st 6 levels are of the above pattern. The last 3 levels have to challenge the player.
7th level idea - chain explosion reactions, that get triggered by a cherry. Try to add an apple, just to mess with the player.

## 23/2 21:00

- Refactor audio: each level has a continous song that does not stop on user input.
- You can restart the preview pressing R
- Added wave titles and description

Consider if you're going to carry over unused ammo on next levels. This will decrease the difficulty of the latest levels, giving players choices earlier on
that impact later levels. I think this is a must. To do that I need to:
	- restore the functionalities of saving ammo per wave and restoring it when backtracking.

## 25/2 12:24

Added level 8, interruptions. Need to create 2 more levels.

## 19/3 11:56

On the 9th of March I sent out the 0.2.0 prototype. So far I have 8 responses. The critical take aways so far are:
	- The game is a spacial game, rather than a rythm game. It's strong aspect is the spacial part.
	- The music sometimes becomes a nuance. While people enjoy it as an aesthetic, they don't enjoy it as a mechanic.
	- Remove the tutorial. Try to to a level design that does not need a tutorial.
	- Make the UI more intuitive. Drag-n-drop the bombs, instead of this ctrl click shit.

I'm working on the following:
	- remove the resolution and preview phase. There's only one phase in which 
		- place fruits
		- fruits interact with enemies
		- if any enemy escapes the pattern placement, the puzzle automatically replays, until you solve it.
		
This way everything is still on beat, but the game is more of a trial and error game. You have a sense of progress as well. You built your solution like legos.
Resembles a physical puzzle!

Next steps:
	- Remove the level retry screen. It does not make sense.
	- refine the code, simplify things. Go closer to pure functions, based on singleton classes.
	- Test the level end to end.

## 19/3 20:13

I did most of the previous entry's work regarding functionality. An issue is with the pause function - right now after you pause, the convoys don't render correctly.
There's an incosistent distance between the enemies. Play with pause and unpause BEFORE all enemies are rendered, to see that.

I need to fix the above issue, for sure. And also, I want to clean up the logic. It seems that on all games, the mutations on rendered stuff is the almost the same thing as state.
Each change in state typically needs to be rendered. It much like resembles front end work, but with performance in mind.
