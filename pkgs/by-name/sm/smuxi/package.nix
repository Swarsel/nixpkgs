{
  lib,
  stdenv,
  fetchFromGitHub,
  autoconf,
  automake,
  gdk-pixbuf,
  gettext,
  glib,
  gtk-sharp-2_0,
  intltool,
  itstool,
  makeWrapper,
  mono,
  pango,
  pkg-config,
  sqlite,
  stfl,
  guiSupport ? true,
}:

stdenv.mkDerivation rec {
  pname = "smuxi";
  version = "unstable-2023-07-01";

  src = fetchFromGitHub {
    owner = "meebey";
    repo = "smuxi";
    rev = "3e4b5050b66944532e95df3c31245c8ae6379b3f";
    hash = "sha256-zSsckcEPEX99v3RkM4O4+Get5tnz4FOpiodoTGTZq+8=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    pkg-config
    makeWrapper
  ];

  buildInputs = [
    autoconf
    automake
    itstool
    intltool
    gettext
    mono
    stfl
  ]
  ++ lib.optionals guiSupport [
    gtk-sharp-2_0
    # loaded at runtime by GTK#
    gdk-pixbuf
    pango
  ];

  configureFlags = [
    "--disable-frontend-gnome"
    "--enable-frontend-stfl"
  ]
  ++ lib.optional guiSupport "--enable-frontend-gnome";

  preConfigure = ''
    NOCONFIGURE=1 NOGIT=1 ACLOCAL_FLAGS="-I ${gettext}/share/gettext/m4" ./autogen.sh
  '';

  postInstall = ''
    makeWrapper "${mono}/bin/mono" "$out/bin/smuxi-message-buffer" \
      --add-flags "$out/lib/smuxi/smuxi-message-buffer.exe" \
      --prefix ${runtimeLoaderEnvVariableName} : ${
        lib.makeLibraryPath [
          gettext
          sqlite
        ]
      }

    makeWrapper "${mono}/bin/mono" "$out/bin/smuxi-server" \
      --add-flags "$out/lib/smuxi/smuxi-server.exe" \
      --prefix ${runtimeLoaderEnvVariableName} : ${
        lib.makeLibraryPath [
          gettext
          sqlite
        ]
      }

    makeWrapper "${mono}/bin/mono" "$out/bin/smuxi-frontend-stfl" \
      --add-flags "$out/lib/smuxi/smuxi-frontend-stfl.exe" \
      --prefix ${runtimeLoaderEnvVariableName} : ${
        lib.makeLibraryPath [
          gettext
          sqlite
          stfl
        ]
      }

    makeWrapper "${mono}/bin/mono" "$out/bin/smuxi-frontend-gnome" \
      --add-flags "$out/lib/smuxi/smuxi-frontend-gnome.exe" \
      --prefix MONO_GAC_PREFIX : ${if guiSupport then gtk-sharp-2_0 else ""} \
      --prefix ${runtimeLoaderEnvVariableName} : ${
        lib.makeLibraryPath [
          gettext
          glib
          sqlite
          gtk-sharp-2_0
          gtk-sharp-2_0.gtk
          gdk-pixbuf
          pango
        ]
      }

    # install log4net and nini libraries
    mkdir -p $out/lib/smuxi/
    cp -a lib/log4net.dll $out/lib/smuxi/
    cp -a lib/Nini.dll $out/lib/smuxi/

    # install GTK+ icon theme on Darwin
    ${
      if guiSupport && stdenv.hostPlatform.isDarwin then
        "
      mkdir -p $out/lib/smuxi/icons/
      cp -a images/Smuxi-Symbolic $out/lib/smuxi/icons/
    "
      else
        ""
    }
  '';

  runtimeLoaderEnvVariableName =
    if stdenv.hostPlatform.isDarwin then "DYLD_FALLBACK_LIBRARY_PATH" else "LD_LIBRARY_PATH";

  meta = {
    description = "irssi-inspired, detachable, cross-platform, multi-protocol (IRC, XMPP/Jabber) chat client for the GNOME desktop";
    homepage = "https://smuxi.im/";
    changelog = "https://github.com/meebey/smuxi/releases/tag/v${version}";
    license = lib.licenses.gpl2Plus;

    maintainers = with lib.maintainers; [
      meebey
    ];

    platforms = lib.platforms.unix;
    downloadPage = "https://smuxi.im/download/";
  };
}
