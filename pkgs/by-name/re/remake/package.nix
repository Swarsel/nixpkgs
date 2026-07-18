{
  lib,
  stdenv,
  fetchurl,
  fetchpatch,
  guile,
  pkg-config,
  readline,
  guileSupport ? false,
}:

stdenv.mkDerivation rec {
  pname = "remake";
  version = "${remakeVersion}+dbg-${dbgVersion}";

  src = fetchurl {
    url = "mirror://sourceforge/project/bashdb/remake/${version}/remake-${remakeVersion}+dbg-${dbgVersion}.tar.gz";
    sha256 = "11vvch8bi0yhjfz7gn92b3xmmm0cgi3qfiyhbnnj89frkhbwd87n";
  };

  patches = [
    ./glibc-2.27-glob.patch
    (fetchpatch {
      hash = "sha256-Pau0ho0stPFnJjsHKY6lIag/XV4A0bEKBLPp3XRcxc8=";
      name = "gcc15-tolerance.patch";
      url = "https://github.com/Trepan-Debuggers/remake/commit/15f36a69b1a7798fa836d849c68c0fa5cd1dae6f.patch";
    })
  ];

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [ readline ] ++ lib.optionals guileSupport [ guile ];
  dbgVersion = "1.6";
  remakeVersion = "4.3";

  # make check fails, see https://github.com/rocky/remake/issues/117
  meta = {
    description = "GNU Make with comprehensible tracing and a debugger";
    homepage = "https://bashdb.sourceforge.net/remake/";
    license = lib.licenses.gpl3Plus;

    maintainers = with lib.maintainers; [
      bjornfor
    ];

    platforms = with lib.platforms; linux ++ darwin;
    mainProgram = "remake";
  };
}
