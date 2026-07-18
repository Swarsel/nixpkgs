{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "pynobo";
  version = "1.9.0";

  src = fetchFromGitHub {
    owner = "echoromeo";
    repo = "pynobo";
    tag = "v${finalAttrs.version}";
    hash = "sha256-7saIhGkcRkT+HATpnL+DcIWarZue7UCp1lTyfgzLfl8=";
  };

  # Project has no tests
  doCheck = false;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "pynobo" ];

  meta = {
    description = "Python TCP/IP interface for Nobo Hub/Nobo Energy Control devices";
    homepage = "https://github.com/echoromeo/pynobo";
    changelog = "https://github.com/echoromeo/pynobo/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ fab ];
  };
})
