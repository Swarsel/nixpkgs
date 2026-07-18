{
  lib,
  fetchFromGitHub,
  bootstrapped-pip,
  buildPythonPackage,
  pretend,
  scripttest,
  virtualenv,
}:

buildPythonPackage rec {
  pname = "pip";
  version = "20.3.4";

  src = fetchFromGitHub {
    owner = "pypa";
    repo = pname;
    rev = version;
    sha256 = "0hkhs9yc1cjdj1gn9wkycd3sy65c05q8k8rhqgsm5jbpksfssiwn";
    name = "${pname}-${version}-source";
  };

  nativeBuildInputs = [ bootstrapped-pip ];
  # Pip wants pytest, but tests are not distributed
  doCheck = false;

  nativeCheckInputs = [
    scripttest
    virtualenv
    pretend
  ];

  format = "other";
  # pip detects that we already have bootstrapped_pip "installed", so we need
  # to force it a little.
  pipInstallFlags = [ "--ignore-installed" ];

  meta = {
    description = "PyPA recommended tool for installing Python packages";
    homepage = "https://pip.pypa.io/";
    license = with lib.licenses; [ mit ];

    knownVulnerabilities = [
      "CVE-2021-28363"
    ];

    priority = 10;
  };
}
