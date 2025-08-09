#!/usr/bin/env bash
set -e

# ===============================
# Function: show help message
# ===============================
usage() {
  echo "Usage: $0 -c collection.json [-e environment.json] -t {count|duration} -n NUM [-d SECONDS] -r {cli|html|allure}"
  exit 1
}

# ===============================
# Argument parsing
# ===============================
while [[ "$#" -gt 0 ]]; do
  case $1 in
    -c|--collection) COLLECTION="$2"; shift ;;
    -e|--environment) ENVIRONMENT="$2"; shift ;;
    -t|--type) TYPE="$2"; shift ;;
    -n|--runs) RUNS="$2"; shift ;;
    -d|--duration) DURATION="$2"; shift ;;
    -r|--reporter) REPORTER="$2"; shift ;;
    *) echo "Unknown parameter: $1"; usage ;;
  esac
  shift
done

# ===============================
# Validation
# ===============================
[[ -z "$COLLECTION" || -z "$TYPE" || -z "$RUNS" || -z "$REPORTER" ]] && usage
[[ "$TYPE" == "duration" && -z "$DURATION" ]] && usage

# ===============================
# Clear allure-results and allure-report
# ===============================
if [[ "$REPORTER" == "allure" ]]; then
  echo "🧹 Cleaning allure-results and allure-report..."
  rm -rf allure-results allure-report
fi

# ===============================
# Validating existence of newman
# ===============================
if ! command -v newman >/dev/null 2>&1; then
  echo "❌ Newman not found. Installing..."
  npm install -g newman
fi

# ===============================
# Validating existence of reporter
# ===============================
case $REPORTER in
  html)
    if ! npm ls -g newman-reporter-html --depth=0 >/dev/null 2>&1; then
      echo "📦 Installing newman-reporter-html..."
      npm install -g newman-reporter-html
    fi
    ;;
  allure)
    if ! npm ls -g newman-reporter-allure --depth=0 >/dev/null 2>&1; then
      echo "📦 Installing newman-reporter-allure..."
      npm install -g newman-reporter-allure
    fi
    if ! command -v allure >/dev/null 2>&1; then
      echo "📦 Installing Allure CLI..."
      npm install -g allure-commandline --save-dev
    fi
    ;;
esac

# ===============================
# Function: run loop
# ===============================
run_loop() {
  local id=$1
  local report_dir="allure-results"

  while true; do
    if [[ "$TYPE" == "duration" && $SECONDS -ge $END_TIME ]]; then break; fi
    echo "[Run $id] Running..."

    if [[ "$REPORTER" == "allure" ]]; then
      mkdir -p "$report_dir"
      newman run "$COLLECTION" \
        ${ENVIRONMENT:+--environment "$ENVIRONMENT"} \
        --reporters cli,allure \
        --reporter-allure-export "$report_dir"
    else
      newman run "$COLLECTION" \
        ${ENVIRONMENT:+--environment "$ENVIRONMENT"} \
        --reporters cli,"$REPORTER"
    fi

    [[ "$TYPE" == "count" ]] && break
    sleep 1
  done
}

# ===============================
# Runner
# ===============================
if [[ "$TYPE" == "duration" ]]; then
  END_TIME=$((SECONDS + DURATION))
  export END_TIME
fi

export COLLECTION ENVIRONMENT TYPE REPORTER
export -f run_loop

seq 1 "$RUNS" | xargs -n1 -P"$RUNS" bash -c 'run_loop "$@"' _

# ===============================
# Generate Allure report
# ===============================
if [[ "$REPORTER" == "allure" ]]; then
  echo "📊 Generating Allure report..."
  allure generate allure-results --clean -o allure-report
  echo "✅ Report ready: ./allure-report/index.html"
fi
