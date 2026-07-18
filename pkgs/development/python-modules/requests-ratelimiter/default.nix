{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatchling,
  pyrate-limiter,
  pytestCheckHook,
  requests,
  requests-cache,
  requests-mock,
}:

buildPythonPackage (finalAttrs: {
  pname = "requests-ratelimiter";
  version = "0.10.0";

  src = fetchFromGitHub {
    owner = "JWCook";
    repo = "requests-ratelimiter";
    tag = "v${finalAttrs.version}";
    hash = "sha256-P6tDx/jzGEyFC10WIyHQZIFMSEmtMnHjl+jEih987j8=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    requests-cache
    requests-mock
  ];

  build-system = [ hatchling ];

  dependencies = [
    pyrate-limiter
    requests
  ];

  pyproject = true;
  pythonImportsCheck = [ "requests_ratelimiter" ];

  meta = {
    description = "Module for rate-limiting for requests";
    homepage = "https://github.com/JWCook/requests-ratelimiter";
    changelog = "https://github.com/JWCook/requests-ratelimiter/blob/${finalAttrs.src.tag}/HISTORY.md";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
})
