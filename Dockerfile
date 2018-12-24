FROM debian:stretch-slim

# Update packages and install ruby
RUN apt-get update && apt-get install --no-install-recommends -y \
  ruby2.3 ruby2.3-dev \
  git build-essential fontforge zlib1g zlib1g-dev unzip python \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

RUN git clone --recursive https://github.com/google/woff2.git /tmp/woff2 \
  && cd /tmp/woff2 \
  && make clean all && mv woff2_compress /usr/local/bin/woff2_compress \
  && mv woff2_decompress /usr/local/bin/woff2_decompress \
  && rm -rf /tmp/woff2

COPY lib/woff-code-latest.zip /tmp/woff-code-latest.zip
RUN cd /tmp && unzip woff-code-latest.zip -d sfnt2woff \
  && cd sfnt2woff \
  && make && mv sfnt2woff /usr/local/bin/ \
  && rm -rf /tmp/sfnt2woff

# Install latest fontcustom
RUN gem install fontcustom


#Volumes
VOLUME ["/project"]
WORKDIR /project

# Default run "fontcustom --help"
ENTRYPOINT ["fontcustom"]
CMD ["--help"]
