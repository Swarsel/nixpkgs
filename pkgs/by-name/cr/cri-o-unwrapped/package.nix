{
  lib,
  fetchFromGitHub,
  btrfs-progs,
  buildGoModule,
  glibc,
  go-md2man,
  gpgme,
  installShellFiles,
  libapparmor,
  libseccomp,
  libselinux,
  lvm2,
  nixosTests,
  pkg-config,
}:

buildGoModule (finalAttrs: {
  pname = "cri-o";
  version = "1.36.2";

  src = fetchFromGitHub {
    owner = "cri-o";
    repo = "cri-o";
    tag = "v${finalAttrs.version}";
    hash = "sha256-mrR0Q23PCe2OMCgH6AgmSzE4zmZzTA6SiMD8OYiWdpE=";
  };

  outputs = [
    "out"
    "man"
  ];

  nativeBuildInputs = [
    installShellFiles
    go-md2man
    pkg-config
  ];

  buildInputs = [
    btrfs-progs
    gpgme
    libapparmor
    libseccomp
    libselinux
    lvm2
  ]
  ++ lib.optionals (glibc != null) [
    glibc
    glibc.static
  ];

  vendorHash = null;

  env.BUILDTAGS = toString [
    "apparmor"
    "seccomp"
    "selinux"
    "containers_image_openpgp"
    "containers_image_ostree_stub"
  ];

  buildPhase = ''
    runHook preBuild
    sed -i 's;\thack/;\tbash ./hack/;g' Makefile
    make binaries docs BUILDTAGS="$BUILDTAGS"
    runHook postBuild
  '';

  doCheck = false;

  installPhase = ''
    runHook preInstall
    install -Dm755 bin/* -t $out/bin

    for shell in bash fish zsh; do
      installShellCompletion --$shell completions/$shell/*
    done

    install contrib/cni/*.conflist -Dt $out/etc/cni/net.d
    install crictl.yaml -Dt $out/etc

    installManPage docs/*.[1-9]
    runHook postInstall
  '';

  passthru.tests = { inherit (nixosTests) cri-o; };

  meta = {
    description = ''
      Open Container Initiative-based implementation of the
      Kubernetes Container Runtime Interface
    '';

    homepage = "https://cri-o.io";
    license = lib.licenses.asl20;
    platforms = lib.platforms.linux;
    teams = [ lib.teams.podman ];
  };
})
