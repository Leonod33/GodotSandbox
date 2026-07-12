# Ken sprite-sheet notes — phase 1

The supplied sheet is 608×2048 pixels and uses an opaque RGB `(0, 129, 129)` background. The project preserves the original PNG; `ken_colour_key.gdshader` remains available when rendering that original source directly.

`ken_sheet_xbr4.png` is a non-destructive 4× xBR derivative. The teal background is removed after upscaling, and the fighter reads the original frame coordinates multiplied by four. A final 1.5× display scale gives the same effective size as enlarging the original frames by 6×, but from reconstructed curves and colour transitions rather than raw enlarged pixels.

## Confidently identified for this build

- **Idle/standing:** first six sprites on the first row (`x=6…160`, `y=7…45`).
- **Forward walk:** first six sprites on the second row (`x=6…158`, `y=60…97`). The second six nearby appear to be the alternate/backward walk cycle; they are intentionally deferred until movement timing and facing have been tested.
- **Crouch:** the standing-to-crouch transition around `x=30…81`, `y=449…478`.
- **Neutral jump:** the compact vertical arc around `x=30…194`, `y=599…666`. The animation is driven by the character's physical ascent/apex/descent rather than playing as a blind loop.

## Recognised but deliberately deferred

The upper sheet clearly contains standing normals, kicks, hit/guard reactions and knockdowns. The lower sections contain crouching attacks, jumping attacks, throws, victory/defeat sequences and special moves including projectile and rising-uppercut effects. These have not yet been assigned names or timings because several neighbouring sequences are visually similar without testing them in motion.

## Assumptions

- The character begins facing right; the same frames are mirrored when facing left.
- Movement uses a modern smooth velocity for this prototype, not yet frame-perfect SFII movement data.
- The ground collision is currently a single floor plane. Fighter pushboxes, hurtboxes and attack hitboxes are intentionally postponed.
- All six conventional controller attack buttons are reserved. Start/Menu exits the experiment so B/Circle remains available for a future kick binding.
- The original sheet remains available as the authoritative source and instant fallback; movement and animation definitions do not depend on the enhanced sheet.
