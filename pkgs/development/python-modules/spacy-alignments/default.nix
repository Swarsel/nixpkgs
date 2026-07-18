{
  lib,
  stdenv,
  buildPythonPackage,
  cargo,
  fetchPypi,
  isPy3k,
  libiconv,
  rustPlatform,
  rustc,
  setuptools-rust,
}:

buildPythonPackage rec {
  pname = "spacy-alignments";
  version = "0.9.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-jcNYghWR9Xbu97/hAYe8ewa5oMQ4ofNGFwY4cY7/EmM=";
  };

  nativeBuildInputs = [
    setuptools-rust
    rustPlatform.cargoSetupHook
    cargo
    rustc
  ];

  buildInputs = lib.optionals stdenv.hostPlatform.isDarwin [ libiconv ];
  # Fails because spacy_alignments module cannot be loaded correctly.
  doCheck = false;

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit pname version src;
    hash = "sha256-0U1ELUMh4YV6M+zrrZGuzvY8SdgyN66F7bJ6sMhOdXs=";
  };

  disabled = !isPy3k;
  format = "setuptools";
  pythonImportsCheck = [ "spacy_alignments" ];

  meta = {
    description = "Align tokenizations for spaCy and transformers";
    homepage = "https://github.com/explosion/spacy-alignments";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
