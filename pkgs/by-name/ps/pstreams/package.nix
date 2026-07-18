{
  lib,
  stdenv,
  fetchgit,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "PStreams";
  version = "1.0.1";

  src = fetchgit {
    url = "https://git.code.sf.net/p/pstreams/code";

    rev =
      let
        dot2Underscore = lib.strings.stringAsChars (c: if c == "." then "_" else c);
      in
      "RELEASE_${dot2Underscore finalAttrs.version}";

    sha256 = "0r8aj0nh5mkf8cvnzl8bdy4nm7i74vs83axxfimcd74kjfn0irys";
  };

  makeFlags = [ "prefix=${placeholder "out"}" ];
  doCheck = true;
  preInstall = "rm INSTALL";
  dontBuild = true;

  # `make install` fails on case-insensitive file systems (e.g. APFS by
  # default) because this target exists
  meta = {
    description = "POSIX Process Control in C++";

    longDescription = ''
      PStreams allows you to run another program from your C++ application and
      to transfer data between the two programs similar to shell pipelines.

      In the simplest case, a PStreams class is like a C++ wrapper for the
      POSIX.2 functions popen(3) and pclose(3), using C++ iostreams instead of
      C's stdio library.
    '';

    homepage = "https://pstreams.sourceforge.net/";
    license = lib.licenses.boost;
    maintainers = with lib.maintainers; [ arthur ];
    platforms = lib.platforms.all;
    downloadPage = "https://pstreams.sourceforge.net/download/";
  };
})
