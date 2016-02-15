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
  (ao / Arts.pe_fastq `One,
   ao / Arts.pe_fastq `Two)

let bsubtilis_reads = sequencer 100_000 bsubtilis_genome

let spades_bsubtilis_assembly =
  let pe = [ fst bsubtilis_reads], [snd bsubtilis_reads ] in
  Spades.spades ~pe ()
  / Spades.contigs

let idba_ud_bsubtilis_assembly =
  Idba.(idba_ud (fq2fa (`Pe_merge bsubtilis_reads)))
  / Idba.idba_ud_contigs

let quast_comparison =
  Quast.quast
    ~reference:bsubtilis_genome
    [
      spades_bsubtilis_assembly ;
      idba_ud_bsubtilis_assembly ;
    ]

let rep x = "output" :: x

let () = Bistro_app.(
    simple [
      rep [ "B.subtilis" ; "SPAdes" ; "contigs.fa"] %> spades_bsubtilis_assembly ;
      rep [ "B.subtilis" ; "IDBA" ; ] %> idba_ud_bsubtilis_assembly ;
      rep [ "B.subtilis" ; "quast" ] %> quast_comparison
    ]
  )

