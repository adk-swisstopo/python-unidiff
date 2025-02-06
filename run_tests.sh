#! /bin/bash
PYTHONPATH=unidiff python -m unittest discover -s tests/

sample_dir=tests/samples
tmpdir=$(mktemp -d -t unidiff.XXXXXXXXXX)
trap 'rm -r -- "$tmpdir"' EXIT

test_program () {
  local program=$1
  local opt=$2
  for sample in $sample_dir/*.diff
  do
    sample=$(basename $sample)
    stdout=${sample%.diff}.$program.stdout
    stderr=${sample%.diff}.$program.stderr
    printf "$program $opt % -40s" $sample
    PYTHONPATH=. bin/$program $opt $sample_dir/$sample > $tmpdir/$stdout 2> $tmpdir/$stderr
    retval=$?
    failure=""
    cmp $sample_dir/$stdout $tmpdir/$stdout || failure="wrong stdout"
    cmp $sample_dir/$stderr $tmpdir/$stderr || failure="wrong stderr"
    [ $retval = 0 ] && [ -s $sample_dir/$stderr ] && failure="unexpected success"
    [ $retval != 0 ] && [ ! -s $sample_dir/$stderr ] && failure="unexpected failure"
    [ -n "$failure" ] && echo "FAIL: $failure" || echo "PASS"
  done
}

test_program unidiff -f
test_program shunk
