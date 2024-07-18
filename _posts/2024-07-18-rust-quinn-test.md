---
title: '[wip] QuinnでQUICを試す'
author: r74tech
categories:
  - wip
tags:
  - wip
math: false
mermaid: false
slug: 2024-07-18-rust-quinn-test
image:
  path: /assets/img/og/2024-07-18-rust-quinn-test.png
  show: false
---

参考記事: [https://tech.aptpod.co.jp/entry/2020/12/04/100000](https://tech.aptpod.co.jp/entry/2020/12/04/100000)

```
.
├── Cargo.toml
└── src
    └── main.rs
```


```toml
[package]
name = "quinn-echo"
version = "0.1.0"
edition = "2021"


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
use anyhow::*;
use quinn::{ClientConfig, Endpoint, ServerConfig, TransportConfig};
use rustls::{Certificate, PrivateKey};
use std::net::{IpAddr, Ipv4Addr, SocketAddr};
use std::sync::Arc;
use std::time::{Duration, Instant};
use tokio::time::sleep;
use rand::{thread_rng, Rng};
use std::result::Result::Ok;

const MSG_SIZE: usize = 1024 * 10;

#[tokio::main]
async fn main() -> Result<()> {
    let cert = rcgen::generate_simple_self_signed(vec!["localhost".into()])?;
    let cert_der = cert.serialize_der()?;
    let priv_key = cert.serialize_private_key_der();

    let cert_der_clone = cert_der.clone();

    let mut send_data = vec![0u8; MSG_SIZE];
    thread_rng().fill(&mut send_data[..]);

    tokio::spawn(async move {
        run_server(cert_der_clone, priv_key).await.unwrap();
    });

    // サーバーが起動するのを少し待つ
    sleep(Duration::from_secs(1)).await;

    let start = Instant::now();
    run_client(cert_der, &send_data).await?;
    let elapsed = start.elapsed();
    println!(
        "Elapsed time: {} ms",
        elapsed.as_secs() * 1000 + elapsed.subsec_millis() as u64
    );

    Ok(())
}

async fn run_server(cert_der: Vec<u8>, priv_key: Vec<u8>) -> Result<()> {
    let mut server_config = ServerConfig::with_single_cert(
        vec![Certificate(cert_der)],
        PrivateKey(priv_key)
    )?;
    server_config.transport = Arc::new(TransportConfig::default());

    let addr = SocketAddr::new(IpAddr::V4(Ipv4Addr::new(0, 0, 0, 0)), 33333);
    let endpoint = Endpoint::server(server_config, addr)?;
    println!("listening on {}", endpoint.local_addr()?);

    while let Some(conn) = endpoint.accept().await {
        tokio::spawn(async move {
            if let Err(e) = handle_connection(conn).await {
                eprintln!("Connection error: {}", e);
            }
        });
    }

    Ok(())
}

async fn handle_connection(conn: quinn::Connecting) -> Result<()> {
    let connection = conn.await?;
    println!("connected from {}", connection.remote_address());

    loop {
        match connection.accept_uni().await {
            Ok(mut stream) => {
                match stream.read_to_end(MSG_SIZE).await {
                    Ok(data) => {
                        println!("Received data of size: {}", data.len());
                    }
                    Err(e) => {
                        eprintln!("Error reading stream: {}", e);
                        break;
                    }
                }
            }
            Err(quinn::ConnectionError::ApplicationClosed(_)) => {
                println!("Connection closed");
                break;
            }
            Err(e) => {
                eprintln!("Connection error: {}", e);
                break;
            }
        }
    }

    println!("connection closed from {}", connection.remote_address());

    Ok(())
}

async fn run_client(cert_der: Vec<u8>, send_data: &[u8]) -> Result<()> {
    let mut roots = rustls::RootCertStore::empty();
    roots.add(&Certificate(cert_der))?;

    let client_config = ClientConfig::new(Arc::new(
        rustls::ClientConfig::builder()
            .with_safe_defaults()
            .with_root_certificates(roots)
            .with_no_client_auth()
    ));

    let addr = SocketAddr::new(IpAddr::V4(Ipv4Addr::new(127, 0, 0, 1)), 33333);
    let mut endpoint = Endpoint::client("0.0.0.0:0".parse().unwrap())?;
    endpoint.set_default_client_config(client_config);
    let connection = endpoint.connect(addr, "localhost")?.await?;
    println!("connected: addr={}", connection.remote_address());


    for i in 0..1000 {
        let mut send_stream = connection.open_uni().await?;
        send_stream.write_all(send_data).await?;
        send_stream.finish().await?;
        if i % 100 == 0 {
            println!("Sent {} packets", i + 1);
        }
    }

    connection.close(0u8.into(), b"Done");

    endpoint.wait_idle().await;

    Ok(())
}
```
{: file='src/main.rs'}

