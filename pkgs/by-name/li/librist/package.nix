{
  lib,
  stdenv,
  fetchFromGitLab,
  cjson,
  cmocka,
  mbedtls,
  meson,
  ninja,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "librist";
  version = "0.2.11";

  src = fetchFromGitLab {
    owner = "rist";
    repo = "librist";
    rev = "v${finalAttrs.version}";
    hash = "sha256-xWqyQl3peB/ENReMcDHzIdKXXCYOJYbhhG8tcSh36dY=";
    domain = "code.videolan.org";
  };

  # avoid rebuild on Linux for now
  patches = lib.optionals stdenv.hostPlatform.isDarwin [
    # https://code.videolan.org/rist/librist/-/issues/192
    ./no-brew-darwin.diff
  ];

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
  ];

  buildInputs = [
    cjson
    cmocka
    mbedtls
  ];

  meta = {
    description = "Library that can be used to easily add the RIST protocol to your application";
    homepage = "https://code.videolan.org/rist/librist";

    license = with lib.licenses; [
      bsd2
      mit
      isc
    ];

    maintainers = with lib.maintainers; [ raphaelr ];
    platforms = lib.platforms.all;
  };
})
