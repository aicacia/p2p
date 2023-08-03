defmodule P2pWeb.Socket.JSONSerializer do
  def decode!(raw_message, opts) do
    case Keyword.fetch(opts, :opcode) do
      {:ok, :text} -> decode_text(raw_message)
      {:ok, :binary} -> decode_binary(raw_message)
    end
  end

  defp decode_text(raw_message) do
    Phoenix.json_library().decode!(raw_message)
  end

  defp decode_binary(<<
         data::binary
       >>) do
    {:binary, data}
  end
end
