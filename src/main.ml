open Core.Std

let main preview_mode workdir np mem () =
  let backend = Bistro_engine.Scheduler.local_backend ?workdir ~np ~mem:(mem * 1024) () in
  Bistro_app.with_backend backend (Pipeline.make ())

let spec =
  let open Command.Spec in
  empty
  +> flag "--preview-mode" no_arg ~doc:" Run on a small subset of the data"
  +> flag "--workdir"  (optional string) ~doc:"DIR (Preferably local) directory for temporary files"
  +> flag "--np"      (optional_with_default 4 int) ~doc:"INT Number of processors"
  +> flag "--mem"     (optional_with_default 4 int) ~doc:"INT Available memory (in GB)"

let command =
  Command.basic
    ~summary:"Genome assembler benchmark for prokaryotes"
    spec
    main

let () = Command.run ~version:"0.1" command
