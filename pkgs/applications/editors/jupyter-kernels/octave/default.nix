{
  stdenv,
  callPackage,
  imagemagick,
  makeWrapper,
  octave,
  python3,
  runCommand,
}:

# Jupyter console:
# nix run --impure --expr 'with import <nixpkgs> {}; jupyter-console.withSingleKernel octave-kernel.definition'

# Jupyter notebook:
# nix shell --impure --expr 'with import <nixpkgs> {}; [ (jupyter.override { definitions.octave = octave-kernel.definition; }) ]' -c jupyter-notebook

let
  kernel = callPackage ./kernel.nix {
    python3Packages = python3.pkgs;
  };

in

rec {
  definition = {
    argv = [
      "${launcher}/bin/octave-kernel"
      "-f"
      "{connection_file}"
    ];

    displayName = "Octave";
    language = "octave";
    logo32 = sizedLogo "32";
    logo64 = sizedLogo "64";
  };

  launcher =
    runCommand "octave-kernel-launcher"
      {
        inherit octave;
        nativeBuildInputs = [ makeWrapper ];

        python = python3.withPackages (ps: [
          ps.traitlets
          ps.jupyter-core
          ps.ipykernel
          ps.metakernel
          kernel
        ]);
      }
      ''
        mkdir -p $out/bin

        makeWrapper $python/bin/python $out/bin/octave-kernel \
          --add-flags "-m octave_kernel" \
          --suffix PATH : $octave/bin
      '';

  sizedLogo =
    size:
    stdenv.mkDerivation {
      inherit (octave) version;
      pname = "octave-logo-${size}x${size}.png";
      src = octave.src;
      strictDeps = true;
      nativeBuildInputs = [ imagemagick ];

      buildPhase = ''
        magick ./libgui/src/icons/octave/128x128/logo.png -resize ${size}x${size} $out
      '';

      dontConfigure = true;
      dontInstall = true;
    };
}
