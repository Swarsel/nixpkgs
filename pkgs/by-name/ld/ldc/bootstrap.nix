{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  curl,
  fixDarwinDylibNames,
  libxml2,
  tzdata,
}:

let
  inherit (stdenv) hostPlatform;
  OS = if hostPlatform.isDarwin then "osx" else hostPlatform.parsed.kernel.name;
  ARCH =
    if hostPlatform.isDarwin && hostPlatform.isAarch64 then "arm64" else hostPlatform.parsed.cpu.name;
  version = "1.41.0";
  hashes = {
    linux-aarch64 = "sha256-HEuVChPVM3ntT1ZDZsJ+xW1iYeIWhogNcMdIaz6Me6g=";
    linux-x86_64 = "sha256-SkOUV/D+WeadAv1rV1Sfw8h60PVa2fueQlB7b44yfI8=";
    osx-arm64 = "sha256-FXJnBC8QsEchBhkxSqcZtPC/iHYB6TscY0qh7LPFRuQ=";
    # Get these from `nix store prefetch-file https://github.com/ldc-developers/ldc/releases/download/v1.19.0/ldc2-1.19.0-osx-x86_64.tar.xz` etc..
    osx-x86_64 = "sha256-W8/0i2PFakXbqs2wxb3cjqa+htSgx7LHyDGOBH9yEYE=";
  };
in
stdenv.mkDerivation {
  inherit version;
  pname = "ldc-bootstrap";

  src = fetchurl rec {
    url = "https://github.com/ldc-developers/ldc/releases/download/v${version}/${name}";
    hash = hashes."${OS}-${ARCH}" or (throw "missing bootstrap hash for ${OS}-${ARCH}");
    name = "ldc2-${version}-${OS}-${ARCH}.tar.xz";
  };

  nativeBuildInputs =
    lib.optionals hostPlatform.isLinux [
      autoPatchelfHook
    ]
    ++ lib.optional hostPlatform.isDarwin fixDarwinDylibNames;

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    libxml2
    stdenv.cc.cc
  ];

  propagatedBuildInputs = [
    curl
    tzdata
  ];

  installPhase = ''
    mkdir -p $out

    mv bin etc import lib LICENSE README $out/
  '';

  dontBuild = true;
  dontConfigure = true;

  meta = {
    description = "LLVM-based D Compiler";
    homepage = "https://github.com/ldc-developers/ldc";

    # from https://github.com/ldc-developers/ldc/blob/master/LICENSE
    license = with lib.licenses; [
      bsd3
      boost
      mit
      ncsa
      gpl2Plus
    ];

    maintainers = with lib.maintainers; [ lionello ];

    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
    ];
  };
}
