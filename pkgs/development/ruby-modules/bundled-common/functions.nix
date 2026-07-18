{ lib, gemConfig, ... }:

let
  inherit (lib)
    attrValues
    concatMap
    converge
    filterAttrs
    getAttrs
    intersectLists
    ;

in
rec {
  applyGemConfigs =
    attrs: (if gemConfig ? ${attrs.gemName} then attrs // gemConfig.${attrs.gemName} attrs else attrs);

  bundlerFiles =
    {
      gemdir ? null,
      gemfile ? null,
      gemset ? null,
      lockfile ? null,
      ...
    }:
    {
      inherit gemdir;

      gemfile =
        if gemfile == null then
          assert gemdir != null;
          gemdir + "/Gemfile"
        else
          gemfile;

      gemset =
        if gemset == null then
          assert gemdir != null;
          gemdir + "/gemset.nix"
        else
          gemset;

      lockfile =
        if lockfile == null then
          assert gemdir != null;
          gemdir + "/Gemfile.lock"
        else
          lockfile;
    };

  composeGemAttrs =
    ruby: gems: name: attrs:
    (
      (removeAttrs attrs [ "platforms" ])
      // {
        inherit ruby;
        inherit (attrs.source) type;
        gemName = name;
        gemPath = map (gemName: gems.${gemName}) (attrs.dependencies or [ ]);
        source = removeAttrs attrs.source [ "type" ];
      }
    );

  filterGemset =
    { groups, ruby, ... }:
    gemset:
    let
      platformGems = filterAttrs (_: platformMatches ruby) gemset;
      directlyMatchingGems = filterAttrs (_: groupMatches groups) platformGems;

      expandDependencies =
        gems:
        let
          depNames = concatMap (gem: gem.dependencies or [ ]) (attrValues gems);
          deps = getAttrs depNames platformGems;
        in
        gems // deps;
    in
    converge expandDependencies directlyMatchingGems;

  genStubsScript =
    {
      lib,
      binPaths,
      bundler,
      confFiles,
      groups,
      ruby,
      runCommand,
      ...
    }:
    let
      genStubsScript =
        runCommand "gen-bin-stubs"
          {
            strictDeps = true;
            nativeBuildInputs = [ ruby ];
          }
          ''
            cp ${./gen-bin-stubs.rb} $out
            chmod +x $out
            patchShebangs --build $out
          '';
    in
    ''
      ${genStubsScript} \
        "${ruby}/bin/ruby" \
        "${confFiles}/Gemfile" \
        "$out/${ruby.gemPath}" \
        "${bundler}/${ruby.gemPath}/gems/bundler-${bundler.version}" \
        ${lib.escapeShellArg binPaths} \
        ${lib.escapeShellArg groups}
    '';

  groupMatches =
    groups: attrs:
    groups == null
    || !(attrs ? groups)
    || (intersectLists (groups ++ [ "default" ]) attrs.groups) != [ ];

  pathDerivation =
    {
      gemName,
      path,
      version,
      ...
    }:
    let
      res = {
        version = version;
        outputs = [ "out" ];
        bundledByPath = true;
        gemType = "path";
        name = gemName;
        out = res;
        outPath = "${path}";
        outputName = "out";
        suffix = version;
        type = "derivation";
      };
    in
    res;

  platformMatches =
    { rubyEngine, version, ... }:
    attrs:
    (
      !(attrs ? platforms)
      || builtins.length attrs.platforms == 0
      || builtins.any (
        platform:
        platform.engine == rubyEngine && (!(platform ? version) || platform.version == version.majMin)
      ) attrs.platforms
    );
}
