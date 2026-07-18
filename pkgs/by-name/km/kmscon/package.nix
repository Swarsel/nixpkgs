{
  lib,
  stdenv,
  fetchFromGitHub,
  bash,
  buildPackages,
  check,
  docbook_xml_dtd_42,
  docbook_xsl,
  fontconfig,
  freetype,
  gawk,
  inotify-tools,
  libGL,
  libGLU,
  libdrm,
  libgbm,
  libtsm,
  libxkbcommon,
  libxslt,
  meson,
  ncurses,
  ninja,
  nix-update-script,
  nixosTests,
  pango,
  pkg-config,
  python3,
  seatd,
  systemdLibs,
  zlib,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "kmscon";
  version = "10.0.0";

  src = fetchFromGitHub {
    owner = "kmscon";
    repo = "kmscon";
    tag = "v${finalAttrs.version}";
    hash = "sha256-M3830e1GzzLT2fhheWwNRkURzYkHv4k8uEMoCqKkjJY=";
  };

  outputs = [
    "out"
    "man"
  ];

  postPatch = ''
    patchShebangs scripts/terminfo
  '';

  strictDeps = true;

  nativeBuildInputs = [
    meson
    ninja
    docbook_xsl
    pkg-config
    libxslt # xsltproc
    docbook_xml_dtd_42
    python3
    ncurses
  ];

  buildInputs = [
    libGLU
    libGL
    libdrm
    libtsm
    libxkbcommon
    freetype
    fontconfig
    zlib
    pango
    systemdLibs
    libgbm
    seatd
    check
    # Needed for autoPatchShebangs when strictDeps = true
    bash
  ];

  env = {
    DESTDIR = "/";
    PKG_CONFIG_SYSTEMD_SYSTEMDSYSTEMUNITDIR = "${placeholder "out"}/lib/systemd/system";
  };

  postFixup = ''
    substituteInPlace $out/bin/kmscon \
      --replace-fail "awk" "${lib.getExe gawk}"
    substituteInPlace $out/bin/kmscon-launch-gui \
      --replace-fail "inotifywait" "${lib.getExe' inotify-tools "inotifywait"}"
  '';

  __structuredAttrs = true;

  depsBuildBuild = [
    buildPackages.stdenv.cc
  ];

  passthru = {
    tests.kmscon = nixosTests.kmscon;
    updateScript = nix-update-script { extraArgs = [ "--use-github-releases" ]; };
  };

  meta = {
    description = "KMS/DRM based System Console";
    homepage = "https://www.freedesktop.org/wiki/Software/kmscon/";
    changelog = "https://github.com/kmscon/kmscon/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ccicnce113424 ];
    platforms = lib.platforms.linux;
    mainProgram = "kmscon";
  };
})
