{
  lib,
  fetchFromGitHub,
  buildGoModule,
  makeWrapper,
  nix-update-script,
  nixosTests,
}:
buildGoModule (finalAttrs: {
  pname = "ddns-updater";
  version = "2.10.0";

  src = fetchFromGitHub {
    owner = "qdm12";
    repo = "ddns-updater";
    rev = "v${finalAttrs.version}";
    hash = "sha256-E/ToeY5O6GaMl0ItLbNNF5Uur0Gx87FdT0T4kekae88=";
  };

  nativeBuildInputs = [ makeWrapper ];
  vendorHash = "sha256-osrRxiifxYgcxShso6HnxBCDQPMUiwfbt6fVipjkmdE=";

  postInstall = ''
    wrapProgram $out/bin/ddns-updater \
      --set GODEBUG "netdns=go"
  '';

  ldflags = [
    "-s"
    "-w"
  ];

  subPackages = [ "cmd/ddns-updater" ];

  passthru = {
    tests = {
      inherit (nixosTests) ddns-updater;
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "Container to update DNS records periodically with WebUI for many DNS providers";
    homepage = "https://github.com/qdm12/ddns-updater";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ delliott ];
    mainProgram = "ddns-updater";
  };
})
