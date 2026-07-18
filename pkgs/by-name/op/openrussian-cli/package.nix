{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchpatch,
  installShellFiles,
  lua5_3,
  makeWrapper,
  mawk,
  pkg-config,
  sqlite,
  unzip,
  wget,
  which,
}:
let
  luaEnv = lua5_3.withPackages (
    p: with p; [
      luasql-sqlite3
      luautf8
    ]
  );
in
stdenv.mkDerivation (finalAttrs: {
  pname = "openrussian-cli";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "rhaberkorn";
    repo = "openrussian-cli";
    rev = finalAttrs.version;
    hash = "sha256-lu13Dd3D4P/7Yol1ixt86BHk86y8DMsbFzfi244+KuY=";
  };

  patches = [
    (fetchpatch {
      hash = "sha256-/z4YrEeuejtCtwiFXksFREwgQoWvtI0Kl9w75KDQfF8=";
      url = "https://github.com/rhaberkorn/openrussian-cli/commit/984e555acbadbd1aed7df17ab53e2c586a2f8f68.patch";
    })
    # Work around https://github.com/dumblob/mysql2sqlite/issues/75
    ./use-mawk.patch
  ];

  nativeBuildInputs = [
    pkg-config
    wget
    unzip
    sqlite
    which
    installShellFiles
    makeWrapper
    mawk
  ];

  buildInputs = [ luaEnv ];

  makeFlags = [
    "LUA=${luaEnv}/bin/lua"
    "LUAC=${luaEnv}/bin/luac"
  ];

  # Can't use "make install" here
  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/share/openrussian
    cp openrussian-sqlite3.db $out/share/openrussian
    cp openrussian $out/bin

    wrapProgram $out/bin/openrussian \
      --prefix LUA_PATH ';' '${lua5_3.pkgs.luaLib.genLuaPathAbsStr luaEnv}' \
      --prefix LUA_CPATH ';' '${lua5_3.pkgs.luaLib.genLuaCPathAbsStr luaEnv}'

    runHook postInstall
  '';

  postInstall = ''
    installShellCompletion --cmd openrussian --bash ./openrussian-completion.bash
    installManPage ./openrussian.1
  '';

  dontConfigure = true;

  meta = {
    description = "Offline Console Russian Dictionary (based on openrussian.org)";
    homepage = "https://github.com/rhaberkorn/openrussian-cli";

    license = with lib.licenses; [
      gpl3Only
      mit
      cc-by-sa-40
    ];

    maintainers = with lib.maintainers; [ zane ];
    platforms = lib.platforms.unix;
    mainProgram = "openrussian";
  };
})
