{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  latex2mathml,
  matplotlib,
  nbval,
  pyparsing,
  pytestCheckHook,
  setuptools,
  writableTmpDirAsHomeHook,
  ziafont,
  ziamath,
}:

buildPythonPackage rec {
  pname = "schemdraw";
  version = "0.23";

  src = fetchFromGitHub {
    owner = "cdelker";
    repo = "schemdraw";
    tag = version;
    hash = "sha256-NAvJDrJKf4CYs9W4zdNAU8WnuXlCK6FU44+5flWzyAk=";
  };

  # Strip out references to unfree fonts from the test suite
  postPatch = ''
    substituteInPlace test/test_backend.ipynb --replace-fail "(font='Times')" "()"
  '';

  nativeCheckInputs = [
    pytestCheckHook
    nbval
    matplotlib
    latex2mathml
    ziafont
    ziamath
    writableTmpDirAsHomeHook
  ];

  preCheck = "rm test/test_pictorial.ipynb"; # Tries to download files
  build-system = [ setuptools ];
  dependencies = [ pyparsing ];

  optional-dependencies = {
    matplotlib = [ matplotlib ];

    svgmath = [
      latex2mathml
      ziafont
      ziamath
    ];
  };

  pyproject = true;
  pytestFlags = [ "--nbval-lax" ];
  pythonImportsCheck = [ "schemdraw" ];

  meta = {
    description = "Package for producing high-quality electrical circuit schematic diagrams";
    homepage = "https://schemdraw.readthedocs.io/en/latest/";
    changelog = "https://schemdraw.readthedocs.io/en/latest/changes.html";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ sfrijters ];
  };
}
