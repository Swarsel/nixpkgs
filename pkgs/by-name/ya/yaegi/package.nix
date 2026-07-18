{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  testers,
  yaegi,
}:

buildGoModule (finalAttrs: {
  pname = "yaegi";
  version = "0.16.1";

  src = fetchFromGitHub {
    owner = "traefik";
    repo = "yaegi";
    rev = "v${finalAttrs.version}";
    hash = "sha256-jpLx2z65KeCPC4AQgFmUUphmmiT4EeHwrYn3/rD4Rzg=";
  };

  vendorHash = null;

  ldflags = [
    "-s"
    "-w"
    "-X=main.version=${finalAttrs.version}"
  ];

  subPackages = [
    "cmd/yaegi"
  ];

  passthru.tests = {
    version = testers.testVersion {
      command = "yaegi version";
      package = yaegi;
    };
  };

  meta = {
    description = "Go interpreter";
    homepage = "https://github.com/traefik/yaegi";
    changelog = "https://github.com/traefik/yaegi/releases/tag/${finalAttrs.src.rev}";
    license = lib.licenses.asl20;
    maintainers = [ ];
    mainProgram = "yaegi";
    # The last successful Darwin Hydra build was in 2023
    broken = stdenv.hostPlatform.isDarwin;
  };
})
