{
  lib,
  stdenv,
  binlore,
  resholve,
  writeTextFile,
}:

rec {
  colons = l: builtins.concatStringsSep ":" l;

  injectUnresholved =
    solutions: unresholved:
    (builtins.mapAttrs (name: value: value // { inherit unresholved; }) solutions);

  /*
    This uses nested derivations so we can:
    - let project build however it needs in inner "unresholved" drv
    - pass this drv through binlore to collect info on exec behavior
      in any scripts and binaries in its output
    - resholve with lore unresholved source and lore as inputs

    some concerns:
    - resholve drv isn't keeping many of the caller's args,
      (to avoid re-triggering phases and such in outer build)
      so they can't readily set LOGLEVEL and such...
    - not sure how this affects multiple outputs
  */
  mkDerivation = lib.extendMkDerivation {
    constructDrv = stdenv.mkDerivation;

    excludeDrvArgNames = [
      "postResholve"
      "solutions"
    ];

    extendDrvArgs =
      finalAttrs:
      {
        pname,
        solutions,
        src,
        version,
        passthru ? { },
        postResholve ? "",
        ...
      }@args:
      {
        pname = "${pname}-unresholved";

        passthru = passthru // {
          # needed to resholve in outer drv
          inherit postResholve solutions;
        };
      };

    transformDrv =
      unresholved:
      stdenv.mkDerivation {
        inherit (unresholved) version;
        inherit (unresholved) meta strictDeps __structuredAttrs;
        pname = lib.removeSuffix "-unresholved" unresholved.pname;
        src = unresholved;
        buildInputs = [ resholve ];

        installPhase = ''
          cp -R $src $out
        '';

        # enable below for verbose debug info if needed
        # supports default python.logging levels
        # LOGLEVEL="INFO";
        preFixup = phraseSolutions unresholved.solutions unresholved;
        postFixup = unresholved.postResholve;
        disallowedReferences = [ resholve ];
        dontBuild = true;
        # do these imply that we should use NoCC or something?
        dontConfigure = true;

        passthru = unresholved.passthru // {
          # fallback attr for update bot to query our src
          originalSrc = unresholved.src;
          # retain a reference to the base
          unresholved = unresholved;
        };
      };
  };

  # Throw a fit with dotted attr path context
  nope = path: msg: throw "${builtins.concatStringsSep "." path}: ${msg}";

  # Pull out specific solution keys to build CLI argstring
  phraseArgs =
    {
      scripts,
      flags ? [ ],
      ...
    }:
    spaces (flags ++ scripts);

  phraseBinloreArgs =
    value:
    let
      hasUnresholved = builtins.hasAttr "unresholved" value;
    in
    {
      drvs = value.inputs ++ lib.optionals hasUnresholved [ value.unresholved ];
      strip = if hasUnresholved then [ value.unresholved ] else [ ];
    };

  # Build resholve invocation for each solution.
  phraseCommands =
    solutions: unresholved:
    builtins.concatStringsSep "\n" (
      lib.mapAttrsToList phraseInvocation (injectUnresholved solutions unresholved)
    );

  /*
    subshell/PS4/set -x and : command to output resholve envs
    and invocation. Extra context makes it clearer what the
    Nix API is doing, makes nix-shell debugging easier, etc.
  */
  phraseContext =
    {
      invokable,
      prep ? ''cd "$out"'',
    }:
    ''
      (
        ${prep}
        PS4=$'\x1f'"\033[33m[resholve context]\033[0m "
        set -x
        : invoking resholve with PWD=$PWD
        ${invokable}
      )
    '';

  phraseContextForOut = invokable: phraseContext { inherit invokable; };

  phraseContextForPWD =
    invokable:
    phraseContext {
      inherit invokable;
      prep = "";
    };

  # Special-case directive value representations by type
  phraseDirective =
    solution: env: name: val:
    if builtins.isInt val then
      toString val
    else if builtins.isString val then
      name
    else if true == val then
      name
    else if false == val then
      "" # omit!
    else if null == val then
      "" # omit!
    else if builtins.isList val then
      "${name}:${semicolons (map lib.escapeShellArg val)}"
    else
      nope [
        solution
        env
        name
      ] "unexpected type: ${builtins.typeOf val}";

  # Build fake/fix/keep directives from Nix types
  phraseDirectives =
    solution: env: val:
    lib.mapAttrsToList (phraseDirective solution env) val;

  # Build a single ENV=val pair
  phraseEnv =
    solution: env: value:
    "RESHOLVE_${lib.toUpper env}=${shellEnv solution env value}";

  # Special-case value representation by type/name
  phraseEnvVal =
    solution: env: val:
    if env == "inputs" then
      (colons (map relSafeBinPath val))
    else if builtins.isString val then
      val
    else if builtins.isList val then
      spaces val
    else if builtins.isAttrs val then
      spaces (phraseDirectives solution env val)
    else
      nope [
        solution
        env
      ] "unexpected type: ${builtins.typeOf val}";

  # Pull out specific solution keys to build ENV=val pairs
  phraseEnvs =
    solution: value: spaces (lib.mapAttrsToList (phraseEnv solution) (removeUnneededArgs value));

  # Build a single resholve invocation
  phraseInvocation =
    solution: value:
    if validateSolution value then
      # we pass resholve a directory
      "RESHOLVE_LORE=${binlore.collect (phraseBinloreArgs value)} ${phraseEnvs solution value} ${resholve}/bin/resholve --overwrite ${phraseArgs value}"
    else
      throw "invalid solution"; # shouldn't trigger for now

  phraseSolution = name: solution: (phraseContextForOut (phraseInvocation name solution));

  phraseSolutions =
    solutions: unresholved: phraseContextForOut (phraseCommands solutions unresholved);

  # Custom ~search-path routine to handle relative path strings
  relSafeBinPath =
    input:
    if lib.isDerivation input then
      ((lib.getOutput "bin" input) + "/bin")
    else if builtins.isString input then
      input
    else
      throw "unexpected type for input: ${builtins.typeOf input}";

  /*
    Discard attrs:
    - claimed by phraseArgs
    - only needed for binlore.collect
  */
  removeUnneededArgs =
    value:
    removeAttrs value [
      "scripts"
      "flags"
      "unresholved"
    ];

  semicolons = l: builtins.concatStringsSep ";" l;

  # Shell-format each env value
  shellEnv =
    solution: env: value:
    lib.escapeShellArg (phraseEnvVal solution env value);

  /*
    These functions break up the work of partially validating the
    'solutions' attrset and massaging it into env/cli args.

    Note: some of the left-most args do not *have* to be passed as
    deep as they are, but I've done so to provide more error context
  */
  # for brevity / line length
  spaces = l: builtins.concatStringsSep " " l;

  # Verify required arguments are present
  validateSolution =
    {
      inputs,
      interpreter,
      scripts,
      ...
    }:
    true;

  writeScript =
    name: partialSolution: text:
    writeTextFile {
      inherit name text;

      checkPhase = ''
        ${
          (phraseContextForPWD (
            phraseInvocation name (
              partialSolution
              // {
                scripts = [ "${placeholder "out"}" ];
              }
            )
          ))
        }
      '';

      executable = true;
    };

  writeScriptBin =
    name: partialSolution: text:
    writeTextFile rec {
      inherit name text;

      checkPhase = ''
        ${phraseContextForOut (
          phraseInvocation name (
            partialSolution
            // {
              scripts = [ "bin/${name}" ];
            }
          )
        )}
      '';

      destination = "/bin/${name}";
      executable = true;
    };
}
