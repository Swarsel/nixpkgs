{
  lib,
  stdenv,
  fetchFromGitHub,
  autoconf,
  automake,
  gtk3,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gsimplecal";
  version = "2.5.2";

  src = fetchFromGitHub {
    owner = "dmedvinsky";
    repo = "gsimplecal";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-OaXZ/ch/Os6oi6V75Sy+QHeIGolwtieecFuLy4998yc=";
  };

  postPatch = ''
    sed -i -e '/sys\/sysctl.h/d' src/Unique.cpp
  '';

  nativeBuildInputs = [
    pkg-config
    automake
    autoconf
  ];

  buildInputs = [ gtk3 ];
  preConfigure = "./autogen.sh";
  enableParallelBuilding = true;

  meta = {
    description = "Lightweight calendar application written in C++ using GTK";

    longDescription = ''
      gsimplecal was intentionally made for use with tint2 panel in the
      openbox environment to be launched upon clock click, but of course it
      will work without it. In fact, binding the gsimplecal to some hotkey in
      you window manager will probably make you happy. The thing is that when
      it is started it first shows up, when you run it again it closes the
      running instance. In that way it is very easy to integrate anywhere. No
      need to write some wrapper scripts or whatever.

      Also, you can configure it to not only show the calendar, but also
      display multiple clocks for different world time zones.
    '';

    homepage = "http://dmedvinsky.github.io/gsimplecal/";
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.romildo ];
    platforms = lib.platforms.linux;
    mainProgram = "gsimplecal";
  };
})
