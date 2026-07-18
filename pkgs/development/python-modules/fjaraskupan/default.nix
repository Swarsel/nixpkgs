{
  lib,
  fetchFromGitHub,
  bleak,
  bleak-retry-connector,
  buildPythonPackage,
  pytest-mock,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "fjaraskupan";
  version = "2.3.4";

  src = fetchFromGitHub {
    owner = "elupus";
    repo = "fjaraskupan";
    tag = finalAttrs.version;
    hash = "sha256-0rJoUQYexB+4ehOXKa1aca401E7opDtdoBmIW/2uOOE=";
  };

  nativeCheckInputs = [
    pytest-mock
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    bleak
    bleak-retry-connector
  ];

  pyproject = true;
  pythonImportsCheck = [ "fjaraskupan" ];

  meta = {
    description = "Module for controlling Fjäråskupan kitchen fans";
    homepage = "https://github.com/elupus/fjaraskupan";
    changelog = "https://github.com/elupus/fjaraskupan/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
