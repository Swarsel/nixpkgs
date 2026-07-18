{
  lib,
  stdenv,
  fetchFromGitLab,
  autoreconfHook,
  fontconfig,
  libxaw,
  libxft,
  libxkbfile,
  libxmu,
  libxrender,
  libxt,
  nix-update-script,
  pkg-config,
  util-macros,
  wrapWithXFileSearchPathHook,
  xorgproto,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "xfd";
  version = "1.1.5";

  src = fetchFromGitLab {
    owner = "app";
    repo = "xfd";
    tag = "xfd-${finalAttrs.version}";
    hash = "sha256-mdDnS6315po8/DafpGJDzGJTPV0HsRbSLlqSaN11d6o=";
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
    fontconfig
    libxaw
    libxft
    libxkbfile
    libxmu
    libxrender
    libxt
    xorgproto
  ];

  installFlags = [ "appdefaultdir=$out/share/X11/app-defaults" ];
  passthru.updateScript = nix-update-script { extraArgs = [ "--version-regex=xfd-(.*)" ]; };

  meta = {
    description = "X font display utility, using either the X11 core protocol or libxft.";
    homepage = "https://gitlab.freedesktop.org/xorg/app/xfd";
    license = lib.licenses.mitOpenGroup;
    maintainers = [ ];
    platforms = lib.platforms.unix;
    mainProgram = "xfd";
  };
})
