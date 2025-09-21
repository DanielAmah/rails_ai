# CI Monitoring Setup Guide

## 🚀 Continuous Monitoring via GitHub Actions

Your Rails AI gem now has automated monitoring that runs continuously!

## 📋 What's Set Up

### 1. Daily Monitoring Workflow (`.github/workflows/monitoring.yml`)
- **Runs**: Every day at 9 AM UTC
- **Manual**: Can be triggered manually
- **Triggers**: On pushes to main branch
- **Checks**: RubyGems, GitHub, Google searches
- **Outputs**: Monitoring reports and logs

### 2. Security Monitoring Workflow (`.github/workflows/security-monitoring.yml`)
- **Runs**: Every 6 hours
- **Focus**: Security and plagiarism detection
- **Checks**: Code similarity, package conflicts
- **Outputs**: Security reports

## 🔧 Setup Steps

### Step 1: Enable GitHub Actions
1. Go to your GitHub repository
2. Click "Actions" tab
3. Enable GitHub Actions if not already enabled

### Step 2: Add API Keys (Optional but Recommended)
1. Go to repository Settings → Secrets and variables → Actions
2. Add these secrets:
   - `GOOGLE_API_KEY`: For Google search monitoring
   - `GITHUB_PAT`: For GitHub API access
   - `RUBYGEMS_API_KEY`: For RubyGems API access

### Step 3: Test the Workflows
1. Go to Actions tab
2. Click "Rails AI Monitoring"
3. Click "Run workflow" to test manually

## �� Monitoring Outputs

### Daily Reports
- **Location**: Actions → Artifacts
- **Files**: `monitoring-results-{run_number}`
- **Content**: Detailed monitoring logs

### Security Reports
- **Location**: Actions → Artifacts
- **Files**: `security-report-{run_number}`
- **Content**: Security and plagiarism checks

## 🔔 Notifications

### Email Notifications
- GitHub will email you when workflows fail
- Set up email notifications in GitHub settings

### Slack/Discord Integration (Optional)
Add this to your workflow for Slack notifications:

```yaml
- name: Notify Slack
  if: failure()
  uses: 8398a7/action-slack@v3
  with:
    status: failure
    text: "Rails AI monitoring found potential issues!"
  env:
    SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK_URL }}
```

## 📈 Monitoring Schedule

### Daily (9 AM UTC)
- RubyGems package monitoring
- GitHub repository searches
- Google search monitoring
- Generate monitoring report

### Every 6 Hours
- Security checks
- Code plagiarism detection
- Package conflict detection
- Generate security report

## 🛠️ Customization

### Change Schedule
Edit the cron expressions in the workflow files:
```yaml
schedule:
  - cron: '0 9 * * *'  # Daily at 9 AM UTC
  - cron: '0 */6 * * *'  # Every 6 hours
```

### Add More Checks
Add new monitoring steps to the workflow:
```yaml
- name: Check specific website
  run: |
    curl -s "https://example.com/search?q=rails_ai" | grep -i "commercial"
```

### Add More APIs
Add API keys to repository secrets and use them:
```yaml
env:
  CUSTOM_API_KEY: ${{ secrets.CUSTOM_API_KEY }}
```

## 📱 Mobile Monitoring

### GitHub Mobile App
- Get notifications on your phone
- View monitoring results anywhere
- Respond to alerts immediately

### Email Alerts
- Set up email notifications for failures
- Get daily monitoring summaries
- Receive security alerts

## 🔍 What Gets Monitored

### RubyGems
- New packages with similar names
- Commercial usage in descriptions
- Download statistics
- Package dependencies

### GitHub
- Repositories using your gem
- Forks of your code
- Similar project names
- Commercial usage indicators

### Google Search
- Web mentions of your gem
- Commercial usage discussions
- Competitor analysis
- Brand monitoring

## 🚨 Alert Conditions

### High Priority
- Direct code copying
- Commercial use without license
- Trademark infringement
- Patent violations

### Medium Priority
- Similar package names
- Competitive analysis
- Usage discussions
- Feature requests

### Low Priority
- General mentions
- Educational usage
- Open source contributions
- Community discussions

## 📊 Monitoring Dashboard

### GitHub Actions Tab
- View all monitoring runs
- See success/failure status
- Download monitoring reports
- View detailed logs

### Artifacts
- Download monitoring results
- View security reports
- Analyze trends over time
- Share reports with legal team

## 🔧 Troubleshooting

### Common Issues
1. **Workflow not running**: Check if GitHub Actions is enabled
2. **API errors**: Verify API keys are set correctly
3. **Permission errors**: Check repository permissions
4. **Rate limiting**: Add delays between API calls

### Debug Mode
Add this to see detailed logs:
```yaml
- name: Debug monitoring
  run: |
    echo "Debug information:"
    echo "Date: $(date)"
    echo "Ruby version: $(ruby --version)"
    echo "Working directory: $(pwd)"
```

## 📞 Support

### GitHub Actions Documentation
- https://docs.github.com/en/actions

### Monitoring Script Issues
- Check the monitoring_script.rb file
- Review the monitoring logs
- Test locally first

### Legal Questions
- Contact your IP lawyer
- Review the legal protection guide
- Use the cease and desist template

---

**Your Rails AI gem is now continuously monitored! 🛡️**
