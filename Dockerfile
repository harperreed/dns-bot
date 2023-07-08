# First stage: Generate Corefile from template
FROM alpine as builder

RUN apk add --no-cache gettext

COPY Corefile.template /root/Corefile.template
RUN envsubst < /root/Corefile.template > /root/Corefile

# Second stage: Set up CoreDNS
FROM coredns/coredns:latest

COPY --from=builder /root/Corefile /root/Corefile

EXPOSE 53 53/udp

ENTRYPOINT ["/coredns"]
