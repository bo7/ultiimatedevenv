#!/bin/bash

# Advanced Development Tools Installer
# Adds additional development tools and configurations to the container

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE} Installing Advanced Development Tools${NC}"
echo "==========================================="

# Check if container is running
if ! docker ps | grep -q claude-dev-env; then
    echo -e "${YELLOW}  Container not running. Starting it first...${NC}"
    ./manage.sh start
    sleep 5
fi

# Install additional Python packages
echo -e "${BLUE} Installing additional Python packages...${NC}"
docker exec claude-dev-env bash -c "
pip install --upgrade \
    jupyterlab \
    streamlit \
    dash \
    plotly \
    bokeh \
    sqlalchemy \
    alembic \
    redis \
    celery \
    pydantic \
    typer \
    rich \
    textual \
    asyncio \
    aiohttp \
    websockets \
    python-multipart \
    python-jose \
    passlib \
    bcrypt \
    pytest-asyncio \
    pytest-mock \
    factory-boy \
    faker \
    locust \
    bandit \
    safety \
    coverage \
    sphinx \
    mkdocs \
    mkdocs-material
"

# Install additional Node.js tools
echo -e "${BLUE} Installing additional Node.js tools...${NC}"
docker exec claude-dev-env bash -c "
npm install -g \
    @nestjs/cli \
    @angular/cli \
    create-react-app \
    next \
    nuxt \
    vue-cli \
    svelte \
    vite \
    webpack \
    parcel \
    rollup \
    esbuild \
    pm2 \
    nodemon \
    concurrently \
    cross-env \
    dotenv-cli \
    http-server \
    serve \
    json-server \
    @storybook/cli \
    playwright \
    cypress \
    jest \
    mocha \
    chai \
    nyc \
    standard \
    xo \
    @typescript-eslint/cli \
    ts-node-dev \
    tsx
"

# Install development databases and tools
echo -e "${BLUE}  Installing database tools...${NC}"
docker exec claude-dev-env bash -c "
pip install \
    psycopg2-binary \
    pymongo \
    motor \
    asyncpg \
    databases \
    tortoise-orm \
    peewee \
    sqlmodel \
    neo4j \
    elasticsearch \
    aiomysql
"

# Install monitoring and observability tools
echo -e "${BLUE} Installing monitoring tools...${NC}"
docker exec claude-dev-env bash -c "
pip install \
    prometheus-client \
    grafana-api \
    sentry-sdk \
    opentelemetry-api \
    opentelemetry-sdk \
    structlog \
    loguru \
    pyinstrument \
    memory-profiler \
    py-spy
"

# Install additional VS Code extensions
echo -e "${BLUE} Installing additional VS Code extensions...${NC}"
docker exec claude-dev-env bash -c "
code --install-extension ms-python.jupyter \
    --install-extension ms-toolsai.jupyter \
    --install-extension ms-python.debugpy \
    --install-extension ms-vscode.makefile-tools \
    --install-extension ms-vscode.cmake-tools \
    --install-extension redhat.vscode-yaml \
    --install-extension ms-kubernetes-tools.vscode-kubernetes-tools \
    --install-extension ms-vscode.docker \
    --install-extension hashicorp.terraform \
    --install-extension ms-vscode.powershell \
    --install-extension ms-dotnettools.csharp \
    --install-extension golang.go \
    --install-extension rust-lang.rust-analyzer \
    --install-extension vadimcn.vscode-lldb \
    --install-extension ms-vscode.vscode-json \
    --install-extension tamasfe.even-better-toml \
    --install-extension bungcip.better-toml \
    --install-extension ms-vscode.sublime-keybindings \
    --install-extension streetsidesoftware.code-spell-checker \
    --install-extension gruntfuggly.todo-tree \
    --install-extension aaron-bond.better-comments \
    --install-extension pkief.material-icon-theme \
    --install-extension zhuangtongfa.material-theme \
    --install-extension dracula-theme.theme-dracula \
    --install-extension github.github-vscode-theme
"

# Setup Jupyter Lab configuration
echo -e "${BLUE} Configuring Jupyter Lab...${NC}"
docker exec claude-dev-env bash -c "
mkdir -p /home/devuser/.jupyter
cat > /home/devuser/.jupyter/jupyter_lab_config.py << 'EOF'
c.ServerApp.ip = '0.0.0.0'
c.ServerApp.port = 8888
c.ServerApp.open_browser = False
c.ServerApp.allow_root = False
c.ServerApp.token = ''
c.ServerApp.password = ''
c.ServerApp.root_dir = '/workspace'
EOF
chown devuser:devuser /home/devuser/.jupyter/jupyter_lab_config.py
"

# Create advanced development aliases
echo -e "${BLUE} Adding advanced aliases...${NC}"
docker exec claude-dev-env bash -c "
cat >> /home/devuser/.zshrc << 'EOF'

# Advanced Development Aliases
# ============================

# Jupyter Lab
alias jupyter-start='jupyter lab --allow-root --ip=0.0.0.0 --port=8888 --no-browser'
alias jupyter-stop='pkill -f jupyter'

# Streamlit
alias streamlit-run='streamlit run --server.port 8501 --server.address 0.0.0.0'

# Database shortcuts
alias postgres-start='sudo service postgresql start'
alias redis-start='sudo service redis-server start'
alias mongo-start='sudo service mongod start'

# Docker development
alias docker-clean='docker system prune -af'
alias docker-logs='docker-compose logs -f'
alias docker-rebuild='docker-compose down && docker-compose build --no-cache && docker-compose up -d'

# Performance monitoring
alias monitor-cpu='htop'
alias monitor-memory='free -h && ps aux --sort=-%mem | head'
alias monitor-disk='df -h'
alias monitor-network='netstat -tuln'

# Code quality tools
alias security-check='bandit -r . && safety check'
alias coverage-report='coverage run -m pytest && coverage report && coverage html'
alias profile-code='python -m cProfile -o profile.stats'

# API development
alias api-test='pytest tests/test_api.py -v'
alias api-docs='python -c \"import webbrowser; webbrowser.open(\\\"http://localhost:8000/docs\\\")\";'
alias api-load-test='locust --host=http://localhost:8000'

# Frontend development
alias frontend-audit='npm audit && npm outdated'
alias frontend-update='npm update && npm audit fix'
alias frontend-clean='rm -rf node_modules package-lock.json && npm install'

# Documentation
alias docs-build='mkdocs build'
alias docs-serve='mkdocs serve --dev-addr 0.0.0.0:8002'
alias docs-deploy='mkdocs gh-deploy'

# Advanced Git workflows
alias git-squash='git rebase -i HEAD~'
alias git-undo='git reset --soft HEAD~1'
alias git-graph='git log --graph --pretty=format:\"%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset\" --abbrev-commit'
alias git-contributors='git shortlog -sn'
alias git-changes='git diff --stat'

# Claude Code advanced workflows
alias claude-review='claude -p \"Perform a comprehensive code review of this project structure and suggest improvements\"'
alias claude-optimize='claude -p \"Use zen with deepseek to analyze performance bottlenecks and suggest optimizations\"'
alias claude-test='claude -p \"Use frontend-testing to generate comprehensive test suites for this codebase\"'
alias claude-docs='claude -p \"Use context7 to get latest documentation and generate project documentation\"'
alias claude-debug='claude -p \"Use zen debugging workflow to trace and fix this issue\"'
alias claude-refactor='claude -p \"Use zen refactoring analysis to improve code structure and maintainability\"'

# Project scaffolding functions
create-fastapi-project() {
    local project_name=\$1
    if [ -z \"\$project_name\" ]; then
        echo \"Usage: create-fastapi-project <project-name>\"
        return 1
    fi
    
    mkdir \$project_name && cd \$project_name
    python -m venv venv
    source venv/bin/activate
    
    pip install fastapi uvicorn python-multipart jinja2 python-jose passlib bcrypt
    pip install pytest pytest-asyncio httpx
    
    mkdir -p app/{api,core,models,schemas,crud,db} tests
    
    cat > app/__init__.py << 'EOFPY'
EOFPY
    
    cat > app/main.py << 'EOFPY'
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI(title=\"\$project_name API\", version=\"1.0.0\")

app.add_middleware(
    CORSMiddleware,
    allow_origins=[\"*\"],
    allow_credentials=True,
    allow_methods=[\"*\"],
    allow_headers=[\"*\"],
)

@app.get(\"/\")
async def root():
    return {\"message\": \"Hello from \$project_name!\"}

@app.get(\"/health\")
async def health_check():
    return {\"status\": \"healthy\"}
EOFPY
    
    cat > requirements.txt << 'EOFREQ'
fastapi
uvicorn[standard]
python-multipart
jinja2
python-jose[cryptography]
passlib[bcrypt]
sqlalchemy
alembic
psycopg2-binary
redis
celery
pydantic
pytest
pytest-asyncio
httpx
EOFREQ
    
    cat > .gitignore << 'EOFGIT'
__pycache__/
*.pyc
*.pyo
*.pyd
.Python
env/
venv/
.venv/
pip-log.txt
.tox/
.coverage
.pytest_cache/
*.log
.env
.DS_Store
EOFGIT
    
    echo \"FastAPI project '\$project_name' created!\"
    echo \"Run: uvicorn app.main:app --reload --host 0.0.0.0 --port 8000\"
}

create-react-project() {
    local project_name=\$1
    if [ -z \"\$project_name\" ]; then
        echo \"Usage: create-react-project <project-name>\"
        return 1
    fi
    
    npx create-react-app \$project_name --template typescript
    cd \$project_name
    
    npm install @types/node @types/react @types/react-dom
    npm install axios react-router-dom @emotion/react @emotion/styled
    npm install -D @testing-library/jest-dom @testing-library/react @testing-library/user-event
    
    echo \"React TypeScript project '\$project_name' created!\"
    echo \"Run: npm start\"
}

create-fullstack-project() {
    local project_name=\$1
    if [ -z \"\$project_name\" ]; then
        echo \"Usage: create-fullstack-project <project-name>\"
        return 1
    fi
    
    mkdir \$project_name && cd \$project_name
    
    # Backend
    create-fastapi-project backend
    cd ..
    
    # Frontend  
    create-react-project frontend
    cd ..
    
    # Docker Compose
    cat > docker-compose.yml << 'EOFDOCKER'
version: '3.8'

services:
  backend:
    build: ./backend
    ports:
      - \"8000:8000\"
    environment:
      - DATABASE_URL=postgresql://user:password@db:5432/appdb
      - REDIS_URL=redis://redis:6379
    depends_on:
      - db
      - redis
    volumes:
      - ./backend:/app
    command: uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload

  frontend:
    build: ./frontend
    ports:
      - \"3000:3000\"
    volumes:
      - ./frontend:/app
      - /app/node_modules
    command: npm start

  db:
    image: postgres:15
    environment:
      POSTGRES_USER: user
      POSTGRES_PASSWORD: password
      POSTGRES_DB: appdb
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - \"5432:5432\"

  redis:
    image: redis:7-alpine
    ports:
      - \"6379:6379\"

volumes:
  postgres_data:
EOFDOCKER
    
    echo \"Full-stack project '\$project_name' created!\"
    echo \"Run: docker-compose up -d\"
}

# Performance monitoring functions
monitor-app() {
    echo \" Application Monitoring Dashboard\"
    echo \"==================================\"
    echo \"CPU Usage: \$(top -bn1 | grep \"Cpu(s)\" | awk '{print \$2}' | awk -F'%' '{print \$1}')%\"
    echo \"Memory Usage: \$(free | grep Mem | awk '{printf(\"%.2f%%\", \$3/\$2 * 100.0)}')\"
    echo \"Disk Usage: \$(df -h / | awk 'NR==2{printf \"%s\", \$5}')\"
    echo \"Active Connections: \$(netstat -an | grep ESTABLISHED | wc -l)\"
    echo \"Running Processes: \$(ps aux | wc -l)\"
}

profile-python() {
    local script=\$1
    if [ -z \"\$script\" ]; then
        echo \"Usage: profile-python <script.py>\"
        return 1
    fi
    
    echo \" Profiling \$script...\"
    python -m cProfile -o \$script.profile \$script
    python -c \"
import pstats
p = pstats.Stats('\$script.profile')
p.sort_stats('cumulative').print_stats(20)
\"
}

benchmark-api() {
    local url=\${1:-http://localhost:8000}
    echo \" Benchmarking API at \$url\"
    
    # Simple load test
    ab -n 1000 -c 10 \$url/ || echo \"Install apache2-utils for 'ab' command\"
    
    # Or use curl for basic test
    echo \"Response time test:\"
    curl -w \"@-\" -o /dev/null -s \"\$url\" << 'EOF'
     time_namelookup:  %{time_namelookup}\n
        time_connect:  %{time_connect}\n
     time_appconnect:  %{time_appconnect}\n
    time_pretransfer:  %{time_pretransfer}\n
       time_redirect:  %{time_redirect}\n
  time_starttransfer:  %{time_starttransfer}\n
                     ----------\n
          time_total:  %{time_total}\n
EOF
}

EOF
"

echo -e "${GREEN} Advanced development tools installed!${NC}"
echo ""
echo "New features available:"
echo "• Jupyter Lab: jupyter-start"
echo "• Project creation: create-fastapi-project, create-react-project, create-fullstack-project"
echo "• Monitoring: monitor-app, profile-python, benchmark-api"
echo "• Claude workflows: claude-review, claude-optimize, claude-test"
echo "• Database tools: postgres-start, redis-start, mongo-start"
echo ""
echo "Restart your shell or run: source ~/.zshrc"
