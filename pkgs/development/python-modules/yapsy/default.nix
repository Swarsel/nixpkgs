{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
  unstableGitUpdater,
}:

buildPythonPackage (finalAttrs: {
  pname = "yapsy";
  version = "1.12.2-unstable-2023-03-28";

  src = fetchFromGitHub {
    owner = "tibonihoo";
    repo = "yapsy";
    rev = "6b487b04affb19ab40adbbc87827668bea0abcee";
    hash = "sha256-QKZlUAhYMCCsT/jbEHb39ESZ2+2FZYnhJnc1PgsozBA=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "yapsy" ];
  sourceRoot = "${finalAttrs.src.name}/package";

  passthru.updateScript = unstableGitUpdater {
    tagPrefix = "release_Yapsy-";
  };

  meta = {
    description = "Yet another plugin system";
    homepage = "https://yapsy.sourceforge.net/";
    license = lib.licenses.bsd2;
  };
})
