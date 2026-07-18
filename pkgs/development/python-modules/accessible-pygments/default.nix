{
  lib,
  buildPythonPackage,
  fetchPypi,
  hatch-fancy-pypi-readme,
  hatch-vcs,
  hatchling,
  pygments,
}:

buildPythonPackage rec {
  pname = "accessible-pygments";
  version = "0.0.5";

  src = fetchPypi {
    inherit version;
    hash = "sha256-QJGNPmorYZrUJMuR5Va9O9iGVEPZ8i8dzfeeM8gEaHI=";
    pname = "accessible_pygments";
  };

  # Tests only execute pygments with these styles
  doCheck = false;

  build-system = [
    hatchling
    hatch-vcs
    hatch-fancy-pypi-readme
  ];

  dependencies = [ pygments ];
  pyproject = true;

  pythonImportsCheck = [
    "a11y_pygments"
    "a11y_pygments.utils"
  ];

  meta = {
    description = "Collection of accessible pygments styles";
    homepage = "https://github.com/Quansight-Labs/accessible-pygments";
    changelog = "https://github.com/Quansight-Labs/accessible-pygments/raw/v${version}/CHANGELOG.md";
    license = lib.licenses.bsd3;
    maintainers = [ ];
  };
}
