{
  lib,
  stdenv,
  fetchFromGitLab,
  qmake,
  qtbase,
  wrapQtAppsHook,
}:

stdenv.mkDerivation rec {
  pname = "nemo-qml-plugin-dbus";
  version = "2.1.24";

  src = fetchFromGitLab {
    owner = "mer-core";
    repo = "nemo-qml-plugin-dbus";
    rev = version;
    sha256 = "1ilg929456d3k0xkvxa5r4k7i4kkw9i8kgah5xx1yq0d9wka0l77";
    domain = "git.sailfishos.org";
  };

  postPatch = ''
    substituteInPlace dbus.pro --replace ' tests' ""
    substituteInPlace src/nemo-dbus/nemo-dbus.pro \
      --replace /usr $out \
      --replace '$$[QT_INSTALL_LIBS]' $out'/lib'
    substituteInPlace src/plugin/plugin.pro \
      --replace '$$[QT_INSTALL_QML]' $out'/${qtbase.qtQmlPrefix}'
  '';

  nativeBuildInputs = [
    qmake
    wrapQtAppsHook
  ];

  meta = {
    description = "Nemo DBus plugin for qml";
    homepage = "https://git.sailfishos.org/mer-core/nemo-qml-plugin-dbus/";
    license = lib.licenses.lgpl2Only;
    maintainers = [ lib.maintainers.Thra11 ];
    platforms = lib.platforms.linux;
  };
}
