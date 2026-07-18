{
  lib,
  stdenv,
  fetchFromGitHub,
  acl,
  attr,
  autoreconfHook,
  boost,
  btrfs-progs,
  coreutils,
  dbus,
  diffutils,
  docbook_xml_dtd_45,
  docbook_xsl,
  e2fsprogs,
  json_c,
  libxml2,
  libxslt,
  lvm2,
  ncurses,
  nixosTests,
  pam,
  pkg-config,
  util-linux,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "snapper";
  version = "0.13.1";

  src = fetchFromGitHub {
    owner = "openSUSE";
    repo = "snapper";
    tag = "v${finalAttrs.version}";
    hash = "sha256-oPIIEReHWkWSj4K/mi1VD3Ukaltquzqh8UVBPc4q+vw=";
  };

  # Hard-coded root paths, hard-coded root paths everywhere...
  postPatch = ''
    for file in {client/installation-helper,client/systemd-helper,data,scripts,zypp-plugin,scripts/completion}/Makefile.am; do
      substituteInPlace $file \
        --replace-warn '$(DESTDIR)/usr' "$out" \
        --replace-warn "DESTDIR" "out" \
        --replace-warn "/usr" "$out"
    done
  '';

  strictDeps = true;

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
    docbook_xsl
    libxslt
    docbook_xml_dtd_45
  ];

  buildInputs = [
    acl
    attr
    boost
    btrfs-progs
    dbus
    diffutils
    e2fsprogs
    libxml2
    lvm2
    pam
    util-linux
    json_c
    ncurses
    zlib
  ];

  configureFlags = [
    "--disable-ext4" # requires patched kernel & e2fsprogs
    "DIFFBIN=${diffutils}/bin/diff"
    "RMBIN=${coreutils}/bin/rm"
  ];

  postInstall = ''
    rm -r $out/etc/cron.*
    patchShebangs $out/lib/zypp/plugins/commit/*
    for file in \
      $out/lib/pam_snapper/* \
      $out/lib/systemd/system/* \
      $out/share/dbus-1/system-services/* \
    ; do
      substituteInPlace $file --replace-warn "/usr" "$out"
    done
  '';

  enableParallelBuilding = true;
  passthru.tests.snapper = nixosTests.snapper;

  meta = {
    description = "Tool for Linux filesystem snapshot management";
    homepage = "http://snapper.io";
    license = lib.licenses.gpl2Only;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "snapper";
  };
})
