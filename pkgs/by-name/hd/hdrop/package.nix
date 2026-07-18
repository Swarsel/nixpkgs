{
  lib,
  fetchFromGitHub,
  coreutils,
  curl,
  gawk,
  hyprland,
  jq,
  libnotify,
  makeWrapper,
  scdoc,
  stdenvNoCC,
  util-linux,
  withHyprland ? true,
}:

stdenvNoCC.mkDerivation rec {
  pname = "hdrop";
  version = "0.7.9";

  src = fetchFromGitHub {
    owner = "Schweber";
    repo = "hdrop";
    rev = "v${version}";
    hash = "sha256-Z8jtuO1GTk7md9iXOiE2poAY1D9YOIqzSlEY7Eai/pg=";
  };

  nativeBuildInputs = [
    makeWrapper
    scdoc
  ];

  makeFlags = [ "PREFIX=$(out)" ];

  postInstall = ''
    wrapProgram $out/bin/hdrop --prefix PATH ':' \
      "${
        lib.makeBinPath (
          [
            coreutils
            curl
            util-linux
            jq
            libnotify
            gawk
          ]
          ++ lib.optional withHyprland hyprland
        )
      }"
  '';

  meta = {
    description = "Emulate 'tdrop' in Hyprland (run, show and hide specific programs per keybind)";
    homepage = "https://github.com/Schweber/hdrop";
    changelog = "https://github.com/Schweber/hdrop/releases/tag/v${version}";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ Schweber ];
    platforms = lib.platforms.linux;
    mainProgram = "hdrop";
  };
}
