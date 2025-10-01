# Agent Communication Protocols

This document defines the standardized communication protocols for CCPM agent coordination, ensuring efficient information flow, context preservation, and conflict prevention across the agent ecosystem.

## Communication Architecture

### Agent Hierarchy
```
orchestration-master
├── requirements-analyzer
├── architecture-planner
├── parallel-worker
│   ├── code-analyzer
│   ├── test-runner
│   ├── security-auditor
│   └── performance-optimizer
├── deployment-manager
└── file-analyzer
```

### Communication Patterns

#### 1. Command & Control Pattern
- **Orchestration Master** → **Specialized Agents**
- Used for: Task assignment, work coordination, resource allocation
- Format: Structured task specifications with clear deliverables

#### 2. Information Flow Pattern
- **Specialized Agents** → **Orchestration Master**
- Used for: Status updates, results reporting, issue escalation
- Format: Standardized report structures with key metrics

#### 3. Peer Coordination Pattern
- **Agent A** ↔ **Agent B** (via Orchestration Master)
- Used for: Dependency resolution, resource sharing, conflict prevention
- Format: Coordination messages with shared context

## Message Formats

### Task Assignment Message
```yaml
task_assignment:
  message_id: "task_${timestamp}_${agent_name}"
  timestamp: "2024-01-15T10:30:00Z"
  source_agent: "orchestration-master"
  target_agent: "requirements-analyzer"
  priority: "high" # high, medium, low
  
  task_specification:
    objective: "Analyze PRD and extract structured requirements"
    scope: "user-authentication-feature"
    deliverables:
      - "structured_requirements.md"
      - "dependency_map.yaml"
      - "risk_assessment.md"
    
    context:
      project_phase: "planning"
      related_tasks: ["epic-decomposition", "architecture-design"]
      constraints:
        - "must_complete_by: 2024-01-15T18:00:00Z"
        - "resource_limit: medium"
    
    input_artifacts:
      - path: ".claude/prds/user-authentication.md"
        type: "prd"
        description: "Product requirements document"
    
    success_criteria:
      - "all_functional_requirements_extracted"
      - "dependencies_mapped_completely"
      - "risks_identified_and_assessed"
    
    coordination_notes:
      dependencies: []
      conflicts_to_avoid: ["avoid_modifying_existing_architecture"]
      handoff_agents: ["architecture-planner"]

  execution_context:
    working_directory: ".claude/epics/user-authentication"
    environment_variables:
      PROJECT_NAME: "user-auth-system"
      ANALYSIS_DEPTH: "comprehensive"
    
    resource_allocation:
      max_execution_time: "2h"
      memory_limit: "moderate"
      concurrent_tasks: 1
```

### Status Update Message
```yaml
status_update:
  message_id: "status_${timestamp}_${agent_name}"
  timestamp: "2024-01-15T11:15:00Z"
  source_agent: "requirements-analyzer"
  target_agent: "orchestration-master"
  task_id: "task_20240115103000_requirements-analyzer"
  
  status: "in_progress" # queued, in_progress, completed, failed, blocked
  progress_percentage: 65
  
  progress_details:
    completed_activities:
      - "prd_document_analysis"
      - "functional_requirements_extraction"
      - "stakeholder_identification"
    
    current_activity: "dependency_mapping"
    
    remaining_activities:
      - "risk_assessment"
      - "report_generation"
    
    estimated_completion: "2024-01-15T12:00:00Z"
  
  intermediate_results:
    functional_requirements_count: 23
    non_functional_requirements_count: 8
    identified_stakeholders: 5
    preliminary_risks: 3
  
  issues_encountered: []
  
  resource_usage:
    execution_time_elapsed: "45m"
    memory_usage: "low"
```

### Results Report Message
```yaml
results_report:
  message_id: "results_${timestamp}_${agent_name}"
  timestamp: "2024-01-15T12:00:00Z"
  source_agent: "requirements-analyzer"
  target_agent: "orchestration-master"
  task_id: "task_20240115103000_requirements-analyzer"
  
  completion_status: "completed" # completed, partial, failed
  
  deliverables:
    - artifact_path: ".claude/epics/user-authentication/requirements.md"
      artifact_type: "structured_requirements"
      description: "Comprehensive requirements analysis"
      size_kb: 45
      checksum: "sha256:abc123..."
    
    - artifact_path: ".claude/epics/user-authentication/dependencies.yaml"
      artifact_type: "dependency_map"
      description: "Requirement dependencies and relationships"
      size_kb: 12
      checksum: "sha256:def456..."
  
  execution_summary:
    total_execution_time: "1h 30m"
    success_criteria_met: 3
    success_criteria_total: 3
    quality_score: 95
  
  key_findings:
    - type: "insight"
      description: "Authentication system requires integration with 3 external services"
      impact: "medium"
    
    - type: "risk"
      description: "GDPR compliance requirements may affect data storage design"
      impact: "high"
    
    - type: "dependency"
      description: "Requires completion of user management system first"
      impact: "high"
  
  recommendations:
    - priority: "high"
      action: "Review GDPR compliance requirements with legal team"
      rationale: "Critical for architecture decisions"
    
    - priority: "medium"
      action: "Validate external service integration capabilities"
      rationale: "May affect technical feasibility"
  
  handoff_information:
    next_agents: ["architecture-planner"]
    context_for_next_phase: "Requirements analysis complete, ready for technical design"
    critical_constraints: ["gdpr_compliance", "external_service_dependencies"]
```

### Coordination Message
```yaml
coordination_message:
  message_id: "coord_${timestamp}_${source}_${target}"
  timestamp: "2024-01-15T13:30:00Z"
  source_agent: "security-auditor"
  target_agent: "architecture-planner"
  coordination_type: "dependency_notification" # dependency_notification, resource_request, conflict_resolution
  
  coordination_details:
    subject: "Security requirements for authentication architecture"
    
    dependencies:
      - requirement: "Multi-factor authentication implementation"
        impact: "Must be designed into authentication flow"
        priority: "high"
      
      - requirement: "Session management security"
        impact: "Affects token storage and validation design"
        priority: "high"
    
    constraints:
      - type: "security"
        description: "All authentication data must be encrypted at rest"
        impact: "Database and storage architecture"
      
      - type: "compliance"
        description: "GDPR right to be forgotten must be supported"
        impact: "Data architecture and retention policies"
    
    recommendations:
      - "Implement OAuth 2.0 with PKCE for enhanced security"
      - "Use JWT tokens with short expiration and refresh mechanism"
      - "Design for audit trail requirements from day one"
  
  response_required: true
  response_deadline: "2024-01-15T16:00:00Z"
```

## Communication Rules

### 1. Message Routing Rules
- All inter-agent communication must go through the orchestration master
- Direct agent-to-agent communication is prohibited to prevent coordination conflicts
- Emergency escalation messages can bypass normal routing with explicit justification

### 2. Context Preservation Rules
- Each message must include sufficient context for the recipient to understand the request
- Shared artifacts must be referenced by absolute paths with checksums
- Critical information must be preserved across message chains

### 3. Conflict Prevention Rules
- Agents must declare resource requirements and constraints upfront
- Conflicting operations must be serialized through the orchestration master
- Shared resources must be locked/reserved before use

### 4. Quality Assurance Rules
- All deliverables must include quality metrics and validation results
- Failed tasks must include detailed error information and suggested remediation
- Partial completions must clearly specify what was and wasn't accomplished

## Standard Response Formats

### Acknowledgment Response
```yaml
acknowledgment:
  message_id: "ack_${original_message_id}"
  timestamp: "2024-01-15T10:31:00Z"
  source_agent: "requirements-analyzer"
  target_agent: "orchestration-master"
  original_message_id: "task_20240115103000_requirements-analyzer"
  
  status: "accepted" # accepted, rejected, deferred
  estimated_start_time: "2024-01-15T10:35:00Z"
  estimated_completion_time: "2024-01-15T12:30:00Z"
  
  resource_requirements:
    execution_time: "2h"
    memory_usage: "moderate"
    disk_space: "100MB"
    external_dependencies: ["github_api", "documentation_files"]
  
  potential_conflicts:
    - resource: "requirements_document"
      conflict_type: "read_write"
      mitigation: "will_create_backup_before_modification"
```

### Error Response
```yaml
error_response:
  message_id: "error_${timestamp}_${agent_name}"
  timestamp: "2024-01-15T11:45:00Z"
  source_agent: "code-analyzer"
  target_agent: "orchestration-master"
  original_task_id: "task_20240115103000_code-analyzer"
  
  error_type: "execution_failure" # validation_error, resource_unavailable, execution_failure, timeout
  error_severity: "high" # low, medium, high, critical
  
  error_details:
    error_code: "ANALYSIS_001"
    error_message: "Unable to analyze code due to missing dependency information"
    
    root_cause: "Dependency mapping not available in expected location"
    
    affected_scope: "Complete code analysis task"
    
    recovery_possible: true
    recovery_strategy: "Wait for dependency mapping from requirements-analyzer"
  
  impact_assessment:
    blocked_tasks: ["security-audit", "performance-analysis"]
    timeline_impact: "2h delay"
    quality_impact: "Analysis will be incomplete without dependency context"
  
  recommended_actions:
    - priority: "immediate"
      action: "Request dependency mapping from requirements-analyzer"
      rationale: "Required for accurate code analysis"
    
    - priority: "fallback"
      action: "Proceed with partial analysis and flag missing dependencies"
      rationale: "Allows some progress while waiting for dependencies"
```

## Communication Protocols by Agent Type

### Orchestration Master Protocols
- **Outbound**: Task assignments, coordination directives, resource allocation
- **Inbound**: Status updates, results reports, escalation requests
- **Special**: Conflict resolution, priority adjustments, emergency coordination

### Specialized Agent Protocols
- **Outbound**: Status updates, results reports, coordination requests, error reports
- **Inbound**: Task assignments, coordination messages, priority updates
- **Special**: Peer coordination (via orchestration master), resource requests

### Parallel Worker Protocols
- **Outbound**: Sub-task assignments, consolidated reports, resource coordination
- **Inbound**: Work packages, coordination directives, sub-agent results
- **Special**: Sub-agent management, parallel execution coordination

## Quality Assurance Protocols

### Message Validation
```yaml
message_validation:
  required_fields:
    - message_id
    - timestamp
    - source_agent
    - target_agent
    - message_type
  
  format_validation:
    timestamp: "ISO 8601 format"
    message_id: "Unique identifier with agent name"
    agent_names: "Must match registered agent names"
  
  content_validation:
    task_assignments: "Must include objective, deliverables, success criteria"
    status_updates: "Must include progress percentage and current activity"
    results_reports: "Must include deliverables and execution summary"
```

### Context Integrity
- All references to files and artifacts must include absolute paths
- Shared context must be validated for consistency across agents
- Critical information must be checksummed to detect corruption

### Performance Monitoring
- Message processing times must be tracked and reported
- Communication bottlenecks must be identified and resolved
- Agent response times must be monitored for SLA compliance

## Emergency Protocols

### Escalation Procedures
1. **Agent Failure**: Immediate notification to orchestration master with failure details
2. **Resource Conflicts**: Automatic conflict detection and resolution coordination
3. **Deadline Risks**: Proactive notification when deadlines are at risk
4. **Quality Issues**: Immediate escalation of quality failures or security issues

### Fallback Mechanisms
- **Agent Unavailable**: Automatic task reassignment to backup agents
- **Communication Failure**: Retry mechanisms with exponential backoff
- **Resource Exhaustion**: Automatic resource reallocation and priority adjustment
- **Cascade Failures**: Circuit breaker patterns to prevent system-wide failures

## Monitoring and Observability

### Communication Metrics
- Message throughput and latency
- Agent response times and availability
- Task completion rates and quality scores
- Error rates and escalation frequency

### Audit Trail
- Complete message history for compliance and debugging
- Agent decision logs for transparency and improvement
- Resource usage tracking for optimization
- Performance metrics for capacity planning

This communication protocol ensures efficient, reliable, and transparent coordination across the CCPM agent ecosystem while maintaining context integrity and preventing conflicts.
