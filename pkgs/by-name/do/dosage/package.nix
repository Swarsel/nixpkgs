{
  lib,
  fetchPypi,
  nix-update-script,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "dosage";
  version = "3.3";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    sha256 = "sha256-hkk8JCR1cWrYJFOlSfZkGtSHvPQcQ9O+0MMLfq9x0us=";
  };

  nativeCheckInputs = with python3Packages; [
    pytestCheckHook
    pytest-xdist
    responses
  ];

  build-system = [ python3Packages.setuptools-scm ];

  dependencies = with python3Packages; [
    brotli
    imagesize
    lxml
    platformdirs
    requests
    rich
    zstandard
  ];

  pyproject = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Comic strip downloader and archiver";
    homepage = "https://dosage.rocks/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ toonn ];
    mainProgram = "dosage";
  };
})
