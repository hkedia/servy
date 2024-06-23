defmodule Servy.Handler do
  @moduledoc """
  Handles HTTP requests.
  """

  alias Servy.Plugins
  alias Servy.Parser
  alias Servy.FileHandler

  @pages_path Path.expand("../../pages", __DIR__)

  @doc "Transforms the request into a response"
  def handle(request) do
    request
    |> Parser.parse()
    |> Plugins.rewrite_path()
    |> Plugins.log()
    |> route
    |> Plugins.track()
    |> emojify
    |> format_response
  end

  def route(%{method: "GET", path: "/wildthings"} = conv) do
    %{conv | status: 200, resp_body: "Bears, Lions, Tigers"}
  end

  def route(%{method: "GET", path: "/bears"} = conv) do
    %{conv | status: 200, resp_body: "Teddy, Smokey, Paddington"}
  end

  def route(%{method: "GET", path: "/bears/new"} = conv) do
    @pages_path
    |> Path.join("form.html")
    |> File.read()
    |> FileHandler.handle_file(conv)
  end

  def route(%{method: "GET", path: "/bears/" <> id} = conv) do
    %{conv | status: 200, resp_body: "Bear #{id}"}
  end

  def route(%{method: "DELETE", path: "/bears/" <> _id} = conv) do
    %{conv | status: 403, resp_body: "Deleting a bear is forbidden"}
  end

  # Implementation using multi-clause functions

  def route(%{method: "GET", path: "/about"} = conv) do
    @pages_path
    |> Path.join("about.html")
    |> File.read()
    |> FileHandler.handle_file(conv)
  end

  def route(%{method: "GET", path: "/pages/" <> file} = conv) do
    @pages_path
    |> Path.join(file <> ".html")
    |> File.read()
    |> FileHandler.handle_file(conv)
  end

  def route(%{path: path} = conv) do
    %{conv | status: 404, resp_body: "No #{path} here!"}
  end

  # Implementation using case statements

  # def route(%{method: "GET", path: "/about"} = conv) do
  #   file =
  #     Path.expand("../../pages", __DIR__)
  #     |> Path.join("about.html")

  #   case File.read(file) do
  #     {:ok, content} ->
  #       %{conv | status: 200, resp_body: content}

  #     {:error, :enoent} ->
  #       %{conv | status: 404, resp_body: "File not found"}

  #     {:error, reason} ->
  #       %{conv | status: 500, resp_body: "File error: #{reason}"}
  #   end
  # end

  def format_response(conv) do
    """
    HTTP/1.1 #{conv.status} #{status_reason(conv.status)}
    Content-Type: text/html
    Content-Length: #{byte_size(conv.resp_body)}

    #{conv.resp_body}
    """
  end

  defp status_reason(code) do
    %{
      200 => "OK",
      201 => "Created",
      401 => "Unauthorized",
      403 => "Forbidden",
      404 => "Not Found",
      500 => "Internal Server Error"
    }[code]
  end

  defp emojify(%{status: 200} = conv) do
    emoji = String.duplicate("🎉", 5)
    body = emoji <> "\n" <> conv.resp_body <> "\n" <> emoji
    %{conv | resp_body: body}
  end

  defp emojify(conv), do: conv
end

request = """
GET /wildthings HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)

IO.puts(response)

request = """
GET /bears HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)

IO.puts(response)

request = """
GET /bigfoot HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)

IO.puts(response)

request = """
GET /bears/1 HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)

IO.puts(response)

request = """
DELETE /bears/1 HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)

IO.puts(response)

request = """
GET /wildlife HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)

IO.puts(response)

request = """
GET /bears?id=1 HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)

IO.puts(response)

request = """
GET /about HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)

IO.puts(response)

request = """
GET /bears/new HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)

IO.puts(response)
