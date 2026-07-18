{
  lib,
  fetchFromGitHub,
  attrs,
  buildPythonPackage,
  click,
  consolekit,
  dist-meta,
  docutils,
  dom-toml,
  domdf-python-tools,
  editables,
  handy-archives,
  natsort,
  packaging,
  pyproject-parser,
  pytestCheckHook,
  setuptools,
  shippinglabel,
}:

buildPythonPackage rec {
  pname = "whey";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "repo-helper";
    repo = "whey";
    tag = "v${version}";
    hash = "sha256-s2jZmuFj0gTWVTcXWcBhcu5RBuaf/qMS/xzIpIoG1ZE=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail 'setuptools!=61.*,<=67.1.0,>=40.6.0' setuptools
  '';

  # missing dependency pyproject-examples
  doCheck = false;

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    attrs
    click
    consolekit
    dist-meta
    dom-toml
    domdf-python-tools
    handy-archives
    natsort
    packaging
    pyproject-parser
    shippinglabel
  ];

  optional-dependencies = {
    all = lib.concatAttrValues (lib.removeAttrs optional-dependencies [ "all" ]);

    editable = [
      editables
    ];

    readme = [
      docutils
      pyproject-parser
    ]
    ++ pyproject-parser.optional-dependencies.readme;
  };

  pyproject = true;
  pythonImportsCheck = [ "whey" ];

  meta = {
    description = "Simple Python wheel builder for simple projects";
    homepage = "https://github.com/repo-helper/whey";
    changelog = "https://github.com/repo-helper/whey/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ tyberius-prime ];
  };
}
