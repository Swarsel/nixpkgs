{
  lib,
  stdenv,
  fetchFromGitHub,
  # nativeBuildInputs
  bison,
  flex,
  # tests
  gtkwave,
  iverilog,
  # propagatedBuildInputs
  libffi,
  makeWrapper,
  nix-update-script,
  pkg-config,
  python3,
  readline,
  # passthru
  symlinkJoin,
  tcl,
  yosys,
  yosys-bluespec,
  yosys-ghdl,
  yosys-symbiflow,
  zlib,
  enablePython ? true, # enable python binding
}:

let
  withPlugins =
    plugins:
    let
      paths = lib.closePropagation plugins;
      libExt = stdenv.hostPlatform.extensions.sharedLibrary;
      pluginPath = "$out/share/yosys/plugins";
      module_flags =
        with builtins;
        concatStringsSep " " (
          map (n: "--add-flags -m --add-flags ${pluginPath}/${n.plugin}${libExt}") plugins
        );
    in
    lib.appendToName "with-plugins" (symlinkJoin {
      inherit (yosys) name;
      nativeBuildInputs = [ makeWrapper ];

      postBuild = ''
        wrapProgram $out/bin/yosys \
          --set YOSYS_PATH $out/share/yosys \
          --set YOSYS_PLUGIN_PATH ${pluginPath} \
          ${module_flags}
      '';

      paths = paths ++ [ yosys ];
      meta.mainProgram = "yosys";
    });

  allPlugins = {
    bluespec = yosys-bluespec;
    ghdl = yosys-ghdl;
  }
  // yosys-symbiflow;

in
stdenv.mkDerivation (finalAttrs: {
  pname = "yosys";
  version = "0.62";

  src = fetchFromGitHub {
    owner = "YosysHQ";
    repo = "yosys";
    tag = "v${finalAttrs.version}";
    hash = "sha256-FzvdjdAURB5iCkGwsYY6A2wP/Je/IW4AOd4kVOEOeVc=";
    fetchSubmodules = true;
  };

  postPatch = ''
    substituteInPlace Makefile \
      --replace-fail 'GIT_REV := $(shell GIT_DIR=$(YOSYS_SRC)/.git git rev-parse --short=9 HEAD || echo UNKNOWN)' 'GIT_REV := v${finalAttrs.version}' \
      --replace-fail 'GIT_DIRTY := $(shell GIT_DIR=$(YOSYS_SRC)/.git git diff --exit-code --quiet 2>/dev/null; if [ $$? -ne 0 ]; then echo "-dirty"; fi)' 'GIT_DIRTY := ""'

    substituteInPlace Makefile \
      --replace-fail "| check-git-abc" ""

    substituteInPlace Makefile \
      --replace-fail 'new=$$(cd abc 2>/dev/null && git rev-parse HEAD 2>/dev/null || echo none)' 'new=none'

    sed -i 's/^YOSYS_VER :=.*/YOSYS_VER := ${finalAttrs.version}/' Makefile

    patchShebangs tests ./misc/yosys-config.in
  '';

  nativeBuildInputs = [
    bison
    flex
    pkg-config
  ];

  propagatedBuildInputs = [
    libffi
    readline
    tcl
    zlib
    (python3.withPackages (
      pp: with pp; [
        click
        cxxheaderparser
        pybind11
      ]
    ))
  ]
  ++ lib.optionals enablePython [
    python3.pkgs.boost
  ];

  makeFlags = [
    "PREFIX=${placeholder "out"}"
    "YOSYS_VER=${finalAttrs.version}"
  ];

  preBuild = ''
    chmod -R u+w .
    make config-${if stdenv.cc.isClang or false then "clang" else "gcc"}

    if ! grep -q "YOSYS_VER := ${finalAttrs.version}" Makefile; then
      echo "ERROR: yosys version in Makefile isn't equivalent to version of the nix package, failing."
      exit 1
    fi
  ''
  + lib.optionalString enablePython ''
    echo "PYOSYS_USE_UV := 0" >> Makefile.conf
    echo "ENABLE_PYOSYS := 1" >> Makefile.conf
    echo "PYTHON_DESTDIR := $out/${python3.sitePackages}" >> Makefile.conf
    echo "BOOST_PYTHON_LIB := -lboost_python${lib.versions.major python3.version}${lib.versions.minor python3.version}" >> Makefile.conf
  '';

  doCheck = true;

  nativeCheckInputs = [
    gtkwave
    iverilog
  ];

  preCheck = ''
    tests/tools/autotest.sh
  '';

  checkTarget = "test";
  enableParallelBuilding = true;
  setupHook = ./setup-hook.sh;

  passthru = {
    inherit withPlugins allPlugins;
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Open RTL synthesis framework and tools";
    homepage = "https://yosyshq.net/yosys/";
    changelog = "https://github.com/YosysHQ/yosys/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.isc;

    maintainers = with lib.maintainers; [
      shell
      thoughtpolice
      Luflosi
    ];

    platforms = lib.platforms.all;
    mainProgram = "yosys";
  };
})
