defmodule Answerwrong do
  @moduledoc """
  Answerwrong keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """
  def start(_type, _args) do
    import Supervisor.Spec, warn: false
    :ets.new(:session, [:named_table, :public, read_concurrency: true])
  end
end
