FROM elixir:1.14 as builder

WORKDIR /app

ARG MIX_ENV=prod

RUN mix local.hex --force
RUN mix local.rebar --force

ENV MIX_ENV=${MIX_ENV}

COPY mix.exs /app/mix.exs
COPY mix.lock /app/mix.lock

RUN mix deps.get --only prod
RUN mix deps.compile

COPY . .

RUN mix release
RUN mix phx.gen.release

FROM elixir:1.14-slim

WORKDIR /app

ENV PHX_SERVER true

COPY --from=builder /app/_build/prod/rel/p2p ./

CMD ["/app/bin/p2p", "start"]