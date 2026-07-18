{
  lib,
  fetchFromGitHub,
  buildGoModule,
  versionCheckHook,
}:
buildGoModule rec {
  pname = "docker-compose";
  version = "5.3.1";

  src = fetchFromGitHub {
    owner = "docker";
    repo = "compose";
    tag = "v${version}";
    hash = "sha256-UNORlxZ/b4Jrp9v8pbsxTt8PrYq1/u4AjBU8+pfuG1k=";
  };

  vendorHash = "sha256-Ug6/hpuHgJ2CAUX87/+Tt3cHm4AbJF9oznx61kTVKI4=";
  doCheck = false;

  installPhase = ''
    runHook preInstall
    install -D $GOPATH/bin/cmd $out/libexec/docker/cli-plugins/docker-compose

    mkdir -p $out/bin
    ln -s $out/libexec/docker/cli-plugins/docker-compose $out/bin/docker-compose
    runHook postInstall
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  ldflags = [
    "-X github.com/docker/compose/v5/internal.Version=${version}"
    "-s"
    "-w"
  ];

  modPostBuild = ''
    patch -d vendor/github.com/docker/cli/ -p1 < ${./cli-system-plugin-dir-from-env.patch}
  '';

  meta = {
    description = "Docker CLI plugin to define and run multi-container applications with Docker";
    homepage = "https://github.com/docker/compose";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ airone01 ];
    mainProgram = "docker-compose";
  };
}
