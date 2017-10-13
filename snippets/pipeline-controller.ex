defmodule WarpWeb.API.PipelineController do
  use WarpWeb, :controller

  alias Warp.Pipelines
  alias Warp.Projects

  @doc """
  GET /projects/:project_id/pipelines
  Lists all Pipelines of a Project.
  """
  def index(conn, %{"project_id" => project_id}) do
    project = Projects.get!(project_id)
    pipelines = Pipelines.list(project)
    render(conn, "list.json", pipelines: pipelines)
  end

  @doc """
  POST /projects/:project_id/pipelines
  Creates a Pipeline for a Project.
  """
  def create(conn, %{"data" => pipeline_params, "project_id" => project_id}) do
    project = Projects.get!(project_id)

    case Pipelines.create(project, pipeline_params) do
      {:ok, pipeline} ->
        conn
        |> put_status(:created)
        |> render("show.json", pipeline: pipeline)
      {:error, changeset} ->
        conn
        |> put_status(:bad_request)
        |> render(WarpWeb.API.ChangesetView, "error.json", changeset: changeset)
    end
  end

  @doc """
  GET /pipelines/:id
  Gets a Pipeline.
  """
  def show(conn, %{"id" => id}) do
    pipeline = Pipelines.get!(id)
    render(conn, "show.json", pipeline: pipeline)
  end

  @doc """
  PUT /pipelines/:id
  Updates a Pipeline.
  """
  def update(conn, %{"id" => id, "data" => pipeline_params}) do
    pipeline = Pipelines.get!(id)

    case Pipelines.update(pipeline, pipeline_params) do
      {:ok, pipeline} ->
        render(conn, "show.json", pipeline: pipeline)
      {:error, changeset} ->
        conn
        |> put_status(:bad_request)
        |> render(WarpWeb.API.ChangesetView, "error.json", changeset: changeset)
    end
  end

  @doc """
  DELETE /pipelines/:id
  Deletes a Pipeline.
  """
  def delete(conn, %{"id" => id}) do
    pipeline = Pipelines.get!(id)
    {:ok, _pipeline} = Pipelines.delete(pipeline)
    render(conn, WarpWeb.API.MetaView, "show.json", message: "Pipeline deleted successfully.")
  end
end
