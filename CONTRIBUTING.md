# Contributing to Claude Development Environment

##  Welcome Contributors!

Thank you for your interest in contributing to this AI-powered development environment!

##  Getting Started

1. **Fork the repository**
2. **Clone your fork**
3. **Create a feature branch**
4. **Make your changes**
5. **Test thoroughly**
6. **Submit a pull request**

##  Development Setup

```bash
# Clone your fork
git clone https://github.com/yourusername/claude-dev-environment.git
cd claude-dev-environment

# Setup development environment
./setup.sh

# Create your environment file
cp .env_template_master .env
# Add your API keys and configuration
```

##  Contribution Guidelines

### **Code Style**
- Follow existing code patterns
- Use clear, descriptive commit messages
- Add documentation for new features
- Test all changes thoroughly

### **Areas for Contribution**
- **New MCP servers** - Add support for additional AI tools
- **Docker environments** - New specialized development containers
- **Editor configurations** - Enhance Neovim setup or add other editors
- **Documentation** - Improve guides and examples
- **Testing** - Add automated tests and validation
- **Templates** - New project templates and configurations

### **Pull Request Process**
1. Update documentation for any new features
2. Add tests where applicable
3. Ensure all existing tests pass
4. Update README if needed
5. Get review from maintainers

##  Bug Reports

Please use GitHub Issues for bug reports. Include:
- Steps to reproduce
- Expected vs actual behavior
- Environment details (OS, Docker version, etc.)
- Relevant log output

##  Feature Requests

We welcome feature requests! Please:
- Check existing issues first
- Describe the use case clearly
- Explain how it benefits users
- Consider implementation complexity

##  License

By contributing, you agree that your contributions will be licensed under the Apache 2.0 License.
