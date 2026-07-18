{
  lib,
  stdenv,
  fetchFromGitHub,
  gawk,
  i3,
  jq,
  libnotify,
  makeWrapper,
  rofi,
  vim,
  xdotool,
  xrandr,
}:

let
  path = lib.makeBinPath [
    vim
    jq
    rofi
    xrandr
    xdotool
    i3
    gawk
    libnotify
  ];
in

stdenv.mkDerivation {
  pname = "i3-layout-manager";
  version = "unstable-2020-05-04";

  src = fetchFromGitHub {
    owner = "klaxalk";
    repo = "i3-layout-manager";
    rev = "df54826bba351d8bcd7ebeaf26c07c713af7912c";
    hash = "sha256-g9mJco8o97pKuEz0Vv/vSwvsmDycCdQKtM6I6wfJmzE=";
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    install -D layout_manager.sh $out/bin/layout_manager
    wrapProgram $out/bin/layout_manager \
      --prefix PATH : "${path}"

    runHook postInstall
  '';

  dontBuild = true;

  meta = {
    description = "Saving, loading and managing layouts for i3wm";
    homepage = "https://github.com/klaxalk/i3-layout-manager";
    license = lib.licenses.mit;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "layout_manager";
  };
}
