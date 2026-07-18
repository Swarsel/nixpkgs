{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  robotframework,
  robotframework-assertion-engine,
  setuptools,
  sqlparse,
}:

buildPythonPackage rec {
  pname = "robotframework-databaselibrary";
  version = "2.4.1";

  src = fetchFromGitHub {
    owner = "MarketSquare";
    repo = "Robotframework-Database-Library";
    tag = "v${version}";
    hash = "sha256-RGTx5Xn40MHr5M6DUb3dkR2OU7B0JKuFYP1o18o3Ct4=";
  };

  propagatedBuildInputs = [
    robotframework
    robotframework-assertion-engine
    sqlparse
  ];

  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    setuptools
  ];

  pyproject = true;
  pythonImportsCheck = [ "DatabaseLibrary" ];

  meta = {
    description = "Database Library contains utilities meant for Robot Framework";
    homepage = "https://github.com/MarketSquare/Robotframework-Database-Library";
    changelog = "https://github.com/MarketSquare/Robotframework-Database-Library/releases/tag/${src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ talkara ];
  };
}
