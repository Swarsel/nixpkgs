{
  lib,
  stdenv,
  fetchFromGitLab,
  autoreconfHook,
  libx11,
  libxaw,
  libxmu,
  libxt,
  nix-update-script,
  pkg-config,
  util-macros,
  wrapWithXFileSearchPathHook,
  xorgproto,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "xload";
  version = "1.2.0";

  src = fetchFromGitLab {
    owner = "app";
    repo = "xload";
    tag = "xload-${finalAttrs.version}";
    hash = "sha256-Mm09uKP+LUW0xGrwcJth/XCUqJ1RDEspbYpL92vOdk4=";
    domain = "gitlab.freedesktop.org";
    group = "xorg";
  };

  strictDeps = true;

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
    util-macros
    wrapWithXFileSearchPathHook
  ];

  buildInputs = [
    libx11
    libxaw
    libxmu
    xorgproto
    libxt
  ];

  installFlags = [ "appdefaultdir=$out/share/X11/app-defaults" ];
  passthru.updateScript = nix-update-script { extraArgs = [ "--version-regex=xload-(.*)" ]; };

  meta = {
    description = "System load average display for X";

    longDescription = ''
      xload displays a periodically updating histogram of the system load average.
    '';

    homepage = "https://gitlab.freedesktop.org/xorg/app/xload";

    license = with lib.licenses; [
      x11
      mit
    ];

    maintainers = [ ];
    platforms = lib.platforms.unix;
    mainProgram = "xload";
  };
})
