{
  lib,
  boost,
  fetchzip,
  fmt_9,
  gmpxx,
  libelf,
  libunwind,
  llvmPackages_18,
  ninja,
  pkg-config,
  sbcl,
}:

let
  inherit (llvmPackages_18) stdenv llvm libclang;
in

stdenv.mkDerivation rec {
  pname = "clasp";
  version = "2.7.0";

  src = fetchzip {
    url = "https://github.com/clasp-developers/clasp/releases/download/${version}/clasp-${version}.tar.gz";
    hash = "sha256-IoEwsMvY/bbb6K6git+7zRGP0DIJDROt69FBQuzApRk=";
  };

  patches = [
    ./remove-unused-command-line-argument.patch
  ];

  # Workaround for https://github.com/clasp-developers/clasp/issues/1590
  postPatch = ''
    echo '(defmethod configure-unit (c (u (eql :git))))' >> src/koga/units.lisp
  '';

  nativeBuildInputs = [
    sbcl
    pkg-config
    fmt_9
    gmpxx
    libelf
    boost
    libunwind
    ninja
    llvm
    libclang
  ];

  postInstall = ''
    # --dylib-path not honored. Fix it in post.
    mv $out/libclasp* $out/lib/
  '';

  configurePhase = ''
    export SOURCE_DATE_EPOCH=1
    export ASDF_OUTPUT_TRANSLATIONS=$(pwd):$(pwd)/__fasls
    sbcl --script koga \
      --skip-sync \
      --build-mode=bytecode-faso \
      --cc=$NIX_CC/bin/cc \
      --cxx=$NIX_CC/bin/c++ \
      --reproducible-build \
      --package-path=/ \
      --bin-path=$out/bin \
      --lib-path=$out/lib \
      --dylib-path=$out/lib \
      --share-path=$out/share \
      --pkgconfig-path=$out/lib/pkgconfig
  '';

  ninjaFlags = [
    "-C"
    "build"
  ];

  meta = {
    description = "Common Lisp implementation based on LLVM with C++ integration";
    homepage = "https://github.com/clasp-developers/clasp";
    license = lib.licenses.lgpl21Plus;

    platforms = [
      "x86_64-linux"
    ];

    mainProgram = "clasp";
    teams = [ lib.teams.lisp ];
  };
}
