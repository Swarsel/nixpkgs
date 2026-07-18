{
  lib,
  stdenv,
  fetchFromGitHub,
  fontconfig,
  imlib2,
  libx11,
  libxext,
  libxft,
  libxinerama,
  libxrender,
  writeText,
  conf ? null,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "pmenu";
  version = "3.1.1";

  src = fetchFromGitHub {
    owner = "phillbush";
    repo = "pmenu";
    rev = "v${finalAttrs.version}";
    hash = "sha256-7NI5az3LxOYEnsts8Qqi3gvO3dXpNjPDOTW2c5Y25Lc=";
  };

  postPatch =
    let
      configFile =
        if lib.isDerivation conf || builtins.isPath conf then conf else writeText "config.h" conf;
    in
    lib.optionalString (conf != null) "mv ${configFile} config.h";

  buildInputs = [
    fontconfig
    imlib2
    libx11
    libxext
    libxft
    libxinerama
    libxrender
  ];

  makeFlags = [
    "INSTALL=install"
    "PREFIX=\${out}"
  ];

  meta = {
    description = "Pie-menu tool";

    longDescription = ''
      πmenu is a pie menu utility for X. πmenu receives a menu specification in
      stdin, shows a menu for the user to select one of the options, and outputs
      the option selected to stdout.
    '';

    homepage = "https://github.com/phillbush/pmenu";
    changelog = "https://github.com/phillbush/pmenu/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = [ ];
    platforms = lib.platforms.unix;
    mainProgram = "pmenu";
    # The last successful Darwin Hydra build was in 2023
    broken = stdenv.hostPlatform.isDarwin;
  };
})
