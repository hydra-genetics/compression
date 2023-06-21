__author__ = "Martin Rippin"
__copyright__ = "Copyright 2021, Martin Rippin"
__email__ = "martin.rippin@scilifelab.uu.se"
__license__ = "GPL3"


rule samtools_view:
    input:
        bam="alignment/samtools_merge_bam/{file}.bam",
        bai="alignment/samtools_merge_bam/{file}.bam.bai",
        ref=config.get("reference", {}).get("fasta", ""),
    output:
        cram=temp("compression/samtools_view/{file}.cram"),
    params:
        extra=get_samtools_view_extra,
    log:
        "compression/samtools_view/{file}.cram.log",
    benchmark:
        repeat(
            "compression/samtools_view/{file}.cram.benchmark.tsv",
            config.get("samtools_view", {}).get("benchmark_repeats", 1),
        )
    resources:
        mem_mb=config.get("samtools_view", {}).get("mem_mb", config["default_resources"]["mem_mb"]),
        mem_per_cpu=config.get("samtools_view", {}).get("mem_per_cpu", config["default_resources"]["mem_per_cpu"]),
        partition=config.get("samtools_view", {}).get("partition", config["default_resources"]["partition"]),
        threads=config.get("samtools_view", {}).get("threads", config["default_resources"]["threads"]),
        time=config.get("samtools_view", {}).get("time", config["default_resources"]["time"]),
    threads: config.get("samtools_view", {}).get("threads", config["default_resources"]["threads"])
    container:
        config.get("samtools_view", {}).get("container", config["default_container"])
    message:
        "{rule}: compress bam file {input.bam} to cram"
    wrapper:
        "v1.3.1/bio/samtools/view"


rule samtools_index:
    input:
        cram="{file}.cram",
    output:
        crai=temp("{file}.cram.crai"),
    params:
        extra=config.get("samtools_index", {}).get("extra", ""),
    log:
        "{file}.cram.crai.log",
    benchmark:
        repeat(
            "{file}.cram.crai.benchmark.tsv",
            config.get("samtools_index", {}).get("benchmark_repeats", 1),
        )
    container:
        config.get("samtools_index", {}).get("container", config["default_container"])
    threads: config.get("samtools_index", {}).get("threads", config["default_resources"]["threads"])
    resources:
        mem_mb=config.get("samtools_index", {}).get("mem_mb", config["default_resources"]["mem_mb"]),
        mem_per_cpu=config.get("samtools_index", {}).get("mem_per_cpu", config["default_resources"]["mem_per_cpu"]),
        partition=config.get("samtools_index", {}).get("partition", config["default_resources"]["partition"]),
        threads=config.get("samtools_index", {}).get("threads", config["default_resources"]["threads"]),
        time=config.get("samtools_index", {}).get("time", config["default_resources"]["time"]),
    message:
        "{rule}: create index for {wildcards.file}"
    wrapper:
        "v1.1.0/bio/samtools/index"
