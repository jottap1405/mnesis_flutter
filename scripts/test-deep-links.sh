#!/bin/bash

# Mnesis Flutter - Android Deep Link Testing Script
# This script helps test deep links on Android devices/emulators

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Package name
PACKAGE="com.mnesis.mnesis_flutter"

echo -e "${GREEN}==================================${NC}"
echo -e "${GREEN}Mnesis Deep Link Testing Script${NC}"
echo -e "${GREEN}==================================${NC}\n"

# Check if ADB is available
if ! command -v adb &> /dev/null; then
    echo -e "${RED}Error: ADB is not installed or not in PATH${NC}"
    echo "Please install Android SDK Platform Tools"
    exit 1
fi

# Check if device is connected
DEVICE_COUNT=$(adb devices | grep -c device$)
if [ "$DEVICE_COUNT" -eq 0 ]; then
    echo -e "${RED}Error: No Android device/emulator connected${NC}"
    echo "Please connect a device or start an emulator"
    exit 1
fi

# Check if app is installed
if ! adb shell pm list packages | grep -q "$PACKAGE"; then
    echo -e "${YELLOW}Warning: App not found on device${NC}"
    echo "Package: $PACKAGE"
    echo "Please install the app first using: flutter run"
    exit 1
fi

echo -e "${GREEN}Device connected and app installed!${NC}\n"

# Function to test a deep link
test_link() {
    local scheme=$1
    local description=$2

    echo -e "${YELLOW}Testing: $description${NC}"
    echo "URL: $scheme"

    # Launch the deep link
    adb shell am start -W -a android.intent.action.VIEW -d "$scheme" "$PACKAGE" > /dev/null 2>&1

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Success${NC}\n"
    else
        echo -e "${RED}✗ Failed${NC}\n"
    fi

    sleep 1
}

# Test menu
while true; do
    echo -e "${GREEN}Choose a test option:${NC}"
    echo "1) Test all custom scheme links (mnesis://)"
    echo "2) Test all HTTPS app links (https://mnesis.app)"
    echo "3) Test individual link"
    echo "4) Clear app defaults"
    echo "5) View app link verification status (Android 12+)"
    echo "6) Exit"
    echo -n "Enter choice [1-6]: "
    read choice

    case $choice in
        1)
            echo -e "\n${GREEN}Testing Custom Scheme Links${NC}\n"
            test_link "mnesis://chat" "Chat Screen (Custom Scheme)"
            test_link "mnesis://new" "New Consultation (Custom Scheme)"
            test_link "mnesis://operation" "Operation Screen (Custom Scheme)"
            test_link "mnesis://admin" "Admin Screen (Custom Scheme)"
            ;;
        2)
            echo -e "\n${GREEN}Testing HTTPS App Links${NC}\n"
            test_link "https://mnesis.app/chat" "Chat Screen (HTTPS)"
            test_link "https://mnesis.app/new" "New Consultation (HTTPS)"
            test_link "https://mnesis.app/operation" "Operation Screen (HTTPS)"
            test_link "https://mnesis.app/admin" "Admin Screen (HTTPS)"
            ;;
        3)
            echo "Enter the full deep link URL:"
            echo "Examples:"
            echo "  - mnesis://chat"
            echo "  - https://mnesis.app/operation"
            echo -n "URL: "
            read url
            test_link "$url" "Custom Link"
            ;;
        4)
            echo -e "\n${YELLOW}Clearing app defaults...${NC}"
            adb shell pm clear-defaults "$PACKAGE"
            echo -e "${GREEN}Defaults cleared${NC}\n"
            ;;
        5)
            echo -e "\n${YELLOW}Checking app link verification status...${NC}"
            adb shell pm get-app-links "$PACKAGE"
            echo ""
            ;;
        6)
            echo -e "${GREEN}Goodbye!${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid option. Please try again.${NC}\n"
            ;;
    esac
done