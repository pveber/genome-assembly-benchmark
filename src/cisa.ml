open Core.Std
open Bistro.Std
open Bistro_bioinfo.Std
open Bistro.EDSL_sh


let package = Bistro.Workflow.make ~descr:"cisa.package" [%sh{|
PREFIX={{ dest }}

set -e
mkdir -p $PREFIX/bin
cd $PREFIX
wget http://sb.nhri.org.tw/CISA/upload/en/2014/3/CISA_20140304-05194132.tar
tar xvf CISA_20140304-05194132.tar
cd CISA1.3
cp *.py ../bin

cd ..
rm -f CISA_20140304-05194132.tar
|}]

type cisa_output = [`cisa_output] directory

let merge ?(min_length = 100) xs =
  let config_line (label, fa) =
    [
      string "data=" ; dep fa ;
      string ",title=" ; string label ;
    ]
  in
  let config_file_path = tmp // "merge.config" in
  let config_file =
    List.intersperse ~sep:[string "\n"] (
      [ string "count=" ; int (List.length xs) ]
      :: List.map xs ~f:config_line
      @
      [string "Master_file=" ; dest]
      :: [string "min_length=" ; int min_length]
      :: []
    )
    |> List.concat
    |> seq ~sep:""
  in
  workflow [
    mkdir_p tmp ;
    heredoc ~dest:config_file_path config_file ;
    cmd "Merge.py" ~path:[package] [ config_file_path ] ;
  ]

let cisa genome_size contigs =
  let config_file =
    List.intersperse ~sep:[string "\n"] [
      [ string "genome=" ; int genome_size ] ;
      [ string "infile=" ; dep contigs ] ;
      [ string "outfile=" ; dest] ;
      [ string "nucmer=" ; dep Mummer.package // "bin/nucmer" ] ;
      [ string "R2_Gap=0.95" ] ;
      [ string "CISA=" ; dep package // "CISA1.3" ] ;
      [ string "makeblastdb=" ; dep Blast.package // "bin/makeblastdb" ] ;
      [ string "blastn=" ; dep Blast.package // "bin/blastn" ] ;
    ]
    |> List.concat
    |> seq ~sep:""
  in
  let config_file_path = tmp // "cisa.config" in
  workflow [
    mkdir_p tmp ;
    cd tmp ;
    mkdir_p (tmp // "CISA1") ;
    heredoc ~dest:config_file_path config_file ;
    cmd ""
      ~path:[package;Mummer.package;Blast.package]
      [ string "yes | CISA.py" ; config_file_path ] ;
  ]
