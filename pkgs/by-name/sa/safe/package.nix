{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "safe";
  version = "1.8.0";

  src = fetchFromGitHub {
    owner = "starkandwayne";
    repo = "safe";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-sg0RyZ5HpYu7M11bNy17Sjxm7C3pkQX3I17edbALuvU=";
  };

  vendorHash = "sha256-w8gHCqOfmZg4JZgg1nZBtTJ553Rbp0a0JsoQVDFjehM=";

  ldflags = [
    "-X main.Version=${finalAttrs.version}"
  ];

  subPackages = [ "." ];

  meta = {
    description = "Vault CLI";
    homepage = "https://github.com/starkandwayne/safe";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ eonpatapon ];
    mainProgram = "safe";
  };
})
