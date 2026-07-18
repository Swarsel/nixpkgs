{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  commonmark,
  docutils,
  isPy3k,
  pytestCheckHook,
  sphinx,
}:

buildPythonPackage rec {
  pname = "recommonmark";
  version = "0.7.1";

  src = fetchFromGitHub {
    owner = "rtfd";
    repo = "recommonmark";
    rev = version;
    sha256 = "0kwm4smxbgq0c0ybkxfvlgrfb3gq9amdw94141jyykk9mmz38379";
  };

  propagatedBuildInputs = [
    commonmark
    docutils
    sphinx
  ];

  doCheck = !isPy3k; # Not yet compatible with latest Sphinx.
  nativeCheckInputs = [ pytestCheckHook ];

  disabledTests = [
    # https://github.com/readthedocs/recommonmark/issues/164
    "test_lists"
    "test_integration"
  ];

  format = "setuptools";
  pythonImportsCheck = [ "recommonmark" ];

  meta = {
    description = "Docutils-compatibility bridge to CommonMark";
    homepage = "https://github.com/rtfd/recommonmark";
    license = lib.licenses.mit;
  };
}
