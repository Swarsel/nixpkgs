{
  lib,
  stdenv,
  fetchFromGitHub,
  btrfs-progs,
  buildGoModule,
  go-md2man,
  gpgme,
  installShellFiles,
  libapparmor,
  libseccomp,
  libselinux,
  lvm2,
  pkg-config,
  versionCheckHook,
  writableTmpDirAsHomeHook,
}:

buildGoModule (finalAttrs: {
  pname = "buildah";
  version = "1.44.0";

  src = fetchFromGitHub {
    owner = "podman-container-tools";
    repo = "buildah";
    tag = "v${finalAttrs.version}";
    hash = "sha256-/Rv5la54ikmP4qVT19tg0sv0kM+xpQO6w9XU1PpGFk4=";
  };

  outputs = [
    "out"
    "man"
  ];

  nativeBuildInputs = [
    go-md2man
    installShellFiles
    pkg-config
  ];

  buildInputs = [
    gpgme
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    btrfs-progs
    libapparmor
    libseccomp
    libselinux
    lvm2
  ];

  vendorHash = null;

  buildPhase = ''
    runHook preBuild
    patchShebangs .
    make bin/buildah
    make -C docs GOMD2MAN="go-md2man"
    runHook postBuild
  '';

  doCheck = false;

  installPhase = ''
    runHook preInstall
    install -Dm755 bin/buildah $out/bin/buildah
    installShellCompletion --bash contrib/completions/bash/buildah
    make -C docs install PREFIX="$man"
    runHook postInstall
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    writableTmpDirAsHomeHook
    versionCheckHook
  ];

  versionCheckKeepEnvironment = [ "HOME" ];

  meta = {
    description = "Tool which facilitates building OCI images";
    homepage = "https://buildah.io/";
    changelog = "https://github.com/podman-container-tools/buildah/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;
    mainProgram = "buildah";
    teams = [ lib.teams.podman ];
  };
})
