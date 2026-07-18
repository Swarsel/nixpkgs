{
  lib,
  stdenv,
  fetchurl,
  adwaita-icon-theme,
  bcachefs-tools,
  btrfs-progs,
  coreutils,
  cryptsetup,
  dosfstools,
  e2fsprogs,
  exfatprogs,
  f2fs-tools,
  gettext,
  glib,
  gnugrep,
  gnused,
  gpart,
  gtkmm3,
  hdparm,
  hfsprogs,
  jfsutils,
  libuuid,
  libxml2,
  lvm2,
  mtools,
  nilfs-utils,
  ntfs3g,
  parted,
  pkg-config,
  polkit,
  procps,
  replaceVars,
  udftools,
  util-linuxMinimal,
  wrapGAppsHook3,
  xfsdump,
  xfsprogs,
  xhost,
  withAllTools ? false,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gparted";
  version = "1.8.1";

  src = fetchurl {
    url = "mirror://sourceforge/gparted/gparted-${finalAttrs.version}.tar.gz";
    hash = "sha256-ZziKxAX5/pKkBjbLA7Dh4LtkA62JzMF0sv8ZDvbzI0k=";
  };

  # Tries to run `pkexec --version` to get version.
  # however the binary won't be suid so it returns
  # an error preventing the program from detection
  patches = [
    (replaceVars ./polkit.patch {
      polkit_version = polkit.version;
    })
  ];

  nativeBuildInputs = [
    gettext
    pkg-config
    wrapGAppsHook3
  ];

  buildInputs = [
    parted
    glib
    libuuid
    gtkmm3
    libxml2
    polkit.bin
    adwaita-icon-theme
  ];

  configureFlags = [
    "--disable-doc"
    "--enable-xhost-root"
  ];

  preConfigure = ''
    # For ITS rules
    addToSearchPath "XDG_DATA_DIRS" "${polkit.out}/share"
  '';

  # Doesn't get installed automatically if PREFIX != /usr
  postInstall = ''
    install -D -m0644 org.gnome.gparted.policy \
      $out/share/polkit-1/actions/org.gnome.gparted.policy
  '';

  preFixup = ''
    gappsWrapperArgs+=(
       --prefix PATH : "${
         lib.makeBinPath (
           [
             gpart
             hdparm
             procps
             coreutils
             gnused
             gnugrep
             mtools
             xhost
           ]
           ++ finalAttrs.runtimeDeps
         )
       }"
    )
  '';

  enableParallelBuilding = true;

  runtimeDeps = [
    dosfstools
    e2fsprogs
    util-linuxMinimal
  ]
  ++ lib.optionals withAllTools [
    bcachefs-tools
    btrfs-progs
    exfatprogs
    f2fs-tools
    hfsprogs
    jfsutils
    cryptsetup
    lvm2
    nilfs-utils
    ntfs3g
    udftools
    xfsprogs
    xfsdump
  ];

  meta = {
    description = "Graphical disk partitioning tool";

    longDescription = ''
      GNOME Partition Editor for creating, reorganizing, and deleting disk
      partitions. GParted enables you to change the partition organization
      while preserving the partition contents.
    '';

    homepage = "https://gparted.org";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
    mainProgram = "gparted";
  };
})
