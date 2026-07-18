{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  docutils,
  packaging,
  pdm-backend,
  platformdirs,
  pydantic,
  pytestCheckHook,
  sphinx,
  sphinx-autodoc-typehints,
  sphinx-rtd-theme,
  sphinxHook,
  tabulate,
}:

buildPythonPackage rec {
  pname = "pytoolconfig";
  version = "1.3.1";

  src = fetchFromGitHub {
    owner = "bagel897";
    repo = "pytoolconfig";
    tag = "v${version}";
    hash = "sha256-h21SDgVsnCDZQf5GS7sFE19L/p+OlAFZGEYKc0RHn30=";
  };

  outputs = [
    "out"
    "doc"
  ];

  nativeBuildInputs = [
    pdm-backend

    # docs
    docutils
    sphinx-autodoc-typehints
    sphinx-rtd-theme
    sphinxHook
  ]
  ++ optional-dependencies.doc;

  propagatedBuildInputs = [ packaging ];
  env.PDM_PEP517_SCM_VERSION = version;

  nativeCheckInputs = [
    pytestCheckHook
  ]
  ++ lib.concatAttrValues optional-dependencies;

  optional-dependencies = {
    doc = [
      sphinx
      tabulate
    ];

    global = [ platformdirs ];
    validation = [ pydantic ];
  };

  pyproject = true;
  pythonImportsCheck = [ "pytoolconfig" ];

  meta = {
    description = "Python tool configuration";
    homepage = "https://github.com/bagel897/pytoolconfig";
    changelog = "https://github.com/bagel897/pytoolconfig/releases/tag/v${version}";
    license = lib.licenses.lgpl3Plus;

    maintainers = with lib.maintainers; [
      fab
      hexa
    ];
  };
}
