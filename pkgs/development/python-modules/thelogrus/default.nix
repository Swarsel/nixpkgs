{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  dateutils,
  poetry-core,
  pyaml,
}:

buildPythonPackage rec {
  pname = "thelogrus";
  version = "0.7.0";

  src = fetchFromGitHub {
    owner = "unixorn";
    repo = "thelogrus";
    tag = "v${version}";
    hash = "sha256-96/EjDh5XcTsfUcTnsltsT6LMYbyKuM/eNyeq2Pukfo=";
  };

  nativeBuildInputs = [
    poetry-core
  ];

  propagatedBuildInputs = [
    dateutils
    pyaml
  ];

  # Module has no unit tests
  doCheck = false;
  pyproject = true;
  pythonImportsCheck = [ "thelogrus" ];
  pythonRelaxDeps = [ "pyaml" ];

  meta = {
    description = "Python 3 version of logrus";
    homepage = "https://github.com/unixorn/thelogrus";
    changelog = "https://github.com/unixorn/thelogrus/blob/${version}/ChangeLog.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "human-time";
  };
}
