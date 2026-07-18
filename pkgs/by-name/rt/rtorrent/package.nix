{
  lib,
  stdenv,
  fetchFromGitHub,
  _experimental-update-script-combinators,
  autoreconfHook,
  cppunit,
  curl,
  installShellFiles,
  libtool,
  libtorrent-rakshasa,
  lua5_4_compat,
  ncurses,
  nix-update-script,
  nixosTests,
  openssl,
  pkg-config,
  versionCheckHook,
  writableTmpDirAsHomeHook,
  zlib,
  withLua ? false,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "rtorrent";
  version = "0.16.17";

  src = fetchFromGitHub {
    owner = "rakshasa";
    repo = "rtorrent";
    tag = "v${finalAttrs.version}";
    hash = "sha256-pFEUbxrruP4Zq9WdlnBSmE6Fe95jpZ88x3md5jzytO4=";
  };

  outputs = [
    "out"
    "man"
  ];

  strictDeps = true;

  nativeBuildInputs = [
    autoreconfHook
    installShellFiles
    pkg-config
    writableTmpDirAsHomeHook
  ];

  buildInputs = [
    cppunit
    curl
    libtool
    libtorrent-rakshasa
    ncurses
    openssl
    zlib
  ]
  ++ lib.optionals withLua [ lua5_4_compat ];

  configureFlags = [
    "--with-xmlrpc-tinyxml2"
    "--with-posix-fallocate"
  ]
  ++ lib.optionals withLua [ "--with-lua" ];

  postInstall = ''
    installManPage doc/old/rtorrent.1
    install -Dm644 doc/rtorrent.rc-example -t $out/share/doc/rtorrent/rtorrent.rc
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  __structuredAttrs = true;
  enableParallelBuilding = true;
  versionCheckKeepEnvironment = [ "HOME" ];
  versionCheckProgramArg = "-h";

  passthru = {
    inherit libtorrent-rakshasa;
    tests = { inherit (nixosTests) rtorrent; };

    updateScript = _experimental-update-script-combinators.sequence [
      (nix-update-script { attrPath = "libtorrent-rakshasa"; })
      (nix-update-script { })
    ];
  };

  meta = {
    description = "Ncurses client for libtorrent, ideal for use with screen, tmux, or dtach";
    homepage = "https://rakshasa.github.io/rtorrent/";
    license = lib.licenses.gpl2Plus;

    maintainers = with lib.maintainers; [
      thiagokokada
    ];

    platforms = lib.platforms.unix;
    mainProgram = "rtorrent";
  };
})
