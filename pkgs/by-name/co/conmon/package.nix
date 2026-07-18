{
  lib,
  stdenv,
  fetchFromGitHub,
  glib,
  glibc,
  libseccomp,
  nixosTests,
  pkg-config,
  systemdMinimal,
  versionCheckHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "conmon";
  version = "2.2.1";

  src = fetchFromGitHub {
    owner = "containers";
    repo = "conmon";
    tag = "v${finalAttrs.version}";
    hash = "sha256-YkPgpT+0cE7FCP/dcqnTy6oonPbXKiutFCGX5Lj1JB8=";
    leaveDotGit = true;

    postFetch = ''
      cd $out
      git rev-parse HEAD > COMMIT
      rm -rf .git
    '';
  };

  strictDeps = true;
  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    glib
    libseccomp
    systemdMinimal
  ]
  ++ lib.optionals (!stdenv.hostPlatform.isMusl) [
    glibc
    glibc.static
  ];

  # manpage requires building the vendored go-md2man
  makeFlags = [
    "bin/conmon"
  ];

  preConfigure = ''
    substituteInPlace Makefile \
      --replace-fail "(GIT_COMMIT)" "(shell cat COMMIT)"
  '';

  installPhase = ''
    runHook preInstall
    install -D bin/conmon -t $out/bin
    runHook postInstall
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  enableParallelBuilding = true;
  versionCheckProgramArg = "--version";
  passthru.tests = { inherit (nixosTests) cri-o podman; };

  meta = {
    description = "OCI container runtime monitor";
    homepage = "https://github.com/containers/conmon";
    changelog = "https://github.com/containers/conmon/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    platforms = lib.platforms.linux;
    mainProgram = "conmon";
    teams = [ lib.teams.podman ];
  };
})
