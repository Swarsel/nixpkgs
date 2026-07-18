{
  lib,
  shfmt,
  stdenvNoCC,
}:
# See https://nixos.org/manual/nixpkgs/unstable/#tester-shfmt
# or doc/build-helpers/testers.chapter.md
{
  name,
  src,
  indent ? 2,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  inherit src indent;
  strictDeps = true;
  nativeBuildInputs = [ shfmt ];
  doCheck = true;

  checkPhase = ''
    shfmt --diff --indent $indent --simplify "$src"
  '';

  installPhase = ''
    touch "$out"
  '';

  __structuredAttrs = true;
  dontBuild = true;
  dontConfigure = true;
  dontUnpack = true; # Unpack phase tries to extract archive
  name = "shfmt-${name}";
})
