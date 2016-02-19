open Core.Std
open Bistro.Std
open Bistro_bioinfo.Std
open Bistro.EDSL_sh


let package = Bistro.Workflow.make ~descr:"spades.package" [%sh{|
PREFIX={{ dest }}

mkdir -p $PREFIX
cd $PREFIX
wget https://www.ebi.ac.uk/~zerbino/velvet/velvet_1.2.10.tgz
tar xvfz velvet_1.2.10.tgz
cd velvet_1.2.10
make

mkdir $PREFIX/bin
cp velveth velvetg $PREFIX/bin

cd ..
rm -rf velvet_1.2.10*
|}]



type velvet_output = [`velvet_output] directory

let velvet ?cov_cutoff ?min_contig_lgth ~hash_length ~ins_length ~exp_cov fq1 fq2 =
  workflow ~descr:"velvet" [
    mkdir_p dest ;
    cmd ~path:[package] "velveth" [
      dest ;
      int hash_length ;
      string "-separate" ;

      string "-shortPaired" ;
      string "-fastq" ;
      string "-short" ;
      dep fq1 ;
      dep fq2 ;
    ] ;
    cmd ~path:[package] "velvetg" [
      dest ;
      opt "-ins_length" int ins_length ;
      opt "-exp_cov" float exp_cov ;
      option (opt "-cov_cutoff" int) cov_cutoff ;
      option (opt "-min_contig_lgth" int) min_contig_lgth ;
    ]
  ]

let contigs = selector ["contigs.fa"]
