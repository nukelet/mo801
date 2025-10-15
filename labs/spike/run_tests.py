#!/usr/bin/env python
import os
import re
import subprocess
import matplotlib.pyplot as plt
import numpy as np

class PerfTestResult:
    def __init__(self, raw: str, prefix: str):
        self.bytes_read = None
        self.bytes_written = None
        self.read_accesses = None
        self.write_accesses = None
        self.read_misses = None
        self.write_misses = None
        self.writebacks = None
        self.miss_rate = None
        # pattern = f"^{re.escape(prefix)}.*"
        # print(f"matching: {pattern}")
        # print("input:")
        # print(raw)
        # matches = re.findall(pattern, raw, re.MULTILINE) 
        print(raw)
        for line in [match.strip(prefix).strip() for match in raw.splitlines() if match.startswith(prefix)]:
            print(line)
            line = line.split(":")
            match line[0]:
                case "Bytes Read":
                    self.bytes_read = int(line[1].strip())
                case "Bytes Written":
                    self.bytes_written = int(line[1].strip())
                case "Read Accesses":
                    self.read_accesses = int(line[1].strip())
                case "Write Accesses":
                    self.write_accesses = int(line[1].strip())
                case "Read Misses":
                    self.read_misses = int(line[1].strip())
                case "Write Misses":
                    self.write_misses = int(line[1].strip())
                case "Writebacks":
                    self.writebacks = int(line[1].strip())
                case "Miss Rate":
                    self.miss_rate = float(line[1].strip().replace("%", "e-2"))

    def __str__(self):
        out = (f"bytes_read: {self.bytes_read}\n"
               f"bytes_written: {self.bytes_written}\n"
               f"read_accesses: {self.read_accesses}\n"
               f"write_accesses: {self.write_accesses}\n"
               f"read_misses: {self.read_misses}\n"
               f"write_misses: {self.write_misses}\n"
               f"writebacks: {self.writebacks}\n"
               f"miss_rate: {self.miss_rate * 100 :.2f}%\n")
        return out

class PerfTest:
    def __init__(self, binary: str,
                 prefix: str = "D$",
                 icache_params: tuple[int, int, int] = None,
                 dcache_params: tuple[int, int, int] = None,
                 l2_params: tuple[int, int, int] = None):
        self.binary = binary
        self.prefix = prefix
        self.icache_params = icache_params
        self.dcache_params = dcache_params
        self.l2_params = l2_params
        self.result = None

    def run(self):
        opts: list[str] = []
        if self.icache_params:
            s, w, b = self.icache_params
            opts.append(f"--ic={s}:{w}:{b}")

        if self.dcache_params:
            s, w, b = self.dcache_params
            opts.append(f"--dc={s}:{w}:{b}")

        cmd = ["spike"]
        cmd += opts
        cmd += ["pk", self.binary]

        print(" ".join(cmd))

        output = subprocess.run(cmd, capture_output=True, text=True).stdout
        self.result = PerfTestResult(output, self.prefix)

def main():
    binary = "/home/nuke/faculdade/mo801-isaias/mo801-simulacao-spike/hello.rv"
    test_cases = [
        # 8 KiB
        (256, 1, 32),
        (128, 2, 32),
        (64, 4, 32),
        (128, 2, 64),
        # 16 KiB
        (256, 2, 64),
        (128, 2, 128),
        (16384, 1, 32),
        (8192, 2, 32),
        (4096, 4, 32),
        (4096, 2, 64),
        (8192, 2, 64),
        (16384, 2, 64),
        (8192, 2, 128),
    ]

    fig, ax = plt.subplots(layout="constrained")

    tests = []
    for params in test_cases:
        print(params)
        test = PerfTest(binary, dcache_params=params)
        test.run()
        print(test.result)
        tests.append(test)
        cache_size = int(params[0] * params[1] * params[2] / 1024)
        print(f"cache size: {cache_size} KiB")

    print("==== miss rate benchmark results ====")
    tests.sort(key=lambda test: test.result.read_misses / test.result.read_accesses)
    for test in tests:
        s, w, b = test.dcache_params
        read_miss_rate = test.result.read_misses / test.result.read_accesses
        cache_size = int(s * w * b / 1024)
        print(f"s={s}, w={w}, b={b} ({cache_size} KiB total); "
              f"read_miss_rate={read_miss_rate * 100 :.2f}%, "
              f"read_misses={test.result.read_misses}, write_misses={test.result.write_misses}")
    print("")


if __name__ == "__main__":
    main()
