{ lib, testers }:
lib.recurseIntoAttrs {
  # Positive tests
  indent2 = testers.shfmt {
    src = ./src/indent2.sh;
    indent = 2;
    name = "indent2";
  };

  indent2Bin = testers.shfmt {
    src = ./src;
    indent = 2;
    name = "indent2Bin";
  };

  indent2BinWith0 = testers.testBuildFailure' {
    drv = testers.shfmt {
      src = ./src;
      indent = 0;
      name = "indent2Bin";
    };
  };

  indent2BinWith4 = testers.testBuildFailure' {
    drv = testers.shfmt {
      src = ./src;
      indent = 4;
      name = "indent2Bin";
    };
  };

  # Negative tests
  indent2With0 = testers.testBuildFailure' {
    drv = testers.shfmt {
      src = ./src/indent2.sh;
      indent = 0;
      name = "indent2";
    };
  };

  indent2With4 = testers.testBuildFailure' {
    drv = testers.shfmt {
      src = ./src/indent2.sh;
      indent = 4;
      name = "indent2";
    };
  };
}
