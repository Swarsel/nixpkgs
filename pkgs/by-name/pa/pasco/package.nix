{
  lib,
  stdenv,
  fetchurl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "pasco";
  version = "20040505_1";

  src = fetchurl {
    url = "mirror://sourceforge/project/fast/Pasco/Pasco%20v${finalAttrs.version}/pasco_${finalAttrs.version}.tar.gz";
    hash = "sha256-o7jue+lgVxQQvFZOzJMGd1WihlD7Nb+1WaSutq9vaGg=";
  };

  patches = [
    ./include-string.h.patch
  ];

  postPatch = ''
    substituteInPlace src/Makefile \
      --replace gcc cc
  '';

  makeFlags = [
    "-C src"
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp bin/pasco $out/bin
    runHook postInstall
  '';

  meta = {
    description = "Examine the contents of Internet Explorer's cache files for forensic purposes";
    homepage = "https://sourceforge.net/projects/fast/files/Pasco/";
    license = with lib.licenses; [ bsd3 ];
    maintainers = [ ];
    platforms = lib.platforms.unix;
    mainProgram = "pasco";
  };
})
