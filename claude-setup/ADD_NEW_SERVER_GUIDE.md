#  Quick Guide: Adding New Claude Code Servers

##  **Checklist for Adding New MCP Servers**

When you develop a new Claude Code server and want to integrate it into the master template:

###  **Files to Update:**

1. **Global MCP Configuration**
   - `~/docker-dev-environment/claude-setup/global-config/mcp_config.json`

2. **All Project Templates** (5 files)
   - `templates/python-project/.mcp.json`
   - `templates/fastapi-project/.mcp.json`
   - `templates/react-project/.mcp.json`
   - `templates/ml-project/.mcp.json`
   - `templates/datascience-project/.mcp.json`

3. **Environment Templates** (6 files)
   - `templates/.env_template_master`
   - `templates/python-project/.env_template`
   - `templates/fastapi-project/.env_template`
   - `templates/react-project/.env_template`
   - `templates/ml-project/.env_template`
   - `templates/datascience-project/.env_template`

4. **Installation Script**
   - `scripts/install-claude-setup.sh` (add to `local servers=()`)

5. **Documentation**
   - `CLAUDE_SETUP_COMPLETE.md`
   - `README_COMPLETE.md`

###  **Quick Commands:**

```bash
# 1. Use the helper script
cd ~/docker-dev-environment/claude-setup
./add-new-server.sh my-server @myorg/my-mcp-server "My server description"

# 2. Update configurations manually (see main guide)

# 3. Test integration
./run-setup.sh
claude-new test-project
cd test-project
claude -p "List available MCP servers"
```

###  **Template for New Server:**

**MCP Configuration:**
```json
"your-server": {
  "command": "npx",
  "args": ["-y", "your-mcp-package"],
  "env": {
    "YOUR_API_KEY": "${YOUR_API_KEY}",
    "YOUR_ENDPOINT": "${YOUR_ENDPOINT:-default}"
  }
}
```

**Environment Variables:**
```bash
# =============================================================================
# Your Server Configuration
# =============================================================================
YOUR_API_KEY="your_api_key_here"
YOUR_ENDPOINT="https://your-server.example.com"
YOUR_TIMEOUT=30
```

**Custom Command:**
```markdown
# Your server specialized workflow
Please use the your-server MCP to help with:

1. **Primary Function**: What your server does
2. **Use Cases**: When to use it
3. **Integration**: How it works with other tools

**Task**: $ARGUMENTS
```

###  **Fast Track Process:**

1. **Add to installation script** → Server gets installed automatically
2. **Update MCP configs** → Server is available in all projects
3. **Add environment vars** → Configuration is ready
4. **Create custom commands** → Specialized workflows available
5. **Update docs** → Users know about the new server

###  **Result:**
Every new project created with `claude-new` will automatically include your server!

---

**See the full guide in README_COMPLETE.md for detailed step-by-step instructions.**
