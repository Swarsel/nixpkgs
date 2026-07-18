{
  lib,
  stdenv,
  fetchFromGitHub,
  # Dependencies (@see https://github.com/pavanjadhaw/betterlockscreen/blob/master/shell.nix)
  bc,
  coreutils,
  dbus,
  dunst,
  gawk,
  gnugrep,
  gnused,
  i3lock-color,
  imagemagick,
  makeWrapper,
  procps,
  xdpyinfo,
  xrandr,
  xset,
  withDunst ? true,
}:

let
  runtimeDeps = [
    bc
    coreutils
    dbus
    i3lock-color
    gawk
    gnugrep
    gnused
    imagemagick
    procps
    xdpyinfo
    xrandr
    xset
  ]
  ++ lib.optionals withDunst [ dunst ];
in

stdenv.mkDerivation (finalAttrs: {
  pname = "betterlockscreen";
  version = "4.4.0";

  src = fetchFromGitHub {
    owner = "betterlockscreen";
    repo = "betterlockscreen";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-59Ct7XIfZqU3yaW9FO7UV8SSMLdcZMPRc7WJangxFPo=";
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp betterlockscreen $out/bin/betterlockscreen
    wrapProgram "$out/bin/betterlockscreen" \
      --prefix PATH : "$out/bin:${lib.makeBinPath runtimeDeps}"

    runHook postInstall
  '';

  meta = {
    description = "Fast and sweet looking lockscreen for linux systems with effects";
    homepage = "https://github.com/betterlockscreen/betterlockscreen";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      eyjhb
    ];

    platforms = lib.platforms.linux;
    mainProgram = "betterlockscreen";
  };
})
