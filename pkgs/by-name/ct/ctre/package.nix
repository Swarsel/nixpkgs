{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ctre";
  version = "3.11.0";

  src = fetchFromGitHub {
    owner = "hanickadot";
    repo = "compile-time-regular-expressions";
    rev = "v${finalAttrs.version}";
    hash = "sha256-YtshxSdVT9V9V0KcYF+9NtgW0kYUCQ4I9EbcWNajuxI=";
  };

  postPatch = ''
    substituteInPlace packaging/pkgconfig.pc.in \
      --replace "\''${prefix}/" ""
  '';

  nativeBuildInputs = [ cmake ];
  dontBuild = true;

  meta = {
    description = "Fast compile-time regular expressions library";

    longDescription = ''
      Fast compile-time regular expressions with support for
      matching/searching/capturing during compile-time or runtime.
    '';

    homepage = "https://compile-time.re";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ azahi ];
    platforms = lib.platforms.all;
  };
})
