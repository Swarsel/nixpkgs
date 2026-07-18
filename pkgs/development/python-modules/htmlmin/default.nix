{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
  standard-cgi,
}:

buildPythonPackage rec {
  pname = "htmlmin";
  version = "0.1.12";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-UMHvRjA3Sl1yOQAJapYc/0Jt/0a0jzTRlKgbvhTsoXg=";
  };

  # pypi tarball does not contain tests
  doCheck = false;

  build-system = [
    setuptools
  ];

  dependencies = [
    standard-cgi
  ];

  pyproject = true;

  meta = {
    description = "Configurable HTML Minifier with safety features";
    homepage = "https://github.com/mankyd/htmlmin";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ nickcao ];
    mainProgram = "htmlmin";
  };
}
