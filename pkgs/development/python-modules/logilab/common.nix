{
  lib,
  fetchFromGitLab,
  buildPythonPackage,
  mypy-extensions,
  pytestCheckHook,
  pytz,
  setuptools,
  typing-extensions,
}:

buildPythonPackage (finalAttrs: {
  pname = "logilab-common";
  version = "2.1.0";

  src = fetchFromGitLab {
    owner = "open-source";
    repo = "logilab-common";
    tag = finalAttrs.version;
    hash = "sha256-cKodCj9m3n4P54CZ2X+BXN62ewd9nHSZBMENlo8S1iY=";
    domain = "forge.extranet.logilab.fr";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytz
  ];

  preCheck = ''
    export COLLECT_DEPRECATION_WARNINGS_PACKAGE_NAME=true
  '';

  build-system = [ setuptools ];

  dependencies = [
    setuptools
    mypy-extensions
    typing-extensions
  ];

  pyproject = true;

  meta = {
    description = "Python packages and modules used by Logilab";
    homepage = "https://logilab-common.readthedocs.io/";
    changelog = "https://forge.extranet.logilab.fr/open-source/logilab-common/-/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.lgpl21Plus;
    maintainers = [ ];
    mainProgram = "logilab-pytest";
  };
})
