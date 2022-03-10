__author__ = "Martin Rippin"
__copyright__ = "Copyright 2021, Martin Rippin"
__email__ = "martin.rippin@scilifelab.uu.se"
__license__ = "GPL3"


rule spring:
    input:
        fastq=lambda wildcards: [
            get_fastq_file(units, wildcards, "fastq1"),
            get_fastq_file(units, wildcards, "fastq2"),
        ],
    output:
        spring="compression/spring/{sample}_{flowcell}_{lane}_{type}.spring",
    params:
        extra=get_spring_extra,
    log:
        "compression/spring/{sample}_{flowcell}_{lane}_{type}.spring.log",
    benchmark:
        repeat(
            "compression/spring/{sample}_{flowcell}_{lane}_{type}.spring.benchmark.tsv",
            config.get("spring", {}).get("benchmark_repeats", 1),
        )
    resources:
        mem_mb=config.get("spring", {}).get("mem_mb", config["default_resources"]["mem_mb"]),
        mem_per_cpu=config.get("spring", {}).get("mem_per_cpu", config["default_resources"]["mem_per_cpu"]),
        partition=config.get("spring", {}).get("partition", config["default_resources"]["partition"]),
        threads=config.get("spring", {}).get("threads", config["default_resources"]["threads"]),
        time=config.get("spring", {}).get("time", config["default_resources"]["time"]),
    threads: config.get("spring", {}).get("threads", config["default_resources"]["threads"])
    conda:
        "../envs/spring.yaml"
    container:
        config.get("spring", {}).get("container", config["default_container"])
    message:
        "{rule}: compress fastq files {input.fastq}"
    shell:
        "(spring "
        "-i {input.fastq} "
        "-t {threads} "
        "-c "
        "{params.extra} "
        "-w compression/spring/ "
        "-o {output.spring}) &> {log}"
