FROM mikuxdev/archiso:latest

COPY --chown=builder:users . .

# Run entrypoint
ENTRYPOINT ["./build-packages.sh"]
