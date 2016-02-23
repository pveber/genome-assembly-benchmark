open Core.Std
open Bistro.Std
open Bistro_bioinfo.Std
open Bistro.EDSL_sh


(* THIS INSTALL SCRIPT IS WRONG AND SHOULD BE REWORKED AFTER
   ENHANCEMENT IN BISTRO

   This ugly install script is made necessary by the way the package
   works. In particular, you can read in the INSTALL file that:

   "make install"

   This command will build the appropriate scripts and binaries in the
   current directory. Refer to the "README" file in this directory for
   further assistance, or the "docs" directory for detailed information
   on the various utilities.  To make all of the scripts and executables
   accessible from different directories, simply add the full MUMmer
   directory path to your system PATH, or link the desired MUMmer
   programs to your favorite bin directory. Please note that the 'make'
   command dynamically generates the MUMmer scripts with the appropriate
   paths, therefore if the MUMmer directory is moved after the 'make'
   command is issued, the scripts will fail to run. If the MUMmer
   executables are needed in a directory other than the install
   directory, it is recommended that the install directory be left
   untouched and its files linked to the desired destination. An
   alternative would be to move the install directory and reissue the
   'make' command at the new location.
*)

let package = Bistro.Workflow.make ~descr:"spades.package" [%sh{|
PREFIX={{ dest }}

set -e
mkdir -p $PREFIX
cd $PREFIX
wget http://downloads.sourceforge.net/project/mummer/mummer/3.23/MUMmer3.23.tar.gz
tar xvfz MUMmer3.23.tar.gz
mv MUMmer3.23 bin
cd bin

make
for f in `find . -type f`; do
  sed -i 's|/_bistro/build/|/_bistro/cache/|g' $f;
done
|}]
