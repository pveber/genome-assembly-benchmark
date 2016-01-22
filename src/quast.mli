open Bistro.Std
open Bistro_bioinfo.Std

type quast_output = [`quast_output] directory

val quast :
  ?reference:fasta workflow ->
  fasta workflow list ->
  quast_output workflow
