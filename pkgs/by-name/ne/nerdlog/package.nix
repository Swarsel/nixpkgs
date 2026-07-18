{
  lib,
  fetchFromGitHub,
  buildGoModule,
  libx11,
  nix-update-script,
  versionCheckHook,
}:
buildGoModule (finalAttrs: {
  pname = "nerdlog";
  version = "1.10.0";

  src = fetchFromGitHub {
    owner = "dimonomid";
    repo = "nerdlog";
    tag = "v${finalAttrs.version}";
    hash = "sha256-XlzWNeyd+Ar4ArFcN1wkQ0aod6ckAiIb12odK7cf4+s=";
  };

  nativeBuildInputs = [ versionCheckHook ];
  buildInputs = [ libx11 ];
  vendorHash = "sha256-hvv0dsE1yz85VLaBOE7RWbux8L8kVTihcA1HyyHRYAM=";

  # e2e tests require SSH connections to test hosts
  checkFlags = [
    "-skip"
    "^TestE2E"
  ];

  doInstallCheck = true;
  __structuredAttrs = true;

  ldflags = [
    "-X github.com/dimonomid/nerdlog/version.version=${finalAttrs.version}"
    "-X github.com/dimonomid/nerdlog/version.builtBy=nix"
  ];

  subPackages = [ "cmd/nerdlog" ];
  # `nerdlog --version` will fail if $HOME is not defined
  versionCheckKeepEnvironment = [ "HOME" ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Fast, remote-first, multi-host TUI log viewer with timeline histogram";

    longDescription = ''
      Nerdlog is a fast, remote-first, multi-host TUI log viewer with timeline histogram
      and no central server. Loosely inspired by Graylog/Kibana, but without the bloat.
      Pretty much no setup needed, either.
    '';

    homepage = "https://github.com/dimonomid/nerdlog";
    changelog = "https://github.com/dimonomid/nerdlog/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ tophcodes ];
    mainProgram = "nerdlog";
  };
})
