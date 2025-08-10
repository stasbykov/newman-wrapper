# Newman Wrapper

![MIT License](https://img.shields.io/badge/license-MIT-blue.svg)
![Newman](https://img.shields.io/badge/built%20with-Newman-FF6C37?logo=postman)
![Bash](https://img.shields.io/badge/shell-Bash-4EAA25?logo=gnu-bash)


This README describes how to use the `newman-wrapper-macos.sh` and `newman-wrapper-linux.sh` scripts, designed for running Postman collections in parallel with report generation.

## Features

- Run a collection in **N parallel threads**.
- Run collections in parallel for a **specified duration**.
- Support for various reporters (`cli`, `html`, `allure`, etc.).
- Automatic installation of missing reporters.
- Automatic cleanup of `allure-results` and `allure-report` folders before execution.

## Requirements

- **macOS** or **Linux**
- [Node.js](https://nodejs.org/) and npm
- [Newman](https://www.npmjs.com/package/newman) (`npm install -g newman`)  
**ℹ️ Note**: If Newman is not installed, the script will install it automatically.
- For Allure reports: [Allure Commandline](https://docs.qameta.io/allure/) (`brew install allure` for macOS or `sudo apt install allure` for Linux)

## Usage

### Make scripts executable:

```bash
chmod +x newman-wrapper-*.sh
```

### Run parallel threads

```bash
./newman-wrapper-macos.sh --collection collection.json --type count --runs 3 --reporter cli,html
````
or
```bash
./newman-wrapper-linux.sh -c collection.json -t count -n 3 -r cli,html
```

### Run for a specific duration

```bash
./newman-wrapper-linux.sh --collection collection.json --type duration --runs 5 --duration 600 --reporter cli,allure
```
or
```bash
./newman-wrapper-macos.sh -c collection.json -t duration -n 5 -d 600 -r cli,allure
```

### Parameters

- `-c | --collection` — path to Postman collection.
- `-e | --environment` — path to Postman environment.
- `-t | --type` — launch type: `count` (single launch) or `duration` (specified time)
- `-n | --runs` — number of parallel threads.
- `-d | --duration` — (optional) time in seconds for continuous startup.
- `-r | --reporter` — comma separated list of reporters.

## Report Cleanup

Before each run, the script automatically removes the `allure-results` and `allure-report` directories.

## Examples

- Run 3 threads with an HTML report:

```bash
./newman-wrapper-macos.sh --collection collection.json --type count --runs 3 --reporter cli,html
```
or
```bash
./newman-wrapper-linux.sh -c collection.json -t count -n 3 -r cli,html
```

- Run a 10-minute load test with Allure:

```bash
./newman-wrapper-linux.sh --collection collection.json --type duration --runs 5 --duration 600 --reporter cli,allure
```
or
```bash
./newman-wrapper-macos.sh -c collection.json -t duration -n 5 -d 600 -r cli,allure
```