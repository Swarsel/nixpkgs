{
  lib,
  stdenv,
  fetchFromCodeberg,
  libxcrypt,
  libxkbcommon,
  nix-update-script,
  pkg-config,
  versionCheckHook,
  wayland,
  wayland-protocols,
  wayland-scanner,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "wlock";
  version = "1.0";

  src = fetchFromCodeberg {
    owner = "sewn";
    repo = "wlock";
    tag = finalAttrs.version;
    hash = "sha256-vbGrePrZN+IWwzwoNUzMHmb6k9nQbRLVZmbWIAsYneY=";
  };

  postPatch = ''
    substituteInPlace Makefile --replace-fail 'chmod 4755' 'chmod 755'
  '';

  strictDeps = true;

  nativeBuildInputs = [
    pkg-config
    wayland-scanner
  ];

  buildInputs = [
    wayland
    wayland-protocols
    libxkbcommon
    libxcrypt
  ];

  makeFlags = [
    "PREFIX=$(out)"
    ("WAYLAND_SCANNER=" + lib.getExe wayland-scanner)
  ];

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  versionCheckProgramArg = "-v";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Sessionlocker for Wayland compositors that support the ext-session-lock-v1 protocol";
    homepage = "https://codeberg.org/sewn/wlock";
    license = lib.licenses.gpl3Only;

    maintainers = with lib.maintainers; [
      fliegendewurst
      yiyu
    ];

    platforms = lib.platforms.linux;
    mainProgram = "wlock";
  };
})
