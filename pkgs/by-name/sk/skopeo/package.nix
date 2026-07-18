{
  lib,
  stdenv,
  fetchFromGitHub,
  btrfs-progs,
  buildGoModule,
  dockerTools,
  fuse-overlayfs,
  go-md2man,
  gpgme,
  installShellFiles,
  lvm2,
  makeWrapper,
  pkg-config,
  runCommand,
  skopeo,
  testers,
}:

buildGoModule rec {
  pname = "skopeo";
  version = "1.23.0";

  src = fetchFromGitHub {
    owner = "containers";
    repo = "skopeo";
    rev = "v${version}";
    hash = "sha256-crt6TYEOQaBdP1lIixtnrMPeWQ/GAyA6N6K3Il+ZA1E=";
  };

  outputs = [
    "out"
    "man"
  ];

  nativeBuildInputs = [
    pkg-config
    go-md2man
    installShellFiles
    makeWrapper
  ];

  buildInputs = [
    gpgme
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    lvm2
    btrfs-progs
  ];

  vendorHash = null;

  buildPhase = ''
    runHook preBuild
    patchShebangs .
    make bin/skopeo docs
  ''
  + lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    make completions
  ''
  + ''
    runHook postBuild
  '';

  doCheck = false;

  installPhase = ''
    runHook preInstall
    PREFIX=${placeholder "out"} make install-binary install-docs
  ''
  + lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    PREFIX=${placeholder "out"} make install-completions
  ''
  + ''
    install ${passthru.policy}/default-policy.json -Dt $out/etc/containers
  ''
  + lib.optionalString stdenv.hostPlatform.isLinux ''
    wrapProgram $out/bin/skopeo \
      --prefix PATH : ${lib.makeBinPath [ fuse-overlayfs ]}
  ''
  + ''
    runHook postInstall
  '';

  passthru = {
    policy = runCommand "policy" { } ''
      install ${src}/default-policy.json -Dt $out
    '';

    tests = {
      inherit (dockerTools.examples) testNixFromDockerHub;

      version = testers.testVersion {
        package = skopeo;
      };
    };
  };

  meta = {
    description = "Command line utility for various operations on container images and image repositories";
    homepage = "https://github.com/containers/skopeo";
    changelog = "https://github.com/containers/skopeo/releases/tag/${src.rev}";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      lewo
      developer-guy
      ryan4yin
    ];

    mainProgram = "skopeo";
    teams = [ lib.teams.podman ];
  };
}
