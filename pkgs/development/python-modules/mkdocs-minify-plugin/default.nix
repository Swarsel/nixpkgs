{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  csscompressor,
  htmlmin,
  jsmin,
  mkdocs,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "mkdocs-minify-plugin";
  version = "0.7.1";

  src = fetchFromGitHub {
    owner = "byrnereese";
    repo = "mkdocs-minify-plugin";
    tag = version;
    hash = "sha256-LDCAWKVbFsa6Y/tmY2Zne4nOtxe4KvNplZuWxg4e4L8=";
  };

  propagatedBuildInputs = [
    csscompressor
    htmlmin
    jsmin
    mkdocs
  ];

  # Some tests fail with an assertion error failure
  doCheck = false;

  nativeCheckInputs = [
    mkdocs
    pytestCheckHook
  ];

  format = "setuptools";
  pythonImportsCheck = [ "mkdocs" ];

  meta = {
    description = "Mkdocs plugin to minify the HTML of a page before it is written to disk";
    homepage = "https://github.com/byrnereese/mkdocs-minify-plugin";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ tfc ];
  };
}
