{
  lib,
  stdenv,
  fetchFromGitHub,
  boost,
  cmake,
  dconf,
  libdbusmenu,
  libsForQt5,
  makeWrapper,
  openldap,
  zlib,
  client ? false, # build Quassel client
  enableDaemon ? false, # build Quassel daemon
  monolithic ? true, # build monolithic Quassel
  static ? false, # link statically
  tag ? "-kf5", # tag added to the package name
}:

let
  buildClient = monolithic || client;
  buildCore = monolithic || enableDaemon;
in

assert monolithic -> !client && !enableDaemon;
assert client || enableDaemon -> !monolithic;

let
  edf = flag: feature: [ ("-D" + feature + (if flag then "=ON" else "=OFF")) ];

in
stdenv.mkDerivation rec {
  pname = "quassel${tag}";
  version = "0.14.0";

  src = fetchFromGitHub {
    owner = "quassel";
    repo = "quassel";
    rev = version;
    sha256 = "sha256-eulhNcyCmy9ryietOhT2yVJeJH+MMZRbTUo2XuTy9qU=";
  };

  nativeBuildInputs = [
    cmake
    makeWrapper
  ]
  ++ lib.optional buildClient libsForQt5.wrapQtAppsHook;

  buildInputs = [
    libsForQt5.qtbase
    boost
    zlib
  ]
  ++ lib.optionals buildCore [
    libsForQt5.qtscript
    libsForQt5.qca-qt5
    openldap
  ]
  ++ lib.optionals buildClient [
    libdbusmenu
  ];

  cmakeFlags = [
    "-DEMBED_DATA=OFF"
    "-DUSE_QT5=ON"
  ]
  ++ edf static "STATIC"
  ++ edf monolithic "WANT_MONO"
  ++ edf enableDaemon "WANT_CORE"
  ++ edf enableDaemon "WITH_LDAP"
  ++ edf client "WANT_QTCLIENT";

  # Prevent ``undefined reference to `qt_version_tag''' in SSL check
  env.NIX_CFLAGS_COMPILE = "-DQT_NO_VERSION_TAGGING=1";

  postFixup =
    lib.optionalString enableDaemon ''
      wrapProgram "$out/bin/quasselcore" --suffix PATH : "${libsForQt5.qtbase.bin}/bin"
    ''
    + lib.optionalString buildClient ''
      wrapQtApp "$out/bin/quassel${lib.optionalString client "client"}" \
        --prefix GIO_EXTRA_MODULES : "${dconf}/lib/gio/modules"
    '';

  dontWrapQtApps = true;

  meta = {
    inherit (libsForQt5.qtbase.meta) platforms;
    description = "Qt/KDE distributed IRC client supporting a remote daemon";

    longDescription = ''
      Quassel IRC is a cross-platform, distributed IRC client,
      meaning that one (or multiple) client(s) can attach to
      and detach from a central core -- much like the popular
      combination of screen and a text-based IRC client such
      as WeeChat, but graphical (based on Qt4/KDE4 or Qt5/KF5).
    '';

    homepage = "https://quassel-irc.org/";
    license = lib.licenses.gpl3;
    maintainers = [ ];

    mainProgram =
      if monolithic then
        "quassel"
      else if buildClient then
        "quasselclient"
      else
        "quasselcore";
  };
}
