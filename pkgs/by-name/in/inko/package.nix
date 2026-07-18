{
  lib,
  stdenv,
  fetchFromGitHub,
  callPackage,
  libffi,
  libxml2,
  libz,
  llvm,
  makeWrapper,
  ncurses,
  nix-update-script,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "inko";
  version = "0.20.0";

  src = fetchFromGitHub {
    owner = "inko-lang";
    repo = "inko";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Bisw84MwdLb2pgzwQ5zpZiyNHSWtdJ2QpaFn40x+SdI=";
  };

  nativeBuildInputs = [
    llvm
    makeWrapper
  ];

  buildInputs = [
    libffi
    libz
    libxml2
    ncurses
    (lib.getLib stdenv.cc.cc)
  ];

  cargoHash = "sha256-+3U3rMVF3qwyTIGOb/6NIxSBdiLuf/uY/VL3tYHte+c=";

  env = {
    INKO_RT = "${placeholder "out"}/lib/runtime";
    INKO_STD = "${placeholder "out"}/lib";
  };

  postInstall = ''
    mkdir -p $out/lib/runtime
    mv $out/lib/*.a $out/lib/runtime/
    cp -r std/src/* $out/lib/
  '';

  postFixup = ''
    wrapProgram $out/bin/inko \
      --prefix PATH : ${lib.makeBinPath [ stdenv.cc ]}
  '';

  __darwinAllowLocalNetworking = true;

  passthru = {
    tests = {
      simple = callPackage ./test.nix { };
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "Language for building concurrent software with confidence";
    homepage = "https://inko-lang.org/";
    license = lib.licenses.mpl20;
    maintainers = [ lib.maintainers.feathecutie ];
    platforms = lib.platforms.unix;
    mainProgram = "inko";
    teams = [ lib.teams.ngi ];
  };
})
