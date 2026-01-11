# AWS CLI SSO SETUP & TOOLKIT - Complete Guide

**Updated:** December 17, 2025  
**For:** macOS, Linux, WSL2  
**Includes:** Enhanced fzf-powered commands

---

## 🎯 Overview

This guide covers:
1. ✅ Complete AWS SSO setup (your original guide)
2. ✅ Enhanced terminal toolkit with fzf integration
3. ✅ Common workflows and troubleshooting

**What Makes This Better:**
- No more forgetting profile names (fzf shows them all)
- No more typing long commands (simple shortcuts)
- Login to all profiles at once
- Check session status instantly
- Switch profiles with fzf menu

---

## 📦 Prerequisites

- **macOS, Linux, or WSL2**
- **AWS CLI v2** (SSO requires v2)

Verify version:
```bash
aws --version
# Should show: aws-cli/2.x.x
```

---

## 🚀 Quick Start (New Users)

### 1. Setup Your First SSO Profile:
```bash
awssetup
```

This runs `aws configure sso` interactively and guides you through:
- SSO start URL
- SSO region
- Account selection
- Role selection
- Profile name

### 2. Login:
```bash
awslogin
```

fzf menu appears → select profile → browser opens → authenticate

### 3. Set Active Profile:
```bash
awsuse
```

fzf menu appears → select profile → profile is set

### 4. Use AWS CLI:
```bash
aws s3 ls
aws sts get-caller-identity
```

**Done!** 🎉

---

## 📋 Complete Command Reference

### Authentication Commands:

| Command | What It Does | Example |
|---------|-------------|---------|
| `awslogin` | Login to SSO (fzf picks profile) | Interactive menu |
| `awsl` | Same as awslogin (short alias) | Quick login |
| `awsloginall` | Login to ALL SSO profiles at once | Morning routine |
| `awsla` | Same as awsloginall (short alias) | Bulk login |
| `awsstatus` | Check which sessions are active/expired | Status check |
| `awss` | Same as awsstatus (short alias) | Quick status |

### Profile Management:

| Command | What It Does | Example |
|---------|-------------|---------|
| `awsuse` | Set AWS_PROFILE (fzf picks) | Interactive switch |
| `awsuse prod` | Set specific profile | Direct switch |
| `awsclear` | Unset AWS_PROFILE | Clear env var |
| `awswhoami` | Show current profile & identity | Who am I? |
| `awsw` | Same as awswhoami (short alias) | Quick check |
| `awsprofiles` | List all profiles | See all configs |
| `awsp` | Same as awsprofiles (short alias) | Quick list |

### Setup & Configuration:

| Command | What It Does |
|---------|-------------|
| `awssetup` | Setup new SSO profile (interactive) |
| `awsconfig` | Edit ~/.aws/config in your editor |
| `awshelp` | Show complete help |

---

## 💡 Common Workflows

### Morning Routine (Login to Everything):
```bash
❯ awsloginall
🔐 AWS SSO - Login to ALL profiles

Found 3 SSO profile(s):
  • mycompany-dev
  • mycompany-staging
  • mycompany-prod

Login to all profiles? (y/n): y

[authenticates all profiles]

✅ Success: 3
❌ Failed: 0
```

### Switch Between Profiles:
```bash
# Work on prod
❯ awsuse prod
✅ AWS_PROFILE set to: prod
aws s3 ls

# Switch to dev
❯ awsuse dev
✅ AWS_PROFILE set to: dev
aws s3 ls
```

### Check Session Status:
```bash
❯ awsstatus
📊 AWS SSO Session Status

Checking 3 profile(s)...

✅ mycompany-dev       Active   (Account: 123456789, User: john.doe)
✅ mycompany-staging   Active   (Account: 234567890, User: john.doe)
❌ mycompany-prod      Expired

💡 To refresh expired sessions, run: awslogin
```

### What Profile Am I Using?
```bash
❯ awswhoami
🔍 Current AWS Configuration

Profile: mycompany-prod

Identity:
{
    "UserId": "AROAXXXXXXXXX:john.doe",
    "Account": "123456789012",
    "Arn": "arn:aws:sts::123456789012:assumed-role/AdministratorAccess/john.doe"
}

✅ Session is active
```

---

## 🏗️ File Structure

### ~/.aws/config (Your SSO Profiles)

Example with multiple profiles:

```ini
[profile mycompany-dev]
sso_start_url = https://mycompany.awsapps.com/start
sso_region = us-east-1
sso_account_id = 123456789012
sso_role_name = DeveloperAccess
region = us-east-1
output = json

[profile mycompany-prod]
sso_start_url = https://mycompany.awsapps.com/start
sso_region = us-east-1
sso_account_id = 999999999999
sso_role_name = ReadOnlyAccess
region = us-east-1
output = json

# Role chaining example (advanced)
[profile prod-admin]
source_profile = mycompany-prod
role_arn = arn:aws:iam::999999999999:role/AdminRole
region = us-east-1
```

**Key Points:**
- ✅ No access keys
- ✅ No secrets
- ✅ No session tokens
- ✅ This is correct!

### ~/.aws/credentials

**DO NOT USE for SSO profiles!**

This file should be empty or contain only non-SSO credentials.

### ~/.aws/sso/cache/

Auto-generated. Contains cached SSO credentials.

**Do not edit manually.**

---

## 🎯 Advanced: Role Chaining

Assume additional roles using SSO profile as source:

```ini
[profile prod-readonly]
source_profile = mycompany-sso
role_arn = arn:aws:iam::999999999999:role/ReadOnlyRole
region = us-east-1

[profile prod-admin]
source_profile = mycompany-sso
role_arn = arn:aws:iam::999999999999:role/AdminRole
region = us-east-1
```

Usage:
```bash
awsuse prod-admin
aws s3 ls

# One SSO login, multiple role assumptions!
```

---

## 🔧 Troubleshooting

### Error: "Unable to locate credentials"

**Cause:** Not logged in or session expired

**Fix:**
```bash
awslogin
```

---

### Error: Session expired during work

**Cause:** SSO sessions expire after ~8 hours

**Fix:**
```bash
awslogin
# Re-authenticate without losing your current profile
```

---

### Error: "Which profile am I using?"

**Fix:**
```bash
awswhoami
```

---

### Error: Forgot profile names

**Fix:**
```bash
awsprofiles
# Shows all configured profiles
```

---

### Tool ignores AWS_PROFILE

**Cause:** Some tools require explicit profile flag

**Fix:**
```bash
# Instead of relying on AWS_PROFILE
terraform plan --profile=mycompany-prod

# Or in provider block
provider "aws" {
  profile = "mycompany-prod"
}
```

---

## 🎨 Integration with Tools

### Terraform:
```hcl
provider "aws" {
  profile = "mycompany-prod"
  region  = "us-east-1"
}
```

### kubectl + EKS:
```bash
awsuse dev
aws eks update-kubeconfig --name my-cluster
kubectl get pods
```

### SAM / Serverless:
```bash
awsuse dev
sam deploy --profile mycompany-dev
```

### Docker (ECR):
```bash
awsuse prod
aws ecr get-login-password | docker login --username AWS --password-stdin 123456789012.dkr.ecr.us-east-1.amazonaws.com
```

---

## 📊 Session Management

### Check All Sessions:
```bash
awsstatus
```

### Login to All Profiles (Morning Routine):
```bash
awsloginall
```

### Clear Environment:
```bash
awsclear
```

---

## 🔒 Security Best Practices

### ✅ DO:
- Use SSO profiles (no long-lived credentials)
- Set up MFA on your SSO provider
- Use role chaining for least privilege
- Regularly rotate SSO sessions
- Review profiles periodically: `awsprofiles`

### ❌ DON'T:
- Store credentials in ~/.aws/credentials for SSO
- Share SSO profiles between users
- Commit ~/.aws/config to git (has account IDs)
- Use old AWS CLI v1 for SSO

---

## 📝 Installation

### Add to Your Terminal Setup:

1. Copy the toolkit:
```bash
cp aws-sso-toolkit.zsh ~/.zsh/aws-sso-toolkit.zsh
```

2. Add to your .zshrc:
```bash
# AWS SSO Toolkit
if [ -f ~/.zsh/aws-sso-toolkit.zsh ]; then
  source ~/.zsh/aws-sso-toolkit.zsh
fi
```

3. Reload:
```bash
source ~/.zshrc
```

4. Test:
```bash
awshelp
```

---

## 🎓 Learning Path

### Day 1: Setup
```bash
awssetup          # Configure first profile
awslogin          # Authenticate
awsuse            # Set active profile
aws s3 ls         # Test it works
```

### Day 2: Multiple Profiles
```bash
awssetup          # Add second profile
awsloginall       # Login to both
awsuse            # Switch between them
awsstatus         # Check session status
```

### Day 3: Advanced
```bash
# Add role chaining to ~/.aws/config
awsconfig

# Use chained roles
awsuse prod-admin
aws sts get-caller-identity
```

---

## 📚 Resources

- [AWS SSO Documentation](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-sso.html)
- [AWS CLI v2 Installation](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
- [Role Chaining](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_use_switch-role-cli.html)

---

## 🎉 Benefits of This Setup

### Before (Manual):
```bash
# Have to remember profile name
aws sso login --profile mycompany-dev-us-east-1-developer-access

# Have to remember to set profile
export AWS_PROFILE=mycompany-dev-us-east-1-developer-access

# Can't remember which profiles you have
cat ~/.aws/config | grep profile

# Don't know which sessions are active
# (try commands until one works)
```

### After (With Toolkit):
```bash
# fzf menu of profiles
awslogin

# fzf menu to switch
awsuse

# See all profiles
awsprofiles

# Check all sessions
awsstatus
```

**Way better!** 🚀

---

## 💡 Pro Tips

1. **Morning Routine:**
   ```bash
   awsloginall && awsstatus
   ```

2. **Quick Profile Switch:**
   ```bash
   alias dev='awsuse mycompany-dev'
   alias prod='awsuse mycompany-prod'
   ```

3. **Add to Starship Prompt:**
   ```toml
   [aws]
   format = '[$symbol($profile)]($style) '
   symbol = "☁️ "
   ```

4. **Shell Functions:**
   ```bash
   # Function to run command in specific profile
   awsrun() {
     local profile=$1
     shift
     AWS_PROFILE=$profile "$@"
   }
   
   # Usage: awsrun prod aws s3 ls
   ```

---

**Your AWS SSO workflow is now effortless!** ☁️✨
