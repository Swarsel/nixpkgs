{
  lib,
  stdenv,
  udevCheckHook,
}:

stdenv.mkDerivation {
  pname = "wooting-udev-rules";
  version = "0-unstable-2024-11-20";
  # Source: https://help.wooting.io/article/147-configuring-device-access-for-wootility-under-linux-udev-rules
  src = [ ./wooting.rules ];

  nativeBuildInputs = [
    udevCheckHook
  ];

  installPhase = ''
    install -Dpm644 $src $out/lib/udev/rules.d/70-wooting.rules
  '';

  doInstallCheck = true;
  dontUnpack = true;

  meta = {
    description = "udev rules that give NixOS permission to communicate with Wooting keyboards";
    homepage = "https://help.wooting.io/article/147-configuring-device-access-for-wootility-under-linux-udev-rules";
    # We think they are so simple that they are uncopyrightable
    license = lib.licenses.publicDomain;

    maintainers = with lib.maintainers; [
      returntoreality
    ];

    platforms = lib.platforms.linux;
  };
}
