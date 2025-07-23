# Zen MCP Server Test Examples

## Basic Tests to Run

### 1. Simple Chat Test
```bash
# Test basic chat functionality with qwen3:8b
claude
# Then type: Use zen chat to ask qwen3:8b what 2+2 equals
```

### 2. Model List Test
```bash
# Test if qwen3:8b is available
claude
# Then type: Use zen listmodels to show available models
```

### 3. Code Analysis Test
```bash
# Test code analysis with a simple file
claude
# Then type: Use zen analyze to examine /workspace/pushup3/app.py
```

### 4. ThinkDeep Test
```bash
# Test extended reasoning
claude
# Then type: Use zen thinkdeep to explain how Flask routing works in detail
```

### 5. Debug Test
```bash
# Test debugging workflow
claude
# Then type: Use zen debug to help me understand why my Flask app might be slow
```

## Advanced Tests

### 6. Code Review Test
```bash
# Test code review functionality
claude
# Then type: Use zen codereview to review /workspace/pushup3/models.py for potential improvements
```

### 7. Refactor Test  
```bash
# Test refactoring suggestions
claude
# Then type: Use zen refactor to suggest improvements for /workspace/pushup3/app.py
```

### 8. Test Generation
```bash
# Test test generation
claude
# Then type: Use zen testgen to create tests for the User model in /workspace/pushup3/models.py
```

## Expected Results

- All commands should use the **qwen3:8b** model via Ollama
- Responses should be in English
- The thinking mode should be set to "high" for detailed analysis
- Connection should be via `host.docker.internal:11434/v1`

## Troubleshooting

If tests fail, verify:
1. Ollama is running: `ollama list`
2. qwen3:8b model is available: `ollama pull qwen3:8b`
3. Zen MCP server is connected: `claude mcp list`
4. .env file is correct in `/home/devuser/.zen-mcp-server/.env`