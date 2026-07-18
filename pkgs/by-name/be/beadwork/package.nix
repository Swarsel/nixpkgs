{
  lib,
  fetchFromGitHub,
  buildGoModule,
  gitMinimal,
  nix-update-script,
  versionCheckHook,
}:

buildGoModule (finalAttrs: {
  pname = "beadwork";
  version = "0.13.2";

  src = fetchFromGitHub {
    owner = "jallum";
    repo = "beadwork";
    rev = "v${finalAttrs.version}";
    hash = "sha256-OVwr/AUIx6k5QF2rZf25BWD+3UHYqN8tziJTa8tgDYU=";
  };

  vendorHash = "sha256-LjqZSI7F3C8GyNrPK/BwG9QTmNg89hFAvhUuBjmbHTU=";
  doCheck = true;

  nativeCheckInputs = [
    gitMinimal
    versionCheckHook
  ];

  preCheck = ''
    export HOME="$TMPDIR"
    git config --global user.email "test@test.com"
    git config --global user.name "Test"
    git config --global init.defaultBranch main
  '';

  doInstallCheck = true;
  __structuredAttrs = true;
  subPackages = [ "cmd/bw" ];
  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "Git-native work management for AI coding agents";
    homepage = "https://github.com/jallum/beadwork";
    license = licenses.mit;
    maintainers = with lib.maintainers; [ munksgaard ];
    mainProgram = "bw";
  };
})
