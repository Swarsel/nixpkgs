{
  lib,
  stdenv,
  fetchFromGitLab,
  installShellFiles,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "recoverdm";
  version = "0.20-9";

  src = fetchFromGitLab {
    owner = "pkg-security-team";
    repo = "recoverdm";
    rev = "debian/${finalAttrs.version}";
    hash = "sha256-HLaiTeeqXn0mgRnG5FZflkPiDiB8CGzq4FR7lDj5oHI=";
    domain = "salsa.debian.org";
  };

  patches =
    let
      patch = name: "./debian/patches/${name}";
    in
    [
      (patch "10_fix-makefile.patch")
      (patch "20_fix-typo-binary.patch")
      (patch "30-fix-BTS-mergebad-crash.patch")
      (patch "40_dev-c.patch")
      (patch "50_ftbfs-with-gcc-14.patch")
      ./0001-darwin-build-fixes.patch
    ];

  postPatch = ''
    substituteInPlace Makefile \
      --replace-fail '$(DESTDIR)/usr/bin' $out/bin
  '';

  nativeBuildInputs = [
    installShellFiles
  ];

  preInstall = ''
    mkdir -p $out/bin
  '';

  postInstall = ''
    installManPage recoverdm.1
  '';

  meta = {
    description = "Recover damaged CD DVD and disks with bad sectors";
    homepage = "https://salsa.debian.org/pkg-security-team/recoverdm";
    changelog = "https://salsa.debian.org/pkg-security-team/recoverdm/-/blob/debian/master/debian/changelog";
    license = lib.licenses.gpl1Only;
    maintainers = [ ];
    platforms = lib.platforms.unix;
    mainProgram = "recoverdm";
  };
})
