{
  lib,
  fetchzip,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation rec {
  pname = "theano";
  version = "2.0";

  src = fetchzip {
    url = "https://github.com/akryukov/theano/releases/download/v${version}/theano-${version}.otf.zip";
    hash = "sha256-9wnwHcRHB+AToOvGwZSXvHkQ8hqMd7Sdl26Ty/IwbPw=";
    stripRoot = false;
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/fonts/opentype
    mkdir -p $out/share/doc/${pname}-${version}
    cp *.otf $out/share/fonts/opentype
    cp *.txt $out/share/doc/${pname}-${version}

    runHook postInstall
  '';

  meta = {
    description = "Old-style font designed from historic samples";
    homepage = "https://github.com/akryukov/theano";
    license = lib.licenses.ofl;

    maintainers = with lib.maintainers; [
      raskin
      rycee
    ];

    platforms = lib.platforms.all;
  };
}
