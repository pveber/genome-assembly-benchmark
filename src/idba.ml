open Core.Std
open Bistro.Std
open Bistro_bioinfo.Std
open Bistro.EDSL_sh



type fq2fa_input = [
  | `Se of [`sanger] fastq workflow
  | `Pe_merge of [`sanger] fastq workflow * [`sanger] fastq workflow
  | `Pe_paired of [`sanger] fastq workflow
]

let fq2fa ?filter input =
  let args = match input with
    | `Se fq -> dep fq
    | `Pe_merge (fq1, fq2) ->
      opt "--merge" ident (seq ~sep:" " [dep fq1 ; dep fq2])
    | `Pe_paired fq ->
      opt "--paired" dep fq
  in
  workflow ~descr:"fq2fa" [
    cmd "fq2fa" [
      args ;
      dest ;
    ]
  ]


type idba_ud_output = [`idba_ud_output] directory

let idba_ud fa : idba_ud_output workflow =
  workflow ~descr:"idba_ud" [
    mkdir_p dest ;
    cmd "idba_ud" [
      opt "--read" dep fa ;
      opt "--out" ident dest ;
    ]
  ]

let idba_ud_contigs = selector ["contig.fa"]
let idba_ud_scaffolds = selector ["scaffold.fa"]
