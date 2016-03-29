open Core.Std
open Bistro.Std
open Bistro_bioinfo.Std

let ( / ) = Bistro.EDSL.( / )

type dataset = {
  name : string ;
  reference : fasta workflow ;
  genome_size : int ;
  reads : [`sanger] fastq workflow * [`sanger] fastq workflow ;
}


let pipeline { name ; genome_size ; reference ; reads = ((reads_1, reads_2) as reads) } =
  let spades_assembly =
    let pe = [ reads_1 ], [ reads_2 ] in
    Spades.spades ~pe () / Spades.contigs
  in
  let idba_ud_assembly =
    Idba.(idba_ud (fq2fa (`Pe_merge reads)))
    / Idba.idba_ud_contigs
  in
  let velvet_assembly =
    Velvet.velvet
    ~cov_cutoff:4
    ~min_contig_lgth:100
    ~hash_length:21
    ~ins_length:400
    ~exp_cov:7.5
    reads_1 reads_2
    / Velvet.contigs
  in
  let cisa_assembly : fasta workflow =
    Cisa.merge [
      "SPAdes", spades_assembly ;
      "IDBA", idba_ud_assembly ;
      "Velvet", velvet_assembly ;
    ]
    |> Cisa.cisa genome_size
  in
  let quast_comparison =
    Quast.quast
      ~reference
      ~labels:["SPAdes" ; "IDBA-UD" ; "Velvet" ; "CISA"]
      [
        spades_assembly ;
        idba_ud_assembly ;
        velvet_assembly ;
        cisa_assembly ;
      ]
  in
  let open Bistro_app in
  let rep x = "output" :: name :: x in
  [
    rep [ "SPAdes" ; "contigs.fa"] %> spades_assembly ;
    rep [ "IDBA" ; ] %> idba_ud_assembly ;
    rep [ "Velvet" ; ] %> velvet_assembly ;
    rep [ "CISA" ; ] %> cisa_assembly ;
    rep [ "quast" ] %> quast_comparison ;
  ]


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


let bsubtilis_genome : fasta workflow =
  Unix_tools.wget "ftp://ftp.ncbi.nlm.nih.gov/genomes/refseq/bacteria/Bacillus_subtilis/representative/GCF_000227465.1_ASM22746v1/GCF_000227465.1_ASM22746v1_genomic.fna.gz"
  |> Unix_tools.gunzip

let bsubtilis = {
  name = "B.subtilis" ;
  genome_size = 5_000_000 ;
  reference = bsubtilis_genome ;
  reads = sequencer 100_000 bsubtilis_genome ;
}

let np = 4
let mem = 10 * 1024

let main queue workdir () =
  let backend = match queue with
    | None -> Bistro_engine.Scheduler.local_backend ~np ~mem
    | Some queue ->
      let workdir = Option.value ~default:(Sys.getcwd ()) workdir in
      Bistro_pbs.Backend.make ~queue ~workdir
  in
  let targets = List.concat [
      pipeline bsubtilis
    ]
  in
  Bistro_app.with_backend backend targets

let spec =
  let open Command.Spec in
  empty
  +> flag "--pbsqueue" (optional string) ~doc:"QUEUE Name of a PBS queue"
  +> flag "--nodedir"  (optional string) ~doc:"DIR (Preferably local) scratch directory on worker nodes"

let command =
  Command.basic
    ~summary:"Genome assembler benchmark for prokaryotes"
    spec
    main

let () = Command.run ~version:"0.1" command
