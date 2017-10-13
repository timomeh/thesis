defmodule WarpWeb.Router do
  use WarpWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", WarpWeb do
    pipe_through :api

    resources "/projects", API.ProjectController, only: [] do
      resources "/pipelines", API.PipelineController, only: [:index, :create]
    end

    resources "/pipelines", API.PipelineController, only: [:show, :update, :delete]
  end
end
