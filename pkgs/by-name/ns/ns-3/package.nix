{
  lib,
  stdenv,
  fetchFromGitLab,
  boost,
  cmake,
  # for manual, tetex is used to get the eps2pdf binary
  # texlive to get latexmk. building manual still fails though
  dia,
  freetype,
  glib,
  gsl,
  gtk3-x11,
  harfbuzz,
  jansson,
  libpcap,
  libxml2,
  pkg-config,
  python3,
  root,
  sqlite,
  # for binding generation
  castxml ? null,
  cppyy ? null,
  doxygen ? null,
  # can take a long time, generates > 30000 images/graphs
  enableDoxygen ? false,
  ghostscript ? null,
  graphviz ? null,
  imagemagick ? null,
  ncurses ? null,
  # generates python bindings
  pythonSupport ? true,
  tetex ? null,
  texliveMedium ? null,
  # very long
  withManual ? false,
}:

let
  pythonEnv = python3.withPackages (
    ps:
    lib.optional withManual ps.sphinx
    ++ lib.optionals pythonSupport (
      with ps;
      [
        pybindgen
        pygccxml
        cppyy
      ]
    )
  );
in
stdenv.mkDerivation (finalAttrs: {
  pname = "ns-3";
  version = "47";

  src = fetchFromGitLab {
    owner = "nsnam";
    repo = "ns-3-dev";
    rev = "ns-3.${finalAttrs.version}";
    hash = "sha256-Av5Ret1v4RLafvYvUtCEh4Xb1ZwU3CgNOcDlRJrJsn8=";
  };

  outputs = [ "out" ];

  nativeBuildInputs = [
    cmake
    pkg-config
    pythonEnv
  ];

  # ncurses is a hidden dependency of waf when checking python
  buildInputs =
    lib.optionals pythonSupport [
      castxml
      ncurses
    ]
    ++ lib.optionals enableDoxygen [
      doxygen
      graphviz
      imagemagick
    ]
    ++ lib.optionals withManual [
      dia
      tetex
      ghostscript
      imagemagick
      texliveMedium
    ]
    ++ [
      libxml2
      pythonEnv
      sqlite.dev
      gsl
      boost
      root # provides cppyy
      glib.out
      glib.dev
      libpcap
      gtk3-x11.dev
      harfbuzz
      freetype
      jansson
    ];

  propagatedBuildInputs = [ pythonEnv ];

  cmakeFlags = [
    "-DPython3_LIBRARY_DIRS=${pythonEnv}/lib"
    "-DPython3_INCLUDE_DIRS=${pythonEnv}/include"
    "-DPython3_EXECUTABLE=${pythonEnv}/bin/python"
    "-DNS3_PYTHON_BINDINGS=ON"
    "-DNS3_DES_METRICS=ON"
    "-DNS3_BINDINGS_INSTALL_DIR=${pythonEnv.sitePackages}"
    "-DNS3_LOG=ON"
    "-DNS3_ASSERT=ON"
    "-DNS3_GTK3=ON"
    "-DGTK3_GLIBCONFIG_INCLUDE_DIR=${glib.out}/lib/glib-2.0/include"
  ]
  ++ lib.optional finalAttrs.doCheck "-DNS3_TESTS=ON";

  # to prevent fatal error: 'backward_warning.h' file not found
  env.CXXFLAGS = "-D_GLIBCXX_PERMIT_BACKWARD_HASH";

  preConfigure = ''
     substituteInPlace src/tap-bridge/CMakeLists.txt \
       --replace-fail '-DTAP_CREATOR="''${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/src/tap-bridge/' "-DTAP_CREATOR=\"$out/libexec/ns3/"

    substituteInPlace src/fd-net-device/CMakeLists.txt \
      --replace-fail '-DRAW_SOCK_CREATOR="''${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/src/fd-net-device/' "-DRAW_SOCK_CREATOR=\"$out/libexec/ns3/"

    substituteInPlace src/fd-net-device/CMakeLists.txt \
      --replace-fail '-DTAP_DEV_CREATOR="''${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/src/fd-net-device/' "-DTAP_DEV_CREATOR=\"$out/libexec/ns3/"
  '';

  doCheck = false;

  buildTargets =
    "build" + lib.optionalString enableDoxygen " doxygen" + lib.optionalString withManual "sphinx";

  # strictoverflow prevents clang from discovering pyembed when bindings
  hardeningDisable = [
    "fortify"
    "strictoverflow"
  ];

  # Make generated python bindings discoverable in customized python environment
  passthru = {
    pythonModule = python3;
  };

  meta = {
    description = "Discrete time event network simulator";
    homepage = "http://www.nsnam.org";
    license = lib.licenses.gpl3;

    maintainers = with lib.maintainers; [
      teto
      rgrunbla
    ];

    platforms = with lib.platforms; unix;

    # never built on aarch64-darwin since first introduction in nixpkgs
    broken =
      (stdenv.hostPlatform.isDarwin && stdenv.hostPlatform.isAarch64)
      || (stdenv.hostPlatform.isLinux && stdenv.hostPlatform.isAarch64);
  };
})
