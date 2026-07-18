{
  lib,
  fetchFromGitHub,
  python3Packages,
}:
python3Packages.buildPythonApplication (finalAttrs: {
  pname = "vermin";
  version = "1.8.0";

  src = fetchFromGitHub {
    owner = "netromdk";
    repo = "vermin";
    rev = "v${finalAttrs.version}";
    hash = "sha256-UJAIwxCnI8gcEPgLep5sKHxcDtJFB65S7OA043VN5S8=";
  };

  checkPhase = ''
    runHook preCheck
    python runtests.py
    runHook postCheck
  '';

  build-system = with python3Packages; [
    setuptools
  ];

  dependencies = with python3Packages; [
    setuptools
  ];

  pyproject = true;

  meta = {
    description = "Concurrently detect the minimum Python versions needed to run code";
    homepage = "https://github.com/netromdk/vermin";
    changelog = "https://github.com/netromdk/vermin/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.fidgetingbits ];
    mainProgram = "vermin";
  };
})
