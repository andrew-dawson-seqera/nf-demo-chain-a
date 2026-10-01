/*
 * Pipeline A — Data Producer
 *
 * Generates a synthetic sample sheet and writes it to S3,
 * then drops a marker file so a downstream Action can fire.
 */

params.outdir      = 's3://edu-test-bucket-pipelines/demo-chain'
params.num_samples = 5

process GENERATE_SAMPLES {
    /*
     * Produces a CSV that looks like a real sample manifest:
     * sample_id, organism, library_type, read_count
     */

    output:
    path 'samples.csv', emit: csv

    script:
    """
    cat <<'CSV' > samples.csv
    sample_id,organism,library_type,read_count
    SRR10001,Homo sapiens,paired-end,42318764
    SRR10002,Mus musculus,paired-end,38741029
    SRR10003,Homo sapiens,single-end,27654310
    SRR10004,Danio rerio,paired-end,51092847
    SRR10005,Homo sapiens,paired-end,44567123
    CSV
    sed -i 's/^[[:space:]]*//' samples.csv
    head -n \$(( ${params.num_samples} + 1 )) samples.csv > tmp && mv tmp samples.csv
    """
}

process PUBLISH_AND_MARK {
    /*
     * Copies the sample CSV to the output bucket and writes
     * a zero-byte marker file that signals "Pipeline A is done."
     *
     * The marker is the last thing written — if it exists,
     * the upstream data is guaranteed complete.
     */

    publishDir "${params.outdir}", mode: 'copy'

    input:
    path csv

    output:
    path csv
    path '.marker-a-complete'

    script:
    """
    touch .marker-a-complete
    """
}

workflow {
    GENERATE_SAMPLES()
    PUBLISH_AND_MARK( GENERATE_SAMPLES.out.csv )
}
