{ rootSrc, rustPlatform }:
let
  mkRustpkgs = _: p: rustPlatform.buildRustPackage p;
in
(builtins.mapAttrs mkRustpkgs {
  iir-rust = rec {
    pname = "iir-rust";
    version = "0.1.3";
    src = rootSrc;
    nativeBuildInputs = [ rustPlatform.bindgenHook ];
    cargoHash = "sha256-CV1e/f3oCKW5mTbQnFBnp7E2d9nFyDwY3qclP2HwdPM=";
    doCheck = false;
    sourceRoot = "${src.name}/src/operation/iIR/source/iir-rust/iir";
  };

  liberty-parser = rec {
    pname = "liberty-parser";
    version = "0.1.0";
    src = rootSrc;
    nativeBuildInputs = [ rustPlatform.bindgenHook ];
    cargoHash = "sha256-nRIOuSz5ImENvKeMAnthmBo+2/Jy5xbM66xkcfVCTMI=";
    doCheck = false;
    sourceRoot = "${src.name}/src/database/manager/parser/liberty/lib-rust/liberty-parser";
  };

  sdf_parse = rec {
    pname = "sdf_parse";
    version = "0.1.0";
    src = rootSrc;
    nativeBuildInputs = [ rustPlatform.bindgenHook ];
    cargoHash = "sha256-PORA/9DDIax4lOn/pzmi7Y8mCCBUphMTzbBsb64sDl0=";
    sourceRoot = "${src.name}/src/database/manager/parser/sdf/sdf_parse";
  };

  spef-parser = rec {
    pname = "spef-parser";
    version = "0.2.4";
    src = rootSrc;
    nativeBuildInputs = [ rustPlatform.bindgenHook ];
    cargoHash = "sha256-Qr/oXTqn2gaxyAyLsRjaXNniNzIYVzPGefXTdkULmYk=";
    sourceRoot = "${src.name}/src/database/manager/parser/spef/spef-parser";
  };

  vcd_parser = rec {
    pname = "vcd_parser";
    version = "0.1.0";
    src = rootSrc;
    nativeBuildInputs = [ rustPlatform.bindgenHook ];
    cargoHash = "sha256-xcfVzDrnW4w3fU7qo6xzSQeIH8sEbEyzPF92F5tDcAk=";
    doCheck = false;
    sourceRoot = "${src.name}/src/database/manager/parser/vcd/vcd_parser";
  };

  verilog-parser = rec {
    pname = "verilog-parser";
    version = "0.1.0";
    src = rootSrc;
    nativeBuildInputs = [ rustPlatform.bindgenHook ];
    cargoHash = "sha256-ooxY8Q8bfD+klBGfpTDD3YyWptEOGGHDoyamhjlSNTM=";
    doCheck = false;
    sourceRoot = "${src.name}/src/database/manager/parser/verilog/verilog-rust/verilog-parser";
  };
})
