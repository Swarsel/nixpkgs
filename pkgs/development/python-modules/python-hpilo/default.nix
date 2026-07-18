{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  setuptools,
}:

buildPythonPackage rec {
  pname = "python-hpilo";
  version = "4.4.3";

  src = fetchFromGitHub {
    owner = "seveas";
    repo = "python-hpilo";
    tag = version;
    hash = "sha256-O0WGJRxzT9R9abFOsXHSiv0aFOtBWQqTrfbw5rnuZbY=";
  };

  # Most tests requires an actual iLO to run
  doCheck = false;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "hpilo" ];

  meta = {
    description = "Python module to access the HP iLO XML interface";
    homepage = "https://seveas.github.io/python-hpilo/";
    changelog = "https://github.com/seveas/python-hpilo/blob/${version}/CHANGES";

    license = with lib.licenses; [
      asl20
      gpl3Plus
    ];

    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "hpilo_cli";
  };
}
