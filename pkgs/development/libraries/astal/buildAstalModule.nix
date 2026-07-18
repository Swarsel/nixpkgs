{
  lib,
  stdenv,
  glib,
  gobject-introspection,
  meson,
  ninja,
  pkg-config,
  python3,
  source, # this is ./source.nix
  vala,
  wayland,
  wayland-scanner,
  wrapGAppsHook3,
}:
let
  cleanArgs = lib.flip removeAttrs [
    "name"
    "sourceRoot"
    "nativeBuildInputs"
    "buildInputs"
    "website-path"
    "meta"
  ];

  buildAstalModule =
    {
      name,
      buildInputs ? [ ],
      meta ? { },
      nativeBuildInputs ? [ ],
      sourceRoot ? "lib/${name}",
      website-path ? name,
      ...
    }@args:
    stdenv.mkDerivation (
      finalAttrs:
      cleanArgs args
      // {
        inherit (source) version;
        pname = "astal-${name}";
        src = source;
        strictDeps = true;

        nativeBuildInputs = nativeBuildInputs ++ [
          wrapGAppsHook3
          gobject-introspection
          meson
          pkg-config
          ninja
          vala
          wayland
          wayland-scanner
          python3
        ];

        buildInputs = [ glib ] ++ buildInputs;
        __structuredAttrs = true;
        sourceRoot = "${finalAttrs.src.name}/${sourceRoot}";

        meta = {
          homepage = "https://aylur.github.io/astal/guide/libraries/${website-path}";
          license = lib.licenses.lgpl21;
          maintainers = with lib.maintainers; [ PerchunPak ];

          platforms = [
            "aarch64-linux"
            "x86_64-linux"
          ];
        }
        // meta;
      }
    );
in

args:
# to support (finalAttrs: {...})
if builtins.typeOf args == "function" then
  buildAstalModule (lib.fix args)
else
  buildAstalModule args
