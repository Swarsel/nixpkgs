{
  lib,
  stdenv,
  callPackage,
  glslang,
  meson,
  ninja,
  wine,
}:

let
  sources = callPackage ./sources.nix { };
in
stdenv.mkDerivation (finalAttrs: {
  inherit (sources.vkd3d-proton) pname version src;

  outputs = [
    "out"
    "dev"
  ];

  postPatch = ''
    substituteInPlace meson.build \
      --replace-fail "vkd3d_build = vcs_tag(" \
                     "vkd3d_build = vcs_tag( fallback : '$(cat .nixpkgs-auxfiles/vkd3d_build)'", \
      --replace-fail "vkd3d_version = vcs_tag(" \
                     "vkd3d_version = vcs_tag( fallback : '$(cat .nixpkgs-auxfiles/vkd3d_version)'",
  '';

  strictDeps = true;

  nativeBuildInputs = [
    glslang
    meson
    ninja
    wine
  ];

  passthru = {
    inherit sources;
  };

  meta = {
    inherit (wine.meta) platforms;
    description = "Fork of VKD3D, which aims to implement the full Direct3D 12 API on top of Vulkan";
    homepage = "https://github.com/HansKristian-Work/vkd3d-proton";
    license = with lib.licenses; [ lgpl21Plus ];
    maintainers = [ ];
  };
})
