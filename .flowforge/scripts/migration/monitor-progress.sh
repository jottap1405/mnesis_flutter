#!/bin/bash

# FlowForge v2.0 Migration Progress Monitor
# Real-time monitoring for Monday's deployment

set -e

# Configuration
MIGRATION_LOG="/tmp/flowforge-migration.log"
STATUS_FILE="/tmp/flowforge-migration-status.json"
MONITOR_INTERVAL=1
DASHBOARD_PORT=8080

# Color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Function to display the dashboard
display_dashboard() {
    clear
    echo -e "${CYAN}═══════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}     FlowForge v2.0 Migration Monitor${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════${NC}"
    echo ""
    
    if [[ -f "$STATUS_FILE" ]]; then
        local status=$(jq -r '.status' "$STATUS_FILE" 2>/dev/null || echo "unknown")
        local progress=$(jq -r '.progress' "$STATUS_FILE" 2>/dev/null || echo "0")
        local current_task=$(jq -r '.current_task' "$STATUS_FILE" 2>/dev/null || echo "Idle")
        local sessions=$(jq -r '.sessions_processed' "$STATUS_FILE" 2>/dev/null || echo "0")
        local tasks=$(jq -r '.tasks_processed' "$STATUS_FILE" 2>/dev/null || echo "0")
        local errors=$(jq -r '.errors' "$STATUS_FILE" 2>/dev/null || echo "0")
        local start_time=$(jq -r '.start_time' "$STATUS_FILE" 2>/dev/null || echo "N/A")
        local eta=$(jq -r '.eta' "$STATUS_FILE" 2>/dev/null || echo "Calculating...")
        
        # Status indicator
        case "$status" in
            "running")
                echo -e "Status: ${GREEN}● RUNNING${NC}"
                ;;
            "error")
                echo -e "Status: ${RED}● ERROR${NC}"
                ;;
            "complete")
                echo -e "Status: ${GREEN}✓ COMPLETE${NC}"
                ;;
            *)
                echo -e "Status: ${YELLOW}○ WAITING${NC}"
                ;;
        esac
        
        echo ""
        
        # Progress bar
        echo -n "Progress: ["
        local bar_length=40
        local filled=$((progress * bar_length / 100))
        for ((i=0; i<bar_length; i++)); do
            if [ $i -lt $filled ]; then
                echo -n "█"
            else
                echo -n "░"
            fi
        done
        echo "] ${progress}%"
        
        echo ""
        echo -e "${BLUE}Current Task:${NC} $current_task"
        echo ""
        
        # Statistics
        echo -e "${CYAN}╔═══════════════════════════════════════════╗${NC}"
        echo -e "${CYAN}║           Migration Statistics            ║${NC}"
        echo -e "${CYAN}╠═══════════════════════════════════════════╣${NC}"
        printf "${CYAN}║${NC} Sessions Processed: %-22s${CYAN}║${NC}\n" "$sessions"
        printf "${CYAN}║${NC} Tasks Processed:    %-22s${CYAN}║${NC}\n" "$tasks"
        printf "${CYAN}║${NC} Errors:             %-22s${CYAN}║${NC}\n" "$errors"
        printf "${CYAN}║${NC} Start Time:         %-22s${CYAN}║${NC}\n" "$start_time"
        printf "${CYAN}║${NC} ETA:                %-22s${CYAN}║${NC}\n" "$eta"
        echo -e "${CYAN}╚═══════════════════════════════════════════╝${NC}"
        
        # Recent log entries
        echo ""
        echo -e "${YELLOW}Recent Activity:${NC}"
        if [[ -f "$MIGRATION_LOG" ]]; then
            tail -5 "$MIGRATION_LOG" | while read -r line; do
                echo "  $line"
            done
        fi
        
        # Alerts
        if [ "$errors" -gt 0 ]; then
            echo ""
            echo -e "${RED}⚠ ALERTS:${NC}"
            echo -e "${RED}  $errors error(s) detected. Check log for details.${NC}"
        fi
    else
        echo -e "${YELLOW}Waiting for migration to start...${NC}"
    fi
    
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════${NC}"
    echo "Press Ctrl+C to exit monitor"
}

# Function to start web dashboard
start_web_dashboard() {
    cat > /tmp/migration-dashboard.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>FlowForge v2.0 Migration Monitor</title>
    <style>
        body { 
            font-family: 'Courier New', monospace; 
            background: #1e1e1e; 
            color: #00ff00;
            padding: 20px;
        }
        .container { 
            max-width: 1200px; 
            margin: 0 auto;
        }
        .header {
            text-align: center;
            border: 2px solid #00ff00;
            padding: 10px;
            margin-bottom: 20px;
        }
        .status-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 20px;
            margin-bottom: 20px;
        }
        .status-card {
            border: 1px solid #00ff00;
            padding: 15px;
            background: #2a2a2a;
        }
        .progress-bar {
            background: #333;
            height: 30px;
            border: 1px solid #00ff00;
            position: relative;
            margin: 20px 0;
        }
        .progress-fill {
            background: linear-gradient(90deg, #00ff00, #00aa00);
            height: 100%;
            transition: width 0.5s;
        }
        .progress-text {
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            color: white;
            font-weight: bold;
        }
        .log-viewer {
            background: #000;
            border: 1px solid #00ff00;
            padding: 10px;
            height: 300px;
            overflow-y: auto;
            font-size: 12px;
        }
        .metric {
            font-size: 24px;
            font-weight: bold;
            color: #00ffff;
        }
        .error { color: #ff3333; }
        .success { color: #00ff00; }
        .warning { color: #ffaa00; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🚀 FlowForge v2.0 Migration Monitor</h1>
            <div id="status">Loading...</div>
        </div>
        
        <div class="progress-bar">
            <div class="progress-fill" id="progress-fill"></div>
            <div class="progress-text" id="progress-text">0%</div>
        </div>
        
        <div class="status-grid">
            <div class="status-card">
                <h3>Sessions</h3>
                <div class="metric" id="sessions">0</div>
            </div>
            <div class="status-card">
                <h3>Tasks</h3>
                <div class="metric" id="tasks">0</div>
            </div>
            <div class="status-card">
                <h3>Errors</h3>
                <div class="metric error" id="errors">0</div>
            </div>
            <div class="status-card">
                <h3>Duration</h3>
                <div class="metric" id="duration">00:00:00</div>
            </div>
            <div class="status-card">
                <h3>Rate</h3>
                <div class="metric" id="rate">0/sec</div>
            </div>
            <div class="status-card">
                <h3>ETA</h3>
                <div class="metric" id="eta">--:--:--</div>
            </div>
        </div>
        
        <h3>Live Log Output</h3>
        <div class="log-viewer" id="log-viewer">
            Waiting for migration to start...
        </div>
    </div>
    
    <script>
        function updateDashboard() {
            fetch('/api/status')
                .then(response => response.json())
                .then(data => {
                    document.getElementById('status').textContent = data.status.toUpperCase();
                    document.getElementById('status').className = 
                        data.status === 'complete' ? 'success' : 
                        data.status === 'error' ? 'error' : 'warning';
                    
                    document.getElementById('progress-fill').style.width = data.progress + '%';
                    document.getElementById('progress-text').textContent = data.progress + '%';
                    
                    document.getElementById('sessions').textContent = data.sessions_processed;
                    document.getElementById('tasks').textContent = data.tasks_processed;
                    document.getElementById('errors').textContent = data.errors;
                    document.getElementById('duration').textContent = data.duration || '00:00:00';
                    document.getElementById('rate').textContent = data.rate || '0/sec';
                    document.getElementById('eta').textContent = data.eta || '--:--:--';
                });
            
            fetch('/api/logs')
                .then(response => response.text())
                .then(logs => {
                    const logViewer = document.getElementById('log-viewer');
                    logViewer.innerHTML = logs.replace(/\n/g, '<br>');
                    logViewer.scrollTop = logViewer.scrollHeight;
                });
        }
        
        setInterval(updateDashboard, 1000);
        updateDashboard();
    </script>
</body>
</html>
EOF

    # Simple HTTP server for monitoring (optional)
    if command -v python3 &> /dev/null; then
        echo "Starting web dashboard at http://localhost:$DASHBOARD_PORT"
        python3 -m http.server $DASHBOARD_PORT --directory /tmp &> /dev/null &
        WEB_PID=$!
    fi
}

# Function to track migration in background
track_migration() {
    local migration_pid=$1
    local start_epoch=$(date +%s)
    
    while kill -0 $migration_pid 2>/dev/null; do
        # Update status file
        local current_epoch=$(date +%s)
        local duration=$((current_epoch - start_epoch))
        
        # Parse current progress from migration output
        if [[ -f "$MIGRATION_LOG" ]]; then
            local last_progress=$(grep -oP 'Progress: \K\d+' "$MIGRATION_LOG" | tail -1 || echo 0)
            local current_task=$(grep -oP 'Processing \K.*' "$MIGRATION_LOG" | tail -1 || echo "Initializing")
            
            cat > "$STATUS_FILE" << EOF
{
    "status": "running",
    "progress": $last_progress,
    "current_task": "$current_task",
    "sessions_processed": $(grep -c "Session processed" "$MIGRATION_LOG" 2>/dev/null || echo 0),
    "tasks_processed": $(grep -c "Task processed" "$MIGRATION_LOG" 2>/dev/null || echo 0),
    "errors": $(grep -c "ERROR" "$MIGRATION_LOG" 2>/dev/null || echo 0),
    "start_time": "$(date -d @$start_epoch '+%H:%M:%S')",
    "duration": "$(printf '%02d:%02d:%02d' $((duration/3600)) $((duration%3600/60)) $((duration%60)))",
    "eta": "$(calculate_eta $last_progress $duration)"
}
EOF
        fi
        
        sleep $MONITOR_INTERVAL
    done
    
    # Check final status
    wait $migration_pid
    local exit_code=$?
    
    if [ $exit_code -eq 0 ]; then
        update_status "complete" 100
    else
        update_status "error" $(jq -r '.progress' "$STATUS_FILE" 2>/dev/null || echo 0)
    fi
}

# Function to calculate ETA
calculate_eta() {
    local progress=$1
    local elapsed=$2
    
    if [ $progress -gt 0 ]; then
        local total_time=$((elapsed * 100 / progress))
        local remaining=$((total_time - elapsed))
        printf '%02d:%02d:%02d' $((remaining/3600)) $((remaining%3600/60)) $((remaining%60))
    else
        echo "Calculating..."
    fi
}

# Function to update status
update_status() {
    local status=$1
    local progress=$2
    
    jq --arg status "$status" --arg progress "$progress" \
        '.status = $status | .progress = ($progress | tonumber)' \
        "$STATUS_FILE" > "$STATUS_FILE.tmp" && mv "$STATUS_FILE.tmp" "$STATUS_FILE"
}

# Main monitoring modes
case "${1:-console}" in
    console)
        echo "Starting console monitor..."
        while true; do
            display_dashboard
            sleep $MONITOR_INTERVAL
        done
        ;;
    
    web)
        echo "Starting web monitor..."
        start_web_dashboard
        echo "Web dashboard available at http://localhost:$DASHBOARD_PORT"
        echo "Press Ctrl+C to stop"
        trap "kill $WEB_PID 2>/dev/null; exit" SIGINT
        wait
        ;;
    
    track)
        # Track a specific migration process
        if [[ -z "$2" ]]; then
            echo "Usage: $0 track <migration-pid>"
            exit 1
        fi
        track_migration "$2"
        ;;
    
    *)
        echo "Usage: $0 [console|web|track <pid>]"
        echo "  console - Display real-time console dashboard"
        echo "  web     - Start web-based monitoring dashboard"
        echo "  track   - Track a specific migration process"
        exit 1
        ;;
esac