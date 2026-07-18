{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  dconf,
  docbook2x,
  gobject-introspection,
  gtk3,
  ibus,
  pkg-config,
  python3,
  wrapGAppsHook3,
}:

stdenv.mkDerivation rec {
  pname = "ibus-table";
  version = "1.17.18";

  src = fetchFromGitHub {
    owner = "kaio";
    repo = "ibus-table";
    rev = version;
    sha256 = "sha256-NU+lZcuCJs1k0BNnPyxR6aiFNc8mmcNxM9k9yrg0Q/M=";
  };

  postPatch = ''
    # Data paths will be set at run-time.
    sed -e "/export IBUS_TABLE_LIB_LOCATION=/ s/^.*$//" \
        -e "/export IBUS_TABLE_LOCATION=/ s/^.*$//" \
        -i "engine/ibus-engine-table.in"
    sed -e "/export IBUS_TABLE_BIN_PATH=/ s/^.*$//" \
        -e "/export IBUS_TABLE_DATA_DIR=/ s/^.*$//" \
        -i "engine/ibus-table-createdb.in"
    sed -e "/export IBUS_PREFIX=/ s/^.*$//" \
        -e "/export IBUS_DATAROOTDIR=/ s/^.$//" \
        -e "/export IBUS_LOCALEDIR=/ s/^.$//" \
        -i "setup/ibus-setup-table.in"
    substituteInPlace engine/tabcreatedb.py --replace '/usr/share/ibus-table' $out/share/ibus-table
    substituteInPlace engine/ibus_table_location.py \
      --replace '/usr/libexec' $out/libexec \
      --replace '/usr/share/ibus-table/' $out/share/ibus-table/
  '';

  nativeBuildInputs = [
    autoreconfHook
    docbook2x
    pkg-config
    gobject-introspection
    wrapGAppsHook3
  ];

  buildInputs = [
    dconf
    gtk3
    ibus
    (python3.withPackages (
      pypkgs: with pypkgs; [
        dbus-python
        pygobject3
        (toPythonModule ibus)
      ]
    ))
  ];

  postUnpack = ''
    substituteInPlace $sourceRoot/engine/Makefile.am \
      --replace "docbook2man" "docbook2man --sgml"
  '';

  meta = {
    description = "IBus framework for table-based input methods";
    homepage = "https://github.com/kaio/ibus-table/wiki";
    license = lib.licenses.lgpl21;
    maintainers = with lib.maintainers; [ mudri ];
    platforms = lib.platforms.linux;
    mainProgram = "ibus-table-createdb";
    isIbusEngine = true;
  };
}
