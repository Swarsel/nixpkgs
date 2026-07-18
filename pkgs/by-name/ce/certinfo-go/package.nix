{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
}:

buildGoModule (finalAttrs: {
  pname = "certinfo-go";
  version = "0.1.55";

  src = fetchFromGitHub {
    owner = "paepckehh";
    repo = "certinfo";
    tag = "v${finalAttrs.version}";
    hash = "sha256-L7gX6GaNI2tqLf7diCBOXDWtP2bQJYI//ZKQ/76J+ZA=";
  };

  vendorHash = "sha256-SuQGgPT9ItoJPca6f8hsARwlpPwwb2avszZFBBp6LBA=";

  ldflags = [
    "-s"
    "-w"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Tool to analyze and troubleshoot x.509 & ssh certificates, encoded keys";
    homepage = "https://paepcke.de/certinfo";
    changelog = "https://github.com/paepckehh/certinfo/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ paepcke ];
    mainProgram = "certinfo";
  };
})
