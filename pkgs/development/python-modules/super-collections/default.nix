{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hjson,
  pytestCheckHook,
  pyyaml,
  rich,
  setuptools,
}:

buildPythonPackage rec {
  pname = "super-collections";
  version = "0.6.2";

  src = fetchFromGitHub {
    owner = "fralau";
    repo = "super-collections";
    tag = "v${version}";
    hash = "sha256-7QW5cL+TZlPX8ZMNNH+xZSGNIGr8Cy2jP1oSWy5tKaY=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    rich
    pyyaml
  ];

  build-system = [
    setuptools
  ];

  dependencies = [
    hjson
  ];

  pyproject = true;

  pythonImportsCheck = [
    "super_collections"
  ];

  meta = {
    description = "Python SuperDictionaries (with attributes) and SuperLists";
    homepage = "https://github.com/fralau/super-collections";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ marcel ];
  };
}
