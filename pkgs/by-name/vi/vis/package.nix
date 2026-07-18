{
  lib,
  stdenv,
  fetchFromGitHub,
  acl,
  copyDesktopItems,
  libselinux,
  libtermkey,
  lua,
  makeDesktopItem,
  makeWrapper,
  ncurses,
  pkg-config,
  tre,
}:

let
  luaEnv = lua.withPackages (ps: [ ps.lpeg ]);
in
stdenv.mkDerivation rec {
  pname = "vis";
  version = "0.9";

  src = fetchFromGitHub {
    owner = "martanne";
    repo = "vis";
    rev = "v${version}";
    hash = "sha256-SYM3zlzhp3NdyOjtXc+pOiWY4/WA/Ax+qAWe18ggq3g=";
  };

  nativeBuildInputs = [
    pkg-config
    makeWrapper
    copyDesktopItems
  ];

  buildInputs = [
    ncurses
    libtermkey
    luaEnv
    tre
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    acl
    libselinux
  ];

  postInstall = ''
    wrapProgram $out/bin/vis \
      --prefix LUA_CPATH ';' "${luaEnv}/lib/lua/${lua.luaversion}/?.so" \
      --prefix LUA_PATH ';' "${luaEnv}/share/lua/${lua.luaversion}/?.lua" \
      --prefix VIS_PATH : "\$HOME/.config:$out/share/vis"
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [
        "Application"
        "Development"
        "IDE"
      ];

      comment = meta.description;
      desktopName = "vis";
      exec = "vis %U";
      genericName = "Text editor";
      icon = "accessories-text-editor";

      mimeTypes = [
        "text/plain"
        "application/octet-stream"
      ];

      name = "vis";
      startupNotify = false;
      terminal = true;
      type = "Application";
    })
  ];

  meta = {
    description = "Vim like editor";
    homepage = "https://github.com/martanne/vis";
    license = lib.licenses.isc;
    maintainers = with lib.maintainers; [ ramkromberg ];
    platforms = lib.platforms.unix;
    mainProgram = "vis";
  };
}
