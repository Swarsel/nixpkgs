{
  lib,
  stdenv,
  fetchFromGitHub,
  SDL2,
  SDL2_mixer,
  cmake,
  curl,
  doxygen,
  ffmpeg,
  freetype,
  lua,
  makeWrapper,
  # Update
  nix-update-script,
  timidity,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "corsix-th";
  version = "0.69.2";

  src = fetchFromGitHub {
    owner = "CorsixTH";
    repo = "CorsixTH";
    rev = "v${finalAttrs.version}";
    hash = "sha256-Dohql0AJspcnGhoDKvszw84/YKGy7IlIfk4pWvjG+8o=";
  };

  patches = [
    ./darwin-cmake-no-fixup-bundle.patch
  ];

  nativeBuildInputs = [
    cmake
    doxygen
    makeWrapper
  ];

  buildInputs =
    let
      luaEnv = lua.withPackages (
        p: with p; [
          luafilesystem
          lpeg
          luasec
          luasocket
        ]
      );
    in
    [
      curl
      ffmpeg
      freetype
      lua
      luaEnv
      SDL2
      SDL2_mixer
      timidity
    ];

  cmakeFlags = [ "-Wno-dev" ];

  postInstall =
    lib.optionalString stdenv.hostPlatform.isLinux ''
      wrapProgram $out/bin/corsix-th \
      --set LUA_PATH "$LUA_PATH" \
      --set LUA_CPATH "$LUA_CPATH"
    ''
    + lib.optionalString stdenv.hostPlatform.isDarwin ''
      mkdir -p $out/Applications
      mv $out/CorsixTH.app $out/Applications
      wrapProgram $out/Applications/CorsixTH.app/Contents/MacOS/CorsixTH \
        --set LUA_PATH "$LUA_PATH" \
        --set LUA_CPATH "$LUA_CPATH"
    '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Reimplementation of the 1997 Bullfrog business sim Theme Hospital";
    homepage = "https://corsixth.com/";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      hughobrien
      matteopacini
    ];

    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "corsix-th";
  };
})
