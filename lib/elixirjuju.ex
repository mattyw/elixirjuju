defmodule Elixirjuju do
  @moduledoc """
  Example usage:

  iex(1)> pid = Elixirjuju.start("url", "admin-secret")
  iex(2)> pid <- Elixirjuju.deploy("wordpress", "cs:precise/wordpress", 1)
  iex(3)> pid <- Elixirjuju.deploy("mysql", "cs:precise/mysql", 1)        
  iex(4)> pid <- Elixirjuju.add_relation("wordpress", "mysql")  

  """
  require Socket
  require HTTPotion
  require Jsonex
  alias HTTPotion.Response


  def fetch_charm_info(charm_url) do
    case HTTPotion.get("https://store.juju.ubuntu.com/charm-info?charms=#{charm_url}") do
      Response[body: body, status_code: status, headers: _headers]
      when status in 200..299 ->
        {:ok, body}
      Response[body: body, status_code: _status, headers: _headers] ->
        {:error, body}
    end
  end

  def latest_charm_version(charm_url) do
    {:ok, info} = fetch_charm_info(charm_url)
    json = Jsonex.decode(info)
    json[charm_url]["revision"]
  end

  @doc """
  Build a login message 
  """
  def login(user, password) do
    "{\"Type\": \"Admin\", \"Request\": \"Login\", \"Params\": {\"AuthTag\": \"#{user}\", \"Password\": \"#{password}\"}}"
  end

  @doc """
  Build a message to watch for any changes
  """
  def watch_all() do
    "{\"Type\": \"Client\", \"Request\": \"WatchAll\", \"Params\": {}}"
  end

  @doc """
  Whilst watching, grab the next item
  """
  def next() do
    "{\"Type\": \"AllWatcher\", \"Request\": \"Next\", \"Id\": \"1\"}"
  end

  @doc """
  Build a message to deploy a service
  """
  def deploy(service_name, charm_url, num_units) do
    latest_version = latest_charm_version(charm_url)
    "{\"Type\": \"Client\", \"Request\": \"ServiceDeploy\", \"Params\": { \"ServiceName\": \"#{service_name}\", \"CharmURL\": \"#{charm_url}-#{latest_version}\", \"NumUnits\": #{num_units}, \"Config\": {}, \"Constraints\": {}}}"
  end

  @doc """
  Build a message to destroy a service
  """
  def destroy_service(service_name) do
    "{ \"Type\": \"Client\", \"Request\": \"ServiceDestroy\", \"Params\": { \"ServiceName\": \"#{service_name}\"}}"
  end

  @doc """
  Build a message to add a relation
  """
  def add_relation(serviceA, serviceB) do
    "{\"Type\": \"Client\", \"Request\": \"AddRelation\", \"Params\": { \"Endpoints\": [\"#{serviceA}\", \"#{serviceB}\"]}}"
  end

  @doc """
  Build a message to remove a relation
  """
  def remove_relation(serviceA, serviceB) do
    "{\"Type\": \"Client\", \"Request\": \"DestroyRelation\", \"Params\": { \"Endpoints\": [\"#{serviceA}\", \"#{serviceB}\"]}}"
  end

  @doc """
  Build a message to add a unit
  """
  def add_unit(service_name, num_units) do
    "{\"Type\": \"Client\", \"Request\": \"AddServiceUnits\", \"Params\": { \"ServiceName\": \"#{service_name}\", \"NumUnits\": #{num_units}}}"
  end

  @doc """
  Build a message to remove a unit
  """
  def remove_units(unit_names) do
    "{\"Type\": \"Client\", \"Request\": \"DestroyServiceUnits\", \"Params\": { \"UnitNames\": [\"#{unit_names}\"]}}"
  end

  def to_juju(sock) do
    receive do
      m ->
        IO.puts "Sending! #{m}"
        sock.send({:text, m})
        to_juju(sock)
      :exit ->
        IO.puts "done!"
    end
  end

  def recv(sock) do
    {:ok, data} = sock.recv
    IO.inspect data
    recv(sock)
  end

  def watch(pid) do
    pid <- next() # Need to call this multiple times to get changes
    :timer.sleep(30000)
    watch(pid)
  end

  @doc """
   Start a process that will send and recv data with the juju api.
   As well as starting the connection login as well
  """
  def start(url, password) do
    {:ok, secure_sock} = Socket.Web.connect(url, 17070, secure: true, origin: "http://localhost")

    #self <- watch_all()
    #self <- deploy("wordpress", "cs:precise/wordpress", 1)
    #self <- deploy("mysql", "cs:precise/mysql", 1)
    #self <- add_relation("wordpress", "mysql")
    #self <- remove_relation("wordpress", "mysql")
    #self <- add_unit("wordpress", 1)
    #self <- remove_units(["wordpress/1"])
    #self <- destroy_service("wordpress")
    #spawn(__MODULE__, :watch, [self])
    spawn(__MODULE__, :recv, [secure_sock]) # TODO send over output channel
    pid = spawn(__MODULE__, :to_juju, [secure_sock])
    pid <- login("user-admin", password)
    pid
  end
end
