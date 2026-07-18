{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  curl,
  libxml2,
  lua5_4,
  nix-update-script,
  openssl,
  pkg-config,
  versionCheckHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "nbfc-linux";
  version = "0.5.2";

  src = fetchFromGitHub {
    owner = "nbfc-linux";
    repo = "nbfc-linux";
    tag = finalAttrs.version;
    hash = "sha256-468/dFRjEgyJ0AW98wKq04WKZ4sZyzswBASSF6hyjVY=";
  };

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs = [
    lua5_4
    curl
    libxml2
    openssl
  ];

  configureFlags = [
    "--bindir=${placeholder "out"}/bin"
  ];

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "C port of Stefan Hirschmann's NoteBook FanControl";

    longDescription = ''
      nbfc-linux provides fan control service for notebooks
    '';

    homepage = "https://github.com/nbfc-linux/nbfc-linux";
    license = lib.licenses.gpl3Only;

    maintainers = with lib.maintainers; [
      Celibistrial
      bohanubis
    ];

    platforms = lib.platforms.linux;
    mainProgram = "nbfc";
  };
})
