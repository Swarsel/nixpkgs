{
  lib,
  stdenv,
  fetchFromGitHub,
  copyPkgconfigItems,
  makePkgconfigItem,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "symfpu";
  version = "1.2.0-unstable-2026-05-13";

  src = fetchFromGitHub {
    owner = "martin-cs";
    repo = "symfpu";

    rev =
      {
        "0-unstable-2019-05-17" = "8fbe139bf0071cbe0758d2f6690a546c69ff0053";
        "1.2.0-unstable-2026-05-13" = "40bdec00e99f8ea1b96c3dac0a05eed11c541639";
      }
      ."${finalAttrs.version}";

    hash =
      {
        "0-unstable-2019-05-17" = "sha256-ONGfvJMo/HXlbxHmkFs9O5nhs6aDM+XuNSPgY+ykxck=";
        "1.2.0-unstable-2026-05-13" = "sha256-ho0tLWFlPozq5hD+qX6AQiCPxUuRPwnXe9dEfzXwSY0=";
      }
      ."${finalAttrs.version}";
  };

  nativeBuildInputs = [ copyPkgconfigItems ];

  env = {
    # copyPkgconfigItems will substitute this in the pkg-config file
    includedir = "${placeholder "out"}/include";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out/include/symfpu
    cp -r * $out/include/symfpu/

    runHook postInstall
  '';

  dontBuild = true;

  pkgconfigItems = [
    (makePkgconfigItem {
      inherit (finalAttrs) version;
      inherit (finalAttrs.meta) description;
      cflags = [ "-I\${includedir}" ];
      name = "symfpu";

      variables = {
        includedir = "@includedir@";
      };
    })
  ];

  meta = {
    description = "Implementation of SMT-LIB / IEEE-754 operations in terms of bit-vector operations";
    homepage = "https://github.com/martin-cs/symfpu";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ shadaj ];
    platforms = lib.platforms.unix;
  };
})
