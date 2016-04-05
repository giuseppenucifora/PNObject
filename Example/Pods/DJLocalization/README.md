# DJLocalization

[![Version](https://img.shields.io/cocoapods/v/DJLocalization.svg?style=flat)](http://cocoadocs.org/docsets/DJLocalization)
[![License](https://img.shields.io/cocoapods/l/DJLocalization.svg?style=flat)](http://cocoadocs.org/docsets/DJLocalization)
[![Platform](https://img.shields.io/cocoapods/p/DJLocalization.svg?style=flat)](http://cocoadocs.org/docsets/DJLocalization)

Localization system that allows language switching at runtime. Supports both code strings (NSLocalizedString) and storyboards (base internationalization).

## Demo

To try the example project, just run the following command:

    pod try DJLocalization

## Requirements

Requires iOS 6 or higher.

## Installation

### From CocoaPods

DJLocalization is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

    pod "DJLocalization"

### Manually

_**Important note if your project doesn't use ARC**: you must add the `-fobjc-arc` compiler flag to all 'DJLocalization' files in Target Settings > Build Phases > Compile Sources._

* Drag the `DJLocalization/DJlocalization` folder into your project.

## Usage

### Importing headers

Then simply add the following import to your prefix header, or any file where you use the NSLocalizedString macro (or variants).

    #import <DJLocalization/DJLocalization.h>

#####*Important:*
You must import the header wherever you use the NSLocalizedString macro, as this header replaces the default NSLocalizedString macro with a custom one. If you don't, runtime switching of languages won't work.

### Switching languages

At runtime, you can switch the language at any time by setting the language property:

    [DJLocalizationSystem shared].language = @"en";

Be careful to only use language codes (en, nl, fr, etc...) for localizations that exist in your project.

#####*Important:*
Views are translated on load. This means that if you switch the language at some point, only subsequently loaded views will have the correct language strings. Ideally, when you switch languages, you should pop your navigation controller to it's root view controller.

## Credits

DJLocalization is brought to you by [David Jennes](https://twitter.com/davidjennes). The code is inspired by [Rolandas Razma's](https://twitter.com/rolandas_razma) work with [RRBaseInternationalization](https://github.com/RolandasRazma/RRBaseInternationalization) (especially the way to load strings for storyboard/xib views).

Props to Rolandas Razma

## License

DJLocalization is available under the MIT license. See the LICENSE file for more info.
