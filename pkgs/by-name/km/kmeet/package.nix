{
  lib,
  fetchurl,
  appimageTools,
}:

appimageTools.wrapType2 rec {
  pname = "kmeet";
  version = "2.0.1";

  src = fetchurl {
    url = "https://download.storage5.infomaniak.com/meet/kmeet-desktop-${version}-linux-x86_64.AppImage";
    hash = "sha256-0lygBbIwaEydvFEfvADiL2k5GWzVpM1jX4orweriBYw=";
    name = "kmeet-${version}.AppImage";
  };

  extraInstallCommands =
    let
      contents = appimageTools.extractType2 { inherit pname version src; };
    in
    ''
      mkdir -p "$out/share/applications"
      mkdir -p "$out/share/lib/kmeet"
      cp -r ${contents}/{locales,resources} "$out/share/lib/kmeet"
      cp -r ${contents}/usr/* "$out"
      cp "${contents}/kMeet.desktop" "$out/share/applications/"
      mv "$out/bin/kmeet" "$out/bin/${meta.mainProgram}" || true
      substituteInPlace $out/share/applications/kMeet.desktop --replace 'Exec=AppRun' 'Exec=${meta.mainProgram}'
    '';

  meta = {
    description = "Organise secure online meetings via your web browser, your mobile, your tablet or your computer";

    longDescription = ''
      kMeet allows you to organise secure online meetings via your web browser, your mobile, your tablet or your
      computer.
    '';

    homepage = "https://www.infomaniak.com/en/apps/download-kmeet";
    license = lib.licenses.unfree;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    maintainers = [ lib.maintainers.vinetos ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "kmeet";
  };
}
