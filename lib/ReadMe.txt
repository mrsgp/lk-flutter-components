SUBMODULE added:
> git submodule add https://github.com/mrsgp/lk-flutter-components.git lk-flutter-components

IF git does not download code, run below
> git submodule update --init --recursive

The source code is cloned from https://github.com/mrsgp/lk-flutter-components.git that was forked from https://github.com/livekit/components-flutter.git

mdc_version - folder has modified source codes from original fetch (src)
This is so that we can get latest updates from livekit but not affect our changes.

IMPORTANT: DO NOT UPDATE ANY CODES OTHER THAN IN **MDC_VERSION** folder.
