{
  lib,
  buildPythonPackage,
  cjkwrap,
  fetchPypi,
  mistune,
  pytestCheckHook,
  wcwidth,
}:

buildPythonPackage rec {
  pname = "md2gemini";
  version = "1.9.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-XreDqqzH3UQ+RIBOrvHpaBb7PXcPPptjQx5cjpI+VzQ=";
  };

  propagatedBuildInputs = [
    mistune
    cjkwrap
    wcwidth
  ];

  nativeCheckInputs = [ pytestCheckHook ];
  format = "setuptools";
  pythonImportsCheck = [ "md2gemini" ];

  meta = {
    description = "Markdown to Gemini text format conversion library";
    homepage = "https://github.com/makeworld-the-better-one/md2gemini";
    license = lib.licenses.lgpl3Plus;
    maintainers = [ lib.maintainers.kaction ];
    broken = lib.versionAtLeast mistune.version "3";
  };
}
