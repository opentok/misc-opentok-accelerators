# CHANGELOG

The changelog for `screensharing-annotation-acc-pack` iOS.

--------------------------------------

2.0.0
-----

### Enhancements

- Migrate our dependency 

1.2.0
-----

### Enhancements

- Re design annotation toolbar to be more natural.
- Re order annotation toolbar under landscape mode.
- An anntoator can to attach to a specified session rather than the shared one.

### Fixes

- Fix a bug that results in unregistered annotator receiving post notification.
- Fix a bug to make sure a target stream is always there.

1.1.12
-----

### Enhancements

- Provide notifications for annotation toolbar actions.

1.1.11
-----

### DEPRECATED 

1.1.10
-----

### Fixes

- Fix a bug that color picker bar does not dismiss properly.
- Fix a bug that drawing a circle results in octagons.

1.1.9
-----

### Fixes

- Fix a bug that it's unable to remove text annotation.

1.1.8
-----

### DEPRECATED 

1.1.7
-----

### Enhancements

- Add clear action.
- Add erase and clear action for remote annotation.
- Enhance text annotation for local and remote.

### Fixes

- Fix minor bugs

1.1.6
-----

### DEPRECATED 


1.1.5
-----

### Breaking changes

- Remove `canvasSize` property from all connection methods for giving back flexibility to change it even after connecting to a session.

### Fixes

- Include `color` property for sending remote annotation data.
- Make sure `color` property won't be affected by exchanging annotation data.


1.1.4
-----

### DEPRECATED

1.1.3
-----

### DEPRECATED

1.1.2
-----

### Breaking changes

- Remove single direction remote annotation(either send or receive) to enable bi-directional remote annotation.

1.1.1
-----

### Enhancements

- Add platform info for remote annotation.

### Breaking changes

- Change meta data for signaling tpye string

1.1.0
-----

### Enhancements

- Enhance documentation.
- Enhance remote annotation feature.

1.0.0
-----

Official release

All previous versions
---------------------

Unfortunately, release notes are not available for earlier versions of the library.
