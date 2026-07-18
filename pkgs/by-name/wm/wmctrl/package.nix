{
  lib,
  stdenv,
  fetchurl,
  glib,
  libx11,
  libxmu,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {

  pname = "wmctrl";
  version = "1.07";

  src = fetchurl {
    # NOTE: 2019-04-11: There is also a semi-official mirror: http://tripie.sweb.cz/utils/wmctrl/
    url = "https://sites.google.com/site/tstyblo/wmctrl/wmctrl-${finalAttrs.version}.tar.gz";
    sha256 = "1afclc57b9017a73mfs9w7lbdvdipmf9q0xdk116f61gnvyix2np";
  };

  patches = [ ./64-bit-data.patch ];
  strictDeps = true;
  nativeBuildInputs = [ glib.dev ];

  buildInputs = [
    libx11
    libxmu
    glib
  ];

  depsBuildBuild = [ pkg-config ];

  meta = {
    description = "CLI tool to interact with EWMH/NetWM compatible X Window Managers";
    homepage = "https://sites.google.com/site/tstyblo/wmctrl";
    license = lib.licenses.gpl2Plus;
    maintainers = [ lib.maintainers.Anton-Latukha ];
    platforms = with lib.platforms; all;
    mainProgram = "wmctrl";
  };

})
