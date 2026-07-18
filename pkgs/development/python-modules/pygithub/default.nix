{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  deprecated,
  pyjwt,
  pynacl,
  requests,
  setuptools,
  setuptools-scm,
  typing-extensions,
  urllib3,
}:

buildPythonPackage rec {
  pname = "pygithub";
  version = "2.8.1";

  src = fetchFromGitHub {
    owner = "PyGithub";
    repo = "PyGithub";
    tag = "v${version}";
    hash = "sha256-36taxa95WrpQw0UUlmnWX4XFslAAuuoousxNh5O5uDA=";
  };

  # Test suite makes REST calls against github.com
  doCheck = false;

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    deprecated
    pyjwt
    pynacl
    requests
    typing-extensions
    urllib3
  ]
  ++ pyjwt.optional-dependencies.crypto;

  pyproject = true;
  pythonImportsCheck = [ "github" ];

  meta = {
    description = "Python library to access the GitHub API v3";
    homepage = "https://github.com/PyGithub/PyGithub";
    changelog = "https://github.com/PyGithub/PyGithub/raw/${src.tag}/doc/changes.rst";
    license = lib.licenses.lgpl3Plus;
    maintainers = [ ];
  };
}
