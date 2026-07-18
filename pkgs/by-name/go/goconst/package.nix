{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "goconst";
  version = "1.10.2";

  src = fetchFromGitHub {
    owner = "jgautheron";
    repo = "goconst";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-2u05GYOMHt9CtRRh68mV8heql0aCYQv2NORBF3vZkag=";
  };

  vendorHash = null;
  excludedPackages = [ "tests" ];

  ldflags = [
    "-s"
    "-w"
  ];

  meta = {
    description = "Find in Go repeated strings that could be replaced by a constant";
    homepage = "https://github.com/jgautheron/goconst";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ kalbasit ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "goconst";
  };
})
