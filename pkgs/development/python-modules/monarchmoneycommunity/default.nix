{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  gql,
  oathtool,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "monarchmoneycommunity";
  version = "1.5.1";

  src = fetchFromGitHub {
    owner = "bradleyseanf";
    repo = "monarchmoneycommunity";
    tag = "v${finalAttrs.version}";
    hash = "sha256-3dOBFXzWJzLQ3Lr1lqwYxJ7s4uiUZatwEdZx3lRnhGs=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    gql
    oathtool
  ];

  pyproject = true;
  pythonImportsCheck = [ "monarchmoney" ];

  meta = {
    description = "Monarch Money API for Python";
    homepage = "https://github.com/bradleyseanf/monarchmoneycommunity";
    changelog = "https://github.com/bradleyseanf/monarchmoneycommunity/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.jamiemagee ];
  };
})
