{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  commandlines,
  naked,
  pexpect,
  setuptools,
  unittestCheckHook,
  wheel,
}:

buildPythonPackage rec {
  pname = "hsh";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "chrissimpkins";
    repo = "hsh";
    rev = "v${version}";
    hash = "sha256-bAAytoidFHH2dSXqN9aqBd2H4p/rwTWXIZa1t5Djdz0=";
  };

  nativeBuildInputs = [
    setuptools
    wheel
  ];

  propagatedBuildInputs = [ commandlines ];

  nativeCheckInputs = [
    unittestCheckHook
    pexpect
    naked
  ];

  preCheck = "cd tests";
  pyproject = true;
  pythonImportsCheck = [ "hsh" ];

  meta = {
    description = "Cross-platform command line application that generates file hash digests and performs file integrity checks via file hash digest comparisons";
    homepage = "https://github.com/chrissimpkins/hsh";
    license = lib.licenses.mit;
    maintainers = [ ];
    downloadPage = "https://github.com/chrissimpkins/hsh/releases";
  };
}
