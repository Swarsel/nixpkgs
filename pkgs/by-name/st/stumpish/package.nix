{
  lib,
  stdenv,
  fetchFromGitHub,
  gnused,
  ncurses,
  replaceVars,
  rlwrap,
  xprop,
}:

stdenv.mkDerivation {
  pname = "stumpish";
  version = "0.0.1";

  src = fetchFromGitHub {
    owner = "stumpwm";
    repo = "stumpwm-contrib";
    rev = "9f5f06652c480159ec57d1fd8751b16f02db06dc";
    sha256 = "1dxzsnir3158p8y2128s08r9ca0ywr9mcznivmhn1lycw8mg4nfl";
  };

  patches = [
    (replaceVars ./paths.patch {
      rlwrap = "${rlwrap}/bin/rlwrap";
      sed = "${gnused}/bin/sed";
      tput = "${ncurses}/bin/tput";
      xprop = "${xprop}/bin/xprop";
    })
  ];

  buildInputs = [
    gnused
    xprop
    rlwrap
    ncurses
  ];

  buildPhase = ''
    mkdir -p $out/bin
  '';

  installPhase = ''
    cp util/stumpish/stumpish $out/bin
  '';

  meta = {
    description = "STUMPwm Interactive SHell";
    homepage = "https://github.com/stumpwm/stumpwm-contrib";
    license = lib.licenses.gpl2;
    platforms = lib.platforms.unix;
    mainProgram = "stumpish";
  };
}
