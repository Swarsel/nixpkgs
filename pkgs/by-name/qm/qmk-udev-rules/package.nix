{
  lib,
  stdenv,
  fetchFromGitHub,
  udevCheckHook,
}:

## Usage
# In NixOS, set hardware.keyboard.qmk.enable = true;

stdenv.mkDerivation (finalAttrs: {
  pname = "qmk-udev-rules";
  version = "0.27.13";

  src = fetchFromGitHub {
    owner = "qmk";
    repo = "qmk_firmware";
    tag = finalAttrs.version;
    hash = "sha256-Zs508OQ0RYCg0f9wqR+VXUmVvhP/jCA3piwRq2ZpR84=";
  };

  nativeBuildInputs = [
    udevCheckHook
  ];

  installPhase = ''
    runHook preInstall

    install -D util/udev/50-qmk.rules $out/lib/udev/rules.d/50-qmk.rules

    runHook postInstall
  '';

  doInstallCheck = true;
  dontBuild = true;

  meta = {
    description = "Official QMK udev rules list";
    homepage = "https://github.com/qmk/qmk_firmware";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ miniharinn ];
    platforms = lib.platforms.linux;
  };
})
