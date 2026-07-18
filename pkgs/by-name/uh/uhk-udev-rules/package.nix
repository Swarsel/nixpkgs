{
  lib,
  stdenv,
  udevCheckHook,
  uhk-agent,
}:

stdenv.mkDerivation {
  inherit (uhk-agent) version;
  pname = "uhk-udev-rules";

  nativeBuildInputs = [
    udevCheckHook
  ];

  installPhase = ''
    runHook preInstall
    install -D -m 644 ${uhk-agent.out}/opt/uhk-agent/rules/50-uhk60.rules $out/lib/udev/rules.d/50-uhk60.rules
    runHook postInstall
  '';

  doInstallCheck = true;
  dontBuild = true;
  dontUnpack = true;

  meta = {
    inherit (uhk-agent.meta) license;
    description = "udev rules for UHK keyboards from https://ultimatehackingkeyboard.com";
  };
}
