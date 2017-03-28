#!/bin/bash

#------------------------------------------------------------------------------
#                  GEOS-Chem Global Chemical Transport Model                  !
#------------------------------------------------------------------------------
#BOP
#
# !MODULE: initialSetup.sh
# 
# !DESCRIPTION: Sets up symbolic links to data required by GCHP.
#\\
#\\
# !REMARKS:
#  (1) Use upon first time setup of the run directory.  
#  (2) Subsequent usage requires deletion of the following symbolic links
#         CodeDir
#         MainDataDir
#         MetDir
#         RestartsDir
#         ChemDataDir
#         TileFiles
#
# !REVISION HISTORY: 
#  Navigate to your unit tester directory and type 'gitk' at the prompt
#  to browse the revision history.
#EOP
#------------------------------------------------------------------------------
#BOC
# First time setup script - run only once!

# Check whether symlinks for source code, met, hemco, chem, and restarts 
# already are set. If yes then exist since setup is not necessary. 
if [[ -L CodeDir && -L MainDataDir && -L MetDir && -L ChemDataDir && -L TileFiles ]] ; then
  echo "Symbolic links already set up"
  exit 1
fi

# Prompt the user for source code directory and set symlink
read -p "Enter path to code directory:" codePath
if [[ ! -d ${codePath} ]]; then
  echo "Directory ${codePath} does not exist"
  exit 1
fi
ln -s ${codePath} CodeDir

# Define the restart filename stored on gcgrid
RestartsFile="initial_GEOSChem_rst.c24_gchp.nc"

# Define tile file needed to regrid Olson landmap and MODIS LAI to c24 (~4x5)
tileFile=DE1440xPE0720_CF0024x6C.bin

# Prompt the user on whether using Odyssey (Harvard)
read -p "Are you on Odyssey [y/n]? " onOdyssey

# Automatically set met, hemco, chem, and restart paths if on Odyssey,
# and ask the user what input met resolution to use.
onOdyssey=$( echo "${onOdyssey}" | tr '[:upper:]' '[:lower:]' )
if [[ ${onOdyssey} == "y" ]]; then
  baseDir='/n/holylfs/EXTERNAL_REPOS/GEOS-CHEM/gcgrid'
  MetDir=$baseDir
  MainDataDir="$baseDir/data/ExtData/HEMCO"
  RestartsDir="$baseDir/data/ExtData/SPC_RESTARTS"
  ChemDataDir="$baseDir/gcdata/ExtData/CHEM_INPUTS"
  TileFileDir="$baseDir/gcdata/ExtData/GCHP/TileFiles"
  MetDir=${baseDir}/GEOS_2x2.5_GEOS_5/GEOS_FP
  # On Odyssey, remove the safety check - holylfs is only visible off the login nodes
  checkPath=0

# If not on Odyssey, ask the user for the paths
elif [[ ${onOdyssey} == "n" ]]; then
  read -p "Enter path containing met data: " MetDir
  read -p "Enter path to HEMCO data directory: " MainDataDir
  read -p "Enter path to GEOS-Chem restart files: " RestartsDir
  read -p "Enter path to CHEM_INPUTS directory: " ChemDataDir
  read -p "Enter path to tile files: " TileFileDir
  checkPath=1
else
  echo "Invalid response given"
  unlink CodeDir
  exit 1
fi

# Check if the target paths exist (if not on Odyssey)
if [[ $checkPath -eq 1 ]]; then
  pathOK=0
  if [[ -d ${MetDir} && -d ${MainDataDir} && -d ${RestartsDir} && -d ${ChemDataDir} && -d ${TileFileDir} ]]; then
    pathOK=1
  fi
else
  # On Odyssey, assume the paths are OK
  pathOK=1
fi

# Set symlinks based on the paths set above
if [[ $pathOK -eq 1 ]]; then
  ln -s ${MetDir} MetDir
  ln -s ${MainDataDir} MainDataDir
  ln -s ${RestartsDir}/${RestartsFile} ${RestartsFile}
  ln -s ${ChemDataDir} ChemDataDir
  ln -s ${TileFileDir} TileFiles
else
  echo "Could not find target directories"
  unlink CodeDir
  exit 1
fi

echo " "
echo "IMPORTANT NOTES: You must now set up your environment, compile, and run" 
echo " "
echo "  (1) ENVIRONMENT: You must set up your environment by sourcing a "
echo "bashrc file. Sample bashrc files compatible with Harvard's Odyssey "
echo "Compute Cluster and Dalhousie's ACENET Glooscap cluster are included"
echo "in this run directory. If you are on a different system, you may use"
echo "them as a guide to customize a bashrc compatible with your local "
echo "system. If you clean and compile with build.sh, or with any make"
echo "commands that call build.sh, then you will be guided through the"
echo "process of setting up your environment."
echo " "
echo "  (2) COMPILE: Compile using one of the make commands defined in the"
echo "Makefile which calls build.sh, or use build.sh directly. Enter"
echo "'make help' or './build.sh help' for options."
echo " "
echo "  (3) RUN: Sample run scripts for SLURM and Grid Engine schedulers"
echo "are included in this directory. The scripts are GCHP_slurm.run and"
echo "and GCHP_gridengine.run. GCHP_slurm.run is configured for use"
echo "on Harvard's Odyssey cluster and GCHP_gridengine.run for use on"
echo "Dalhousie's Glooscap cluster. These may be helpful in creating"
echo "a run script for your own system. Beware that the bashrc is"
echo "hard-coded in the run scripts and you should check and edit as"
echo "needed prior to submitting."
echo " "
echo "Thank you for using the GCHP Dev Kit! Please send any comments, issues,"
echo "or questions to Lizzie Lundgren at elundgren@seas.harvard.edu"

exit 0
