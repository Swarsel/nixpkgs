{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "storj-uplink";
  version = "1.142.7";

  src = fetchFromGitHub {
    owner = "storj";
    repo = "storj";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Y0pnketYzKC7xzndIceFk7dwyUwSjMzvvJF1EqSSD7s=";
  };

  vendorHash = "sha256-sdLobkctLiehei9J2vxc/IH3whGeqxq6T+AadrIuPRs=";
  # Tests fail with 'listen tcp 127.0.0.1:0: bind: operation not permitted'.
  __darwinAllowLocalNetworking = true;
  ldflags = [ "-s" ];
  subPackages = [ "cmd/uplink" ];

  meta = {
    description = "Command-line tool for Storj";
    homepage = "https://storj.io";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ felipeqq2 ];
    mainProgram = "uplink";
  };
})
