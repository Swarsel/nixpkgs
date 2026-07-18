{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  setuptools,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "tls-client";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "FlorianREGAZ";
    repo = "Python-Tls-Client";
    tag = version;
    hash = "sha256-0eH9fA/oQzrgXcQilUdg4AaTqezj1Q9hP9olhZEDeBc=";
  };

  nativeBuildInputs = [ setuptools ];
  propagatedBuildInputs = [ typing-extensions ];
  # Module has no tests
  doCheck = false;
  pyproject = true;
  pythonImportsCheck = [ "tls_client" ];

  meta = {
    description = "Advanced HTTP Library";
    homepage = "https://github.com/FlorianREGAZ/Python-Tls-Client";
    changelog = "https://github.com/FlorianREGAZ/Python-Tls-Client/releases/tag/${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
