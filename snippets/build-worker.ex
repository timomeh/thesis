defmodule Warp.Worker.BuildWorker do
  use GenServer

  def start(build, project_id) do
    state = %{
      build: build,
      current_stage_index: -1,
      project_id: project_id
    }
    Process.flag(:trap_exit, true)
    GenServer.start(__MODULE__, state)
  end

  def run(pid) do
    GenServer.cast(pid, :run)
  end

  def handle_cast(:run, state) do
    log(state, "START")

    {:ok, build} = Builds.update_started(state.build)
    state =
      state
      |> Map.put(:build, build)
      |> broadcast()
      |> log("RUN FIRST STAGE")
      |> run_next_stage()

    {:noreply, state}
  end

  defp run_next_stage(state) do
    state = Map.put(state, :current_stage_index, state.current_stage_index + 1)

    state.build.stages
    |> Enum.at(state.current_stage_index)
    |> run_stage(state)

    state
  end

  defp run_stage(stage, state) do
    {:ok, pid} = GroupWorker.start_link(stage, state.project_id, state.build.working_dir, :stage)
    GroupWorker.run(pid)
  end

  def handle_info({:EXIT, _pid, :normal}, %{current_stage_index: i, build: %{stages: stages}} = state)
    when i < length(stages) - 1
  do
    state =
      state
      |> log("RUN NEXT STAGE")
      |> run_next_stage()

    {:noreply, state}
  end

  def handle_info({:EXIT, _pid, :normal}, %{current_stage_index: i, build: %{stages: stages}} = state)
    when i == length(stages) - 1
  do
    log(state, "ALL STAGES DONE")
    {:stop, :normal, state}
  end

  def handle_info({:EXIT, _pid, :error}, state) do
    log(state, "STAGE ERRORED. ABORT")
    {:stop, :error, state}
  end

  def terminate(reason, state) do
    build = case reason do
      :normal ->
        {:ok, build} = Builds.update_finished(state.build)
        build
      :error ->
        {:ok, build} = Builds.update_finished(state.build, "failed")
        Stages.update_all_pending_to_stopped(build)
        build
    end

    PipelineQueue.dequeue(build.pipeline_id, build.id)

    state
    |> Map.put(:build, build)
    |> log("TERMINATE")
    |> broadcast()
  end

  defp broadcast(state, event \\ "change") do
    topic = "project:#{state.project_id}"
    message = %{
      event: event,
      type: "build",
      data: state.build
    }
    PubSub.broadcast(Warp.PubSub, topic, message)
    state
  end
end
