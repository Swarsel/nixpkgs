{
  runCommandLocal,
  symlinkJoin,
  testers,
  writeTextFile,
}:

let
  inherit (testers) testEqualContents testBuildFailure;

  foo = writeTextFile {
    destination = "/etc/test.d/foo";
    name = "foo";
    text = "foo";
  };

  bar = writeTextFile {
    destination = "/etc/test.d/bar";
    name = "bar";
    text = "bar";
  };

  baz = writeTextFile {
    destination = "/var/lib/arbitrary/baz";
    name = "baz";
    text = "baz";
  };

  qux = writeTextFile {
    name = "qux";
    text = "qux";
  };

  emulatedSymlinkJoinFooBarStrip = runCommandLocal "symlinkJoin-strip-foo-bar" { } ''
    mkdir $out
    ln -s ${foo}/etc/test.d/foo $out/
    ln -s ${bar}/etc/test.d/bar $out/
  '';
in
{
  symlinkJoin = testEqualContents {
    actual = symlinkJoin {
      name = "symlinkJoin";

      paths = [
        foo
        bar
        baz
      ];
    };

    assertion = "symlinkJoin";

    expected = runCommandLocal "symlinkJoin-foo-bar-baz" { } ''
      mkdir -p $out/{var/lib/arbitrary,etc/test.d}
      ln -s {${foo},${bar}}/etc/test.d/* $out/etc/test.d
      ln -s ${baz}/var/lib/arbitrary/baz $out/var/lib/arbitrary/
    '';
  };

  symlinkJoin-fails-on-file =
    runCommandLocal "symlinkJoin-fails-on-file"
      {
        failed = testBuildFailure (symlinkJoin {
          failOnMissing = true;
          name = "symlinkJoin-fail";

          paths = [
            foo
            bar
            qux
          ];

          stripPrefix = "/etc/test.d";
        });
      }
      ''
        grep -e "-qux/etc/test.d: Not a directory" $failed/testBuildFailure.log
        touch $out
      '';

  symlinkJoin-fails-on-missing =
    runCommandLocal "symlinkJoin-fails-on-missing"
      {
        failed = testBuildFailure (symlinkJoin {
          failOnMissing = true;
          name = "symlinkJoin-fail";

          paths = [
            foo
            bar
            baz
          ];

          stripPrefix = "/etc/test.d";
        });
      }
      ''
        grep -e "-baz/etc/test.d: No such file or directory" $failed/testBuildFailure.log
        touch $out
      '';

  symlinkJoin-strip-paths = testEqualContents {
    actual = symlinkJoin {
      name = "symlinkJoinPrefix";

      paths = [
        foo
        bar
      ];

      stripPrefix = "/etc/test.d";
    };

    assertion = "symlinkJoin-strip-paths";
    expected = emulatedSymlinkJoinFooBarStrip;
  };

  symlinkJoin-strip-paths-skip-missing = testEqualContents {
    actual = symlinkJoin {
      name = "symlinkJoinPrefix";

      paths = [
        foo
        bar
        baz
      ];

      stripPrefix = "/etc/test.d";
    };

    assertion = "symlinkJoin-strip-paths-skip-missing";
    expected = emulatedSymlinkJoinFooBarStrip;
  };

  symlinkJoin-strip-paths-skip-not-directories = testEqualContents {
    actual = symlinkJoin {
      name = "symlinkJoinPrefix";

      paths = [
        foo
        bar
        qux
      ];

      stripPrefix = "/etc/test.d";
    };

    assertion = "symlinkJoin-strip-paths-skip-not-directories";
    expected = emulatedSymlinkJoinFooBarStrip;
  };

  symlinkJoin-structured-attrs = testEqualContents {
    actual = symlinkJoin {
      __structuredAttrs = true;
      name = "symlinkJoin-structured-attrs";

      paths = [
        foo
        bar
        baz
      ];
    };

    assertion = "symlinkJoin-structured-attrs";

    expected = runCommandLocal "symlinkJoin-foo-bar-baz" { } ''
      mkdir -p $out/{var/lib/arbitrary,etc/test.d}
      ln -s {${foo},${bar}}/etc/test.d/* $out/etc/test.d
      ln -s ${baz}/var/lib/arbitrary/baz $out/var/lib/arbitrary/
    '';
  };
}
