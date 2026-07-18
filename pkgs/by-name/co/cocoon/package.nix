{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
  nixosTests,
  stdenvNoCC,
}:
buildGoModule (finalAttrs: {
  pname = "cocoon";
  version = "0.10";

  src = fetchFromGitHub {
    owner = "haileyok";
    repo = "cocoon";
    tag = "v${finalAttrs.version}";
    hash = "sha256-SvLXtn4Nr8zcvvjGarNLYeKqyniI6eg50cnqV6Q+3/s=";
  };

  vendorHash = "sha256-Vkf5XyJA/Vdufa1OpCzgIGSQa5pVsFCTfaAVI7l947E=";

  ldflags = [
    "-s"
    "-w"
    "-X main.Version=${finalAttrs.version}"
  ];

  passthru = {
    tests = lib.optionalAttrs stdenvNoCC.hostPlatform.isLinux { inherit (nixosTests) cocoon; };
    updateScript = nix-update-script { };
  };

  meta = {
    description = "ATProtocol Personal Data Server written in Go with a SQLite block and blob store";
    homepage = "https://github.com/haileyok/cocoon";
    changelog = "https://github.com/haileyok/cocoon/releases/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ isabelroses ];
    mainProgram = "cocoon";
  };
})
