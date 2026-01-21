#!/bin/bash

# Test iOS Deep Links Script
# This script tests all configured deep links on iOS simulator

echo "======================================"
echo "iOS Deep Link Testing Script"
echo "======================================"
echo ""

# Function to test a deep link
test_link() {
    local url=$1
    local description=$2

    echo "Testing: $description"
    echo "URL: $url"
    xcrun simctl openurl booted "$url"
    echo "✓ Command sent"
    echo "---"

    # Wait a bit between tests
    sleep 2
}

echo "Testing Custom URL Scheme (mnesis://)"
echo "======================================"
test_link "mnesis://chat" "Chat Screen"
test_link "mnesis://new" "New Operation Screen"
test_link "mnesis://operation" "Operation List Screen"
test_link "mnesis://admin" "Admin Screen"

echo ""
echo "Testing Universal Links (https://)"
echo "======================================"
test_link "https://mnesis.app/chat" "Chat Screen (Universal Link)"
test_link "https://mnesis.app/new" "New Operation Screen (Universal Link)"
test_link "https://mnesis.app/operation" "Operation List Screen (Universal Link)"
test_link "https://mnesis.app/admin" "Admin Screen (Universal Link)"

echo ""
echo "======================================"
echo "Testing Complete!"
echo "======================================"
echo ""
echo "Notes:"
echo "- Make sure the iOS Simulator is running with the app installed"
echo "- For Universal Links to work in production, the AASA file must be hosted"
echo "- Check the app to verify each link navigated to the correct screen"