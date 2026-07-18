{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cargo,
  nix-update-script,
  numpy,
  pytest-cov-stub,
  pytestCheckHook,
  rustPlatform,
  rustc,
  scikit-learn,
  scipy,
  setuptools,
  setuptools-rust,
  setuptools-scm,
}:
buildPythonPackage (finalAttrs: {
  pname = "scalib";
  version = "0.6.4";

  src = fetchFromGitHub {
    owner = "simple-crypto";
    repo = "SCALib";
    tag = "v${finalAttrs.version}";
    hash = "sha256-DVXb93W0TmOcyGyMN5GmIJNAdbLeeFnNm+3QfTw2j5s=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail '"setuptools-scm-git-archive",' ""
  '';

  nativeBuildInputs = [
    cargo
    rustPlatform.cargoSetupHook
    rustc
    setuptools-rust
  ];

  env = {
    SCALIB_PORTABLE = "1";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-cov-stub
    scikit-learn
    scipy
    numpy
  ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs)
      pname
      version
      src
      cargoRoot
      ;

    hash = "sha256-mzzp5EnaBYIbGGxJ9mJ6dqRVcTDS406BRx7hWVZ11SY=";
  };

  cargoRoot = "src/scalib_ext";

  dependencies = [
    numpy
  ];

  pyproject = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Side-Channel Analysis Library";
    homepage = "https://github.com/simple-crypto/scalib";
    changelog = "https://github.com/simple-crypto/SCALib/blob/${finalAttrs.src.tag}/CHANGELOG.rst";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ d-brasher ];
  };
})
