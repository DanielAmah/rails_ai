# Release Process

This document outlines the process for releasing new versions of Rails AI.

## 🏷️ Version Numbering

We follow [Semantic Versioning](https://semver.org/):

- **MAJOR** (1.0.0): Breaking changes, major features
- **MINOR** (0.2.0): New features, backward compatible
- **PATCH** (0.1.1): Bug fixes, minor improvements

### Version Examples

```
0.1.0  - Initial release
0.1.1  - Bug fixes
0.1.2  - Security patches
0.2.0  - New features (backward compatible)
0.2.1  - Bug fixes for 0.2.0
1.0.0  - Major release with breaking changes
1.0.1  - Bug fixes for 1.0.0
```

## 🚀 Release Checklist

### Pre-Release

- [ ] All tests pass
- [ ] Code follows style guidelines
- [ ] Documentation is updated
- [ ] CHANGELOG.md is updated
- [ ] Version is bumped
- [ ] Breaking changes are documented
- [ ] Migration guide is created (if needed)

### Release

- [ ] Tag is created
- [ ] Gem is built
- [ ] Gem is pushed to RubyGems
- [ ] GitHub release is created
- [ ] Announcement is posted

### Post-Release

- [ ] Monitor for issues
- [ ] Update documentation
- [ ] Respond to feedback
- [ ] Plan next release

## 📝 Release Steps

### 1. Update Version

```ruby
# lib/rails_ai/version.rb
module RailsAi
  VERSION = "0.1.1"
end
```

### 2. Update CHANGELOG

```markdown
# CHANGELOG.md

## [0.1.1] - 2024-01-15

### Added
- New feature X
- New feature Y

### Changed
- Improved performance of Z
- Updated documentation

### Fixed
- Bug fix A
- Bug fix B

### Security
- Security fix C
```

### 3. Run Tests

```bash
# Run all tests
bundle exec rspec

# Run against all Rails versions
bundle exec appraisal rspec

# Run linter
bundle exec standardrb

# Run security audit
bundle audit
```

### 4. Build Gem

```bash
# Build the gem
gem build rails_ai.gemspec

# Verify gem contents
gem contents rails_ai-0.1.1.gem
```

### 5. Test Gem

```bash
# Install gem locally
gem install rails_ai-0.1.1.gem

# Test in new Rails app
rails new test_app
cd test_app
echo 'gem "rails_ai"' >> Gemfile
bundle install
rails generate rails_ai:install
```

### 6. Create Tag

```bash
# Create and push tag
git tag -a v0.1.1 -m "Release version 0.1.1"
git push origin v0.1.1
```

### 7. Push to RubyGems

```bash
# Push to RubyGems
gem push rails_ai-0.1.1.gem
```

### 8. Create GitHub Release

1. Go to [GitHub Releases](https://github.com/yourusername/rails_ai/releases)
2. Click "Create a new release"
3. Select tag `v0.1.1`
4. Add release title: "Rails AI 0.1.1"
5. Add release notes from CHANGELOG
6. Click "Publish release"

## 🔄 Automated Release

### GitHub Actions Workflow

```yaml
# .github/workflows/release.yml
name: Release

on:
  push:
    tags:
      - 'v*'

jobs:
  release:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Set up Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: 3.2
          
      - name: Install dependencies
        run: bundle install
        
      - name: Run tests
        run: bundle exec rspec
        
      - name: Run linter
        run: bundle exec standardrb
        
      - name: Build gem
        run: gem build rails_ai.gemspec
        
      - name: Push to RubyGems
        run: gem push rails_ai-*.gem
        env:
          RUBYGEMS_API_KEY: ${{ secrets.RUBYGEMS_API_KEY }}
```

### Release Script

```bash
#!/bin/bash
# scripts/release.sh

set -e

VERSION=$1

if [ -z "$VERSION" ]; then
  echo "Usage: $0 <version>"
  echo "Example: $0 0.1.1"
  exit 1
fi

echo "Releasing version $VERSION..."

# Update version
echo "Updating version to $VERSION..."
sed -i "s/VERSION = \".*\"/VERSION = \"$VERSION\"/" lib/rails_ai/version.rb

# Run tests
echo "Running tests..."
bundle exec rspec

# Run linter
echo "Running linter..."
bundle exec standardrb

# Build gem
echo "Building gem..."
gem build rails_ai.gemspec

# Create tag
echo "Creating tag v$VERSION..."
git add lib/rails_ai/version.rb
git commit -m "Bump version to $VERSION"
git tag -a "v$VERSION" -m "Release version $VERSION"

# Push changes
echo "Pushing changes..."
git push origin main
git push origin "v$VERSION"

# Push to RubyGems
echo "Pushing to RubyGems..."
gem push "rails_ai-$VERSION.gem"

echo "Release $VERSION completed!"
```

## 📋 Release Types

### Patch Release (0.1.1)

**When to release:**
- Bug fixes
- Security patches
- Documentation updates
- Minor improvements

**Process:**
1. Create bug fix branch
2. Fix the issue
3. Add test coverage
4. Update CHANGELOG
5. Bump patch version
6. Create pull request
7. Merge and release

### Minor Release (0.2.0)

**When to release:**
- New features
- New providers
- Performance improvements
- New Rails version support

**Process:**
1. Create feature branch
2. Implement feature
3. Add comprehensive tests
4. Update documentation
5. Update CHANGELOG
6. Bump minor version
7. Create pull request
8. Merge and release

### Major Release (1.0.0)

**When to release:**
- Breaking changes
- Major architecture changes
- API redesign
- Dropping support for old Rails versions

**Process:**
1. Create major release branch
2. Implement breaking changes
3. Create migration guide
4. Update all documentation
5. Update CHANGELOG with breaking changes
6. Bump major version
7. Create pull request
8. Merge and release
9. Announce breaking changes

## 🔒 Security Releases

### Security Patch Process

1. **Immediate Response**
   - Create security branch
   - Fix the vulnerability
   - Add security tests
   - Create patch release

2. **Communication**
   - Update security advisory
   - Notify users via GitHub
   - Post security notice

3. **Follow-up**
   - Monitor for issues
   - Provide additional patches if needed
   - Update security documentation

### Security Release Example

```markdown
# Security Release: 0.1.2

## Security Fixes

- Fixed XSS vulnerability in image analysis
- Patched SQL injection in context handling
- Updated dependencies with security fixes

## Impact

- All users should upgrade immediately
- No breaking changes
- Backward compatible

## Upgrade

```bash
bundle update rails_ai
```
```

## 📊 Release Metrics

### Tracking Metrics

- **Downloads**: Track gem downloads
- **Issues**: Monitor issue reports
- **Performance**: Track performance metrics
- **Adoption**: Monitor adoption rate

### Release Success Criteria

- [ ] All tests pass
- [ ] No critical issues reported
- [ ] Performance maintained or improved
- [ ] Documentation is complete
- [ ] Community feedback is positive

## 🚨 Rollback Process

### When to Rollback

- Critical bugs discovered
- Performance regression
- Security issues
- Breaking changes not documented

### Rollback Steps

1. **Immediate Action**
   - Revert to previous version
   - Update RubyGems
   - Notify users

2. **Investigation**
   - Identify root cause
   - Fix the issue
   - Test thoroughly

3. **Re-release**
   - Create new patch version
   - Include fix
   - Communicate with users

### Rollback Example

```bash
# Revert to previous version
git revert <commit-hash>

# Create new patch
git tag -a v0.1.3 -m "Rollback and fix for 0.1.2"
git push origin v0.1.3

# Push to RubyGems
gem push rails_ai-0.1.3.gem
```

## 📚 Release Documentation

### Release Notes Template

```markdown
# Rails AI 0.1.1 Release Notes

## What's New

### Features
- New feature X
- New feature Y

### Improvements
- Improved performance of Z
- Better error handling

### Fixes
- Fixed bug A
- Fixed bug B

## Breaking Changes

None in this release.

## Migration Guide

No migration needed for this release.

## Upgrade Instructions

```bash
bundle update rails_ai
```

## Full Changelog

See [CHANGELOG.md](CHANGELOG.md) for complete details.
```

## 🎯 Release Best Practices

### Before Release

- Test thoroughly
- Document everything
- Get code review
- Plan communication

### During Release

- Follow process strictly
- Test each step
- Monitor for issues
- Communicate clearly

### After Release

- Monitor metrics
- Respond to issues
- Gather feedback
- Plan next release

---

Following this release process ensures reliable, high-quality releases for Rails AI. 🚀
