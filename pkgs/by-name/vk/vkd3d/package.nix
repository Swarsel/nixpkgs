{
  lib,
  stdenv,
  fetchFromGitLab,
  autoreconfHook,
  bison,
  flex,
  perlPackages,
  pkg-config,
  spirv-headers,
  vulkan-headers,
  vulkan-loader,
  wine,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "vkd3d";
  version = "2.0";

  src = fetchFromGitLab {
    owner = "wine";
    repo = "vkd3d";
    tag = "vkd3d-${finalAttrs.version}";
    hash = "sha256-S0sQaDt0aYYi2Rs/MNRIQ9oOuHm9/LsxaSL93M5jBRw=";
    domain = "gitlab.winehq.org";
  };

  outputs = [
    "out"
    "dev"
    "lib"
  ];

  strictDeps = true;

  nativeBuildInputs = [
    autoreconfHook
    bison
    flex
    perlPackages.perl
    perlPackages.JSON
    pkg-config
    wine
  ];

  buildInputs = [
    spirv-headers
    vulkan-headers
    vulkan-loader
  ];

  meta = {
    inherit (wine.meta) platforms;
    description = "Direct3D to Vulkan translation library";

    longDescription = ''
      Vkd3d is a 3D graphics library built on top of Vulkan. It has an API very
      similar, but not identical, to Direct3D 12.

      Vkd3d can be used by projects that target Direct3D 12 as a drop-in
      replacement at build-time with some modest source modifications.

      If vkd3d is available when building Wine, then Wine will use it to support
      Direct3D 12 applications.
    '';

    homepage = "https://gitlab.winehq.org/wine/vkd3d";
    license = with lib.licenses; [ lgpl21Plus ];
    maintainers = with lib.maintainers; [ liberodark ];
    mainProgram = "vkd3d-compiler";
  };
})
