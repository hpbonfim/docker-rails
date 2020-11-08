FROM ruby:2.7.2

#Install dependencies - ARG is set only during the build
ARG DEBIAN_FRONTEND=noninteractive 
ARG NODE_VERSION=14.15.0

RUN apt-get update && apt-get install -y apt-utils && apt-get install -y curl && apt-get install -y build-essential

# Install PostgreSQL
RUN apt-get update -qq && apt-get install -y postgresql-client && apt-get upgrade -y

# Install NodeJS LTS, NPM and Yarn
RUN curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.37.0/install.sh | bash
ENV NVM_DIR=/root/.nvm
RUN . "$NVM_DIR/nvm.sh" && nvm install ${NODE_VERSION} \
    && . "$NVM_DIR/nvm.sh" && nvm use v${NODE_VERSION} \
    && . "$NVM_DIR/nvm.sh" && nvm alias default v${NODE_VERSION}
ENV PATH="/root/.nvm/versions/node/v${NODE_VERSION}/bin/:${PATH}"
RUN npm install -g yarn && node --version && npm --version && yarn --version

#Install Ruby and Rails
RUN mkdir /app
WORKDIR /app
COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock
RUN bundle install
COPY . /app

# Add a script to be executed every time the container starts.
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000

# Start the main process.
CMD ["rails", "server", "-b", "0.0.0.0"]
