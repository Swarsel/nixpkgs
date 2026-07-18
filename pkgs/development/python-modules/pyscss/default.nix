{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
  six,
}:

buildPythonPackage (finalAttrs: {
  pname = "pyscss";
  version = "1.4.0";

  src = fetchFromGitHub {
    owner = "Kronuz";
    repo = "pyScss";
    tag = "v${finalAttrs.version}";
    hash = "sha256-z0y4z+/JE6rZWHAvps/taDZvutyVhxxs2gMujV5rNu4=";
  };

  # Test suite is broken.
  # See https://github.com/Kronuz/pyScss/issues/415
  doCheck = false;
  nativeCheckInputs = [ pytestCheckHook ];
  __structuredAttrs = true;
  build-system = [ setuptools ];
  dependencies = [ six ];
  pyproject = true;

  meta = {
    description = "Scss compiler for Python";
    homepage = "https://pyscss.readthedocs.org/en/latest/";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
})
