{
  lib,
  buildPythonPackage,
  fetchPypi,
  hatch-vcs,
  hatchling,
  pytest-cov-stub,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "python-xz";
  version = "0.6.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-yNxRBweZ7p533dndIHoRzJFw6SmFQvgecYcHLg1UNHg=";
    pname = "python_xz";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-cov-stub
  ];

  build-system = [
    hatchling
    hatch-vcs
  ];

  pyproject = true;
  pythonImportsCheck = [ "xz" ];

  meta = {
    description = "Pure Python library for seeking within compressed xz files";
    homepage = "https://github.com/Rogdham/python-xz";
    changelog = "https://github.com/Rogdham/python-xz/blob/v${version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ mxmlnkn ];
    platforms = lib.platforms.all;
  };
}
