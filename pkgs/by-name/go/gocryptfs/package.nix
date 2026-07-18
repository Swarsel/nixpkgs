{
  lib,
  fetchFromGitHub,
  buildGoModule,
  libfido2,
  makeWrapper,
  nixosTests,
  openssl,
  pandoc,
  pkg-config,
}:

buildGoModule (finalAttrs: {
  pname = "gocryptfs";
  version = "2.6.1";

  src = fetchFromGitHub {
    owner = "rfjakob";
    repo = "gocryptfs";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-uQLFcabN418m1dvogJ71lJeTF3F9JycK/8qCPaXblSU=";
  };

  patches = [ ./0001-mount.go-try-fusermount3-suid-wrapper-and-fallback-t.patch ];

  nativeBuildInputs = [
    makeWrapper
    pkg-config
    pandoc
  ];

  buildInputs = [ openssl ];
  propagatedBuildInputs = [ libfido2 ];
  vendorHash = "sha256-dvOROh5TsMl+52RvKmDG4ftNv3WF19trgttu5BGWktU=";

  postBuild = ''
    pushd Documentation/
    mkdir -p $out/share/man/man1
    # taken from Documentation/MANPAGE-render.bash
    pandoc MANPAGE.md -s -t man -o $out/share/man/man1/gocryptfs.1
    pandoc MANPAGE-XRAY.md -s -t man -o $out/share/man/man1/gocryptfs-xray.1
    pandoc MANPAGE-STATFS.md -s -t man -o $out/share/man/man1/statfs.1
    popd
  '';

  postInstall = ''
    ln -s $out/bin/gocryptfs $out/bin/mount.fuse.gocryptfs
  '';

  ldflags = [
    "-X main.GitVersion=${finalAttrs.version}"
    "-X main.GitVersionFuse=[vendored]"
    "-X main.BuildDate=unknown"
  ];

  subPackages = [
    "."
    "gocryptfs-xray"
    "contrib/statfs"
  ];

  passthru.tests.gocryptfs = nixosTests.gocryptfs;

  meta = {
    description = "Encrypted overlay filesystem written in Go";
    homepage = "https://nuetzlich.net/gocryptfs/";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      flokli
      prusnak
    ];

    platforms = lib.platforms.unix;
  };
})
