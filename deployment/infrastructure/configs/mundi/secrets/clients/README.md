# Client Secrets

These secrets contain the client credentials for services to integrate with the uma-user-agent with resource protection deployed.
Prior to creating the secrets, a client must be registered with the login-service in order to generate the credentials.
These secrets thus depend on the following workloads to be deployed before they can be generated:
- sealed-secrets
- login-service

Prior to creating the secret, the helper script `register-client` can be used to register a client and store the credentials to a `client.yaml`
file. This `client.yaml` file should *not* be committed to version control.