{
  lib,
  fetchFromGitHub,
  crystal,
  llvmPackages,
  makeWrapper,
  openssl,
}:

let
  version = "0.17.1";
  src = fetchFromGitHub {
    owner = "elbywan";
    repo = "crystalline";
    tag = "v${version}";
    hash = "sha256-SIfInDY6KhEwEPZckgobOrpKXBDDd0KhQt/IjdGBhWo=";
  };
in
crystal.buildCrystalPackage {
  inherit version src;
  pname = "crystalline";

  nativeBuildInputs = [
    llvmPackages.llvm
    openssl
    makeWrapper
  ];

  env.LLVM_CONFIG = lib.getExe' (lib.getDev llvmPackages.llvm) "llvm-config";

  preConfigure = ''
    substituteInPlace "./src/crystalline/main.cr" \
      --replace-fail '`shards version #{__DIR__}`' '"${version}"' \
      --replace-fail 'system("git rev-parse --short HEAD || echo unknown").stringify' '"${src.rev}"'
  '';

  doCheck = false;

  postInstall = ''
    wrapProgram "$out/bin/crystalline" --prefix PATH : '${
      lib.makeBinPath [
        (lib.getDev llvmPackages.llvm)
      ]
    }'
  '';

  doInstallCheck = false;

  crystalBinaries.crystalline = {
    src = "src/crystalline.cr";

    options = [
      "--release"
      "--no-debug"
      "--progress"
      "-Dpreview_mt"
    ];
  };

  format = "crystal";
  shardsFile = ./shards.nix;

  meta = {
    description = "Language Server Protocol implementation for Crystal";
    homepage = "https://github.com/elbywan/crystalline";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ donovanglover ];
    mainProgram = "crystalline";
  };
}
