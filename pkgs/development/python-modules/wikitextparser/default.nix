{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  flit-core,
  pytestCheckHook,
  regex,
  setuptools,
  wcwidth,
}:

buildPythonPackage rec {
  pname = "wikitextparser";
  version = "0.56.4";

  src = fetchFromGitHub {
    owner = "5j9";
    repo = "wikitextparser";
    rev = "v${version}";
    hash = "sha256-xg2cWhfJXS7zUuzXPslFTZz6mY/Pvl2F2b7HNWV2c3I=";
  };

  nativeBuildInputs = [ setuptools ];

  propagatedBuildInputs = [
    flit-core
    wcwidth
    regex
  ];

  nativeCheckInputs = [ pytestCheckHook ];
  pyproject = true;
  pythonImportsCheck = [ "wikitextparser" ];

  meta = {
    description = "Simple parsing tool for MediaWiki's wikitext markup";
    homepage = "https://github.com/5j9/wikitextparser";
    changelog = "https://github.com/5j9/wikitextparser/blob/v${version}/CHANGELOG.rst";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ rapiteanu ];
  };
}
