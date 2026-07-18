{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  coloraide,
  decorator,
  freezegun,
  humanize,
  multimethod,
  platformdirs,
  # build-system
  poetry-core,
  pytest-cov-stub,
  # tests
  pytestCheckHook,
  # passthru
  rgbxy,
  rich,
  sqlparse,
  typing-extensions,
}:
buildPythonPackage (finalAttrs: {
  pname = "rich-tables";
  version = "0.9.0";

  src = fetchFromGitHub {
    owner = "snejus";
    repo = "rich-tables";
    tag = finalAttrs.version;
    hash = "sha256-6sXWrFP8TDBcFaGCymsZfHL8bfsRbj63VZCeY1H6h/Y=";
  };

  nativeBuildInputs = [
    pytestCheckHook
    pytest-cov-stub
    freezegun
  ]
  ++ finalAttrs.finalPackage.passthru.optional-dependencies.hue;

  build-system = [
    poetry-core
  ];

  dependencies = [
    coloraide
    decorator
    humanize
    multimethod
    platformdirs
    rich
    sqlparse
    typing-extensions
  ];

  optional-dependencies = {
    hue = [
      rgbxy
    ];
  };

  pyproject = true;

  pythonImportsCheck = [
    "rich_tables"
  ];

  pythonRelaxDeps = [
    "multimethod"
  ];

  meta = {
    description = "Ready-made rich tables for various purposes";
    homepage = "https://pypi.org/project/rich-tables/";
    license = lib.licenses.mit;

    maintainers = [
      lib.maintainers._9999years
    ];

    mainProgram = "table";
  };
})
