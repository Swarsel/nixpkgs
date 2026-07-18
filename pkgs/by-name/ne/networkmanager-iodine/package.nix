{
  lib,
  stdenv,
  fetchFromGitLab,
  autoreconfHook,
  glib,
  gtk3,
  intltool,
  iodine,
  libnma,
  libsecret,
  networkmanager,
  pkg-config,
  replaceVars,
  unstableGitUpdater,
  withGnome ? true,
}:

stdenv.mkDerivation {
  pname = "NetworkManager-iodine${lib.optionalString withGnome "-gnome"}";
  version = "1.2.0-unstable-2025-12-22";

  src = fetchFromGitLab {
    owner = "GNOME";
    repo = "network-manager-iodine";
    rev = "c329a1fc2be59a6094ef7f7b1fe5fd92f73947a4";
    sha256 = "mE7Hzvh3mZKwcVPeVlB8jWcTRp3sDLe0zr0l6kaUEo8=";
    domain = "gitlab.gnome.org";
  };

  patches = [
    (replaceVars ./fix-paths.patch {
      inherit iodine;
    })
  ];

  nativeBuildInputs = [
    intltool
    autoreconfHook
    pkg-config
    glib
  ];

  buildInputs = [
    iodine
    networkmanager
    glib
  ]
  ++ lib.optionals withGnome [
    gtk3
    libsecret
    libnma
  ];

  configureFlags = [
    "--with-gnome=${lib.boolToYesNo withGnome}"
    "--localstatedir=/" # needed for the management socket under /run/NetworkManager
    "--enable-absolute-paths"
  ];

  preConfigure = ''
    intltoolize
  '';

  passthru = {
    networkManagerPlugin = "VPN/nm-iodine-service.name";

    updateScript = unstableGitUpdater {
      tagPrefix = "v";
    };
  };

  meta = {
    inherit (networkmanager.meta) maintainers teams platforms;
    description = "NetworkManager's iodine plugin";
    homepage = "https://gitlab.gnome.org/GNOME/network-manager-iodine";
    license = lib.licenses.gpl2Plus;
  };
}
