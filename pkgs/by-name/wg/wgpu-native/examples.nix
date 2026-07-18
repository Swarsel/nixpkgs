{
  lib,
  stdenv,
  cmake,
  glfw,
  libx11,
  libxrandr,
  makeWrapper,
  ninja,
  pkg-config,
  src,
  version,
  vulkan-loader,
  wayland,
  wgpu-native,
}:

stdenv.mkDerivation (finalAttrs: {
  inherit version src;
  pname = "wgpu-native-examples";

  postPatch = ''
    substituteInPlace ./CMakeLists.txt \
      --replace-fail 'add_subdirectory(vendor/glfw)' 'find_package(glfw3 3.4 REQUIRED)'
  '';

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    pkg-config
    ninja
    makeWrapper
  ];

  buildInputs = [
    wgpu-native
    glfw
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    wayland
    libx11
    libxrandr
  ];

  installPhase = ''
    runHook preInstall

    concatTo makeWrapperArgsArray makeWrapperArgs

    # find all executables that have the same name as their directory
    for executable in $(find . -regex '.*\(/[^/]*\)\1' -type f -executable)
    do
      target="$(basename "$(dirname "$executable")")"
      install -Dm755 $executable -t $out/bin
      mkdir -p $out/share/$target
      wrapProgram $out/bin/$target --chdir $out/share/$target "''${makeWrapperArgsArray[@]}"

      # The examples expect their shaders in the CWD, so we copy them into the store
      # and wrap the examples to run in the directory containing the shader.
      for shader in $(find ../$target -type f -name '*.wgsl'); do
        install -Dm644 $shader $out/share/$target/
      done
    done

    runHook postInstall
  '';

  makeWrapperArgs = lib.optionals (finalAttrs.runtimeInputs != [ ]) [
    "--prefix LD_LIBRARY_PATH : ${toString (lib.makeLibraryPath finalAttrs.runtimeInputs)}"
  ];

  runtimeInputs = lib.optionals stdenv.hostPlatform.isLinux [
    # Without wayland in library path, this warning is raised:
    # "No windowing system present. Using surfaceless platform"
    wayland
    # Without vulkan-loader present, wgpu won't find any adapter
    vulkan-loader
  ];

  sourceRoot = "${src.name}/examples";

  meta = wgpu-native.meta // {
    description = "Examples for the native WebGPU implementation based on wgpu-core";
    mainProgram = "triangle";
  };
})
