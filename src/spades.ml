open Core.Std
open Bistro.Std
open Bistro_bioinfo.Std
open Bistro.EDSL_sh


let package = Bistro.Workflow.make ~descr:"spades.package" [%sh{|
PREFIX={{ dest }}

set -e
mkdir -p $PREFIX
cd $PREFIX
wget http://spades.bioinf.spbau.ru/release3.6.2/SPAdes-3.6.2.tar.gz
tar xvfz SPAdes-3.6.2.tar.gz
cd SPAdes-3.6.2
sed -i 's/make -j 8/make/g' spades_compile.sh
./spades_compile.sh
cp -r bin ..
cp -r share ..
cd ..
rm -rf SPAdes-3.6.2*
|}]

let pe_args (ones, twos) =
  let opt side i x =
    opt (sprintf "--pe%d-%d" (i + 1) side) dep x
  in
  seq ~sep:" " (
    List.mapi ones ~f:(opt 1)
    @
    List.mapi twos ~f:(opt 2)
  )

type spades_output = [`spades_output] directory

let spades
    ?single_cell ?iontorrent
    ?pe
    ()
  : spades_output workflow
  =
  workflow ~descr:"spades" [
    mkdir_p dest ;
    cmd ~path:[package] "spades.py" [
      option (flag string "--sc") single_cell ;
      option (flag string "--iontorrent") iontorrent ;
      option pe_args pe ;
      opt "-o" ident dest ;
    ]
  ]

let contigs = selector ["contigs.fasta"]
let scaffolds = selector ["scaffolds.fasta"]
