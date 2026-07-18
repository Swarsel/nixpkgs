{
  lib,
  stdenv,
  fetchFromGitHub,
}:
let
  version = "3.0.0";
in
stdenv.mkDerivation {
  inherit version;
  pname = "lavat";

  src = fetchFromGitHub {
    owner = "AngelJumbo";
    repo = "lavat";
    rev = "v${version}";
    hash = "sha256-yroJQzcg8a0dSZu1I4jcqgrjwhtd5065+9rwtU5/vpc=";
  };

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp lavat $out/bin
    runHook postInstall
  '';

  meta = {
    description = "Lava lamp simulation in the terminal";

    longDescription = ''
      Lavat puts ascii metaballs in your terminal to make it look a bit like a
      lava lamp.

      Lavat contains various options, including those to change the color and
      speed of the metaballs. For a full list, run `lavat -h`
    '';

    homepage = "https://github.com/AngelJumbo/lavat";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.minion3665 ];
    platforms = lib.platforms.all;
    mainProgram = "lavat";
  };
}
