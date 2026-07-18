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

  name = "${cudaNamePrefix}-tests-cudnn-frontend-samples";

  runtimeInputs = [
    cudnn-frontend.samples
    jq
  ];

  text = ''
    args=( "${getExe' cudnn-frontend.samples "samples"}" )

    if (( $# != 0 ))
    then
      args+=( "$@" )
      "''${args[@]}"
    else
      args+=(
        --success
        --rng-seed=0
        --reporter=json
      )
      echo "Running with default arguments: ''${args[*]}" >&2
      "''${args[@]}" | jq
    fi
  '';
}
