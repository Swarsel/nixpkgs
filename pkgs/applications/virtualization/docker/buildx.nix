{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule rec {
  pname = "docker-buildx";
  version = "0.35.0";

  src = fetchFromGitHub {
    owner = "docker";
    repo = "buildx";
    rev = "v${version}";
    hash = "sha256-Q4f7tejn0LO4eiEq+ske53WJ1oe5JxtCVZA2Im+7dv8=";
  };

  vendorHash = null;
  doCheck = false;

  installPhase = ''
    runHook preInstall
    install -D $GOPATH/bin/buildx $out/libexec/docker/cli-plugins/docker-buildx

    mkdir -p $out/bin
    ln -s $out/libexec/docker/cli-plugins/docker-buildx $out/bin/docker-buildx
    runHook postInstall
  '';

  ldflags = [
    "-w"
    "-s"
    "-X github.com/docker/buildx/version.Package=github.com/docker/buildx"
    "-X github.com/docker/buildx/version.Version=v${version}"
  ];

  meta = {
    description = "Docker CLI plugin for extended build capabilities with BuildKit";
    homepage = "https://github.com/docker/buildx";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      ivan-babrou
      developer-guy
    ];

    mainProgram = "docker-buildx";
  };
}
