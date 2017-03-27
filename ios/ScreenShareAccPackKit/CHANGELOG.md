# CHANGELOG

The changelog for `screensharing-annotation-acc-pack` iOS.

--------------------------------------

### MIGRATION

We will rename and migrate `screen-share-kit` iOS to `OTAcceleratorCore`[here](https://github.com/opentok/accelerator-core-ios)

2.0.5
-----

### WE ARE MIGRATING THIS PODS TO ANOTHER FOR *GOOD*

2.0.4
-----

### Enhancements

- Add `isPublishOnly` to allow publishing only.

2.0.3
-----

### Breaking changes

- Adapt the new `OTAcceleratorPackUtil`.

2.0.2
-----

### Fixes

- Correct a wrong signaling: `OTPublisherCreated` -> `OTSubscriberReady`.

2.0.1
-----

### Fixes

- Put back the `isScreenSharing` boolean value.

2.0.0
-----

### Enhancements

- Remove shared instance so developers can control it.
- Add OTMultiPartyScreenSharer for mutliparty screen sharing logic.

1.1.6
-----

### Enhancements

- Introduce `isRemoteAudioAvailable` and `isRemoteVideoAvailable` to have more audio and video control.

1.1.5
-----

### Enhancements

- Nil out `publisherView` and `subscriberView` in `disconnect` method for avoiding potential side effect.

1.1.4
-----

### Enhancements

- Add `subscriberVideoContentMode` for displaying a fit or fill video.
- Add `subscribeToStreamWithName:` for switching to another stream.
- Add `subscribeToStreamWithStreamId:` for switching to another stream.
- Make sure that the publisher has a name.
- Nil out `publisher` and `subscriber` in `disconnect` method for avoiding potential side effect.

### Fixes

- Perform un-subscription and do subscription if there are any new streams being created. This will ensure that the session does not hold extra unused subscribers.

1.1.3
-----

### Enhancements

- Enhance documentation

1.1.2
-----

### Breaking changes

- Remove `setOpenTokApiKey:sessionId:token:` from OTOneToOneCommunicator. Instead, force to use the one from `OTAcceleratorSession` to avoid redundancy.

### Enhancements

- Add reconnection callback.
- Enhance documentation.


### Fixes

- Fixed `isSubscribeToAudio` and `isSubscribeToVideo` have a wrong value as `subscriber.stream` is not taken into account.

1.1.1
-----

### Fixes

- Fix a bug that `session` can not be updated when multiple acc-packs are running together. 

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
