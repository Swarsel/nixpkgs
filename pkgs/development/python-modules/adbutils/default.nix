{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  deprecation,
  pbr,
  pillow,
  pytestCheckHook,
  requests,
  retry2,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "adbutils";
  version = "2.12.0";

  src = fetchFromGitHub {
    owner = "openatx";
    repo = "adbutils";
    tag = finalAttrs.version;
    hash = "sha256-zJz4fBekKOUeqBBfBPgGnHXVEKddelqReAQ2CEblObs=";
  };

  env = {
    PBR_VERSION = finalAttrs.version;
  };

  doCheck = !stdenv.hostPlatform.isDarwin;
  nativeCheckInputs = [ pytestCheckHook ];
  __structuredAttrs = true;

  build-system = [
    setuptools
  ];

  dependencies = [
    pbr
    deprecation
    pillow
    requests
    retry2
  ];

  pyproject = true;
  pythonImportsCheck = [ "adbutils" ];

  meta = {
    description = "Pure python adb library for google adb service";
    homepage = "https://github.com/openatx/adbutils";
    changelog = "https://github.com/openatx/adbutils/releases/tag/${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dshatz ];
  };
})
