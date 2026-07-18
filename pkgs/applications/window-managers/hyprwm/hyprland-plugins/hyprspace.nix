{
  lib,
  fetchFromGitHub,
  mkHyprlandPlugin,
  nix-update-script,
}:

mkHyprlandPlugin {
  version = "0-unstable-2026-05-28";

  src = fetchFromGitHub {
    owner = "KZDKM";
    repo = "hyprspace";
    rev = "c109256f5a79a8694acd6176971c4a273d32264c";
    hash = "sha256-q+5ETwj+oiZBT9j6/huwB8nwV4nbZdZmCrchL2E7tDQ=";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib
    mv Hyprspace.so $out/lib/libhyprspace.so

    runHook postInstall
  '';

  dontUseCmakeConfigure = true;
  pluginName = "hyprspace";
  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    description = "Workspace overview plugin for Hyprland";
    homepage = "https://github.com/KZDKM/Hyprspace";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ donovanglover ];
    platforms = lib.platforms.linux;
  };
}
