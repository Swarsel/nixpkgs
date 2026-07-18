{
  lib,
  stdenv,
  fetchFromGitHub,
  libxft,
  libxinerama,
  libxrandr,
  nix-update-script,
  pkg-config,
  versionCheckHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "xosd-xft";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "kdmurthy";
    repo = "libxosd-xft";
    tag = finalAttrs.version;
    hash = "sha256-hsI7KMDmqGoGExSI3K7JiKNoiwZMNLubekuEEgkmQTg=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    libxft
    libxrandr
    libxinerama
  ];

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  versionCheckProgram = "${placeholder "out"}/bin/osd-echo";
  versionCheckProgramArg = "--help";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Show text content with Xft/TTF fonts on X11 display";
    homepage = "https://github.com/kdmurthy/libxosd-xft";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ ulysseszhan ];
    platforms = lib.platforms.linux;
  };
})
