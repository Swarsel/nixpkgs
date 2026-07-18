{
  lib,
  stdenv,
  fetchurl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "parse-cli-bin";
  version = "3.0.5";

  src = fetchurl {
    url = "https://github.com/ParsePlatform/parse-cli/releases/download/release_${finalAttrs.version}/parse_linux";
    sha256 = "1iyfizbbxmr87wjgqiwqds51irgw6l3vm9wn89pc3zpj2zkyvf5h";
  };

  installPhase = ''
    mkdir -p "$out/bin"
    cp "$src" "$out/bin/parse"
    chmod +x "$out/bin/parse"
  '';

  dontUnpack = true;

  meta = {
    description = "Parse Command Line Interface";
    homepage = "https://parse.com";
    license = lib.licenses.bsd3;
    platforms = lib.platforms.linux;
    mainProgram = "parse";
  };
})
