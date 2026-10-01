# nf-demo-chain-a

Pipeline A in the Actions v2 demo chain. It generates a small synthetic sample sheet, publishes it to S3, and drops a marker file so a downstream Seqera Action can launch the next pipeline.

## What it does

1. `GENERATE_SAMPLES` writes `samples.csv` with `sample_id`, `organism`, `library_type` and `read_count` columns.
2. `PUBLISH_AND_MARK` copies the CSV to the output bucket and writes a zero-byte `.marker-a-complete` file.

The marker is written last. If it exists, the sample sheet is complete and safe to consume.

## Run

```
nextflow run andrew-dawson-seqera/nf-demo-chain-a [--outdir <s3 path>] [--num_samples <n>]
```

## Params

| Param | Default | Description |
|-------|---------|-------------|
| `--outdir` | `s3://edu-test-bucket-pipelines/demo-chain` | Where the sample sheet and marker file are published. |
| `--num_samples` | `5` | Number of sample rows to keep, maximum 5. |

## Output

```
<outdir>/samples.csv
<outdir>/.marker-a-complete
```

## Demo chain

```
Pipeline A  --marker-->  Pipeline B  --marker-->  nf-sleep  --failure-->  Agent fix PR
```
