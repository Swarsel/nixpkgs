{
  lib,
  stdenv,
  fetchurl,
  coq,
  eprover,
  makeWrapper,
  ocaml-ng,
  which,
  zlib,
}:

let
  inherit (ocaml-ng.ocamlPackages_4_14) ocaml;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "satallax";
  version = "2.7";

  src = fetchurl {
    url = "https://www.ps.uni-saarland.de/~cebrown/satallax/downloads/satallax-${finalAttrs.version}.tar.gz";
    sha256 = "1kvxn8mc35igk4vigi5cp7w3wpxk2z3bgwllfm4n3h2jfs0vkpib";
  };

  patches = [
    # GCC9 doesn't allow default value in friend declaration.
    ./fix-declaration-gcc9.patch
  ];

  strictDeps = true;

  nativeBuildInputs = [
    makeWrapper
    ocaml
    which
    eprover
    coq
  ];

  buildInputs = [ zlib ];
  # error: invalid suffix on literal; C++11 requires a space between literal and identifier
  env.NIX_CFLAGS_COMPILE = lib.optionalString stdenv.hostPlatform.isDarwin "-Wno-reserved-user-defined-literal";

  preConfigure = ''
    mkdir fake-tools
    echo "echo 'Nix-build-host.localdomain'" > fake-tools/hostname
    chmod a+x fake-tools/hostname
    export PATH="$PATH:$PWD/fake-tools"

    (
      cd picosat-*
      ./configure
      make
    )
    export PATH="$PATH:$PWD/libexec/satallax"

    mkdir -p "$out/libexec/satallax"
    cp picosat-*/picosat picosat-*/picomus "$out/libexec/satallax"

    (
      cd minisat
      export MROOT=$PWD
      cd core
      make
      cd ../simp
      make
    )
  '';

  doCheck = stdenv.hostPlatform.isLinux;

  checkPhase = ''
    runHook preCheck
    if bash ./test | grep ERROR; then
      echo "Tests failed"
      exit 1
    fi
    runHook postCheck
  '';

  installPhase = ''
    mkdir -p "$out/share/doc/satallax" "$out/bin" "$out/lib" "$out/lib/satallax"
    cp bin/satallax.opt "$out/bin/satallax"
    wrapProgram "$out/bin/satallax" \
      --suffix PATH : "${
        lib.makeBinPath [
          coq
          eprover
        ]
      }:$out/libexec/satallax" \
      --add-flags "-M" --add-flags "$out/lib/satallax/modes"

    cp LICENSE README "$out/share/doc/satallax"

    cp bin/*.so "$out/lib"

    cp -r modes "$out/lib/satallax/"
    cp -r problems "$out/lib/satallax/"
    cp -r coq* "$out/lib/satallax/"
  '';

  prePatch = ''
    patch -p1 -i ${./minisat-fenv.patch} -d minisat
  '';

  meta = {
    description = "Automated theorem prover for higher-order logic";
    homepage = "http://www.ps.uni-saarland.de/~cebrown/satallax/index.php";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.raskin ];
    platforms = lib.platforms.unix;
    mainProgram = "satallax";
    downloadPage = "http://www.ps.uni-saarland.de/~cebrown/satallax/downloads.php";
  };
})
