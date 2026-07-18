{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "shutilwhich";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "mbr";
    repo = "shutilwhich";
    tag = finalAttrs.version;
    hash = "sha256-QNbEPJ37vrTIuhxS4NrUaUTH2A87EjBZvhxxg6xk3BU=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  __structuredAttrs = true;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "shutilwhich" ];

  meta = {
    description = "Backport of shutil.which";
    homepage = "https://github.com/mbr/shutilwhich";
    license = lib.licenses.psfl;
    maintainers = with lib.maintainers; [ multun ];
  };
})
