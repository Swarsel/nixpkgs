{
  lib,
  stdenv,
  fetchFromGitHub,
  imagemagick,
  jre,
  pkgs,
  runCommand,
  writeShellScript,
}:

# Jupyter console:
# nix run --impure --expr 'with import <nixpkgs> {}; jupyter-console.withSingleKernel clojupyter.definition'

# Jupyter notebook:
# nix shell --impure --expr 'with import <nixpkgs> {}; [ (jupyter.override { definitions.clojure = clojupyter.definition; }) ]' -c jupyter-notebook

let
  cljdeps = import ./deps.nix { inherit pkgs; };
  classp = cljdeps.makeClasspaths { };

  shellScript = writeShellScript "clojupyter" ''
    ${jre}/bin/java -cp ${classp} clojupyter.kernel.core "$@"
  '';

  pname = "clojupyter";
  version = "0.3.3";

  meta = {
    description = "Jupyter kernel for Clojure";
    homepage = "https://github.com/clojupyter/clojupyter";
    license = lib.licenses.mit;
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ]; # deps from maven
    maintainers = with lib.maintainers; [ thomasjm ];
    platforms = jre.meta.platforms;
  };

  sizedLogo =
    size:
    stdenv.mkDerivation {
      inherit meta;

      src = fetchFromGitHub {
        owner = "clojupyter";
        repo = "clojupyter";
        tag = version;
        sha256 = "sha256-BCzcPnLSonm+ELFU4JIIzLPlVnP0VzlrRSGxOd/LFow=";
      };

      buildInputs = [ imagemagick ];

      buildPhase = ''
        convert ./resources/clojupyter/assets/logo-64x64.png -resize ${size}x${size} $out
      '';

      dontConfigure = true;
      dontInstall = true;
      name = "clojupyter-logo-${size}x${size}.png";
    };

in

rec {
  definition = {
    argv = [
      "${launcher}/bin/clojupyter"
      "{connection_file}"
    ];

    displayName = "Clojure";
    language = "clojure";
    logo32 = sizedLogo "32";
    logo64 = sizedLogo "64";
  };

  launcher =
    runCommand "clojupyter"
      {
        inherit
          pname
          version
          meta
          shellScript
          ;
      }
      ''
        mkdir -p $out/bin
        ln -s $shellScript $out/bin/clojupyter
      '';
}
