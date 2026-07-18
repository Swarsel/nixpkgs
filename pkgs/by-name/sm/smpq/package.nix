{
  lib,
  stdenv,
  fetchurl,
  cmake,
  stormlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "smpq";
  version = "1.6";

  src = fetchurl {
    url = "https://launchpad.net/smpq/trunk/${finalAttrs.version}/+download/smpq_${finalAttrs.version}.orig.tar.gz";
    hash = "sha256-tdLcil3oYptx7l02ErboTYhBi4bFzTm6MV6esEYvGMs=";
  };

  strictDeps = true;
  nativeBuildInputs = [ cmake ];
  buildInputs = [ stormlib ];

  cmakeFlags = [
    (lib.cmakeBool "WITH_KDE" false)
    "-DCMAKE_POLICY_VERSION_MINIMUM=3.5"
  ];

  meta = {
    description = "StormLib MPQ archiving utility";
    homepage = "https://launchpad.net/smpq";
    license = lib.licenses.gpl3Only;

    maintainers = with lib.maintainers; [
      aanderse
    ];

    platforms = lib.platforms.all;
    mainProgram = "smpq";
  };
})
