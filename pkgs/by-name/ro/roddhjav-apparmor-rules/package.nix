{
  lib,
  fetchFromGitHub,
  stdenvNoCC,
  unstableGitUpdater,
}:

stdenvNoCC.mkDerivation {
  pname = "roddhjav-apparmor-rules";
  version = "0-unstable-2025-10-25";

  src = fetchFromGitHub {
    owner = "roddhjav";
    repo = "apparmor.d";
    rev = "6aaa6e79183d489c84f9baad821354e72b322c46";
    hash = "sha256-fDjajIA06USViGWNKvnqg2V6dc1Hzqt/9q8PbKWvKxA=";
  };

  installPhase = ''
    runHook preInstall
    mkdir -p $out/etc/apparmor.d
    cp -r apparmor.d/* $out/etc/apparmor.d
    runHook postInstall
  '';

  dontBuild = true;
  dontConfigure = true;
  passthru.updateScript = unstableGitUpdater { };

  meta = {
    description = "Over 1500 AppArmor profiles aiming to confine most linux processes";

    longDescription = ''
      AppArmor.d is a set of over 1500 AppArmor profiles whose aim is to confine
      most Linux based applications and processes. Confines all system services, user services
      and most desktop environments. Currently supported DEs are GNOME, KDE and XFCE (partial).
      If your DE is not listed in https://github.com/roddhjav/apparmor.d
      Do not use this, else it may break your system.
    '';

    homepage = "https://github.com/roddhjav/apparmor.d";
    license = lib.licenses.gpl2;

    maintainers = with lib.maintainers; [
      johnrtitor
    ];

    platforms = lib.platforms.linux;
  };
}
