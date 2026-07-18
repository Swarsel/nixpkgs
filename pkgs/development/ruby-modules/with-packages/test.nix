# a generic test suite for all gems for all ruby versions.
# use via nix-build.
let
  pkgs = import ../../../.. { };
  lib = pkgs.lib;
  stdenv = pkgs.stdenv;

  rubyVersions = [
    # TODO FIXME: All versions listed here were dropped from Nixpkgs.
    # Add current versions here or remove this file if it’s no longer
    # being used.
  ];

  gemTests = (lib.mapAttrs (name: gem: [ name ]) pkgs.ruby.gems) // (import ./require_exceptions.nix);

  testWrapper =
    ruby:
    stdenv.mkDerivation {
      buildInputs = [ ((ruby.withPackages (ps: [ ])).wrappedRuby) ];

      buildCommand = ''
        cat <<'EOF' > test-ruby
        #!/usr/bin/env ruby
        puts RUBY_VERSION
        EOF

        chmod +x test-ruby
        patchShebangs test-ruby
        [[ $(./test-ruby) = $(${ruby}/bin/ruby test-ruby) ]]
        touch $out
      '';

      name = "test-wrappedRuby-${ruby.name}";
    };

  tests =
    ruby:
    lib.mapAttrs (
      name: gem:
      let
        test =
          if builtins.isList gemTests.${name} then
            pkgs.writeText "${name}.rb" ''
              puts "${name} GEM_HOME: #{ENV['GEM_HOME']}"
              ${lib.concatStringsSep "\n" (map (n: "require '${n}'") gemTests.${name})}
            ''
          else
            pkgs.writeText "${name}.rb" gemTests.${name};

        deps = ruby.withPackages (g: [ g.${name} ]);
      in
      stdenv.mkDerivation {
        buildInputs = [ deps ];

        buildCommand = ''
          INLINEDIR=$PWD ruby ${test}
          touch $out
        '';

        name = "test-gem-${ruby.name}-${name}";
      }
    ) ruby.gems;
in
stdenv.mkDerivation {
  buildInputs = builtins.foldl' (
    sum: ruby: sum ++ [ (testWrapper ruby) ] ++ (builtins.attrValues (tests ruby))
  ) [ ] rubyVersions;

  buildCommand = ''
    touch $out
  '';

  name = "test-all-ruby-gems";
}
