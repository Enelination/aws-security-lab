# Security Requirements

1. Broken access control must not allow one user to read another user's data.
2. SQL injection must not be possible.
3. Administrative APIs must require an administrator identity.
4. Secrets must not be committed to source control.
5. JWT validation must enforce expected issuer, audience and algorithm.
6. Sensitive endpoints must have rate limiting.
7. Error responses must not disclose stack traces or secrets.
8. Application dependencies and container images must be scanned.
9. Infrastructure must use encryption at rest where supported.
10. Security findings should be reproducible and revalidated after remediation.
