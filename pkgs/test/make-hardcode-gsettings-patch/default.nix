{
  lib,
  clang-tools,
  git,
  makeHardcodeGsettingsPatch,
  runCommandLocal,
}:

let
  mkTest =
    {
      args,
      expected,
      name,
      src,
      patches ? [ ],
    }:

    let
      patch = makeHardcodeGsettingsPatch (
        args
        // {
          inherit src patches;
        }
      );
    in
    runCommandLocal "makeHardcodeGsettingsPatch-tests-${name}"

      {
        nativeBuildInputs = [
          git
          clang-tools
        ];
      }

      ''
        cp -r --no-preserve=all "${src}" src
        cp -r --no-preserve=all "${expected}" src-expected

        pushd src
        for patch in ${lib.escapeShellArgs (map (p: "${p}") patches)}; do
            patch < "$patch"
        done
        patch < "${patch}"
        popd

        find src -name '*.c' -print0 | while read -d $'\0' sourceFile; do
          sourceFile=''${sourceFile#src/}
          clang-format -style='{BasedOnStyle: InheritParentConfig, ColumnLimit: 240}' -i "src/$sourceFile" "src-expected/$sourceFile"
          git diff --no-index "src/$sourceFile" "src-expected/$sourceFile" | cat
        done
        touch "$out"
      '';
in
{
  patches = mkTest {
    src = ./fixtures/example-project-wrapped-settings-constructor;

    patches = [
      # Avoid using wrapper function, which the generator cannot handle.
      ./fixtures/example-project-wrapped-settings-constructor-resolve.patch
    ];

    args = {
      schemaIdToVariableMapping = {
        "org.gnome.evolution-data-server.addressbook" = "EDS";
      };
    };

    expected = ./fixtures/example-project-wrapped-settings-constructor-patched;
    name = "patches";
  };

  basic = mkTest {
    src = ./fixtures/example-project;

    args = {
      schemaIdToVariableMapping = {
        "org.gnome.evolution-data-server.addressbook" = "EDS";
        "org.gnome.evolution.calendar" = "EVO";
        "org.gnome.seahorse.nautilus.window" = "SEANAUT";
      };
    };

    expected = ./fixtures/example-project-patched;
    name = "basic";
  };

  existsFn = mkTest {
    src = ./fixtures/example-project;

    args = {
      schemaExistsFunction = "e_ews_common_utils_gsettings_schema_exists";

      schemaIdToVariableMapping = {
        "org.gnome.evolution-data-server.addressbook" = "EDS";
        "org.gnome.evolution.calendar" = "EVO";
        "org.gnome.seahorse.nautilus.window" = "SEANAUT";
      };
    };

    expected = ./fixtures/example-project-patched-with-exists-fn;
    name = "exists-fn";
  };

}
