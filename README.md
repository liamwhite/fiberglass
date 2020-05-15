# fiberglass

Docker-insulated image processing libraries for [Philomena](https://github.com/derpibooru/philomena)

## Rationale

Keeping up to date with bugfixes and improvements in image processing programs can be difficult if the operating system you run has not yet published a new version. Fiberglass makes it easy to install these programs on a production server (only Docker or Podman is required).

Fiberglass also helps to minimize the available attack surface to RCE takeover, DoS, and RFIs in the event of a full program compromise:

- No host paths are mounted in the volume beyond the Docker defaults
- CPU core access is restricted to 2 per spawned container
- Memory access is restricted to 1GB per spawned container
- No network interface is created for spawned containers
- Output is buffered, not streamed

## Provided programs

- convert
- identify
- jpegtran
- gifsicle
- optipng
- ffmpeg
- ffprobe
- file
- image-intensities
- mediastat
- safe-rsvg-convert
