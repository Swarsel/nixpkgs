{
  lib,
  fetchFromGitHub,
  attrs,
  buildPythonPackage,
  # optionals
  cattrs,
  fonttools,
  lxml,
  msgpack,
  orjson,
  pytestCheckHook,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "ufolib2";
  version = "0.18.1";

  src = fetchFromGitHub {
    owner = "fonttools";
    repo = "ufoLib2";
    tag = "v${version}";
    hash = "sha256-YFGgPpiEurPaTUFaSMsVBKS4Ob+vPyZhputfRE39wtg=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ]
  ++ lib.concatAttrValues optional-dependencies;

  build-system = [ setuptools-scm ];

  dependencies = [
    attrs
    fonttools
  ]
  ++ fonttools.optional-dependencies.ufo;

  optional-dependencies = {
    converters = [ cattrs ];

    json = [
      cattrs
      orjson
    ];

    lxml = [ lxml ];

    msgpack = [
      cattrs
      msgpack
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "ufoLib2" ];

  meta = {
    description = "Library to deal with UFO font sources";
    homepage = "https://github.com/fonttools/ufoLib2";
    changelog = "https://github.com/fonttools/ufoLib2/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
