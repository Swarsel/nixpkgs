{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cached-property,
  pydantic,
  pytestCheckHook,
  setuptools,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "datauri";
  version = "3.0.2";

  src = fetchFromGitHub {
    owner = "fcurella";
    repo = "python-datauri";
    tag = "v${version}";
    hash = "sha256-WrOQPUZ9vaLSR0hxIvCK8kBnARiOLh6qqWBw/h6XpaY=";
  };

  nativeCheckInputs = [
    pydantic
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    typing-extensions
    cached-property
  ];

  pyproject = true;
  pythonImportsCheck = [ "datauri" ];

  meta = {
    description = "Module for Data URI manipulation";
    homepage = "https://github.com/fcurella/python-datauri";
    changelog = "https://github.com/fcurella/python-datauri/releases/tag/${src.tag}";
    license = lib.licenses.unlicense;
    maintainers = [ ];
  };
}
