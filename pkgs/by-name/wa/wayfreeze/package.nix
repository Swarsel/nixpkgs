{
  lib,
  fetchFromGitHub,
  libxkbcommon,
  nix-update-script,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "wayfreeze";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "Jappie3";
    repo = "wayfreeze";
    tag = finalAttrs.version;
    hash = "sha256-jz77zWCUUcXiLdCQpta1b1dlEZaahkhYfhnHUa/Zk2A=";
  };

  buildInputs = [
    libxkbcommon
  ];

  cargoHash = "sha256-cofOfaCDKjVpXJHqXiqz2PSIiscYIzCQI2tm5EdWRvE=";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Tool to freeze the screen of a Wayland compositor";
    homepage = "https://github.com/Jappie3/wayfreeze";
    license = lib.licenses.agpl3Only;

    maintainers = with lib.maintainers; [
      purrpurrn
      jappie3 # upstream dev
    ];

    platforms = lib.platforms.linux;
    mainProgram = "wayfreeze";
  };
})
