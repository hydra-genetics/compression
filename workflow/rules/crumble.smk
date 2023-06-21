__author__ = "Martin Rippin"
__copyright__ = "Copyright 2021, Martin Rippin"
__email__ = "martin.rippin@scilifelab.uu.se"
__license__ = "GPL3"


rule crumble:
    input:
        cram="compression/samtools_view/{file}.cram",
    output:
        crum=temp("compression/crumble/{file}.crumble.cram"),
    params:
        extra=config.get("crumble", {}).get("extra", ""),
    log:
        "compression/crumble/{file}.crumble.cram.log",
    benchmark:
        repeat(
            "compression/crumble/{file}.crumble.cram.benchmark.tsv",
            config.get("crumble", {}).get("benchmark_repeats", 1),
        )
    resources:
        mem_mb=config.get("crumble", {}).get("mem_mb", config["default_resources"]["mem_mb"]),
        mem_per_cpu=config.get("crumble", {}).get("mem_per_cpu", config["default_resources"]["mem_per_cpu"]),
        partition=config.get("crumble", {}).get("partition", config["default_resources"]["partition"]),
        threads=config.get("crumble", {}).get("threads", config["default_resources"]["threads"]),
        time=config.get("crumble", {}).get("time", config["default_resources"]["time"]),
    threads: config.get("crumble", {}).get("threads", config["default_resources"]["threads"])
    container:
        config.get("crumble", {}).get("container", config["default_container"])
    message:
        "{rule}: compress cram file {input.cram} to crumble cram"
    shell:
        "crumble "
        "{params.extra} "
        "{input.cram} "
        "{output.crum} &> {log}"
