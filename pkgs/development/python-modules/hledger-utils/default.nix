{
  lib,
  fetchFromGitLab,
  asteval,
  buildPythonPackage,
  drawilleplot,
  hledger,
  matplotlib,
  pandas,
  perl,
  psutil,
  rich,
  scipy,
  setuptools,
  setuptools-scm,
  unittestCheckHook,
}:

buildPythonPackage rec {
  pname = "hledger-utils";
  version = "1.14.0";

  src = fetchFromGitLab {
    owner = "nobodyinperson";
    repo = "hledger-utils";
    tag = "v${version}";
    hash = "sha256-Qu4nUcAGTACmLhwc7fkLxITOyFnUHv85qMhtViFumVs=";
  };

  nativeBuildInputs = [
    setuptools
    setuptools-scm
  ];

  propagatedBuildInputs = [
    rich
    pandas
    scipy
    psutil
    matplotlib
    drawilleplot
    asteval
  ];

  nativeCheckInputs = [
    hledger
    perl
  ];

  checkInputs = [ unittestCheckHook ];

  preCheck = ''
    export PATH=$out/bin:$PATH
  '';

  pyproject = true;

  meta = {
    description = "Utilities extending hledger";
    homepage = "https://gitlab.com/nobodyinperson/hledger-utils";

    license = with lib.licenses; [
      cc0
      cc-by-40
      gpl3
    ];

    maintainers = with lib.maintainers; [ nobbz ];
    platforms = lib.platforms.all;
  };
}
