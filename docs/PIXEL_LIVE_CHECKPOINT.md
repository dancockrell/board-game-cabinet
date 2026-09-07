# First live pixel unit checkpoint

The live arena now renders Hoplites with PixelActor and triggers their guard/recovery on authoritative health decreases. Repeated snapshots cannot replay damage; serial is owned by the visual replica and discarded when the replica is removed. Ghost previews support sprite tint. Game coordinates, targeting, damage and resource rules remain authoritative.

Temporary limitations: Hoplite locomotion is still a static glide; only one facing has guard frames; no pixel attack clip; both factions have blue garment art and are distinguished by existing team markers. Other units and terrain remain legacy 3D. This is an integration checkpoint toward the full goal, not final visual acceptance. The guard is a cosmetic damage reaction, not a newly implemented blocking mechanic.

Native verification: 64 roster checks, 55 app checks, 35 board checks passed; 773 arena rule checks passed. Captured 180 frames at 30 fps after six legal player placements, match seconds 38-44. Live screenshot reviewed. Dense sprite source looked sharp at small screen size, so source mipmaps and nearest-with-mipmaps filtering are enabled to reduce minification shimmer.

Whole-sheet walk generation again failed opposite-foot continuity. Original is retained in work/art-source/olympus/walk-rejected-02 with rejection reason. Next art step is one correctly controlled opposite-foot contact pose, then intermediate poses. No more whole-sheet retries of that failed recipe.

Windows checkpoint exported from 0705c5f. Launch/capture smoke completed with exit 0. Executable SHA256 716BA704F738EF6C24FCD0B7127E41F134B52EE57C5C78C73E0BBEC87B243853. Local archive: Olympus-Pixel-First-Live-Windows.zip. No final quality or full-match export acceptance is claimed.
