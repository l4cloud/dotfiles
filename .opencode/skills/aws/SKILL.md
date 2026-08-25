---
name: aws
description: AWS, TGW, routing, VPC, Identity Center, and read-only troubleshooting. Use when the user asks about AWS networking issues, Transit Gateway, routes, SSO auth, or account selection.
---

# AWS Troubleshooting

- Use AWS CLI only in read-only mode.
- Prefer AWS Identity Center (SSO) auth.
- If auth is needed:
  - run `aws sso login --profile <profile>`
  - list accessible accounts
  - pick an account with `fzf` if available
  - fall back to a numbered selection if not
  - list roles for the chosen account
  - default role: `SSO-ViewOnly`
- If you need a quick picker, use this pattern:

```bash
accounts_json="$(aws sso list-accounts --profile "$AWS_PROFILE" --output json)"
choices="$(python3 - <<'PY' "$accounts_json"
import json,sys
data=json.loads(sys.argv[1])
for a in data.get('accountList', []):
    print(f"{a['accountName']}\t{a['accountId']}")
PY
)"
selected="$(printf '%s\n' "$choices" | fzf --prompt='AWS account> ' | cut -f2)"
```

- Helpful read-only commands:
  - `aws sts get-caller-identity`
  - `aws ec2 describe-transit-gateways`
  - `aws ec2 describe-transit-gateway-route-tables`
  - `aws ec2 search-transit-gateway-routes`
  - `aws ec2 describe-route-tables`
  - `aws ec2 describe-vpcs`
  - `aws ec2 describe-subnets`
  - `aws ec2 describe-network-interfaces`
- Focus on:
  - TGW attachments
  - route propagation
  - static vs propagated routes
  - VPC route tables
  - blackhole or asymmetric routing
