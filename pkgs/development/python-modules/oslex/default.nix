{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatchling,
  mslex,
  pytestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "oslex";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "petamas";
    repo = "oslex";
    tag = "release/v${finalAttrs.version}";
    hash = "sha256-BTyLL3tb1P8VMGvTgoHGmwvFqf3gOyXOI+YmHuEjrKc=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [
    hatchling
  ];

  dependencies = [
    mslex
  ];

  pyproject = true;

  pythonImportsCheck = [
    "oslex"
  ];

  meta = {
    description = "OS-independent wrapper for shlex and mslex";
    homepage = "https://github.com/petamas/oslex";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ yzx9 ];
  };
})
