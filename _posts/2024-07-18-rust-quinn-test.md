---
title: '[wip] QuinnでQUICを試す'
author: r74tech
categories:
  - dev
tags:
  - web rust
math: false
mermaid: false
slug: 2024-07-18-rust-quinn-test
image:
  path: /assets/img/og/2024-07-18-rust-quinn-test.png
  show: false
---

参考記事: [https://tech.aptpod.co.jp/entry/2020/12/04/100000](https://tech.aptpod.co.jp/entry/2020/12/04/100000)

[https://github.com/r74tech/quinn-example](https://github.com/r74tech/quinn-example)

```
.
├── Cargo.toml
└── src
    ├── client.rs
    ├── common.rs
    ├── main.rs
    └── server.rs
```


```toml
[package]
name = "quinn-example"
version = "0.1.0"
edition = "2021"

# See more keys and their definitions at https://doc.rust-lang.org/cargo/reference/manifest.html


[[bin]]
name = "server"
path = "src/server.rs"

[[bin]]
name = "client"
path = "src/client.rs"

[dependencies]
anyhow = "1.0"
quinn = "0.10"
tokio = { version = "1.38", features = ["full"] }
futures = "0.3"
rcgen = "0.12"
rand = "0.8"
rustls = { version = "0.21", features = ["dangerous_configuration"] }
```
{: file='Cargo.toml'}


```rust
use anyhow::Result;
mod common;

fn main() -> Result<()> {
    let (cert_der, key_der) = common::generate_self_signed_cert()?;
    common::save_cert_and_key(&cert_der, &key_der)?;
    Ok(())
}
```
{: file='src/main.rs'}

```rust
use quinn::{ClientConfig, ServerConfig, TransportConfig};
use rustls::{Certificate, PrivateKey};
use std::net::{IpAddr, Ipv4Addr, SocketAddr};
use std::sync::Arc;
use anyhow::*;

pub const SERVER_PORT: u16 = 5000;
pub const SERVER_CERT_PATH: &str = "cert.der";
pub const SERVER_KEY_PATH: &str = "key.der";

pub fn generate_self_signed_cert() -> Result<(Vec<u8>, Vec<u8>)> {
    let cert = rcgen::generate_simple_self_signed(vec!["localhost".into()])?;
    let cert_der = cert.serialize_der()?;
    let priv_key = cert.serialize_private_key_der();
    Ok((cert_der, priv_key))
}

pub fn save_cert_and_key(cert_der: &[u8], key_der: &[u8]) -> Result<()> {
    std::fs::write(SERVER_CERT_PATH, cert_der)?;
    std::fs::write(SERVER_KEY_PATH, key_der)?;
    Ok(())
}

pub fn load_cert_and_key() -> Result<(Vec<u8>, Vec<u8>)> {
    let cert_der = std::fs::read(SERVER_CERT_PATH)?;
    let key_der = std::fs::read(SERVER_KEY_PATH)?;
    Ok((cert_der, key_der))
}

pub fn configure_server(cert_der: Vec<u8>, priv_key: Vec<u8>) -> Result<ServerConfig> {
    let mut server_config = ServerConfig::with_single_cert(
        vec![Certificate(cert_der)],
        PrivateKey(priv_key)
    )?;
    server_config.transport = Arc::new(TransportConfig::default());
    Ok(server_config)
}

pub fn configure_client(cert_der: Vec<u8>) -> Result<ClientConfig> {
    let mut roots = rustls::RootCertStore::empty();
    roots.add(&Certificate(cert_der))?;

    let client_config = ClientConfig::new(Arc::new(
        rustls::ClientConfig::builder()
            .with_safe_defaults()
            .with_root_certificates(roots)
            .with_no_client_auth()
    ));

    Ok(client_config)
}

pub fn get_server_addr() -> SocketAddr {
    SocketAddr::new(IpAddr::V4(Ipv4Addr::new(127, 0, 0, 1)), SERVER_PORT)
}
```
{: file='src/common.rs'}

```rust
use anyhow::*;
use quinn::{Endpoint, Connection};
use tokio::io::AsyncReadExt;
use std::result::Result::Ok;

mod common;

#[tokio::main]
async fn main() -> Result<()> {
    let (cert_der, _) = common::load_cert_and_key()?;
    let client_config = common::configure_client(cert_der)?;

    let mut endpoint = Endpoint::client("0.0.0.0:0".parse()?)?;
    endpoint.set_default_client_config(client_config);

    let server_addr = common::get_server_addr();
    let connection = endpoint.connect(server_addr, "localhost")?.await?;
    println!("Connected to {}", connection.remote_address());

    run_client(connection).await?;

    endpoint.wait_idle().await;
    Ok(())
}

async fn run_client(connection: Connection) -> Result<()> {
    loop {
        println!("Enter a message (or 'quit' to exit):");
        let mut input = String::new();
        std::io::stdin().read_line(&mut input)?;
        
        let message = input.trim();
        if message == "quit" {
            break;
        }

        let response = send_message(&connection, message).await?;
        println!("Server response: {}", response);
    }

    connection.close(0u32.into(), b"Done");
    Ok(())
}

async fn send_message(connection: &Connection, message: &str) -> Result<String> {
    let (mut send, mut recv) = connection.open_bi().await?;
    
    send.write_all(message.as_bytes()).await?;
    send.finish().await?;

    let mut response = String::new();
    recv.read_to_string(&mut response).await?;

    Ok(response)
}
```
{: file='src/client.rs'}



```rust
use anyhow::*;
use quinn::{Endpoint, Connection};
use std::net::{SocketAddr, IpAddr, Ipv4Addr};
use std::result::Result::Ok;

mod common;

#[tokio::main]
async fn main() -> Result<()> {
    let (cert_der, priv_key) = common::load_cert_and_key()?;
    let server_config = common::configure_server(cert_der, priv_key)?;

    let addr = SocketAddr::new(IpAddr::V4(Ipv4Addr::new(127, 0, 0, 1)), common::SERVER_PORT);
    let endpoint = Endpoint::server(server_config, addr)?;
    println!("Listening on {}", endpoint.local_addr()?);

    run_server(endpoint).await
}

async fn run_server(endpoint: Endpoint) -> Result<()> {
    while let Some(conn) = endpoint.accept().await {
        tokio::spawn(async move {
            match conn.await {
                Ok(connection) => {
                    println!("Connection established from: {}", connection.remote_address());
                    if let Err(e) = handle_connection(connection).await {
                        eprintln!("Connection error: {}", e);
                    }
                }
                Err(e) => eprintln!("Connection failed: {}", e),
            }
        });
    }
    Ok(())
}

async fn handle_connection(connection: Connection) -> Result<()> {
    while let Ok((mut send, mut recv)) = connection.accept_bi().await {
        let mut buf = Vec::new();
        while let Some(chunk) = recv.read_chunk(1024, false).await? {
            buf.extend_from_slice(&chunk.bytes);
        }
        println!("Received: {}", String::from_utf8_lossy(&buf));

        send.write_all(&buf).await?;
        send.finish().await?;
    }
    Ok(())
}
```
{: file='src/server.rs'}

```bash
$ cargo run --bin quinn-example
$ cargo run --bin server
$ cargo run --bin client
```
