{
  runCommand,
  substitute,
  testers,
}:
let
  # Ofborg doesn't allow any traces on stderr,
  # so mock `lib` to not trace warnings,
  # because substitute gives a deprecation warning
  substituteSilent = substitute.override (prevArgs: {
    lib = prevArgs.lib.extend (
      finalLib: prevLib: {
        trivial = prevLib.trivial // {
          warn = msg: value: value;
        };
      }
    );
  });
in
{

  legacySingleArg = testers.testEqualContents {
    actual = substituteSilent {
      src = builtins.toFile "source" ''
        Hello world!
      '';

      # Not great that this works at all, but is supported
      replacements = [
        "--replace-fail world list"
      ];
    };

    assertion = "substitute-single-arg";

    expected = builtins.toFile "expected" ''
      Hello list!
    '';
  };

  legacySingleReplace = testers.testEqualContents {
    actual = substituteSilent {
      src = builtins.toFile "source" ''
        Hello world!
      '';

      replacements = [
        "--replace-fail"
        "world"
        "paul"
      ];
    };

    assertion = "substitute-single-replace";

    expected = builtins.toFile "expected" ''
      Hello paul!
    '';
  };

  legacyString = testers.testEqualContents {
    actual = substituteSilent {
      src = builtins.toFile "source" ''
        Hello world!
      '';

      # Not great that this works at all, but is supported
      replacements = "--replace-fail world string";
    };

    assertion = "substitute-string";

    expected = builtins.toFile "expected" ''
      Hello string!
    '';
  };

  legacyVar = testers.testEqualContents {
    actual = substituteSilent {
      src = builtins.toFile "source" ''
        @greeting@ @name@!
      '';

      name = "peter";

      # Not great that this works at all, but is supported
      replacements = [
        "--subst-var name"
        "--subst-var-by greeting Yo"
      ];
    };

    assertion = "substitute-var";

    expected = builtins.toFile "expected" ''
      Yo peter!
    '';
  };

  substitutions = testers.testEqualContents {
    actual = substitute {
      src = builtins.toFile "source" ''
        Hello world!
      '';

      substitutions = [
        "--replace-fail"
        "Hello world!"
        "Yo peter!"
      ];
    };

    assertion = "substitutions-spaces";

    expected = builtins.toFile "expected" ''
      Yo peter!
    '';
  };

}
