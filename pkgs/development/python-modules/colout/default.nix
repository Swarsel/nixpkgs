{
  lib,
  fetchFromGitHub,
  babel,
  buildPythonPackage,
  pygments,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "colout";
  version = "1.1";

  src = fetchFromGitHub {
    owner = "nojhan";
    repo = "colout";
    tag = "v${version}";
    hash = "sha256-7Dtf87erBElqVgqRx8BYHYOWv1uI84JJ0LHrcneczCI=";
  };

  nativeBuildInputs = [ setuptools-scm ];

  propagatedBuildInputs = [
    babel
    pygments
  ];

  # This project does not have a unit test
  doCheck = false;
  format = "setuptools";
  pythonImportsCheck = [ "colout" ];

  meta = {
    description = "Color Up Arbitrary Command Output";
    homepage = "https://github.com/nojhan/colout";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ badele ];
    mainProgram = "colout";
  };
}
