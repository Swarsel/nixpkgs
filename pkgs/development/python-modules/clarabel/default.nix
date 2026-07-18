{
  lib,
  stdenv,
  buildPythonPackage,
  cffi,
  fetchPypi,
  libiconv,
  nix-update-script,
  numpy,
  rustPlatform,
  scipy,
}:

buildPythonPackage rec {
  pname = "clarabel";
  version = "0.11.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-58QcR/Dlmuq5mu//nlivSodT7lJpu+7L1VJvxvQblZg=";
  };

  nativeBuildInputs = with rustPlatform; [
    cargoSetupHook
    maturinBuildHook
  ];

  buildInputs = lib.optional stdenv.hostPlatform.isDarwin libiconv;

  # no tests but run the same examples as .github/workflows/pypi.yaml
  checkPhase = ''
    runHook preCheck
    python examples/python/example_sdp.py
    python examples/python/example_qp.py
    runHook postCheck
  '';

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit pname version src;
    hash = "sha256-Cmxbz1zPA/J7EeJhGfD4Zt+QvyJK6BOZ+YQAsf8H+is=";
  };

  dependencies = [
    cffi
    numpy
    scipy
  ];

  pyproject = true;
  pythonImportsCheck = [ "clarabel" ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Conic Interior Point Solver";
    homepage = "https://github.com/oxfordcontrol/Clarabel.rs";
    changelog = "https://github.com/oxfordcontrol/Clarabel.rs/releases/tag/v${version}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
}
