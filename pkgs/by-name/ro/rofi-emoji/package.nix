{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  cairo,
  glib,
  libnotify,
  makeWrapper,
  nix-update-script,
  pkg-config,
  rofi-unwrapped,
  wl-clipboard,
  wtype,
  xclip,
  xdotool,
  waylandSupport ? true,
  x11Support ? true,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "rofi-emoji";
  version = "4.1.0";

  src = fetchFromGitHub {
    owner = "Mange";
    repo = "rofi-emoji";
    rev = "v${finalAttrs.version}";
    hash = "sha256-Amaz+83mSPue+pjZq/pJiCxu5QczYvmJk6f96eraaK8=";
  };

  patches = [
    # Look for plugin-related files in $out/lib/rofi
    ./0001-Patch-plugindir-to-output.patch
  ];

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
    makeWrapper
  ];

  buildInputs = [
    cairo
    glib
    rofi-unwrapped
  ];

  postFixup = ''
    wrapProgram $out/share/rofi-emoji/clipboard-adapter.sh \
     --prefix PATH ":" ${
       lib.makeBinPath (
         [
           libnotify
         ]
         ++ lib.optionals waylandSupport [
           wl-clipboard
           wtype
         ]
         ++ lib.optionals x11Support [
           xclip
           xdotool
         ]
       )
     }
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Emoji selector plugin for Rofi";
    homepage = "https://github.com/Mange/rofi-emoji";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      cole-h
      Mange
    ];

    platforms = lib.platforms.linux;
  };
})
