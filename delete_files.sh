#!/bin/bash

# Define the list of specific files to delete
FILES_TO_DELETE=(
    "generated_for_cpu.c"
    "testbench.c"
    "top_level.c"
    "test_cpu"
    "top_level.v"
)

echo "Starting deletion process..."

# 1. Delete specific files from the list
for FILE in "${FILES_TO_DELETE[@]}"; do
    if [ -f "$FILE" ]; then
        rm "$FILE"
        echo "Successfully deleted: $FILE"
    else
        echo "Skip: $FILE does not exist."
    fi
done

# 2. Delete all .xml files in the current directory
if ls *.xml >/dev/null 2>&1; then
    rm *.xml
    echo "Successfully deleted all .xml files."
else
    echo "No .xml files found to delete."
fi

echo "Done."
