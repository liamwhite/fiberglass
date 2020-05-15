FROM alpine:latest

# cache bust git repos
ADD https://api.github.com/repos/derpibooru/cli_intensities/git/refs/heads/master /tmp/cli_intensities_version.json
ADD https://api.github.com/repos/derpibooru/FFmpeg/git/refs/heads/master /tmp/FFmpeg_version.json
ADD https://api.github.com/repos/derpibooru/mediatools/git/refs/heads/master /tmp/mediatools_version.json

RUN apk update \
    && apk add imagemagick file-dev libpng-dev libjpeg-turbo-utils optipng gifsicle librsvg build-base git \
    x264-dev x265-dev libvpx-dev lame-dev opus-dev libvorbis-dev yasm ruby \
    && cd /opt \
    && git clone https://github.com/derpibooru/cli_intensities \
    && git clone https://github.com/derpibooru/FFmpeg \
    && git clone https://github.com/derpibooru/mediatools

# build FFmpeg
RUN cd /opt/FFmpeg \
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
    && make install

# build cli_intensities
RUN cd /opt/cli_intensities \
    && make install

# build mediatools
RUN cd /opt/mediatools \
    && make install

# Add input parser script
COPY input.rb /opt/input.rb
