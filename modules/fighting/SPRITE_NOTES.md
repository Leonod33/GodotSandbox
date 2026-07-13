# Ken sprite-sheet notes — full-resolution remap

The authoritative sheet is the original 1546×5207 RGBA PNG. Its background is already transparent, so the fighter references it directly without a colour-key or resized derivative.

All atlas rectangles in `ken_fighter.gd` are expressed directly in the full-resolution PNG's pixel coordinates. Each frame also has an explicit bottom-centre anchor derived from its visible alpha bounds. This keeps the feet on the floor and prevents differing crop sizes from pulling Ken sideways. The `Node2D` itself is never moved or scaled to compensate for a bad crop.

## Confidently identified for this build

- **Idle/standing:** first six sprites on the first row (`x=15…407`, `y=17…115`).
- **Far standing light punch:** row 3 frames 1–3.
- **Far standing medium/heavy punch:** both use row 3 frames 4–8. Heavy holds the fully extended third frame longer.
- **Close standing punches:** row 5 contains light (frames 1–3), medium (frames 4–10), and heavy (frames 11–15).
- **Far standing light/medium kick:** both use frames 1–5 on row 4. Light plays the sequence quickly; medium pauses briefly on the fully extended third frame.
- **Far standing heavy kick:** frames 6–10 on row 4.
- **Close standing kicks:** row 6 contains light (frames 1–5), medium (frames 6–10), and heavy (frames 11–16).
- **Forward walk:** first six sprites on the second row (`x=15…402`, `y=152…247`). The second six nearby appear to be the alternate/backward walk cycle; they are intentionally deferred until movement timing and facing have been tested.
- **Crouch:** the standing-to-crouch transition around `x=76…206`, `y=1141…1216`.
- **Neutral jump:** the compact vertical arc around `x=76…494`, `y=1522…1694`. The animation is driven by the character's physical ascent/apex/descent rather than playing as a blind loop.
- **Travelling jump:** all nine sprites on row 16 (`y=2167…2345`) form the forward/backward somersault and play rapidly over a committed horizontal arc.

## Import settings

- Filter: nearest (set on the fighter `CanvasItem`).
- Mipmaps: disabled (`mipmaps/generate=false`).
- Compression: lossless (`compress/mode=0`).
- Resize limit: disabled (`process/size_limit=0`).

## Controls

- Xbox controller **X**: standing light punch (`JOY_BUTTON_X`, button index `2`).
- Xbox controller **A**: standing light kick (`JOY_BUTTON_A`, button index `0`).
- Xbox controller **B**: standing medium kick (`JOY_BUTTON_B`, button index `1`).
- Xbox controller **RT**: standing heavy kick (`JOY_AXIS_TRIGGER_RIGHT`, axis index `5`).
- Xbox controller **Select/View**: toggle the training-ground help overlay.
- Xbox controller **L3**: reset Ken to his starting side of the dummy.

## Training dummy

- The dummy is a blue-palette Ken using the same six-frame idle animation.
- It remains at the stage centre and turns to face the player.
- Ground pushboxes meet when the two idle sprites' forward hair/head tips touch; airborne movement still permits jump-over crossovers.
- Ken automatically faces the dummy after moving to either side.
- Confirmed standing punch and kick variants are selected automatically within a 155-pixel centre-distance threshold. Since ground collision occurs at 106 pixels, close attacks require Ken to enter roughly the nearest half of the available range. LB remains available as a direct close-heavy-punch preview.

## Recognised but deliberately deferred

The upper sheet clearly contains standing normals, kicks, hit/guard reactions and knockdowns. The lower sections contain crouching attacks, jumping attacks, throws, victory/defeat sequences and special moves including projectile and rising-uppercut effects. These have not yet been assigned names or timings because several neighbouring sequences are visually similar without testing them in motion.

## Assumptions

- The character begins facing right; the same frames are mirrored when facing left.
- Ground movement uses a modern smooth velocity. Jumps now use a higher, sharper committed arc inspired by the original SFII behaviour, but are not yet frame-data-perfect.
- The ground collision is currently a single floor plane with simple horizontal fighter pushboxes. Hurtboxes and attack hitboxes are intentionally postponed.
- All six conventional controller attack buttons are reserved. Start/Menu exits the experiment, while Select/View opens its help overlay.
- The original sheet remains available as the authoritative source and instant fallback; movement and animation definitions do not depend on the enhanced sheet.
