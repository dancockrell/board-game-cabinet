# Character batch production

Current user direction: produce full sprite sheets in large batches, expanding the established characters with interesting complete sequences. Do not return to one generated image per pose. Use only built-in image generation. Retain the shared pixel-art identity, elevated camera, mature proportions, clean silhouettes and coherent equipment.

## Scale and organization

Production target: seven characters x sixteen action families x four directions x eight drawings = 3,584 requested drawings. This is a content target, not a claim of completed or usable sprites. Each hero needs 64 directional clips, organized into sixteen 32-cell sheets. The complete roster target is 112 sheets. Start with existing Hoplites, Atalanta, Heracles and Medusa; expand Minotaur, Hydra and Harpies next. Their movement families adapt to creature anatomy.

Action families: idle, walk/flight, run/fast flight, movement start, movement stop, turn, primary attack, secondary attack, guard, light hurt, heavy hurt, stagger, dodge, defeat, victory and arrival. New actions first supply presentation variety; they do not invent new rules abilities. Every gameplay action remains triggered by authoritative state/events.

Initial wave: four sheets per character, four characters, 512 requested cells. Each sheet contains four complete eight-frame sequences. Rows stay chronological. Drawings can repeat at intentional return-to-rest bookends, but those are not counted as distinct added poses. Observed figures, usable cells, approved clips and runtime-admitted drawings are separate counts.

## Sheet contract

Use the existing character references; preserve costume construction, palette, handedness, weapons, silhouette and elevated camera. A sheet must specify every row action and ordered frame beats. No mirrored equipment swaps. Ask for true alpha or the existing controlled magenta key; no light-background masking or baked checkerboard. Preserve original pixels and use runtime keying for previews.

Default layout is eight columns by four rows. Long-weapon sequences can use four columns by eight rows, each clip occupying two consecutive rows of four, so weapons have adequate horizontal room. Requested layout is not proof of actual layout. Measure the image and verify rows before making Resources. A seven-figure row must not be sliced as eight; neighboring spears crossing cell boundaries are a failed crop, even if the full sheet looks attractive.

## Shared delivery and game admission

Store unchanged sheets, exact prompts, source paths, hashes, row metadata and findings in art_batches/<character>_batch_01 and a corresponding local shared-library candidate folder. Candidate batches are excluded from Windows exports. Do not publish private candidates to the public shared repository automatically.

Preview useful rows with the real PixelActor/key shader. Review the full sequence at close and battlefield scale, including feet registration, equipment continuity, edge bleed and loop/recovery. Admit good rows independently; a bad walk does not discard a useful defeat sequence. Approved runtime clips get explicit Resources and event integration, tested against authoritative state. Replacement requires evidence that it improves the current action.

## Parallel ownership

Each character agent owns one batch folder and one batch report. The coordinator owns export exclusions, batch indexing, preview tooling, runtime integration and publication. Work in sheet batches, commit exact owned files frequently, and keep generation, review and runtime-admission statuses honest. Small implementation fixes remain separate commits.
