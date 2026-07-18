{
  lib,
  stdenv,
  buildPythonPackage,
  cargo,
  libiconv,
  pytestCheckHook,
  pythonAtLeast,
  rustPlatform,
  rustc,
  setuptools-rust,
  sudachi-rs,
  sudachidict-core,
  sudachipy,
  tokenizers,
}:

buildPythonPackage rec {
  inherit (sudachi-rs) src version;
  pname = "sudachipy";

  nativeBuildInputs = [
    cargo
    rustPlatform.cargoSetupHook
    rustc
    setuptools-rust
  ];

  buildInputs = lib.optionals stdenv.hostPlatform.isDarwin [ libiconv ];

  preBuild = ''
    cd python
  '';

  # avoid infinite recursion due to sudachidict
  doCheck = false;

  nativeCheckInputs = [
    pytestCheckHook
    sudachidict-core
    tokenizers
  ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit pname version src;
    hash = "sha256-qWuFY97qPoKVxWp29ywaMEr2fTc0Y4wDR9LK+40r6QI";
  };

  disabled = pythonAtLeast "3.14"; # The pyo3 version used does not support 3.14+
  format = "setuptools";
  pythonImportsCheck = [ "sudachipy" ];

  passthru = {
    inherit (sudachi-rs) updateScript;

    tests = {
      pytest = sudachipy.overridePythonAttrs (_: {
        doCheck = true;
        # avoid catchConflicts of sudachipy
        # we don't need to install this package since it is just a test
        dontInstall = true;
      });
    };
  };

  meta = sudachi-rs.meta // {
    homepage = "https://github.com/WorksApplications/sudachi.rs/tree/develop/python";
    mainProgram = "sudachipy";
  };
}
