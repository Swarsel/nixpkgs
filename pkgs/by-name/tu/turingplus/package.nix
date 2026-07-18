{
  lib,
  stdenv,
  fetchFromGitHub,
  callPackage,
  bootstrap ? callPackage ./bootstrap.nix { },
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "turingplus";
  version = "6.2.1";

  src = fetchFromGitHub {
    owner = "CordyJ";
    repo = "Open-TuringPlus";
    tag = "v${finalAttrs.version}";
    hash = "sha256-jiMbSuNg2o9fNCPNoLpyAdMCxgMVBiDjRhC0HgKwmqk=";
  };

  # Patch required to fix compilation errors when certain C input files are used with tpc
  patches = [ ./use-gnu89.patch ];

  postPatch = ''
    # Replace hardcoded paths in source
    find src -type f -exec sed -i \
      -e "s#/usr/local/lib/tplus#$out/lib#g" \
      -e "s#/local/lib/tplus#$out/lib#g" \
      -e "s#/usr/local/include/tplus#$out/include#g" \
      -e "s#/local/include/tplus#$out/include#g" \
      -e "s#/usr/local/bin#$out/bin#g" \
      -e "s#/bin/rm#rm#g" \
      {} +

    # Use proper C compiler for target
    substituteInPlace src/cmd/lib/* \
      --replace-fail 'cc ' '${stdenv.cc}/bin/cc '
  '';

  nativeBuildInputs = [ bootstrap ];

  buildFlags = [
    "INCLUDE_DIR=${bootstrap}/include"
    "TPC=${bootstrap}/bin/tpc"
  ];

  # Using -std=gnu89 to prevent errors that occur with default args
  env.NIX_CFLAGS_COMPILE = "-std=gnu89 -Wno-int-conversion";
  checkFlags = [ "-C test" ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{bin,lib,include}
    cp bin/* $out/bin/
    cp lib/* $out/lib/
    cp -r include/* $out/include/

    runHook postInstall
  '';

  checkTarget = "all";

  meta = {
    description = "Extended version of the Turing programming language with concurrency and systems programming features";
    homepage = "https://github.com/CordyJ/Open-TuringPlus";
    changelog = "https://github.com/CordyJ/Open-TuringPlus/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ MysteryBlokHed ];

    platforms = [
      "x86_64-linux"
    ];

    mainProgram = "tpc";
    downloadPage = "https://github.com/CordyJ/Open-TuringPlus/releases";
  };
})
