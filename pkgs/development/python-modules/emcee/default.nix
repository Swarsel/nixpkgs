{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  numpy,
  pytestCheckHook,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "emcee";
  version = "3.1.6";

  src = fetchFromGitHub {
    owner = "dfm";
    repo = "emcee";
    tag = "v${version}";
    hash = "sha256-JVZK3kvDwWENho0OxZ9OxATcm3XpGmX+e7alPclRsHY=";
  };

  nativeBuildInputs = [ setuptools-scm ];
  propagatedBuildInputs = [ numpy ];
  nativeCheckInputs = [ pytestCheckHook ];
  format = "setuptools";
  pythonImportsCheck = [ "emcee" ];

  meta = {
    description = "Kick ass affine-invariant ensemble MCMC sampling";
    homepage = "https://emcee.readthedocs.io/";
    changelog = "https://github.com/dfm/emcee/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
