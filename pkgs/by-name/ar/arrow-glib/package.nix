{
  lib,
  stdenv,
  arrow-cpp,
  glib,
  gobject-introspection,
  meson,
  ninja,
  pkg-config,
  python3,
}:

stdenv.mkDerivation {
  inherit (arrow-cpp) src version;
  pname = "arrow-glib";
  strictDeps = true;

  nativeBuildInputs = [
    meson
    ninja
    python3
    pkg-config
    gobject-introspection
  ];

  buildInputs = [
    arrow-cpp
    glib
  ];

  sourceRoot = "${arrow-cpp.src.name}/c_glib";

  meta = {
    inherit (arrow-cpp.meta) license platforms;
    description = "GLib bindings for Apache Arrow";
    homepage = "https://arrow.apache.org/docs/c_glib/";
    maintainers = with lib.maintainers; [ amarshall ];
  };
}
