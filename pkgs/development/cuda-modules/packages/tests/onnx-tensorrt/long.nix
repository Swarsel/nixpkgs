{
  cudaNamePrefix,
  cuda_cudart,
  onnx-tensorrt,
  python3,
  writeShellApplication,
}:
writeShellApplication {
  derivationArgs = {
    strictDeps = true;
    __structuredAttrs = true;
  };

  name = "${cudaNamePrefix}-tests-onnx-tensorrt-long";

  runtimeInputs = [
    cuda_cudart
    (python3.withPackages (ps: [
      ps.onnx-tensorrt
      ps.pytest
      ps.six
    ]))
  ];

  text = ''
    args=(
      python3
      "${onnx-tensorrt.test_script}/onnx_backend_test.py"
    )

    if (( $# != 0 ))
    then
      args+=( "$@" )
    else
      args+=( --verbose )
      echo "Running with default arguments: ''${args[*]}" >&2
    fi

    mkdir -p "$HOME/.onnx"
    chmod -R +w "$HOME/.onnx"
    "''${args[@]}"
  '';
}
