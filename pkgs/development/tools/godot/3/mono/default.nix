{
  callPackage,
  dotnet-sdk,
  godot3,
  mkNugetDeps,
  mono,
  python311Packages,
  scons,
}:

(godot3.override {
  scons = scons.override {
    python3Packages = python311Packages;
  };
}).overrideAttrs
  (
    self: base: {
      pname = "godot3-mono";

      nativeBuildInputs = base.nativeBuildInputs ++ [
        mono
        dotnet-sdk
      ];

      buildInputs = base.buildInputs ++ [
        (mkNugetDeps {
          name = "deps";
          sourceFile = ./deps.json;
        })
      ];

      postConfigure = ''
        echo "Setting up buildhome."
        mkdir buildhome
        export HOME="$PWD"/buildhome

        echo "Overlaying godot glue."
        cp -R --no-preserve=mode "$glue"/. .
      '';

      glue = callPackage ./glue.nix { };
      godotBuildDescription = "mono build";
      installedGodotShortcutDisplayName = "Godot Engine (Mono) 3";
      installedGodotShortcutFileName = "org.godotengine.GodotMono3.desktop";

      sconsFlags = base.sconsFlags ++ [
        "module_mono_enabled=true"
        "mono_prefix=${mono}"
      ];

      passthru = {
        make-deps = callPackage ./make-deps.nix { };
      };
    }
  )
