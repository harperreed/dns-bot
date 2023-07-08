# DNS-Bot: Universal CoreDNS Server

This project sets up a CoreDNS server that resolves all incoming DNS queries to a specific domain's DNS records. This is useful in scenarios where you want to point multiple domains to the same set of DNS records. The target domain can be easily changed by setting an environment variable.

## Prerequisites

- Docker installed on your local machine
- A Fly.io account and the Fly CLI installed
- A domain with pre-configured DNS records that you want to mirror

## Setup

1. **Configure CoreDNS**: Create a `Corefile.template` with the following configuration. `${TARGET_DOMAIN}` is a placeholder for the domain.

```plaintext
.:53 {
    errors
    log
    rewrite name regex (.*) ${TARGET_DOMAIN}
    forward . /etc/resolv.conf
}
```

2. **Create a Dockerfile**: Create a `Dockerfile` for the CoreDNS application. The Dockerfile should look like this:

```Dockerfile
FROM coredns/coredns:latest

COPY Corefile.template /root/Corefile.template

RUN apk add --no-cache gettext && \
    envsubst < /root/Corefile.template > /root/Corefile && \
    apk del gettext

EXPOSE 53 53/udp

ENTRYPOINT ["/coredns"]
```

3. **Build the Docker Image**: Run the following command in the directory containing your Dockerfile and `Corefile.template` to build the Docker image:

```bash
docker build -t mycoredns .
```

Replace `mycoredns` with your preferred Docker image name.

4. **Initialize Fly Application**: Run `fly init` and follow the prompts to create a new Fly application.

5. **Set the Target Domain**: Set the `TARGET_DOMAIN` environment variable to the domain you want to mirror. This can be done with the `flyctl` command:

```bash
flyctl secrets set TARGET_DOMAIN=mydomain.com
```

6. **Deploy the Application**: Run `fly deploy` to deploy your application to Fly.io.

7. **Allocate a Global IP Address**: Run `fly ips allocate -v 6` to allocate a global Anycast IPv6 address for your DNS service.

8. **Check Your Application**: Run `fly status` to check the status of your application.

## Important Notes

- This procedure assumes you want to use an Anycast IPv6 address for your DNS service. If you want to use an Anycast IPv4 address, you need to reach out to the Fly.io support for assistance, as they manage IPv4 addresses manually.
- Remember to replace `mycoredns` with the name of your Docker image and application.
- Be aware of the potential security and privacy implications of running a DNS server and ensure you are following all relevant laws and regulations.

## Support

If you run into any issues or have any questions, please open an issue in this repository.

