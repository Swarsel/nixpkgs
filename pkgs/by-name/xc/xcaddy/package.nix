{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "xcaddy";
  version = "0.4.6";

  src = fetchFromGitHub {
    owner = "caddyserver";
    repo = "xcaddy";
    rev = "v${finalAttrs.version}";
    hash = "sha256-SXCOKrGaTwcdrVhPenQGjdBaDl8/bUGmm1B3spk8eUA=";
  };

  patches = [
    ./inject_version_info.diff
    ./use_tmpdir_on_darwin.diff
  ];

  vendorHash = "sha256-K5+Gj4Lqla6q9vx95BtCS67mZMWkMjgIHVYpBUdx/Wc=";

  ldflags = [
    "-s"
    "-w"
    "-X github.com/caddyserver/xcaddy/cmd.customVersion=v${finalAttrs.version}"
  ];

  subPackages = [ "cmd/xcaddy" ];

  meta = {
    description = "Build Caddy with plugins";
    homepage = "https://github.com/caddyserver/xcaddy";
    license = lib.licenses.asl20;
    mainProgram = "xcaddy";
  };
})
