# Amblyopia Plasticity Study — Psychophysics Test Battery

[![Code license: MIT](https://img.shields.io/badge/code%20license-MIT-green.svg)](LICENSE)
[![Docs/data license: CC BY 4.0](https://img.shields.io/badge/docs%2Fdata%20license-CC%20BY%204.0-lightgrey.svg)](LICENSE-DATA)
[![MATLAB R2022b](https://img.shields.io/badge/MATLAB-R2022b-orange.svg)](https://www.mathworks.com/)
[![Psychtoolbox 3.0.18](https://img.shields.io/badge/Psychtoolbox-3.0.18-blue.svg)](http://psychtoolbox.org/)

![Experiment Image](data/icon/eye_icon.png)

MATLAB/Psychtoolbox battery of psychophysical tests that measures visual
function in adults with amblyopia ("lazy eye") before and after dichoptic VR
training. It was used for the study:

> Fars J. *et al.* **Dichoptic Training Boosts Binocular Vision and Reduces GABA
> in Adult Amblyopia** (in preparation).

The battery measures, for each eye and binocularly: cut-off spatial frequency,
contrast sensitivity, interocular imbalance, dichoptic noise tolerance,
stereoacuity (Asteroid) and tumbling-E visual acuity (isolated and crowded).

> **Version note.** The study data were collected with the code tagged
> [`v1.0.0-data-collection`](../../tree/v1.0.0-data-collection). Later
> versions fix bugs found while preparing this archive, notably in how the
> contrast-sensitivity and interocular-imbalance thresholds are computed. See
> [CHANGELOG.md](CHANGELOG.md) before reusing the `MEAN` rows of v1.0.0 output files.

## Related repositories

This repository is one part of the study's code. The other parts are:

| Repository | Contents |
|---|---|
| [Amblyopia_plasticity_analysis](https://github.com/julienfars/Amblyopia_plasticity_analysis) | Analysis of the behavioural data produced by this battery |
| [lazy_eye_VR_training](https://github.com/julienfars/lazy_eye_VR_training) | Unity app for the dichoptic VR training (Meta Quest 2) |
| [mrs_amblyopia_analysis](https://github.com/julienfars/mrs_amblyopia_analysis) | MR spectroscopy preprocessing and quantification pipeline |

## Contents

- [Requirements](#requirements)
- [Setup](#setup)
- [Running the battery](#running-the-battery)
- [The tests](#the-tests)
- [Output files](#output-files)
- [Repository layout](#repository-layout)
- [Third-party code](#third-party-code)
- [Citation](#citation)
- [License](#license)

## Requirements

### Software
| Component | Version used | Notes |
|---|---|---|
| MATLAB | 9.13 (R2022b) | |
| Image Processing Toolbox | R2022b | `imresize` in the dichoptic noise generator |
| [Psychtoolbox-3](http://psychtoolbox.org/) | 3.0.18 | |
| EyeLink Developers Kit + Psychtoolbox `Eyelink` toolbox | — | Only needed when eye tracking is switched on |

Tested on Linux. On Windows and macOS, `setupScreen.m` skips the Psychtoolbox
sync tests.

### Hardware used in the study
| Item | Setting |
|---|---|
| Display | Display++ (Cambridge Research Systems), 700 × 392 mm, 1920 × 1080 px |
| Stereo presentation | Passive polarised 3D glasses; Psychtoolbox `InterleavedLineStereo` (stereo mode `100`) |
| Viewing distance | 150 cm (all tests); 250 cm (tumbling-E tests) |
| Eye tracker | SR Research EyeLink 1000 (optional) |
| Responses | Keyboard/controller arrow keys (see below) |

The screen geometry and distances are set in
[`functions/GetGlobalVariables.m`](functions/GetGlobalVariables.m). **Change
them for your own setup.** Stimulus sizes are computed in degrees of visual
angle from these values. Without a line-interleaved stereo display, the
monocular/dichoptic separation will not work as intended.

## Setup

1. Install MATLAB, the Image Processing Toolbox and Psychtoolbox, and run
   `PsychtoolboxVersion` to check the installation.
2. Clone the repository and add the `functions` folder to the MATLAB path:
   ```matlab
   cd visual_tests_amblyopia
   addpath('functions')
   ```
3. Edit `functions/GetGlobalVariables.m` for your screen size (mm) and viewing
   distances (mm).

Each test script `cd`s to the repository folder and writes its results to
`data/`. Shared state between tests (participant ID, amblyopic eye,
thresholds) is kept in `data/Global_parameters/global_param.mat`. It is
updated by every test; answer `true` to "New patient?" to reset it.

## Running the battery

Run each test script from the MATLAB command window. A series of dialogs asks
for:
- **New patient?** Answer `true` for the first test of a new participant. This
  resets `global_param.mat` from `GetGlobalVariables.m`.
- **Retest?**
- **Start EyeLink?** Answer `false` to run without an eye tracker.
- Participant number, viewing distance, tested eye (`Left`/`Right`/`Both`) and
  amblyopic eye (`Left`/`Right`).

**Test order** (some tests use results from earlier ones):

| # | Script | Eyes | Uses |
|---|---|---|---|
| 1 | `Cutoff.m` | FE, AE, BE | — |
| 2 | `Contrast_Interleaved.m` | FE, AE, BE | cut-off of the same eye |
| 3 | `Interocular_Imbalance.m` | BE | — |
| 4 | `Dichoptic.m` | BE | AE cut-off, AE contrast threshold (as dialog default) |
| 5 | `Asteroid.m` | BE | — |
| 6 | `Snellen.m` | FE, AE, BE | — |
| 7 | `Snellen_crowded.m` | FE, AE, BE | — |

FE = fellow eye, AE = amblyopic eye, BE = both eyes. Test the fellow eye
before the amblyopic eye: participants find the task easier to learn with
their better eye. In the Contrast and Dichoptic dialogs, leave the cut-off as
`-` to use the value stored by `Cutoff.m`, or type a value.

**Keys:**
- *Fusion-cross alignment* (binocular runs, before each trial): the arrows
  move the half-cross one pixel per press, `Space` re-centres it, and `Esc`
  confirms the alignment and starts the trial.
- *Responses*: ←/→ tilt direction (Gabor tests), ↑/↓/←/→ orientation (tumbling
  E) or grating position (Dichoptic). The Asteroid test uses ↑, `k`, ↓, `m`
  for its four patches.
- `a` during a trial aborts the test. The trials so far are still saved.

**Testing without the lab hardware:** answer `false` to the EyeLink prompt,
and set `debug = 1` near the top of a test script to open a small window.
Stereo separation is only meaningful on an interleaved-line display.

## The tests

Each script starts with a header describing its stimuli and staircase. In summary:

### Cut-off frequency — `Cutoff.m`
Gabor patches (2 dva, 100 % contrast, σ = 0.17 dva) tilted ±45°. A 3-up-1-down
staircase on spatial frequency (1–24 cpd) finds the highest frequency at which
the tilt can still be reported. The first 5 trials at 2 cpd are practice. The
test ends after 8 reversals, and the threshold is the mean of the last 6.
Measured for FE, AE and BE, the cut-off sets the frequencies of the contrast
and dichoptic tests.

### Contrast sensitivity — `Contrast_Interleaved.m`
Six randomly interleaved 3-up-1-down contrast staircases at 1, 3/4, 1/2, 1/4,
1/8 and 1/16 of the cut-off frequency of the tested eye. Each staircase ends
after 8 reversals, and its threshold is the mean of its last 6 reversal
levels. A "reduced" four-frequency version can be selected at start-up.

### Interocular imbalance — `Interocular_Imbalance.m`
Binocular phase/orientation combination after
[Mao et al., 2020](https://doi.org/10.1167/iovs.61.8.7). Each eye sees a Gabor
tilted ±7.1° in opposite directions (200 ms), and the participant reports the
perceived tilt. Four interleaved 2-up-2-down staircases (0.5, 1, 2, 4 cpd)
adjust the fellow-eye contrast to find the balance point. For observers with
normal vision, set "normal observer" to `1` in the dialog: the AE contrast is
then varied instead.

### Dichoptic noise tolerance — `Dichoptic.m`
After [Liu & Zhang, 2019](https://doi.org/10.1167/iovs.18-26483). The AE sees
two gratings (40 % of the AE cut-off frequency, different contrasts), the FE
sees band-pass noise (10 dva), and the participant reports which grating has
the higher contrast. A 3-up-1-down staircase on noise contrast estimates the
maximum tolerable noise. 20 % of trials are attention checks with an arrow in
the FE. This test sets the starting noise of the VR training, and its result
is informative only: the VR setup differs from this one.

### Stereoacuity — `Asteroid.m`
Adapted from the ASTEROID stereotest
([McCaslin et al., 2020](https://doi.org/10.1167/tvst.9.9.29)), with code kindly
provided by Prof. Jenny Read. Four dynamic random-dot patches, one containing
a disparity-defined square (1–1000 arcsec), are shown in a 4-AFC Bayesian
staircase over 60 trials. Changes from the original: Display++ line-interleaved
stereo, dots drawn as ovals, patch and dot sizes rescaled to keep the same
dva, updated colour handling in `ChooseDotColors*.m`, and EyeLink integration.

### Tumbling E and crowded tumbling E — `Snellen.m`, `Snellen_crowded.m`
A letter E in one of four orientations, viewed from 250 cm. A 3-up-1-down
staircase on letter size (pixels) runs for up to 30 trials or 8 reversals. In
the crowded version, the central E is surrounded by four randomly oriented Es.

## Output files

Each run writes one Excel table to `data/`, named:

```
<ID>_<y_M_d_HH_mm>_<test>_<EYE>[_AMB]_<test>.xls
```

where `EYE` is `LEFT`, `RIGHT` or `BOTH`, and `_AMB` marks the amblyopic eye.
Each row is one trial. Columns common to all tests:

| Column | Meaning |
|---|---|
| `Task`, `Date_time` | Test name, trial timestamp |
| `Trial`, `Reversal` | Trial counter and reversal counter of the staircase |
| `AMB_eye`, `Eye_tested` | Amblyopic eye, tested eye |
| `Position`, `Key`, `Success`, `RT` | Stimulus position, key pressed, correct/incorrect, reaction time (s) |

Test-specific columns include `Contrast`, `Frequency_cpp`/`Frequency_dva`,
`Staircase` (interleaved tests), `Contrast_FE`/`Contrast_AE`, `Noise` and
`opto_size_pixel(s)`. At the end of each staircase, one extra row with
`AMB_eye = MEAN`, `Eye_tested = REVERSAL` holds the threshold.
`Key = Complete_reversals` means at least 6 reversals went into it.
[`Variables_description.mlx`](Variables_description.mlx) describes the main
script variables.

Other outputs: EyeLink `.edf` files (repository root, when tracking is on),
and the Asteroid per-trial `.mat` file (`data/`).

**Never commit participant data.** `.gitignore` excludes `data/*.xls`,
`data/*.mat`, `data/temp/` and `*.edf` in the repository root.

### Example data
`data/Example_data/` contains output files from three pilot sessions
(`Good`, `Medium`, `Bad`: quality of the run, with test/retest repeats). They
were recorded with v1.0.0, so their contrast and interocular-imbalance `MEAN`
rows are affected by the bug described in [CHANGELOG.md](CHANGELOG.md). Older
pilot files use slightly different names (`TEST`/`RETEST`/`RERETEST`).

## Repository layout

```
├── Cutoff.m, Contrast_Interleaved.m, Interocular_Imbalance.m,
│   Dichoptic.m, Asteroid.m, Snellen.m, Snellen_crowded.m   # test scripts
├── functions/            # shared helpers (screen, staircase, EyeLink, drawing, I/O)
│   └── targets/          # fixation-target images
├── data/
│   ├── Example_data/     # pilot outputs (v1.0.0)
│   ├── Global_parameters/# session state shared between tests
│   └── icon/
├── Variables_description.mlx
├── CITATION.cff, CHANGELOG.md, LICENSE, LICENSE-DATA
```

## Third-party code

These files are **not** covered by this repository's MIT licence and keep
their authors' terms:

| File(s) | Origin | Terms |
|---|---|---|
| `functions/staircase.m` | Alex S. Baldwin, [MatlabStaircase](https://github.com/alexsbaldwin/MatlabStaircase) ([doi:10.5281/zenodo.3266141](https://doi.org/10.5281/zenodo.3266141)) | AGPL-3.0, see [`functions/LICENSE-staircase`](functions/LICENSE-staircase) |
| `Asteroid.m` (adapted), `functions/LIKELOGISTIC4AFC.m`, `functions/ChooseDotColors*.m`, `functions/scramble.m` | ASTEROID stereotest code from Prof. Jenny Read's lab (Newcastle University); likelihood function by Dr Ignacio Serrano-Pedraza | Provided by the authors for this study; no licence stated. Contact them before reuse |
| `functions/eyelink_*.m` | Based on SR Research / Psychtoolbox EyeLink demo code | Original terms |

Some tests are also inspired by Peter Scarfe's
[Psychtoolbox tutorials](https://peterscarfe.com/ptbtutorials.html).

## Citation

If you use this code, please cite it, together with the article above. The
metadata is in [`CITATION.cff`](CITATION.cff), and GitHub's **"Cite this
repository"** button generates APA/BibTeX from it. The Zenodo DOI will be added
on release.

## License

- **Code** (`*.m`): [MIT](LICENSE), except the third-party files listed above.
- **Documentation, example data and images** (`README.md`, `data/`,
  `functions/targets/`): [CC BY 4.0](LICENSE-DATA).
