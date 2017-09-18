
# SciTuner 2.0

[![Build Status][travis-image]][travis-url]
[![License: MIT][license-image]][license-url]
[![Platform][platform-image]][platform-url]
[![Coverage Status](https://coveralls.io/repos/github/kreshikhin/scituner/badge.svg?branch=master)](https://coveralls.io/github/kreshikhin/scituner?branch=master)

SciTuner is guitar tuner with real-time signal visualization.
The application uses digital signal processing algorithm for accurate frequency estimation and wave visualization.
SciTuner presents many useful features:

- Works with guitars, ukuleles, banjos, violins and some other instruments
- Allows to see a wave form of a sound in real time
- Suppresses false harmonics in filter mode (on by default)
- Allows to tune on 5th, 7th and 12th frets for fine tune
- Makes frequency estimation with precision ±0,1Hz
- Allows to freeze the wave form and values by button "pause"
- Works in noisy conditions

## Available On Appstore

The previous version of SciTuner 1.1 is available on AppStore. SciTuner 2.0 is coming soon.

[![FREE Download from Appstore][appstore-image]](https://itunes.apple.com/us/app/scituner/id952300084?mt=8)

## Screenshots

![Screenshots][screenshots-image]

## How it works

The main controller is TunerViewController. This controller works with three models object `Tuner`, `Processing` and `Microphone`.
`Processing` receives sound data from `Microphone` through controller and calculates power spectrum by `FFT`.
Spectrum is used for estimation greatest peak position in frequency domain. Because a guitar sound may have many harmonics, it's necessary also detect harmonic order. Artificial Neural Network is used for this purposes by activating an input layer with spectrum powers taken on special frequencies (1/4, 1/3, 1/2, 2/3, 3/4, 1, 3/2, 2, 3, 4) relative to greatest peak.


![Screenshots][uml-image]

## License

  [MIT](LICENSE)

[travis-image]: https://img.shields.io/travis/kreshikhin/scituner/master.svg
[travis-url]: https://travis-ci.org/kreshikhin/scituner

[license-image]: https://img.shields.io/badge/License-MIT-yellow.svg
[license-url]: https://opensource.org/licenses/MIT

[platform-image]: https://img.shields.io/badge/platform-ios-lightgrey.svg?style=flat
[platform-url]: http://github.com/kreshikhin/scituner

[appstore-image]: https://github.com/kreshikhin/scituner/blob/master/Docs/appstore.png
[screenshots-image]: https://github.com/kreshikhin/scituner/blob/master/Docs/screenshots_small.png
[uml-image]: https://github.com/kreshikhin/scituner/blob/master/Docs/uml.png
