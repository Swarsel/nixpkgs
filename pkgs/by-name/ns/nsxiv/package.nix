{
  lib,
  stdenv,
  fetchFromCodeberg,
  giflib,
  imlib2Full,
  libexif,
  libinotify-kqueue,
  libwebp,
  libxft,
  conf ? null,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "nsxiv";
  version = "34";

  src = fetchFromCodeberg {
    owner = "nsxiv";
    repo = "nsxiv";
    rev = "v${finalAttrs.version}";
    hash = "sha256-Yv5Px72iZWLtix0K7Tbzhkar7ZBSb121cBzMhkAZhak=";
  };

  outputs = [
    "out"
    "man"
    "doc"
  ];

  postPatch = lib.optionalString (conf != null) ''
    cp ${(builtins.toFile "config.def.h" conf)} config.def.h
  '';

  buildInputs = [
    giflib
    imlib2Full
    libxft
    libexif
    libwebp
  ]
  ++ lib.optional stdenv.hostPlatform.isDarwin libinotify-kqueue;

  makeFlags = [ "CC:=$(CC)" ];
  env.NIX_LDFLAGS = lib.optionalString stdenv.hostPlatform.isDarwin "-linotify";
  installFlags = [ "PREFIX=$(out)" ];
  installTargets = [ "install-all" ];

  meta = {
    description = "New Suckless X Image Viewer";

    longDescription = ''
      nsxiv is a fork of now unmaintained sxiv with the purpose of being a
      drop-in replacement of sxiv, maintaining it and adding simple, sensible
      features, like:

      - Basic image operations, e.g. zooming, panning, rotating
      - Customizable key and mouse button mappings (in config.h)
      - Script-ability via key-handler
      - Thumbnail mode: grid of selectable previews of all images
      - Ability to cache thumbnails for fast re-loading
      - Basic support for animated/multi-frame images (GIF/WebP)
      - Display image information in status bar
      - Display image name/path in X title
    '';

    homepage = "https://nsxiv.codeberg.page/";
    changelog = "https://codeberg.org/nsxiv/nsxiv/src/tag/${finalAttrs.src.rev}/etc/CHANGELOG.md";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ sikmir ];
    platforms = lib.platforms.unix;
    mainProgram = "nsxiv";
  };
})
