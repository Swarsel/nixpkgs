{
  lib,
  fetchFromGitHub,
  coreutils,
  fetchPypi,
  gitMinimal,
  mercurial,
  python3,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "nbstripout";
  version = "0.8.2";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-KHZTDraEv5OltI/m2SshY/eNBAchx2s31bnhUU04/Gk=";
  };

  nativeCheckInputs = [
    coreutils
    gitMinimal
    mercurial
  ]
  ++ (with python3.pkgs; [
    pytestCheckHook
  ]);

  checkInputs = [
    testAssets
  ];

  preCheck = ''
    export HOME=$(mktemp -d)
    export PATH=$out/bin:$PATH
    git config --global init.defaultBranch main

    cp -r --no-preserve=mode,ownership ${testAssets}/tests/e2e_notebooks $TMPDIR/e2e_notebooks
    chmod -R +w $TMPDIR/e2e_notebooks
    substituteInPlace tests/test_end_to_end.py --replace "tests/e2e_notebooks" "$TMPDIR/e2e_notebooks"
  '';

  build-system = with python3.pkgs; [
    setuptools
  ];

  dependencies = with python3.pkgs; [
    nbformat
  ];

  pyproject = true;
  pythonImportsCheck = [ "nbstripout" ];

  testAssets = fetchFromGitHub {
    hash = "sha256-OSJLrWkYQIhcdyofS3Bo39ppsU6K3A4546UKB8Q1GGg=";
    owner = "kynan";
    repo = "nbstripout";
    rev = "${version}";
  };

  meta = {
    description = "Strip output from Jupyter and IPython notebooks";
    homepage = "https://github.com/kynan/nbstripout";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ jluttine ];
    mainProgram = "nbstripout";
  };
}
