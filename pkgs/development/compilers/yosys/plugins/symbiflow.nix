{
  lib,
  stdenv,
  fetchFromGitHub,
  gtest,
  pkg-config,
  python3,
  readline,
  yosys,
  yosys-symbiflow,
  zlib,
}:
let

  version = "1.20230906";

  src = fetchFromGitHub {
    owner = "chipsalliance";
    repo = "yosys-f4pga-plugins";
    rev = "v${version}";
    hash = "sha256-XIn5wFw8i2njDN0Arua5BdZ0u1q6a/aJAs48YICehsc=";
  };

  # Supported symbiflow plugins.
  #
  # The following are disabled:
  #
  # "ql-qlf" builds but fails to load the plugin, so is not currently supported.
  plugins = [
    "design_introspection"
    "fasm"
    "integrateinv"
    "params"
    "ql-iob"
    # "ql-qlf"
    "sdc"
    "xdc"
  ];

  static_gtest = gtest.overrideAttrs (old: {
    cmakeFlags = old.cmakeFlags ++ [ "-DBUILD_SHARED_LIBS=OFF" ];
    dontDisableStatic = true;
  });

in
lib.genAttrs plugins (
  plugin:
  stdenv.mkDerivation rec {
    inherit src version plugin;
    pname = "yosys-symbiflow-${plugin}-plugin";

    nativeBuildInputs = [
      python3
      pkg-config
    ];

    buildInputs = [
      yosys
      readline
      zlib
    ];

    makeFlags = [
      "PLUGIN_LIST=${plugin}"
    ];

    buildFlags = [
      "YOSYS_PLUGINS_DIR=\${out}/share/yosys/plugins/"
      "YOSYS_DATA_DIR=\${out}/share/yosys/"
    ];

    # A Makefile rule tries to wget-fetch a yosys script from github.
    # Link the script from our yosys sources in preBuild instead, so that
    # the Makefile rule is a no-op.
    preBuild = ''
      ln -s ${yosys.src}/passes/pmgen/pmgen.py pmgen.py
    '';

    # xdc has an incorrect path to a test which has yet to be patched
    doCheck = plugin != "xdc";
    nativeCheckInputs = [ static_gtest ];

    checkFlags = [
      (
        "NIX_YOSYS_PLUGIN_DIRS=\${NIX_BUILD_TOP}/source/${plugin}-plugin/build"
        # sdc and xdc plugins use design introspection for their tests
        + (lib.optionalString (
          plugin == "sdc" || plugin == "xdc"
        ) ":${yosys-symbiflow.design_introspection}/share/yosys/plugins/")
      )
    ];

    checkTarget = "test";
    enableParallelBuilding = true;
    installFlags = buildFlags;

    # Providing a symlink avoids the need for patching the test makefile
    postUnpack = ''
      mkdir -p source/third_party/googletest/build/
      ln -s ${static_gtest}/lib source/third_party/googletest/build/lib
    '';

    meta = {
      description = "Symbiflow ${plugin} plugin for Yosys";
      license = lib.licenses.isc;

      maintainers = with lib.maintainers; [
        ollieB
        thoughtpolice
      ];

      platforms = lib.platforms.all;
    };
  }
)
