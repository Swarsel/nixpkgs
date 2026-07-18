{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  boost,
  buildPackages,
  gd,
  libtool,
  libusb-compat-0_1,
  libxml2,
  ncurses,
  perl,
  pkg-config,
  python311,
  swig,
  tcl,
  perlBindings ? stdenv.buildPlatform == stdenv.hostPlatform,
  pythonBindings ? true,
  tclBindings ? true,
}:
let
  python3 = python311; # needs distutils and imp
in
stdenv.mkDerivation (finalAttrs: {
  pname = "hamlib";
  version = "4.7.1";

  src = fetchFromGitHub {
    owner = "Hamlib";
    repo = "Hamlib";
    tag = finalAttrs.version;
    hash = "sha256-nI8gDACxlci2Q9V2W4D1DYDUL74JwlCs+qyyNkXOPu4=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    swig
    pkg-config
    libtool
    autoreconfHook
  ]
  ++ lib.optionals pythonBindings [ python3 ]
  ++ lib.optionals tclBindings [ tcl ]
  ++ lib.optionals perlBindings [ perl ];

  buildInputs = [
    gd
    libxml2
    libusb-compat-0_1
    boost
  ]
  ++ lib.optionals pythonBindings [
    python3
    ncurses
  ]
  ++ lib.optionals tclBindings [ tcl ];

  configureFlags = [
    "CC_FOR_BUILD=${stdenv.cc.targetPrefix}cc"
  ]
  ++ lib.optionals perlBindings [ "--with-perl-binding" ]
  ++ lib.optionals tclBindings [
    "--with-tcl-binding"
    "--with-tcl=${tcl}/lib/"
  ]
  ++ lib.optionals pythonBindings [ "--with-python-binding" ];

  depsBuildBuild = [ buildPackages.stdenv.cc ];

  meta = {
    description = "Runtime library to control radio transceivers and receivers";

    longDescription = ''
      Hamlib provides a standardized programming interface that applications
      can use to send the appropriate commands to a radio.

      Also included in the package is a simple radio control program 'rigctl',
      which lets one control a radio transceiver or receiver, either from
      command line interface or in a text-oriented interactive interface.
    '';

    homepage = "https://hamlib.sourceforge.net";

    license = with lib.licenses; [
      gpl2Plus
      lgpl2Plus
    ];

    maintainers = with lib.maintainers; [
      relrod
      fstracke
    ];

    platforms = with lib.platforms; unix;
  };
})
