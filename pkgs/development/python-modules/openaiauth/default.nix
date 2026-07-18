{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
  tls-client,
}:

buildPythonPackage rec {
  pname = "openaiauth";
  version = "3.0.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-9SrptiheiM5s9YI6Ht68ahDGMFADWfBQgAWUBY3EEJ8=";
    pname = "OpenAIAuth";
  };

  nativeBuildInputs = [ setuptools ];
  propagatedBuildInputs = [ tls-client ];
  # Module has no tests
  doCheck = false;
  pyproject = true;
  pythonImportsCheck = [ "OpenAIAuth" ];

  meta = {
    description = "Library for authenticating with the OpenAI API";
    homepage = "https://github.com/acheong08/OpenAIAuth";
    changelog = "https://github.com/acheong08/OpenAIAuth/releases/tag/${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ logger ];
  };
}
