{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "pebble";
  version = "5.2.0";

  src = fetchFromGitHub {
    owner = "noxdafox";
    repo = "pebble";
    tag = finalAttrs.version;
    hash = "sha256-U6siydeKf/Ekqq2qHZj/ro2VQix2dRaP80d5CPQnRKU=";
  };

  doCheck = !stdenv.hostPlatform.isDarwin;
  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    setuptools
  ];

  pyproject = true;
  pythonImportsCheck = [ "pebble" ];

  meta = {
    description = "API to manage threads and processes within an application";
    homepage = "https://github.com/noxdafox/pebble";
    changelog = "https://github.com/noxdafox/pebble/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.lgpl3Plus;
    maintainers = [ ];
  };
})
