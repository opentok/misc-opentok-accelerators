OpenTok iOS SDK release notes
=============================

New features and changes
------------------------

Version 2.7.1

* We have fixed the following issues:

  * If an app using OpenTok is running in the background when
    a phone call is received and the call duration is more than 10 seconds,
    the app sometimes crashes when the call finishes.

  * Distorted "robotic" audio when switching from the loudspeaker
    to a Bluetooth headset.

  * Calling
    `[OTPublisher initWithDelegate:name:cameraResolution:
    cameraFrameRate:]` can take long (10 secs) to complete.

  * Apps using OpenTok sometimes crash when the user switches
    the network connection (for example, from Wi-Fi to cellular).

* A new beta bitcode version of the SDK, which also fixes these issues, is
  available at <https://tokbox.com/downloads/opentok-ios-sdk-2.7.2-beta.1>.

Version 2.7.0

* Setting the frame rate and resolution for a published stream using the default
  camera video capturer. A new
  `OTPublisher initWithDelegate:name:cameraResolution:cameraFrameRate:]` method
  includes parameters for setting the frame rate and resolution of the stream.

* New methods for getting audio and video statistics for a stream. You can now
  set a delegate object to monitor the following statistics for a subscriber's
  stream:

  * Total audio and video packets lost
  * Total audio and video packets received
  * Total audio and video bytes received

  See the documentation for the `OTSubscriberKit.networkStatsDelegate` property.

* New beta automatic reconnection feature. When the client disconnects
  from the session due to a drop in network connectivity, it attempts
  to reconnect. And if a subscribed stream drops out, the client attempts to
  reconnect to the stream. This is a beta feature. To participate
  in the beta program, see https://tokbox.com/platform/beta-programs.

  The new `[OTSessionDelegate sessionDidBeginReconnecting]` and
  `[OTSessionDelegate sessionDidConnect]` messages are sent when the client is
  attempting to reconnect and when it succeeds in reconnecting. Any existing
  publishers and subscribers are automatically reconnected when the client
  reconnects.

  The new `[OTSubscriberKitDelegate subscriberDidDisconnectFromStream:]` and
  `[OTSubscriberKitDelgate subscriberDidReconnectToStream:]` messages are sent
  when the subscriber's stream disconnects and reconnects.

  If the client cannot reconnect to the session, the
  `[OTSessionDelegate sessionDidDisconnect:]` message is sent. You can choose to
  have any signals initiated by the the local client while disconnected be sent
  when it reconnects; set the `retryAfterReconnect` parameter to `NO` when
  calling the new
  `[OTSession signalWithType:string:connection:retryAfterReconnect:error:]`
  method. (All signals sent by other clients while your client was disconnected
  are received upon reconnecting.)

* New beta scalable video feature. Using the scalable video feature, a client
  can publish a multi-quality video stream, composed of multiple video
  resolutions and frame rates, allowing simultaneous subscribing endpoints to
  consume different video resolutions and frame rates. This beta feature is
  available for publishers using the OpenTok Android and the OpenTok iOS SDK,
  as well as for publishers using OpenTok.js in Chrome. To participate in the
  beta program, see https://tokbox.com/platform/beta-programs.

  For streams that use the scaleable video feature, you can set the preferred
  video resolution and frame rate used by a subscriber. Lowering the preferred
  video resolution and frame rate lowers video quality, but it also reduces
  network and CPU usage. See the documentation for the
  `OTSubscriberKit.preferredFrameRate` and
  `OTSubscriberKit.prefereredResolution` properties.

* A beta bitcode version of the OpenTok iOS SDK is available at
  https://tokbox.com/downloads/opentok-ios-sdk-2.7.1-beta.1.
  Please send comments or report issues to
  [ios-bitcode-beta@tokbox.com](mailto:ios-bitcode-beta@tokbox.com).

* Fixed an issue preventing connections from working while the device is locked
  and app Data Protection enabled.

* Fixed an issue that was causing apps to crash when disconnecting from an
  OpenTok session.

Version 2.6.1

* Fixed iOS 9 crash in the video renderer.

* Fixed audio distortion issue on the iPhone 6s and 6s+ running in iOS 9.

* Fixed the publisher video in the XCode iOS 9 Simulator.

Version 2.6.0

* Added `OTPublisher.viewScaleBehavior` and `OTSubscriber.viewScaleBehavior`
  properties to allow easily switching between common scaling methods without
  using a custom video renderer.

* Added the `[OTSession reportIssue:]` method. You can call this method
  when your app experiences an issue. The method sets an issue ID,
  which you can use with the
  <a href="https://tokbox.com/developer/tools/Inspector">Inspector</a>
  or when discussing an issue with the TokBox support team.

* Increased the default video resolution and frame rate for OTPublisher.

* Improved audio device handling.

* H264-related bug fixes and improvements (in relayed one-to-one sessions
  between iOS devices).

* Fixed the the following issues:

  * Data was sent over WWAN when WiFi was available.

  * Audio was going to the receiver (instead of the speaker) after a phone call
    ended on the device.

  * The initial `videoDimensions` property of an OTStream was incorrect.

  * When unpublishing a stream, audio for subscribers was dropped.

Version 2.5.0

* Added hardware-accelerated H.264 support for relayed one-to-one sessions
  between iOS devices.

* Added proxy support.

* Added the implementation of the
 `[OTPublisher initWithDelegate: name: audioTrack: videoTrack:]`
  method (inherited from OTPublisherKit).

* Removed clang autolink feature from compilation.

* Fixed broken video mirroring behavior in the publisher view.

* Note that the samples directory is no longer included in the SDK bundle.
  The sample code is now available at the open-source [opentok-ios-sdk-samples
  repo](https://github.com/opentok/opentok-ios-sdk-samples)
  on GitHub. This allows us to keep it up to date and provide developers with
  latest version of the sample code. Feel free to clone the repo or download
  the source code to see the best-practice examples of OpenTok usage.

* All calls to AudioUnitGetProperty were removed from the remote I/O thread (in
  both the SDK and in the external audio device sample app).

Version 2.4.1

* Previous versions of the SDK would use the mobile data connection to transmit
and receive media streams when a Wi-Fi network was available. We have fixed this
issue.

* This version adds support for interactivity with clients using Firefox 38
in relayed OpenTok sessions (sessions that do not use [the OpenTok Media
Router](http://tokbox.com/opentok/tutorials/create-session/#media-mode )).

* Version 2.4.1 and 2.4.0 require different libraries that were required by
previous versions of the OpenTok iOS SDK. When moving a project from using
version 2.3.1, you need to include the VideoToolbox.framework, and you need to
remove libstdc++. For complete details, see "Using the SDK" in the README.md
file of the SDK.

* Fixed an issue in which an app could deadlock when starting or stopping audio
  or receiving an incoming call.

* The OpenTok iOS SDK is now available as the Pod "OpenTok", for use with
  [CocoaPods](http://cocoapods.org/).

Version 2.4.0

* This version adds support for the arm64 architecture.

* This version adds support for screen sharing. When publishing a screen-sharing
  stream, set the `videoType` property of the OTPublisherKit object and
  pass in `OTPublisherKitVideoTypeScreen` (defined in the
  OTPublisherKitVideoType enum). This optimizes the video encoding for screen
  sharing. It is recommended to use a low frame rate (5 frames per second or
  lower) with screen sharing. When using the screen video type in
  a session that uses the OpenTok Media Server, you should set the
  `[OTPublisherKit audioFallbackEnabled]` property to `NO` to disable
  the audio-only fallback feature, so that the video does not drop out
  in subscribers. See [the OpenTok Media
  Router](http://tokbox.com/opentok/tutorials/create-session/#media-mode ).

  When a stream is created in a session, you can determine the video type
  of the stream (screen or camera) by checking the `videoType` property of
  the OTStream object. The type of stream is defined by constants in the
  OTStreamVideoType enum: `OTStreamVideoTypeScreen` and
  `OTStreamVideoTypeCamera`.

  To publish a screen-sharing stream, you need to implement a custom video
  capturer for the OTPublisherKit object. For sample code that publishes a
  screen-sharing stream, see the "Screen-Sharing" app in the samples directory.

* You can disable the audio-only fallback feature for a published stream by
  setting the `audioFallbackEnabled` property of the OTPublisher object to
  `NO`. The audio-fallback feature is available in sessions that use the
  [OpenTok Media 
  Router](http://tokbox.com/opentok/tutorials/create-session/#media-mode). With
  the audio-fallback feature enabled (the default), when the OpenTok
  Media Router determines that a stream's quality has degraded significantly for
  a specific subscriber, it disables the video in that subscriber in order to 
  preserve audio quality. For streams that use a have the video source set to
  camera, the audio-fallback feature is enabled by default. For screen-sharing 
  streams, the audio-fallback feature is disabled by default.

Version 2.3.1

* This version fixes a bug that cause apps to crash when running in iOS 6.

Version 2.3.0

* This version adds support for armv7s and i386 architectures (in addition to
  armv7). You can now target the iOS Simulator. However, the Xcode iOS Simulator
  does not provide access to the camera. When testing in the iOS Simulator, an
  OTPublisher object uses a demo video instead of the camera.

* This version includes a new custom audio driver API. This lets you use
  custom audio streams and define the audio device used to capture and render
  audio data. The following new classes and protocols support the custom audio
  driver API:

  * OTAudioDeviceManager -- Use this class to set the app to specify a custom
  audio device for use in the app.

  * OTAudioDevice -- Defines an audio device for use in a session.

  * OTAudioBus -- The audio bus marshals audio data between the network and
  the audio device.

  * OTAudioFormat -- Defines the format of the audio.

* There are new delegate protocols and messages for getting the audio level of a
  publisher or subscriber. See the `OTPublisherKit.audioLevelDelegate` property
  and the `OTPublisherKitAudioLevelDelegate` protocol, as well as the
  `OTSubscriberKit.audioLevelDelegate` property and the
  `OTSubscriberKitAudioLevelDelegate` protocol.
  
* The new `[OTSubscriberKitDelegate subscriberVideoEnabled:reason:]` message is sent when
  a subscriber's video stream starts (when there previously was no video) or resumes
  (after video was disabled).

* The `reason` parameter has been added to the
  `[OTSubscriberKitDelegate subscriberVideoDisabled:reason:]` message. This parameter
  describes the reason why the subscriber video is being disabled.
  In the previous version, this message was only sent when the video was
  disabled due to changes in the stream quality (in a session that uses the
  OpenTok Media Router). In version 2.3.0, the message is also sent if the
  publisher stops sending a video stream or the subscriber stops subscribing to
  it (and the `reason` parameter value will be set accordingly).

* The new `[OTSubscriberKitDelegate subscriberVideoDisabledWarning:]` message is
  sent when the OpenTok Media Router determines that the stream quality has
  degraded and the video will be disabled if the quality degrades more. The new
  `[OTSubscriberKitDelegate subscriberVideoDisabledWarningLifted:]` message
  is sent when the stream quality improves. This feature is only available in
  sessions that use the OpenTok Media Router (sessions with the
  [media mode](http://tokbox.com/opentok/tutorials/create-session/#media-mode)
  set to routed), not in sessions with the media mode set to relayed.

* This version adds support for armv7s and i386 architectures, in addition to
  armv7. (The SDK does not support arm64.) You can now target the iOS Simulator.
  However, the Xcode iOS Simulator does not provide access to the camera. When
  testing in the iOS Simulator, an OTPublisher object uses a demo video instead
  of the camera.

* This version adds support for iOS 8.
  
Version 2.2.1

* Updated to use version 1.0.1h of OpenSSL.
* Created backwards compatibility with OpenTok iOS SDK 2.1.7 (subscriber
orientation).

Version 2.2.0

* For a list of new features and changes, see 
[Migrating to version 2.2 of the OpenTok SDK]
(http://tokbox.com/opentok/libraries/client/ios/migrating-to-version-2.2.html).

Known issues
------------

This version of the OpenTok iOS SDK does not support displaying videos using
Apple AirPlay.

H.264 support is disabled in version 2.7.0. We are working on a fix to
re-enable it.

In a session with the [media
mode](http://tokbox.com/opentok/tutorials/create-session/#media-mode)
set to relayed, only one client can subscribe to a stream published by an
ioS device.

The Xcode iOS Simulator does not provide access to the camera. When testing in
the iOS Simulator, an OTPublisher object uses a demo video instead of the
camera.

Subscribing to screen-sharing streams (see "New features and changes - Version
2.4") is not supported in the OpenTok iOS SDK version 2.3 and older. You must
upgrade to version 2.4.

Do not use the `-all_load` linker flag. Instead, use the `-force_load` linker
flag to load specific libraries that require it.

The OpenTok iOS SDK links to the libc++ standard library. If another library
that links to the libc++ standard library was compiled in a version of Xcode
older than 6.0.0, it may result in segfaults at run time when using it with the
OpenTok iOS SDK. Known incompatible libraries include, but are not limited to,
Firebase (versions earlier than 2.1.2 -- see
https://code.google.com/p/webrtc/issues/detail?id=3992) and Google Maps
(versions earlier than 1.9.0). To fix this issue, download a version of the
other library that was compiled using Xcode 6.0.0 or later.

Video streaming is prevented on networks that have firewalls that use
authenticated proxies. This is due to a core issue with the current underlying
WebRTC implementation. (See [this Chromium bug
report](https://code.google.com/p/chromium/issues/detail?id=439560).)
