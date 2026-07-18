{
  lib,
  fetchFromGitHub,
  aiohttp,
  apispec,
  bottle,
  buildPythonPackage,
  flask,
  flit-core,
  mock,
  pytestCheckHook,
  tornado,
}:

buildPythonPackage rec {
  pname = "apispec-webframeworks";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "marshmallow-code";
    repo = "apispec-webframeworks";
    tag = version;
    hash = "sha256-V4tdqcHfYRh9VoXUTPXM3SIOogJDJB14SLj5dSd7LzU=";
  };

  nativeCheckInputs = [
    aiohttp
    bottle
    flask
    mock
    pytestCheckHook
    tornado
  ];

  build-system = [ flit-core ];
  dependencies = [ apispec ] ++ apispec.optional-dependencies.yaml;
  pyproject = true;
  pythonImportsCheck = [ "apispec_webframeworks" ];

  meta = {
    description = "Web framework plugins for apispec";
    homepage = "https://github.com/marshmallow-code/apispec-webframeworks";
    changelog = "https://github.com/marshmallow-code/apispec-webframeworks/blob/${version}/CHANGELOG.rst";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
