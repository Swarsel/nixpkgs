{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
  versionCheckHook,
}:
buildGoModule (finalAttrs: {
  pname = "crowdsec-firewall-bouncer";
  version = "0.0.34";

  src = fetchFromGitHub {
    owner = "crowdsecurity";
    repo = "cs-firewall-bouncer";
    tag = "v${finalAttrs.version}";
    hash = "sha256-lDO9pwPkbI+FDTdXBv03c0p8wbkRUiIDNl1ip3AZo2g=";
  };

  vendorHash = "sha256-SbpclloBgd9vffC0lBduGRqPOqmzQ0J91/KeDHCh0jo=";
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  ldflags = [
    "-X github.com/crowdsecurity/go-cs-lib/version.Version=v${finalAttrs.version}"
  ];

  versionCheckProgram = "${placeholder "out"}/bin/cs-firewall-bouncer";
  versionCheckProgramArg = "-version";

  passthru = {
    updateScript = nix-update-script {
      extraArgs = [ "--version-regex=^v(\\d+\\.\\d+\\.\\d+)$" ];
    };
  };

  meta = {
    description = "Crowdsec bouncer written in golang for firewalls";

    longDescription = ''
      CrowdSec Remediation Component written in golang for firewalls.

      crowdsec-firewall-bouncer will fetch new and old decisions from a
      CrowdSec API and add them to a blocklist used by supported firewalls.
    '';

    homepage = "https://crowdsec.net/";
    changelog = "https://github.com/crowdsecurity/cs-firewall-bouncer/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      tornax
      jk
    ];

    mainProgram = "cs-firewall-bouncer";
    downloadPage = "https://github.com/crowdsecurity/cs-firewall-bouncer";
  };
})
