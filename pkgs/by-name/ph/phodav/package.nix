{
  lib,
  stdenv,
  fetchurl,
  gnome,
  libsoup_3,
  libxml2,
  meson,
  ninja,
  pkg-config,
  udevCheckHook,
}:

stdenv.mkDerivation rec {
  pname = "phodav";
  version = "3.0";

  src = fetchurl {
    url = "mirror://gnome/sources/phodav/${version}/phodav-${version}.tar.xz";
    sha256 = "OS7C0G1QMA3P8e8mmiqYUwTim841IAAvyiny7cHRONE=";
  };

  outputs = [
    "out"
    "dev"
    "lib"
  ];

  nativeBuildInputs = [
    pkg-config
    meson
    ninja
    udevCheckHook
  ];

  buildInputs = [
    libsoup_3
    libxml2
  ];

  mesonFlags = [
    "-Davahi=disabled"
    "-Dsystemdsystemunitdir=${placeholder "out"}/lib/systemd/system"
    "-Dgtk_doc=disabled"
    "-Dudevrulesdir=${placeholder "out"}/lib/udev/rules.d"
  ];

  env = lib.optionalAttrs stdenv.hostPlatform.isDarwin {
    NIX_LDFLAGS = "-lintl";
  };

  # We need to do this in pre-configure before the data/ folder disappears.
  preConfigure = ''
    install -vDt $out/lib/udev/rules.d/ data/*-spice-webdavd.rules
  '';

  doInstallCheck = true;

  passthru = {
    updateScript = gnome.updateScript {
      packageName = pname;
    };
  };

  meta = {
    description = "WebDav server implementation and library using libsoup";
    homepage = "https://gitlab.gnome.org/GNOME/phodav";
    license = lib.licenses.lgpl21Plus;
    maintainers = with lib.maintainers; [ wegank ];
    platforms = lib.platforms.unix;
  };
}
