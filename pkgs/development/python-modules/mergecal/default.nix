{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  icalendar,
  pytest-cov-stub,
  pytestCheckHook,
  rich,
  setuptools,
  typer,
  x-wr-timezone,
}:

buildPythonPackage rec {
  pname = "mergecal";
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "mergecal";
    repo = "python-mergecal";
    tag = "v${version}";
    hash = "sha256-Je3gFREu97Ycofszhr6pKOCiK76oBuzb3ji4LAf5aE8=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-cov-stub
  ];

  build-system = [ setuptools ];

  dependencies = [
    icalendar
    rich
    typer
    x-wr-timezone
  ];

  pyproject = true;
  pythonImportsCheck = [ "mergecal" ];

  meta = {
    homepage = "https://mergecal.readthedocs.io/en/latest/";
    changelog = "https://github.com/mergecal/python-mergecal/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ erictapen ];
  };
}
