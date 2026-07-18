{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  dbus-glib,
  fontconfig,
  freetype,
  gdk-pixbuf,
  gtk2,
  gtk3,
  libGL,
  libpulseaudio,
  libx11,
  libxcomposite,
  libxcursor,
  libxdamage,
  libxext,
  libxi,
  libxrender,
  libxt,
  makeWrapper,
  pango,
  wrapGAppsHook3,
}:

stdenv.mkDerivation rec {
  pname = "seamonkey";
  version = "2.53.23";

  # Upstream requires highly deprecated build tools to compile from source
  src = fetchurl {
    url = "https://archive.seamonkey-project.org/releases/${version}/linux-x86_64/en-US/seamonkey-${version}.en-US.linux-x86_64.tar.bz2";
    sha256 = "1si5vqprq7hgm366db76yziqxcqdvxj675kgxb6lp2ppprl8rlkw";
  };

  strictDeps = true;

  nativeBuildInputs = [
    wrapGAppsHook3
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = [
    gtk2
    gtk3
    gdk-pixbuf
    dbus-glib
    libpulseaudio
    libGL
    pango
    freetype
    fontconfig
    libxi
    libxcursor
    libxdamage
    libxrender
    libxcomposite
    libxext
    libx11
    libxt
  ];

  installPhase = ''
    mkdir -p $out/lib/seamonkey $out/bin
    cp -r * $out/lib/seamonkey/

    ln -s $out/lib/seamonkey/seamonkey $out/bin/seamonkey

    wrapProgram $out/bin/seamonkey \
      --prefix LD_LIBRARY_PATH : "${
        lib.makeLibraryPath [
          libpulseaudio
          libGL
        ]
      }"
  '';

  __structuredAttrs = true;

  meta = with lib; {
    description = "The SeaMonkey project is a community effort to deliver production-quality releases of code names previously known as 'Mozilla Application Suite'";
    homepage = "https://www.seamonkey-project.org/";
    license = licenses.mpl20;
    maintainers = [ lib.maintainers.redhood ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "seamonkey";
  };
}
