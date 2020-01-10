#!/bin/csh

# Form input files for DMPfold from an alignment
# Argument is a text file with a single sequence per line and
#  the ungapped target sequence as the first line

# By David T. Jones, Jun 2018

# Copyright (C) 2018 University College London

# License: GPLv3


# Set the number of CPUs to use for HHblits, PSICOV, FreeContact and CCMpred
set ncpu = 8

# Set this to point to the DMPfold directory
set dmpfolddir = ~/tools/DMPfold

# Set this to point to the CCMpred bin directory
set ccmpreddir = ~/tools/CCMpred/bin

# Set this to point to the FreeContact command
set freecontactcmd = ~/tools/freecontact/bin/freecontact

# Set this to point to the legacy BLAST bin directory
set ncbidir = /bmm/soft/Linux_2.6_64_redhat6/src/blast-2.2.9-amd64-linux

set bindir = $dmpfolddir/bin

set alnfile = $1
set target = $1:t:r

limit stacksize unlimited

echo ">$target" > $target.temp.fasta
head -1 $alnfile >> $target.temp.fasta

$bindir/aln2fasta $alnfile > $target.temp.seqs

$ncbidir/formatdb -i $target.temp.seqs -t $target.temp.seqs

if (! -e $target.temp.solv) then
    echo "Running PSIPRED & SOLVPRED"
    $bindir/runpsipredandsolvwithdb $target.temp.fasta $target.temp.seqs
endif

if (`cat $alnfile | wc -l` >= 5) then
    if (! -e $target.psicov) then
        echo "Running PSICOV"
        $bindir/psicov -z $ncpu -o -d 0.03 $alnfile > $target.psicov
    endif
    if (! -e $target.evfold) then
        echo "Running FreeContact"
        $freecontactcmd -a $ncpu < $alnfile > $target.evfold
    endif
    if (! -e $target.ccmpred) then
        echo "Running CCMpred"
        $ccmpreddir/ccmpred -t $ncpu $alnfile $target.ccmpred
    endif
else
    echo "Fewer than 5 sequences in alignment, not running PSICOV/FreeContact/CCMpred"
    \rm -f $target.psicov $target.evfold $target.ccmpred
    touch $target.psicov $target.evfold $target.ccmpred
endif

echo "Forming DMPfold input files"
$bindir/alnstats $alnfile $target.colstats $target.pairstats

$bindir/dmp_makepredmaps $target.colstats $target.pairstats $target.psicov $target.evfold $target.ccmpred $target.temp.ss2 $target.temp.solv $target.map $target.fix

$bindir/cov21stats $alnfile $target.21c
