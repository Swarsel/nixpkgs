{
  lib,
  fetchFromGitHub,
  beautifulsoup4,
  buildPythonPackage,
  markdown,
  mkdocs,
  pandas,
  pytestCheckHook,
  pyyaml,
  rich,
  setuptools,
  super-collections,
}:

buildPythonPackage rec {
  pname = "mkdocs-test";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "fralau";
    repo = "mkdocs-test";
    tag = "v${version}";
    hash = "sha256-IP6qL+qR8uYSV5eG7/spiiNtdNghApdiuHBF+8OjPPg=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    mkdocs
  ]
  ++ pandas.optional-dependencies.html;

  build-system = [
    setuptools
  ];

  dependencies = [
    beautifulsoup4
    markdown
    mkdocs
    pandas
    pyyaml
    rich
    super-collections
  ];

  pyproject = true;

  pythonImportsCheck = [
    "mkdocs_test"
  ];

  meta = {
    description = "Framework for testing MkDocs projects";
    homepage = "https://github.com/fralau/mkdocs-test";
    changelog = "https://github.com/fralau/mkdocs-test/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ marcel ];
  };
}
