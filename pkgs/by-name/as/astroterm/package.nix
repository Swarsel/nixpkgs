{
  lib,
  stdenv,
  fetchurl,
  fetchFromGitHub,
  argtable,
  meson,
  ncurses,
  ninja,
  nix-update-script,
  versionCheckHook,
  xxd,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "astroterm";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "da-luce";
    repo = "astroterm";
    tag = "v${finalAttrs.version}";
    hash = "sha256-u0UKYoZCDClRmG12czmm0rmOcy3nruarSyjdh8Lu2dw=";
  };

  postPatch = ''
    mkdir -p data
    ln -s ${finalAttrs.bsc5File} data/bsc5
  '';

  nativeBuildInputs = [
    meson
    ninja
    xxd
  ];

  buildInputs = [
    argtable
    ncurses
  ];

  doCheck = true;
  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  bsc5File = fetchurl {
    hash = "sha256-5HHQLq9O7LYcEvh5octkMrqde2ipqMVlSh60KgyMw0A=";
    url = "https://web.archive.org/web/20231007085824/http://tdc-www.harvard.edu/catalogs/BSC5";
  };

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Celestial viewer for the terminal, written in C";
    homepage = "https://github.com/da-luce/astroterm/";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.da-luce ];
    platforms = lib.platforms.unix;
    mainProgram = "astroterm";
  };
})
