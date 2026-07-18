{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  callPackage,
  cdrkit,
  coreutils,
  debootstrap,
  gnupg,
  gnutar,
  hivex,
  makeWrapper,
  nix-update-script,
  nixosTests,
  pkg-config,
  squashfsTools,
  wimlib,
}:

let
  bins = [
    coreutils
    debootstrap
    gnupg
    gnutar
    squashfsTools
  ]
  ++ lib.optionals stdenv.hostPlatform.isx86_64 [
    # repack-windows deps
    cdrkit
    hivex
    wimlib
  ];
in
buildGoModule (finalAttrs: {
  pname = "distrobuilder";
  version = "3.3.1";

  src = fetchFromGitHub {
    owner = "lxc";
    repo = "distrobuilder";
    tag = "v${finalAttrs.version}";
    sha256 = "sha256-l9HtpeG4BSN9saDsNaF9uyOJbHGyLN0PwJ728IJfN/s=";
  };

  nativeBuildInputs = [
    pkg-config
    makeWrapper
  ]
  ++ bins;

  buildInputs = bins;
  vendorHash = "sha256-7dYfY6u8URJDMADY6yTW2SjOeSiRwqIh7oxUup6BHMg=";

  # upstream only supports make targets due to GOFLAGS, but none of the targets work for us
  # this could be fragile, but the alternative is copying them here
  preBuild = ''
    export GOFLAGS="$(grep 'export GOFLAGS' Makefile | sed 's/export GOFLAGS=//') -trimpath"
  '';

  # tests require a local keyserver (mkg20001/nixpkgs branch distrobuilder-with-tests) but gpg is currently broken in tests
  doCheck = false;

  postInstall = ''
    wrapProgram $out/bin/distrobuilder --prefix PATH ":" ${lib.makeBinPath bins}
  '';

  passthru = {
    generator = callPackage ./generator.nix { inherit (finalAttrs) src version; };

    tests = {
      incus-lts = nixosTests.incus-lts.container;
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "System container image builder for LXC and LXD";
    homepage = "https://github.com/lxc/distrobuilder";
    changelog = "https://github.com/lxc/distrobuilder/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;
    platforms = lib.platforms.linux;
    mainProgram = "distrobuilder";
    teams = [ lib.teams.lxc ];
  };
})
