{
  lib,
  stdenv,
  fetchurl,
  appimageTools,
  makeWrapper,
  undmg,
}:

let

  pname = "sleek-todo";
  version = "2.0.14";

  src =
    fetchurl
      {
        x86_64-linux = {
          hash = "sha256-d2fLsCI7peuNBtjgHs1qumgPAF9eJeBYiIIffoSv9Jk=";
          url = "https://github.com/ransome1/sleek/releases/download/v${version}/sleek-2.0.14.AppImage";
        };
      }
      .${stdenv.hostPlatform.system} or (throw "Unsupported system: ${stdenv.system}");

  meta = {
    description = "Todo manager based on todo.txt syntax";
    homepage = "https://github.com/ransome1/sleek";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ByteSudoer ];

    platforms = [
      "x86_64-linux"
    ];

    mainProgram = "sleek-todo";
  };
  appimageContents = appimageTools.extract { inherit pname version src; };
in
if stdenv.hostPlatform.isDarwin then
  stdenv.mkDerivation {
    inherit
      pname
      version
      src
      meta
      ;

    nativeBuildInputs = [ undmg ];

    installPhase = ''
      runHook preInstall
      mkdir -p $out/Applications
      cp -r *.app $out/Applications/
      runHook postInstall
    '';

    sourceRoot = ".";
  }
else
  appimageTools.wrapType2 {
    inherit
      pname
      version
      src
      meta
      ;

    nativeBuildInputs = [ makeWrapper ];

    extraInstallCommands = ''
      wrapProgram $out/bin/sleek-todo \
        --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations}}"
      mkdir -p $out/share/{applications,sleek}
      cp -a ${appimageContents}/{locales,resources} $out/share/sleek
      cp -a ${appimageContents}/usr/share/icons $out/share
      install -Dm 444 ${appimageContents}/sleek.desktop $out/share/applications
      substituteInPlace $out/share/applications/sleek.desktop \
      --replace-warn 'Exec=AppRun' 'Exec=${pname}'
    '';

  }
