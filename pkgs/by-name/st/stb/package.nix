{
  lib,
  stdenv,
  fetchFromGitHub,
  copyPkgconfigItems,
  makePkgconfigItem,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "stb";
  version = "0-unstable-2023-01-29";

  src = fetchFromGitHub {
    owner = "nothings";
    repo = "stb";
    rev = "5736b15f7ea0ffb08dd38af21067c314d6a3aae9";
    hash = "sha256-s2ASdlT3bBNrqvwfhhN6skjbmyEnUgvNOrvhgUSRj98=";
  };

  nativeBuildInputs = [ copyPkgconfigItems ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/include/stb
    cp *.h $out/include/stb/
    cp *.c $out/include/stb/
    runHook postInstall
  '';

  dontBuild = true;

  pkgconfigItems = [
    (makePkgconfigItem rec {
      inherit (finalAttrs.meta) description;
      version = "1";
      cflags = [ "-I${variables.includedir}/stb" ];
      name = "stb";

      variables = rec {
        includedir = "${prefix}/include";
        prefix = "${placeholder "out"}";
      };
    })
  ];

  meta = {
    description = "Single-file public domain libraries for C/C++";
    homepage = "https://github.com/nothings/stb";

    license = with lib.licenses; [
      mit
      # OR
      unlicense
    ];

    maintainers = [ ];
    platforms = lib.platforms.all;
  };
})
