{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  commandlines,
  fonttools,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "ufolint";
  version = "1.2.0";

  # PyPI source tarballs omit tests, fetch from Github instead
  src = fetchFromGitHub {
    owner = "source-foundry";
    repo = "ufolint";
    rev = "v${version}";
    hash = "sha256-sv8WbnDd2LFHkwNsB9FO04OlLhemdzwjq0tC9+Fd6/M=";
  };

  nativeBuildInputs = [ pytestCheckHook ];

  propagatedBuildInputs = [
    commandlines
    fonttools
  ]
  ++ fonttools.optional-dependencies.ufo;

  build-system = [ setuptools ];
  pyproject = true;

  meta = {
    description = "Linter for Unified Font Object (UFO) source code";
    homepage = "https://github.com/source-foundry/ufolint";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ danc86 ];
    mainProgram = "ufolint";
  };
}
