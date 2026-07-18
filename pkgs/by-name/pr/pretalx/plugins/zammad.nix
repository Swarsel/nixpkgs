{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  setuptools,
  zammad-py,
}:

buildPythonPackage (finalAttrs: {
  pname = "pretalx-zammad";
  version = "2025.0.1";

  src = fetchFromGitHub {
    owner = "badbadc0ffee";
    repo = "pretalx-zammad";
    tag = "v${finalAttrs.version}";
    hash = "sha256-YIKZO04vaKPGhUrTFiE4F+KjuBrYm0KsxUua5+Hm7gg=";
  };

  doCheck = false; # no tests

  build-system = [
    setuptools
  ];

  dependencies = [
    zammad-py
  ];

  pyproject = true;

  pythonImportsCheck = [
    "pretalx_zammad"
  ];

  meta = {
    description = "Pretalx plugin for Zammad issue tracker";
    homepage = "https://github.com/badbadc0ffee/pretalx-zammad";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ hexa ];
  };
})
