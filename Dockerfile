FROM rustlang/rust:nightly as builder

# Make a fake Rust app to keep a cached layer of compiled crates
RUN USER=root cargo new app
WORKDIR /usr/src/app
RUN mkdir ln-websocket-proxy
COPY Cargo.toml Cargo.lock ./
# Needs at least a main.rs file with a main function
# Since this is a rust workspace, we need to init the other things too
RUN mkdir src && echo "fn main(){}" > src/main.rs && echo "fn main(){}" > src/lib.rs
# Will build all dependent crates in release mode
RUN --mount=type=cache,target=/usr/local/cargo/registry \
    --mount=type=cache,target=/usr/src/app/target \
    cargo build --release --features="server"

# Copy the rest
COPY . .
# Build (install) the actual binaries
RUN cargo install --path . --features="server"

# Runtime image
FROM debian:bullseye-slim

# Some general ENVs
ENV RUST_LOG=debug
ENV LN_PROXY_PORT=8080

# Run as "app" user
RUN useradd -ms /bin/bash app

USER app
WORKDIR /app

# Get compiled binaries from builder's cargo install directory
COPY --from=builder /usr/local/cargo/bin/ln_websocket_proxy /app/ln-websocket-proxy

# No CMD or ENTRYPOINT, see fly.toml with `cmd` override.
ENTRYPOINT [ "/app/ln-websocket-proxy" ]
