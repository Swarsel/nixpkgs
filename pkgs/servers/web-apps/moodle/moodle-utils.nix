{ stdenv, unzip, ... }:

let
  buildMoodlePlugin =
    a@{
      name,
      pluginType,
      src,
      buildInputs ? [ ],
      buildPhase ? ":",
      configurePhase ? ":",
      nativeBuildInputs ? [ ],
      ...
    }:
    stdenv.mkDerivation (
      a
      // {
        inherit pluginType;
        inherit configurePhase buildPhase buildInputs;
        nativeBuildInputs = [ unzip ] ++ nativeBuildInputs;

        installPhase = ''
          runHook preInstall

          mkdir -p "$out"
          mv * $out/

          runHook postInstall
        '';

        name = name;
      }
    );
in
{
  inherit buildMoodlePlugin;
}
