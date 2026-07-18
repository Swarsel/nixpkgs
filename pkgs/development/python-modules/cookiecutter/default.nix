{
  lib,
  arrow,
  bash,
  binaryornot,
  buildPythonPackage,
  click,
  fetchPypi,
  freezegun,
  git,
  isPyPy,
  jinja2,
  jinja2-time,
  pytest-cov-stub,
  pytest-mock,
  pytestCheckHook,
  python-slugify,
  pyyaml,
  requests,
  rich,
  setuptools,
}:

buildPythonPackage rec {
  pname = "cookiecutter";
  version = "2.6.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-2yH4Fp6k9P3CQI1IykSFk0neJkf75JSp1sPt/AVCwhw=";
  };

  postPatch = ''
    patchShebangs tests/test-pyshellhooks/hooks tests/test-shellhooks/hooks

    substituteInPlace tests/test_hooks.py \
      --replace-fail "/bin/bash" "${lib.getExe bash}"
  '';

  nativeCheckInputs = [
    pytestCheckHook
    pytest-cov-stub
    pytest-mock
    freezegun
    git
  ];

  preCheck = ''
    export HOME="$(mktemp -d)"
  '';

  build-system = [ setuptools ];

  dependencies = [
    binaryornot
    jinja2
    click
    pyyaml
    jinja2-time
    python-slugify
    requests
    arrow
    rich
  ];

  # not sure why this is broken
  disabled = isPyPy;

  disabledTests = [
    # messes with $PYTHONPATH
    "test_should_invoke_main"
  ];

  pyproject = true;
  pythonImportsCheck = [ "cookiecutter.main" ];

  meta = {
    description = "Command-line utility that creates projects from project templates";
    homepage = "https://github.com/audreyr/cookiecutter";
    changelog = "https://github.com/cookiecutter/cookiecutter/blob/${version}/HISTORY.md";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ kragniz ];
    mainProgram = "cookiecutter";
  };
}
