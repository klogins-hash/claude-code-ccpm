#!/usr/bin/env python3
import os
import subprocess
import json
from flask import Flask, request, jsonify, render_template_string
from flask_cors import CORS
import logging

app = Flask(__name__)
CORS(app)

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# HTML template for the web interface
HTML_TEMPLATE = '''
<!DOCTYPE html>
<html>
<head>
    <title>CCPM - Claude Code Project Manager</title>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; margin: 0; padding: 20px; background: #f5f5f5; }
        .container { max-width: 1200px; margin: 0 auto; background: white; padding: 30px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        h1 { color: #2c3e50; margin-bottom: 30px; }
        .command-section { margin-bottom: 30px; padding: 20px; background: #f8f9fa; border-radius: 6px; }
        .command-input { width: 100%; padding: 12px; border: 1px solid #ddd; border-radius: 4px; font-family: monospace; }
        .execute-btn { background: #007bff; color: white; padding: 12px 24px; border: none; border-radius: 4px; cursor: pointer; margin-top: 10px; }
        .execute-btn:hover { background: #0056b3; }
        .output { background: #2d3748; color: #e2e8f0; padding: 15px; border-radius: 4px; margin-top: 15px; font-family: monospace; white-space: pre-wrap; max-height: 400px; overflow-y: auto; }
        .status { padding: 10px; border-radius: 4px; margin-top: 10px; }
        .status.success { background: #d4edda; color: #155724; border: 1px solid #c3e6cb; }
        .status.error { background: #f8d7da; color: #721c24; border: 1px solid #f5c6cb; }
        .quick-commands { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 15px; margin-bottom: 30px; }
        .quick-cmd { background: #e9ecef; padding: 15px; border-radius: 6px; cursor: pointer; transition: background 0.2s; }
        .quick-cmd:hover { background: #dee2e6; }
        .quick-cmd h4 { margin: 0 0 8px 0; color: #495057; }
        .quick-cmd p { margin: 0; font-size: 14px; color: #6c757d; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🤖 CCPM - Claude Code Project Manager</h1>
        <p>Spec-driven development workflow using GitHub issues, Git worktrees, and parallel AI agents.</p>
        
        <div class="quick-commands">
            <div class="quick-cmd" onclick="setCommand('/pm:help')">
                <h4>📚 Help</h4>
                <p>Show all available commands</p>
            </div>
            <div class="quick-cmd" onclick="setCommand('/pm:init')">
                <h4>🚀 Initialize</h4>
                <p>Set up CCPM in current project</p>
            </div>
            <div class="quick-cmd" onclick="setCommand('/pm:prd-new my-feature')">
                <h4>📝 New PRD</h4>
                <p>Create product requirements document</p>
            </div>
            <div class="quick-cmd" onclick="setCommand('/pm:epic-list')">
                <h4>📋 List Epics</h4>
                <p>Show all epics and their status</p>
            </div>
        </div>

        <div class="command-section">
            <h3>Execute CCPM Command</h3>
            <input type="text" id="command" class="command-input" placeholder="Enter CCPM command (e.g., /pm:help)" value="/pm:help">
            <button class="execute-btn" onclick="executeCommand()">Execute</button>
            <div id="status"></div>
            <div id="output"></div>
        </div>
    </div>

    <script>
        function setCommand(cmd) {
            document.getElementById('command').value = cmd;
        }

        async function executeCommand() {
            const command = document.getElementById('command').value;
            const statusDiv = document.getElementById('status');
            const outputDiv = document.getElementById('output');
            
            statusDiv.innerHTML = '<div class="status">Executing command...</div>';
            outputDiv.innerHTML = '';
            
            try {
                const response = await fetch('/execute', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ command: command })
                });
                
                const result = await response.json();
                
                if (result.success) {
                    statusDiv.innerHTML = '<div class="status success">Command executed successfully</div>';
                    outputDiv.innerHTML = '<div class="output">' + result.output + '</div>';
                } else {
                    statusDiv.innerHTML = '<div class="status error">Command failed</div>';
                    outputDiv.innerHTML = '<div class="output">' + result.error + '</div>';
                }
            } catch (error) {
                statusDiv.innerHTML = '<div class="status error">Network error</div>';
                outputDiv.innerHTML = '<div class="output">Error: ' + error.message + '</div>';
            }
        }
        
        // Allow Enter key to execute command
        document.getElementById('command').addEventListener('keypress', function(e) {
            if (e.key === 'Enter') {
                executeCommand();
            }
        });
    </script>
</body>
</html>
'''

@app.route('/')
def index():
    return render_template_string(HTML_TEMPLATE)

@app.route('/execute', methods=['POST'])
def execute_command():
    try:
        data = request.get_json()
        command = data.get('command', '').strip()
        
        if not command:
            return jsonify({'success': False, 'error': 'No command provided'})
        
        # Set up environment
        env = os.environ.copy()
        env['PATH'] = '/app/ccpm:' + env.get('PATH', '')
        
        # Sanitize command to prevent injection
        if not command.startswith('/pm:'):
            return jsonify({'success': False, 'error': 'Only CCPM commands are allowed (must start with /pm:)'})
        
        # Execute the command
        result = subprocess.run(
            ['bash', '-c', f'cd /app && {command}'],
            capture_output=True,
            text=True,
            timeout=60,
            env=env
        )
        
        if result.returncode == 0:
            return jsonify({
                'success': True,
                'output': result.stdout,
                'stderr': result.stderr
            })
        else:
            return jsonify({
                'success': False,
                'error': result.stderr or result.stdout,
                'returncode': result.returncode
            })
            
    except subprocess.TimeoutExpired:
        return jsonify({'success': False, 'error': 'Command timed out'})
    except Exception as e:
        logger.error(f"Error executing command: {e}")
        return jsonify({'success': False, 'error': str(e)})

@app.route('/health')
def health():
    return jsonify({'status': 'healthy', 'service': 'ccpm-web'})

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 8080))
    app.run(host='0.0.0.0', port=port, debug=False)
