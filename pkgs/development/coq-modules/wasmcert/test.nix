{
  stdenv,
  coq,
  wasmcert,
}:

stdenv.mkDerivation {
  inherit (wasmcert) src version;
  pname = "wasmcert-interpreter-test";
  doCheck = true;

  nativeCheckInputs = [
    wasmcert
    coq
  ];

  checkPhase = ''
    coqc .ci/import_test.v

    wasm_coq_interpreter tests/add.wasm -r main

    if [ $? -ne 0 ]; then
      echo "Wasm_coq_interpreter failed to run hello world program"
      exit 1
    fi
  '';

  installPhase = "touch $out";
  dontBuild = true;
  dontConfigure = true;
}
