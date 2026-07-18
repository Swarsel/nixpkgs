{
  lib,
  stdenv,
  fetchurl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "915resolution";
  version = "0.5.3";

  src = fetchurl {
    url = "http://915resolution.mango-lang.org/915resolution-${finalAttrs.version}.tar.gz";
    sha256 = "0hmmy4kkz3x6yigz6hk99416ybznd67dpjaxap50nhay9f1snk5n";
  };

  installPhase = "mkdir -p $out/sbin; cp 915resolution $out/sbin/";
  patchPhase = "rm *.o";

  meta = {
    description = "Tool to modify Intel 800/900 video BIOS";
    homepage = "http://915resolution.mango-lang.org/";
    license = lib.licenses.publicDomain;

    platforms = [
      "i686-linux"
      "x86_64-linux"
    ];

    mainProgram = "915resolution";
  };
})
