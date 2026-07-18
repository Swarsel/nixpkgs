{ lib }:
let
  p = import ../../stdenv/generic/problems.nix { inherit lib; };

  genConstraintsTest = problems: expected: {
    inherit expected;
    expr = (p.genHandlerSwitch { inherit problems; }).definedConstraints;
  };

  genHandlerTest =
    let
      slowReference =
        config: kind: name: package:
        # Try to find an explicit handler
        (config.problems.handlers.${package} or { }).${name}
          # Fall back, iterating through the matchers
          or (lib.pipe config.problems.matchers [
            # Find matches
            (lib.filter (
              matcher:
              (matcher.name != null -> name == matcher.name)
              && (matcher.kind != null -> kind == matcher.kind)
              && (matcher.package != null -> package == matcher.package)
            ))
            # Extract handler level
            (map (matcher: matcher.handler))
            # Take the strongest matched handler level
            (lib.foldl' p.handlers.max "ignore")
          ]);

      genValue =
        f:
        map
          (
            package:
            map
              (
                name:
                map (kind: f kind name package) [
                  "k1"
                  "k2"
                  "k3"
                ]
              )
              [
                "n1"
                "n2"
                "n3"
              ]
          )
          [
            "p1"
            "p2"
            "p3"
          ];

    in
    v: {
      expected = genValue (slowReference {
        problems = v;
      });

      expr = genValue (p.genHandlerSwitch { problems = v; }).handlerForProblem;
    };
in
lib.runTests {
  testDefinedConstraintsEmpty =
    genConstraintsTest
      {
        handlers = { };
        matchers = [ ];
      }
      {
        kinds = [ ];
        names = [ ];
        packages = [ ];
      };

  testDefinedConstraintsHandlers =
    genConstraintsTest
      {
        handlers.p1.n1 = "warn";
        handlers.p1.n2 = "error";
        handlers.p2.n3 = "ignore";
        matchers = [ ];
      }
      {
        kinds = [ ];

        names = [
          "n1"
          "n2"
        ];

        packages = [
          "p1"
        ];
      };

  testDefinedConstraintsMatchers =
    genConstraintsTest
      {
        handlers = { };

        matchers = [
          {
            handler = "warn";
            kind = "k1";
            name = null;
            package = null;
          }
          {
            handler = "error";
            kind = "k2";
            name = null;
            package = null;
          }
          {
            handler = "ignore";
            kind = "k3";
            name = null;
            package = null;
          }
          {
            handler = "error";
            kind = null;
            name = "n1";
            package = "p1";
          }
          {
            handler = "warn";
            kind = null;
            name = "n1";
            package = "p2";
          }
        ];
      }
      {
        kinds = [
          "k1"
          "k2"
        ];

        names = [ "n1" ];

        packages = [
          "p1"
          "p2"
        ];
      };

  testHandlerEmpty = genHandlerTest {
    handlers = { };
    matchers = [ ];
  };

  testHandlerNameSpecificHandlers = genHandlerTest {
    handlers.p1.n1 = "error";
    handlers.p1.n2 = "warn";
    handlers.p1.n3 = "ignore";
    matchers = [ ];
  };

  testHandlerPackageSpecificHandlers = genHandlerTest {
    handlers.p1.n1 = "error";
    handlers.p2.n1 = "warn";
    handlers.p3.n1 = "ignore";
    matchers = [ ];
  };

  testHandlersLessThan =
    let
      levels = p.handlers.levels;
      slowReference =
        a: b:
        lib.lists.findFirstIndex (v: v == a) (abort "Shouldn't happen") levels
        < lib.lists.findFirstIndex (v: v == b) (abort "Shouldn't happen") levels;

      genValue =
        f:
        lib.genList (
          i: lib.genList (j: f (lib.elemAt levels i) (lib.elemAt levels j)) (lib.length levels)
        ) (lib.length levels);
    in
    {
      expected = genValue slowReference;
      expr = genValue p.handlers.lessThan;
    };

  testHandlersOverrideMatchers = genHandlerTest {
    handlers.p1.n1 = "warn";

    matchers = [
      {
        handler = "error";
        kind = null;
        name = "n1";
        package = "p1";
      }
    ];
  };

  testMatchersComplicated = genHandlerTest {
    handlers = { };

    matchers = [
      {
        handler = "warn";
        kind = null;
        name = null;
        package = "p1";
      }
      {
        handler = "error";
        kind = null;
        name = "n1";
        package = "p1";
      }
      {
        handler = "error";
        kind = "k1";
        name = null;
        package = "p1";
      }
      {
        handler = "error";
        kind = "k2";
        name = "n2";
        package = "p1";
      }
    ];
  };

  testMatchersDefault = genHandlerTest {
    handlers = { };

    matchers = [
      # Everything should warn by default
      {
        handler = "warn";
        kind = null;
        name = null;
        package = null;
      }
    ];
  };
}
