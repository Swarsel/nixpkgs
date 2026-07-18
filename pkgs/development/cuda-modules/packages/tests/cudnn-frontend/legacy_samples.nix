{
  lib,
  cudaNamePrefix,
  cudnn-frontend,
  jq,
  writeShellApplication,
}:
let
  inherit (lib.meta) getExe';
in
writeShellApplication {
  derivationArgs = {
    strictDeps = true;
    __structuredAttrs = true;
  };

  name = "${cudaNamePrefix}-tests-cudnn-frontend-legacy-samples";

  runtimeInputs = [
    cudnn-frontend.legacy_samples
    jq
  ];

  text = ''
    args=( "${getExe' cudnn-frontend.legacy_samples "legacy_samples"}" )

    if (( $# != 0 ))
    then
      args+=( "$@" )
      "''${args[@]}"
    else
      args+=(
        --success
        --rng-seed=0
        --reporter=json
        exclude:"Scale Bias Conv BNGenstats with CPU Reference"
      )
      echo "Running with default arguments: ''${args[*]}" >&2
      "''${args[@]}" | jq
    fi
  '';
}
