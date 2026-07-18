{
  mkDerivation,
  mkcsmapper,
  mkesdb,
}:

mkDerivation {
  preBuild = ''
    export makeFlags="$makeFlags ESDBDIR=$out/share/i18n/esdb CSMAPPERDIR=$out/share/i18n/csmapper"
  '';

  extraNativeBuildInputs = [
    mkcsmapper
    mkesdb
  ];

  noLibc = true;
  path = "share/i18n";
}
