{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  go-md2man,
  installShellFiles,
  libapparmor,
  libseccomp,
  libselinux,
  makeBinaryWrapper,
  nixosTests,
  pkg-config,
  which,
}:

buildGoModule (finalAttrs: {
  pname = "runc";
  version = "1.4.3";

  src = fetchFromGitHub {
    owner = "opencontainers";
    repo = "runc";
    tag = "v${finalAttrs.version}";
    hash = "sha256-I9DruagoSWjrEBB4n+w5rzali5wvD/q3tVQFWPDnLAI=";
  };

  outputs = [
    "out"
    "man"
  ];

  nativeBuildInputs = [
    go-md2man
    installShellFiles
    makeBinaryWrapper
    pkg-config
    which
  ];

  buildInputs = [
    libselinux
    libseccomp
    libapparmor
  ];

  vendorHash = null;

  makeFlags = [
    "BUILDTAGS+=seccomp"
    "SHELL=${stdenv.shell}"
  ];

  buildPhase = ''
    runHook preBuild
    patchShebangs .
    make ${toString finalAttrs.makeFlags} runc man
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -Dm755 runc $out/bin/runc
    installManPage man/*/*.[1-9]
    wrapProgram $out/bin/runc \
      --prefix PATH : /run/current-system/systemd/bin
    runHook postInstall
  '';

  passthru.tests = { inherit (nixosTests) cri-o docker podman; };

  meta = {
    description = "CLI tool for spawning and running containers according to the OCI specification";
    homepage = "https://github.com/opencontainers/runc";
    license = lib.licenses.asl20;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "runc";
    teams = [ lib.teams.podman ];
  };
})
