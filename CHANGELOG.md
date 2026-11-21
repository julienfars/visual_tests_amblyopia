# Changelog

## [1.1.0] – unreleased

Post-hoc fixes made while preparing the repository for archiving. **The study
data were collected with v1.0.0** (git tag `v1.0.0-data-collection`). Use that
tag to see exactly what ran. Use this version for new data collection.

### Fixed
- **Interleaved-staircase thresholds (`calculateMeanReversals.m`).** For
  `Contrast_Interleaved.m` and `Interocular_Imbalance.m`, the threshold written
  to the `MEAN` row of each output `.xls` was not the mean of the last six
  reversals. The code selected rows of the shared reversal table whose
  *reversal number* equalled the staircase index, instead of rows from that
  staircase, and averaged the *frequency* column, not the contrast. The
  recorded value was therefore either a mean spatial frequency (in
  cycles/pixel) or, when nothing matched, the contrast of the last trial. The
  threshold now comes from the staircase object's own reversal levels
  (`sc.reversals`, last 6, converted with `10^level/100`). **v1.0.0 `MEAN` rows
  for these two tests should not be used as thresholds.** Recompute them from
  the trial-level rows in the same files.
- **Thresholds were never carried over between tests (`results_table.m`).**
  `updateGlobalParams` modified a copy of `global_param` and discarded it, so
  `cut_off_*`, `contrast_*`, `logMAR_*`, etc. stayed at their defaults. The `-`
  ("use the stored value") option in the Contrast and Dichoptic dialogs
  therefore never worked, and the cut-off had to be typed by hand.
- **Crowded tumbling-E files were labelled as uncrowded.** In `results_table.m`,
  `_snellen_e` was matched before `_snellen_e_crowded`, so crowded result files
  got the suffix `_snellen_e` and crowded thresholds were stored as uncrowded
  ones. File names now end in `_snellen_e_crowded`. Analysis code that tells
  the two apart by the word `crowded` in the file name is unaffected.
- **Dichoptic cut-off (`getParticipantInfo.m`, `Dichoptic.m`).** The `-` default
  now uses the **amblyopic-eye** cut-off, as described in the Dichoptic method,
  not the both-eyes cut-off. A stored numeric cut-off no longer crashes
  `str2num`.
- The Contrast and Dichoptic tests now stop with a clear error, before the
  screen opens, if no valid cut-off frequency is available.

### Repository
- Removed pseudonymised participant sessions (`data/temp/`) from version
  control and from the git history, and added a `.gitignore` so test outputs are never committed.
- Licence changed from CC BY-NC-SA 4.0 to MIT (code) + CC BY 4.0
  (documentation and example data). Third-party files keep their own terms,
  see `README.md#third-party-code`. Added Baldwin's AGPL-3.0 licence as
  `functions/LICENSE-staircase`.
- Added `CITATION.cff`, this changelog, and a rewritten README with
  requirements, setup and run instructions, and output file descriptions.

## [1.0.0] – data collection (tag `v1.0.0-data-collection`)
Version used to collect the study data (2023–2024).
