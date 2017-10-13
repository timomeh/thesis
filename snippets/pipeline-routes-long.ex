defmodule WarpWeb.Router do
  use WarpWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", WarpWeb do
    pipe_through :api

    get "/projects/:project_id/pipelines", API.ProjectController, :index
    post "/projects/:project_id/pipelines", API.ProjectController, :create
    get "/pipelines/:pipeline_id", API.ProjectController, :show
    put "/pipelines/:pipeline_id", API.ProjectController, :update
    delete "/pipelines/:pipeline_id", API.ProjectController, :delete
  end
end
