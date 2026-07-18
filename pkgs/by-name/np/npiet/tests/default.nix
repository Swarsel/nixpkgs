{ fetchurl, callPackage }:
let
  # More examples can be found at https://www.dangermouse.net/esoteric/piet/samples.html
  hello-program = fetchurl {
    hash = "sha256-E8OMu0b/oU8lDF3X4o5WMnnD1IKNT2YF+qe4MXLuczI=";
    url = "https://www.dangermouse.net/esoteric/piet/hw6.png";
  };
  prime-tester-program = fetchurl {
    hash = "sha256-4eaJweV/n73byoWZWCXiMLkfSEhMPf5itVwz48AK/FA=";
    url = "https://www.bertnase.de/npiet/nprime.gif";
  };
  brainfuck-interpreter-program = fetchurl {
    hash = "sha256-LIfOG0KFpr4nxAtLLeIsPQl+8Ujyvfz/YnEm/HRoVjY=";
    url = "https://www.dangermouse.net/esoteric/piet/piet_bfi.gif";
  };
in
{
  brainfuck = callPackage ./run-test.nix {
    expectedOutput = "Piet";
    programInput = ",+>,+>,+>,+.<.<.<.|sdhO";
    programPath = brainfuck-interpreter-program;
    testName = "brainfuck";
  };

  hello = callPackage ./run-test.nix {
    expectedOutput = "Hello, world!";
    programPath = hello-program;
    testName = "hello";
  };

  no-prime = callPackage ./run-test.nix {
    expectedOutput = "N";
    programInput = "2070";
    programPath = prime-tester-program;
    testName = "no-prime";
  };

  prime = callPackage ./run-test.nix {
    expectedOutput = "Y";
    programInput = "2069";
    programPath = prime-tester-program;
    testName = "prime";
  };
}
