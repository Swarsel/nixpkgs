{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  fetchzip,
  installShellFiles,
  writableTmpDirAsHomeHook,
}:

let
  version = "2.9.1";
  srcHash = "sha256-aVJpUigIkGXsjvb40hEkZ2OiUghGcte3Msq4DMLIcbU=";
  vendorHash = "sha256-TG41xOrAAVBsE6CJ4av6y3bxfudk6gV49+/xB9Qu5ME=";
  manifestsHash = "sha256-DeTjdgOZyvrpQvIoXyVUfRIbHoJ9o74FRuTpVgT1/3I=";

  manifests = fetchzip {
    hash = manifestsHash;
    stripRoot = false;
    url = "https://github.com/fluxcd/flux2/releases/download/v${version}/manifests.tar.gz";
  };
in

buildGoModule rec {
  inherit vendorHash version;
  pname = "fluxcd";

  src = fetchFromGitHub {
    owner = "fluxcd";
    repo = "flux2";
    rev = "v${version}";
    hash = srcHash;
  };

  nativeBuildInputs = [ installShellFiles ];
  env.CGO_ENABLED = 0;
  # Required to workaround test error:
  #   panic: mkdir /homeless-shelter: permission denied
  nativeCheckInputs = [ writableTmpDirAsHomeHook ];

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    for shell in bash fish zsh; do
      installShellCompletion --cmd flux \
        --$shell <($out/bin/flux completion $shell)
    done
  '';

  doInstallCheck = true;

  installCheckPhase = ''
    $out/bin/flux --version | grep ${version} > /dev/null
  '';

  ldflags = [
    "-s"
    "-w"
    "-X main.VERSION=${version}"
  ];

  postUnpack = ''
    cp -r ${manifests} source/cmd/flux/manifests

    # disable tests that require network access
    rm source/cmd/flux/create_secret_git_test.go
  '';

  subPackages = [ "cmd/flux" ];
  passthru.updateScript = ./update.sh;

  meta = {
    description = "Open and extensible continuous delivery solution for Kubernetes";

    longDescription = ''
      Flux is a tool for keeping Kubernetes clusters in sync
      with sources of configuration (like Git repositories), and automating
      updates to configuration when there is new code to deploy.
    '';

    homepage = "https://fluxcd.io";
    changelog = "https://github.com/fluxcd/flux2/releases/tag/v${version}";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      jlesquembre
      ryan4yin
      SchahinRohani
      stealthybox
    ];

    mainProgram = "flux";
    downloadPage = "https://github.com/fluxcd/flux2/";
  };
}
