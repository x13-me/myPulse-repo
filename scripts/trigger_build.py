#!/usr/bin/env python3
"""
Trigger os-mypulse build via GitHub Actions repository_dispatch.

Usage:
  python3 trigger_build.py --ref v0.2.3 --version 0.2.3
  python3 trigger_build.py --ref main --version 0.2.4
"""

import argparse
import os
import sys
import json
import subprocess


def run_cmd(cmd, check=True):
    """Run command and return output."""
    result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
    if check and result.returncode != 0:
        print(f"ERROR: {cmd}\n{result.stderr}", file=sys.stderr)
        sys.exit(result.returncode)
    return result.stdout.strip()


def main():
    parser = argparse.ArgumentParser(description="Trigger os-mypulse build")
    parser.add_argument("--ref", required=True, help="Git ref to build (tag, branch, commit)")
    parser.add_argument("--version", required=True, help="Package version (e.g., 0.2.3)")
    parser.add_argument("--repo", default="x13-me/myPulse-repo", help="GitHub repo (owner/name)")
    parser.add_argument("--event-type", default="build_os_mypulse", help="Repository dispatch event type")
    parser.add_argument("--token", help="GitHub PAT (or use GITHUB_TOKEN env)")
    parser.add_argument("--dry-run", action="store_true", help="Print curl command without executing")
    args = parser.parse_args()

    token = args.token or os.environ.get("GITHUB_TOKEN")
    if not token:
        print("ERROR: GITHUB_TOKEN not set and --token not provided", file=sys.stderr)
        sys.exit(1)

    payload = {
        "event_type": args.event_type,
        "client_payload": {
            "ref": args.ref,
            "version": args.version
        }
    }

    url = f"https://api.github.com/repos/{args.repo}/dispatches"
    curl_cmd = [
        "curl", "-X", "POST", url,
        "-H", f"Authorization: Bearer {token}",
        "-H", "Accept: application/vnd.github.v3+json",
        "-H", "Content-Type: application/json",
        "-d", json.dumps(payload)
    ]

    if args.dry_run:
        print("Would run:")
        print(" ".join(curl_cmd))
        print("\nPayload:")
        print(json.dumps(payload, indent=2))
        return 0

    print(f"Triggering build for {args.repo}...")
    print(f"  ref: {args.ref}")
    print(f"  version: {args.version}")

    try:
        result = subprocess.run(curl_cmd, capture_output=True, text=True)
        if result.returncode != 0:
            print(f"ERROR: {result.stderr}", file=sys.stderr)
            sys.exit(1)
        print("Build triggered successfully!")
        if result.stdout:
            print(result.stdout)
    except Exception as e:
        print(f"ERROR: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()