<h1 align="center">openwrt-24.10 CURL HTTP/3 prebuilt packages</h1>
<p align="center">
  <img width="200" src="https://curl.se/logo/curl-logo.svg" />
</p>
<p align="center">
  <b>build curl library with quictls + libngtcp2 + libnghttp3</b>
</p>

-----------

## Releases

Check out the latest releases and download statistics: [GitHub Releases](https://github.com/ewgen198409/openwrt-curl-prebuilt/releases)

## Installation

1. Download the appropriate package for your architecture from the [releases page](https://github.com/ewgen198409/openwrt-curl-prebuilt/releases).
2. Extract the downloaded tar.gz file.
3. Run the included `install_h3.sh` script to install the packages:

```bash
tar -xzf curl-8.19.0-aarch64_cortex-a53.tar.gz
cd packages_ci
sudo ./install_h3.sh
```

The script will automatically detect your architecture and install the required packages (curl, libnghttp3, libngtcp2, libopenssl) with HTTP/3 support.

## Supported Architectures

- aarch64_cortex-a53
- mipsel_24kc
- x86_64

## Features

- HTTP/3 support via QUIC
- Built with quictls OpenSSL for enhanced security
- Compatible with OpenWrt 24.10

## Source Repositories

These packages were built using the following repositories:

- [curl](https://github.com/sbwml/feeds_packages_net_curl) - OpenWrt package for curl with QUIC support
- [nghttp3](https://github.com/sbwml/package_libs_nghttp3) - OpenWrt package for nghttp3 library
- [ngtcp2](https://github.com/sbwml/package_libs_ngtcp2) - OpenWrt package for ngtcp2 library
- [openssl](https://github.com/sbwml/package_libs_openssl) - OpenWrt package for quictls OpenSSL with QUIC support

