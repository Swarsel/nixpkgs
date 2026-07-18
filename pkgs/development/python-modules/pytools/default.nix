{
  lib,
  buildPythonPackage,
  fetchPypi,
  hatchling,
  numpy,
  platformdirs,
  pytestCheckHook,
  siphash24,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "pytools";
  version = "2026.1.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-Jg4NiMmpA8Zc/jT76Bh2T0Sj+W5yLho2Rc5NWWrdIrE=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [ hatchling ];

  dependencies = [
    platformdirs
    siphash24
    typing-extensions
  ];

  optional-dependencies = {
    numpy = [ numpy ];
  };

  pyproject = true;

  pythonImportsCheck = [
    "pytools"
    "pytools.lex"
  ];

  meta = {
    description = "Miscellaneous Python lifesavers";
    homepage = "https://github.com/inducer/pytools/";
    changelog = "https://github.com/inducer/pytools/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
