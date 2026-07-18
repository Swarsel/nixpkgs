{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchpatch2,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "outils";
  version = "0.13";

  src = fetchFromGitHub {
    owner = "leahneukirchen";
    repo = "outils";
    rev = "v${finalAttrs.version}";
    hash = "sha256-FokJytwQsbGsryBzyglpb1Hg3wti/CPQTOfIGIz9ThA=";
  };

  patches = [
    (fetchpatch2 {
      hash = "sha256-jOnCMPcHKMRR3J0Yh+ZTHAn7P85FO80yXVX0K2vtlVk=";
      name = "outils-add-recallocarray-prototype.patch";
      url = "https://github.com/leahneukirchen/outils/commit/50877e1bf7c905044e0b50b227ecff48cfec394b.patch?full_index=1";
    })
  ];

  makeFlags = [ "PREFIX=$(out)" ];

  meta = {
    description = "Port of OpenBSD-exclusive tools such as `calendar`, `vis`, and `signify`";
    homepage = "https://github.com/leahneukirchen/outils";

    license = with lib.licenses; [
      beerware
      bsd2
      bsd3
      bsdOriginal
      isc
      mit
      publicDomain
    ];

    maintainers = with lib.maintainers; [ somasis ];
    platforms = lib.platforms.linux;
  };
})
