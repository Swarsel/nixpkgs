{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "intel-cmt-cat";
  version = "26.06";

  src = fetchFromGitHub {
    owner = "intel";
    repo = "intel-cmt-cat";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-4rpmbQzxLD7FrtIzE+iE4G0sU7Dvz4rWs4MSlJqZcok=";
  };

  makeFlags = [
    "PREFIX=$(out)"
    "NOLDCONFIG=y"
  ];

  enableParallelBuilding = true;

  meta = {
    description = "User space software for Intel(R) Resource Director Technology";
    homepage = "https://github.com/intel/intel-cmt-cat";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ arkivm ];
    platforms = [ "x86_64-linux" ];
  };
})
