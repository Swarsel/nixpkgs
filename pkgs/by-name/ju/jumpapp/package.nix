{
  lib,
  stdenv,
  fetchFromGitHub,
  net-tools,
  pandoc,
  perl,
  wmctrl,
  xdotool,
  xprop,
}:

stdenv.mkDerivation rec {
  pname = "jumpapp";
  version = "1.2";

  src = fetchFromGitHub {
    owner = "mkropat";
    repo = "jumpapp";
    rev = "v${version}";
    sha256 = "sha256-9sh0+zpDxwqRGC1jUgGTDdSDRdAFsL12mQ/Opwh/UBc=";
  };

  nativeBuildInputs = [
    pandoc
    perl
  ];

  buildInputs = [
    xdotool
    wmctrl
    xprop
    net-tools
    perl
  ];

  makeFlags = [ "PREFIX=$(out)" ];

  postFixup =
    let
      runtimePath = lib.makeBinPath buildInputs;
    in
    ''
      sed -i "2 i export PATH=${runtimePath}:\$PATH" $out/bin/jumpapp
      sed -i "2 i export PATH=${perl}/bin:\$PATH" $out/bin/jumpappify-desktop-entry
    '';

  meta = {
    description = "Run-or-raise application switcher for any X11 desktop";
    homepage = "https://github.com/mkropat/jumpapp";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.matklad ];
  };
}
