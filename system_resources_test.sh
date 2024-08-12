#!/bin/bash

# Set thresholds
MEMORY_THRESHOLD=90  # in percentage
CPU_THRESHOLD=60     # in percentage
DISK_THRESHOLD=70    # in percentage

# Initialize a flag to track if any threshold is exceeded
THRESHOLD_EXCEEDED=0

# Function to check memory usage
check_memory() {
    # Step 1: Calculate the percentage of memory used.
    # - 'free' command provides information about memory usage (total, used, free, etc.).
    # - 'grep Mem' filters the output to get the line with memory usage details.
    # - 'awk' calculates the percentage of memory used by dividing used memory ($3) by total memory ($2) and multiplying by 100.
    # $2: Refers to the second column in the filtered line, which typically represents the total memory.
    # $3: Refers to the third column in the filtered line, which typically represents the used memory.
    MEMORY_USED=$(free | grep Mem | awk '{print $3/$2 * 100.0}')
    
    # Step 2: Convert the floating-point memory usage percentage to an integer.
    # - 'printf "%.0f"' formats the floating-point number to zero decimal places, effectively rounding it.
    # - The result is stored in the MEMORY_INT variable.
    MEMORY_INT=$(printf "%.0f" "$MEMORY_USED")
    
    # Step 3: Compare the current memory usage with the threshold.
    # - The if statement checks if the memory usage percentage (MEMORY_INT) is greater than or equal to the defined threshold (MEMORY_THRESHOLD).
    if [ "$MEMORY_INT" -ge "$MEMORY_THRESHOLD" ]; then
        # Step 4a: If memory usage exceeds the threshold, print a warning message.
        # - The message includes the current memory usage percentage and the threshold value.
        echo "Warning: Memory usage is at ${MEMORY_INT}% (Threshold: ${MEMORY_THRESHOLD}%)"
        
        # Step 5: Set a flag indicating that the threshold has been exceeded.
        # - THRESHOLD_EXCEEDED is set to 1, which could be used elsewhere in the script to take further action.
        THRESHOLD_EXCEEDED=1
    else
        # Step 4b: If memory usage is below the threshold, print a normal status message.
        # - The message indicates the current memory usage percentage.
        echo "Memory usage is at ${MEMORY_INT}%"
    fi
}

# Function to check CPU usage
check_cpu() {
    # Step 1: Calculate the CPU load percentage by processing the output of the 'top' command.
    # - 'top -bn1' runs the 'top' command in batch mode ('-b') with no delay ('-n1'), producing a snapshot of the system's CPU usage.
    # - 'grep "Cpu(s)"' extracts the line that contains information about CPU usage.
    # - 'sed "s/.*, *\([0-9.]*\)%* id.*/\1/"' uses a 'sed' command to isolate the percentage of CPU idle time ('id') from the extracted line:
    #     - 's/.*, *\([0-9.]*\)%* id.*/\1/' is a substitution pattern:
    #         - It matches everything before the idle percentage ('.*,'), followed by the idle percentage itself ('\([0-9.]*\)%* id').
    #         - The matched idle percentage is captured in '\1'.
    #         - The 'sed' command replaces the entire line with just the captured idle percentage.
    # - 'awk '{print 100 - $1}'' calculates the CPU load by subtracting the idle percentage from 100.
    #     - '$1' refers to the idle percentage extracted by 'sed'.
    #     - The result is the percentage of CPU load (i.e., how much of the CPU is being used).
    CPU_LOAD=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
    CPU_INT=$(printf "%.0f" "$CPU_LOAD")

    if [ "$CPU_INT" -ge "$CPU_THRESHOLD" ]; then
        echo "Warning: CPU usage is at ${CPU_INT}% (Threshold: ${CPU_THRESHOLD}%)"
        THRESHOLD_EXCEEDED=1
    else
        echo "CPU usage is at ${CPU_INT}%"
    fi
}

# Function to check disk space usage
check_disk() {
    # Step 1: Check the disk usage percentage for the root filesystem (/).
    # - 'df /' runs the 'df' command to report the disk space usage for the root filesystem ('/').
    #     - 'df' provides information such as the total size, used space, available space, and usage percentage of filesystems.
    # - 'grep /' filters the output to get the line that contains information specifically for the root filesystem ('/').
    #     - This ensures that we're only working with the relevant data for the root partition.
    # - 'awk '{ print $5 }'' extracts the fifth field from the filtered line, which represents the disk usage percentage.
    #     - The fifth field in 'df' output typically contains the percentage of disk space used (e.g., '45%').
    # - 'sed 's/%//g'' removes the percentage sign (%) from the extracted value.
    #     - 's/%//g' is a 'sed' substitution command that replaces the '%' character with nothing (i.e., deletes it).
    #     - The 'g' at the end ensures that all occurrences of '%' are removed, though in this case, there should only be one.
    # - The final result is stored in the DISK_USED variable as a numeric value representing the disk usage percentage for the root filesystem.
    DISK_USED=$(df / | grep / | awk '{ print $5}' | sed 's/%//g')
    
    if [ "$DISK_USED" -ge "$DISK_THRESHOLD" ]; then
        echo "Warning: Disk usage is at ${DISK_USED}% (Threshold: ${DISK_THRESHOLD}%)"
        THRESHOLD_EXCEEDED=1
    else
        echo "Disk usage is at ${DISK_USED}%"
    fi
}


# Main script
echo "Checking system resources..."
sleep 5
check_cpu
check_memory
check_disk

# Exit with code 0 if all is well, or 1 if any threshold is exceeded
if [ "$THRESHOLD_EXCEEDED" -eq 1 ]; then
    exit 1
else
    exit 0
fi