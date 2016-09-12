# CHANGELOG

The changelog for `screensharing-annotation-acc-pack` iOS.

--------------------------------------

1.1.0
-----

### Migrate to a new repo to separate the sample app and the accelerator pack.

1.0.5
-----

### Breaking changes

- renaming all OpenTok related stuff to have `OT` suffix.

### Enhancements

- Expose `subscriberVideoContentMode` property to have control of the video content mode.
- Expose `subscriberVideoDimension` property to read the actual video dimension.

1.0.4
-----

### Enhancements

- Now `connect` and `disconnect` will return an immediate `NSError` object to indicate pre-connection errors.

### Fixes

- Fix a bug that `isScreenSharing` does not reset to `NO` when it deregisters.

1.0.3
-----

### This version is deprecated as it has a severe bug.

1.0.2
-----

### Breaking changes

- Change class initialization method name from `communicator` to `sharedInstance` for successfully bridging to Swift API.

### Enhancements

- Update to use 2.0.0 OTKAnalytics as the shared instance nature gets removed.

1.0.1
-----

### Enhancements

- Update the core code of `OTScreenCapture` to fix a bug from https://bugs.chromium.org/p/webrtc/issues/detail?id=4643#c7.

### Fixes

- Fixed a bug that custom getters for `subscribeToAudio`, `subscribeToVideo`, `publishAudio` and `publishVideo` result in unchangeability.

1.0.0
-----

Official release

All previous versions
---------------------

Unfortunately, release notes are not available for earlier versions of the library.
