{
  lib,
  fetchFromGitHub,
  buildGoModule,
  buildNpmPackage,
}:

let
  version = "1.4.0-stable";

  src = fetchFromGitHub {
    owner = "gtsteffaniak";
    repo = "filebrowser";
    tag = "v${version}";
    hash = "sha256-Ojz1VTtlCFUTodQ66mr0ozLKsx3kUirm79HuFJu33yQ=";
  };

  frontend = buildNpmPackage {
    inherit version src;
    pname = "filebrowser-quantum-frontend";
    npmDepsHash = "sha256-tisZA7v0WsynNxgbww48eERz9+om4w8MW4IMzQIyh+Y=";

    buildPhase = ''
      runHook preBuild

      npm run build:docker

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out
      cp -r dist/* $out

      runHook postInstall
    '';

    sourceRoot = "${src.name}/frontend";
  };

in
buildGoModule {
  inherit version src;
  pname = "filebrowser-quantum";
  vendorHash = "sha256-WvilFCwTGXecsD/afUpLL6TrGzr/cgkQeltCKKDc4AI=";

  preBuild = ''
    mkdir -p http/embed
    cp -r ${frontend}/* http/embed/
  '';

  postInstall = ''
    mv $out/bin/backend $out/bin/filebrowser-quantum
  '';

  ldflags = [
    "-w"
    "-s"
    "-X github.com/gtsteffaniak/filebrowser/backend/version.CommitSHA=testingCommit"
    "-X github.com/gtsteffaniak/filebrowser/backend/version.Version=testing"
  ];

  sourceRoot = "${src.name}/backend";

  meta = {
    description = "Access and manage your files from the web";
    homepage = "https://github.com/gtsteffaniak/filebrowser";
    changelog = "https://github.com/gtsteffaniak/filebrowser/blob/v${version}/CHANGELOG.md";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      jocimsus
      denperidge
    ];

    mainProgram = "filebrowser-quantum";
  };
}
