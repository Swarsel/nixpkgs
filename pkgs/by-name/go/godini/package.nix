{
  lib,
  fetchFromGitHub,
  buildGoModule,
  godini,
  nix-update-script,
  testers,
}:

buildGoModule (finalAttrs: {
  pname = "godini";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "bilbilak";
    repo = "godini";
    tag = "v${finalAttrs.version}";
    hash = "sha256-83OAddIoJzAUXPZKGnAx8XPKrdSmtc1EIJUDmRHTU/U=";
  };

  vendorHash = "sha256-hocnLCzWN8srQcO3BMNkd2lt0m54Qe7sqAhUxVZlz1k=";

  ldflags = [
    "-s"
    "-w"
    "-X github.com/bilbilak/godini/config.Version=${finalAttrs.version}"
  ];

  passthru = {
    tests = {
      version = testers.testVersion {
        command = "godini --version";
        package = godini;
      };
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "INI Configuration Management Tool";
    homepage = "https://github.com/bilbilak/godini";
    changelog = "https://github.com/bilbilak/godini/blob/main/CHANGELOG.md";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ _4r7if3x ];
    platforms = with lib.platforms; unix ++ windows;
    mainProgram = "godini";
  };
})
