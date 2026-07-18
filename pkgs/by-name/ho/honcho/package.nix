{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "honcho";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "nickstenning";
    repo = "honcho";
    tag = "v${finalAttrs.version}";
    hash = "sha256-hXPoqxK9jzCn7KrQ6zH0E/3YVC60OSoiUx6654+bhhw=";
  };

  # missing plugins
  doCheck = false;

  nativeCheckInputs = with python3Packages; [
    jinja2
    pytest
    mock
    coverage
  ];

  checkPhase = ''
    runHook preCheck

    PATH=$out/bin:$PATH coverage run -m pytest

    runHook postCheck
  '';

  build-system = with python3Packages; [
    setuptools
    setuptools-scm
  ];

  pyproject = true;

  meta = {
    description = "Python clone of Foreman, a tool for managing Procfile-based applications";
    homepage = "https://github.com/nickstenning/honcho";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ benley ];
    platforms = lib.platforms.unix;
    mainProgram = "honcho";
  };
})
