{
  lib,
  stdenv,
  fetchFromGitHub,
  binutils,
  bison,
  makeWrapper,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "myrddin";
  version = "0.3.1";

  src = fetchFromGitHub {
    owner = "oridb";
    repo = "mc";
    rev = "r${finalAttrs.version}";
    sha256 = "7ImjiG/rIKGPHq3Vh/mftY7pqw/vfOxD3LJeT87HmCk=";
  };

  postPatch = ''
    substituteInPlace mk/c.mk \
      --replace "-Werror" ""
  '';

  nativeBuildInputs = [
    bison
    pkg-config
    makeWrapper
  ];

  buildPhase = ''
    make bootstrap -j$NIX_BUILD_CORES
    make -j$NIX_BUILD_CORES
  '';

  doCheck = true;

  checkPhase = ''
    make check
  '';

  postInstall = ''
    for b in $out/bin/*; do
      wrapProgram $b --prefix PATH : $out/bin:${lib.makeBinPath [ binutils ]}
    done
  '';

  meta = {
    description = "Systems language that is both powerful and fun to use";
    homepage = "https://myrlang.org/";
    license = lib.licenses.mit;
    maintainers = [ ];
    platforms = lib.platforms.all;

    # darwin: never built on Hydra https://hydra.nixos.org/job/nixpkgs/trunk/myrddin.x86_64-darwin
    broken =
      (stdenv.hostPlatform.isLinux && stdenv.hostPlatform.isAarch64) || stdenv.hostPlatform.isDarwin;
  };
})
