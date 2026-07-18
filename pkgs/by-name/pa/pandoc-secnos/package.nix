{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonApplication rec {
  pname = "pandoc-secnos";
  version = "2.2.2";

  src = fetchFromGitHub {
    owner = "tomduck";
    repo = pname;
    rev = version;
    sha256 = "sha256-J9KLZvioYM3Pl2UXjrEgd4PuLTwCLYy9SsJIzgw5/jU=";
  };

  patches = [
    ./patch/fix-manifest.patch
  ];

  nativeBuildInputs = with python3Packages; [
    setuptools
  ];

  propagatedBuildInputs = with python3Packages; [ pandoc-xnos ];
  # Different pandoc executables are not available
  doCheck = false;
  pyproject = true;

  meta = {
    description = "Standalone pandoc filter from the pandoc-xnos suite for numbering sections and section references";
    homepage = "https://github.com/tomduck/pandoc-secnos";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ ppenguin ];
    mainProgram = "pandoc-secnos";
  };
}
