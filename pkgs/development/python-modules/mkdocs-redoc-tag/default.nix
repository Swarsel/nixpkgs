{
  lib,
  fetchFromGitHub,
  beautifulsoup4,
  buildPythonPackage,
  hatchling,
  mkdocs,
  mkdocs-material,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "mkdocs-redoc-tag";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "Blueswen";
    repo = "mkdocs-redoc-tag";
    tag = "v${version}";
    hash = "sha256-pgJMcK8LZOj0niyRcbHi8Szsro2iNTj6hz6r24jrtVw=";
  };

  propagatedBuildInputs = [
    mkdocs
    beautifulsoup4
  ];

  nativeCheckInputs = [
    mkdocs-material
    pytestCheckHook
  ];

  build-system = [ hatchling ];
  pyproject = true;
  pytestFlags = [ "-s" ];

  meta = {
    description = "MkDocs plugin supports for add Redoc UI in page";
    homepage = "https://github.com/blueswen/mkdocs-redoc-tag";
    changelog = "https://github.com/blueswen/mkdocs-redoc-tag/blob/v${version}/CHANGELOG";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ benhiemer ];
  };
}
