{
  lib,
  buildPythonPackage,
  fetchPypi,
  hatch-vcs,
  hatchling,
  pytest,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "pytest-env";
  version = "1.2.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-R14uvoYmzuAfSR8wSnSxITd0I5fWx4TqS8JY8GkjK4A=";
    pname = "pytest_env";
  };

  nativeBuildInputs = [
    hatch-vcs
    hatchling
  ];

  buildInputs = [ pytest ];
  nativeCheckInputs = [ pytestCheckHook ];
  pyproject = true;

  meta = {
    description = "Pytest plugin used to set environment variables";
    homepage = "https://github.com/MobileDynasty/pytest-env";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ erikarvstedt ];
  };
}
