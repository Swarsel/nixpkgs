{
  lib,
  stdenv,
  fetchurl,
  dbus,
  glib,
  gobject-introspection,
  intltool,
  libgcrypt,
  pkg-config,
  testers,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libgnome-keyring";
  version = "3.12.0";

  src = fetchurl {
    url = "mirror://gnome/sources/libgnome-keyring/${lib.versions.majorMinor finalAttrs.version}/libgnome-keyring-${finalAttrs.version}.tar.xz";
    hash = "sha256-xMF4+7BfcqzEhNIt2wVo91MsQJsKE+BlE/9UuR6Ud4M=";
  };

  outputs = [
    "out"
    "dev"
  ];

  postPatch = ''
    # uses pkg-config in some places and uses the correct $PKG_CONFIG in some
    # it's an ancient library so it has very old configure scripts and m4
    substituteInPlace ./configure \
      --replace "pkg-config" "$PKG_CONFIG"
  '';

  strictDeps = true;

  nativeBuildInputs = [
    pkg-config
    intltool
  ];

  propagatedBuildInputs = [
    glib
    gobject-introspection
    dbus
    libgcrypt
  ];

  configureFlags = [
    # not ideal to use -config scripts but it's not possible switch it to pkg-config
    # binaries in dev have a for build shebang
    "LIBGCRYPT_CONFIG=${lib.getExe' (lib.getDev libgcrypt) "libgcrypt-config"}"
  ];

  passthru.tests.pkg-config = testers.testMetaPkgConfig finalAttrs.finalPackage;

  meta = {
    description = "Framework for managing passwords and other secrets";

    longDescription = ''
      gnome-keyring is a program that keeps password and other secrets for
      users. The library libgnome-keyring is used by applications to integrate
      with the gnome-keyring system.
    '';

    homepage = "https://gitlab.gnome.org/Archive/libgnome-keyring";
    changelog = "https://gitlab.gnome.org/Archive/libgnome-keyring/-/blob/${finalAttrs.version}/NEWS?ref_type=tags";

    license = with lib.licenses; [
      gpl2Plus
      lgpl2Plus
    ];

    maintainers = [ ];
    platforms = lib.platforms.unix;
    pkgConfigModules = [ "gnome-keyring-1" ];
  };
})
