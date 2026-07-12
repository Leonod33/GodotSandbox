# Ken sprite-sheet notes — full-resolution remap

The authoritative sheet is the original 1546×5207 RGBA PNG. Its background is already transparent, so the fighter references it directly without a colour-key or resized derivative.

All atlas rectangles in `ken_fighter.gd` are expressed directly in the full-resolution PNG's pixel coordinates. Each frame also has an explicit bottom-centre anchor derived from its visible alpha bounds. This keeps the feet on the floor and prevents differing crop sizes from pulling Ken sideways. The `Node2D` itself is never moved or scaled to compensate for a bad crop.

## Confidently identified for this build

- **Idle/standing:** first six sprites on the first row (`x=15…407`, `y=17…115`).
- **Forward walk:** first six sprites on the second row (`x=15…402`, `y=152…247`). The second six nearby appear to be the alternate/backward walk cycle; they are intentionally deferred until movement timing and facing have been tested.
- **Crouch:** the standing-to-crouch transition around `x=76…206`, `y=1141…1216`.
- **Neutral jump:** the compact vertical arc around `x=76…494`, `y=1522…1694`. The animation is driven by the character's physical ascent/apex/descent rather than playing as a blind loop.

## Import settings

- Filter: nearest (set on the fighter `CanvasItem`).
- Mipmaps: disabled (`mipmaps/generate=false`).
- Compression: lossless (`compress/mode=0`).
- Resize limit: disabled (`process/size_limit=0`).

## Recognised but deliberately deferred

The upper sheet clearly contains standing normals, kicks, hit/guard reactions and knockdowns. The lower sections contain crouching attacks, jumping attacks, throws, victory/defeat sequences and special moves including projectile and rising-uppercut effects. These have not yet been assigned names or timings because several neighbouring sequences are visually similar without testing them in motion.

## Assumptions

- The character begins facing right; the same frames are mirrored when facing left.
- Movement uses a modern smooth velocity for this prototype, not yet frame-perfect SFII movement data.
- The ground collision is currently a single floor plane. Fighter pushboxes, hurtboxes and attack hitboxes are intentionally postponed.
- All six conventional controller attack buttons are reserved. Start/Menu exits the experiment so B/Circle remains available for a future kick binding.
- The original sheet remains available as the authoritative source and instant fallback; movement and animation definitions do not depend on the enhanced sheet.
