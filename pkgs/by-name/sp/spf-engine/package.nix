{
  lib,
  fetchurl,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "spf-engine";
  version = "3.1.0";

  src = fetchurl {
    url = "https://launchpad.net/spf-engine/${lib.versions.majorMinor finalAttrs.version}/${finalAttrs.version}/+download/spf-engine-${finalAttrs.version}.tar.gz";
    hash = "sha256-HUuMxYFCqItLFgMSnrkwfmJWqgFGyI1RWgmljb+jkWk=";
  };

  nativeBuildInputs = [
    python3Packages.flit-core
  ];

  dependencies = with python3Packages; [
    pyspf
    dnspython
    authres
    pymilter
  ];

  pyproject = true;

  pythonImportsCheck = [
    "spf_engine"
    "spf_engine.milter_spf"
    "spf_engine.policyd_spf"
  ];

  meta = {
    description = "Postfix policy engine for Sender Policy Framework (SPF) checking";
    homepage = "https://launchpad.net/spf-engine/";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
})
