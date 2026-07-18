{
  lib,
  stdenv,
  autoreconfHook,
  fetchFromCodeberg,
  gtkmm3,
  pkg-config,
  versionCheckHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "litemdview";
  version = "0.0.32";

  src = fetchFromCodeberg {
    owner = "g0tsu";
    repo = "litemdview";
    rev = "litemdview-${finalAttrs.version}";
    hash = "sha256-XGjP+7i3mYCEzPYwVY+75DARdXJFY4vUWHFpPeoNqAE=";
  };

  patches = [
    ./fix-gcc15.patch
  ];

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs = [
    gtkmm3
  ];

  # Required for build with gcc-14
  env.NIX_CFLAGS_COMPILE = "-Wno-error=implicit-int";
  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  enableParallelBuilding = true;

  meta = {
    description = "Suckless markdown viewer";

    longDescription = ''
      LiteMDview is a lightweight, extremely fast markdown viewer with lots of useful features. One of them is ability to use your prefered text editor to edit markdown files, every time you save the file, litemdview reloads those changes (I call it live-reload). It has a convinient navigation through local directories, has support for a basic "git-like" folders hierarchy as well as vimwiki projects.

      Features:


        - Does not use any of those bloated gecko(servo)-blink engines
        - Lightweight and fast
        - Live reload
        - Convinient key bindings
        - Supports text zooming
        - Supports images
        - Supports links
        - Navigation history
        - Cool name which associates with 1337, at least for me :)
        - Builtin markdown css themes
        - Supports emoji™️
        - vimwiki support
        - Basic html support (very simple offline documents in html)
        - Syntax highlighting
    '';

    homepage = "https://codeberg.org/g0tsu/litemdview";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ WhiteBlackGoose ];
    platforms = lib.platforms.linux;
    mainProgram = "litemdview";
  };
})
