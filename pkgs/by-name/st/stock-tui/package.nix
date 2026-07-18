{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
}:

buildGoModule (finalAttrs: {
  pname = "stock-tui";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "ni5arga";
    repo = "stock-tui";
    tag = "v${finalAttrs.version}";
    hash = "sha256-5k24fBG0ZBr2JhVf30IGjLky087j203hZGEvtSzwUqQ=";
  };

  vendorHash = "sha256-Use54AVRMZ9xYx8tQpcRN3th+MufuER3lCJ+JVPpYRU=";
  subPackages = [ "cmd/stock-tui" ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Terminal-based stock and cryptocurrency price tracker";
    homepage = "https://github.com/ni5arga/stock-tui";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ni5arga ];
    mainProgram = "stock-tui";
  };
})
