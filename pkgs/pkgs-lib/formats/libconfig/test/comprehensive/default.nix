{
  lib,
  formats,
  stdenvNoCC,
  writeText,
  ...
}:
let
  libconfig = formats.libconfig { };

  include_expr = {
    val = 1;
  };

  include_file = writeText "libconfig-test-include" ''
    val=1;
  '';

  expression = {
    # > An array may have zero or more elements, but the elements must all be scalar values of the same type.
    array1d = libconfig.lib.mkArray [
      1
      5
      2
    ];

    array2d = [
      (libconfig.lib.mkArray [
        1
        2
      ])
      (libconfig.lib.mkArray [
        2
        1
      ])
    ];

    ## Same syntax here on these two, but they should get serialized differently:
    # > A list may have zero or more elements, each of which can be a scalar value, an array, a group, or another list.
    list1d = libconfig.lib.mkList [
      1
      "mixed!"
      5
      2
    ];

    # You might also omit the mkList, as a list will be a list (in contrast to an array) by default.
    list2d = [
      1
      [
        1
        1.2
        "foo"
      ]
      [
        "bar"
        1.2
        1
      ]
    ];

    nasty_string = "\"@\n\\\t^*bf\n0\";'''$";
    nested.attrset.has.a.integer.value = 100;
    nested.level-dash = "pass";
    simple_top_level_attr = "1.0";
    some_floaty = 29.95;
    ## dashes in key names
    top-level-dash = "pass";

    weirderTypes = {
      _includes = [ include_file ];

      array_of_ints = libconfig.lib.mkArray [
        (libconfig.lib.mkOctal "0732")
        (libconfig.lib.mkHex "0xA3")
        1234
      ];

      bigint = 9223372036854775807;
      float = libconfig.lib.mkFloat "1.2E-3";
      hex = libconfig.lib.mkHex "0x1FC3";

      list_of_weird_types = [
        3.141592654
        9223372036854775807
        (libconfig.lib.mkHex "0x1FC3")
        (libconfig.lib.mkOctal "0027")
        (libconfig.lib.mkFloat "1.2E-32")
        (libconfig.lib.mkFloat "1")
      ];

      octal = libconfig.lib.mkOctal "0027";
      pi = 3.141592654;
    };
  };

  libconfig-test-cfg = libconfig.generate "libconfig-test.cfg" expression;
in
stdenvNoCC.mkDerivation {
  doCheck = true;

  checkPhase = ''
    cp ${./expected.txt} expected.txt
    substituteInPlace expected.txt \
        --subst-var-by include_file "${include_file}"
    diff -U3 ./expected.txt ${libconfig-test-cfg}
  '';

  installPhase = ''
    mkdir $out
    cp expected.txt $out
    cp ${libconfig-test-cfg} $out/libconfig-test.cfg
    cp ${libconfig-test-cfg.passthru.json} $out/libconfig-test.json
  '';

  dontBuild = true;
  dontUnpack = true;
  name = "pkgs.formats.libconfig-test-comprehensive";
}
