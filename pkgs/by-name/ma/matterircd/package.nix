{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "matterircd";
  version = "0.30.0";

  src = fetchFromGitHub {
    owner = "42wim";
    repo = "matterircd";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-W00q5bRzCXl9R56xGol1bWYeW5w5MUpcoraKVaKimyk=";
  };

  vendorHash = null;

  ldflags = [
    "-s"
    "-w"
  ];

  meta = {
    description = "Minimal IRC server bridge to Mattermost";
    homepage = "https://github.com/42wim/matterircd";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ numinit ];
    mainProgram = "matterircd";
  };
})
