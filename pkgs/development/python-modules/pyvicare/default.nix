{
  lib,
  fetchFromGitHub,
  authlib,
  buildPythonPackage,
  deprecated,
  poetry-core,
  pytest-cov-stub,
  pytestCheckHook,
  requests,
}:

buildPythonPackage (finalAttrs: {
  pname = "pyvicare";
  version = "2.60.2";

  src = fetchFromGitHub {
    owner = "openviess";
    repo = "PyViCare";
    tag = finalAttrs.version;
    hash = "sha256-hXmIPKa37kSEJT/4m41AtemjWf1oO0f1FtnFGzY6cQw=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail 'version = "0.1.0"' 'version = "${finalAttrs.version}"'
  '';

  nativeCheckInputs = [
    pytest-cov-stub
    pytestCheckHook
  ];

  build-system = [ poetry-core ];

  dependencies = [
    authlib
    deprecated
    requests
  ];

  pyproject = true;
  pythonImportsCheck = [ "PyViCare" ];

  meta = {
    description = "Python Library to access Viessmann ViCare API";
    homepage = "https://github.com/somm15/PyViCare";
    changelog = "https://github.com/openviess/PyViCare/releases/tag/${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
})
