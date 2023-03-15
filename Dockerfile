FROM alpine:latest

ADD https://api.github.com/repos/philomena-dev/FFmpeg/git/refs/heads/release/5.1 /tmp/FFmpeg_version.json
ADD https://api.github.com/repos/philomena-dev/cli_intensities/git/refs/heads/master /tmp/cli_intensities_version.json
ADD https://api.github.com/repos/philomena-dev/mediatools/git/refs/heads/master /tmp/mediatools_version.json

RUN apk update \
    && apk add imagemagick file file-dev libpng-dev libjpeg-turbo-utils optipng gifsicle librsvg build-base git \
       x264-dev x265-dev libvpx-dev lame-dev opus-dev libvorbis-dev yasm ruby ffmpeg \
    && git clone --depth 1 https://github.com/philomena-dev/FFmpeg /opt/FFmpeg \
    && cd /opt/FFmpeg \
    && ./configure \
      --prefix=/usr \
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
    && make -j$(nproc) install \
    && git clone https://github.com/philomena-dev/cli_intensities /opt/cli_intensities \
    && cd /opt/cli_intensities \
    && git checkout 401639cdd9a46a89a9f8491c69258bc84d4c0c4b \
    && make -j$(nproc) install \
    && git clone 1 https://github.com/philomena-dev/mediatools /opt/mediatools \
    && ln -s /usr/lib/librsvg-2.so.2 /usr/lib/librsvg-2.so \
    && cd /opt/mediatools \
    && git checkout 670d3bbcf2ce33e077ec247daa740f4c6c200539 \
    && make -j$(nproc) install \
    && rm -rf /opt/cli_intensities \
    && rm -rf /opt/mediatools \
    && rm -rf /opt/FFmpeg \
    && apk del file-dev build-base git x264-dev x265-dev libvpx-dev lame-dev opus-dev libvorbis-dev

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
