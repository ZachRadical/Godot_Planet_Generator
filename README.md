# Godot Planet Generator
This is a mini-project for dynamically creating a mesh and collision shape for a 3D planet in Godot 4.2. It uses FastNoiseLite and MeshDataTool to extrude the vertices of an icosahedron, then redraws the faces and normals accordingly. There's also some shaders thrown in for good measure.

The terrain generation algorithm is inspired by Sebastian Lague's "Coding Adventure: Procedural Moons and Planets" video on YouTube: https://www.youtube.com/watch?v=lctXaT9pxA0
The atmosphere effect on the Terran planet and the Sun are based on Martin Donald's "Planet atmospheres, ray-sphere intersections." video on YouTube: https://www.youtube.com/watch?v=OCZTVpfMSys

## How To Use
Some steps in this process are tricky, and one of the TODOS for this repo is to rectify that. Nontheless, read carefully!
### Create New Planet
First, create a new scene with a StaticBody3D root and a MeshInstance3D child

![image](https://github.com/ZachRadical/Godot_Planet_Generator/assets/90569822/64f347cb-d74c-4019-8b71-695ad5bba3fc)

Then, create a new ArrayMesh on the child node

![image](https://github.com/ZachRadical/Godot_Planet_Generator/assets/90569822/faa514ee-11fd-429f-b1d1-9871e5e0ca94)

Next, attach the script "sphere_gen.gd" to the Mesh node

If all is well, you should see it generates a sphere. You can play with the exported settings to change the resolution and diameter of the sphere. The more subdivisions, the higher the resolution. The higher the resolution, the more detail you can have on your planets, at the cost of performance.

Now, detach the gen script from the MeshInstance and instead attach "template_terrain_gen.gd" to the same Mesh node

You should now see all of the exported parameters in the editor. There's a lot of them, but for now, look for the second header called Shape Noise, and increase the frequency a little bit. You don't want too much, but just a little bit to see it in action

![image](https://github.com/ZachRadical/Godot_Planet_Generator/assets/90569822/168b30e5-778f-4bca-b3ed-e37cf1f0ee9b)

# Noise Settings

Clicking the object under the "Fnl" parameter shows a menu for the noise algorithm attached to that noise category. It should look like this:

![image](https://github.com/ZachRadical/Godot_Planet_Generator/assets/90569822/2c0516f5-7ad3-46d3-a599-75df90325f62)

Note: Any slider parameters (parameters that are of type Float) should be changed only in the exported editor window. Changing it in this FastNoiseLite control panel can lead to inconsistent results, as it tries to pull from the exported values but pulls from the control panel's "master" value instead. Only change Noise Type and Domain Warp toggle from here. When changing a value in the FNL control panel, the "New seed" exported variable button needs to be pressed for that export category in order for the change to take effect. 

### Noise Types
These are the foundation of the noise shape. Each one will have a vastly different look depending on the parameters applied, and conversely, the same look can be achieved by different noise types using the proper params. The name of the game is EXPERIMENTATION.

Simplex: Basic, rounded deformations; good for learning how noise algorithms work, but is generally outmoded by other noise types in practice.

Simplex Smooth: The better version of Simplex; smooths out terrain more and is less prone to rounding errors, which can sometimes break the geometry.

Cellular: Distribution deformations in a grid; can be modified with it's own unique parameters like Jitter, which randomly offsets the grid to create a more natural-looking pattern.

Perlin: Similar to Simplex Smooth, but usually distribution the noise horizontally rather than vertically, allowing for a more uniform topography. Good for making natural bumps that aren't so jagged that they become distinctly mountainous or hill-y.

Value Cubic: Uses the absolute value of the noise and rounds it subtley to give the extrusions some curvature. Good for abrasive terrain with a large margin of elevation.

Value: Value Cubic but without nearly as much rounding. Some rounding still exists here to prevent geometry destruction, but will look much more jagged than Value Cubic.

### Fractal Types
These are an extra calculation applied to the noise values to give it an even more distinct look. Each fractal type can look different depending on the base type, and with their own fractal parameters, there are millions of possibilities when combined with different base Noise Types.

None: Doesn't apply a fractal type

FBM: Applies a rounding effect to everything, and dispersing the noise a little more uniformly across terrain. Very good go-to for normal-looking planet shapes.

Ridged: Concentrates the noise values into singular points; in terms of the sample picture shown in the Fnl noise settings, these often like more like "lines" than "splotches". Easy way to make some quick mountains.

Ping-pong: Creates a ringed, porous-like pattern in the terrain. Ping-pong strength is a unique parameter for this fractal type, which can further increase the frequency of the rings that are created. You can make some really crazy (or really ugly) shapes with this.

### Noise Params
Seed: The random seed that generates that specific noise pattern. Necessary access point for procedural generation.

Frequency: Increases frequency of deformations; less will create a smoother terrain, more will create a more granular terrain. Recommend keeping lower than 2.

Offset: repositions the location of the deformations on all three axes. Not very useful for procedural generation, but comes in handy when hand-crafting planets.

Fractal Lacunarity: Increases sharpness of fractal effect; will often make terrain more jagged and/or granular. Recommend keeping lower than 10.

Fractal Gain: Increases magnitude of fractal noise; A value of 0 will see no fractal noise at all, while higher values will see a maelstrom of geometry take hold of your editor view. Recommend keeping this at or below 1.

Weight Strength: Homogenizes fractal values, making the fractal noise more uniformly spread across the terrain. Values range between 0 and 1. If you have a fractal pattern that you like but is a little too violent, try increasing this value to be closer to 1. Conversely, if a fractal pattern appears too subdued, lower this value closer to 0.

Fractal Octaves: Increases frequency of fractal noise distribution. At a max of 10, this will make the pattern appear more small, but much more frequent. Exceeding 10 can destroy geometry, so be careful.

## Domain Warp
This is the scary stuff. You can make extremely interesting designs when using this, but you also need to be extremely careful. It is highly recommended that you pre-emptively set all domain warp values to 0 before enabling it.
Domain Warp can greatly alter the shape of your geometry for better or worse. It can make terrain look more natural or unnatural, depending on your goal. It has it's own Noise and Fractal types in the FNL control panel, so there's many more degrees of experimentation with this enabled, however, you are more likely to destroy your geometry if you are not very careful when playing with the parameters. The power of domain warp is matched only by its volitility. The phrase "Use with caution" proactively applies to each parameter.

### Domain Warp Params
Domain Warp Amplitude: Increases power of domain warp modifier; Power is proportional to other parameters, namely frequency and lacunarity, so the max recommended value can be fuzzy. As a hard rule i never let it go above 10, but sometimes values lower than that can still destroy geometry depending on other values, so play it safe.

Domain Warp Frequency: Similar to regular noise frequency, this impacts the amount of distortion happening to the geometry, but this time through the Domain Warp algorithm rather than regular noise.

Domain Warp Lacunarity: The sharpness of the domain warp; similar to fractal lacunarity, but applies to the fractal type *of* the domain warp, and will similarly turn your planet into a porcupine the closer you get to a value of 1.

Domain Warp Gain: Increases magnitude of Domain Warp's Fractal setting; Recommend keeping it below 1.

Domain Warp Fractal Octaves: Increases distribution of Domain Warp's Fractal setting. Recommend keeping it between 2-5.


## Exported Editor Categories

### Shape Noise
This dictates the general shape of the whole object. In other words, this dictates the geography of the planet. With high frequency and lacunarity, it can look very granular, like a moon or otherwise barren world. For natural looking landscapes, Perlin with the FBM Fractal type is usually a good option. Simplex Smooth can also get the job done if you want something a little more rounded.

### Mountain Noise
This dictates the shape of mountains. Without params set under Mask noise, this will not have any effect. For the most part, any noise type with the Ridged fractal type will do, but with some experimenting you can also create very unique looking mountain ranges. For example, Cellular with return type set to Cell Value can create raised plateaus that can be blended into the terrain with the proper weight strength and fractal params applied.

### Mask Noise
This one can be tricky to understand, but this one dictates what is and isn't mountain. If the frequency of this is set to something high, you'll notice that mountains cover much more of the landscape, and lower frequency may create more defined mountain areas, or make an entire third of the planet into mountains. Experimenting is key with this one, and you may end up setting a new seed and tweaking the offset very often until you find a distribution you like.

## Fixing Destroyed Geometry
If you go too crazy with the settings and find that you have destroyed the geometry, you will have to create a new planet with the instructions listed above. Destroyed geometry usually looks like a hole was punched into the planet.

# TODO

1. Fix editor issues; This is an amputation of an old project I was working on, so there are some things from it that the editor will try to find but simply don't exist
2. Clean up icosahedron algorithm to not fill the editor with error text
3. Decrease frequency of geometry destruction
4. Edit/Rewrite this readme
5. Make the exported variables cleaner; maybe add semantic names to variables instead of things like Lacunarity and Gain

