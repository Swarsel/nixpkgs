{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
}:

buildGoModule (finalAttrs: {
  pname = "cliqr";
  version = "0.1.31";

  src = fetchFromGitHub {
    owner = "paepckehh";
    repo = "cliqr";
    tag = "v${finalAttrs.version}";
    hash = "sha256-AEUtPmLzNDsO39zRah1ln077w1S6ldsV8SsKStfQOlI=";
  };

  vendorHash = null;

  ldflags = [
    "-s"
    "-w"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Transfer, share data & secrets via console qr codes";
    homepage = "https://paepcke.de/cliqr";
    changelog = "https://github.com/paepckehh/cliqr/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ paepcke ];
    mainProgram = "cliqr";
  };
})
