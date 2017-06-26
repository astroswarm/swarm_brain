ARG ARCH

FROM astroswarm/base-$ARCH:latest

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get -y update
RUN apt-get -y install build-essential curl git
RUN apt-get -y install zlib1g-dev libssl-dev libreadline-dev libyaml-dev libxml2-dev libxslt-dev
RUN apt-get -y install rbenv
RUN git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
RUN CONFIGURE_OPTS="--disable-install-doc --enable-shared" rbenv install -v 2.4.1

ENV PATH $HOME/.rbenv/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
RUN rbenv global 2.4.1
RUN rbenv exec gem install --no-ri --no-rdoc bundler

ENV INSTALL_PATH /app

RUN mkdir -p $INSTALL_PATH
WORKDIR $INSTALL_PATH

ENV BUNDLE_PATH /bundle

COPY Gemfile $INSTALL_PATH
COPY Gemfile.lock $INSTALL_PATH
RUN rbenv exec bundle install

COPY . $INSTALL_PATH

EXPOSE 9292

CMD rbenv exec bundle exec rackup -s puma -p 9292 -o 0.0.0.0 -E $RACK_ENV