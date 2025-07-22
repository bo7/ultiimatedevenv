# Contributing to Docker Development Environment

Thank you for your interest in contributing! This project uses a **fork-based workflow** to ensure code quality and security. This guide will walk you through the entire contribution process.

## 🔄 Fork-Based Workflow Overview

We use fork-based contributions instead of direct repository access. This means:
- ✅ **No direct push access** to the main repository
- ✅ **All changes via Pull Requests** from your fork
- ✅ **Safe and secure** contribution process
- ✅ **Standard open source practice**

## 🚀 Quick Start for Contributors

### 1. Fork the Repository
```bash
# On GitHub, click "Fork" button on the main repository
# This creates your own copy of the repository
```

### 2. Clone Your Fork
```bash
# Clone your fork (not the original repository)
git clone https://github.com/YOUR_USERNAME/docker-dev-environment.git
cd docker-dev-environment

# Add the original repository as upstream
git remote add upstream https://github.com/ORIGINAL_OWNER/docker-dev-environment.git
```

### 3. Set Up Development Environment
```bash
# Run the setup script
./setup.sh

# This will:
# - Install git hooks (including emoji removal)
# - Set up Docker environment
# - Configure development tools
```

### 4. Create a Feature Branch
```bash
# Always create a new branch for your changes
git checkout -b feature/your-feature-name

# Examples:
git checkout -b feature/add-new-mcp-server
git checkout -b fix/docker-build-issue
git checkout -b docs/improve-readme
```

### 5. Make Your Changes
```bash
# Make your changes
# Edit files, add features, fix bugs, etc.

# Test your changes
./manage.sh build  # Test Docker build
./manage.sh test   # Run tests (if available)

# The pre-push hook will automatically remove emojis
```

### 6. Commit Your Changes
```bash
# Stage your changes
git add .

# Commit with a descriptive message
git commit -m "feat: add new MCP server for database connections

- Add PostgreSQL MCP server configuration
- Update documentation with setup instructions
- Add example usage in README"

# Follow conventional commit format:
# feat: new feature
# fix: bug fix
# docs: documentation changes
# chore: maintenance tasks
# refactor: code refactoring
```

### 7. Keep Your Fork Updated
```bash
# Before creating PR, sync with upstream
git fetch upstream
git checkout main
git merge upstream/main
git push origin main

# Rebase your feature branch
git checkout feature/your-feature-name
git rebase main
```

### 8. Push and Create Pull Request
```bash
# Push your feature branch to your fork
git push origin feature/your-feature-name

# Go to GitHub and create a Pull Request:
# - From: your-fork/feature-branch
# - To: original-repo/main
# - Fill out the PR template with details
```

## 📋 Contribution Guidelines

### What We Welcome
- ✅ **New MCP servers** and integrations
- ✅ **Development tools** and configurations
- ✅ **Documentation improvements**
- ✅ **Bug fixes** and error handling
- ✅ **Performance optimizations**
- ✅ **Docker environment enhancements**
- ✅ **Testing and automation**

### Code Standards
- ✅ **No emojis** in code (automatically removed by pre-push hook)
- ✅ **Clear commit messages** following conventional commit format
- ✅ **Documentation** for new features
- ✅ **Testing** when applicable
- ✅ **Docker compatibility** maintained

### File Structure for New Features
```
your-feature/
├── docs/                    # Documentation for your feature
│   └── your-feature.md
├── configs/                 # Configuration files
│   └── your-feature.json
├── scripts/                 # Helper scripts
│   └── install-your-feature.sh
└── examples/               # Usage examples
    └── your-feature-example/
```

## 🧪 Testing Your Contributions

### Local Testing
```bash
# Test Docker build
./manage.sh build

# Test container startup
./manage.sh start
./manage.sh enter

# Test your changes inside container
cd /workspace
# Test your feature here

# Clean up
./manage.sh stop
./manage.sh clean
```

### Automated Testing
- GitHub Actions will automatically test your PR
- Docker build must succeed
- Setup scripts must work correctly
- No security vulnerabilities introduced

## 📝 Pull Request Process

### PR Requirements
1. **Descriptive title** and description
2. **Reference issues** if applicable (#123)
3. **Include screenshots** for UI changes
4. **Update documentation** if needed
5. **Add tests** when applicable

### Review Process
1. **Automated checks** must pass
2. **Code review** by maintainers
3. **Approval required** before merge
4. **Squash and merge** to main branch

### PR Template
When creating a PR, fill out our template:
- Description of changes
- Type of change (feature/fix/docs)
- Testing performed
- Screenshots (if applicable)
- Checklist completion

## 🛠️ Common Contribution Types

### Adding a New MCP Server
1. Create configuration in `configs/mcp-servers/`
2. Add documentation in `docs/mcp-servers/`
3. Update setup scripts if needed
4. Add usage examples

### Improving Documentation
1. Update relevant `.md` files
2. Ensure links work correctly
3. Add examples where helpful
4. Test documentation locally

### Fixing Bugs
1. Reference the issue number
2. Include reproduction steps in PR
3. Add tests to prevent regression
4. Update documentation if needed

### Adding Development Tools
1. Update Dockerfile if needed
2. Add configuration files
3. Document installation and usage
4. Test in clean environment

## 🔧 Development Environment Details

### Container Development
- Work inside the Docker container for best compatibility
- Use `/workspace` for your projects
- Container includes all necessary development tools

### Git Configuration Inside Container
```bash
# Configure git inside container
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# Set up SSH keys for GitHub if needed
ssh-keygen -t ed25519 -C "your.email@example.com"
cat ~/.ssh/id_ed25519.pub  # Add to GitHub
```

### Debugging Issues
- Check Docker logs: `docker logs claude-dev-env`
- Test setup script: `./setup.sh`
- Verify environment: `./manage.sh status`
- Check inside container: `./manage.sh enter`

## 🆘 Getting Help

### Before Asking for Help
1. Search existing issues and discussions
2. Check documentation thoroughly
3. Test with a clean setup
4. Provide detailed information

### How to Get Help
- **GitHub Issues**: For bugs and feature requests
- **GitHub Discussions**: For questions and general help
- **Documentation**: Check README and guides
- **Examples**: Look at existing configurations

### Reporting Issues
Use our issue templates:
- **Bug Report**: For problems and errors
- **Feature Request**: For new functionality
- **Documentation**: For documentation improvements
- **Question**: For general help

## 🎉 Recognition

Contributors will be:
- ✅ **Listed in contributors** section
- ✅ **Mentioned in release notes** for significant contributions
- ✅ **Invited to collaborate** on related projects
- ✅ **Given feedback** and guidance for improvement

## 📚 Additional Resources

- [GitHub Flow Guide](https://guides.github.com/introduction/flow/)
- [Conventional Commits](https://www.conventionalcommits.org/)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [MCP Server Documentation](https://modelcontextprotocol.io/)

## 🤝 Code of Conduct

Be respectful, inclusive, and constructive in all interactions. We're here to build something great together!

---

**Thank you for contributing to the Docker Development Environment project!** 

Your contributions help make AI-powered development accessible to everyone.
