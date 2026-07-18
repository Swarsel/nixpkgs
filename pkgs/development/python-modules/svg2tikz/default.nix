{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  inkex,
  lxml,
  poetry-core,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "svg2tikz";
  version = "3.3.4";

  src = fetchFromGitHub {
    owner = "xyz2tex";
    repo = "svg2tikz";
    tag = "v${version}";
    hash = "sha256-hIVxrUqT9g3e8eKdz1xPqRBiN62BPLav+xPHm6WCAqw=";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    poetry-core
  ];

  dependencies = [
    inkex
    lxml
  ];

  pyproject = true;
  pythonImportsCheck = [ "svg2tikz" ];

  pythonRelaxDeps = [
    "inkex"
    "lxml"
  ];

  meta = {
    description = "Set of tools for converting SVG graphics to TikZ/PGF code";
    homepage = "https://github.com/xyz2tex/svg2tikz";
    changelog = "https://github.com/xyz2tex/svg2tikz/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.gpl2Plus;

    maintainers = with lib.maintainers; [
      dotlambda
      gal_bolle
    ];
  };
}
