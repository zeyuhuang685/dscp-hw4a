#!/bin/bash
cat 3586.csv 3587.csv 3588.csv 3589.csv 3590.csv | sort -t, -k1,1g | head -100 > hw4best100.csv
