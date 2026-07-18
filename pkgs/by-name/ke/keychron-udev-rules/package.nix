{
  lib,
  stdenvNoCC,
  udevCheckHook,
  writeTextFile,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "keychron-udev-rules";
  version = "0-unstable-2026-01-07";

  src = writeTextFile {
    name = "69-keychron.rules";

    text = ''
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="3434", MODE="0660", TAG+="uaccess"
      KERNEL=="event*", SUBSYSTEM=="input", ENV{ID_VENDOR_ID}=="3434", ENV{ID_INPUT_JOYSTICK}=="*?", ENV{ID_INPUT_JOYSTICK}=""
    '';
  };

  nativeBuildInputs = [ udevCheckHook ];

  installPhase = ''
    runHook preInstall
    install -Dm644 $src $out/lib/udev/rules.d/69-keychron.rules
    runHook postInstall
  '';

  dontBuild = true;
  dontConfigure = true;
  dontFixup = true;
  dontUnpack = true;

  meta = {
    description = "Keychron Keyboard Udev Rules, fixes issues with keyboard detection on Linux & permissions on Keychron Launcher";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ kruziikrel13 ];
    platforms = lib.platforms.linux;
  };
})
