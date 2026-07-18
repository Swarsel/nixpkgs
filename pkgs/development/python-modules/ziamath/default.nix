{
  lib,
  fetchurl,
  fetchFromGitHub,
  buildPythonPackage,
  latex2mathml,
  nbval,
  pytestCheckHook,
  setuptools,
  writableTmpDirAsHomeHook,
  ziafont,
}:
buildPythonPackage rec {
  pname = "ziamath";
  version = "0.13";

  src = fetchFromGitHub {
    owner = "cdelker";
    repo = "ziamath";
    tag = version;
    hash = "sha256-4TSKxCCU4DP+CQKJoi3nBqstHVUb9ycz+JAlYctxGxY=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    nbval
    latex2mathml
    writableTmpDirAsHomeHook
  ];

  preCheck =
    let
      # The test notebooks try to download font files, unless they already exist in the test directory,
      # so we prepare them in advance.
      checkFonts = lib.map fetchurl (import ./checkfonts.nix);
      copyFontCmd = font: "cp ${font} test/${lib.last (lib.splitString "/" font.url)}\n";
    in
    lib.concatMapStrings copyFontCmd checkFonts;

  build-system = [ setuptools ];
  dependencies = [ ziafont ];
  pyproject = true;
  pytestFlags = [ "--nbval-lax" ];
  pythonImportsCheck = [ "ziamath" ];

  meta = {
    description = "Render MathML and LaTeX Math to SVG without Latex installation";
    homepage = "https://ziamath.readthedocs.io/en/latest/";
    changelog = "https://ziamath.readthedocs.io/en/latest/changes.html";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sfrijters ];
  };
}
