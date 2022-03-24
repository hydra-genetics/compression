__author__ = "Martin Rippin"
__copyright__ = "Copyright 2021, Martin Rippin"
__email__ = "martin.rippin@scilifelab.uu.se"
__license__ = "GPL-3"


import pandas
import yaml

from hydra_genetics.utils.resources import load_resources
from hydra_genetics.utils.samples import *
from hydra_genetics.utils.units import *
from snakemake.utils import min_version
from snakemake.utils import validate

min_version("6.10")

### Set and validate config file


configfile: "config.yaml"


validate(config, schema="../schemas/config.schema.yaml")
config = load_resources(config, config["resources"])
validate(config, schema="../schemas/resources.schema.yaml")


### Read and validate samples file

samples = pandas.read_table(config["samples"], dtype=str).set_index("sample", drop=False)
validate(samples, schema="../schemas/samples.schema.yaml")

### Read and validate units file

units = pandas.read_table(config["units"], dtype=str).set_index(["sample", "type", "flowcell", "lane"], drop=False).sort_index()
validate(units, schema="../schemas/units.schema.yaml")


### Set wildcard constraints


wildcard_constraints:
    sample="|".join(get_samples(samples)),
    unit="N|T|R",
    read="fastq[1|2]",


### Functions


def get_samtools_view_extra(wildcards: snakemake.io.Wildcards):
    extra = "{extra} -T {ref}".format(
        extra=config.get("samtools_view", {}).get("extra", ""),
        ref=config.get("reference", {}).get("fasta", ""),
    )
    return extra


def get_spring_extra(wildcards: snakemake.io.Wildcards):
    extra = config.get("spring", {}).get("extra", "")
    if get_fastq_file(units, wildcards, "fastq1").endswith(".gz"):
        extra = "%s %s" % (extra, "-g")
    return extra


def compile_output_list(wildcards: snakemake.io.Wildcards):
    output_list = [
        "compression/spring/%s_%s_%s_%s.spring" % (sample, flowcell, lane, t)
        for sample in set(units["sample"])
        for flowcell in set(units["flowcell"])
        for lane in set(units["lane"])
        for t in set(units["type"])
    ]
    output_list.append(
        [
            "compression/crumble/%s_%s.crumble.cram" % (sample, t)
            for sample in get_samples(samples)
            for t in get_unit_types(units, sample)
        ]
    )
    return output_list
