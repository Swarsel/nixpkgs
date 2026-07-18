{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
  nixosTests,
  versionCheckHook,
}:

buildGoModule (finalAttrs: {
  pname = "yarr";
  version = "2.6";

  src = fetchFromGitHub {
    owner = "nkanaev";
    repo = "yarr";
    rev = "v${finalAttrs.version}";
    hash = "sha256-D/049qH6CFNL7MY5e54guA9i84pbAwGf2UPHnVQWCkU=";
  };

  vendorHash = null;
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  ldflags = [
    "-s"
    "-w"
    "-X main.Version=${finalAttrs.version}"
    "-X main.GitHash=none"
  ];

  tags = [
    "sqlite_foreign_keys"
    "sqlite_json"
  ];

  passthru = {
    tests = lib.optionalAttrs stdenv.hostPlatform.isLinux nixosTests.yarr;
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Yet another rss reader";
    homepage = "https://github.com/nkanaev/yarr";
    changelog = "https://github.com/nkanaev/yarr/blob/v${finalAttrs.version}/doc/changelog.md";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      sikmir
      christoph-heiss
    ];

    mainProgram = "yarr";
  };
})
