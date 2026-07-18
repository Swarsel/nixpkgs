{ pkgs }:
let
  inherit (pkgs) lib formats;

  # merging allows us to add metadata to the input
  # this makes error messages more readable during development
  mergeInput =
    name: format: input:
    format.type.merge
      [ ]
      [
        {
          # inject the name
          file = "format-test-${name}";

          # explicitly throw here to trigger the code path that prints the error message for users
          value =
            lib.throwIfNot (format.type.check input)
              (builtins.trace input "definition does not pass the type's check function")
              input;
        }
      ];

  # run a diff between expected and real output
  runDiff =
    name: drv: expected:
    pkgs.runCommand name
      {
        inherit expected drv;
        passAsFile = [ "expected" ];
      }
      ''
        if diff -u "$expectedPath" "$drv"; then
          touch "$out"
        else
          echo
          echo "Got different values than expected; diff above."
          exit 1
        fi
      '';

  # use this to check for proper serialization
  # in practice you do not have to supply the name parameter as this one will be added by runBuildTests
  shouldPass =
    {
      expected,
      format,
      input,
    }:
    name: {
      name = "pass-${name}";

      path = runDiff "test-format-${name}" (format.generate "test-format-${name}" (
        mergeInput name format input
      )) expected;
    };

  # use this function to assert that a type check must fail
  # in practice you do not have to supply the name parameter as this one will be added by runBuildTests
  # note that as per 352e7d330a26 and 352e7d330a26 the type checking of attrsets and lists are not strict
  # this means that the code below needs to properly merge the module type definition and also evaluate the (lazy) return value
  shouldFail =
    { format, input }:
    name:
    let
      # trigger a deep type check using the module system
      typeCheck = lib.modules.mergeDefinitions [ "tests" name ] format.type [
        {
          file = "format-test-${name}";
          value = input;
        }
      ];
      # actually use the return value to trigger the evaluation
      eval = builtins.tryEval (typeCheck.mergedValue == input);
      # the check failing is what we want, so don't do anything here
      typeFails = pkgs.runCommand "test-format-${name}" { } "touch $out";
      # bail with some verbose information in case the type check passes
      typeSucceeds =
        pkgs.runCommand "test-format-${name}"
          {
            # this will fail if the input contains functions as values
            # however that should get caught by the type check already
            inputText = builtins.toJSON input;
            passAsFile = [ "inputText" ];
            testName = name;
          }
          ''
            echo "Type check $testName passed when it shouldn't."
            echo "The following data was used as input:"
            echo
            cat "$inputTextPath"
            exit 1
          '';
    in
    {
      name = "fail-${name}";
      path = if eval.success then typeSucceeds else typeFails;
    };

  # this function creates a linkFarm for all the tests below such that the results are easily visible in the filesystem after a build
  # the parameters are an attrset of name: test pairs where the name is automatically passed to the test
  # the test therefore is an invocation of ShouldPass or shouldFail with the attrset parameters but *not* the name (which this adds for convenience)
  runBuildTests = (lib.flip lib.pipe) [
    (lib.mapAttrsToList (name: value: value name))
    (pkgs.linkFarm "nixpkgs-pkgs-lib-format-tests")
  ];

in
runBuildTests {

  PlistGenerate = shouldPass {
    expected = ''
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0">
      <dict>
      ''\t<key>attrs</key>
      ''\t<dict>
      ''\t''\t<key>foo</key>
      ''\t''\t<integer>0</integer>
      ''\t</dict>
      ''\t<key>false</key>
      ''\t<false/>
      ''\t<key>float</key>
      ''\t<real>3.141000</real>
      ''\t<key>int</key>
      ''\t<integer>10</integer>
      ''\t<key>list</key>
      ''\t<array>
      ''\t''\t<integer>1</integer>
      ''\t''\t<string>hello</string>
      ''\t''\t<dict>
      ''\t''\t''\t<key>attrs</key>
      ''\t''\t''\t<dict>
      ''\t''\t''\t''\t<key>key</key>
      ''\t''\t''\t''\t<dict>
      ''\t''\t''\t''\t''\t<key>value</key>
      ''\t''\t''\t''\t''\t<array>
      ''\t''\t''\t''\t''\t''\t<array>
      ''\t''\t''\t''\t''\t''\t''\t<integer>1</integer>
      ''\t''\t''\t''\t''\t''\t''\t<integer>2</integer>
      ''\t''\t''\t''\t''\t''\t''\t<integer>3</integer>
      ''\t''\t''\t''\t''\t''\t</array>
      ''\t''\t''\t''\t''\t''\t<string>test</string>
      ''\t''\t''\t''\t''\t</array>
      ''\t''\t''\t''\t</dict>
      ''\t''\t''\t</dict>
      ''\t''\t</dict>
      ''\t</array>
      ''\t<key>str</key>
      ''\t<string>foo</string>
      ''\t<key>true</key>
      ''\t<true/>
      </dict>
      </plist>'';

    format = formats.plist { };

    input = {
      attrs.foo = 0;
      false = false;
      float = 3.141;
      int = 10;

      list = [
        1
        "hello"
        {
          attrs = {
            key = {
              value = [
                [
                  1
                  2
                  3
                ]
                "test"
              ];
            };
          };
        }
      ];

      null = null;
      str = "foo";
      true = true;
    };
  };

  PlistNull = shouldPass {
    expected = ''
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0">

      </plist>'';

    format = formats.plist { };
    input = null;
  };

  badgerfishToXmlGenerate = shouldPass {
    expected = ''
      <?xml version="1.0" encoding="utf-8"?>
      <root class="example" id="123">
        <child1 name="child1Name">text node</child1>
        <child2>
          <grandchild>This is a grandchild text node.</grandchild>
        </child2>
        <nulltest></nulltest>
      </root>
    '';

    format = formats.xml { };

    input = {
      root = {
        "@class" = "example";
        "@id" = "123";

        child1 = {
          "#text" = "text node";
          "@name" = "child1Name";
        };

        child2 = {
          grandchild = "This is a grandchild text node.";
        };

        nulltest = null;
      };
    };
  };

  cdnAtoms = shouldPass {
    expected = ''
      attrs {
        "foo": null
      }
      "false": false
      "float": 3.141
      "int": 10
      list [
        1,
        null
      ]
      "null": null
      "path": "${./testfile}"
      "str": "foo"
      "true": true
    '';

    format = formats.cdn { };

    input = {
      attrs.foo = null;
      false = false;
      float = 3.141;
      int = 10;

      list = [
        1
        null
      ];

      null = null;
      path = ./testfile;
      str = "foo";
      true = true;
    };
  };

  cdnNull = shouldPass {
    expected = ''
      null: null
    '';

    format = formats.cdn { };
    input = null;
  };

  configobjAtoms = shouldPass {
    expected = ''
      bool = True
      float = 3.141
      int = 10
      str = string
    '';

    format = formats.configobj { };

    input = {
      bool = true;
      float = 3.141;
      int = 10;
      str = "string";
    };
  };

  configobjInvalidAtom = shouldFail {
    format = formats.configobj { };

    input = {
      function = _: 1;
    };
  };

  configobjListWithoutListToValue = shouldPass {
    expected = ''
      items = 1, True, x
    '';

    format = formats.configobj { };

    input = {
      items = [
        1
        true
        "x"
      ];
    };
  };

  configobjNestedAttrsets = shouldPass {
    expected = ''
      [interfaces]
      [[local]]
      address = 123
      [[[coin]]]
      foo = bar
      [[remote]]
      address = 456
      [logging]
      level = info
      rotate = True
      [server]
      enabled = True
      host = 127.0.0.1
      port = 8080
      tags = web, nix, 42
    '';

    format = formats.configobj { };

    input = {
      interfaces = {
        local = {
          address = "123";

          coin = {
            foo = "bar";
          };
        };

        remote = {
          address = "456";
        };
      };

      logging = {
        level = "info";
        rotate = true;
      };

      server = {
        enabled = true;
        host = "127.0.0.1";
        port = 8080;

        tags = [
          "web"
          "nix"
          42
        ];
      };
    };
  };

  configobjNullableValues = shouldPass {
    expected = ''
      nullable = None
      [nested]
      keep = ok
      missing = None
    '';

    format = formats.configobj { };

    input = {
      nested = {
        keep = "ok";
        missing = null;
      };

      nullable = null;
    };
  };

  hcl1Atoms = shouldPass {
    expected = ''
      {
        "enabled": true,
        "number": 42,
        "output": [
          {
            "ip": [
              {
                "value": "127.0.0.1"
              }
            ]
          }
        ],
        "primitive": "just a string",
        "resource": [
          {
            "aws_instance": [
              {
                "example": [
                  {
                    "ami": "ami-12345",
                    "instance_type": "t2.micro"
                  }
                ]
              }
            ]
          }
        ],
        "variable": [
          {
            "region": [
              {
                "default": "us-east-1"
              }
            ]
          }
        ]
      }
    '';

    format = formats.hcl1 { };

    input = {
      enabled = true;
      number = 42;

      output = {
        ip = {
          value = "127.0.0.1";
        };
      };

      primitive = "just a string";

      resource = {
        aws_instance = {
          example = {
            ami = "ami-12345";
            instance_type = "t2.micro";
          };
        };
      };

      variable = {
        region = {
          default = "us-east-1";
        };
      };
    };
  };

  iniAtoms = shouldPass {
    expected = ''
      [foo]
      bool=true
      float=3.141000
      int=10
      str=string
    '';

    format = formats.ini { };

    input = {
      foo = {
        bool = true;
        float = 3.141;
        int = 10;
        str = "string";
      };
    };
  };

  iniCoercedDuplicateKeys = shouldPass rec {
    expected = ''
      [foo]
      bar=1
      bar=2
    '';

    format = formats.ini {
      atomsCoercedToLists = true;
      listsAsDuplicateKeys = true;
    };

    input =
      format.type.merge
        [ ]
        [
          {
            file = "format-test-inner-iniCoercedDuplicateKeys";

            value = {
              foo = {
                bar = 1;
              };
            };
          }
          {
            file = "format-test-inner-iniCoercedDuplicateKeys";

            value = {
              foo = {
                bar = 2;
              };
            };
          }
        ];
  };

  iniCoercedListToValue = shouldPass rec {
    expected = ''
      [foo]
      bar=1, 2
    '';

    format = formats.ini {
      atomsCoercedToLists = true;
      listToValue = lib.concatMapStringsSep ", " (lib.generators.mkValueStringDefault { });
    };

    input =
      format.type.merge
        [ ]
        [
          {
            file = "format-test-inner-iniCoercedListToValue";

            value = {
              foo = {
                bar = 1;
              };
            };
          }
          {
            file = "format-test-inner-iniCoercedListToValue";

            value = {
              foo = {
                bar = 2;
              };
            };
          }
        ];
  };

  iniCoercedNoLists = shouldFail {
    format = formats.ini { atomsCoercedToLists = true; };

    input = {
      foo = {
        bar = 1;
      };
    };
  };

  iniDuplicateKeys = shouldPass {
    expected = ''
      [foo]
      bar=null
      bar=true
      bar=test
      bar=1.200000
      bar=10
      baz=false
      qux=qux
    '';

    format = formats.ini { listsAsDuplicateKeys = true; };

    input = {
      foo = {
        bar = [
          null
          true
          "test"
          1.2
          10
        ];

        baz = false;
        qux = "qux";
      };
    };
  };

  iniDuplicateKeysWithoutList = shouldFail {
    format = formats.ini { };

    input = {
      foo = {
        bar = [
          null
          true
          "test"
          1.2
          10
        ];

        baz = false;
        qux = "qux";
      };
    };
  };

  iniInvalidAtom = shouldFail {
    format = formats.ini { };

    input = {
      foo = {
        function = _: 1;
      };
    };
  };

  iniListToValue = shouldPass {
    expected = ''
      [foo]
      bar=null, true, test, 1.200000, 10
      baz=false
      qux=qux
    '';

    format = formats.ini {
      listToValue = lib.concatMapStringsSep ", " (lib.generators.mkValueStringDefault { });
    };

    input = {
      foo = {
        bar = [
          null
          true
          "test"
          1.2
          10
        ];

        baz = false;
        qux = "qux";
      };
    };
  };

  iniNoCoercedNoLists = shouldFail {
    format = formats.ini { atomsCoercedToLists = false; };

    input = {
      foo = {
        bar = 1;
      };
    };
  };

  iniWithGlobalCoercedDuplicateKeys = shouldPass rec {
    expected = ''
      baz=3
      baz=4

      [foo]
      bar=2
      bar=1
    '';

    format = formats.iniWithGlobalSection {
      atomsCoercedToLists = true;
      listsAsDuplicateKeys = true;
    };

    input =
      format.type.merge
        [ ]
        [
          {
            file = "format-test-inner-iniWithGlobalCoercedDuplicateKeys";

            value = {
              globalSection = {
                baz = 4;
              };

              sections = {
                foo = {
                  bar = 1;
                };
              };
            };
          }
          {
            file = "format-test-inner-iniWithGlobalCoercedDuplicateKeys";

            value = {
              globalSection = {
                baz = 3;
              };

              sections = {
                foo = {
                  bar = 2;
                };
              };
            };
          }
        ];
  };

  iniWithGlobalCoercedListToValue = shouldPass rec {
    expected = ''
      baz=3, 4

      [foo]
      bar=2, 1
    '';

    format = formats.iniWithGlobalSection {
      atomsCoercedToLists = true;
      listToValue = lib.concatMapStringsSep ", " (lib.generators.mkValueStringDefault { });
    };

    input =
      format.type.merge
        [ ]
        [
          {
            file = "format-test-inner-iniWithGlobalCoercedListToValue";

            value = {
              globalSection = {
                baz = 4;
              };

              sections = {
                foo = {
                  bar = 1;
                };
              };
            };
          }
          {
            file = "format-test-inner-iniWithGlobalCoercedListToValue";

            value = {
              globalSection = {
                baz = 3;
              };

              sections = {
                foo = {
                  bar = 2;
                };
              };
            };
          }
        ];
  };

  iniWithGlobalCoercedNoLists = shouldFail {
    format = formats.iniWithGlobalSection { atomsCoercedToLists = true; };

    input = {
      foo = {
        bar = 1;
      };

      globalSection = {
        baz = 4;
      };
    };
  };

  iniWithGlobalEverything = shouldPass {
    expected = ''
      bar=true

      [foo]
      bool=true
      float=3.141000
      int=10
      str=string
    '';

    format = formats.iniWithGlobalSection { };

    input = {
      globalSection = {
        bar = true;
      };

      sections = {
        foo = {
          bool = true;
          float = 3.141;
          int = 10;
          str = "string";
        };
      };
    };
  };

  iniWithGlobalListToValue = shouldPass {
    expected = ''
      bar=null, true, test, 1.200000, 10
      baz=false
      qux=qux

      [foo]
      bar=null, true, test, 1.200000, 10
      baz=false
      qux=qux
    '';

    format = formats.iniWithGlobalSection {
      listToValue = lib.concatMapStringsSep ", " (lib.generators.mkValueStringDefault { });
    };

    input = {
      globalSection = {
        bar = [
          null
          true
          "test"
          1.2
          10
        ];

        baz = false;
        qux = "qux";
      };

      sections = {
        foo = {
          bar = [
            null
            true
            "test"
            1.2
            10
          ];

          baz = false;
          qux = "qux";
        };
      };
    };
  };

  iniWithGlobalNoCoercedNoLists = shouldFail {
    format = formats.iniWithGlobalSection { atomsCoercedToLists = false; };

    input = {
      foo = {
        bar = 1;
      };

      globalSection = {
        baz = 4;
      };
    };
  };

  iniWithGlobalNoSections = shouldPass {
    expected = "";
    format = formats.iniWithGlobalSection { };
    input = { };
  };

  iniWithGlobalOnlyGlobal = shouldPass {
    expected = ''
      bar=baz

    '';

    format = formats.iniWithGlobalSection { };

    input = {
      globalSection = {
        bar = "baz";
      };
    };
  };

  iniWithGlobalOnlySections = shouldPass {
    expected = ''
      [foo]
      bar=baz
    '';

    format = formats.iniWithGlobalSection { };

    input = {
      sections = {
        foo = {
          bar = "baz";
        };
      };
    };
  };

  iniWithGlobalWrongSections = shouldFail {
    format = formats.iniWithGlobalSection { };

    input = {
      foo = { };
    };
  };

  # This test is responsible for
  #   1. testing type coercions
  #   2. providing a more readable example test
  # Whereas java-properties/default.nix tests the low level escaping, etc.
  javaProperties = shouldPass {
    expected = ''
      # Generated with Nix

      1 = 2
      contradictions = false
      floaty = 3.141500
      foo = bar
      package = ${pkgs.hello}
      tautologies = true
      \u00fctf\ 8 = d\u00fbh
      \u0627\u0644\u062c\u0628\u0631 = \u0623\u0643\u062b\u0631 \u0645\u0646 \u0645\u062c\u0631\u062f \u0623\u0631\u0642\u0627\u0645
    '';

    format = formats.javaProperties { };

    input = {
      # # Disallowed at eval time, because it's ambiguous:
      # # add to store or convert to string?
      # root = /root;
      "1" = 2;
      contradictions = false;
      floaty = 3.1415;
      foo = "bar";
      package = pkgs.hello;
      tautologies = true;
      "ütf 8" = "dûh";
      # NB: Some editors (vscode) show this _whole_ line in right-to-left order
      "الجبر" = "أكثر من مجرد أرقام";
    };
  };

  jsonAtoms = shouldPass {
    expected = ''
      {
        "attrs": {
          "foo": null
        },
        "false": false,
        "float": 3.141,
        "int": 10,
        "list": [
          null,
          null
        ],
        "null": null,
        "path": "${./testfile}",
        "str": "foo",
        "true": true
      }
    '';

    format = formats.json { };

    input = {
      attrs.foo = null;
      false = false;
      float = 3.141;
      int = 10;

      list = [
        null
        null
      ];

      null = null;
      path = ./testfile;
      str = "foo";
      true = true;
    };
  };

  jsonNull = shouldPass {
    expected = ''
      null
    '';

    format = formats.json { };
    input = null;
  };

  keyValueAtoms = shouldPass {
    expected = ''
      bool=true
      float=3.141000
      int=10
      str=string
    '';

    format = formats.keyValue { };

    input = {
      bool = true;
      float = 3.141;
      int = 10;
      str = "string";
    };
  };

  keyValueDuplicateKeys = shouldPass {
    expected = ''
      bar=null
      bar=true
      bar=test
      bar=1.200000
      bar=10
      baz=false
      qux=qux
    '';

    format = formats.keyValue { listsAsDuplicateKeys = true; };

    input = {
      bar = [
        null
        true
        "test"
        1.2
        10
      ];

      baz = false;
      qux = "qux";
    };
  };

  keyValueListToValue = shouldPass {
    expected = ''
      bar=null, true, test, 1.200000, 10
      baz=false
      qux=qux
    '';

    format = formats.keyValue {
      listToValue = lib.concatMapStringsSep ", " (lib.generators.mkValueStringDefault { });
    };

    input = {
      bar = [
        null
        true
        "test"
        1.2
        10
      ];

      baz = false;
      qux = "qux";
    };
  };

  luaBindings = shouldPass {
    expected = ''
      _false = false
      _true = true
      attrs = {
        ["foo"] = nil,
      }
      float = 3.141
      inline = (hello("world"))
      int = 10
      list = {
        nil,
        nil,
      }
      null = nil
      path = "${./testfile}"
      str = "foo"
    '';

    format = formats.lua {
      asBindings = true;
    };

    input = {
      _false = false;
      _true = true;
      attrs.foo = null;
      float = 3.141;
      inline = lib.mkLuaInline "hello('world')";
      int = 10;

      list = [
        null
        null
      ];

      null = null;
      path = ./testfile;
      str = "foo";
    };
  };

  luaNull = shouldPass {
    expected = ''
      return nil
    '';

    format = formats.lua { };
    input = null;
  };

  luaTable = shouldPass {
    expected = ''
      return {
        ["attrs"] = {
          ["foo"] = nil,
        },
        ["false"] = false,
        ["float"] = 3.141,
        ["inline"] = (hello("world")),
        ["int"] = 10,
        ["list"] = {
          nil,
          nil,
        },
        ["null"] = nil,
        ["path"] = "${./testfile}",
        ["str"] = "foo",
        ["true"] = true,
      }
    '';

    format = formats.lua { };

    input = {
      attrs.foo = null;
      false = false;
      float = 3.141;
      inline = lib.mkLuaInline "hello('world')";
      int = 10;

      list = [
        null
        null
      ];

      null = null;
      path = ./testfile;
      str = "foo";
      true = true;
    };
  };

  nixConfAtoms = shouldPass {
    # note that null type is hard to test here,
    # as it involves a trailing space our formatter will remove here
    expected = ''
      # WARNING: this file is generated from the nix.* options in
      # your NixOS configuration, typically
      # /etc/nixos/configuration.nix.  Do not edit it!
      auto-optimise-store = true
      cores = 0
      store = auto

      ignore-try = false
    '';

    format = formats.nixConf {
      version = pkgs.nix.version;
      extraOptions = "ignore-try = false";
      package = pkgs.nix;
    };

    input = {
      auto-optimise-store = true;
      cores = 0;
      store = "auto";
    };
  };

  nixConfNull = shouldFail {
    format = formats.nixConf {
      version = pkgs.nix.version;
      extraOptions = "ignore-try = false";
      package = pkgs.nix;
    };

    input = null;
  };

  phpAtoms = shouldPass rec {
    expected = ''
      <?php
      declare(strict_types=1);
      $config = ['attrs' => ['foo' => null], 'false' => false, 'float' => 3.141000, 'int' => 10, 'list' => [null, null], 'mixed' => [10, 3.141000, 'attrs' => ['foo' => null], 'str' => 'foo'], 'null' => null, 'raw' => random_function(), 'str' => 'foo', 'str_special' => 'foo
      testhello\'\'\'${"'"}, 'true' => true];
    '';

    format = formats.php { finalVariable = "config"; };

    input = {
      attrs.foo = null;
      false = false;
      float = 3.141;
      int = 10;

      list = [
        null
        null
      ];

      mixed = format.lib.mkMixedArray [ 10 3.141 ] {
        attrs.foo = null;
        str = "foo";
      };

      null = null;
      raw = format.lib.mkRaw "random_function()";
      str = "foo";
      str_special = "foo\ntesthello'''";
      true = true;
    };
  };

  phpNull = shouldPass {
    expected = ''
      <?php
      declare(strict_types=1);
      $config = null;
    '';

    format = formats.php { finalVariable = "config"; };
    input = null;
  };

  phpReturn = shouldPass {
    expected = ''
      <?php
      declare(strict_types=1);
      return ['attrs' => ['foo' => null], 'float' => 3.141000, 'int' => 10, 'str' => 'foo', 'str_special' => 'foo
      testhello\'\'\'${"'"}];
    '';

    format = formats.php { };

    input = {
      attrs.foo = null;
      float = 3.141;
      int = 10;
      str = "foo";
      str_special = "foo\ntesthello'''";
    };
  };

  pythonVars = shouldPass (
    let
      format = formats.pythonVars { };
    in
    {
      inherit format;

      expected = ''
        import re
        import a.b.c

        attrs = {
            "conditional": 1 if True else 2,
            "foo": None,
        }
        bool = True
        float = 3.141
        func = re.findall(r"\bf[a-z]*", "which foot or hand fell fastest")
        int = 10
        list = [
            None,
            1,
            "str",
            True,
            1 if True else 2,
        ]
        null = None
        str = "foo"
        str_special = "foo\ntesthello''''"
      '';

      input = {
        _imports = [
          "re"
          "a.b.c"
        ];

        attrs = {
          conditional = format.lib.mkRaw "1 if True else 2";
          foo = null;
        };

        bool = true;
        float = 3.141;
        func = format.lib.mkRaw "re.findall(r'\\bf[a-z]*', 'which foot or hand fell fastest')";
        int = 10;

        list = [
          null
          1
          "str"
          true
          (format.lib.mkRaw "1 if True else 2")
        ];

        null = null;
        str = "foo";
        str_special = "foo\ntesthello'''";
      };
    }
  );

  pythonVarsNull = shouldFail {
    format = formats.pythonVars { };
    input = null;
  };

  tomlAtoms = shouldPass {
    expected = ''
      false = false
      float = 3.141
      int = 10
      list = [1, 2]
      str = "foo"
      true = true

      [attrs]
      foo = "foo"

      [level1.level2.level3]
      level4 = "deep"
    '';

    format = formats.toml { };

    input = {
      attrs.foo = "foo";
      false = false;
      float = 3.141;
      int = 10;
      level1.level2.level3.level4 = "deep";

      list = [
        1
        2
      ];

      str = "foo";
      true = true;
    };
  };

  # Regression test for https://github.com/sclevine/yj/issues/52
  # yj truncates keys at the first comma because it stores TOML keys in Go
  # struct tags, where commas are option separators.
  # e.g. "stack(x,n)" is emitted as "stack(x" — silently losing data.
  tomlCommaInKey = shouldPass {
    expected = ''
      "stack(x,n)" = "foobar"
    '';

    format = formats.toml { };

    input = {
      "stack(x,n)" = "foobar";
    };
  };

  # Regression test for https://github.com/NixOS/nixpkgs/issues/511970
  # yj crashes on arrays mixing scalars and attrsets (heterogeneous arrays),
  # e.g. Helix language-server configs like ["bash-ls", {name = "ts-ls"; ...}].
  # TOML 1.0 allows mixed-type arrays; the converter must emit them as
  # inline arrays with inline tables.
  tomlHeterogeneousArray = shouldPass {
    expected = ''
      language-server = ["bash-language-server", { except-features = ["diagnostics"], name = "typescript-language-server" }]
    '';

    format = formats.toml { };

    input = {
      language-server = [
        "bash-language-server"
        {
          except-features = [ "diagnostics" ];
          name = "typescript-language-server";
        }
      ];
    };
  };

  tomlNull = shouldFail {
    format = formats.toml { };
    input = null;
  };

  xmlNull = shouldFail {
    format = formats.xml { };
    input = null;
  };

  yaml_1_1Atoms = shouldPass {
    expected = ''
      attrs:
        foo: null
      'false': false
      float: 3.141
      list:
      - null
      - null
      'no': 'no'
      'null': null
      path: ${./testfile}
      str: foo
      time: '22:30:00'
      'true': true
    '';

    format = formats.yaml_1_1 { };

    input = {
      attrs.foo = null;
      false = false;
      float = 3.141;

      list = [
        null
        null
      ];

      no = "no";
      null = null;
      path = ./testfile;
      str = "foo";
      time = "22:30:00";
      true = true;
    };
  };

  yaml_1_1Null = shouldPass {
    expected = ''
      null
      ...
    '';

    format = formats.yaml_1_1 { };
    input = null;
  };

  yaml_1_2Atoms = shouldPass {
    expected = ''
      attrs:
        foo: null
      'false': false
      float: 3.141
      list:
      - null
      - null
      no: no
      'null': null
      path: ${./testfile}
      str: foo
      time: 22:30:00
      'true': true
    '';

    format = formats.yaml_1_2 { };

    input = {
      attrs.foo = null;
      false = false;
      float = 3.141;

      list = [
        null
        null
      ];

      no = "no";
      null = null;
      path = ./testfile;
      str = "foo";
      time = "22:30:00";
      true = true;
    };
  };

  yaml_1_2Null = shouldPass {
    # nixfmt insists on removing indentation, so force it with ${"  "}
    expected = ''

      ${"  "}null
    '';

    format = formats.yaml_1_2 { };
    input = null;
  };
}
