{
  lib,
  stdenv,
  fetchFromGitHub,
  hidapi,
  nix-update-script,
  pkg-config,
  udev,
  versionCheckHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "hidapitester";
  version = "0.6";

  src = fetchFromGitHub {
    owner = "todbot";
    repo = "hidapitester";
    tag = "v${finalAttrs.version}";
    hash = "sha256-WqyAaoiiuHbLAgfGpl4M3AHyWFl8KPGA/OaO2E/uix0=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    udev
    hidapi
  ];

  env.HIDAPITESTER_VERSION = finalAttrs.version;

  installPhase = ''
    runHook preInstall
    install -Dm755 hidapitester $out/bin/hidapitester
    runHook postInstall
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  postUnpack = ''
    cp --no-preserve=mode -r ${hidapi.src} hidapi
    export HIDAPI_DIR=$PWD/hidapi
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Simple command-line program to test HIDAPI";
    homepage = "https://github.com/todbot/hidapitester";
    changelog = "https://github.com/todbot/hidapitester/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ lykos153 ];
    mainProgram = "hidapitester";
  };
})
