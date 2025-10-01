---
allowed-tools: Bash, Read, Write, LS, Task, Agent
---

# Agent Orchestration Command

Launch the orchestration master to coordinate specialized agents for complex workflows.

## Usage
```
/pm:agent-orchestrate <workflow_type> [scope] [options]
```

## Workflow Types

### 1. Requirements Analysis
```bash
/pm:agent-orchestrate requirements-analysis epic-name
```
- **Primary Agent**: requirements-analyzer
- **Supporting Agents**: file-analyzer (for existing docs)
- **Output**: Structured requirements, dependency maps, risk assessments

### 2. Architecture Design
```bash
/pm:agent-orchestrate architecture-design epic-name
```
- **Primary Agent**: architecture-planner
- **Supporting Agents**: requirements-analyzer, security-auditor
- **Output**: Technical architecture, API specs, infrastructure design

### 3. Code Analysis & Review
```bash
/pm:agent-orchestrate code-review [file-pattern]
```
- **Primary Agent**: code-analyzer
- **Supporting Agents**: security-auditor, performance-optimizer, test-runner
- **Output**: Bug reports, security findings, performance recommendations

### 4. Security Audit
```bash
/pm:agent-orchestrate security-audit [scope]
```
- **Primary Agent**: security-auditor
- **Supporting Agents**: code-analyzer, file-analyzer
- **Output**: Vulnerability assessment, compliance report, remediation plan

### 5. Performance Optimization
```bash
/pm:agent-orchestrate performance-audit [component]
```
- **Primary Agent**: performance-optimizer
- **Supporting Agents**: code-analyzer, test-runner
- **Output**: Performance analysis, optimization recommendations, benchmarks

### 6. Deployment Planning
```bash
/pm:agent-orchestrate deployment-plan environment
```
- **Primary Agent**: deployment-manager
- **Supporting Agents**: security-auditor, performance-optimizer
- **Output**: Deployment strategy, CI/CD pipeline, monitoring setup

### 7. Full Epic Implementation
```bash
/pm:agent-orchestrate epic-implement epic-name
```
- **Primary Agent**: orchestration-master
- **All Agents**: Coordinated based on epic requirements
- **Output**: Complete implementation with quality assurance

## Quick Check

1. **Verify epic/scope exists:**
   ```bash
   if [ "$2" ]; then
     test -f .claude/epics/$2/epic.md || echo "❌ Epic not found: $2"
   fi
   ```

2. **Check for uncommitted changes:**
   ```bash
   if [ -n "$(git status --porcelain)" ]; then
     echo "⚠️  Uncommitted changes detected. Consider committing before orchestration."
   fi
   ```

3. **Validate agent availability:**
   ```bash
   # Check if required agent files exist
   WORKFLOW_TYPE="$1"
   case "$WORKFLOW_TYPE" in
     "requirements-analysis")
       test -f .claude/agents/requirements-analyzer.md || echo "❌ Requirements analyzer not available"
       ;;
     "architecture-design")
       test -f .claude/agents/architecture-planner.md || echo "❌ Architecture planner not available"
       ;;
     "code-review")
       test -f .claude/agents/code-analyzer.md || echo "❌ Code analyzer not available"
       ;;
   esac
   ```

## Instructions

### 1. Initialize Orchestration Context

```bash
WORKFLOW_TYPE="$1"
SCOPE="${2:-default}"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
ORCHESTRATION_ID="orch_${TIMESTAMP}_${WORKFLOW_TYPE}"

# Create orchestration workspace
mkdir -p .claude/orchestration/$ORCHESTRATION_ID
cd .claude/orchestration/$ORCHESTRATION_ID

# Initialize orchestration log
cat > orchestration.log << EOF
# Orchestration Session: $ORCHESTRATION_ID
Started: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
Workflow: $WORKFLOW_TYPE
Scope: $SCOPE
Status: Initializing
EOF
```

### 2. Launch Orchestration Master

Use the Task tool to launch the orchestration master:

```yaml
Task:
  description: "Orchestrate $WORKFLOW_TYPE workflow for scope: $SCOPE"
  subagent_type: "orchestration-master"
  prompt: |
    You are the Orchestration Master coordinating a $WORKFLOW_TYPE workflow.
    
    Workflow Context:
    - Type: $WORKFLOW_TYPE
    - Scope: $SCOPE
    - Session ID: $ORCHESTRATION_ID
    - Working Directory: .claude/orchestration/$ORCHESTRATION_ID
    
    Your Mission:
    1. Analyze the workflow requirements and complexity
    2. Determine the optimal agent coordination strategy
    3. Deploy and coordinate specialized agents as needed
    4. Ensure quality gates are met throughout execution
    5. Provide consolidated results and recommendations
    
    Available Specialized Agents:
    - requirements-analyzer: PRD and specification analysis
    - architecture-planner: System design and technical planning
    - code-analyzer: Deep code analysis and bug hunting
    - security-auditor: Security analysis and compliance
    - performance-optimizer: Performance analysis and optimization
    - deployment-manager: CI/CD and deployment coordination
    - test-runner: Comprehensive testing and validation
    - file-analyzer: Large file analysis and summarization
    - parallel-worker: Parallel execution coordination
    
    Coordination Protocols:
    - Follow agent communication protocols in .claude/protocols/
    - Use standardized message formats for agent coordination
    - Implement quality gates and validation checkpoints
    - Provide progress updates and status monitoring
    - Escalate issues and conflicts appropriately
    
    Success Criteria:
    - All workflow objectives achieved with high quality
    - Efficient resource utilization and minimal conflicts
    - Clear documentation of decisions and outcomes
    - Actionable recommendations for next steps
    
    Begin by analyzing the workflow requirements and creating your execution plan.
```

### 3. Monitor Orchestration Progress

```bash
# Function to monitor orchestration progress
monitor_orchestration() {
    local session_id="$1"
    local log_file=".claude/orchestration/$session_id/orchestration.log"
    
    echo "Monitoring orchestration session: $session_id"
    echo "Log file: $log_file"
    echo "Press Ctrl+C to stop monitoring"
    echo "----------------------------------------"
    
    # Tail the orchestration log
    tail -f "$log_file" 2>/dev/null &
    local tail_pid=$!
    
    # Monitor for completion
    while true; do
        if grep -q "Status: Completed\|Status: Failed" "$log_file" 2>/dev/null; then
            kill $tail_pid 2>/dev/null
            break
        fi
        sleep 5
    done
    
    echo "----------------------------------------"
    echo "Orchestration session completed."
}

# Start monitoring
monitor_orchestration "$ORCHESTRATION_ID"
```

### 4. Workflow-Specific Configurations

#### Requirements Analysis Workflow
```bash
if [ "$WORKFLOW_TYPE" = "requirements-analysis" ]; then
    # Prepare requirements analysis context
    EPIC_PATH=".claude/epics/$SCOPE"
    
    if [ -f "$EPIC_PATH/epic.md" ]; then
        cp "$EPIC_PATH/epic.md" ./input_epic.md
        echo "Epic file prepared for analysis"
    fi
    
    if [ -f ".claude/prds/$SCOPE.md" ]; then
        cp ".claude/prds/$SCOPE.md" ./input_prd.md
        echo "PRD file prepared for analysis"
    fi
    
    # Set specific success criteria
    cat >> orchestration.log << EOF

Requirements Analysis Configuration:
- Input Epic: $EPIC_PATH/epic.md
- Input PRD: .claude/prds/$SCOPE.md
- Expected Outputs:
  - Structured requirements document
  - Dependency mapping
  - Risk assessment
  - Implementation recommendations
EOF
fi
```

#### Code Review Workflow
```bash
if [ "$WORKFLOW_TYPE" = "code-review" ]; then
    # Prepare code review context
    FILE_PATTERN="${SCOPE:-**/*.{js,py,java,go,rs,ts,jsx,tsx}}"
    
    # Find files to review
    find . -name "$FILE_PATTERN" -not -path "./.git/*" -not -path "./node_modules/*" > files_to_review.txt
    
    FILE_COUNT=$(wc -l < files_to_review.txt)
    echo "Found $FILE_COUNT files matching pattern: $FILE_PATTERN"
    
    # Set specific success criteria
    cat >> orchestration.log << EOF

Code Review Configuration:
- File Pattern: $FILE_PATTERN
- Files to Review: $FILE_COUNT
- Review Scope: Security, Performance, Quality, Testing
- Expected Outputs:
  - Bug analysis report
  - Security vulnerability assessment
  - Performance optimization recommendations
  - Test coverage analysis
EOF
fi
```

#### Security Audit Workflow
```bash
if [ "$WORKFLOW_TYPE" = "security-audit" ]; then
    # Prepare security audit context
    AUDIT_SCOPE="${SCOPE:-full}"
    
    # Identify security-sensitive files
    find . -name "*.{js,py,java,go,rs,ts,jsx,tsx,sql,yaml,yml,json}" \
        -not -path "./.git/*" \
        -not -path "./node_modules/*" > security_audit_files.txt
    
    # Set specific success criteria
    cat >> orchestration.log << EOF

Security Audit Configuration:
- Audit Scope: $AUDIT_SCOPE
- Security Focus Areas:
  - Authentication and authorization
  - Input validation and sanitization
  - Data protection and encryption
  - Dependency vulnerabilities
  - Configuration security
- Expected Outputs:
  - Vulnerability assessment report
  - Compliance status report
  - Remediation recommendations
  - Security testing recommendations
EOF
fi
```

### 5. Results Collection and Reporting

```bash
# Function to collect and summarize results
collect_results() {
    local session_id="$1"
    local results_dir=".claude/orchestration/$session_id"
    
    echo "Collecting orchestration results..."
    
    # Create summary report
    cat > "$results_dir/orchestration_summary.md" << EOF
# Orchestration Summary Report

## Session Information
- **Session ID**: $session_id
- **Workflow Type**: $WORKFLOW_TYPE
- **Scope**: $SCOPE
- **Started**: $(grep "Started:" "$results_dir/orchestration.log" | cut -d' ' -f2-)
- **Completed**: $(date -u +"%Y-%m-%dT%H:%M:%SZ")

## Execution Summary
$(tail -20 "$results_dir/orchestration.log")

## Generated Artifacts
EOF
    
    # List all generated files
    find "$results_dir" -type f -name "*.md" -o -name "*.yaml" -o -name "*.json" | while read file; do
        echo "- $(basename "$file"): $(wc -l < "$file") lines" >> "$results_dir/orchestration_summary.md"
    done
    
    echo "Results collected in: $results_dir/orchestration_summary.md"
}

# Collect results after completion
collect_results "$ORCHESTRATION_ID"
```

### 6. Integration with Existing Commands

```bash
# Update epic status if this was an epic-related orchestration
if [ "$WORKFLOW_TYPE" = "epic-implement" ] && [ -f ".claude/epics/$SCOPE/epic.md" ]; then
    # Update epic with orchestration results
    echo "" >> ".claude/epics/$SCOPE/epic.md"
    echo "## Orchestration Results" >> ".claude/epics/$SCOPE/epic.md"
    echo "- Session: $ORCHESTRATION_ID" >> ".claude/epics/$SCOPE/epic.md"
    echo "- Completed: $(date)" >> ".claude/epics/$SCOPE/epic.md"
    echo "- Results: .claude/orchestration/$ORCHESTRATION_ID/" >> ".claude/epics/$SCOPE/epic.md"
fi

# Create GitHub issue if configured
if command -v gh >/dev/null 2>&1 && [ -n "$GITHUB_REPO" ]; then
    gh issue comment --repo "$GITHUB_REPO" --body "Orchestration completed: $ORCHESTRATION_ID" "$SCOPE" 2>/dev/null || true
fi
```

## Advanced Options

### Parallel Execution Mode
```bash
/pm:agent-orchestrate code-review --parallel --max-agents=4
```

### Custom Agent Selection
```bash
/pm:agent-orchestrate security-audit --agents="security-auditor,code-analyzer" --exclude="performance-optimizer"
```

### Quality Gate Configuration
```bash
/pm:agent-orchestrate epic-implement epic-name --quality-gates="strict" --auto-retry=true
```

### Resource Constraints
```bash
/pm:agent-orchestrate performance-audit --max-memory=2GB --timeout=30m
```

## Output Structure

```
.claude/orchestration/$ORCHESTRATION_ID/
├── orchestration.log              # Main orchestration log
├── orchestration_summary.md       # Executive summary
├── agent_communications/          # Agent message logs
│   ├── requirements-analyzer.log
│   ├── architecture-planner.log
│   └── ...
├── deliverables/                  # Agent outputs
│   ├── requirements_analysis.md
│   ├── architecture_design.md
│   ├── security_report.md
│   └── ...
├── quality_reports/               # Quality assessments
│   ├── quality_metrics.yaml
│   ├── validation_results.md
│   └── ...
└── coordination_data/             # Coordination metadata
    ├── resource_usage.yaml
    ├── timing_analysis.yaml
    └── performance_metrics.yaml
```

## Error Handling

The orchestration system includes comprehensive error handling:

1. **Agent Failures**: Automatic retry with alternative agents
2. **Resource Conflicts**: Intelligent conflict resolution and serialization
3. **Quality Failures**: Automatic remediation and re-execution
4. **Timeout Handling**: Graceful degradation and partial results
5. **Dependency Issues**: Dynamic dependency resolution and alternative paths

## Best Practices

1. **Start Small**: Begin with single-agent workflows before complex orchestrations
2. **Monitor Progress**: Use the monitoring functions to track orchestration progress
3. **Quality First**: Don't skip quality gates for faster execution
4. **Resource Awareness**: Consider system resources when launching parallel agents
5. **Documentation**: Always review the generated summary reports
6. **Iterative Improvement**: Use orchestration metrics to improve future workflows

This orchestration command provides a powerful interface for coordinating complex multi-agent workflows while maintaining quality, efficiency, and transparency.
