#!/bin/bash

# Configuration with defaults
MAX_DEPTH=2
SHOW_FILES=true
SHOW_FOLDERS=true
SHOW_PROGRESS=true
PROGRESS_BAR_LENGTH=30
DIR="."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Initialize counters
TOTAL_FILES=0
TOTAL_FOLDERS=0
PROCESSED_ITEMS=0
START_TIME=$(date +%s)

# Function to display help
display_help() {
    echo "Usage: $(basename "$0") [OPTIONS] [DIRECTORY]"
    echo
    echo "Scan and display directory structure with counts."
    echo
    echo "Arguments:"
    echo "  DIRECTORY           Directory to scan (default: current directory)"
    echo
    echo "Options:"
    echo "  -h, --help          Display this help message"
    echo "  -d, --depth NUM     Maximum depth for scanning (default: 2)"
    echo "  -f, --files-only    Show only files in output"
    echo "  -D, --dirs-only     Show only directories in output"
    echo "  -p, --no-progress   Disable progress bar display"
    echo "  -l, --length NUM    Progress bar length (default: 30)"
    echo "  -q, --quiet         Minimal output (no progress, no summary)"
    echo
    echo "Examples:"
    echo "  $(basename "$0")                    # Scan current directory"
    echo "  $(basename "$0") /path/to/dir       # Scan specific directory"
    echo "  $(basename "$0") -d 3 ~/projects    # Scan with depth 3"
    echo "  $(basename "$0") -f -D -d 1         # Show both files and dirs at depth 1"
    echo "  $(basename "$0") -q -d 4            # Quiet mode with depth 4"
    exit 0
}

# Parse command line arguments
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                display_help
                ;;
            -d|--depth)
                if [[ $2 =~ ^[0-9]+$ ]] && [ "$2" -ge 1 ]; then
                    MAX_DEPTH="$2"
                    shift 2
                else
                    echo "Error: Depth must be a positive integer"
                    exit 1
                fi
                ;;
            -f|--files-only)
                SHOW_FILES=true
                SHOW_FOLDERS=false
                shift
                ;;
            -D|--dirs-only)
                SHOW_FILES=false
                SHOW_FOLDERS=true
                shift
                ;;
            -p|--no-progress)
                SHOW_PROGRESS=false
                shift
                ;;
            -l|--length)
                if [[ $2 =~ ^[0-9]+$ ]] && [ "$2" -ge 10 ]; then
                    PROGRESS_BAR_LENGTH="$2"
                    shift 2
                else
                    echo "Error: Progress bar length must be at least 10"
                    exit 1
                fi
                ;;
            -q|--quiet)
                SHOW_PROGRESS=false
                # We'll handle summary suppression later
                shift
                ;;
            --)
                shift
                DIR="$1"
                break
                ;;
            -*)
                echo "Error: Unknown option $1"
                echo "Use --help for usage information"
                exit 1
                ;;
            *)
                # If it's a directory path
                if [[ -d "$1" ]] || [[ "$1" == "." ]] || [[ "$1" == ".." ]]; then
                    DIR="$1"
                else
                    echo "Error: '$1' is not a valid directory"
                    echo "Use --help for usage information"
                    exit 1
                fi
                shift
                ;;
        esac
    done
    
    # Handle quiet mode flag
    QUIET_MODE=false
    for arg in "$@"; do
        if [[ "$arg" == "-q" ]] || [[ "$arg" == "--quiet" ]]; then
            QUIET_MODE=true
            break
        fi
    done
}

# Function to calculate total items
calculate_total_items() {
    local dir="$1"
    local depth="$2"
    local count=0
    
    if [ "$SHOW_FILES" = true ]; then
        count=$((count + $(find "$dir" -maxdepth "$depth" -type f 2>/dev/null | wc -l)))
    fi
    
    if [ "$SHOW_FOLDERS" = true ]; then
        # Subtract 1 to exclude the root directory itself
        count=$((count + $(find "$dir" -maxdepth "$depth" -type d 2>/dev/null | wc -l) - 1))
    fi
    
    echo $count
}

# Function to count files and folders in a directory (up to max depth)
count_items() {
    local dir="$1"
    local max_depth="$2"
    local current_depth="${3:-1}"
    
    local files_count=0
    local folders_count=0
    
    # Count files at current depth
    if [ "$SHOW_FILES" = true ]; then
        files_count=$(find "$dir" -maxdepth 1 -mindepth 1 -type f 2>/dev/null | wc -l)
    fi
    
    # Count folders at current depth
    if [ "$SHOW_FOLDERS" = true ]; then
        folders_count=$(find "$dir" -maxdepth 1 -mindepth 1 -type d 2>/dev/null | wc -l)
    fi
    
    # Recursively count subdirectories if not at max depth
    if [ $current_depth -lt $max_depth ]; then
        while IFS= read -r subdir; do
            if [ -d "$subdir" ]; then
                local sub_counts=$(count_items "$subdir" $max_depth $((current_depth + 1)))
                local sub_files=$(echo "$sub_counts" | cut -d'/' -f1)
                local sub_folders=$(echo "$sub_counts" | cut -d'/' -f2)
                files_count=$((files_count + sub_files))
                folders_count=$((folders_count + sub_folders))
            fi
        done < <(find "$dir" -maxdepth 1 -mindepth 1 -type d 2>/dev/null)
    fi
    
    echo "${files_count}/${folders_count}"
}

# Function to update progress bar (fixed to stay at bottom)
update_progress() {
    if [ "$SHOW_PROGRESS" != true ] || [ $TOTAL_ITEMS -eq 0 ]; then
        return
    fi
    
    local current=$1
    local total=$2
    local eta=$3
    
    # Calculate percentage
    local percent=$((current * 100 / total))
    
    # Calculate progress bar length
    local filled=$((current * PROGRESS_BAR_LENGTH / total))
    local empty=$((PROGRESS_BAR_LENGTH - filled))
    
    # Create progress bar string
    local bar="["
    for ((i=0; i<filled; i++)); do
        bar="${bar}="
    done
    for ((i=0; i<empty; i++)); do
        bar="${bar} "
    done
    bar="${bar}]"
    
    # Format ETA - only show if we have enough data
    local eta_str=""
    if [ $eta -gt 0 ] && [ $current -gt 1 ]; then
        eta_str=$(printf "ETA: %02d:%02d" $((eta/60)) $((eta%60)))
    fi
    
    # Always move to the bottom line and update progress bar
    if [[ -t 1 ]]; then  # Only if stdout is a terminal
        # Move to bottom of terminal
        printf "\033[999;1H"
        
        # Clear the line and print progress bar
        printf "\r\033[2K"  # Clear the entire line
        printf "${CYAN}Progress: %3d%% %s Items: %d/%d %s${NC}" \
            "$percent" "$bar" "$current" "$total" "$eta_str"
        
        # Move cursor back up to where we were printing the tree
        # We need to move up based on how many lines of tree we've printed
        # This is tricky, so instead we'll just print a newline after each tree item
    else
        # For non-terminal output, just print normally with newline
        printf "${CYAN}Progress: %3d%% %s Items: %d/%d %s${NC}\n" \
            "$percent" "$bar" "$current" "$total" "$eta_str"
    fi
}

# Function to format counts - only show if greater than 0
format_counts() {
    local files=$1
    local folders=$2
    local result=""
    
    if [ $files -gt 0 ] && [ $folders -gt 0 ]; then
        result="(files: $files, folders: $folders)"
    elif [ $files -gt 0 ]; then
        result="(files: $files)"
    elif [ $folders -gt 0 ]; then
        result="(folders: $folders)"
    fi
    
    echo "$result"
}

# Function to scan directory (fixed to handle progress bar properly)
scan_directory() {
    local dir="$1"
    local prefix="$2"
    local depth="$3"
    
    if [ $depth -gt $MAX_DEPTH ]; then
        return
    fi
    
    # Get all items in directory
    local items=()
    if [ "$SHOW_FOLDERS" = true ]; then
        while IFS= read -r item; do
            items+=("$item")
        done < <(find "$dir" -maxdepth 1 -mindepth 1 -type d 2>/dev/null | sort)
    fi
    
    if [ "$SHOW_FILES" = true ]; then
        while IFS= read -r item; do
            items+=("$item")
        done < <(find "$dir" -maxdepth 1 -mindepth 1 -type f 2>/dev/null | sort)
    fi
    
    local total_items=${#items[@]}
    local count=0
    
    for item in "${items[@]}"; do
        count=$((count + 1))
        PROCESSED_ITEMS=$((PROCESSED_ITEMS + 1))
        
        # Calculate ETA - fix division by zero and handle edge cases
        local current_time=$(date +%s)
        local elapsed=$((current_time - START_TIME))
        local items_remaining=$((TOTAL_ITEMS - PROCESSED_ITEMS))
        local eta=0
        
        if [ $PROCESSED_ITEMS -gt 0 ] && [ $items_remaining -gt 0 ] && [ $elapsed -gt 0 ]; then
            # Calculate items per second
            local items_per_sec=$((PROCESSED_ITEMS / elapsed))
            if [ $items_per_sec -gt 0 ]; then
                eta=$((items_remaining / items_per_sec))
            fi
        fi
        
        # Update progress bar BEFORE printing tree item
        update_progress $PROCESSED_ITEMS $TOTAL_ITEMS $eta
        
        local name=$(basename "$item")
        local is_last=$([ $count -eq $total_items ] && echo "true" || echo "false")
        
        if [ -d "$item" ]; then
            TOTAL_FOLDERS=$((TOTAL_FOLDERS + 1))
            
            # Count files and folders in this directory (including nested)
            local counts=$(count_items "$item" $MAX_DEPTH $((depth + 1)))
            local file_count=$(echo "$counts" | cut -d'/' -f1)
            local folder_count=$(echo "$counts" | cut -d'/' -f2)
            
            # Format counts (only show if > 0)
            local count_str=$(format_counts $file_count $folder_count)
            
            # Print folder with counts
            printf "${prefix}"
            if [ "$is_last" = "true" ]; then
                printf "└── "
                local new_prefix="${prefix}    "
            else
                printf "├── "
                local new_prefix="${prefix}│   "
            fi
            
            # Only append count string if not empty
            if [ -n "$count_str" ]; then
                printf "${BLUE}%s${NC} %s\n" "$name" "$count_str"
            else
                printf "${BLUE}%s${NC}\n" "$name"
            fi
            
            # Recursively scan subdirectory
            scan_directory "$item" "$new_prefix" $((depth + 1))
            
        elif [ -f "$item" ]; then
            TOTAL_FILES=$((TOTAL_FILES + 1))
            
            # Print file
            printf "${prefix}"
            if [ "$is_last" = "true" ]; then
                printf "└── "
            else
                printf "├── "
            fi
            
            printf "${GREEN}%s${NC}\n" "$name"
        fi
    done
}

# Main execution (updated to handle progress bar at bottom)
parse_arguments "$@"

# Check if directory exists
if [ ! -d "$DIR" ]; then
    echo "Error: Directory '$DIR' does not exist."
    exit 1
fi

# Calculate total items
if [ "$SHOW_PROGRESS" = true ]; then
    echo "Calculating total items..."
fi
TOTAL_ITEMS=$(calculate_total_items "$DIR" $MAX_DEPTH)

# Display configuration (unless quiet mode)
if [ "$QUIET_MODE" = false ]; then
    echo "Scanning directory: $(realpath "$DIR")"
    echo "Max depth level: $MAX_DEPTH"
    echo "Total items to process: $TOTAL_ITEMS"
    echo "Showing:"
    [ "$SHOW_FILES" = true ] && echo "  Files"
    [ "$SHOW_FOLDERS" = true ] && echo "  Folders"
    echo ""
fi

# Print root directory with correct counts
root_name=$(basename "$(realpath "$DIR")")
# Count items in root directory (excluding the root itself)
root_counts=$(count_items "$DIR" $MAX_DEPTH 1)
root_files=$(echo "$root_counts" | cut -d'/' -f1)
root_folders=$(echo "$root_counts" | cut -d'/' -f2)

# Format root counts (only show if > 0)
root_count_str=$(format_counts $root_files $root_folders)

# Print root directory name
printf "${PURPLE}%s${NC}" "$root_name"

# Only append count string if not empty
if [ -n "$root_count_str" ]; then
    printf " %s\n" "$root_count_str"
else
    printf "\n"
fi

# Start with an initial progress bar at 0% at the bottom
if [ "$SHOW_PROGRESS" = true ]; then
    # Make space for the progress bar
    printf "\n"
    update_progress 0 $TOTAL_ITEMS 0
    # Move cursor back up to continue printing tree
    printf "\033[1A"
fi

# Start scanning
scan_directory "$DIR" "" 1

# Final progress update to 100% and clean up
if [ "$SHOW_PROGRESS" = true ]; then
    update_progress $TOTAL_ITEMS $TOTAL_ITEMS 0
    printf "\n"  # Move to the line after progress bar
fi

# Display summary (unless quiet mode)
if [ "$QUIET_MODE" = false ]; then
    echo ""
    echo "Summary:"
    echo "  Total files displayed: $TOTAL_FILES"
    echo "  Total folders displayed: $TOTAL_FOLDERS"
    echo "  Total items processed: $PROCESSED_ITEMS"
fi