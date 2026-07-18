{
  lib,
  opentxl,
  runCommand,
}:
runCommand "opentxl-test"
  {
    src = lib.sources.sourceByRegex ./. [
      ".*.txl"
    ];

    nativeBuildInputs = [ opentxl ];
  }
  ''
    printf '10' > factorial.in
    result=$(txl factorial.in $src/factorial.txl)
    [[ "$result" -eq '3628800' ]] && touch $out
  ''
