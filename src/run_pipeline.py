import subprocess
import sys
import time

def run_step(step_name, script_path):
    print(f"\n{'='*50}")
    print(f"STEP: {step_name}")
    print(f"{'='*50}")
    start = time.time()
    result = subprocess.run([sys.executable, script_path], capture_output=True, text=True)
    elapsed = time.time() - start

    print(result.stdout)
    if result.returncode != 0:
        print(f"❌ FAILED: {step_name}")
        print(result.stderr)
        sys.exit(1)
    else:
        print(f"✅ Completed in {elapsed:.2f} seconds")

def main():
    print("Starting Zeptalytix automated pipeline...\n")
    overall_start = time.time()

    run_step("Data Cleaning", "src/data_cleaning.py")
    run_step("Load to PostgreSQL", "src/load_to_postgres.py")
    run_step("Quality Check Query", "src/run_pg_queries.py")

    overall_elapsed = time.time() - overall_start
    print(f"\n{'='*50}")
    print(f"PIPELINE COMPLETE in {overall_elapsed:.2f} seconds")
    print(f"{'='*50}")

if __name__ == "__main__":
    main()