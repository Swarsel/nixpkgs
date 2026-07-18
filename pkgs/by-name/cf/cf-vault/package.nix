{
  lib,
  fetchFromGitHub,
  buildGoModule,
  cf-vault,
  testers,
}:
buildGoModule (finalAttrs: {
  pname = "cf-vault";
  version = "0.0.18";

  src = fetchFromGitHub {
    owner = "jacobbednarz";
    repo = "cf-vault";
    rev = finalAttrs.version;
    sha256 = "sha256-vp9ufjNZabY/ck2lIT+QpD6IgaVj1BkBRTjPxkb6IjQ=";
  };

  vendorHash = "sha256-7qFB1Y1AnqMgdu186tAXCdoYOhCMz8pIh6sY02LbIgs=";

  ldflags = [
    "-s"
    "-w"
    "-X github.com/jacobbednarz/cf-vault/cmd.Rev=${finalAttrs.version}"
  ];

  passthru.tests.version = testers.testVersion {
    command = "cf-vault version";
    package = cf-vault;
  };

  meta = {
    description = "Tool for managing your Cloudflare credentials, securely";
    homepage = "https://github.com/jacobbednarz/cf-vault/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ viraptor ];
    mainProgram = "cf-vault";
  };
})
