{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  ciso8601,
  msgpack,
  orjson,
  pendulum,
  pytest-mock,
  pytestCheckHook,
  pyyaml,
  setuptools,
  tomli-w,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "mashumaro";
  version = "3.21";

  src = fetchFromGitHub {
    owner = "Fatal1ty";
    repo = "mashumaro";
    tag = "v${version}";
    hash = "sha256-SWmZA/yoiElQ299+BkjwTdcPukKfgw/UgUwiesFRkqo=";
  };

  nativeCheckInputs = [
    ciso8601
    pendulum
    pytest-mock
    pytestCheckHook
  ]
  ++ lib.concatAttrValues optional-dependencies;

  build-system = [ setuptools ];
  dependencies = [ typing-extensions ];

  optional-dependencies = {
    msgpack = [ msgpack ];
    orjson = [ orjson ];
    toml = [ tomli-w ];
    yaml = [ pyyaml ];
  };

  pyproject = true;
  pythonImportsCheck = [ "mashumaro" ];

  meta = {
    description = "Serialization library on top of dataclasses";
    homepage = "https://github.com/Fatal1ty/mashumaro";
    changelog = "https://github.com/Fatal1ty/mashumaro/releases/tag/${src.tag}";
    license = lib.licenses.asl20;
  };
}
