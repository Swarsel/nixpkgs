{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "tcolorpy";
  version = "0.1.7";

  src = fetchFromGitHub {
    owner = "thombashi";
    repo = "tcolorpy";
    tag = "v${version}";
    hash = "sha256-0AXpwRQgBisO4360J+Xd4+EWzDtDJ64UpSUmDnSYjKE=";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  pyproject = true;
  pythonImportsCheck = [ "tcolorpy" ];

  meta = {
    description = "Library to apply true color for terminal text";
    homepage = "https://github.com/thombashi/tcolorpy";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
