# Support Specialist (Fintech) Interview Preparation

## 1. Walk me through a production incident you handled.

### Answer

One production incident I handled involved a Kubernetes cluster where several applications suddenly became unavailable. Grafana alerts showed increased resource utilization and users reported failures accessing certain services.

I started by checking cluster health and found several pods stuck in a Pending state. Using `kubectl describe`, I discovered the worker node had entered a MemoryPressure condition and Kubernetes had tainted the node to prevent additional workloads from being scheduled.

I reviewed recently deployed workloads and identified an application consuming significantly more memory than expected due to missing resource limits. To restore service, I redistributed workloads, restarted affected services, and implemented appropriate resource requests and limits.

After service was restored, I worked with the team to add proactive alerts and resource governance policies to prevent similar incidents in the future.

---

## 2. What metrics would you monitor for a fintech application?

### Answer

I would monitor metrics across four areas.

### Application Health
- Response times
- Error rates
- API success rates

### Transaction Processing
- Transaction success rates
- Failed transactions
- Processing latency
- Queue backlogs

### Infrastructure
- CPU utilization
- Memory utilization
- Disk utilization
- Network performance

### Database
- Connection counts
- Slow queries
- Replication health
- Query execution times

In a fintech environment, transaction success rates and processing latency are especially important because they directly affect customers and revenue.

---

## 3. Tell me about a Grafana alert you've investigated.

### Answer

One Grafana alert I investigated involved unusually high memory consumption on a Kubernetes worker node.

The alert showed memory usage continuously increasing over several hours. I reviewed dashboard metrics and confirmed the issue wasn't a temporary spike.

I then checked workloads running on the node and identified an application that had recently been deployed without proper resource limits. The application gradually consumed available memory until Kubernetes triggered MemoryPressure conditions.

I worked with the team to apply appropriate resource limits and requests, redistributed workloads, and monitored the environment afterward to confirm stability.

---

## 4. What's the most difficult issue you solved using logs?

### Answer

I once investigated an application issue where users were experiencing intermittent failures, but infrastructure metrics appeared normal.

Using centralized ELK logging, I correlated logs across multiple services and identified repeated failures during communication with an external dependency. The error was occurring only under specific request conditions, which made it difficult to reproduce.

By tracing timestamps and request IDs across services, I was able to isolate the failing component and provide detailed evidence to the development team. That significantly reduced troubleshooting time and allowed a fix to be deployed quickly.

---

## 5. Describe a database performance issue you solved.

### Answer

An application began experiencing slow response times during peak usage periods.

I reviewed server resources and confirmed CPU and memory utilization were healthy, which suggested the bottleneck might be database-related.

I checked database performance metrics, reviewed the slow query log, and identified a frequently executed query performing full table scans against a large dataset.

Using `EXPLAIN`, I confirmed that appropriate indexes were not being used. After implementing indexing improvements and validating them in testing, query execution times dropped significantly and application performance returned to normal.

---

## 6. How do you troubleshoot a slow database?

### Answer

My process is systematic.

1. Verify the issue is database-related.
2. Check application and infrastructure metrics.
3. Review CPU, memory, and disk I/O.
4. Check connection counts.
5. Review active queries.
6. Analyze slow query logs.
7. Check for locks or blocking transactions.
8. Run `EXPLAIN` on problematic queries.
9. Verify indexes are being used efficiently.
10. Review recent deployments or workload changes.

---

## 7. Have you restored a database backup before?

### Answer

Yes.

Part of my responsibilities involved validating backups and performing restoration testing. During these exercises, I restored backups to isolated environments, verified database integrity, confirmed application functionality, and documented recovery times.

The goal wasn't simply restoring the backup but ensuring it was usable and met the organization's recovery objectives.

---

## 8. How do you determine whether an issue belongs to support or development?

### Answer

I gather evidence before deciding ownership.

### Typically Support Issues
- Configuration problems
- Permissions issues
- Infrastructure failures
- Integration issues
- User-related problems

### Typically Development Issues
- Application bugs
- Logic defects
- Unexpected application behavior
- Code-related failures

I always provide developers with enough evidence to accelerate investigation.

---

## 9. What information do developers need before you escalate?

### Answer

I provide:

- Timestamps
- Affected users
- Steps to reproduce
- Screenshots
- Relevant logs
- Error messages
- Severity level
- Business impact
- Troubleshooting steps already performed

The goal is to eliminate unnecessary back-and-forth.

---

## 10. What are RTO and RPO? Why test restores?

### Answer

### RTO (Recovery Time Objective)

The maximum acceptable downtime following a service disruption.

### RPO (Recovery Point Objective)

The maximum acceptable amount of data loss measured in time.

### Why Test Restores?

A backup is only valuable if it can be restored successfully.

Restore testing:

- Validates backup integrity
- Confirms recovery procedures
- Verifies recovery objectives
- Reduces risk during real incidents

---

## 11. How do you perform an access review?

### Answer

1. Generate a list of active users.
2. Review assigned permissions.
3. Verify access with managers or system owners.
4. Remove unnecessary privileges.
5. Disable inactive accounts.
6. Document approvals and changes.
7. Maintain records for audit purposes.

---

## 12. What is the principle of least privilege?

### Answer

The principle of least privilege means users should only receive the minimum level of access required to perform their job responsibilities.

Benefits include:

- Reduced security risks
- Lower chance of accidental changes
- Smaller attack surface
- Reduced impact of compromised accounts

---

## 13. A service is down on a Linux server. What do you check?

### Answer

I follow a structured troubleshooting process.

```bash
systemctl status <service>
journalctl -u <service>
df -h
free -m
top
ss -tulpn
```

### Investigation Areas

- Service status
- Application logs
- System logs
- CPU utilization
- Memory utilization
- Disk utilization
- Network connectivity
- Dependencies
- Recent deployments or changes

---

## 14. Disk usage is at 100%. What do you do?

### Answer

1. Identify which filesystem is full.
2. Determine what is consuming disk space.
3. Check:
   - Log files
   - Temporary files
   - Backups
   - Application-generated files
4. Safely remove unnecessary files.
5. Rotate logs if needed.
6. Restore service functionality.
7. Investigate root cause.
8. Implement retention policies and monitoring.

---

## 15. Tell me about a script you wrote.

### Answer

I developed Bash and Python scripts to automate repetitive operational tasks.

One example involved automating infrastructure validation and routine checks that engineers previously performed manually.

The script:

- Collected system information
- Verified service health
- Generated reports
- Reduced manual effort
- Improved consistency
- Reduced human error

---

## 16. An EC2-hosted application becomes unreachable. How would you troubleshoot?

### Answer

I would systematically isolate the failure domain.

### DNS
- Verify DNS resolution

### AWS Infrastructure
- Check EC2 instance health
- Review Security Groups
- Review Network ACLs
- Validate route tables

### Application
- Verify service status
- Review application logs

### Load Balancer
- Check target health
- Verify listener configuration

### Recent Changes
- Review deployments
- Review configuration updates

---

## 17. Why do you want to move into fintech support?

### Answer

I enjoy troubleshooting production systems and solving problems that directly impact users.

What attracts me to fintech is the importance of reliability, customer experience, and operational excellence.

Financial platforms process business-critical transactions where system availability and rapid incident response are essential.

My background in infrastructure, monitoring, databases, and application support positions me well to contribute effectively in this environment.

---

## 18. Tell us about a difficult customer.

### Answer

One customer experienced repeated service interruptions and became understandably frustrated.

I focused on communication as much as troubleshooting.

I listened carefully, acknowledged the impact on their business, provided regular updates, explained findings in non-technical language, and maintained transparency throughout the process.

Even before full resolution, the customer appreciated the communication because they knew progress was being made.

---

## 19. Describe a major incident you handled.

### Answer

Use the Kubernetes MemoryPressure production incident from Question 1.

Key themes:

- Monitoring
- Incident response
- Root cause analysis
- Communication
- Service restoration
- Preventive actions

---

## 20. Describe a time you missed something.

### Answer

I once focused heavily on application behavior during an investigation and initially overlooked a configuration change that had been introduced earlier.

After reviewing change history, I identified the root cause and resolved the issue.

The experience reinforced the importance of reviewing configuration and change history early during investigations.

---

## 21. Describe a time you worked under pressure.

### Answer

During a production incident affecting customer-facing services, multiple stakeholders were requesting updates while troubleshooting was ongoing.

I prioritized stabilizing the service, maintained regular communication, documented findings as I worked, and coordinated with other teams.

The incident was resolved successfully while keeping stakeholders informed throughout the process.

---

## 22. Tell us about a disagreement with a developer.

### Answer

I once believed an issue was caused by application behavior, while the development team suspected infrastructure.

Instead of relying on assumptions, we reviewed logs, metrics, and evidence together.

The investigation ultimately showed that both an application defect and an infrastructure condition contributed to the issue.

The experience reinforced the importance of evidence-based collaboration.

---

## 23. How do you prioritize multiple incidents?

### Answer

I prioritize based on:

1. Business impact
2. Number of affected users
3. Severity level
4. SLA requirements
5. Revenue impact

For example, a payment processing outage affecting all customers would take precedence over a single-user access issue.

I also ensure lower-priority incidents continue progressing through communication and proper escalation.

---

## 24. Why should we hire you?

### Answer

My experience aligns closely with the responsibilities of this role.

I have hands-on experience supporting production systems, troubleshooting incidents, managing Linux environments, working with relational databases, using Grafana and ELK for monitoring and investigation, validating backups, automating operational tasks, and supporting end users.

I understand how to investigate issues methodically, communicate effectively with both customers and technical teams, and operate within SLA-driven environments.

Most importantly, I enjoy solving problems and helping users restore service as quickly as possible.
