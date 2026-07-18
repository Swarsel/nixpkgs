{
  lib,
  fetchFromGitHub,
  R,
  gitMinimal,
  python3Packages,
  rPackages,
  writableTmpDirAsHomeHook,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "radian";
  version = "0.6.15";

  src = fetchFromGitHub {
    owner = "randy3k";
    repo = "radian";
    tag = "v${finalAttrs.version}";
    hash = "sha256-9dpLQ3QRppvwOw4THASfF8kCkIVZmWLALLRwy1LRPiE=";
  };

  nativeBuildInputs = [
    R # needed at setup time to detect R_HOME
  ];

  propagatedBuildInputs =
    (with python3Packages; [
      lineedit
      prompt-toolkit
      pygments
      rchitect
    ])
    ++ (with rPackages; [
      reticulate
      askpass
    ]);

  nativeCheckInputs =
    (with python3Packages; [
      pytestCheckHook
      pyte
      pexpect
      ptyprocess
      jedi
    ])
    ++ [
      gitMinimal
      writableTmpDirAsHomeHook
    ];

  preCheck = ''
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${R}/lib/R/lib
  '';

  build-system = with python3Packages; [
    setuptools
    setuptools-scm
  ];

  makeWrapperArgs = [ "--set R_HOME ${R}/lib/R" ];
  pyproject = true;
  pythonImportsCheck = [ "radian" ];

  meta = {
    description = "21 century R console";
    homepage = "https://github.com/randy3k/radian";
    changelog = "https://github.com/randy3k/radian/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ savyajha ];
    mainProgram = "radian";
  };
})
