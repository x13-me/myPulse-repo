#!/bin/bash
# setup_upstream.sh
# Run this in the upstream GitLab repo (pulse-agent-opnsense) to configure CI integration

set -eu

REPO="ryanstead/pulse-agent-opnsense"
GITHUB_REPO="x13-me/myPulse-repo"

echo "Setting up upstream CI integration for $REPO"
echo ""

# Check for gh CLI
if ! command -v gh &> /dev/null; then
    echo "ERROR: gh CLI not found. Install from https://cli.github.com/"
    exit 1
fi

# Check for glab CLI (GitLab CLI)
if ! command -v glab &> /dev/null; then
    echo "NOTE: glab CLI not found. You'll need to manually add CI variables in GitLab UI."
    echo "Visit: https://gitlab.com/$REPO/-/settings/ci_cd"
else
    echo "glab CLI found. Adding CI/CD variables..."
    
    # Prompt for GitHub PAT
    read -sp "Enter GitHub PAT with 'repo' scope: " GITHUB_PAT
    echo ""
    
    if [ -n "$GITHUB_PAT" ]; then
        glab variable set GITHUB_DISPATCH_TOKEN "$GITHUB_PAT" --repo "$REPO" --masked
        echo "✓ Added GITHUB_DISPATCH_TOKEN to GitLab CI/CD variables"
    fi
fi

echo ""
echo "=== Manual Steps Required ==="
echo ""
echo "1. Add GitHub Pages pkg repo URL to GitLab CI/CD variables (optional):"
echo "   Visit: https://gitlab.com/$REPO/-/settings/ci_cd"
echo "   Add variable: PKG_REPO_URL = https://x13-me.github.io/myPulse-repo/pkg"
echo ""
echo "2. Configure GitLab webhook (optional - for automatic builds on tag push):"
echo "   Visit: https://gitlab.com/$REPO/-/settings/webhooks"
echo "   URL: https://api.github.com/repos/x13-me/myPulse-repo/dispatches"
echo "   Secret: (leave blank or add HMAC secret)"
echo "   Trigger: Push events, Tag push events"
echo "   Headers: Content-Type: application/json"
echo ""
echo "3. Add required secrets to GitHub repo:"
echo "   Visit: https://github.com/x13-me/myPulse-repo/settings/secrets/actions"
echo "   - UPSTREAM_PAT: GitLab PAT with 'read_repository' scope"
echo "   - GITLAB_TOKEN: (optional) GitLab PAT with 'write_package_registry' scope"
echo ""
echo "4. Enable GitHub Pages (after first workflow run creates gh-pages branch):"
echo "   Visit: https://github.com/x13-me/myPulse-repo/settings/pages"
echo "   Source: Deploy from branch → gh-pages / (root)"
echo ""
echo "5. Test the integration:"
echo "   cd /path/to/pulse-agent-opnsense"
echo "   git tag v0.2.4"
echo "   git push origin v0.2.4"
echo "   # Check GitHub Actions: https://github.com/x13-me/myPulse-repo/actions"
echo ""
echo "Done! Check GitHub Actions at: https://github.com/x13-me/myPulse-repo/actions"