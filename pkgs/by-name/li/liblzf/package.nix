{
  lib,
  stdenv,
  fetchurl,
  autoconf,
  automake,
  fetchDebianPatch,
  fetchpatch,
  libtool,
  pkg-config,
  testers,
  validatePkgConfig,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "liblzf";
  version = "3.6";

  src = fetchurl {
    url = "https://dist.schmorp.de/liblzf/liblzf-${finalAttrs.version}.tar.gz";
    hash = "sha256-nF3gH3ucyuQMP2GdJqer7JmGwGw20mDBec7dBLiftGo=";
  };

  outputs = [
    "out"
    "dev"
  ];

  patches = [
    (fetchDebianPatch {
      inherit (finalAttrs) pname version;
      debianRevision = "4";
      hash = "sha256-Rgfp/TysRcEJaogOo/Xno+G4HZzj9Loa69DL43Bp1Ok=";
      patch = "0001-Make-sure-that-the-library-is-linked-with-C-symbols.patch";
    })
    (
      let
        name = "liblzf-3.6-autoconf-20140314.patch";
      in
      fetchpatch {
        inherit name;
        hash = "sha256-rkhI8w0HV3fGiDfHiXBzrnxqGDE/Yo5ntePrsscMiyg=";
        url = "https://src.fedoraproject.org/rpms/liblzf/raw/53da654eead51a24ac81a28e1b1c531eb1afab28/f/${name}";
      }
    )
  ];

  nativeBuildInputs = [
    autoconf
    automake
    libtool
    pkg-config
    validatePkgConfig
  ];

  preConfigure = ''
    sh ./bootstrap.sh
  '';

  postInstall = ''
    pushd $out/bin
    ln -s lzf unlzf
    popd
  '';

  passthru.tests = {
    exeTest = testers.runCommand {
      buildInputs = [ finalAttrs.finalPackage ];
      name = "${finalAttrs.pname}-exe-test";

      script = ''
        lzf -h 2> /dev/null

        echo "LZFLZFLZFLZFLZFLZFLZFLZF" > test.txt

        # unlzf writes to filename minus ".lzf"
        cp test.txt test.txt.orig

        lzf test.txt
        unlzf test.txt.lzf

        # Compare results
        if ! cmp -s test.txt test.txt.orig; then
          echo "Executable test failed: files don't match"
          exit 1
        fi

        echo "Decompressed output matches test string (lzf & unlzf)"

        touch $out
      '';
    };

    pkgConfigTest = testers.hasPkgConfigModules {
      version = "${finalAttrs.version}.0";
      package = finalAttrs.finalPackage;
      versionCheck = true;
    };

    shlibTest = testers.runCommand {
      inherit stdenv; # with CC
      nativeBuildInputs = [ pkg-config ];

      buildInputs = [
        finalAttrs.finalPackage.dev
        finalAttrs.finalPackage
      ];

      name = "${finalAttrs.pname}-shlib-test";

      # tests both the library and pkg-config file
      script = ''
        $CC -g ${./lib_test.c} -o lib_test \
          $(pkg-config --cflags --libs liblzf)

        ./lib_test >/dev/null

        echo "Built and tested file linked against liblzf using pkg-config"
        touch $out
      '';
    };
  };

  meta = {
    description = "Small data compression library";
    homepage = "http://software.schmorp.de/pkg/liblzf.html";

    changelog =
      "http://cvs.schmorp.de/liblzf/Changes?pathrev=rel-"
      + builtins.replaceStrings [ "." ] [ "_" ] finalAttrs.version;

    license = with lib.licenses; [
      bsd2
      gpl2Plus
    ];

    maintainers = with lib.maintainers; [
      tetov
    ];

    platforms = lib.platforms.unix;
    mainProgram = "lzf";
    downloadPage = "http://dist.schmorp.de/liblzf/";
    pkgConfigModules = [ "liblzf" ];
  };
})
