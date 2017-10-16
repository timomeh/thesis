{:ok, pid} = BuildWorker.start(some_build, some_project_id)
BuildWorker.run(pid)
