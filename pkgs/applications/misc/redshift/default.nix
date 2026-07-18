{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchFromGitLab,
  autoconf,
  automake,
  geoclue,
  gettext,
  gobject-introspection,
  gtk3,
  intltool,
  libappindicator,
  libayatana-appindicator,
  libdrm,
  libtool,
  libxcb,
  libxxf86vm,
  pkg-config,
  pygobject3,
  python,
  pyxdg,
  wayland-scanner,
  wrapGAppsHook3,
  wrapPython,
  withAppIndicator ? stdenv.hostPlatform.isLinux,
  withCoreLocation ? withGeolocation && stdenv.hostPlatform.isDarwin,
  withDrm ? stdenv.hostPlatform.isLinux,
  withGeoclue ? withGeolocation && stdenv.hostPlatform.isLinux,
  withGeolocation ? true,
  withQuartz ? stdenv.hostPlatform.isDarwin,
  withRandr ? stdenv.hostPlatform.isLinux,
  withVidmode ? stdenv.hostPlatform.isLinux,
}:

let
  mkRedshift =
    {
      meta,
      pname,
      src,
      version,
    }:
    stdenv.mkDerivation rec {
      inherit
        pname
        version
        src
        meta
        ;

      strictDeps = true;

      nativeBuildInputs = [
        autoconf
        automake
        gettext
        intltool
        libtool
        pkg-config
        wrapGAppsHook3
        wrapPython
        gobject-introspection
        python
      ]
      ++ lib.optionals (pname == "gammastep") [ wayland-scanner ];

      buildInputs = [
        gtk3
      ]
      ++ lib.optional withRandr libxcb
      ++ lib.optional withGeoclue geoclue
      ++ lib.optional withDrm libdrm
      ++ lib.optional withVidmode libxxf86vm
      ++ lib.optional withAppIndicator (
        if (pname != "gammastep") then libappindicator else libayatana-appindicator
      );

      configureFlags = [
        "--enable-randr=${lib.boolToYesNo withRandr}"
        "--enable-geoclue2=${lib.boolToYesNo withGeoclue}"
        "--enable-drm=${lib.boolToYesNo withDrm}"
        "--enable-vidmode=${lib.boolToYesNo withVidmode}"
        "--enable-quartz=${lib.boolToYesNo withQuartz}"
        "--enable-corelocation=${lib.boolToYesNo withCoreLocation}"
      ]
      ++ lib.optionals (pname == "gammastep") [
        "--with-systemduserunitdir=${placeholder "out"}/lib/systemd/user/"
        "--enable-apparmor"
      ];

      preConfigure = "./bootstrap";

      # the geoclue agent may inspect these paths and expect them to be
      # valid without having the correct $PATH set
      postInstall =
        if (pname == "gammastep") then
          ''
            substituteInPlace $out/share/applications/gammastep.desktop \
              --replace 'Exec=gammastep' "Exec=$out/bin/gammastep"
            substituteInPlace $out/share/applications/gammastep-indicator.desktop \
              --replace 'Exec=gammastep-indicator' "Exec=$out/bin/gammastep-indicator"
          ''
        else
          ''
            substituteInPlace $out/share/applications/redshift.desktop \
              --replace 'Exec=redshift' "Exec=$out/bin/redshift"
            substituteInPlace $out/share/applications/redshift-gtk.desktop \
              --replace 'Exec=redshift-gtk' "Exec=$out/bin/redshift-gtk"
          '';

      preFixup = ''
        makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
      '';

      postFixup = ''
        wrapPythonPrograms
        wrapGApp $out/bin/${pname}
      '';

      depsBuildBuild = [ pkg-config ];
      dontWrapGApps = true;
      enableParallelBuilding = true;

      pythonPath = [
        pygobject3
        pyxdg
      ];
    };
in
rec {
  gammastep = mkRedshift rec {
    pname = "gammastep";
    version = "2.0.11";

    src = fetchFromGitLab {
      owner = "chinstrap";
      repo = "gammastep";
      rev = "v${version}";
      hash = "sha256-c8JpQLHHLYuzSC9bdymzRTF6dNqOLwYqgwUOpKcgAEU=";
    };

    meta = redshift.meta // {
      longDescription = "Gammastep" + lib.removePrefix "Redshift" redshift.meta.longDescription;
      homepage = "https://gitlab.com/chinstrap/gammastep";
      maintainers = with lib.maintainers; [ acidbong ] ++ redshift.meta.maintainers;
      mainProgram = "gammastep";
    };
  };

  redshift = mkRedshift rec {
    pname = "redshift";
    version = "1.12";

    src = fetchFromGitHub {
      owner = "jonls";
      repo = "redshift";
      rev = "v${version}";
      sha256 = "12cb4gaqkybp4bkkns8pam378izr2mwhr2iy04wkprs2v92j7bz6";
    };

    meta = {
      description = "Screen color temperature manager";

      longDescription = ''
        Redshift adjusts the color temperature according to the position
        of the sun. A different color temperature is set during night and
        daytime. During twilight and early morning, the color temperature
        transitions smoothly from night to daytime temperature to allow
        your eyes to slowly adapt. At night the color temperature should
        be set to match the lamps in your room.
      '';

      homepage = "http://jonls.dk/redshift";
      license = lib.licenses.gpl3Plus;
      maintainers = [ ];
      platforms = lib.platforms.unix;
      mainProgram = "redshift";
    };
  };
}
