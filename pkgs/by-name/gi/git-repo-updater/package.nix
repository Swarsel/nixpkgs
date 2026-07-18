{
  lib,
  fetchPypi,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "gitup";
  version = "0.5.2";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-51DWPJ9JOMrRdWGaiiL4qzo4VFFeT1rG5yyI6Ej+ZRw=";
  };

  # no tests
  doCheck = false;
  build-system = with python3Packages; [ hatchling ];

  dependencies = with python3Packages; [
    colorama
    gitpython
  ];

  pyproject = true;

  meta = {
    description = "Easily update multiple Git repositories at once";
    homepage = "https://github.com/earwig/git-repo-updater";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      bdesham
      artturin
    ];

    mainProgram = "gitup";
  };
})
