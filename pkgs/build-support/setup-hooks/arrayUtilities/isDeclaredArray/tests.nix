# NOTE: Tests related to isDeclaredArray go here.
{
  lib,
  isDeclaredArray,
  runCommand,
  testers,
}:
let
  inherit (lib.attrsets) recurseIntoAttrs;
  inherit (testers) shellcheck shfmt testBuildFailure';

  commonArgs = {
    strictDeps = true;
    nativeBuildInputs = [ isDeclaredArray ];
    __structuredAttrs = true;
    preferLocalBuild = true;
  };

  check =
    let
      mkLine =
        intro: values:
        "${if intro == null then "" else intro + " "}check${if values == null then "" else "=" + values}";
      mkScope =
        scope: line:
        if scope == null then
          line
        else if scope == "function" then
          ''
            foo() {
              ${line}
            }
            foo
          ''
        else
          throw "Invalid scope: ${scope}";
    in
    {
      intro,
      name,
      scope,
      values,
    }:
    runCommand name commonArgs ''
      set -eu

      ${mkScope scope (mkLine intro values)}

      if isDeclaredArray check; then
        nixLog "test passed"
        touch "$out"
      else
        nixErrorLog "test failed"
        exit 1
      fi
    '';
in
recurseIntoAttrs {
  emptyStringNamerefFails = testBuildFailure' {
    drv = runCommand "emptyStringNameref" commonArgs ''
      set -eu
      if isDeclaredArray ""; then
        nixLog "test passed"
        touch "$out"
      else
        nixErrorLog "test failed"
        exit 1
      fi
    '';

    expectedBuilderLogEntries = [
      "local: `': not a valid identifier"
      "test failed"
    ];

    name = "emptyStringNamerefFails";
  };

  mapFails = testBuildFailure' {
    drv = runCommand "map" commonArgs ''
      set -eu
      local -A map
      if isDeclaredArray map; then
        nixLog "test passed"
        touch "$out"
      else
        nixErrorLog "test failed"
        exit 1
      fi
    '';

    expectedBuilderLogEntries = [
      "test failed"
    ];

    name = "mapFails";
  };

  namerefToEmptyStringFails = testBuildFailure' {
    drv = check {
      intro = "local -n";
      name = "namerefToEmptyString";
      scope = null;
      values = "";
    };

    expectedBuilderLogEntries = [
      "local: `': not a valid identifier"
      # The test fails in such a way that it exits immediately, without returning to the else branch.
    ];

    name = "namerefToEmptyStringFails";
  };

  previousScopeDeclareEmptyArrayFails = testBuildFailure' {
    drv = check {
      intro = "declare -a";
      name = "previousScopeDeclareEmptyArray";
      scope = "function";
      values = "()";
    };

    expectedBuilderLogEntries = [
      "test failed"
    ];

    name = "previousScopeDeclareEmptyArrayFails";
  };

  previousScopeDeclareGlobalEmptyArray = check {
    intro = "declare -ag";
    name = "previousScopeDeclareGlobalEmptyArray";
    scope = "function";
    values = "()";
  };

  previousScopeDeclareGlobalSingletonArray = check {
    intro = "declare -ag";
    name = "previousScopeDeclareGlobalSingletonArray";
    scope = "function";
    values = ''("hello!")'';
  };

  previousScopeDeclareGlobalUnsetArray = check {
    intro = "declare -ag";
    name = "previousScopeDeclareGlobalUnsetArray";
    scope = "function";
    values = null;
  };

  previousScopeDeclareSingletonArrayFails = testBuildFailure' {
    drv = check {
      intro = "declare -a";
      name = "previousScopeDeclareSingletonArray";
      scope = "function";
      values = ''("hello!")'';
    };

    expectedBuilderLogEntries = [
      "test failed"
    ];

    name = "previousScopeDeclareSingletonArrayFails";
  };

  previousScopeDeclareUnsetArrayFails = testBuildFailure' {
    drv = check {
      intro = "declare -a";
      name = "previousScopeDeclareUnsetArray";
      scope = "function";
      values = null;
    };

    expectedBuilderLogEntries = [
      "test failed"
    ];

    name = "previousScopeDeclareUnsetArrayFails";
  };

  # Works because the variable isn't lexically scoped.
  previousScopeEmptyArray = check {
    intro = null;
    name = "previousScopeEmptyArray";
    scope = "function";
    values = "()";
  };

  previousScopeEmptyStringFails = testBuildFailure' {
    drv = check {
      intro = null;
      name = "previousScopeEmptyString";
      scope = "function";
      values = "";
    };

    expectedBuilderLogEntries = [
      "test failed"
    ];

    name = "previousScopeEmptyStringFails";
  };

  previousScopeLocalEmptyArrayFails = testBuildFailure' {
    drv = check {
      intro = "local -a";
      name = "previousScopeLocalEmptyArray";
      scope = "function";
      values = "()";
    };

    expectedBuilderLogEntries = [
      "test failed"
    ];

    name = "previousScopeLocalEmptyArrayFails";
  };

  previousScopeLocalGlobalEmptyArray = check {
    intro = "local -ag";
    name = "previousScopeLocalGlobalEmptyArray";
    scope = "function";
    values = "()";
  };

  previousScopeLocalGlobalSingletonArray = check {
    intro = "local -ag";
    name = "previousScopeLocalGlobalSingletonArray";
    scope = "function";
    values = ''("hello!")'';
  };

  previousScopeLocalGlobalUnsetArray = check {
    intro = "local -ag";
    name = "previousScopeLocalGlobalUnsetArray";
    scope = "function";
    values = null;
  };

  previousScopeLocalSingletonArrayFails = testBuildFailure' {
    drv = check {
      intro = "local -a";
      name = "previousScopeLocalSingletonArray";
      scope = "function";
      values = ''("hello!")'';
    };

    expectedBuilderLogEntries = [
      "test failed"
    ];

    name = "previousScopeLocalSingletonArrayFails";
  };

  previousScopeLocalUnsetArrayFails = testBuildFailure' {
    drv = check {
      intro = "local -a";
      name = "previousScopeLocalUnsetArray";
      scope = "function";
      values = null;
    };

    expectedBuilderLogEntries = [
      "test failed"
    ];

    name = "previousScopeLocalUnsetArrayFails";
  };

  # Works because the variable isn't lexically scoped.
  previousScopeSingletonArray = check {
    intro = null;
    name = "previousScopeSingletonArray";
    scope = "function";
    values = ''("hello!")'';
  };

  sameScopeDeclareEmptyArray = check {
    intro = "declare -a";
    name = "sameScopeDeclareEmptyArray";
    scope = null;
    values = "()";
  };

  sameScopeDeclareSingletonArray = check {
    intro = "declare -a";
    name = "sameScopeDeclareSingletonArray";
    scope = null;
    values = ''("hello!")'';
  };

  sameScopeDeclareUnsetArray = check {
    intro = "declare -a";
    name = "sameScopeDeclareUnsetArray";
    scope = null;
    values = null;
  };

  sameScopeEmptyArray = check {
    intro = null;
    name = "sameScopeEmptyArray";
    scope = null;
    values = "()";
  };

  sameScopeEmptyStringFails = testBuildFailure' {
    drv = check {
      intro = null;
      name = "sameScopeEmptyString";
      scope = null;
      values = "";
    };

    expectedBuilderLogEntries = [
      "test failed"
    ];

    name = "sameScopeEmptyStringFails";
  };

  sameScopeLocalEmptyArray = check {
    intro = "local -a";
    name = "sameScopeLocalEmptyArray";
    scope = null;
    values = "()";
  };

  sameScopeLocalSingletonArray = check {
    intro = "local -a";
    name = "sameScopeLocalSingletonArray";
    scope = null;
    values = ''("hello!")'';
  };

  sameScopeLocalUnsetArray = check {
    intro = "local -a";
    name = "sameScopeLocalUnsetArray";
    scope = null;
    values = null;
  };

  sameScopeSingletonArray = check {
    intro = null;
    name = "sameScopeSingletonArray";
    scope = null;
    values = ''("hello!")'';
  };

  shellcheck = shellcheck {
    src = ./isDeclaredArray.bash;
    name = "isDeclaredArray";
  };

  shfmt = shfmt {
    src = ./isDeclaredArray.bash;
    name = "isDeclaredArray";
  };

  undeclaredFails = testBuildFailure' {
    drv = runCommand "undeclared" commonArgs ''
      set -eu
      if isDeclaredArray undeclared; then
        nixLog "test passed"
        touch "$out"
      else
        nixErrorLog "test failed"
        exit 1
      fi
    '';

    expectedBuilderLogEntries = [
      "test failed"
    ];

    name = "undeclaredFails";
  };
}
