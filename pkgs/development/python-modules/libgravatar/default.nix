{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "libgravatar";
  version = "1.0.4";

  src = fetchFromGitHub {
    owner = "pabluk";
    repo = "libgravatar";
    tag = version;
    hash = "sha256-rJv/jfdT+JldxR0kKtXQLOI5wXQYSQRWJnqwExwWjTA=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "libgravatar" ];

  meta = {
    description = "Library that provides a Python 3 interface for the Gravatar API";
    homepage = "https://github.com/pabluk/libgravatar";
    changelog = "https://github.com/pabluk/libgravatar/releases/tag/${version}";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ gador ];
  };
}
