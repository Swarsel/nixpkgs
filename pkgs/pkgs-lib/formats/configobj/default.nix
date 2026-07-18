{
  lib,
  pkgs,
}:
let
  inherit (lib.types)
    serializableValueWith
    ;
in
{
  format =
    { }:
    {
      generate =
        name: value:
        pkgs.runCommandLocal name
          {
            inherit value;
            strictDeps = true;

            nativeBuildInputs = [
              (pkgs.python3.withPackages (ps: [ ps.configobj ]))
            ];

            __structuredAttrs = true;
          }
          ''
            python3 ${./generate.py} > "$out"
          '';

      type = serializableValueWith { typeName = "ConfigObj mapping"; };
    };
}
