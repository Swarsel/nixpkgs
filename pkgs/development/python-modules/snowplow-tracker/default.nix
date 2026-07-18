{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  freezegun,
  httmock,
  pytestCheckHook,
  requests,
  setuptools,
  typing-extensions,
}:

buildPythonPackage (finalAttrs: {
  pname = "snowplow-tracker";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "snowplow";
    repo = "snowplow-python-tracker";
    tag = finalAttrs.version;
    hash = "sha256-GfKMoMUUOxiUcUVdDc6YGgO+CVRvFjDtqQU/FrTO41U=";
  };

  nativeCheckInputs = [
    httmock
    freezegun
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    requests
    typing-extensions
  ];

  pyproject = true;
  pythonImportsCheck = [ "snowplow_tracker" ];

  meta = {
    description = "Add analytics to your Python and Django apps, webapps and games";
    homepage = "https://github.com/snowplow/snowplow-python-tracker";
    changelog = "https://github.com/snowplow/snowplow-python-tracker/blob/${finalAttrs.src.tag}/CHANGES.txt";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
})
