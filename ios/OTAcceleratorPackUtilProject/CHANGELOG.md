# CHANGELOG

The changelog for `acc-pack-common` iOS.

--------------------------------------

1.2.2
-----

### Enhancements

- Add `subscribeToStreamWithStreamId:` for switching to another stream.


1.2.1
-----

### Enhancements

- Add `subscriberVideoContentMode` for displaying a fit or fill video.
- Add `subscribeToStreamWithName:` for switching to another stream.
- Make sure that the publisher has a name

### Fixes

- Perform un-subscription and do subscription if there are any new streams being created. This will ensure that the session does not hold extra unused subscribers.

1.2.0
-----

### Enhancements

- Update OpenTok iOS SDK dependency to 2.9.1 (https://tokbox.com/developer/sdks/ios/release-notes.html)

1.1.10
------

### Enhancements

- Enhance documentation.
- Remove connection related methods as it's unnecessary.

1.1.9
-----

### Fixes

- Fixed `isSubscribeToAudio` and `isSubscribeToVideo` have a wrong value as `subscriber.stream` is not taken into account.

1.1.8
-----

### Enhancements

- Add documentation

### Breaking changes

- Remove `setOpenTokApiKey:sessionId:token:` from OTOneToOneCommunicator. Instead, force to use the one from `OTAcceleratorSession` to avoid redundancy.

1.1.7
-----

### Enhancements

- Add reconnection callback.
- Update documentation in general.
- Update setting for XCode8.

### Breaking changes

- Update event signals to be more precise especially to subscriber disable events.

1.1.6
-----

### Enhancements

- Update to use OpenTok SDK 2.9.0(https://tokbox.com/developer/sdks/ios/release-notes.html).

### Fixes

- Fixed incorrect condition check on selector `session:archiveStartedWithId:name:` and `session:archiveStoppedWithId:`.

1.1.5
-----

### Enhancements

- Now you can add a name to your publisher by setting `publisherName` property.
- Now `connect` and `disconnect` will return an immediate `NSError` object to indicate pre-connection errors.
- The block handler of `connectWithHandler:` is required now.

1.1.4
-----

### This version is deprecated as it has a severe bug.

1.1.3
-----

### Fixes

- Fixed accelerator packs, who join later, can't get `streamCreated:` signal.

1.1.2
-----

### Enhancements

- Add convenient getters for `subscribeToAudio`, `subscribeToVideo`, `publishAudio` and `publishVideo`.
- Update to use 2.0.0 OTKAnalytics as the shared instance nature gets removed.

1.1.1
-----

### Fixes

- Fixed the acc-pack dose not have a way to refer to a recreated session when `OpenTok` credentials are resetted.

1.1.0
-----

### Breaking changes

- Change class initialization method name from `communicator` to `sharedInstance` for successfully bridging to Swift API.

### Enhancements

- Remove `token` property from `OTAcceleratorSession.h` as it's available from the super class.
- Add an ability to signal `sessionDidDisconnect:` to de-registered accelerator packs.


### Fixes

- Reset `OpenTok` credentials now will force session to be recreated.

1.0.0
-----

Official release

All previous versions
---------------------

Unfortunately, release notes are not available for earlier versions of the library.
