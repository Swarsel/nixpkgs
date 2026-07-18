{
  lib,
  stdenv,
  fetchurl,
  clutter,
  gnome,
  gobject-introspection,
  gtk3,
  meson,
  ninja,
  pkg-config,
}:

let
  version = "1.8.4";
in
stdenv.mkDerivation rec {
  inherit version;
  pname = "clutter-gtk";

  src = fetchurl {
    url = "mirror://gnome/sources/clutter-gtk/${lib.versions.majorMinor version}/clutter-gtk-${version}.tar.xz";
    sha256 = "01ibniy4ich0fgpam53q252idm7f4fn5xg5qvizcfww90gn9652j";
  };

  outputs = [
    "out"
    "dev"
  ];

  postPatch = ''
    # ld: malformed 32-bit x.y.z version number: =1
    substituteInPlace meson.build \
      --replace "host_system == 'darwin'" "false"
  '';

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    gobject-introspection
  ];

  propagatedBuildInputs = [
    clutter
    gtk3
  ];

  postBuild = "rm -rf $out/share/gtk-doc";

  passthru = {
    updateScript = gnome.updateScript {
      packageName = pname;
      versionPolicy = "odd-unstable";
    };
  };

  meta = {
    description = "Clutter-GTK";
    homepage = "http://www.clutter-project.org/";
    license = lib.licenses.lgpl2Plus;
    maintainers = [ ];
    platforms = lib.platforms.unix;
  };
}
