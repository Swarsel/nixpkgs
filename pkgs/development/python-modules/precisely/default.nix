{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  gitUpdater,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "precisely";
  version = "0.1.9";

  src = fetchFromGitHub {
    owner = "mwilliamson";
    repo = "python-precisely";
    tag = version;
    hash = "sha256-jvvRreSGpRgDk1bbqC8Z/UEfvxwKilfc/sm7nxdJU6k=";
  };

  # Tests are outdated and based on Nose, which is not supported anymore.
  doCheck = false;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "precisely" ];
  passthru.updateScript = gitUpdater { };

  meta = {
    description = "Matcher library for Python";
    homepage = "https://github.com/mwilliamson/python-precisely";
    license = lib.licenses.bsd2;
    maintainers = [ ];
  };
}
