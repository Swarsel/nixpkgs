{
  lib,
  stdenv,
  fetchurl,
  avahi,
  dbus-glib,
  ffmpeg,
  libGLU,
  libcap,
  libextractor,
  libglvnd,
  libjpeg,
  libvdpau,
  libx11,
  libxext,
  libxrandr,
  libxrender,
  makeWrapper,
  vdr,
  wayland,
  xine-lib,
}:
let
  makeXinePluginPath = l: lib.concatStringsSep ":" (map (p: "${p}/lib/xine/plugins") l);

  self = stdenv.mkDerivation rec {
    pname = "vdr-xineliboutput";
    version = "2.3.0";

    src = fetchurl {
      url = "mirror://sourceforge/project/xineliboutput/xineliboutput/${pname}-${version}/${pname}-${version}.tgz";
      sha256 = "sha256-GnTaGaIbBufZP2npa9mAbrO1ccMf1RzhbvjrWhKBTjg=";
    };

    postPatch = ''
      # pkg-config is called with opengl, which do not contain needed glx symbols
      substituteInPlace configure \
        --replace "X11  opengl" "X11  gl"
    '';

    nativeBuildInputs = [ makeWrapper ];

    buildInputs = [
      dbus-glib
      ffmpeg
      libcap
      libextractor
      libjpeg
      libglvnd
      libGLU
      libvdpau
      libxext
      libxrandr
      libxrender
      libx11
      vdr
      xine-lib
      avahi
      wayland
    ];

    makeFlags = [ "DESTDIR=$(out)" ];

    postConfigure = ''
      sed -i config.mak \
        -e 's,XINEPLUGINDIR=/[^/]*/[^/]*/[^/]*/,XINEPLUGINDIR=/,'
    '';

    postFixup = ''
      for f in $out/bin/*; do
        wrapProgram $f \
          --prefix XINE_PLUGIN_PATH ":" "${
            makeXinePluginPath [
              "$out"
              xine-lib
            ]
          }"
      done
    '';

    # configure don't accept argument --prefix
    dontAddPrefix = true;

    passthru.requiredXinePlugins = [
      xine-lib
      self
    ];

    meta = {
      inherit (vdr.meta) platforms;
      description = "Xine-lib based software output device for VDR";
      homepage = "https://sourceforge.net/projects/xineliboutput/";
      license = lib.licenses.gpl2;
      maintainers = [ lib.maintainers.ck3d ];
    };
  };
in
self
