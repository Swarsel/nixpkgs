{
  lib,
  makeWrapper,
  nixosTests,
  perlPackages,
  rxvt-unicode-plugins,
  rxvt-unicode-unwrapped,
  symlinkJoin,
  configure ?
    { availablePlugins, ... }:
    {
      extraDeps = [ ];
      perlDeps = [ ];
      plugins = builtins.attrValues availablePlugins;
    },
}:

let
  availablePlugins = lib.filterAttrs (
    _: v: (lib.isDerivation v && (v.meta.license.free or false))
  ) rxvt-unicode-plugins;

  # Transform the string "self" to the plugin itself.
  # It's needed for plugins like bidi who depends on the perl
  # package they provide themself.
  mkPerlDeps =
    p:
    let
      deps = p.perlPackages or [ ];
    in
    map (x: if x == "self" then p else x) deps;

  # The wrapper is called with a `configure` function
  # that takes the urxvt plugins as input and produce
  # the configuration of the wrapper: list of plugins,
  # extra dependencies and perl dependencies.
  # This provides simple way to customize urxvt using
  # the `.override` mechanism.
  wrapper =
    { configure, ... }:
    let
      config = configure { inherit availablePlugins; };
      plugins = config.plugins or (builtins.attrValues availablePlugins);
      extraDeps = config.extraDeps or [ ];
      perlDeps = (config.perlDeps or [ ]) ++ lib.concatMap mkPerlDeps plugins;
    in
    symlinkJoin {
      inherit (rxvt-unicode-unwrapped) meta version;
      pname = "rxvt-unicode";
      nativeBuildInputs = [ makeWrapper ];

      postBuild = ''
        wrapProgram $out/bin/urxvt \
          --prefix PERL5LIB : "${perlPackages.makePerlPath perlDeps}" \
          --suffix-each URXVT_PERL_LIB ':' "$out/lib/urxvt/perl"
        wrapProgram $out/bin/urxvtd \
          --prefix PERL5LIB : "${perlPackages.makePerlPath perlDeps}" \
          --suffix-each URXVT_PERL_LIB ':' "$out/lib/urxvt/perl"
      '';

      paths = [ rxvt-unicode-unwrapped ] ++ plugins ++ extraDeps;

      passthru = {
        plugins = plugins;
        tests.test = nixosTests.terminal-emulators.urxvt;
      };
    };

in
lib.makeOverridable wrapper { inherit configure; }
