{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
  testers,
  treegen,
}:

buildGoModule (finalAttrs: {
  pname = "treegen";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "bilbilak";
    repo = "treegen";
    tag = "v${finalAttrs.version}";
    hash = "sha256-PPWUEfX7OXKZnghiVXU+eCjveA1VszA3uS8C3uI3pFM=";
  };

  vendorHash = "sha256-hocnLCzWN8srQcO3BMNkd2lt0m54Qe7sqAhUxVZlz1k=";

  ldflags = [
    "-s"
    "-w"
    "-X github.com/bilbilak/treegen/config.Version=${finalAttrs.version}"
  ];

  passthru = {
    tests = {
      version = testers.testVersion {
        command = "treegen --version";
        package = treegen;
      };
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "ASCII Tree Directory and File Structure Generator";
    homepage = "https://github.com/bilbilak/treegen";
    changelog = "https://github.com/bilbilak/treegen/blob/main/CHANGELOG.md";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ _4r7if3x ];
    platforms = with lib.platforms; unix ++ windows;
    mainProgram = "treegen";
  };
})
