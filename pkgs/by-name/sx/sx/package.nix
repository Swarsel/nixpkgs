{
  lib,
  fetchFromGitHub,
  coreutils,
  makeDesktopItem,
  nixosTests,
  patsh,
  stdenvNoCC,
  xauth,
  xorg-server,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "sx";
  version = "3.0";

  src = fetchFromGitHub {
    owner = "earnestly";
    repo = "sx";
    rev = finalAttrs.version;
    hash = "sha256-hKoz7Kuus8Yp7D0F05wCOQs6BvV0NkRM9uUXTntLJxQ=";
  };

  nativeBuildInputs = [ patsh ];

  buildInputs = [
    coreutils # needed for cross
    xauth
    xorg-server
  ];

  makeFlags = [ "PREFIX=$(out)" ];

  postInstall = ''
    patsh -f $out/bin/sx -s ${builtins.storeDir} --path "$HOST_PATH"

    install -Dm755 -t $out/share/xsessions ${
      makeDesktopItem {
        comment = "Start a xorg server";
        desktopName = "sx";
        exec = "sx";
        name = "sx";
      }
    }/share/applications/sx.desktop
  '';

  passthru = {
    providedSessions = [ "sx" ];

    tests = {
      inherit (nixosTests) sx;
    };
  };

  meta = {
    description = "Simple alternative to both xinit and startx for starting a Xorg server";
    homepage = "https://github.com/earnestly/sx";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      thiagokokada
      liberodark
    ];

    platforms = lib.platforms.linux;
    mainProgram = "sx";
  };
})
