{
  lib,
  makeWrapper,
  rustPlatform,
  wineWow64Packages,
  yabridge,
}:

rustPlatform.buildRustPackage {
  pname = "yabridgectl";
  version = yabridge.version;
  src = yabridge.src;

  patches = [
    # Patch yabridgectl to search for the chainloader through NIX_PROFILES
    ./chainloader-from-nix-profiles.patch

    # Dependencies are hardcoded in yabridge, so the check is unnecessary and likely incorrect
    ./remove-dependency-verification.patch
  ];

  nativeBuildInputs = [ makeWrapper ];
  cargoHash = "sha256-VcBQxKjjs9ESJrE4F1kxEp4ah3j9jiNPq/Kdz/qPvro=";

  postFixup = ''
    wrapProgram "$out/bin/yabridgectl" \
      --prefix PATH : ${
        lib.makeBinPath [
          wineWow64Packages.yabridge # winedump
        ]
      }
  '';

  patchFlags = [ "-p3" ];
  sourceRoot = "${yabridge.src.name}/tools/yabridgectl";

  meta = {
    description = "Small, optional utility to help set up and update yabridge for several directories at once";
    homepage = "${yabridge.src.meta.homepage}/tree/${yabridge.version}/tools/yabridgectl";
    changelog = yabridge.meta.changelog;
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ kira-bruneau ];
    platforms = yabridge.meta.platforms;
    mainProgram = "yabridgectl";
  };
}
