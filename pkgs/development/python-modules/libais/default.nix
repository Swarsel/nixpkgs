{
  lib,
  buildPythonPackage,
  fetchPypi,
  pytestCheckHook,
  setuptools,
  six,
}:

buildPythonPackage rec {
  pname = "libais";
  version = "0.17";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-6yrqIpjF6XaSfXSOTA0B4f3aLcHXkgA/3WBZBBNQ018=";
  };

  # data files missing
  doCheck = false;
  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  dependencies = [ six ];
  pyproject = true;
  pythonImportsCheck = [ "ais" ];

  meta = {
    description = "Library for decoding maritime Automatic Identification System messages";
    homepage = "https://github.com/schwehr/libais";
    changelog = "https://github.com/schwehr/libais/blob/master/Changelog.md";
    license = lib.licenses.asl20;
    maintainers = [ ];
    platforms = lib.platforms.unix;
  };
}
