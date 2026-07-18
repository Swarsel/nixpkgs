{
  lib,
  fetchPypi,
  nix-update-script,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "asciimol";
  version = "1.2.7";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-SqwViOnVx1TcpY8Kd5VQCg1A8KQnBhL8aq9Gsrwer3k=";
  };

  __structuredAttrs = true;
  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    numpy
    ase
    rdkit
  ];

  pyproject = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Curses based ASCII molecule viewer for terminals";
    homepage = "https://github.com/dewberryants/asciimol";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ tomasrivera ];
    mainProgram = "asciimol";
    downloadPage = "https://pypi.org/project/asciimol/";
  };
})
