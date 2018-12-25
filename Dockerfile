FROM debian:stretch-slim AS build-env

# Update packages and install build dependencies
RUN apt-get update && apt-get install --no-install-recommends -y \
  git ca-certificates build-essential zlib1g zlib1g-dev unzip python

# build woff2
RUN git clone --recursive https://github.com/google/woff2.git /tmp/woff2 \
  && cd /tmp/woff2 \
  && make clean all && mv woff2_compress /usr/local/bin/woff2_compress \
  && mv woff2_decompress /usr/local/bin/woff2_decompress \
  && rm -rf /tmp/woff2

# build sfnt2woff
RUN git clone https://github.com/bramstein/sfnt2woff-zopfli.git /tmp/sfnt2woff-zopfli \
  && cd /tmp/sfnt2woff-zopfli \
  && make && mv sfnt2woff-zopfli /usr/local/bin/sfnt2woff \
  && rm -rf /tmp/sfnt2woff

FROM debian:stretch-slim
# Update packages and install ruby and dependencies
RUN apt-get update && apt-get install --no-install-recommends -y \
  ruby2.3 ruby2.3-dev fontforge build-essential

COPY --from=build-env /usr/local/bin /usr/local/bin

# Install latest fontcustom
RUN gem install fontcustom

#Volumes
VOLUME ["/project"]
WORKDIR /project

# Default run "fontcustom --help"
ENTRYPOINT ["fontcustom"]
CMD ["--help"]
