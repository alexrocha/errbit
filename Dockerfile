FROM ruby:2.5.1
LABEL maintainer="David Papp <david@ghostmonitor.com>"

WORKDIR /app
# throw errors if Gemfile has been modified since Gemfile.lock
RUN echo "gem: --no-document" >> /etc/gemrc \
  && bundle config --global frozen 1 \
  && bundle config --global clean true \
  && bundle config --global disable_shared_gems false \
  && gem update --system 2.7.4 \
  && gem install bundler --version 1.16.1 \
  && apt-get update; apt-get install -y --no-install-recommends curl \
    less \
    libxml2-dev \
    libxslt-dev \
    nodejs \
    tzdata \
    build-essential \
    patch \
    ruby-dev \
    zlib1g-dev


COPY ["Gemfile", "Gemfile.lock", "/app/"]

RUN gem update --system
RUN gem update bundler

RUN bundle install

COPY . /app

RUN RAILS_ENV=production bundle exec rake assets:precompile \
  && rm -rf /app/tmp/* \
  && chmod 777 /app/tmp

EXPOSE 8080

HEALTHCHECK CMD curl --fail "http://$(/bin/hostname -i | /usr/bin/awk '{ print $1 }'):${PORT:-8080}/users/sign_in" || exit 1

CMD ["bundle","exec","puma","-C","config/puma.default.rb"]
