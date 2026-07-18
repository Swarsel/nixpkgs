{
  lib,
  fetchFromGitHub,
  attrs,
  buildPythonPackage,
  cryptography,
  hatch-fancy-pypi-readme,
  hatch-vcs,
  hatchling,
  idna,
  pyasn1,
  pyasn1-modules,
  pyopenssl,
  pytestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "service-identity";
  version = "24.2.0";

  src = fetchFromGitHub {
    owner = "pyca";
    repo = "service-identity";
    tag = finalAttrs.version;
    hash = "sha256-onxCUWqGVeenLqB5lpUpj3jjxTM61ogXCQOGnDnClT4=";
  };

  nativeBuildInputs = [
    hatch-fancy-pypi-readme
    hatch-vcs
    hatchling
  ];

  propagatedBuildInputs = [
    attrs
    cryptography
    idna
    pyasn1
    pyasn1-modules
  ];

  nativeCheckInputs = [ pytestCheckHook ];
  checkInputs = [ pyopenssl ];
  pyproject = true;
  pythonImportsCheck = [ "service_identity" ];

  meta = {
    description = "Service identity verification for pyOpenSSL";
    homepage = "https://service-identity.readthedocs.io";
    changelog = "https://github.com/pyca/service-identity/releases/tag/${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
