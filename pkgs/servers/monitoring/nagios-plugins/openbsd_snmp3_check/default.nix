{
  lib,
  fetchFromGitHub,
  nix-update-script,
  openbsd_snmp3_check,
  python3Packages,
  testers,
}:
python3Packages.buildPythonApplication rec {
  pname = "openbsd_snmp3_check";
  version = "0.55";

  src = fetchFromGitHub {
    owner = "alexander-naumov";
    repo = "openbsd_snmp3_check";
    rev = "v${version}";
    hash = "sha256-qDYANMvQU72f9wz8os7S1PfBH08AAqhtWLHVuSmkub4=";
  };

  postInstall = ''
    install -Dm755 openbsd_snmp3.py $out/bin/openbsd_snmp3.py
  '';

  pyproject = false;

  passthru = {
    tests.version = testers.testVersion {
      package = openbsd_snmp3_check;
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "SNMP v3 check for OpenBSD systems state monitoring";
    homepage = "https://github.com/alexander-naumov/openbsd_snmp3_check";
    changelog = "https://github.com/alexander-naumov/openbsd_snmp3_check/releases/tag/v${version}";
    license = with lib.licenses; [ bsd3 ];
    maintainers = with lib.maintainers; [ jwillikers ];
    platforms = lib.platforms.unix;
    mainProgram = "openbsd_snmp3.py";
  };
}
