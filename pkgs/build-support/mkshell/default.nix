{
  lib,
  stdenv,
}:
# A special kind of derivation that is only meant to be consumed by the
# nix-shell.
lib.extendMkDerivation {
  constructDrv = stdenv.mkDerivation;

  excludeDrvArgNames = [
    "packages"
    "inputsFrom"
  ];

  extendDrvArgs =
    _finalAttrs:
    {
      # propagate all the inputs from the given derivations
      inputsFrom ? [ ],
      name ? "nix-shell",
      # a list of packages to add to the shell environment
      packages ? [ ],
      ...
    }@attrs:
    let
      mergeInputs =
        name:
        (attrs.${name} or [ ])
        ++
          # 1. get all `{build,nativeBuild,...}Inputs` from the elements of `inputsFrom`
          # 2. since that is a list of lists, `flatten` that into a regular list
          # 3. filter out of the result everything that's in `inputsFrom` itself
          # this leaves actual dependencies of the derivations in `inputsFrom`, but never the derivations themselves
          (lib.subtractLists inputsFrom (lib.flatten (lib.catAttrs name inputsFrom)));
    in
    {
      inherit name;
      nativeBuildInputs = packages ++ (mergeInputs "nativeBuildInputs");
      buildInputs = mergeInputs "buildInputs";
      propagatedBuildInputs = mergeInputs "propagatedBuildInputs";

      buildPhase =
        attrs.buildPhase or ''
          { echo "------------------------------------------------------------";
            echo " WARNING: the existence of this path is not guaranteed.";
            echo " It is an internal implementation detail for pkgs.mkShell.";
            echo "------------------------------------------------------------";
            echo;
            # Record all build inputs as runtime dependencies
            export;
          } >> "$out"
        '';

      phases = attrs.phases or [ "buildPhase" ];
      preferLocalBuild = attrs.preferLocalBuild or true;
      propagatedNativeBuildInputs = mergeInputs "propagatedNativeBuildInputs";

      shellHook = lib.concatStringsSep "\n" (
        lib.catAttrs "shellHook" (lib.reverseList inputsFrom ++ [ attrs ])
      );
    };
}
