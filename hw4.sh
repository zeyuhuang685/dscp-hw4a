#!/bin/bash

set -e

tgzfile=$1
template=$2

dirname=$(basename "$tgzfile" .tgz)

echo "Starting job"
echo "pwd:"
pwd
echo "input tgz: $tgzfile"
echo "template: $template"

echo "Checking R..."
which R || true
which Rscript || true
R --version || true
Rscript --version || true

echo "Files before untar:"
ls -lh

tar xzf "$tgzfile"

echo "Files after untar:"
ls -lh
echo "First few files in $dirname:"
ls "$dirname" | head || true

Rscript hw4.R "$template" "$dirname"

echo "Done"
echo "Output csv files:"
ls -lh *.csv
