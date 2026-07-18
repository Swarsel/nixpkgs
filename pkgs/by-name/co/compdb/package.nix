{
  lib,
  fetchFromGitHub,
  python3,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "compdb";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "Sarcasm";
    repo = "compdb";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-nFAgTrup6V5oE+LP4UWDOCgTVCv2v9HbQbkGW+oDnTg=";
  };

  build-system = with python3.pkgs; [
    setuptools
  ];

  pyproject = true;

  meta = {
    description = "Command line tool to manipulate compilation databases";
    homepage = "https://github.com/Sarcasm/compdb";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.detegr ];
    mainProgram = "compdb";
  };
})
