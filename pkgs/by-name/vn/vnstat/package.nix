{
  lib,
  stdenv,
  fetchFromGitHub,
  check,
  gd,
  ncurses,
  pkg-config,
  sqlite,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "vnstat";
  version = "2.13";

  src = fetchFromGitHub {
    owner = "vergoh";
    repo = "vnstat";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Xd3s4Wrtfwis0dxRijeWhfloHcXPUNAj0P91uWi1C3M=";
  };

  postPatch = ''
    substituteInPlace src/cfg.c --replace-fail /usr/local $out
  '';

  strictDeps = true;
  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    gd
    ncurses
    sqlite
  ];

  doCheck = true;
  checkInputs = [ check ];
  __structuredAttrs = true;

  meta = {
    description = "Console-based network statistics utility for Linux";

    longDescription = ''
      vnStat is a console-based network traffic monitor for Linux and BSD that
      keeps a log of network traffic for the selected interface(s). It uses the
      network interface statistics provided by the kernel as information source.
      This means that vnStat won't actually be sniffing any traffic and also
      ensures light use of system resources.
    '';

    homepage = "https://humdi.net/vnstat/";
    license = lib.licenses.gpl2Plus;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    maintainers = with lib.maintainers; [ choco98 ];
    platforms = lib.platforms.linux;
    mainProgram = "vnstat";
  };
})
