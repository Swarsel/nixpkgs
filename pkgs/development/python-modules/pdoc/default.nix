{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hypothesis,
  jinja2,
  markdown2,
  markupsafe,
  nix-update-script,
  pdoc-pyo3-sample-library,
  pydantic,
  pygments,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pdoc";
  version = "16.0.0";

  src = fetchFromGitHub {
    owner = "mitmproxy";
    repo = "pdoc";
    tag = "v${version}";
    hash = "sha256-9amp6CWYIcniVfdlmPKYuRFR7B5JJtuMlOoDxpfvvJA=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    hypothesis
    pdoc-pyo3-sample-library
  ];

  __darwinAllowLocalNetworking = true;
  build-system = [ setuptools ];

  dependencies = [
    jinja2
    pygments
    markupsafe
    markdown2
    pydantic
  ];

  disabledTestMarks = [
    "slow" # skip slow tests
  ];

  disabledTestPaths = [
    # "test_snapshots" tries to match generated output against stored snapshots,
    # which are highly sensitive to dep versions.
    "test/test_snapshot.py"
  ];

  pyproject = true;
  pythonImportsCheck = [ "pdoc" ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "API Documentation for Python Projects";
    homepage = "https://pdoc.dev/";
    changelog = "https://github.com/mitmproxy/pdoc/blob/${src.rev}/CHANGELOG.md";
    license = lib.licenses.unlicense;
    maintainers = with lib.maintainers; [ pbsds ];
    mainProgram = "pdoc";
  };
}
