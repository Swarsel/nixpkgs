{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchpatch2,
  fontconfig,
  gettext,
  groff,
  libsm,
  libx11,
  libxext,
  libxft,
  libxinerama,
  libxrandr,
  lua,
  makeWrapper,
  pkg-config,
  readline,
  which,
  xmessage,
  xterm,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "notion";
  version = "4.0.4";

  src = fetchFromGitHub {
    owner = "raboof";
    repo = "notion";
    tag = finalAttrs.version;
    hash = "sha256-L7WL8zn1Qkf5sqrhqZJqFe4B1l9ULXI3pt3Jpc87huk=";
  };

  outputs = [
    "out"
    "man"
  ];

  patches = [
    # GCC 15 fix
    (fetchpatch2 {
      hash = "sha256-+4GGeY2j7B54Ffw5gFNpG4704Egc7rA6w5z0sZG8210=";
      url = "https://github.com/raboof/notion/commit/89c92f49abfeae1168ad343d4f529a52d0edd78c.patch?full_index=1";
    })
  ];

  strictDeps = true;

  nativeBuildInputs = [
    gettext
    groff
    lua
    makeWrapper
    pkg-config
    which
  ];

  buildInputs = [
    fontconfig
    libsm
    libx11
    libxext
    libxft
    libxinerama
    libxrandr
    lua
    readline
  ];

  makeFlags = [
    "NOTION_RELEASE=${finalAttrs.version}"
    "PREFIX=${placeholder "out"}"
  ];

  buildFlags = [
    "LUA_DIR=${lua}"
    "X11_PREFIX=/no-such-path"
  ];

  postInstall = ''
    wrapProgram $out/bin/notion \
      --prefix PATH ":" "${
        lib.makeBinPath [
          xmessage
          xterm
        ]
      }"
  '';

  meta = {
    description = "Tiling tabbed window manager";
    homepage = "https://notionwm.net";
    license = lib.licenses.lgpl21;

    maintainers = with lib.maintainers; [
      raboof
      NotAShelf
    ];

    platforms = lib.platforms.linux;
    mainProgram = "notion";
  };
})
