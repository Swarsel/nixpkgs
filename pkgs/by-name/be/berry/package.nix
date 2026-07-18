{
  lib,
  stdenv,
  fetchFromGitHub,
  copyDesktopItems,
  fontconfig,
  freetype,
  libx11,
  libxext,
  libxft,
  libxinerama,
  makeDesktopItem,
  pkg-config,
  which,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "berry";
  version = "0.1.13";

  src = fetchFromGitHub {
    owner = "JLErvin";
    repo = "berry";
    rev = finalAttrs.version;
    hash = "sha256-BMK5kZVoYTUA7AFZc/IVv4rpbn893b/QYXySuPAz2Z8=";
  };

  outputs = [
    "out"
    "man"
  ];

  postPatch = ''
    sed -i --regexp-extended 's/(pkg_verstr=").*(")/\1${finalAttrs.version}\2/' configure
  '';

  strictDeps = true;

  nativeBuildInputs = [
    copyDesktopItems
    pkg-config
    which
  ];

  buildInputs = [
    libx11
    libxext
    libxft
    libxinerama
    fontconfig
    freetype
  ];

  env.NIX_CFLAGS_COMPILE = lib.optionalString stdenv.hostPlatform.isDarwin "-D_C99_SOURCE";

  preConfigure = ''
    patchShebangs configure
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [ "Utility" ];
      comment = "A healthy, bite-sized window manager";
      desktopName = "Berry Window Manager";
      exec = "berry";
      genericName = "Berry Window Manager";
      name = "berry";
    })
  ];

  meta = {
    inherit (libx11.meta) platforms;
    description = "Healthy, bite-sized window manager";

    longDescription = ''
      berry is a healthy, bite-sized window manager written in C for unix
      systems. Its main features include:

      - Controlled via a powerful command-line client, allowing users to control
        windows via a hotkey daemon such as sxhkd or expand functionality via
        shell scripts.
      - Small, hackable source code.
      - Extensible themeing options with double borders, title bars, and window
        text.
      - Intuitively place new windows in unoccupied spaces.
      - Virtual desktops.
    '';

    homepage = "https://berrywm.org/";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "berry";
  };
})
