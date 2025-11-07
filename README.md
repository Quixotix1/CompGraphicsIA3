# CompGraphicsIA3

A simple project going over shadow casting, glass, scalable vertex shaders, and scrolling water. Most of it doesn't work, but it definitely goes over it.

## Overview

The project contained the following shaders:
- Scalable Vertex, a shader which allows the user to input a "scale" value and modify the UV according to the sine of the product of the UV and scale input
- Shadows, which creates and reads shadows cast on it
- Glass, which is a transparent shader using a normal map to create a textured glass-like surface
- Water, two shaders (one scrolling and one not) that essentially lay a given foam texture over the water texture

## Issues

The shadows texture has a strange effect at certain radii away from the camera. It appears the shadow resets or otherwise breaks from these distances? The effect can be seen below:
<img width="887" height="577" alt="image" src="https://github.com/user-attachments/assets/bd5eebcf-89cd-4551-a665-67b4af666641" />

The glass is not transparent. A solution was provided in class, but the git project as provided here does not contain it.
<img width="357" height="545" alt="image" src="https://github.com/user-attachments/assets/b3f7193d-6876-40a9-aaba-289e0fbe8b97" />

## Reflection

The project was certainly tricky to put together. The biggest problem by far was the shadow shader as the other two broke insofar as the scripts would likely have to have been rebuilt to construct them (as opposed to the shadow shader which was demonstrably throwing incorrect behaviour). I do not remember the solution, but I believe it had to do with a CBuffer that I simply removed.

## Sources

Some of the textures came from the lecture, particularly from https://3dtextures.me/. The wood texture which could be found in the project demonstrating the scalable vertex shader can be found at https://ambientcg.com/ which contains a massive library of free assets.
