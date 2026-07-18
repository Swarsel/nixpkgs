{
  lib,
  stdenv,
  fetchFromGitHub,
  installShellFiles,
  libusb1,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "mouse_m908";
  version = "3.5";

  src = fetchFromGitHub {
    owner = "dokutan";
    repo = "mouse_m908";
    rev = "v${finalAttrs.version}";
    hash = "sha256-wuYttLCLw0XJ56Xur1aVPpNq9AcsLp2/NADRsVXTugM=";
  };

  nativeBuildInputs = [
    pkg-config
    installShellFiles
  ];

  buildInputs = [ libusb1 ];

  # Uses proper nix directories rather than the ones specified in the makefile
  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin \
      $out/share/doc \
      $out/share/doc/mouse_m908 \
      $out/lib/udev/rules.d

    cp mouse_m908 $out/bin/mouse_m908
    cp mouse_m908.rules $out/lib/udev/rules.d
    cp examples/* $out/share/doc/mouse_m908
    cp README.md $out/share/doc/mouse_m908
    cp keymap.md $out/share/doc/mouse_m908
    installManPage mouse_m908.1

    runHook postInstall
  '';

  doInstallCheck = true;

  meta = {
    description = "Control various Redragon gaming mice from Linux, BSD and Haiku";
    homepage = "https://github.com/dokutan/mouse_m908";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ kylelovestoad ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "mouse_m908";
  };
})
