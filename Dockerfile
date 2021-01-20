FROM ruby:2.6.6
RUN apt-get update && apt-get install -y \
  curl \
  build-essential \
  libpq-dev &&\
  curl -sL https://deb.nodesource.com/setup_10.x | bash - && \
  curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
  echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
  apt-get update && apt-get install -y nodejs yarn

# copy file into container
RUN mkdir /backend
WORKDIR /backend

COPY Gemfile Gemfile.lock ./
RUN gem install bundler:2.1.4 
RUN bundle install
COPY . .

COPY package.json ./
RUN yarn install
# RUN rails webpacker:install

# Add a script to be executed every time the container starts.
# COPY entrypoint.sh /usr/bin/
# RUN chmod +x /usr/bin/entrypoint.sh
# ENTRYPOINT ["/bin/bash", "entrypoint.sh"]
ENV RAILS_ENV development

EXPOSE 3000

# Install webpacker for rails 6

# RUN chmod -R 777 ./


# # Start the main process.
CMD ["rails", "server", "-b", "0.0.0.0"]

