{
  lib,
  stdenv,
  fetchFromGitHub,
  makeWrapper,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "chibi-scheme";
  version = "0.12";

  src = fetchFromGitHub {
    owner = "ashinn";
    repo = "chibi-scheme";
    rev = finalAttrs.version;
    sha256 = "sha256-TQT3/fZqgQP5UfCKN1ShvGgxdjfNdUWnpqdHKQMJHzY=";
  };

  nativeBuildInputs = [ makeWrapper ];

  makeFlags = [
    "PREFIX=${placeholder "out"}"
  ];

  fixupPhase = ''
    wrapProgram "$out/bin/chibi-scheme" \
      --prefix CHIBI_MODULE_PATH : "$out/share/chibi:$out/lib/chibi" \
      ${lib.optionalString stdenv.hostPlatform.isDarwin "--prefix DYLD_LIBRARY_PATH : $out/lib"}

    for f in chibi-doc chibi-ffi snow-chibi; do
      substituteInPlace "$out/bin/$f" \
        --replace "/usr/bin/env chibi-scheme" "$out/bin/chibi-scheme"
    done
  '';

  meta = {
    description = "Small Footprint Scheme for use as a C Extension Language";
    homepage = "https://github.com/ashinn/chibi-scheme";
    license = lib.licenses.bsd3;

    maintainers = with lib.maintainers; [
      applePrincess
      DerGuteMoritz
    ];

    platforms = lib.platforms.all;
  };
})
