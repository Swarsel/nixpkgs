{
  stdenv,
  fetchzip,
  firefox-bin,
  revision,
  system,
  throwSystem,
}:
let
  download =
    (import ./browser-downloads.nix {
      inherit revision;
      name = "firefox";
    }).${system} or throwSystem;

  firefox-linux = stdenv.mkDerivation {
    inherit (firefox-bin.unwrapped)
      nativeBuildInputs
      buildInputs
      runtimeDependencies
      appendRunpaths
      patchelfFlags
      ;

    src = fetchzip {
      inherit (download) url stripRoot;

      hash =
        {
          aarch64-linux = "sha256-G0pcHmjRj5GKsDF7iHdQyGsJCiv4gqaFv2PwGa/t8bw=";
          x86_64-linux = "sha256-ol9Ai8BpstZdfd6v1NDq66BjLTr/5THya0Fk2z1toJg=";
        }
        .${system} or throwSystem;
    };

    buildPhase = ''
      mkdir -p $out/firefox
      cp -R . $out/firefox
    '';

    name = "playwright-firefox";
  };
  firefox-darwin = fetchzip {
    inherit (download) url stripRoot;

    hash =
      {
        aarch64-darwin = "sha256-Opwa5SbuAaXf2A+qrldHc6BkhRaOzzl0dy7R4vodG5w=";
      }
      .${system} or throwSystem;
  };
in
{
  aarch64-darwin = firefox-darwin;
  aarch64-linux = firefox-linux;
  x86_64-linux = firefox-linux;
}
.${system} or throwSystem
