# Godot Sandbox

An expandable collection of small, interactive Godot 4 experiments. The sandbox is organised into categories so that mechanics, effects, and reusable ideas remain easy to find and test.

## Current module

- **Physics → Projectile Laboratory** — adjust launch angle, speed, and gravity, then compare the predicted trajectory with a live projectile.

## Planned categories

- Physics
- Sprites
- Scoring Systems
- Unusual Visual Effects
- Basic Gameplay Loops

## Adding a module

1. Create a self-contained scene inside the appropriate `modules/` folder.
2. Add its details and scene path to `shared/sandbox.gd`.
3. Use `Sandbox.open_category(...)`, `Sandbox.open_module(...)`, or `Sandbox.go_home()` for navigation.

The menu reads directly from the catalogue, so no menu scene needs to be redesigned when a module is added.

