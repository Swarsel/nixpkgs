{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "epr";
  version = "2.4.13";

  src = fetchFromGitHub {
    owner = "wustho";
    repo = "epr";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-1qsqYlqGlCRhl7HINrcTDt5bGlb7g5PmaERylT+UvEg=";
  };

  build-system = with python3Packages; [
    setuptools
  ];

  pyproject = true;

  meta = {
    description = "CLI Epub Reader";
    homepage = "https://github.com/wustho/epr";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
    mainProgram = "epr";
  };
})
