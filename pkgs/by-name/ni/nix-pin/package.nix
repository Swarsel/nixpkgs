{
  lib,
  stdenv,
  fetchFromGitHub,
  git,
  makeWrapper,
  nix,
  pkgs,
  python3,
  runtimeShell,
}:
let
  self = stdenv.mkDerivation rec {
    pname = "nix-pin";
    version = "0.4.0";

    src = fetchFromGitHub {
      owner = "timbertson";
      repo = "nix-pin";
      rev = "version-${version}";
      sha256 = "1pccvc0iqapms7kidrh09g5fdx44x622r5l9k7bkmssp3v4c68vy";
    };

    nativeBuildInputs = [ makeWrapper ];
    buildInputs = [ python3 ];

    installPhase = ''
      mkdir "$out"
      cp -r bin share "$out"
      wrapProgram $out/bin/nix-pin \
        --prefix PATH : "${
          lib.makeBinPath [
            nix
            git
          ]
        }"
    '';

    passthru =
      let
        defaults = import "${self}/share/nix/defaults.nix";
      in
      {
        api =
          {
            pinConfig ? defaults.pinConfig,
          }:
          let
            impl = import "${self}/share/nix/api.nix" { inherit pkgs pinConfig; };
          in
          {
            inherit (impl) augmentedPkgs pins callPackage;
          };

        updateScript = ''
          #!${runtimeShell}
          set -e
          echo
          cd ${toString ./.}
          ${pkgs.nix-update-source}/bin/nix-update-source \
            --prompt version \
            --replace-attr version \
            --set owner timbertson \
            --set repo nix-pin \
            --set type fetchFromGitHub \
            --set rev 'version-{version}' \
            --substitute rev 'version-''${{version}}' \
            --modify-nix default.nix
        '';
      };

    meta = {
      description = "Nixpkgs development utility";
      homepage = "https://github.com/timbertson/nix-pin";
      license = lib.licenses.mit;
      maintainers = [ lib.maintainers.timbertson ];
      platforms = lib.platforms.all;
      mainProgram = "nix-pin";
    };
  };
in
self
