FROM alpine:latest AS build-env

# Update packages and install build dependencies
RUN apk update \
  && apk add --no-cache \
    ruby ruby-dev git libffi-dev make gcc g++ libc-dev zlib-dev

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

RUN gem install fontcustom --no-document


FROM alpine:latest

# copy woff2 and sfnt2woff
COPY --from=build-env /usr/local/bin /usr/local/bin

# Update packages and install ruby, dependencies
RUN apk update \
  && apk add --no-cache \
    --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing \
    ruby fontforge

# copy gems
COPY --from=build-env /usr/lib/ruby /usr/lib/ruby
COPY --from=build-env /usr/bin/fontcustom /usr/bin/fontcustom

#Volumes
VOLUME ["/project"]
WORKDIR /project

# Default run "fontcustom --help"
ENTRYPOINT ["fontcustom"]
CMD ["--help"]
