defmodule P2pWeb.Token do
  use Joken.Config

  @impl true
  def token_config do
    default_claims(iss: "P2P", aud: "P2P", default_exp: 60)
  end
end
