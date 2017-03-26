#!/usr/bin/env bash

# Get the last changes
git pull origin master

# Initial setup
mix deps.get --only prod

# Generate a new release
MIX_ENV=prod mix release --env=prod
_build/prod/rel/discordbot/bin/discordbot stop
_build/prod/rel/discordbot/bin/discordbot start
