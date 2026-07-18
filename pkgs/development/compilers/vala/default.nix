{
  lib,
  stdenv,
  fetchurl,
  autoconf,
  autoreconfHook,
  bison,
  expat,
  flex,
  glib,
  gnome,
  gobject-introspection,
  graphviz,
  libiconv,
  libintl,
  libtool,
  libxslt,
  pkg-config,
  replaceVars,
  vala,
}:

let
  generic = lib.makeOverridable (
    {
      hash,
      version,
      extraBuildInputs ? [ ],
      extraNativeBuildInputs ? [ ],
      withGraphviz ? false,
    }:
    let
      # Build vala (valadoc) without graphviz support. Inspired from the openembedded-core project.
      # https://github.com/openembedded/openembedded-core/blob/a5440d4288e09d3e/meta/recipes-devtools/vala/vala/disable-graphviz.patch
      graphvizPatch =
        {
          "0.56" = ./disable-graphviz-0.56.8.patch;
        }
        .${lib.versions.majorMinor version} or (throw "no graphviz patch for this version of vala");

      disableGraphviz = !withGraphviz;

    in
    stdenv.mkDerivation rec {
      inherit version;
      pname = "vala";

      src = fetchurl {
        inherit hash;
        url = "mirror://gnome/sources/vala/${lib.versions.majorMinor version}/vala-${version}.tar.xz";
      };

      outputs = [
        "out"
        "devdoc"
      ];

      # If we're disabling graphviz, apply the patches and corresponding
      # configure flag. We also need to override the path to the valac compiler
      # so that it can be used to regenerate documentation.
      patches = lib.optionals disableGraphviz [ graphvizPatch ];

      postPatch = ''
        patchShebangs tests
      '';

      nativeBuildInputs = [
        pkg-config
        flex
        bison
        libxslt
        gobject-introspection
      ]
      ++ lib.optional (stdenv.hostPlatform.isDarwin) expat
      ++ lib.optional disableGraphviz autoreconfHook # if we changed our ./configure script, need to reconfigure
      ++ lib.optionals (stdenv.buildPlatform != stdenv.hostPlatform) [ vala ]
      ++ extraNativeBuildInputs;

      buildInputs = [
        glib
        libiconv
        libintl
      ]
      ++ lib.optional withGraphviz graphviz
      ++ extraBuildInputs;

      configureFlags = lib.optional disableGraphviz "--disable-graphviz";

      # when cross-compiling ./compiler/valac is valac for host
      # so add the build vala in nativeBuildInputs
      preBuild = lib.optionalString (
        disableGraphviz && (stdenv.buildPlatform == stdenv.hostPlatform)
      ) "buildFlagsArray+=(\"VALAC=$(pwd)/compiler/valac\")";

      doCheck = false; # fails, requires dbus daemon
      enableParallelBuilding = true;

      setupHook = replaceVars ./setup-hook.sh {
        apiVersion = lib.versions.majorMinor version;
      };

      passthru = {
        updateScript = gnome.updateScript {
          attrPath =
            let
              roundUpToEven = num: num + lib.mod num 2;
            in
            "vala_${lib.versions.major version}_${toString (roundUpToEven (lib.toInt (lib.versions.minor version)))}";

          freeze = true;
          packageName = "vala";
        };
      };

      meta = {
        description = "Compiler for GObject type system";
        homepage = "https://vala.dev";
        license = lib.licenses.lgpl21Plus;

        maintainers = with lib.maintainers; [
          antono
          jtojnar
        ];

        platforms = lib.platforms.unix;
        teams = [ lib.teams.pantheon ];
      };
    }
  );

in
rec {
  vala = vala_0_56;

  vala_0_56 = generic {
    version = "0.56.18";
    hash = "sha256-8q/+fUCrY9uOe57MP2vcnC/H4xNMhP8teV9IL+kmo4I=";
  };
}
