{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "backports-shutil-which";
  version = "3.5.2";

  src = fetchFromGitHub {
    owner = "minrk";
    repo = "backports.shutil_which";
    tag = finalAttrs.version;
    hash = "sha256-smvBySS8Ek24y8X9DUGxF4AfJL2ZQ12xeDhEBsZRiP0=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [ setuptools ];
  pyproject = true;

  meta = {
    description = "Backport of shutil.which from Python 3.3";
    homepage = "https://github.com/minrk/backports.shutil_which";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
})
