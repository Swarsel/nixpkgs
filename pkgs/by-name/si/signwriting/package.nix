{
  lib,
  fetchurl,
  runCommand,
}:

runCommand "signwriting"
  {
    pname = "signwriting";
    version = "1.1.4";
    outputHash = "0cn37s3lc7gbr8036l7ia2869qmxglkmgllh3r9q5j54g3sfjc7q";
    outputHashAlgo = "sha256";
    outputHashMode = "recursive";

    src1 = fetchurl {
      name = "SignWriting_2010.ttf";
      sha256 = "1abjzykbjx2hal8mrxp51rvblv3q84akyn9qhjfaj20rwphkf5zj";
      url = "https://github.com/Slevinski/signwriting_2010_fonts/raw/61c8e7123a1168657b5d34d85266a637f67b9d2b/fonts/SignWriting%202010.ttf";
    };

    src2 = fetchurl {
      name = "SignWriting_2010_Filling.ttf";
      sha256 = "0am5wbf7jdy9szxkbsc5f3959cxvbj7mr0hy1ziqmkz02c6xjw2m";
      url = "https://github.com/Slevinski/signwriting_2010_fonts/raw/61c8e7123a1168657b5d34d85266a637f67b9d2b/fonts/SignWriting%202010%20Filling.ttf";
    };

    meta = {
      description = "Typeface for written sign languages";
      homepage = "https://github.com/Slevinski/signwriting_2010_fonts";
      license = lib.licenses.ofl;
      maintainers = with lib.maintainers; [ mathnerd314 ];
      platforms = lib.platforms.all;
    };
  }
  ''
    mkdir -p $out/share/fonts/truetype
    cp $src1 $out/share/fonts/truetype/SignWriting_2010.ttf
    cp $src2 $out/share/fonts/truetype/SignWriting_2010_Filling.ttf
  ''
