{
  lib,
  stdenv,
  fetchFromGitLab,
  autoreconfHook,
  glib,
  gobject-introspection,
  gtk-doc,
  gtk3,
  # TODO: Clean up on `staging`
  llvmPackages,
  pkg-config,
  gtk ? gtk3,
}:

stdenv.mkDerivation rec {
  pname = "gtk-mac-integration";
  version = "3.0.1";

  src = fetchFromGitLab {
    owner = "GNOME";
    repo = "gtk-mac-integration";
    rev = "gtk-mac-integration-${version}";
    sha256 = "0sc0m3p8r5xfh5i4d7dg72kfixx9yi4f800y43bszyr88y52jkga";
    domain = "gitlab.gnome.org";
  };

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
    gtk-doc
    gobject-introspection
    # TODO: Clean up on `staging`
    llvmPackages.lld
  ];

  buildInputs = [ glib ];
  propagatedBuildInputs = [ gtk ];

  # Fix for ld64 hardening issue
  #
  # TODO: Clean up on `staging`
  env = lib.optionalAttrs stdenv.hostPlatform.isDarwin {
    NIX_CFLAGS_LINK = "-fuse-ld=lld";
  };

  preAutoreconf = ''
    gtkdocize
  '';

  meta = {
    description = "Provides integration for GTK applications into the Mac desktop";
    homepage = "https://gitlab.gnome.org/GNOME/gtk-mac-integration";
    license = lib.licenses.lgpl21;
    maintainers = [ ];
    platforms = lib.platforms.darwin;
  };
}
