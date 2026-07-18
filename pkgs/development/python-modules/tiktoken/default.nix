{
  lib,
  stdenv,
  blobfile,
  buildPythonPackage,
  cargo,
  fetchPypi,
  libiconv,
  regex,
  requests,
  rustPlatform,
  rustc,
  setuptools,
  setuptools-rust,
}:
let
  pname = "tiktoken";
  version = "0.12.0";
  src = fetchPypi {
    inherit pname version;
    hash = "sha256-sYun7isJOGOXj8sU90s3B83I1NTTg2hTzn7GB3ITmTE=";
  };
  postPatch = ''
    cp ${./Cargo.lock} Cargo.lock
  '';
in
buildPythonPackage {
  inherit
    pname
    version
    src
    postPatch
    ;

  nativeBuildInputs = [
    rustPlatform.cargoSetupHook
    setuptools-rust
    cargo
    rustc
  ];

  buildInputs = lib.optionals stdenv.hostPlatform.isDarwin [ libiconv ];
  # almost all tests require network access
  doCheck = false;

  build-system = [
    setuptools
    setuptools-rust
  ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit
      pname
      version
      src
      postPatch
      ;

    hash = "sha256-daIKasW/lwYwIqMs3KvCDJWAoMn1CkPRpNqhl1jKpYY=";
  };

  dependencies = [
    requests
    regex
    blobfile
  ];

  pyproject = true;
  pythonImportsCheck = [ "tiktoken" ];

  meta = {
    description = "Fast BPE tokeniser for use with OpenAI's models";
    homepage = "https://github.com/openai/tiktoken";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ happysalada ];
  };
}
