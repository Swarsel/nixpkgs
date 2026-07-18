{
  lib,
  buildPythonPackage,
  fetchPypi,
  hatch-vcs,
  hatchling,
  pytest,
  pytestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "pytest-metadata";
  version = "3.1.1";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-0qKbA1X7wD8WiqltQf+IsaO0SjsCrL5JGAHJigSAF8g=";
    pname = "pytest_metadata";
  };

  nativeBuildInputs = [
    hatchling
    hatch-vcs
  ];

  buildInputs = [ pytest ];
  nativeCheckInputs = [ pytestCheckHook ];
  pyproject = true;

  meta = {
    description = "Plugin for accessing test session metadata";
    homepage = "https://github.com/pytest-dev/pytest-metadata";
    license = lib.licenses.mpl20;
    maintainers = with lib.maintainers; [ mpoquet ];
  };
})
