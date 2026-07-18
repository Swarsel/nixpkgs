{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "altcha";
  version = "2.0.2";

  src = fetchFromGitHub {
    owner = "altcha-org";
    repo = "altcha-lib-py";
    tag = "v${finalAttrs.version}";
    hash = "sha256-7KepW5PAl2prWdylBqBM/GDvsLGW+6le/itUiMBvFFU=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "altcha" ];

  meta = {
    description = "Lightweight Python library for creating and verifying ALTCHA challenges";
    homepage = "https://github.com/altcha-org/altcha-lib-py";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ erictapen ];
  };
})
