#
#===[ BUILDER IMAGE ]===
#

FROM hexpm/elixir:1.11.1-erlang-22.3.4.12-ubuntu-trusty-20191217 AS builder

ENV MIX_ENV=prod

WORKDIR /app

# Install Node and system build tools
COPY ./devops/install-node.sh ./
RUN bash ./install-node.sh \
  && rm ./install-node.sh
RUN apt-get install -y \
    gcc \
    make \
    nodejs

# Install Elixir build tools
RUN mix local.hex --force && \
    mix local.rebar --force

# Get and compile dependencies
COPY ./mix.exs ./mix.lock ./devops/dynamic-deps.exs ./
RUN MIX_EXS=./dynamic-deps.exs mix do deps.get, deps.compile \
  && rm ./dynamic-deps.exs

# Copy all needed project files
COPY ./config ./config
COPY ./apps ./apps
COPY ./rel ./rel

# Generate web assets
RUN npm --prefix ./apps/riddler_admin_web/assets ci --progress=false --no-audit --loglevel=error
RUN npm run --prefix ./apps/riddler_admin_web/assets deploy
RUN mix phx.digest

# Compile app and generate Elixir release
RUN mix do compile, release server

#
#===[ RELEASE IMAGE ]===
#

FROM ubuntu:18.04

ENV LANG=C.UTF-8

RUN useradd --create-home app
USER app
WORKDIR /home/app

# Copy Elixir release from BUILDER image
COPY --from=builder --chown=app:app /app/_build/prod/rel/server /home/app/
