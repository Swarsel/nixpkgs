{
  lib,
  fetchFromGitHub,
  buildGoModule,
  dbip-country-lite,
  stdenvNoCC,
}:

let
  generator = buildGoModule rec {
    pname = "sing-geoip";
    version = "20240312";

    src = fetchFromGitHub {
      owner = "SagerNet";
      repo = "sing-geoip";
      tag = version;
      hash = "sha256-nIrbiECK25GyuPEFqMvPdZUShC2JC1NI60Y10SsoWyY=";
    };

    postPatch = ''
      sed -i -e '/func main()/,/^}/d' main.go
      cat ${./main.go} >> main.go
    '';

    vendorHash = "sha256-WH0eMg06qCiVcy4H+vBtYrmLMA2KJRCPGXiEnatW+LU=";

    meta = {
      description = "GeoIP data for sing-box";
      homepage = "https://github.com/SagerNet/sing-geoip";
      license = lib.licenses.gpl3Plus;
      maintainers = with lib.maintainers; [ linsui ];
      mainProgram = "sing-geoip";
    };
  };
in
stdenvNoCC.mkDerivation {
  inherit (generator) pname;
  inherit (dbip-country-lite) version;
  nativeBuildInputs = [ generator ];

  buildPhase = ''
    runHook preBuild

    sing-geoip ${dbip-country-lite.mmdb}

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -Dm644 rule-set/* -t $out/share/sing-box/rule-set

    runHook postInstall
  '';

  dontUnpack = true;
  passthru = { inherit generator; };

  meta = generator.meta // {
    inherit (dbip-country-lite.meta) license;
  };
}
