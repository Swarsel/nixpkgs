{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "kpt";
  version = "1.0.0-beta.55";

  src = fetchFromGitHub {
    owner = "kptdev";
    repo = "kpt";
    rev = "v${finalAttrs.version}";
    hash = "sha256-MVrJUsMpt1L56ezy2b2G6Aac9kpe4QgfSosR+PeTuBQ=";
  };

  vendorHash = "sha256-2jJCvBtTiIYmpxA92p8eZnKl1UO74pKr1YFRH14keZY=";

  ldflags = [
    "-s"
    "-w"
    "-X github.com/kptdev/kpt/run.version=${finalAttrs.version}"
  ];

  subPackages = [ "." ];

  meta = {
    description = "Automate Kubernetes Configuration Editing";
    homepage = "https://github.com/kptdev/kpt";
    license = lib.licenses.asl20;
    maintainers = [ ];
    mainProgram = "kpt";
  };
})
