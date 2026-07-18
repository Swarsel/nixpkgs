{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  dataproperty,
  pytestCheckHook,
  setuptools-scm,
  typepy,
}:

buildPythonPackage rec {
  pname = "tabledata";
  version = "1.3.5";

  src = fetchFromGitHub {
    owner = "thombashi";
    repo = "tabledata";
    tag = "v${version}";
    hash = "sha256-yt71e2ZPJ5WpDLs6sU4kYQGR13IgJB7gMEzhaCHblos=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools-scm ];

  dependencies = [
    dataproperty
    typepy
  ];

  pyproject = true;

  meta = {
    description = "Library to represent tabular data";
    homepage = "https://github.com/thombashi/tabledata";
    changelog = "https://github.com/thombashi/tabledata/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
