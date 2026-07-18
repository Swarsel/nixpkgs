{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  python-dateutil,
  pytz,
  regex,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "datefinder";
  version = "0.7.3";

  src = fetchFromGitHub {
    owner = "akoumjian";
    repo = "datefinder";
    tag = "v${finalAttrs.version}";
    hash = "sha256-uOSwS+mHgbvEL+rTfs4Ax9NvJnhYemxFVqqDssy2i7g=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  __structuredAttrs = true;
  build-system = [ setuptools ];

  dependencies = [
    regex
    pytz
    python-dateutil
  ];

  pyproject = true;
  pythonImportsCheck = [ "datefinder" ];

  meta = {
    description = "Extract datetime objects from strings";
    homepage = "https://github.com/akoumjian/datefinder";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      de11n
      despsyched
    ];
  };
})
