#!/bin/bash

echo "🛡️  Setting up Rails AI Monitoring System"
echo "========================================"

# Create monitoring directory
mkdir -p monitoring
cd monitoring

# Create Google Alerts setup guide
cat > google_alerts_setup.md << 'GUIDE'
# Google Alerts Setup for Rails AI

## Step 1: Go to Google Alerts
Visit: https://www.google.com/alerts

## Step 2: Create Alerts for These Terms:
- "Rails AI" commercial
- "rails_ai" business
- "Rails AI" enterprise
- "rails_ai" license
- "Rails AI" gem
- "rails_ai" ruby

## Step 3: Configure Each Alert:
- Frequency: As-it-happens
- Sources: Everything
- Language: English
- Region: Any region
- Delivery: Your email

## Step 4: Test Alerts
Search for your terms manually to ensure alerts work.
GUIDE

# Create GitHub monitoring guide
cat > github_monitoring.md << 'GITHUB'
# GitHub Monitoring for Rails AI

## Manual Searches (Run Weekly):
1. Go to https://github.com/search
2. Search for: "rails_ai" language:ruby
3. Search for: "Rails AI" language:ruby
4. Search for: "rails-ai" language:ruby
5. Search for: "railsai" language:ruby

## GitHub Notifications Setup:
1. Go to GitHub.com → Settings → Notifications
2. Enable email notifications for mentions
3. Watch relevant repositories
4. Set up keyword notifications

## What to Look For:
- Repositories using your gem
- Forks of your code
- Similar project names
- Commercial usage indicators
GITHUB

# Create RubyGems monitoring guide
cat > rubygems_monitoring.md << 'RUBYGEMS'
# RubyGems Monitoring for Rails AI

## Manual Checks (Run Weekly):
1. Go to https://rubygems.org
2. Search for: "rails_ai"
3. Search for: "rails-ai"
4. Search for: "railsai"
5. Check download statistics

## What to Look For:
- Similar gem names
- High download numbers
- Commercial usage in descriptions
- Forked or copied code

## API Access (Optional):
- Get RubyGems API key for automated monitoring
- Use the monitoring script with API access
RUBYGEMS

# Create social media monitoring guide
cat > social_media_monitoring.md << 'SOCIAL'
# Social Media Monitoring for Rails AI

## Twitter/X:
1. Search for: "Rails AI"
2. Search for: "rails_ai"
3. Set up keyword notifications
4. Monitor relevant hashtags

## LinkedIn:
1. Search for: "Rails AI"
2. Search for: "rails_ai"
3. Look for company mentions
4. Check job postings

## Reddit:
1. Search r/ruby for "Rails AI"
2. Search r/rails for "rails_ai"
3. Search r/programming for mentions
4. Monitor for commercial usage

## Stack Overflow:
1. Search for: "rails_ai"
2. Search for: "Rails AI"
3. Look for commercial usage questions
4. Monitor for licensing discussions
SOCIAL

# Create monitoring checklist
cat > monitoring_checklist.md << 'CHECKLIST'
# Rails AI Monitoring Checklist

## Daily Tasks:
- [ ] Check Google Alerts email
- [ ] Check GitHub notifications
- [ ] Check social media mentions

## Weekly Tasks:
- [ ] Run GitHub searches
- [ ] Check RubyGems.org
- [ ] Search social media platforms
- [ ] Check business directories

## Monthly Tasks:
- [ ] Legal database searches
- [ ] Patent database checks
- [ ] Industry publication reviews
- [ ] Update monitoring terms

## When You Find Infringement:
- [ ] Document everything (screenshots)
- [ ] Save evidence to multiple locations
- [ ] Send cease and desist letter
- [ ] File DMCA takedowns if applicable
- [ ] Consult with IP lawyer

## Emergency Contacts:
- IP Lawyer: [Add your lawyer's contact]
- CIPO: 1-866-997-1936
- Copyright Board: 613-952-8621
CHECKLIST

# Make the monitoring script executable
chmod +x ../monitoring_script.rb

echo "✅ Monitoring setup complete!"
echo ""
echo "📁 Created monitoring directory with guides:"
echo "   - google_alerts_setup.md"
echo "   - github_monitoring.md"
echo "   - rubygems_monitoring.md"
echo "   - social_media_monitoring.md"
echo "   - monitoring_checklist.md"
echo ""
echo "🚀 Next steps:"
echo "1. Set up Google Alerts (see google_alerts_setup.md)"
echo "2. Configure GitHub notifications (see github_monitoring.md)"
echo "3. Run weekly manual checks (see monitoring_checklist.md)"
echo "4. Run the monitoring script: ruby monitoring_script.rb"
echo ""
echo "🛡️  Your Rails AI is now protected with monitoring!"
