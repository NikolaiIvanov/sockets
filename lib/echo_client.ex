defmodule EchoClient do
  use WebSockex
  require Logger

  @echo_server "wss://ws.postman-echo.com/raw"

  @doc """
  EchoClient.start_link/0
  Starts a WebSocket connection to the free WebSocket echo server

  ## Examples

      iex> EchoClient.start_link()
      {:ok, #PID<0.220.0>}

  """
  def start_link(opts \\ []) do
    socket_opts = [
      ssl_options: [
        ciphers: :ssl.cipher_suites(:all, :"tlsv1.3")
      ]
    ]
    opts = Keyword.merge(opts, socket_opts)
    WebSockex.start_link(@echo_server, __MODULE__, %{}, opts)
  end

  def handle_frame({:text, "ping" = msg}, state) do
    Logger.info("Echo server says: #{msg}")
    reply = "Pong!"

    Logger.info("Sent to Echo: #{reply}")

    {:reply, {:text, reply}, state}
  end

  @doc """
  EchoClient.handle_flame/2
  Invoked on the reception of a frame on the socket with provided data.

  ## Examples

      iex> {:ok, pid} = EchoClient.start_link()
      {:ok, #PID<0.220.0>}

      iex> WebSockex.send_frame(pid, {:text, "Greetings"})
      14:28:12.927 [info]  Echo server says, Greetings

  """
  def handle_frame({:text, msg}, state) do
    Logger.info("Echo server says, #{msg}")
    {:ok, state}
  end

  @doc """
  EchoClient.handle_flame/2
  Invoked on the reception of a frame on the socket with provided data.

  ## Examples

      iex> {:ok, pid} = EchoClient.start_link()
      {:ok, #PID<0.220.0>}

      iex> WebSockex.send_frame(pid, {:text, "ping"})
      14:34:21.028 [info]  Echo server says: ping

      14:34:21.028 [info]  Sent to Echo: Pong!

      14:34:21.185 [info]  Echo server says, Pong!

  """
  def handle_frame({:text, "halt"}, state) do
    Logger.info("Shutting down...")

    {:close, state}
  end

  def handle_disconnect(%{reason: reason}, state) do
    Logger.info("Disconnect with reason #{inspect reason}")

    {:ok, state}
  end

end
