{
  lib,
  stdenv,
  fetchFromGitLab,
  autoreconfHook,
  bison,
  flex,
  libxext,
  libxmu,
  libxp,
  libxpm,
  libxt,
  nix-update-script,
  pkg-config,
  util-macros,
  xorgproto,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libxaw3d";
  version = "1.6.6";

  src = fetchFromGitLab {
    owner = "lib";
    repo = "libxaw3d";
    tag = "libXaw3d-${finalAttrs.version}";
    hash = "sha256-7w5FnvxbztfdH7QPPqvHyJdAhTyNfe0Je4x+J80dJIY=";
    domain = "gitlab.freedesktop.org";
    group = "xorg";
  };

  strictDeps = true;

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
    util-macros
    bison
    flex
  ];

  buildInputs = [
    libxext
    libxpm
  ];

  propagatedBuildInputs = [
    libxmu
    libxt
    xorgproto
  ];

  passthru = {
    updateScript = nix-update-script { extraArgs = [ "--version-regex=libXaw3d-(.*)" ]; };
  };

  meta = {
    description = "3D appearance variant of the X Athena Widget Set";
    homepage = "https://gitlab.freedesktop.org/xorg/lib/libxaw3d";
    license = lib.licenses.mit;
    maintainers = [ ];
    platforms = lib.platforms.unix;
  };
})
