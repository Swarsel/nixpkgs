{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  lzmaSupport ? true,
  xz ? null,
}:

assert lzmaSupport -> xz != null;

let
  mkWith = flag: name: if flag then "--with-${name}" else "--without-${name}";
in
stdenv.mkDerivation (finalAttrs: {
  pname = "xdelta";
  version = "3.1.0";

  src = fetchFromGitHub {
    owner = "jmacd";
    repo = "xdelta-devel";
    rev = "v${finalAttrs.version}";
    sha256 = "09mmsalc7dwlvgrda56s2k927rpl3a5dzfa88aslkqcjnr790wjy";
  };

  postPatch = ''
    cd xdelta3
  '';

  nativeBuildInputs = [ autoreconfHook ];
  buildInputs = [ ] ++ lib.optionals lzmaSupport [ xz ];

  configureFlags = [
    (mkWith lzmaSupport "liblzma")
  ];

  doCheck = true;

  checkPhase = ''
    mkdir $PWD/tmp
    for i in testing/file.h xdelta3-test.h; do
      substituteInPlace $i --replace /tmp $PWD/tmp
    done
    ./xdelta3regtest
  '';

  installPhase = ''
    install -D -m755 xdelta3 $out/bin/xdelta3
    install -D -m644 xdelta3.1 $out/share/man/man1/xdelta3.1
  '';

  enableParallelBuilding = true;

  meta = {
    description = "Binary differential compression in VCDIFF (RFC 3284) format";

    longDescription = ''
      xdelta is a command line program for delta encoding, which generates two
      file differences. This is similar to diff and patch, but it is targeted
      for binary files and does not generate human readable output.
    '';

    # The dedicated homepage pointed to a gambling website
    homepage = "https://github.com/jmacd/xdelta";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.unix;
    mainProgram = "xdelta3";
  };
})
