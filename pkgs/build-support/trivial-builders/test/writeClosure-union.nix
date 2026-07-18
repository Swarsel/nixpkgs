{
  lib,
  runCommandLocal,
  samples,
  # Test targets
  writeClosure,
}:
runCommandLocal "test-trivial-builders-writeClosure-union"
  {
    inherit samples;
    __structuredAttrs = true;
    closures = lib.mapAttrs (n: v: writeClosure [ v ]) samples;
    collectiveClosure = writeClosure (lib.attrValues samples);

    meta.maintainers = with lib.maintainers; [
      ShamrockLee
    ];
  }
  ''
    set -eu -o pipefail
    echo >&2 Testing mixed closures...
    echo >&2 Checking all samples "(''${samples[*]})" "$collectiveClosure"
    diff -U3 \
      <(sort <"$collectiveClosure") \
      <(cat "''${closures[@]}" | sort | uniq)
    touch "$out"
  ''
