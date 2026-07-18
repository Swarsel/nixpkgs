{
  lib,
  stdenv,
  fetchFromGitHub,
  curl,
  nix-update-script,
  pkg-config,
  wrapGAppsHook3,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "sgdboop";
  version = "1.3.2";

  src = fetchFromGitHub {
    owner = "SteamGridDB";
    repo = "SGDBoop";
    tag = "v${finalAttrs.version}";
    hash = "sha256-/pXZMq80fb7Z+619ACnu/ZYWpouh59PIiruWY7l2cnQ=";
  };

  postPatch = ''
    substituteInPlace Makefile \
      --replace-fail "/app/" "$out/"
  '';

  nativeBuildInputs = [
    pkg-config
    wrapGAppsHook3
  ];

  buildInputs = [
    curl
  ];

  makeFlags = [
    # The flatpak install just copies things to /app - otherwise wants to do things with XDG
    "FLATPAK_ID=fake"
  ];

  postInstall = ''
    rm -r "$out/share/metainfo"
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Applying custom artwork to Steam, using SteamGridDB";
    homepage = "https://github.com/SteamGridDB/SGDBoop/";
    license = lib.licenses.zlib;

    maintainers = with lib.maintainers; [
      saturn745
      fazzi
    ];

    platforms = lib.platforms.linux;
    mainProgram = "SGDBoop";
  };
})
