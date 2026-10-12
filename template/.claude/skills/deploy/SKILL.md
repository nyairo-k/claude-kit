---
name: deploy
description: Deploy this project to production or staging. Use when the user says deploy, ship, release, or push to prod/staging.
---
# Deploy

1. Confirm target (staging or production) with the user. Never assume production.
2. Run tests and lint; stop if either fails.
3. Follow the steps in [deploy-config.md](deploy-config.md) for the chosen target.
4. After deploy, hit the health-check URL and report the result.
