{
  lib,
  fetchFromGitHub,
  libx11,
  libxi,
  libxkbcommon,
  libxtst,
  nix-update-script,
  pkg-config,
  rustPlatform,
  versionCheckHook,
  xdotool,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "snipt";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "snipt";
    repo = "snipt";
    tag = "v${finalAttrs.version}";
    hash = "sha256-UMsoTJtpS4vInviDdCrnZQk2scYHM/5a8l7/HK+o8Tc=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    libx11
    libxi
    libxtst
    xdotool
    libxkbcommon
  ];

  cargoHash = "sha256-mtw9mdUDxYhZcncTves0FH6COvRNVaMZOdapy3VEZrk=";
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  __structuredAttrs = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Powerful text snippet expansion tool";

    longDescription = ''
      Snipt is a powerful text snippet expansion tool that boosts your productivity
      by replacing short text shortcuts with longer content.
      Just type a prefix (like `:`) followed by your shortcut,
      and snipt automatically expands it into your predefined text.
    '';

    homepage = "https://github.com/snipt/snipt";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ chillcicada ];
    platforms = lib.platforms.unix;
    mainProgram = "snipt";
  };
})
