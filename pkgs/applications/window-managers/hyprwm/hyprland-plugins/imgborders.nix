{
  lib,
  cmake,
  fetchFromCodeberg,
  mkHyprlandPlugin,
  nix-update-script,
}:
mkHyprlandPlugin (finalAttrs: {
  version = "1.0.1";

  src = fetchFromCodeberg {
    owner = "zacoons";
    repo = "imgborders";
    tag = finalAttrs.version;
    hash = "sha256-fCzz4gh8pd7J6KQJB/avYcS0Z7NYpxjznPMtOwypPSQ=";
  };

  nativeBuildInputs = [
    cmake
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib
    mv imgborders.so $out/lib/libimgborders.so

    runHook postInstall
  '';

  pluginName = "imgborders";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Add tiling image borders to windows!";
    homepage = "https://codeberg.org/zacoons/imgborders";
    license = lib.licenses.unlicense;

    maintainers = with lib.maintainers; [
      mrdev023
    ];
  };
})
