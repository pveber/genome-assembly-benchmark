open Core.Std
open Bistro.Std
open Bistro_bioinfo.Std
open Bistro.EDSL_sh

type quast_output = [`quast_output] directory

let quast ?reference fas =
  workflow ~descr:"quast" [
    cmd "quast" [
      option (opt "-R" dep) reference ;
      opt "--output-dir" (fun x -> seq [x ; string "/results"]) dest ;
      list ~sep:" " dep fas ;
    ]
  ]
