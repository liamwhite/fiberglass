FROM alpine:latest

RUN apk update \
    && apk add imagemagick file-dev libpng-dev libjpeg-turbo-utils optipng gifsicle librsvg build-base git \
    x264-dev x265-dev libvpx-dev lame-dev opus-dev libvorbis-dev yasm ruby

# build FFmpeg
ADD https://api.github.com/repos/derpibooru/FFmpeg/git/refs/heads/master /tmp/FFmpeg_version.json
RUN git clone https://github.com/derpibooru/FFmpeg /opt/FFmpeg \
    && cd /opt/FFmpeg \
    && ./configure \
      --prefix=/usr \
      --enable-avresample \
      --enable-avfilter \
      --enable-gpl \
      --enable-libmp3lame \
      --enable-libvorbis \
      --enable-libvpx \
      --enable-libx264 \
      --enable-libx265 \
      --enable-postproc \
      --enable-pic \
      --enable-pthreads \
      --enable-shared \
      --disable-stripping \
      --disable-static \
      --disable-librtmp \
      --enable-libopus \
    && make -j4 install

# build cli_intensities
ADD https://api.github.com/repos/derpibooru/cli_intensities/git/refs/heads/master /tmp/cli_intensities_version.json
RUN git clone https://github.com/derpibooru/cli_intensities /opt/cli_intensities \
    && cd /opt/cli_intensities \
    && make install

# build mediatools
ADD https://api.github.com/repos/derpibooru/mediatools/git/refs/heads/master /tmp/mediatools_version.json
RUN git clone https://github.com/derpibooru/mediatools /opt/mediatools \
    && cd /opt/mediatools \
    && make install

# Set up unprivileged user account
RUN addgroup -S fiberglass \
    && adduser -S -G fiberglass fiberglass
USER fiberglass

# Add safe-rsvg-convert
COPY safe-rsvg-convert /usr/local/bin/safe-rsvg-convert

# Add input parser script
COPY input.rb /opt/input.rb

# Sleep forever (to allow container to continue to run)
CMD ["sleep", "infinity"]
