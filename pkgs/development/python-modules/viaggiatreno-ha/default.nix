{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "viaggiatreno-ha";
  version = "0.2.4";

  src = fetchFromGitHub {
    owner = "monga";
    repo = "viaggiatreno_ha";
    tag = "v${version}";
    hash = "sha256-XmZVguuZK4pnAqINBWJbyAa5VesrQS6wP1jNPdWqhiQ=";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  preCheck = ''
    cd tests
  '';

  # Tests use aiohttp's AioHTTPTestCase which starts a local TCP server
  __darwinAllowLocalNetworking = true;
  build-system = [ setuptools ];
  dependencies = [ aiohttp ];
  pyproject = true;
  pythonImportsCheck = [ "viaggiatreno_ha" ];

  meta = {
    description = "Viaggiatreno API wrapper to use with Home Assistant";
    homepage = "https://github.com/monga/viaggiatreno_ha";
    changelog = "https://github.com/monga/viaggiatreno_ha/releases/tag/${src.tag}";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.jamiemagee ];
  };
}
