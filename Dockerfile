FROM ruby:2.5.1-slim
MAINTAINER naari3
 
# Update packages and install ruby
RUN apt-get update && apt-get install -y build-essential zlib1g zlib1g-dev fontforge unzip python

# Install latest fontcustom
COPY lib/woff-code-latest.zip ./woff-code-latest.zip
RUN cd
RUN unzip woff-code-latest.zip -d sfnt2woff && cd sfnt2woff && make && mv sfnt2woff /usr/local/bin/
RUN gem install fontcustom

# Cleanup
ENV SUDO_FORCE_REMOVE yes
RUN apt-get --purge remove -y build-essential unzip zlib1g-dev

#Volumes
VOLUME ["/project"]
WORKDIR /project

# Default run "fontcustom --help"
ENTRYPOINT ["fontcustom"]
CMD ["--help"]
