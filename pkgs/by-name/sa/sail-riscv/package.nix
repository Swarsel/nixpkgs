{
  lib,
  stdenv,
  fetchFromGitHub,
  cli11,
  cmake,
  gmp,
  jsoncons,
  ninja,
  ocamlPackages,
  pkg-config,
  z3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "sail-riscv";
  version = "0.12";

  src = fetchFromGitHub {
    owner = "riscv";
    repo = "sail-riscv";
    tag = finalAttrs.version;
    hash = "sha256-pi/XP6+NX/wNpBESmnEg2d5cppMpMwFripDPk9vTx9I=";
  };

  patches = [
    ./unvendor-deps.patch
  ];

  strictDeps = true;

  nativeBuildInputs = [
    z3
    cmake
    pkg-config
    ninja
    ocamlPackages.sail
  ];

  buildInputs = [
    gmp
    # Header-only
    jsoncons
    cli11
  ];

  cmakeFlags = [
    (lib.cmakeBool "ENABLE_LTO" true)
  ];

  meta = {
    description = "Formal specification of the RISC-V architecture, written in Sail";
    homepage = "https://github.com/riscv/sail-riscv";
    license = lib.licenses.bsd2;

    maintainers = with lib.maintainers; [
      xokdvium
    ];
  };
})
