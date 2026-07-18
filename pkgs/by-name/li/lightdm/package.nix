{
  lib,
  stdenv,
  fetchFromGitHub,
  accountsservice,
  audit,
  autoreconfHook,
  buildPackages,
  busybox,
  fetchpatch,
  gettext,
  glib,
  gobject-introspection,
  gtk-doc,
  intltool,
  itstool,
  libgcrypt,
  libtool,
  libxcb,
  libxdmcp,
  libxklavier,
  nix-update-script,
  nixosTests,
  pam,
  pkg-config,
  plymouth,
  polkit,
  qt5,
  replaceVars,
  vala,
  yelp-tools,
  yelp-xsl,
  withQt5 ? false,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "lightdm";
  version = "1.32.0";

  src = fetchFromGitHub {
    owner = "ubuntu";
    repo = "lightdm";
    tag = finalAttrs.version;
    sha256 = "sha256-ttNlhWD0Ran4d3QvZ+PxbFbSUGMkfrRm+hJdQxIDJvM=";
  };

  outputs = [
    "out"
    "dev"
  ];

  patches = [
    # Adds option to disable writing dmrc files
    (fetchpatch {
      hash = "sha256-NpASGgEhOjxuKME2f7RM2U5JvRRdl0OF5lHnp5aKxxk=";
      url = "https://src.fedoraproject.org/rpms/lightdm/raw/4cf0d2bed8d1c68970b0322ccd5dbbbb7a0b12bc/f/lightdm-1.25.1-disable_dmrc.patch";
    })

    # Hardcode plymouth to fix transitions.
    # For some reason it can't find `plymouth`
    # even when it's in PATH in environment.systemPackages.
    (replaceVars ./fix-paths.patch {
      plymouth = "${plymouth}/bin/plymouth";
    })

    # glib gettext is deprecated and broken, so use regular gettext instead
    ./use-regular-gettext.patch
  ];

  nativeBuildInputs = [
    autoreconfHook
    gettext
    yelp-tools
    yelp-xsl
    gobject-introspection
    gtk-doc
    intltool
    itstool
    libtool
    pkg-config
    vala
  ];

  buildInputs = [
    accountsservice
    audit
    glib
    libxdmcp
    libgcrypt
    libxcb
    libxklavier
    pam
    polkit
  ]
  ++ lib.optional withQt5 qt5.qtbase;

  configureFlags = [
    "--localstatedir=/var"
    "--sysconfdir=/etc"
    "--disable-tests"
    "--disable-dmrc"
  ]
  ++ lib.optional withQt5 "--enable-liblightdm-qt5";

  preConfigure = "NOCONFIGURE=1 ./autogen.sh";

  postInstall = ''
    rm -rf $out/etc/apparmor.d $out/etc/init $out/etc/pam.d
  '';

  dontWrapQtApps = true;

  installFlags = [
    "sysconfdir=${placeholder "out"}/etc"
    "localstatedir=\${TMPDIR}"
  ];

  prePatch = ''
    substituteInPlace autogen.sh \
      --replace "which" "${buildPackages.busybox}/bin/which"

    substituteInPlace src/shared-data-manager.c \
      --replace /bin/rm ${busybox}/bin/rm
  '';

  passthru = {
    tests = { inherit (nixosTests) lightdm; };
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Cross-desktop display manager";
    homepage = "https://github.com/ubuntu/lightdm";

    license = with lib.licenses; [
      gpl3Plus
      # and (
      lgpl2Only
      # or
      lgpl3Only
      # )
    ];

    platforms = lib.platforms.linux;
    teams = [ lib.teams.pantheon ];
  };
})
