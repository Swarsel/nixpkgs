{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPackages,
  cmake,
  fixDarwinDylibNames,
  glib,
  gobject-introspection,
  icu,
  libical,
  libxml2,
  ninja,
  perl,
  pkg-config,
  pkgsBuildBuild,
  python3,
  tzdata,
  vala,
  withIntrospection ?
    lib.meta.availableOn stdenv.hostPlatform gobject-introspection
    && stdenv.hostPlatform.emulatorAvailable buildPackages,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libical";
  version = "3.0.20";

  src = fetchFromGitHub {
    owner = "libical";
    repo = "libical";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-KIMqZ6QAh+fTcKEYrcLlxgip91CLAwL9rwjUdKzBsQk=";
  };

  outputs = [
    "out"
    "dev"
  ]; # "devdoc" ];

  patches = [
    # Will appear in 3.1.0
    # https://github.com/libical/libical/issues/350
    ./respect-env-tzdir.patch

    ./static.patch
  ];

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    icu
    ninja
    perl
    pkg-config
  ]
  ++ lib.optionals withIntrospection [
    gobject-introspection
    vala
    # Docs building fails:
    # https://github.com/NixOS/nixpkgs/pull/67204
    # previously with https://github.com/NixOS/nixpkgs/pull/61657#issuecomment-495579489
    # gtk-doc docbook_xsl docbook_xml_dtd_43 # for docs
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    fixDarwinDylibNames
  ];

  buildInputs = [
    glib
    libxml2
    icu
  ];

  cmakeFlags = [
    "-DENABLE_GTK_DOC=False"
    "-DLIBICAL_BUILD_EXAMPLES=False"
    "-DGOBJECT_INTROSPECTION=${if withIntrospection then "True" else "False"}"
    "-DICAL_GLIB_VAPI=${if withIntrospection then "True" else "False"}"
    "-DSTATIC_ONLY=${if stdenv.hostPlatform.isStatic then "True" else "False"}"
  ]
  ++ lib.optionals (stdenv.hostPlatform != stdenv.buildPlatform) [
    "-DIMPORT_ICAL_GLIB_SRC_GENERATOR=${lib.getDev pkgsBuildBuild.libical}/lib/cmake/LibIcal/IcalGlibSrcGenerator.cmake"
  ];

  # Using install check so we do not have to manually set GI_TYPELIB_PATH
  # Musl does not support TZDIR.
  doInstallCheck = !stdenv.hostPlatform.isMusl;

  nativeInstallCheckInputs = [
    # running libical-glib tests
    (python3.pythonOnBuildForHost.withPackages (
      pkgs: with pkgs; [
        pygobject3
      ]
    ))
  ];

  installCheckPhase = ''
    runHook preInstallCheck

    export TZDIR=${tzdata}/share/zoneinfo
    ctest --output-on-failure

    runHook postInstallCheck
  '';

  depsBuildBuild = lib.optionals (stdenv.hostPlatform != stdenv.buildPlatform) [
    # provides ical-glib-src-generator that runs during build
    libical
  ];

  enableParallelChecking = false;

  preInstallCheck =
    if stdenv.hostPlatform.isDarwin then
      ''
        for testexe in $(find ./src/test -maxdepth 1 -type f -executable); do
          for lib in $(cd lib && ls *.3.dylib); do
            install_name_tool -change $lib $out/lib/$lib $testexe
          done
        done
      ''
    else
      null;

  meta = {
    description = "Open Source implementation of the iCalendar protocols";
    homepage = "https://github.com/libical/libical";
    changelog = "https://github.com/libical/libical/raw/v${finalAttrs.version}/ReleaseNotes.txt";
    license = lib.licenses.mpl20;
    platforms = lib.platforms.unix;
  };
})
