{
  lib,
  fetchFromGitHub,
  clangStdenv,
  cmake,
  hiredis,
  llvm,
  ninja,
  nix-update-script,
  re2c,
  z3,
}:

clangStdenv.mkDerivation (finalAttrs: {
  pname = "alive2";
  version = "21.0";

  src = fetchFromGitHub {
    owner = "AliveToolkit";
    repo = "alive2";
    tag = "v${finalAttrs.version}";
    hash = "sha256-LL6/Epn6iHQJGKb8PX+U6zvXK/WTlvOIJPr6JuGRsSU=";
  };

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail '-Werror' "" \
      --replace-fail 'find_package(Git REQUIRED)' ""
  '';

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    ninja
    re2c
  ];

  buildInputs = [
    z3
    hiredis
    llvm
  ];

  cmakeFlags = [
    (lib.cmakeFeature "BUILD_TV" "1")
  ];

  env = {
    ALIVE2_HOME = "$PWD";
    LLVM2_BUILD = "$LLVM2_HOME/build";
    LLVM2_HOME = "${llvm}";
  };

  preBuild = ''
    mkdir -p build
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp alive $out/bin/
    cp alive-jobserver $out/bin/
    cp alive-tv $out/bin/
    rm -rf $out/bin/CMakeFiles $out/bin/*.o
    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Automatic verification of LLVM optimizations";
    homepage = "https://github.com/AliveToolkit/alive2";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ shogo ];
    platforms = lib.platforms.all;
    mainProgram = "alive";
    teams = [ lib.teams.ngi ];
  };
})
