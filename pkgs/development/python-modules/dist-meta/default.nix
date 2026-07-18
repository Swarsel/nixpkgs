{
  lib,
  buildPythonPackage,
  domdf-python-tools,
  fetchPypi,
  handy-archives,
  hatch-requirements-txt,
  hatchling,
  packaging,
}:
buildPythonPackage rec {
  pname = "dist-meta";
  version = "0.9.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-+hbr1VdHRKCVlqs0IIOhHXIJ2NBc8yiR0cmFvn7Ay9c=";
    pname = "dist_meta";
  };

  build-system = [
    hatchling
    hatch-requirements-txt
  ];

  dependencies = [
    domdf-python-tools
    handy-archives
    packaging
  ];

  pyproject = true;

  meta = {
    description = "Parse and create Python distribution metadata";
    homepage = "https://github.com/repo-helper/dist-meta";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ tyberius-prime ];
  };
}
