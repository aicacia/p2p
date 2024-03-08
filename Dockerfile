FROM elixir:1.16 as builder

WORKDIR /app

ARG MIX_ENV=prod

RUN mix local.hex --force
RUN mix local.rebar --force

ENV MIX_ENV=${MIX_ENV}

COPY mix.exs /app/mix.exs
COPY mix.lock /app/mix.lock

RUN mix deps.get
RUN mix deps.compile

COPY . .

RUN mix release

FROM erlang:26-slim

WORKDIR /app

ARG MIX_ENV=prod

ENV PHX_SERVER=true
ENV MIX_ENV=${MIX_ENV}

COPY --from=builder /app/_build/${MIX_ENV}/rel/p2p ./

CMD ["/app/bin/p2p", "start"]