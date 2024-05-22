# Blocklists
[![build](https://github.com/kuflierl/Blocklists/actions/workflows/build.yml/badge.svg?branch=main)](https://github.com/kuflierl/Blocklists/actions/workflows/build.yml)

A Blocklist aggregator using github actions.

## Project Intent
Finding a good collection of up to date and effective Blocklists has always been a significant issue when using blocking tools like [Pi-Hole](https://pi-hole.net) and [uBlock Origin](https://ublockorigin.com). There are a lot of big and small blacklists on the internet that all lack to some extent. The intent of this project is to generate and distribute up to date composite blacklists using the tools [Make](https://www.gnu.org/software/make), Github Actions and Github Pages.

## Building
The project is built in 2 parts: The Blocklists and the Web Page.  
The Blocklists can be generated using
```sh
make
```
```sh
make default
```
The Jekyl page can be generated using
```sh
make generate_site
```  
Everything is cleaned up using
```sh
make clean
```

## Contributing
Feel free to open pull requests. When adding new domains it would be preferable to give a reason for the addition.
