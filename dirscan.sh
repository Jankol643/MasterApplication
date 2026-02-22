#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Default values
SHOW_FILES=true
SHOW_FOLDERS=true
SHOW_COUNTS=true
MAX_LEVEL=2
TARGET_DIR="."

# Function to display usage
show_usage() {
    echo -e "${BOLD}Usage:${NC} $0 [OPTIONS]"
    echo ""
    echo -e "${BOLD}Options:${NC}"
    echo "  -d, --directory PATH    Directory to scan (default: current directory)"
    echo "  -l, --level NUM         Maximum depth level (default: 2)"
    echo "  -f, --files-only        Show only files"
    echo "  -o, --folders-only      Show only folders"
    echo "  -c, --no-counts         Disable file/folder counts"
    echo "  -h, --help              Show this help message"
    echo ""
    echo -e "${BOLD}Examples:${NC}"
    echo "  $0 -d /home/user -l 3          # Scan /home/user up to 3 levels deep"
    echo "  $0 --files-only --level 4      # Show only files up to 4 levels"
    echo "  $0 --folders-only --no-counts  # Show only folders without counts"
}

# Function to display progress bar
show_progress() {
    local current=$1
    local total=$2
    local width=50
    local percentage=$((current * 100 / total))
    local filled=$((current * width / total))
    local empty=$((width - filled))
    
    printf "\r${CYAN}["
    printf "%${filled}s" | tr ' ' '='
    printf "%${empty}s" | tr ' ' ' '
    printf "] ${percentage}%%${NC}"
}

# Function to count files and folders in a directory
count_items() {
    local dir="$1"
    local file_count=0
    local folder_count=0
    
    if [[ -d "$dir" ]]; then
        # Count files (excluding . and ..)
        if $SHOW_FILES; then
            file_count=$(find "$dir" -maxdepth 1 -type f 2>/dev/null | wc -l)
        fi
        
        # Count folders (excluding . and ..)
        if $SHOW_FOLDERS; then
            folder_count=$(find "$dir" -maxdepth 1 -type d 2>/dev/null | wc -l)
            folder_count=$((folder_count - 1)) # Subtract current directory
        fi
    fi
    
    echo "$file_count $folder_count"
}

# Function to list directory contents
list_directory() {
    local current_dir="$1"
    local level="$2"
    local prefix="$3"
    local is_last="$4"
    
    # Get counts for current directory
    local counts
    counts=$(count_items "$current_dir")
    local file_count=$(echo "$counts" | awk '{print $1}')
    local folder_count=$(echo "$counts" | awk '{print $2}')
    
    # Display current directory with optional counts
    if $SHOW_COUNTS; then
        printf "${BOLD}${BLUE}%s%s${NC}" "$prefix" "$(basename "$current_dir")"
        if $SHOW_FILES && $SHOW_FOLDERS; then
            printf " ${GREEN}(files: ${file_count}, folders: ${folder_count})${NC}\n"
        elif $SHOW_FILES; then
            printf " ${GREEN}(files: ${file_count})${NC}\n"
        elif $SHOW_FOLDERS; then
            printf " ${GREEN}(folders: ${folder_count})${NC}\n"
        fi
    else
        printf "${BOLD}${BLUE}%s%s${NC}\n" "$prefix" "$(basename "$current_dir")"
    fi
    
    # Stop if we've reached max level
    if [[ $level -ge $MAX_LEVEL ]]; then
        return
    fi
    
    # Get list of items to process
    local items=()
    if $SHOW_FOLDERS && $SHOW_FILES; then
        # Both files and folders
        mapfile -t items < <(find "$current_dir" -maxdepth 1 ! -path "$current_dir" ! -name ".*" 2>/dev/null | sort)
    elif $SHOW_FOLDERS; then
        # Only folders
        mapfile -t items < <(find "$current_dir" -maxdepth 1 -type d ! -path "$current_dir" ! -name ".*" 2>/dev/null | sort)
    elif $SHOW_FILES; then
        # Only files
        mapfile -t items < <(find "$current_dir" -maxdepth 1 -type f ! -name ".*" 2>/dev/null | sort)
    fi
    
    local total_items=${#items[@]}
    local processed=0
    
    for item in "${items[@]}"; do
        processed=$((processed + 1))
        
        # Update progress bar for current level
        if [[ $level -eq 0 ]]; then
            show_progress $processed $total_items
        fi
        
        local new_prefix="$prefix"
        if [[ "$is_last" == "true" ]]; then
            new_prefix="${prefix}    "
        else
            new_prefix="${prefix}│   "
        fi
        
        local item_prefix
        if [[ $processed -eq $total_items ]]; then
            item_prefix="└── "
            local next_is_last="true"
        else
            item_prefix="├── "
            local next_is_last="false"
        fi
        
        if [[ -d "$item" ]]; then
            # It's a directory
            if $SHOW_FOLDERS; then
                list_directory "$item" $((level + 1)) "${prefix}${item_prefix}" "$next_is_last"
            fi
        else
            # It's a file
            if $SHOW_FILES; then
                printf "${YELLOW}%s%s${NC}\n" "${prefix}${item_prefix}" "$(basename "$item")"
            fi
        fi
    done
    
    # Clear progress bar line after completion
    if [[ $level -eq 0 ]] && [[ $total_items -gt 0 ]]; then
        printf "\r%${COLUMNS}s\r"
    fi
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -d|--directory)
            TARGET_DIR="$2"
            shift 2
            ;;
        -l|--level)
            MAX_LEVEL="$2"
            if ! [[ "$MAX_LEVEL" =~ ^[0-9]+$ ]]; then
                echo -e "${RED}Error: Level must be a positive integer${NC}"
                exit 1
            fi
            shift 2
            ;;
        -f|--files-only)
            SHOW_FILES=true
            SHOW_FOLDERS=false
            shift
            ;;
        -o|--folders-only)
            SHOW_FILES=false
            SHOW_FOLDERS=true
            shift
            ;;
        -c|--no-counts)
            SHOW_COUNTS=false
            shift
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            show_usage
            exit 1
            ;;
    esac
done

# Validate directory
if [[ ! -d "$TARGET_DIR" ]]; then
    echo -e "${RED}Error: Directory '$TARGET_DIR' does not exist${NC}"
    exit 1
fi

# Get absolute path
TARGET_DIR=$(realpath "$TARGET_DIR")

# Calculate total files and folders for summary
echo -e "${PURPLE}Scanning directory:${NC} ${BOLD}$TARGET_DIR${NC}"
echo -e "${PURPLE}Max depth level:${NC} ${BOLD}$MAX_LEVEL${NC}"
echo -e "${PURPLE}Showing:${NC} ${BOLD}"
if $SHOW_FILES && $SHOW_FOLDERS; then
    echo "  Files and Folders"
elif $SHOW_FILES; then
    echo "  Files only"
elif $SHOW_FOLDERS; then
    echo "  Folders only"
fi
echo -e "${NC}"

# Start scanning
echo -e "${CYAN}Scanning...${NC}"
list_directory "$TARGET_DIR" 0 "" "true"

# Summary counts
echo -e "\n${BOLD}${PURPLE}Summary:${NC}"
echo -e "${PURPLE}════════════════════════════════════════════════════════════════${NC}"

if $SHOW_FILES; then
    total_files=$(find "$TARGET_DIR" -maxdepth "$MAX_LEVEL" -type f 2>/dev/null | wc -l)
    echo -e "${GREEN}Total files found:${NC} ${BOLD}$total_files${NC}"
fi

if $SHOW_FOLDERS; then
    total_folders=$(find "$TARGET_DIR" -maxdepth "$MAX_LEVEL" -type d 2>/dev/null | wc -l)
    total_folders=$((total_folders - 1)) # Subtract root directory
    echo -e "${GREEN}Total folders found:${NC} ${BOLD}$total_folders${NC}"
fi

echo -e "${PURPLE}════════════════════════════════════════════════════════════════${NC}"