{
  lib,
  stdenv,
  fetchurl,
  _7zz,
  appimageTools,
  makeWrapper,
}:

let
  pname = "notesnook";
  version = "3.3.21";

  inherit (stdenv.hostPlatform) system;
  throwSystem = throw "Unsupported system: ${system}";

  suffix =
    {
      aarch64-darwin = "mac_arm64.dmg";
      aarch64-linux = "linux_arm64.AppImage";
      x86_64-linux = "linux_x86_64.AppImage";
    }
    .${system} or throwSystem;

  src = fetchurl {
    url = "https://github.com/streetwriters/notesnook/releases/download/v${version}/notesnook_${suffix}";

    hash =
      {
        aarch64-darwin = "sha256-9CTGpCPJY6sq6JWDpoCTyOTt/vtCazDaoDzFFUzR9zg=";
        aarch64-linux = "sha256-IU4hF/ol4pyh+ABTri2aqwqaB+cfrHLtsF7wrqE+wEY=";
        x86_64-linux = "sha256-NmhV+x5HrKBO7BX1bJyjChKQF/j38kQqJ3x0amSXzGU=";
      }
      .${system} or throwSystem;
  };

  passthru = {
    updateScript = ./update.sh;
  };

  appimageContents = appimageTools.extractType2 {
    inherit pname version src;
  };

  meta = {
    description = "Fully open source & end-to-end encrypted note taking alternative to Evernote";

    longDescription = ''
      Notesnook is a free (as in speech) & open source note taking app
      focused on user privacy & ease of use. To ensure zero knowledge
      principles, Notesnook encrypts everything on your device using
      XChaCha20-Poly1305 & Argon2.
    '';

    homepage = "https://notesnook.com";
    license = lib.licenses.gpl3Only;
    maintainers = [ ];

    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
    ];

    mainProgram = "notesnook";
  };

  linux = appimageTools.wrapType2 rec {
    inherit
      pname
      version
      src
      meta
      passthru
      ;

    nativeBuildInputs = [ makeWrapper ];

    extraInstallCommands = ''
      wrapProgram $out/bin/notesnook \
        --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations}}"
      install -Dm444 ${appimageContents}/notesnook.desktop -t $out/share/applications
      install -Dm444 ${appimageContents}/notesnook.png -t $out/share/icons
      substituteInPlace $out/share/applications/notesnook.desktop \
        --replace 'Exec=AppRun --no-sandbox %U' 'Exec=${pname}'
    '';

    profile = ''
      export LC_ALL=C.UTF-8
    '';
  };

  darwin = stdenv.mkDerivation {
    inherit
      pname
      version
      src
      meta
      passthru
      ;

    nativeBuildInputs = [ _7zz ];

    installPhase = ''
      mkdir -p $out/Applications/Notesnook.app
      cp -R . $out/Applications/Notesnook.app
    '';

    sourceRoot = "Notesnook.app";

    # 7zz did not unpack in setup hook for some reason, done manually here
    unpackPhase = ''
      7zz x $src
    '';
  };
in
if stdenv.hostPlatform.isDarwin then darwin else linux
