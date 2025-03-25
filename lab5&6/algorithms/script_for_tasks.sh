#!/bin/bash

# Create directories for parallel logs if they don't exist
parLogDir="Tpar_logs"
[ ! -d "$parLogDir" ] && mkdir -p "$parLogDir"

parDir="Tpar"
[ ! -d "$parDir" ] && mkdir -p "$parDir"

# Define arrays for number of workers and distribution modes
workers=(1 "auto")
distModes=("load" "no")

# Run parallel tests using pytest-xdist (removing --parallel-threads)
for w in "${workers[@]}"; do
    for d in "${distModes[@]}"; do
        echo "Running: -n $w --dist $d"
        
        for i in {1..3}; do
            # Use the time command to measure execution time, and tee to log output
            { time python -m pytest -n "$w" --dist="$d" | tee "$parLogDir/par_run_${w}_${d}_${i}.log"; } 2>&1 | tee "$parDir/par_run_${w}_${d}_${i}.log"
        done
    done
done

# Create a directory for sequential test logs if it doesn't exist
seqLogDir="Tseq_logs"
[ ! -d "$seqLogDir" ] && mkdir -p "$seqLogDir"

# Run the test suite sequentially 10 times
for i in {1..10}; do
    echo "Running sequential test iteration $i..."
    
    { time python -m pytest | tee "$seqLogDir/seq_run_$i.log"; } 2>&1 | tee "$seqLogDir/seq_time_$i.log"
done

echo "Sequential test execution completed."
