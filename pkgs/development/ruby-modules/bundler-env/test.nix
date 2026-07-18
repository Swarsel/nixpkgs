{
  callPackage,
  should,
  stubs,
  test,
}:
let
  bundlerEnv = callPackage ./default.nix stubs // {
    basicEnv = callPackage ../bundled-common stubs;
  };

  justName = bundlerEnv {
    gemset = ./test/gemset.nix;
    name = "test-0.1.2";
  };

  pnamed = bundlerEnv {
    pname = "test";
    gemdir = ./test;
    gemfile = ./test/Gemfile;
    gemset = ./test/gemset.nix;
    lockfile = ./test/Gemfile.lock;
  };
in
builtins.concatLists [
  (test.run "bundlerEnv { name }" justName {
    name = should.equal "test-0.1.2";
  })
  (test.run "bundlerEnv { pname }" pnamed [
    (should.haveKeys [
      "name"
      "env"
      "postBuild"
    ])
    {
      env = should.beASet;
      postBuild = should.havePrefix "/nix/store";
      name = should.equal "test-0.1.2";
    }
  ])
]
