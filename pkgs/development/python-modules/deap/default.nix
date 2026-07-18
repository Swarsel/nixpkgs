{
  lib,
  buildPythonPackage,
  fetchPypi,
  moocore,
  numpy,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "deap";
  version = "1.4.4";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-UNS9kk/KWhaj26i/2xFApV6cJM5QgWq09Wg9LzHC1zQ=";
    pname = "deap";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  __structuredAttrs = true;

  build-system = [
    setuptools
  ];

  dependencies = [
    moocore
    numpy
  ];

  pyproject = true;

  meta = {
    description = "Novel evolutionary computation framework for rapid prototyping and testing of ideas";
    homepage = "https://github.com/DEAP/deap";
    license = lib.licenses.lgpl3Plus;

    maintainers = with lib.maintainers; [
      getpsyched
      psyanticy
    ];
  };
})
