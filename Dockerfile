FROM ruby:2.5.0
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs
RUN mkdir /app
WORKDIR /app
ADD Gemfile Gemfile.lock /app/
ENV BUNDLER_VERSION=2.0.1
RUN gem install bundler:2.0.1
RUN bundle install
COPY . /app

EXPOSE 3000
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
