# Real Incident Stories & Deep-Dive Scenarios

---

# Incident 1: Cert-Manager DNS01 Cloudflare Challenge Failures

## Situation

We were using cert-manager to automatically issue and renew TLS certificates through Let's Encrypt using the DNS01 challenge with Cloudflare.

Several certificates suddenly failed renewal, generating alerts and putting customer-facing services at risk of certificate expiration.

## Task

I was responsible for identifying why certificate issuance was failing and restoring successful certificate renewals before certificates expired.

## Action

I started by checking the status of the Certificate and Challenge resources:

```bash
kubectl get certificates
kubectl get challenges -A
kubectl describe challenge <challenge-name>
```

The challenge remained in a pending state.

I reviewed cert-manager logs:

```bash
kubectl logs -n cert-manager deploy/cert-manager
```

The logs showed DNS propagation validation failures.

I verified Cloudflare API connectivity, API token permissions, DNS zone configuration, and cert-manager ClusterIssuer configuration.

Further investigation revealed DNS validation was failing because of DNS resolution issues involving authoritative DNS responses.

I worked through DNS validation checks, verified propagation behavior, and corrected the configuration causing the challenge failures.

After validation, I forced certificate reissuance and monitored challenge completion.

## Result

Certificate issuance succeeded, TLS services remained available, and the risk of customer-facing certificate expiration was eliminated.

## Lessons Learned

- Improve DNS monitoring.
- Validate DNS automation changes before production rollout.
- Add alerts for certificate renewal failures.
- Document DNS troubleshooting procedures.

---

# Incident 2: MySQL Performance Degradation

## Situation

Users reported slow application response times during peak business hours.

Application servers appeared healthy, but performance continued deteriorating.

## Task

Identify the bottleneck and restore acceptable application response times.

## Action

I first checked:

```sql
SHOW PROCESSLIST;
```

and reviewed database metrics.

CPU utilization remained moderate, but query execution times increased significantly.

I enabled and reviewed the slow query log and identified a query repeatedly performing full table scans against a large transactions table.

Using:

```sql
EXPLAIN SELECT ...
```

I confirmed indexes were not being used efficiently.

I worked with the development team to review the query pattern and implement indexing improvements.

After testing the changes, we deployed them to production and closely monitored performance.

## Result

- Query execution times dropped significantly.
- Application response times improved.
- Customer complaints stopped.
- Database resource utilization normalized.

## Lessons Learned

- Continuously monitor slow query logs.
- Review indexing strategy as datasets grow.
- Implement proactive database performance monitoring.

---

# Incident 3: PVCs Stuck in Terminating State

## Situation

While performing maintenance in a Kubernetes environment, several Persistent Volume Claims remained stuck in the Terminating state.

This prevented storage cleanup and delayed deployment activities.

## Task

Determine why PVC deletion was blocked and safely complete resource cleanup.

## Action

I began by inspecting PVC details:

```bash
kubectl get pvc
kubectl describe pvc <pvc-name>
```

I discovered Kubernetes finalizers were preventing deletion.

I verified whether pods were still referencing the PVC and checked associated Persistent Volumes.

I reviewed storage controller logs and confirmed that Kubernetes was waiting for cleanup actions that had not completed successfully.

After validating no active workloads were using the volume, I carefully removed the problematic finalizers and verified storage cleanup.

## Result

- PVCs were successfully deleted.
- Storage resources were released.
- Deployment activities resumed normally.

## Lessons Learned

- Always verify workload dependencies before removing finalizers.
- Monitor storage controller health.
- Improve storage lifecycle documentation.

---

# Incident 4: Terraform Deployment Failure

## Situation

A Terraform deployment intended to provision infrastructure failed unexpectedly during execution.

The failure blocked environment deployment and delayed project timelines.

## Task

Identify the root cause, restore deployment functionality, and ensure infrastructure could be provisioned successfully.

## Action

I reviewed Terraform execution logs:

```bash
terraform validate
terraform plan
terraform apply
```

The error pointed to provider configuration and resource dependency issues.

I systematically isolated the affected module, reviewed state consistency, verified provider authentication, and checked resource definitions.

The root cause was an incorrect configuration within the infrastructure module that resulted in resource creation failures.

After correcting the configuration, validating the plan, and testing in a non-production environment, I redeployed successfully.

## Result

- Infrastructure deployment completed successfully.
- Deployment delays were minimized.
- Additional validation checks were introduced into deployment workflows.

## Lessons Learned

- Validate infrastructure changes before production deployment.
- Use peer review for Terraform changes.
- Improve module testing and validation.

---

# Incident 5: Apache/Nginx Production Outage

## Situation

A customer-facing application suddenly became unavailable and users reported inability to access the service.

## Task

Restore service availability quickly while minimizing customer impact.

## Action

I first confirmed the outage and checked service status:

```bash
systemctl status nginx
```

or

```bash
systemctl status httpd
```

I reviewed application and system logs:

```bash
journalctl -xe
tail -f /var/log/nginx/error.log
```

The logs revealed configuration-related issues that prevented the web server from serving requests properly.

I validated the configuration:

```bash
nginx -t
```

or

```bash
apachectl configtest
```

After correcting the configuration and restarting the service, I verified application functionality and monitored traffic.

## Result

- Service availability was restored.
- Customer impact was minimized.
- Additional validation procedures were introduced before future deployments.

## Lessons Learned

- Validate configurations before deployment.
- Implement automated configuration testing.
- Strengthen monitoring around critical web services.

---

# Common Follow-Up Questions For Any Incident

### How was the issue detected?

- Monitoring alert
- Customer report
- Internal health checks

### What was the business impact?

- Service degradation
- User access issues
- Deployment delays
- Security risk
- Potential revenue impact

### Who did you communicate with?

- Customers
- Developers
- QA teams
- Operations teams
- Management

### What would you do differently?

- Earlier alerting
- Better monitoring
- More automation
- Improved documentation
- Additional validation checks

### How did you prevent recurrence?

- Added monitoring
- Added alerts
- Updated runbooks
- Improved automation
- Strengthened validation procedures
