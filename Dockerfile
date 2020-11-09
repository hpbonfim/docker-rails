FROM ruby:2.7.2

#Install dependencies - ARG is set only during the build
ARG DEBIAN_FRONTEND=noninteractive
ARG NODE_VERSION=14.15.0
ARG INSTALL_PATH=/app

RUN apt-get update -qq\ 
    && apt-get install -y apt-utils curl build-essential postgresql-client libpq-dev \
    && apt-get update -qq && apt-get upgrade -y

# Install NodeJS LTS, NPM and Yarn
ENV NVM_DIR=/root/.nvm
RUN curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.37.0/install.sh | bash
RUN . "$NVM_DIR/nvm.sh" && nvm install ${NODE_VERSION} \
    && . "$NVM_DIR/nvm.sh" && nvm use v${NODE_VERSION} \
    && . "$NVM_DIR/nvm.sh" && nvm alias default v${NODE_VERSION}
ENV PATH="/root/.nvm/versions/node/v${NODE_VERSION}/bin/:${PATH}"
RUN npm install -g yarn && node --version && npm --version && yarn --version

#Install Ruby and Rails
RUN mkdir ${INSTALL_PATH}
WORKDIR ${INSTALL_PATH}

COPY . ${INSTALL_PATH}
COPY Gemfile ${INSTALL_PATH}/Gemfile
COPY Gemfile.lock ${INSTALL_PATH}/Gemfile.lock
RUN bundle install

COPY . ${INSTALL_PATH}

# Add a script to be executed every time the container starts.
RUN cp docker-entrypoint.sh /usr/bin/ && \
    chmod +x /usr/bin/docker-entrypoint.sh
ENTRYPOINT ["/usr/bin/docker-entrypoint.sh"]

# Start the main process. bundle exec rails s -p 3000 -b '0.0.0.0'
EXPOSE 3000
CMD ["rails", "server", "-b", "0.0.0.0"]