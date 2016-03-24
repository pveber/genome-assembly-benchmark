open Core.Std
open Bistro.Std
open Bistro_bioinfo.Std
open Bistro.EDSL_sh

type quast_output = [`quast_output] directory

let quast ?reference ?labels fas =
  workflow ~descr:"quast" [
    cmd "quast.py" [
      option (opt "-R" dep) reference ;
      option (opt "--labels" (list ~sep:"," string)) labels ;
      opt "--output-dir" (fun x -> seq [x ; string "/results"]) dest ;
      list ~sep:" " dep fas ;
    ]
  ]
