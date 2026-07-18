{
  lib,
  stdenv,
  fetchurl,
  _7zz,
  addDriverRunpath,
  dpkg,
  electron,
  fetchzip,
  makeWrapper,
  tetrio-plus,
  withTetrioPlus ? false,
}:

let
  inherit (stdenv.hostPlatform) isDarwin system;

  version = "10";

  srcs = {
    aarch64-darwin = fetchurl {
      hash = "sha256-PbK9XEynpii35p6DQYiPbaRM4guPazWd5N4Dr2O4H24=";
      url = "https://tetr.io/about/desktop/builds/${version}/TETR.IO%20Setup%20arm64.dmg";
    };

    x86_64-linux = fetchzip {
      nativeBuildInputs = [ dpkg ];
      hash = "sha256-2FtFCajNEj7O8DGangDecs2yeKbufYLx1aZb3ShnYvw=";
      url = "https://tetr.io/about/desktop/builds/${version}/TETR.IO%20Setup.deb";
    };
  };
in
stdenv.mkDerivation {
  inherit version;
  pname = "tetrio-desktop";
  src = srcs.${system} or (throw "Unsupported system: ${system}");
  nativeBuildInputs = lib.optionals (!isDarwin) [ makeWrapper ] ++ lib.optionals isDarwin [ _7zz ];

  installPhase =
    if isDarwin then
      ''
        runHook preInstall

        mkdir -p "$out/Applications/TETR.IO.app"
        cp -R . "$out/Applications/TETR.IO.app"

        ${lib.optionalString withTetrioPlus ''
          cp ${tetrio-plus} "$out/Applications/TETR.IO.app/Contents/Resources/app.asar"
        ''}

        runHook postInstall
      ''
    else
      let
        asarPath = if withTetrioPlus then tetrio-plus else "opt/TETR.IO/resources/app.asar";
      in
      ''
        runHook preInstall

        mkdir -p $out
        cp -r usr/share/ $out

        mkdir -p $out/share/TETR.IO/
        cp ${asarPath} $out/share/TETR.IO/app.asar

        substituteInPlace $out/share/applications/TETR.IO.desktop \
          --replace-fail "Exec=/opt/TETR.IO/TETR.IO" "Exec=$out/bin/tetrio" \
          --replace-fail "StartupWMClass=TETR.IO" "StartupWMClass=tetrio-desktop"

        runHook postInstall
      '';

  postFixup = lib.optionalString (!isDarwin) ''
    makeShellWrapper '${lib.getExe electron}' $out/bin/tetrio \
      --prefix LD_LIBRARY_PATH : ${addDriverRunpath.driverLink}/lib \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}" \
      --add-flags $out/share/TETR.IO/app.asar
  '';

  sourceRoot = lib.optionalString isDarwin "TETR.IO.app";

  unpackPhase = lib.optionalString isDarwin ''
    7zz x $src
  '';

  meta = {
    description = "Desktop client for TETR.IO, an online stacker game";

    longDescription = ''
      TETR.IO is a free-to-win modern yet familiar online stacker.
      Play multiplayer games against friends and foes all over the world, or claim a spot on the leaderboards - the stacker future is yours!
    '';

    homepage = "https://tetr.io";
    changelog = "https://tetr.io/about/desktop/history/";
    license = lib.licenses.unfree;
    sourceProvenance = [ lib.sourceTypes.binaryBytecode ];

    maintainers = with lib.maintainers; [
      huantian
      anish
    ];

    platforms = [ "x86_64-linux" ] ++ lib.platforms.darwin;
    mainProgram = "tetrio";
    downloadPage = "https://tetr.io/about/desktop/";
  };
}
