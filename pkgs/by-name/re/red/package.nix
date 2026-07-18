{
  lib,
  stdenv,
  fetchurl,
  fetchFromGitHub,
  pkgsi686Linux,
  stdenv_32bit,
}:

stdenv.mkDerivation rec {
  pname = "red";
  version = "0.6.4";

  src = fetchFromGitHub {
    owner = "red";
    repo = "red";
    rev = "755eb943ccea9e78c2cab0f20b313a52404355cb";
    sha256 = "sha256:045rrg9666zczgrwyyyglivzdzja103s52b0fzj7hqmr1fz68q37";
  };

  buildInputs = [
    pkgsi686Linux.curl
    stdenv_32bit
  ];

  buildPhase = ''
    # Do tests
    #${r2} -qw run-all.r

    # Build test
    ${r2} -qw red.r tests/hello.red

    # Compiling the Red console...
    ${r2} -qw red.r -r environment/console/CLI/console.red

    # Generating docs...
    cd docs
    ../${r2} -qw makedoc2.r red-system-specs.txt
    ../${r2} -qw makedoc2.r red-system-quick-test.txt
    cd ../
  '';

  installPhase = ''
    mkdir $out

    # Install
    install -d $out/opt/red
    find quick-test -type f -executable -print0 | xargs -0 rm
    cp -R * $out/opt/red/
    rm -rf $out/opt/red/rebol
    install -Dm755 console $out/bin/red
    install -Dm644 BSD-3-License.txt                          \
        $out/share/licenses/${pname}-${version}/BSD-3-License.txt
    install -Dm644 BSL-License.txt                            \
        $out/share/licenses/${pname}-${version}/BSL-License.txt
    install -Dm644 docs/red-system-quick-test.html            \
        $out/share/doc/${pname}-${version}/red-system-quick-test.html
    install -Dm644 docs/red-system-specs.html                 \
        $out/share/doc/${pname}-${version}/red-system-specs.html

    # PathElf
    patchelf --set-interpreter                            \
        ${stdenv_32bit.cc.libc.out}/lib/32/ld-linux.so.2  \
        $out/opt/red/console
    patchelf --set-rpath ${pkgsi686Linux.curl.out}/lib \
        $out/opt/red/console
    patchelf --set-interpreter                            \
        ${stdenv_32bit.cc.libc.out}/lib/32/ld-linux.so.2  \
        $out/bin/red
    patchelf --set-rpath ${pkgsi686Linux.curl.out}/lib \
        $out/bin/red

  '';

  configurePhase = ''
    # Download rebol
    mkdir rebol/
    tar -xzvf ${rebol} -C rebol/
    patchelf --set-interpreter \
        ${stdenv_32bit.cc.libc.out}/lib/32/ld-linux.so.2 \
        ${r2}
  '';

  r2 = "./rebol/releases/rebol-core/rebol";

  rebol = fetchurl {
    sha256 = "1c1v0pyhf3d8z98qc93a5zmx0bbl0qq5lr8mbkdgygqsq2bv2xbz";
    url = "http://www.rebol.com/downloads/v278/rebol-core-278-4-2.tar.gz";
    meta.license = lib.licenses.unfree; # https://www.rebol.com/license.html
  };

  meta = {
    description = ''
      New programming language strongly inspired by Rebol, but with a
      broader field of usage thanks to its native-code compiler, from system
      programming to high-level scripting, while providing modern support for
      concurrency and multi-core CPUs
    '';

    homepage = "https://www.red-lang.org/";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ uralbash ];

    platforms = [
      "i686-linux"
      "x86_64-linux"
    ];

    mainProgram = "red";
  };
}
