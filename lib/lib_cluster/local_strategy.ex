defmodule LibCluster.LocalStrategy do
  @moduledoc """
  libcluster strategy to be able to configure local nodes with the environment variable NODES

  # Example

  NODES=a@127.0.0.1,b@127.0.0.1 iex --name a@127.0.0.1 -S mix
  NODES=a@127.0.0.1,b@127.0.0.1 iex --name b@127.0.0.1 -S mix

  iex(a@127.0.0.1)1> Node.list
  [:"b@127.0.0.1"]

  iex(b@127.0.0.1)1> Node.list
  [:"a@127.0.0.1"]
  """
  use Cluster.Strategy
  alias Cluster.Strategy.State

  def start_link([%State{} = state]) do
    case System.get_env("NODES") do
      node_binary_list when is_binary(node_binary_list) ->
        nodes = convert_to_nodes(node_binary_list)
        Cluster.Strategy.connect_nodes(state.topology, state.connect, state.list_nodes, nodes)
        :ignore

      _ ->
        :ignore
    end
  end

  def convert_to_nodes(node_binary_list) do
    node_binary_list
    |> String.split(",")
    # TODO: maybe String.to_existing_atom/1
    |> Enum.map(&String.to_atom/1)
  end
end
