{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  directx-shader-compiler,
  ninja,
  nix-update-script,
  runCommand,
  sdl3,
  spirv-cross,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "sdl3-shadercross";
  version = "0-unstable-2026-06-26";

  src = fetchFromGitHub {
    owner = "libsdl-org";
    repo = "SDL_shadercross";
    rev = "e55cf5e31ced6f3d1be5cc6d0c50e99384f9f4ba";
    hash = "sha256-oKetmnMb+SeRlscWmzGln6nR1M7fBkgybFlB1bh1Cos=";
  };

  outputs = [
    "out"
    "lib"
    "dev"
  ];

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    ninja
  ];

  buildInputs = [
    sdl3
    spirv-cross
    directx-shader-compiler
  ];

  cmakeFlags = [
    (lib.cmakeBool "SDLSHADERCROSS_SHARED" (!stdenv.hostPlatform.isStatic))
    (lib.cmakeBool "SDLSHADERCROSS_STATIC" stdenv.hostPlatform.isStatic)
    (lib.cmakeBool "SDLSHADERCROSS_INSTALL" true)
    (lib.cmakeBool "SDLSHADERCROSS_TESTS" finalAttrs.finalPackage.doCheck)
  ];

  doCheck = true;

  passthru.tests.example = runCommand "compile-spv-example" { } ''
    cat > example.vert.hlsl << EOF
    struct Input
    {
        float4 position : POSITION;
        float3 color : COLOR;
    };
    float3 main(in Input IN) : COLOR
    {
        return IN.color;
    };
    EOF
    ${lib.getExe finalAttrs.finalPackage} example.vert.hlsl -o example.spv
    touch $out
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    description = "Shader translation library";
    homepage = "https://github.com/libsdl-org/SDL_shadercross";
    license = lib.licenses.zlib;
    maintainers = with lib.maintainers; [ nyxonios ];
    platforms = lib.platforms.linux;
    mainProgram = "shadercross";
    teams = [ lib.teams.sdl ];
  };
})
