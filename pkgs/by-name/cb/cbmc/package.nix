{
  lib,
  stdenv,
  fetchFromGitHub,
  bison,
  cadical,
  cmake,
  cudd,
  fetchpatch,
  flex,
  makeWrapper,
  nix-update-script,
  perl,
  replaceVars,
  versionCheckHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "cbmc";
  version = "6.10.0";

  src = fetchFromGitHub {
    owner = "diffblue";
    repo = "cbmc";
    tag = "cbmc-${finalAttrs.version}";
    hash = "sha256-GCagpb2TFhOEH+lzMth+PWiJxlEw0L+H1DYUEQoMF3g=";
  };

  patches = [
    (replaceVars ./0001-Do-not-download-sources-in-cmake.patch {
      cudd = cudd.src;
    })
    ./0002-Do-not-download-sources-in-cmake.patch
  ];

  postPatch = ''
    # fix library_check.sh interpreter error
    patchShebangs .

    mkdir -p srccadical
    cp -r ${finalAttrs.srccadical}/* srccadical

    mkdir -p srcglucose
    cp -r ${finalAttrs.srcglucose}/* srcglucose
    find -exec chmod +w {} \;

    substituteInPlace src/solvers/CMakeLists.txt \
     --replace-fail "@srccadical@" "$PWD/srccadical" \
     --replace-fail "@srcglucose@" "$PWD/srcglucose"
  ''
  + lib.optionalString (!stdenv.cc.isGNU) ''
    # goto-gcc rely on gcc
    substituteInPlace "regression/CMakeLists.txt" \
      --replace-fail "add_subdirectory(goto-gcc)" ""
  '';

  nativeBuildInputs = [
    bison
    cmake
    flex
    perl
    makeWrapper
  ];

  # TODO: add jbmc support
  cmakeFlags = [
    "-DWITH_JBMC=OFF"
    "-Dsat_impl=cadical"
  ];

  env.NIX_CFLAGS_COMPILE = toString (
    lib.optionals stdenv.cc.isClang [
      # fix "argument unused during compilation"
      "-Wno-unused-command-line-argument"
      # fix "variable 'plus_overflow' set but not used"
      "-Wno-error=unused-but-set-variable"
      # fix "passing no argument for the '...' parameter of a variadic macro is a C++20 extension"
      "-Wno-error=c++20-extensions"
      # fix "first argument in call to 'memset' is a pointer to non-trivially copyable type"
      "-Wno-error=nontrivial-memcall"
    ]
  );

  postInstall = ''
    # goto-cc expects ls_parse.py in PATH
    mkdir -p $out/share/cbmc
    mv $out/bin/ls_parse.py $out/share/cbmc/ls_parse.py
    chmod +x $out/share/cbmc/ls_parse.py
    wrapProgram $out/bin/goto-cc \
      --prefix PATH : "$out/share/cbmc"
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  srccadical =
    (cadical.override {
      version = "3.0.0";
    }).src;

  srcglucose = fetchFromGitHub {
    hash = "sha256-+KrnXEJe7ApSuj936T615DaXOV+C2LlRxc213fQI+Q4=";
    owner = "brunodutertre";
    repo = "glucose-syrup";
    rev = "0bb2afd3b9baace6981cbb8b4a1c7683c44968b7";
  };

  versionCheckProgram = "${placeholder "out"}/bin/cbmc";

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version-regex"
      "cbmc-(.*)"
    ];
  };

  meta = {
    description = "Bounded Model Checker for C and C++ programs";
    homepage = "http://www.cprover.org/cbmc/";
    license = lib.licenses.bsdOriginal;
    maintainers = with lib.maintainers; [ jiegec ];
    platforms = lib.platforms.unix;
  };
})
