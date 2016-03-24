open Core.Std
open Bistro.Std
open Bistro_bioinfo.Std
open Bistro.EDSL_sh

let package = {
  Bistro.pkg_name = "cisa" ;
  pkg_version = "20140304" ;
}

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
  workflow ~descr:"cisa.Merge" ~pkgs:[package] [
    mkdir_p tmp ;
    heredoc ~dest:config_file_path config_file ;
    cmd "Merge.py" [ config_file_path ] ;
  ]

let which prg =
  let cmd = "which " ^ prg in
  let ic = Unix.open_process_in cmd in
  match In_channel.input_line ic with
  | None -> failwithf "Could not find %s in $PATH" prg ()
  | Some p -> p

let cisa genome_size contigs =
  Bistro.Workflow.make ~descr:"cisa" [%bash{|
NUCMER=`which nucmer`
CISA=$(dirname $(readlink -f $(which CISA.py)))
MAKEBLASTDB=`which makeblastdb`
BLASTN=`which blastn`
CONFIG={{ tmp }}/cisa.config

mkdir -p {{ tmp }}
mkdir -p {{ tmp }}/CISA1

cat > $CONFIG <<__HEREDOC__
genome={{ int genome_size }}
infile={{ dep contigs }}
outfile={{ dest }}
nucmer=$NUCMER
R2_Gap=0.95
CISA=$CISA
makeblastdb=$MAKEBLASTDB
blastn=$BLASTN
__HEREDOC__

yes | CISA.py $CONFIG
|}]
