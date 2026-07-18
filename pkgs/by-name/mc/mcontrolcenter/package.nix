{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  copyDesktopItems,
  kmod,
  makeDesktopItem,
  qt6,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "mcontrolcenter";
  version = "0.5.1";

  src = fetchFromGitHub {
    owner = "dmitry-s93";
    repo = "MControlCenter";
    rev = finalAttrs.version;
    hash = "sha256-uWxEWLb2QOZlJ1d3LbORCc81kILB9N+0bzr+xzHAa7Y=";
  };

  postPatch = ''
    substituteInPlace src/helper/helper.cpp \
      --replace-fail "/usr/sbin/modprobe" "${kmod}/bin/modprobe"
    substituteInPlace src/helper/mcontrolcenter.helper.service \
      --replace-fail "/usr" "$out"
  '';

  nativeBuildInputs = [
    qt6.wrapQtAppsHook
    qt6.qttools
    copyDesktopItems
    cmake
  ];

  buildInputs = [
    qt6.qtbase
    kmod
  ];

  installPhase = ''
    runHook preInstall
    install -Dm755 mcontrolcenter $out/bin/mcontrolcenter
    install -Dm755 helper/mcontrolcenter-helper $out/libexec/mcontrolcenter-helper
    install -Dm644 ../resources/mcontrolcenter.svg $out/share/icons/hicolor/scalable/apps/mcontrolcenter.svg
    install -Dm644 ../src/helper/mcontrolcenter-helper.conf $out/share/dbus-1/system.d/mcontrolcenter-helper.conf
    install -Dm644 ../src/helper/mcontrolcenter.helper.service $out/share/dbus-1/system-services/mcontrolcenter.helper.service
    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [ "System" ];
      comment = finalAttrs.meta.description;
      desktopName = "MControlCenter";
      exec = "mcontrolcenter";
      icon = "mcontrolcenter";
      name = "MControlCenter";
    })
  ];

  meta = {
    description = "Tool to change the settings of MSI laptops running Linux";
    homepage = "https://github.com/dmitry-s93/MControlCenter";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.Tommimon ];
    platforms = lib.platforms.linux;
    mainProgram = "mcontrolcenter";
  };
})
