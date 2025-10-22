import os
import re
import subprocess
from collections import defaultdict

import matplotlib
matplotlib.use("tkagg")

import matplotlib.pyplot as plt
import matplotlib.ticker as mtick
import numpy as np

class CachePerfResult:
    def __init__(self, raw: str, prefix: str):
        self.prefix = prefix
        self.raw = raw

        self.bytes_read = None
        self.bytes_written = None
        self.read_accesses = None
        self.write_accesses = None
        self.read_misses = None
        self.write_misses = None
        self.writebacks = None
        self.miss_rate = None
        for line in [match.replace(prefix, "").strip() for match in raw.splitlines() if match.startswith(prefix)]:
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
                 icache_params: tuple[int, int, int] = None,
                 dcache_params: tuple[int, int, int] = None,
                 l2_params: tuple[int, int, int] = None):
        self.binary = binary
        self.icache_params = icache_params
        self.icache_size = icache_params[0] * icache_params[1] * icache_params[2] if icache_params else None
        self.dcache_params = dcache_params
        self.dcache_size = dcache_params[0] * dcache_params[1] * dcache_params[2] if dcache_params else None
        self.l2_params = l2_params
        self.l2_size = l2_params[0] * l2_params[1] * l2_params[2] if l2_params else None
        self.dcache_result = None
        self.icache_result = None
        self.l2_result = None

    def run(self):
        opts: list[str] = []
        if self.icache_params:
            s, w, b = self.icache_params
            opts.append(f"--ic={s}:{w}:{b}")

        if self.dcache_params:
            s, w, b = self.dcache_params
            opts.append(f"--dc={s}:{w}:{b}")

        if self.l2_params:
            s, w, b = self.l2_params
            opts.append(f"--l2={s}:{w}:{b}")

        cmd = ["./riscv-spike/build/spike", "--isa=rv64gqc"]
        cmd += opts
        cmd += ["./riscv-pk/build/pk"]
        cmd += self.binary

        print(" ".join(cmd))

        output = subprocess.run(cmd, capture_output=True, text=True).stdout
        # print(output)

        if self.icache_params:
            self.icache_result = CachePerfResult(output, "I$")
        if self.dcache_params:
            self.dcache_result = CachePerfResult(output, "D$")
        if self.l2_params:
            self.l2_result = CachePerfResult(output, "L2$")

def q1_icache():
    binary = ["./hello.bin"]
    test_cases = [
        # 8 KiB
        (256, 1, 32),
        (128, 2, 32),
        (64, 4, 32),
        (64, 2, 64),
        # 16 KiB
        (128, 2, 64),
        # 32 KiB
        (256, 2, 64),
        (128, 2, 128),
        # 64 KiB
        (512, 2, 64),
        (128, 4, 128),
        # 128 KiB
        (1024, 2, 64),
        (512, 4, 64),
        (256, 4, 128),
        # 256 KiB
        (2048, 2, 64),
        (1024, 4, 64),
        (512, 4, 128),
        # 512 KiB
        (16384, 1, 32),
        (8192, 2, 32),
        (4096, 4, 32),
        # 1 MiB
        (8192, 2, 64),
        # 2 MiB
        (16384, 2, 64),
        (8192, 2, 128),
    ]

    tests = []
    for params in test_cases:
        print(params)
        test = PerfTest(binary, icache_params=params)
        test.run()
        print(test.icache_result)
        tests.append(test)
        cache_size = int(params[0] * params[1] * params[2] / 1024)
        print(f"cache size: {cache_size} KiB")
    tests.sort(key=lambda test: test.icache_result.miss_rate)

    fig, ax = plt.subplots(layout="constrained")
    fig.set_size_inches(14, 10)
    fig.set_dpi(300)
    y_pos = np.arange(len(tests))
    results = [test.icache_result.miss_rate * 100 for test in tests]
    labels = []
    for test in tests:
        label = f"I$ {test.icache_params}\n{int(test.icache_size / 1024)} KiB total"
        labels.append(label)
    bars = ax.barh(y_pos, results, align="center")
    ax.set_yticks(y_pos, labels=labels)
    ax.xaxis.set_major_formatter(mtick.PercentFormatter())
    ax.invert_yaxis()
    ax.set_title("cache miss rates for different i-cache arrangements\nworkload: hello world")
    ax.bar_label(bars, fmt="%0.2f%%")
    ax.set_xlabel("miss rate (%)")
    ax.set_ylabel("cache configuration")
    plt.savefig("../../presentations/midterm-report/images/q1-icache.png")
    plt.show()

def q1_dcache():
    binary = ["./hello.bin"]
    test_cases = [
        # 8 KiB
        (256, 1, 32),
        (128, 2, 32),
        (64, 4, 32),
        (64, 2, 64),
        # 16 KiB
        (128, 2, 64),
        # 32 KiB
        (256, 2, 64),
        (128, 2, 128),
        # 512 KiB
        (16384, 1, 32),
        (8192, 2, 32),
        (4096, 4, 32),
        # 1 MiB
        (8192, 2, 64),
        # 2 MiB
        (16384, 2, 64),
        (8192, 2, 128),
    ]

    tests = []
    for dcache_params in test_cases:
        test = PerfTest(binary, dcache_params=dcache_params)
        test.run()
        print(f"==== dcache {test.dcache_params} ====")
        print(test.dcache_result)
        tests.append(test)
    tests.sort(key=lambda test: test.dcache_result.miss_rate)

    fig, ax = plt.subplots(layout="constrained")
    fig.set_size_inches(14, 10)
    fig.set_dpi(300)
    y_pos = np.arange(len(tests))
    results = [test.dcache_result.miss_rate * 100 for test in tests]
    labels = []
    for test in tests:
        label = f"D$ {test.dcache_params} ({int(test.dcache_size / 1024)} KiB total)"
        labels.append(label)
    bars = ax.barh(y_pos, results, align="center")
    ax.set_yticks(y_pos, labels=labels)
    ax.xaxis.set_major_formatter(mtick.PercentFormatter())
    ax.invert_yaxis()
    ax.set_title("miss rates for different d-cache arrangements\nworkload: hello world")
    ax.bar_label(bars, fmt="%0.2f%%")
    ax.set_xlabel("miss rate (%)")
    ax.set_ylabel("cache configuration")
    plt.savefig("../../presentations/midterm-report/images/q1-dcache.png")

def q2_naive():
    binary = ["./matmul.bin", "naive"]
    test_cases = [
        # 8 KiB
        (256, 1, 32),
        (128, 2, 32),
        (64, 4, 32),
        (64, 2, 64),
        # 16 KiB
        (128, 2, 64),
        # 32 KiB
        (256, 2, 64),
        (128, 2, 128),
        # 512 KiB
        (16384, 1, 32),
        (8192, 2, 32),
        (4096, 4, 32),
        # 1 MiB
        (8192, 2, 64),
        # 2 MiB
        (16384, 2, 64),
        (8192, 2, 128),
    ]

    tests = []
    for params in test_cases:
        print(params)
        test = PerfTest(binary, dcache_params=params)
        test.run()
        print(test.dcache_result)
        tests.append(test)
        cache_size = int(params[0] * params[1] * params[2] / 1024)
        print(f"cache size: {cache_size} KiB")

    print("==== miss rate benchmark results ====")
    tests.sort(key=lambda test: test.dcache_result.miss_rate)

    fig, ax = plt.subplots()
    fig.set_size_inches(14, 10)
    fig.set_dpi(300)
    y_pos = np.arange(len(tests))
    results = [test.dcache_result.miss_rate * 100 for test in tests]
    labels = []
    for test in tests:
        label = f"D$ {test.dcache_params}\n{int(test.dcache_size / 1024)} KiB total"
        labels.append(label)
    bars = ax.barh(y_pos, results, align="center")
    ax.set_yticks(y_pos, labels=labels)
    ax.xaxis.set_major_formatter(mtick.PercentFormatter())
    ax.invert_yaxis()
    ax.set_title("miss rates for different d-cache arrangements\nworkload: matmul-naive")
    ax.bar_label(bars, fmt="%0.2f%%")
    ax.set_xlabel("miss rate (%)")
    ax.set_ylabel("cache configuration")
    plt.savefig("../../presentations/midterm-report/images/q2-naive-dcache.png")

# extract symbol offset/length from the binary
def get_function_addr_len(bin, function):
    cmd = ["riscv64-unknown-elf-nm", "--print-size", "-g"]
    cmd.append(bin)
    output = subprocess.run(cmd, capture_output=True, text=True).stdout
    print(" ".join(cmd))
    line = [s for s in output.splitlines() if function in s]
    addr, len = line[0].split()[0:2]
    print(addr, len)
    return int(addr, 16), int(len, 16)
    
def q2_execution_stats(file):
    variants = ["naive", "transpose", "alt", "vector"]
    sizes = defaultdict(list)
    counts = defaultdict(list)

    for v in variants:
        target_addr, target_len = get_function_addr_len("./matmul-O2.bin", f"matmul_{v}")
        cmd = ["./riscv-spike/build/spike", "--isa=rv64gqc", "-g"]
        cmd += ["--dc=256:4:64"]
        cmd += ["./riscv-pk/build/pk"]
        cmd += ["./matmul.bin", v]
        print(" ".join(cmd))
        hist = subprocess.run(cmd, capture_output=True, text=True).stderr
        total_count = 0
        for line in hist.splitlines()[1:]:
            addr = int(line.split()[0], 16)
            count = int(line.split()[1], 16)
            if addr in range(target_addr, target_addr + target_len):
                total_count += count
        print(total_count)
        sizes["-O2"].append(target_len)
        counts["-O2"].append(total_count)

    for v in variants:
        target_addr, target_len = get_function_addr_len("./matmul-O3.bin", f"matmul_{v}")
        cmd = ["./riscv-spike/build/spike", "--isa=rv64gqc", "-g"]
        cmd += ["--dc=256:4:64"]
        cmd += ["./riscv-pk/build/pk"]
        cmd += ["./matmul.bin", v]
        print(" ".join(cmd))
        hist = subprocess.run(cmd, capture_output=True, text=True).stderr
        total_count = 0
        for line in hist.splitlines()[1:]:
            addr = int(line.split()[0], 16)
            count = int(line.split()[1], 16)
            if addr in range(target_addr, target_addr + target_len):
                total_count += count
        print(total_count)
        sizes["-O3"].append(target_len)
        counts["-O3"].append(total_count)

    x = np.arange(len(variants))
    width = 0.25
    multiplier = 0
    fig, ax = plt.subplots()
    fig.set_size_inches(14, 10)
    fig.set_dpi(300)

    for opti_level, count in counts.items():
        print(opti_level, count)
        offset = width * multiplier
        rects = ax.bar(x + offset, count, width, label=opti_level)
        ax.bar_label(rects, padding=3)
        multiplier += 1

    ax.set_ylabel("Total executed instructions")
    ax.set_xticks(x+width, variants)
    ax.legend(loc="upper left", ncols=2)
    ax.set_title("Total executed instructions for different matmul methods")
    plt.savefig("../../presentations/midterm-report/images/q2-inst-count.png")


def q2_cache_stats():
    variants = ["naive", "transpose", "alt", "vector"]
    misses = defaultdict(list)
    for v in variants:
        test = PerfTest(["./matmul-O2.bin", v], dcache_params=(512, 4, 64))
        test.run()
        print(test.dcache_result)
        misses["-O2"].append(test.dcache_result.miss_rate)
    for v in variants:
        test = PerfTest(["./matmul-O3.bin", v], dcache_params=(512, 4, 64))
        test.run()
        print(test.dcache_result)
        misses["-O3"].append(test.dcache_result.miss_rate)
    print(misses)
        
    x = np.arange(len(variants))
    width = 0.25
    multiplier = 0
    fig, ax = plt.subplots()
    fig.set_size_inches(14, 10)
    fig.set_dpi(300)

    for opti_level, rate in misses.items():
        offset = width * multiplier
        rects = ax.bar(x + offset, rate, width, label=opti_level)
        ax.bar_label(rects, padding=3)
        multiplier += 1

    ax.set_title("d-cache miss rate for different matmul methods")
    ax.set_ylabel("miss rate")
    ax.set_xticks(x+width, variants)
    ax.legend(loc="upper left", ncols=2)
    plt.savefig("../../presentations/midterm-report/images/q2-miss-rate.png")





def main():
    # q1_icache()
    # q1_dcache()
    # q2_naive()
    # q2_execution_stats()
    # q2_execution_stats("../../presentations/midterm-report/images/q2-stats-comparison.png")
    q2_cache_stats()

if __name__ == "__main__":
    main()
