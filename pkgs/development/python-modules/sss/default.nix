{
  lib,
  buildPythonPackage,
  # tests
  pytestCheckHook,
  python,
  sssd,
}:

let
  sssdForPython = sssd.override {
    python3 = python;
  };
in
buildPythonPackage {
  inherit (sssdForPython) version;
  pname = "sss";
  # No tests
  doCheck = false;

  nativeCheckInputs = [
    pytestCheckHook
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/${python.sitePackages}

    cp -r ${sssdForPython}/${python.sitePackages}/SSSDConfig $out/${python.sitePackages}/
    install -m 755 ${sssdForPython}/${python.sitePackages}/*.so $out/${python.sitePackages}/

    runHook postInstall
  '';

  dependencies = [
    sssdForPython
  ];

  dontBuild = true;
  dontUnpack = true;
  pyproject = false;

  pythonImportsCheck = [
    "sssd"
    "pysss"
    "pysss_murmur"
    "pysss_nss_idmap"
    "pyhbac"
    "SSSDConfig"
  ];

  meta = {
    inherit (sssd.meta)
      homepage
      changelog
      platforms
      maintainers
      ;

    description = "Python bindings for SSSD (System Security Services Daemon)";

    longDescription = ''
      This package provides Python bindings for SSSD including:
      - sssd: SSSD Python utilities module
      - pysss: Core Python module for SSSD operations
      - pysss_murmur: MurmurHash implementation
      - pysss_nss_idmap: NSS ID mapping functionality
      - pyhbac: HBAC (Host-Based Access Control) module
      - SSSDConfig: Configuration management module
    '';
  };
}
