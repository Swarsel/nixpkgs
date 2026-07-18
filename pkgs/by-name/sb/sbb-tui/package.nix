{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
  versionCheckHook,
}:

buildGoModule (finalAttrs: {
  pname = "sbb-tui";
  version = "1.15.0";

  src = fetchFromGitHub {
    owner = "Necrom4";
    repo = "sbb-tui";
    tag = "v${finalAttrs.version}";
    hash = "sha256-bYIIMFUogowywYmXNWRobmo7etbHqwOV8eHmaxz1AUg=";
  };

  vendorHash = "sha256-K4DOu3rfSlKAa5JNKCzWWpnWZlXXxtN5Po7p1Spqe1w=";
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  __structuredAttrs = true;

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${finalAttrs.version}"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "TUI client for Switzerland's public transport timetables, inspired by SBB/CFF/FFS app";
    homepage = "https://github.com/Necrom4/sbb-tui";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ tomasrivera ];
    platforms = lib.platforms.unix;
    mainProgram = "sbb-tui";
  };
})
