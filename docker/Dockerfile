FROM bash:5.2

WORKDIR /challenge
COPY app ./app
COPY scripts ./scripts
RUN chmod +x scripts/*.sh

ENV CTF_FLAG='DEVOPS_CTF{github_actions_context_injection}'
ENTRYPOINT ["./scripts/challenge.sh"]
