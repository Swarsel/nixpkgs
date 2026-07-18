{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nixosTests,
}:

buildGoModule (finalAttrs: {
  pname = "cadvisor";
  version = "0.56.2";

  src = fetchFromGitHub {
    owner = "google";
    repo = "cadvisor";
    rev = "v${finalAttrs.version}";
    hash = "sha256-UBQvFlO0pb5mDUrrUTaEsuQcKX7qKQrAMub2knUZWGA=";
  };

  vendorHash = "sha256-JJulf+Wj/bf3l8l0rufcyLlfqefriOzhxCfGUru6+lA=";

  postInstall = ''
    mv $out/bin/{cmd,cadvisor}
    rm $out/bin/example
  '';

  ldflags = [
    "-s"
    "-w"
    "-X github.com/google/cadvisor/version.Version=${finalAttrs.version}"
  ];

  modRoot = "./cmd";
  passthru.tests = { inherit (nixosTests) cadvisor; };

  meta = {
    description = "Analyzes resource usage and performance characteristics of running docker containers";
    homepage = "https://github.com/google/cadvisor";
    license = lib.licenses.asl20;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "cadvisor";
  };
})
