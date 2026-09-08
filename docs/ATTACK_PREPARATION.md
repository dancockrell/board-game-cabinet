# Attack preparation and contact timing

The rules now expose their current in-range target as attack_target on a unit snapshot. This is presentation data only: targeting, cooldown duration, damage, target death and legal movement remain decided by the existing RefCounted session. The full775-check arena suite passed without changing its expectations.

A nonlooping SpriteClip can declare strike_time. The board uses the authoritative target and remaining cooldown to begin the available preparation portion of that clip. PixelActor holds just before contact until the authoritative hit event arrives, then selects contact and plays recovery. Repeated snapshots cannot invent or repeat a hit. A target leaving range cancels preparation, and zero visual delta freezes the exact phase. Float32 frame-duration boundary tolerance keeps the declared contact marker on the intended drawing.

Initially enabled for the rich Hoplite east thrust, Harpy south attack and Atalanta north/south bow shots. Other clips retain their existing event playback until their contact poses are identified. An immediate first strike with no preceding in-range cooldown still uses direct playback; the renderer never delays rules damage to manufacture anticipation. Limited available preparation time can skip early setup poses. Projectile travel remains cosmetic after the hit decision; this is not a simulation wind-up or delayed-damage redesign.

Validation: dedicated59 native checks drive the real session cooldown and board, covering multiple preparation drawings, exact contact frame, unchanged damage, pause, stale snapshots, recovery and target loss. Existing motion continuity20 and sprite67 checks pass. A180-frame60fps rules-driven combat study recorded snapshots and contact timing; this is a controlled study, not a full match.

The intent does not authorize the view to apply damage or move units. More authored anticipation/recovery directions remain needed.
