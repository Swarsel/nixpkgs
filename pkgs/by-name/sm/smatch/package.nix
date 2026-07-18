{
  lib,
  stdenv,
  fetchFromGitHub,
  libllvm,
  libxml2,
  llvmPackages,
  openssl,
  pkg-config,
  replaceVars,
  sqlite,
  buildc2xml ? false,
  buildllvmsparse ? false,
}:
let
  version = "1.74";
in
stdenv.mkDerivation (finalAttrs: {
  inherit version;
  pname = "smatch";

  src = fetchFromGitHub {
    owner = "error27";
    repo = "smatch";
    tag = finalAttrs.version;
    hash = "sha256-LZdTwoTbNj/YE8o5xQ7MclkULJI3NTeeR38BsAtsI/4=";
  };

  patches = [
    (
      let
        clang-major = lib.versions.major (lib.getVersion llvmPackages.clang-unwrapped);
        clang-lib = lib.getLib llvmPackages.clang-unwrapped;
      in
      replaceVars ./fix_include_path.patch {
        clang = "${clang-lib}/lib/clang/${clang-major}/include";
        libc = "${lib.getDev stdenv.cc.libc}/include";
      }
    )
  ];

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    sqlite
    openssl
  ]
  ++ lib.optionals buildllvmsparse [ libllvm ]
  ++ lib.optionals buildc2xml [ libxml2.dev ];

  makeFlags = [
    "PREFIX=${placeholder "out"}"
    "CXX=${stdenv.cc.targetPrefix}c++"
  ];

  enableParallelBuilding = true;

  meta = {
    description = "Semantic analysis tool for C";
    homepage = "https://sparse.docs.kernel.org/";
    license = lib.licenses.gpl2Plus;
    maintainers = [ ];
    platforms = lib.platforms.all;
  };
})
