{
  lib,
  fetchFromGitHub,
  bash,
  nix-update-script,
  stdenvNoCC,
  udevCheckHook,
}:

stdenvNoCC.mkDerivation {
  pname = "steam-devices-udev-rules";
  version = "1.0.0.61-unstable-2026-06-25";

  src = fetchFromGitHub {
    owner = "ValveSoftware";
    repo = "steam-devices";
    rev = "22ec85e5ff5ea2e15c56d71a41bcbef46356cd60";
    hash = "sha256-nHPvyZlafkN1K0pKY2DsdOT0QviPg0rXmXrc+Wm6qio=";
  };

  nativeBuildInputs = [
    udevCheckHook
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/udev/rules.d/
    cp *.rules $out/lib/udev/rules.d/
    substituteInPlace $out/lib/udev/rules.d/*.rules --replace-warn "/bin/sh" "${bash}/bin/sh"

    runHook postInstall
  '';

  doInstallCheck = true;
  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    description = "Udev rules list for gaming devices";
    homepage = "https://github.com/ValveSoftware/steam-devices";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      azuwis
      yuannan
    ];

    platforms = lib.platforms.linux;
  };
}
