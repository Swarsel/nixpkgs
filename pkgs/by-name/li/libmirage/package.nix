{
  lib,
  stdenv,
  fetchurl,
  bzip2,
  cmake,
  flac,
  glib,
  gobject-introspection,
  intltool,
  libgcrypt,
  libgpg-error,
  libogg,
  libopus,
  libsamplerate,
  libselinux,
  libsepol,
  libsndfile,
  libvorbis,
  pkg-config,
  util-linux,
  vala,
  writeScript,
  xz,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libmirage";
  version = "3.3.2";

  src = fetchurl {
    url = "mirror://sourceforge/cdemu/libmirage-${finalAttrs.version}.tar.xz";
    hash = "sha256-wMAzJpEue1QnDllWheFk3ZX+8pSkYw13s+GU0G/AOfs=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    intltool
    gobject-introspection
    vala
  ];

  buildInputs = [
    glib
    libsndfile
    flac
    libogg
    libvorbis
    zlib
    bzip2
    xz
    libsamplerate
    libgcrypt
    libgpg-error
  ];

  propagatedBuildInputs = [
    util-linux
    libselinux
    libsepol
  ];

  env = {
    PKG_CONFIG_GOBJECT_INTROSPECTION_1_0_GIRDIR = "${placeholder "out"}/share/gir-1.0";
    PKG_CONFIG_GOBJECT_INTROSPECTION_1_0_TYPELIBDIR = "${placeholder "out"}/lib/girepository-1.0";
  };

  passthru = {
    updateScript = writeScript "update-libmirage" ''
      #!/usr/bin/env nix-shell
      #!nix-shell -i bash -p curl pcre2 common-updater-scripts

      set -eu -o pipefail

      # Fetch the latest version from the SourceForge RSS feed for libmirage
      newVersion="$(curl -s "https://sourceforge.net/projects/cdemu/rss?path=/libmirage" | pcre2grep -o1 'libmirage-([0-9.]+)\.tar\.xz' | head -n 1)"

      update-source-version libmirage "$newVersion"
    '';
  };

  meta = {
    description = "CD-ROM image access library";
    homepage = "https://cdemu.sourceforge.io/about/libmirage/";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ bendlas ];
    platforms = lib.platforms.linux;
  };
})
