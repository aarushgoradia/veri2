#!/usr/bin/env python3
"""Prepare or execute one isolated JasperGold analysis of a repository design.

Default is prepare-only. Run this on the server so config paths refer to its checkout.
All input files remain unchanged. Fresh output directories prevent stale-result reuse.
"""
import argparse
import hashlib
import json
from pathlib import Path
import shlex
import shutil
import subprocess


def tcl_string(value):
    """Quote a literal for Tcl, including paths with spaces or metacharacters."""
    value = str(value)
    for old, new in [("\\", "\\\\"), ('"', '\\"'), ("$", "\\$"),
                     ("[", "\\["), ("]", "\\]"), ("\n", "\\n"), ("\r", "\\r")]:
        value = value.replace(old, new)
    return '"' + value + '"'


def build_parser():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--input-dir", type=Path, required=True, help="Directory with module.v and sva.sv")
    p.add_argument("--out-dir", type=Path, required=True, help="New, nonexisting run directory")
    p.add_argument("--top", required=True)
    clock = p.add_mutually_exclusive_group(required=True)
    clock.add_argument("--clock")
    clock.add_argument("--no-clock", action="store_true")
    reset = p.add_mutually_exclusive_group(required=True)
    reset.add_argument("--reset-expr", help="Active reset expression, e.g. !rst_n")
    reset.add_argument("--no-reset", action="store_true")
    binding = p.add_mutually_exclusive_group(required=True)
    binding.add_argument("--bind", type=Path, help="Explicit, reviewed bind/wrapper file")
    binding.add_argument("--embedded-bind", action="store_true", help="Confirm sva.sv already contains binding")
    p.add_argument("--rtl", type=Path, nargs="+", help="Override module.v with ordered RTL files")
    p.add_argument("--coverage", choices=["coi", "proof", "mutation", "stimuli"])
    p.add_argument("--dut-instance", help="Actual hierarchical DUT instance; required for coverage")
    p.add_argument("--time-limit", type=int, default=300, help="Proof time limit in seconds")
    p.add_argument("--prove-covers", action="store_true",
                   help="Also prove enabled cover properties and retain their named verdicts")
    p.add_argument("--dump-traces", action="store_true", help="Save full-design counterexample/cover VCD traces")
    p.add_argument("--jg", default="jg")
    p.add_argument("--execute", action="store_true")
    return p


def prepare(args):
    if args.time_limit <= 0:
        raise ValueError("--time-limit must be positive")
    if args.coverage and not args.dut_instance:
        raise ValueError("--dut-instance is required for coverage; do not guess the hierarchy")
    root = args.input_dir.resolve()
    rtl = [p.resolve() for p in (args.rtl or [root / "module.v"])]
    sva = root / "sva.sv"
    binds = [args.bind.resolve()] if args.bind else []
    inputs = rtl + [sva] + binds
    for path in inputs:
        if not path.is_file():
            raise ValueError(f"Missing input: {path}")
    if args.embedded_bind:
        import re
        source = re.sub(r"/\*.*?\*/|//[^\n]*", "", sva.read_text(), flags=re.S)
        if not re.search(r"\bbind\s+", source):
            raise ValueError("No bind statement found; supply a reviewed --bind file")
    out = args.out_dir.resolve()
    if out.exists():
        raise ValueError(f"Output already exists; choose a fresh run directory: {out}")
    if args.execute and not shutil.which(args.jg):
        raise ValueError(f"JasperGold executable not found: {args.jg}")
    out.mkdir(parents=True)
    config = out / "config.tcl"
    script = Path(__file__).resolve().parent / "formal" / "run.tcl"
    values = {"OUT_DIR": out, "TOP": args.top, "CLOCK": args.clock or "",
              "RESET_EXPR": args.reset_expr or "", "COVERAGE": args.coverage or "",
              "DUT_INSTANCE": args.dut_instance or "", "TIME_LIMIT": args.time_limit,
              "PROVE_COVERS": int(args.prove_covers), "DUMP_TRACES": int(args.dump_traces)}
    lines = [f"set {key} {tcl_string(value)}" for key, value in values.items()]
    for key, paths in [("RTL_FILES", rtl), ("SVA_FILES", [sva]), ("BIND_FILES", binds)]:
        lines.append(f"set {key} [list {' '.join(tcl_string(p) for p in paths)}]")
    config.write_text("\n".join(lines) + "\n")
    command = [args.jg] + (["-cov"] if args.coverage else []) + [
        "-no_gui", "-proj", str(out / "project"), str(script), "---", str(config)]
    manifest = {"command": command, "settings": {k: str(v) for k, v in values.items()},
                "sha256": {str(p): hashlib.sha256(p.read_bytes()).hexdigest()
                           for p in inputs + [script, Path(__file__).resolve(), config]},
                "note": "Tool version and license details are recorded by JasperGold in its logs."}
    (out / "manifest.json").write_text(json.dumps(manifest, indent=2) + "\n")
    return out, command


def main():
    parser = build_parser()
    args = parser.parse_args()
    try:
        out, command = prepare(args)
    except ValueError as error:
        parser.error(str(error))
    print(shlex.join(command))
    if args.execute:
        with (out / "console.log").open("w") as log:
            result = subprocess.run(command, cwd=out, stdout=log, stderr=subprocess.STDOUT)
        if result.returncode or not (out / "completed.txt").exists():
            raise SystemExit(f"Analysis incomplete; inspect {out / 'console.log'}")
    else:
        print("Prepared only. Execute the printed command on this server, or use --execute with a new output directory.")


if __name__ == "__main__":
    main()
