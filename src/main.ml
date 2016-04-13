open Core.Std

let run_main preview_mode tmpdir outdir np mem () =
  let backend = Bistro_engine.Scheduler.local_backend ?tmpdir ~np ~mem:(mem * 1024) () in
  Bistro_app.with_backend backend ~outdir (Pipeline.make ())

let run_spec =
  let open Command.Spec in
  empty
  +> flag "--preview-mode" no_arg ~doc:" Run on a small subset of the data"
  +> flag "--tmpdir"  (optional string) ~doc:"DIR (Preferably local) directory for temporary files"
  +> flag "--outdir"  (required string) ~doc:"DIR Directory where to link exported targets"
  +> flag "--np"      (optional_with_default 4 int) ~doc:"INT Number of processors"
  +> flag "--mem"     (optional_with_default 4 int) ~doc:"INT Available memory (in GB)"

let run_command =
  Command.basic
    ~summary:"Run genome assembler benchmark for prokaryotes"
    run_spec
    run_main

let dump_main () =
  Bistro_app.plan_to_channel (Pipeline.make ()) stdout

let dump_command =
  Command.basic
    ~summary:"Dump workflow"
    Command.Spec.empty
    dump_main

let () =
  Command.group
    ~summary:"Genome assembler benchmark for prokaryotes"
    [ "run", run_command ;
      "dump", dump_command ]
  |> Command.run ~version:"0.1"
