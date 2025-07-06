# Untitled Puzzle Platformer

![Screenshot03](https://github.com/user-attachments/assets/c152372a-f6f6-4a39-97e5-67514245e384)

Inspired by the Nintendo puzzle game Kuru Kuru Kururin for the Game Boy Advance. 

Development is in progress as of July 6th, 2025. No playable demo yet.

Completed aspects include custom collision detection, tilemaps, progress and settings saving, collectables, color-swap shaders for multiple skins, and a handful of interactable objects.

The code and art were created by Walker Jones. SFX were taken from a license-free SFX library. Some Godot tools were used as well.

Art was created in Aseprite

# Tools used

## "BetterTerrain" by Portpunky - Unlicense

Used instead of Godot's built-in tilemap editor as it contains more features.

# Screenshots

![Screenshot04](https://github.com/user-attachments/assets/a6a5a605-880a-48c0-98da-e37d8703a665)

Still image of some visuals created via fragment shaders.

The whirlpool was created by converting UV coordinates to polar coordinates and utilizing [trigonometric shaping functions](https://thebookofshaders.com/05/) to create a [logarithmic spiral](https://en.wikipedia.org/wiki/Logarithmic_spiral#:~:text=A%20logarithmic%20spiral%2C%20equiangular%20spiral,(%22ewige%20Linie%22).) and then coloured with a colour gradient. 

The water current was created using [Perlin noise](https://en.wikipedia.org/wiki/Perlin_noise) texture for the body and a "sum of sines" algorithm to create convincing waves on the sides. 
