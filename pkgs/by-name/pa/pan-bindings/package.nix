{
  lib,
  stdenv,
  fetchFromGitHub,
  asio,
  buildGoModule,
  cmake,
  ncurses,
}:

let
  version = "unstable-2025-06-15";
  src = fetchFromGitHub {
    owner = "lschulz";
    repo = "pan-bindings";
    rev = "708d7f36a0a32816b2b0d8e2e5a4d79f2144f406";
    hash = "sha256-wGHa8NV8M+9dHvn8UqejderyA1UgYQUcTOKocRFhg6U=";
  };
  goDeps = (
    buildGoModule {
      inherit src version;
      vendorHash = "sha256-3MybV76pHDnKgN2ENRgsyAvynXQctv0fJcRGzesmlww=";
      modRoot = "go";
      name = "pan-bindings-goDeps";
    }
  );
in

stdenv.mkDerivation {
  inherit src version;
  pname = "pan-bindings";

  nativeBuildInputs = [
    cmake
    goDeps.go
  ];

  buildInputs = [
    ncurses
    asio
  ];

  cmakeFlags = [
    "-DBUILD_SHARED_LIBS=1"
    "-DBUILD_EXAMPLES=0"
  ];

  patchPhase = ''
    runHook prePatch
    export HOME=$TMP
    cp -r --reflink=auto ${goDeps.goModules} go/vendor
    runHook postPatch
  '';

  meta = {
    description = "SCION PAN Bindings for C, C++, and Python";
    homepage = "https://github.com/lschulz/pan-bindings";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ matthewcroughan ];
    platforms = lib.platforms.all;
    mainProgram = "pan-bindings";
  };
}
