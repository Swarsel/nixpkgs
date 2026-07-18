{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "gosec";
  version = "2.28.0";

  src = fetchFromGitHub {
    owner = "securego";
    repo = "gosec";
    rev = "v${finalAttrs.version}";
    hash = "sha256-kj6G8aDTLgAXOzlZGgHPiDGjpczDSwYog5G7Cw0/VNE=";
  };

  vendorHash = "sha256-jd6nUvuWKygyKxyGCesQQj5OyYp+SD51ZDFXbyaJckc=";

  ldflags = [
    "-s"
    "-w"
    "-X main.Version=${finalAttrs.version}"
    "-X main.GitTag=${finalAttrs.src.rev}"
    "-X main.BuildDate=unknown"
  ];

  subPackages = [
    "cmd/gosec"
  ];

  meta = {
    description = "Golang security checker";
    homepage = "https://github.com/securego/gosec";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      kalbasit
      nilp0inter
    ];

    mainProgram = "gosec";
  };
})
