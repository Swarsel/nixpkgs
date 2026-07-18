{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
}:

buildGoModule (finalAttrs: {
  pname = "zk";
  version = "0.15.5";

  src = fetchFromGitHub {
    owner = "zk-org";
    repo = "zk";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-QV6+ZMQxdFQMqgyELu6AEZqVhk+MGWu9V6YnCabRjbc=";
  };

  vendorHash = "sha256-Kq427Dfiys19GoUnalOxUxFhcQikwg7dd6diLH2kjEo=";
  env.CGO_ENABLED = 1;
  doCheck = false;

  ldflags = [
    "-s"
    "-w"
    "-X=main.Build=${finalAttrs.version}"
    "-X=main.Version=${finalAttrs.version}"
  ];

  tags = [ "fts5" ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Zettelkasten plain text note-taking assistant";
    homepage = "https://github.com/zk-org/zk";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ pinpox ];
    mainProgram = "zk";
  };
})
