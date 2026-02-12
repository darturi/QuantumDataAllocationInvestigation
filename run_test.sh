#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

show_usage() {
  cat <<'USAGE'
Usage: ./run_test.sh [--format] <test_name>

Runs the selected test function from TESTS/d_tests.py with:
- DIMOD.DimodSolver
- CLASSICAL.ILPSolver

Options:
  -f, --format   Also print formatted allocations via format_answer for each solver
  -h, --help     Show this help message
  -l, --list     List available test functions in TESTS/d_tests.py
USAGE
}

LIST_ONLY=0
SHOW_FORMAT=0
TEST_NAME=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    -f|--format)
      SHOW_FORMAT=1
      shift
      ;;
    -l|--list)
      LIST_ONLY=1
      shift
      ;;
    -h|--help)
      show_usage
      exit 0
      ;;
    -*)
      echo "Unknown option: $1" >&2
      show_usage >&2
      exit 1
      ;;
    *)
      if [[ -n "$TEST_NAME" ]]; then
        echo "Only one test name can be provided." >&2
        show_usage >&2
        exit 1
      fi
      TEST_NAME="$1"
      shift
      ;;
  esac
done

if [[ "$LIST_ONLY" -eq 1 ]]; then
  python - <<'PY'
import inspect
import TESTS.d_tests as d_tests

tests = [name for name, obj in inspect.getmembers(d_tests, inspect.isfunction) if name.startswith("test")]
if not tests:
    print("No test functions found in TESTS/d_tests.py")
else:
    print("Available tests:")
    for name in tests:
        print(f"- {name}")
PY
  exit 0
fi

if [[ -z "$TEST_NAME" ]]; then
  echo "A test name is required." >&2
  show_usage >&2
  exit 1
fi

python - "$TEST_NAME" "$SHOW_FORMAT" <<'PY'
import importlib
import sys

from CLASSICAL.IntegerLinearProgramming import ILPSolver
from DIMOD.d1 import DimodSolver


def fail(msg: str) -> None:
    print(msg, file=sys.stderr)
    sys.exit(1)

if len(sys.argv) != 3:
    fail("Internal error: expected test_name and show_format")

test_name = sys.argv[1]
show_format = bool(int(sys.argv[2]))

tests_mod = importlib.import_module("TESTS.d_tests")
test_fn = getattr(tests_mod, test_name, None)

if test_fn is None or not callable(test_fn):
    fail(f"Test '{test_name}' was not found in TESTS/d_tests.py")

nodes, partitions, k_safety, requests, comm_costs = test_fn()

print(f"Running test: {test_name}")

# Dimod solver
print("\n[DimodSolver]")
dimod_solver = DimodSolver(nodes, partitions, k_safety, requests, comm_costs)
dimod_time, dimod_result = dimod_solver.solve()
print(f"solve time (ms): {dimod_time}")

if show_format:
    print("formatted answer:")
    dimod_solver.format_answer(dimod_result)

# ILP solver
print("\n[ILPSolver]")
ilp_solver = ILPSolver(nodes, partitions, k_safety, requests, comm_costs)
ilp_out = ilp_solver.solve()
if ilp_out is None:
    print("solve returned no solution")
else:
    ilp_time, ilp_result = ilp_out
    print(f"solve time (ms): {ilp_time}")
    if show_format:
        print("formatted answer:")
        ilp_solver.format_answer(ilp_result)
PY
