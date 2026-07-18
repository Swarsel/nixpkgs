{
  lib,
  formats,
  stdenvNoCC,
  writeText,
  ...
}:
let
  hocon = formats.hocon { };

  include_file =
    (writeText "hocon-test-include.conf" ''
      "val" = 1
    '').overrideAttrs
      (
        _: _: {
          outputHash = "sha256-UhkJLhT3bD6znq+IdDjs/ahP19mLzrLCy/R14pVrfew=";
          outputHashAlgo = "sha256";
          outputHashMode = "flat";
        }
      );

  expression = {
    array2d = [
      [
        1
        2
        "a"
      ]
      [
        2
        1
        "b"
      ]
    ];

    "cursed \" .attrs \" " = {
      "a" = 1;
      "a b" = hocon.lib.mkSubstitution "a";

      "a b c" = hocon.lib.mkSubstitution {
        required = false;
        value = "a b";
      };
    };

    "misc attrs" = {
      x = 1;
      y = hocon.lib.mkAppend { a = 1; };
    };

    nasty_string = "\"@\n\\\t^*bf\n0\";'''$";
    nested.attrset.has.a.integer.value = 100;
    simple_top_level_attr = "1.0";
    some_floaty = 29.95;

    to_include = {
      _includes = [
        (hocon.lib.mkInclude include_file)
        (hocon.lib.mkInclude "https://example.com")
        (hocon.lib.mkInclude {
          required = true;
          type = "file";
          value = include_file;
        })
        (hocon.lib.mkInclude { value = include_file; })
        (hocon.lib.mkInclude {
          type = "url";
          value = "https://example.com";
        })
      ];
    };
  };

  hocon-test-conf = hocon.generate "hocon-test.conf" expression;
in
stdenvNoCC.mkDerivation {
  doCheck = true;

  checkPhase = ''
    runHook preCheck

    diff -U3 ${./expected.txt} ${hocon-test-conf}

    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall

    mkdir $out
    cp ${./expected.txt} $out/expected.txt
    cp ${hocon-test-conf} $out/hocon-test.conf
    cp ${hocon-test-conf.passthru.json} $out/hocon-test.json

    runHook postInstall
  '';

  dontBuild = true;
  dontUnpack = true;
  name = "pkgs.formats.hocon-test-comprehensive";
}
