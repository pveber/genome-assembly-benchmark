open Core.Std
open Bistro.Std
open Bistro_bioinfo.Std

let ( / ) = Bistro.EDSL.( / )

let bsubtilis_genome : fasta workflow =
  Unix_tools.wget "ftp://ftp.ncbi.nlm.nih.gov/genomes/refseq/bacteria/Bacillus_subtilis/representative/GCF_000227465.1_ASM22746v1/GCF_000227465.1_ASM22746v1_genomic.fna.gz"
  |> Unix_tools.gunzip

let sequencer n fa =
  let ao =
    Arts.(
      art_illumina
        ~aln_output:False
        ~sam_output:False
        ~errfree_sam_output:False
        (Paired_end { len = 150 ;
                      mflen = 400. ;
                      sdev = 20. ;
                      matepair = false })
        (`Read_count n) fa
    )
  in
  ( [ ao / Arts.pe_fastq `One ],
    [ ao / Arts.pe_fastq `Two ] )

