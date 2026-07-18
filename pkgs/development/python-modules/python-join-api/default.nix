{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  flask,
  requests,
  setuptools,
  yarl,
}:

buildPythonPackage (finalAttrs: {
  pname = "python-join-api";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "nkgilley";
    repo = "python-join-api";
    tag = finalAttrs.version;
    hash = "sha256-sT/IS7UshXSVaonegvcn4u2a8CNCRiiovcQ8uAyfU1Q=";
  };

  # No tests
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    flask
    requests
    yarl
  ];

  pyproject = true;
  pythonImportsCheck = [ "pyjoin" ];

  meta = {
    description = "Python API for interacting with Join by joaoapps";
    homepage = "https://github.com/nkgilley/python-join-api";
    changelog = "https://github.com/nkgilley/python-join-api/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.jamiemagee ];
  };
})
