{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
  olm,
  versionCheckHook,
  # This option enables the use of an experimental pure-Go implementation of
  # the Olm protocol instead of libolm for end-to-end encryption. Using goolm
  # is not recommended by the mautrix developers, but they are interested in
  # people trying it out in non-production-critical environments and reporting
  # any issues they run into.
  withGoolm ? false,
}:
buildGoModule rec {
  pname = "mautrix-slack";
  version = "26.06";

  src = fetchFromGitHub {
    inherit tag;
    owner = "mautrix";
    repo = "slack";
    hash = "sha256-Ug4Na9qt140hVKkDQHqUCu4uijJzjJka52noZob/mkc=";
  };

  buildInputs = lib.optional (!withGoolm) olm;
  vendorHash = "sha256-a/3JHm3kR5edozVB17fCTwbm2awBhUvJn0wUSvLq/GY=";
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  ldflags = [
    "-s"
    "-w"
    "-X"
    "main.Tag=${tag}"
  ];

  tag = "v0.2606.0";
  tags = lib.optional withGoolm "goolm";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Matrix-Slack puppeting bridge";
    homepage = "https://github.com/mautrix/slack";
    changelog = "https://github.com/mautrix/slack/blob/v${version}/CHANGELOG.md";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ BonusPlay ];
    mainProgram = "mautrix-slack";
  };
}
