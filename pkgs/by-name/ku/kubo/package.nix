{
  lib,
  stdenv,
  fetchurl,
  buildGoModule,
  callPackage,
  installShellFiles,
  nixosTests,
}:

buildGoModule rec {
  pname = "kubo";
  version = "0.40.1"; # When updating, also check if the repo version changed and adjust repoVersion below

  # Kubo makes changes to its source tarball that don't match the git source.
  src = fetchurl {
    url = "https://github.com/ipfs/kubo/releases/download/${rev}/kubo-source.tar.gz";
    hash = "sha256-O6mSFDKj1DdTMGhg5Q6L0hiLW9CUyUq9uyFz9Xjmm4s=";
  };

  outputs = [
    "out"
    "systemd_unit"
    "systemd_unit_hardened"
  ];

  postPatch = ''
    substituteInPlace 'misc/systemd/ipfs.service' \
      --replace-fail '/usr/local/bin/ipfs' "$out/bin/ipfs"
    substituteInPlace 'misc/systemd/ipfs-hardened.service' \
      --replace-fail '/usr/local/bin/ipfs' "$out/bin/ipfs"
  '';

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = null;

  postInstall = ''
    install --mode=444 -D 'misc/systemd/ipfs-api.socket' "$systemd_unit/etc/systemd/system/ipfs-api.socket"
    install --mode=444 -D 'misc/systemd/ipfs-gateway.socket' "$systemd_unit/etc/systemd/system/ipfs-gateway.socket"
    install --mode=444 -D 'misc/systemd/ipfs.service' "$systemd_unit/etc/systemd/system/ipfs.service"

    install --mode=444 -D 'misc/systemd/ipfs-api.socket' "$systemd_unit_hardened/etc/systemd/system/ipfs-api.socket"
    install --mode=444 -D 'misc/systemd/ipfs-gateway.socket' "$systemd_unit_hardened/etc/systemd/system/ipfs-gateway.socket"
    install --mode=444 -D 'misc/systemd/ipfs-hardened.service' "$systemd_unit_hardened/etc/systemd/system/ipfs.service"
  ''
  + lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd ipfs \
      --bash <($out/bin/ipfs commands completion bash) \
      --fish <($out/bin/ipfs commands completion fish) \
      --zsh <($out/bin/ipfs commands completion zsh)
  '';

  # tarball contains multiple files/directories
  postUnpack = ''
    mkdir kubo-src
    shopt -s extglob
    mv !(kubo-src) kubo-src || true
    cd kubo-src
  '';

  rev = "v${version}";
  sourceRoot = ".";
  subPackages = [ "cmd/ipfs" ];
  passthru.repoVersion = "18";

  passthru.tests = {
    inherit (nixosTests) kubo ipget;
    repoVersion = callPackage ./test-repoVersion.nix { };
  };

  meta = {
    description = "IPFS implementation in Go";
    homepage = "https://ipfs.io/";
    changelog = "https://github.com/ipfs/kubo/releases/tag/${rev}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      Luflosi
    ];

    platforms = lib.platforms.unix;
    mainProgram = "ipfs";
  };
}
