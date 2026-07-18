{
  lib,
  stdenv,
  fetchFromGitHub,
  bash,
  bzip2,
  coreutils,
  desktopToDarwinBundle,
  gnutar,
  gtk3,
  gzip,
  intltool,
  lhasa,
  libxslt,
  makeWrapper,
  p7zip,
  pkg-config,
  unar,
  unzip,
  wrapGAppsHook3,
  xz,
  zip,
  zstd,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "xarchiver";
  version = "0.5.4.27";

  src = fetchFromGitHub {
    owner = "ib";
    repo = "xarchiver";
    rev = finalAttrs.version;
    hash = "sha256-s4RM9loFlKVcOtxNolt6+wZTp3ITdGaHTNUtDnAmqfs=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    intltool
    libxslt
    makeWrapper
    pkg-config
    wrapGAppsHook3
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [ desktopToDarwinBundle ];

  buildInputs = [
    gtk3
    bash # so patchShebangs can patch #!/bin/sh in xarchiver.tap
  ];

  postFixup = ''
    wrapProgram $out/bin/xarchiver \
    --prefix PATH : ${
      lib.makeBinPath [
        zip
        unzip
        p7zip
        unar
        gnutar
        bzip2
        gzip
        lhasa
        xz
        zstd
        coreutils
      ]
    }
  '';

  meta = {
    description = "GTK frontend to 7z,zip,rar,tar,bzip2, gzip,arj, lha, rpm and deb (open and extract only)";
    homepage = "https://github.com/ib/xarchiver";
    license = lib.licenses.gpl2Plus;
    maintainers = [ ];
    platforms = lib.platforms.all;
    mainProgram = "xarchiver";
  };
})
