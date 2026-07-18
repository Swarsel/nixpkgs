{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "comigo";
  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "yumenaka";
    repo = "comigo";
    tag = "v${finalAttrs.version}";
    hash = "sha256-6EnKIpcGFMNY3NRy/QBVgsSXGwBgxsjr1TgOD0cEW7k=";
  };

  vendorHash = "sha256-ehK1fqHrSy6J6DThBR7s+LA+nP5DHDkwSRsR/NIg4g8=";
  __structuredAttrs = true;

  ldflags = [
    "-s"
    "-w"
  ];

  subPackages = [ "." ];

  meta = {
    description = "Simple and Efficient Comic Reader";
    homepage = "https://github.com/yumenaka/comigo";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ zendo ];
    mainProgram = "comigo";
  };
})
