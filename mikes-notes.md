## Godot Notes
- Avoid using Control nodes for anything except UI. Most notably, ColorRect, which has no direct equivalent, should not be used outside of UIs. Using a Sprite with a white texture that's modulated is an easy workaround.
- If a scene is at the wrong origin, it's not really a big deal. Almost every instance will already have a position overriding the default, so you probably only have to hunt down one or two messed up instances after changing the origin to fix it.
- To make YSort work nicely, I recommend putting the origin at the point on the ground the object is at or above, even if they're flying. 
- If objects (like walls) get parented to each other, it will break the YSort. All objects should be parented to a YSort.
- Spawning containers, like the shadow spawn container and lantern spawn container, should also have been YSorts. 
- Using preload for audio assets appears to bypass the settings in their .import files. For SFX, the easy route is just to change .loop to false before playing it in play_sfx.

## Mechanic Design Notes
- Grid based movement looks and feels a lot better with hops.
- Grid based movement makes a lot of things easier.
- Grid based movement makes it awkward to have doors and walls that are not a full grid square thick. Putting them in the middle of the tile instead of at the edge is a common solution. This would also have reduced the number of wall types we had to deal with, but it would've made it impossible to push a statue directly up against a wall. South facing walls also seemed odd, because the nonwalkable area doesn't line up between art and collider.
- Timing is not enough to link cause and effect for players. An object that causes a change based on change in environment must also change itself, or many players will not notice it.
- Not all players will play with audio on. Using SFX to convey information is excellent, but it should always be reinforcing communication that is already happening.

## Shader Notes
- Light2D is a 2D light. To use it properly in 2.5D, pick a plane, light that plane, and then project the light from that plane along the height of surfaces. It won't be quite accurate if objects are short and should only cast shadows partway up a wall, but it's good enough.
- You can do the above Light2D projection by only lighting the floor, and then using a shader to read the pixels along the bottom edge of the current "face" to determine their lighting.
- Light shaders are pretty weak. They don't perform changes to screen space directly, they just modify values on the lights. You can use them if you want to do anything interesting with normal maps or trickery with lighting vectors, but they can't change the light mixing or apply any direct changes to an object.
- Sprites are just a single quad, so vertex shaders aren't really that useful. You can add a custom class that adds additional mesh geometry, and there's an easy to use open source one called geosprite. 
- Using a separate viewport as a render buffer seems very useful and worth looking more into before the next jam. 

## Art Notes
- Thin outlines alias pretty badly when downscaled. Real anti-aliasing is only available on desktop builds, unfortunately. 

## Level Design Notes
- The underlying mechanics and art MUST align. It's obvious in hindsight, but having the LightOccluders match the CollisionShapes used to calculate litness in puzzles is an absolute must, and when choosing how to set up one you must consider how it impacts the other.
- Not all puzzles should introduce a new concept. Discovering a new concept is not a satisfying experience if you haven't felt the power of the previous concept yet. We needed more puzzles that use the already introduced mechanic set in interesting ways before jumping to the next one.
- Combining two concepts and discovering a new interaction treads a fine line between showing the power of previous concepts and discovering an entirely new mechanic. It can fall into either category depending on how much the parts contribute to the whole, and on how clear it is that that interaction will actually occur once the player thinks of it. If the combination is something the player does not think is likely to have been added to the game, something has usually gone wrong.
- Designing all the levels up front was both a blessing and a curse. While it was nice to know exactly what assets and mechanics would need to be added to the game, the problems arose once it came to balancing them. Mechanic changes that prevented issues on one level would cause issues in another, and issues that aren't visible in a level diagram, like parts of the puzzle being offscreen, really hurt a lot of levels. Not being able to feel the timings in levels when designing also caused issues with the ideal timings of things like shadow spawn countdown time being different between levels. 
- The designer should probably be the one to build out the level, and they should build it sequentially, testing that each area accomplishes its goals before moving to the next. This might just be my personal preference, but getting dropped into a ton of unbalanced levels and trying to edit it down from there seems like a rough time. 
- Puzzle games are about the levels. You are not ahead if you punch out the core mechanics quickly. We didn't underestimate the amount of work designing levels, I don't think, but we did underestimate the amount of work it would be to balance the levels. 