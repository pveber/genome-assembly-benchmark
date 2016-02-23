open Core.Std
open Bistro.Std
open Bistro_bioinfo.Std
open Bistro.EDSL_sh


let package = Bistro.Workflow.make ~descr:"blast.package" [%sh{|
PREFIX={{ dest }}

mkdir -p $PREFIX
cd $PREFIX
wget ftp://ftp.ncbi.nlm.nih.gov/blast/executables/blast+/2.3.0/ncbi-blast-2.3.0+-src.tar.gz
tar xvfz ncbi-blast-2.3.0+-src.tar.gz
cd ncbi-blast-2.3.0+-src/c++

./configure --prefix=$PREFIX --without-vdb
make
make install
cd ..
rm -rf ncbi-blast-2.3.0+-src
|}]

