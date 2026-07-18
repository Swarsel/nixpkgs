{
  lib,
  fetchPypi,
  python3Packages,
}:

python3Packages.buildPythonApplication rec {
  pname = "enochecker-test";
  version = "0.9.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-M0RTstFePU7O51YVEncVDuuR6F7R8mfdKbO0j7k/o8Q=";
    pname = "enochecker_test";
  };

  nativeBuildInputs = [
  ];

  propagatedBuildInputs = with python3Packages; [
    certifi
    charset-normalizer
    enochecker-core
    exceptiongroup
    idna
    iniconfig
    jsons
    packaging
    pluggy
    pytest
    requests
    tomli
    typish
    urllib3
  ];

  # tests require network access
  doCheck = false;
  format = "setuptools";
  pythonRelaxDeps = true;

  meta = {
    description = "Automatically test services/checker using the enochecker API";
    homepage = "https://github.com/enowars/enochecker_test";
    changelog = "https://github.com/enowars/enochecker_test/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fwc ];
    mainProgram = "enochecker_test";
  };
}
