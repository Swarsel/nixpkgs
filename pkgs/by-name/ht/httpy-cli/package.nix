{
  lib,
  curl,
  fetchPypi,
  python3Packages,
}:

python3Packages.buildPythonPackage rec {
  pname = "httpy-cli";
  version = "1.1.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-uhF/jF4buHMDiXOuuqjskynioz4qVBevQhdcUbH+91Q=";
    pname = "httpy-cli";
  };

  propagatedBuildInputs = with python3Packages; [
    colorama
    pygments
    requests
    urllib3
  ];

  nativeCheckInputs = [
    python3Packages.pytest
    curl
  ];

  checkPhase = ''
    runHook preCheck
    echo "line1\nline2\nline3" > tests/test_file.txt
    # ignore the test_args according to pytest.ini in the repo
    pytest tests/ --ignore=tests/test_args.py
    runHook postCheck
  '';

  build-system = with python3Packages; [
    setuptools
  ];

  pyproject = true;

  pythonImportsCheck = [
    "httpy"
  ];

  meta = {
    description = "Modern, user-friendly, programmable command-line HTTP client for the API";
    homepage = "https://github.com/knid/httpy";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ eymeric ];
    mainProgram = "httpy";
  };
}
