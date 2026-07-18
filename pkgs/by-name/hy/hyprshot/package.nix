{
  lib,
  fetchFromGitHub,
  grim,
  hyprland,
  hyprpicker,
  jq,
  libnotify,
  makeWrapper,
  slurp,
  stdenvNoCC,
  wl-clipboard,
  withFreeze ? true,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "hyprshot";
  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "Gustash";
    repo = "hyprshot";
    rev = finalAttrs.version;
    hash = "sha256-9taTmV357cWglMGuN3NLq3bfNneFthwV6y+Ml4qEeHA=";
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    install -Dm755 hyprshot -t "$out/bin"
    wrapProgram "$out/bin/hyprshot" \
      --prefix PATH ":" ${
        lib.makeBinPath (
          [
            hyprland
            jq
            grim
            slurp
            wl-clipboard
            libnotify
          ]
          ++ lib.optionals withFreeze [ hyprpicker ]
        )
      }

    runHook postInstall
  '';

  meta = {
    description = "Utility to easily take screenshots in Hyprland using your mouse";
    homepage = "https://github.com/Gustash/hyprshot";
    license = lib.licenses.gpl3Only;

    maintainers = with lib.maintainers; [
      Cryolitia
      ryan4yin
    ];

    platforms = hyprland.meta.platforms;
    mainProgram = "hyprshot";
  };
})
