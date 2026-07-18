{
  lib,
  stdenv,
  fetchFromGitHub,
  installFonts,
  python3Packages,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "xits-math";
  version = "1.302";

  src = fetchFromGitHub {
    owner = "alif-type";
    repo = "xits";
    rev = "v${finalAttrs.version}";
    sha256 = "1x3r505dylz9rz8dj98h5n9d0zixyxmvvhnjnms9qxdrz9bxy9g1";
  };

  postPatch = ''
    rm *.otf
  '';

  nativeBuildInputs =
    (with python3Packages; [
      python
      fonttools
      fontforge
    ])
    ++ [ installFonts ];

  # installFonts adds a hook to `postInstall` that installs fonts
  # into the correct directories
  installPhase = ''
    runHook preInstall
    runHook postInstall
  '';

  meta = {
    description = "OpenType implementation of STIX fonts with math support";
    homepage = "https://github.com/alif-type/xits";
    license = lib.licenses.ofl;
    maintainers = [ ];
    platforms = lib.platforms.all;
  };
})
