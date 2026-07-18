# NOTE: Tests related to isDeclaredMap go here.
{
  lib,
  isDeclaredMap,
  runCommand,
  testers,
}:
let
  inherit (lib.attrsets) recurseIntoAttrs;
  inherit (testers) shellcheck shfmt testBuildFailure';

  commonArgs = {
    strictDeps = true;
    nativeBuildInputs = [ isDeclaredMap ];
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

      if isDeclaredMap check; then
        nixLog "test passed"
        touch "$out"
      else
        nixErrorLog "test failed"
        exit 1
      fi
    '';
in
recurseIntoAttrs {
  arrayFails = testBuildFailure' {
    drv = runCommand "array" commonArgs ''
      set -eu
      local -a array
      if isDeclaredMap array; then
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

    name = "arrayFails";
  };

  emptyStringNamerefFails = testBuildFailure' {
    drv = runCommand "emptyStringNameref" commonArgs ''
      set -eu
      if isDeclaredMap ""; then
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

  previousScopeDeclareEmptyMapFails = testBuildFailure' {
    drv = check {
      intro = "declare -A";
      name = "previousScopeDeclareEmptyMap";
      scope = "function";
      values = "()";
    };

    expectedBuilderLogEntries = [
      "test failed"
    ];

    name = "previousScopeDeclareEmptyMapFails";
  };

  previousScopeDeclareGlobalEmptyMap = check {
    intro = "declare -Ag";
    name = "previousScopeDeclareGlobalEmptyMap";
    scope = "function";
    values = "()";
  };

  previousScopeDeclareGlobalSingletonMap = check {
    intro = "declare -Ag";
    name = "previousScopeDeclareGlobalSingletonMap";
    scope = "function";
    values = ''([greeting]="hello!")'';
  };

  previousScopeDeclareGlobalUnsetMap = check {
    intro = "declare -Ag";
    name = "previousScopeDeclareGlobalUnsetMap";
    scope = "function";
    values = null;
  };

  previousScopeDeclareSingletonMapFails = testBuildFailure' {
    drv = check {
      intro = "declare -A";
      name = "previousScopeDeclareSingletonMap";
      scope = "function";
      values = ''([greeting]="hello!")'';
    };

    expectedBuilderLogEntries = [
      "test failed"
    ];

    name = "previousScopeDeclareSingletonMapFails";
  };

  previousScopeDeclareUnsetMapFails = testBuildFailure' {
    drv = check {
      intro = "declare -A";
      name = "previousScopeDeclareUnsetMap";
      scope = "function";
      values = null;
    };

    expectedBuilderLogEntries = [
      "test failed"
    ];

    name = "previousScopeDeclareUnsetMapFails";
  };

  # Fails because () is ambiguous and defaults to array rather than associative array.
  previousScopeEmptyMapFails = testBuildFailure' {
    drv = check {
      intro = null;
      name = "previousScopeEmptyMap";
      scope = "function";
      values = "()";
    };

    expectedBuilderLogEntries = [
      "test failed"
    ];

    name = "previousScopeEmptyMapFails";
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

  previousScopeLocalEmptyMapFails = testBuildFailure' {
    drv = check {
      intro = "local -A";
      name = "previousScopeLocalEmptyMap";
      scope = "function";
      values = "()";
    };

    expectedBuilderLogEntries = [
      "test failed"
    ];

    name = "previousScopeLocalEmptyMapFails";
  };

  previousScopeLocalGlobalEmptyMap = check {
    intro = "local -Ag";
    name = "previousScopeLocalGlobalEmptyMap";
    scope = "function";
    values = "()";
  };

  previousScopeLocalGlobalSingletonMap = check {
    intro = "local -Ag";
    name = "previousScopeLocalGlobalSingletonMap";
    scope = "function";
    values = ''([greeting]="hello!")'';
  };

  previousScopeLocalGlobalUnsetMap = check {
    intro = "local -Ag";
    name = "previousScopeLocalGlobalUnsetMap";
    scope = "function";
    values = null;
  };

  previousScopeLocalSingletonMapFails = testBuildFailure' {
    drv = check {
      intro = "local -A";
      name = "previousScopeLocalSingletonMap";
      scope = "function";
      values = ''([greeting]="hello!")'';
    };

    expectedBuilderLogEntries = [
      "test failed"
    ];

    name = "previousScopeLocalSingletonMapFails";
  };

  previousScopeLocalUnsetMapFails = testBuildFailure' {
    drv = check {
      intro = "local -A";
      name = "previousScopeLocalUnsetMap";
      scope = "function";
      values = null;
    };

    expectedBuilderLogEntries = [
      "test failed"
    ];

    name = "previousScopeLocalUnsetMapFails";
  };

  previousScopeSingletonMapFails = testBuildFailure' {
    drv = check {
      intro = null;
      name = "previousScopeSingletonMap";
      scope = "function";
      values = ''([greeting]="hello!")'';
    };

    expectedBuilderLogEntries = [
      "greeting: unbound variable"
    ];

    name = "previousScopeSingletonMapFails";
  };

  sameScopeDeclareEmptyMap = check {
    intro = "declare -A";
    name = "sameScopeDeclareEmptyMap";
    scope = null;
    values = "()";
  };

  sameScopeDeclareSingletonMap = check {
    intro = "declare -A";
    name = "sameScopeDeclareSingletonMap";
    scope = null;
    values = ''([greeting]="hello!")'';
  };

  sameScopeDeclareUnsetMap = check {
    intro = "declare -A";
    name = "sameScopeDeclareUnsetMap";
    scope = null;
    values = null;
  };

  sameScopeEmptyMapFails = testBuildFailure' {
    drv = check {
      intro = null;
      name = "sameScopeEmptyMap";
      scope = null;
      values = "()";
    };

    expectedBuilderLogEntries = [
      "test failed"
    ];

    name = "sameScopeEmptyMapFails";
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

  sameScopeLocalEmptyMap = check {
    intro = "local -A";
    name = "sameScopeLocalEmptyMap";
    scope = null;
    values = "()";
  };

  sameScopeLocalSingletonMap = check {
    intro = "local -A";
    name = "sameScopeLocalSingletonMap";
    scope = null;
    values = ''([greeting]="hello!")'';
  };

  sameScopeLocalUnsetMap = check {
    intro = "local -A";
    name = "sameScopeLocalUnsetMap";
    scope = null;
    values = null;
  };

  # Fails because maps must be declared with the -A flag.
  sameScopeSingletonMapFails = testBuildFailure' {
    drv = check {
      intro = null;
      name = "sameScopeSingletonMap";
      scope = null;
      values = ''([greeting]="hello!")'';
    };

    expectedBuilderLogEntries = [
      "greeting: unbound variable"
    ];

    name = "sameScopeSingletonMapFails";
  };

  shellcheck = shellcheck {
    src = ./isDeclaredMap.bash;
    name = "isDeclaredMap";
  };

  shfmt = shfmt {
    src = ./isDeclaredMap.bash;
    name = "isDeclaredMap";
  };

  undeclaredFails = testBuildFailure' {
    drv = runCommand "undeclared" commonArgs ''
      set -eu
      if isDeclaredMap undeclared; then
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
