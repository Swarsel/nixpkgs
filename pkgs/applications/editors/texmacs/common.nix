{
  lib,
  fetchurl,
  chineseFonts,
  extraFonts,
  japaneseFonts,
  koreanFonts,
  tex,
}:
rec {
  postPatch =
    (
      if tex == null then
        ''
          gunzip < ${fullFontsSrc} | (cd TeXmacs && tar xvf -)
        ''
      else
        lib.optionalString extraFonts ''
          gunzip < ${extraFontsSrc} | (cd TeXmacs && tar xvf -)
        ''
    )
    + (lib.optionalString chineseFonts ''
      gunzip < ${chineseFontsSrc} | (cd TeXmacs && tar xvf -)
    '')
    + (lib.optionalString japaneseFonts ''
      gunzip < ${japaneseFontsSrc} | (cd TeXmacs && tar xvf -)
    '')
    + (lib.optionalString koreanFonts ''
      gunzip < ${koreanFontsSrc} | (cd TeXmacs && tar xvf -)
    '');

  chineseFontsSrc = fetchurl {
    sha256 = "sha256-1wnVlFpFjJAjGlVaEm7/TTGO+6isFlFyV9rV0rXE+Xo=";
    url = "https://www.texmacs.org/Download/ftp/fonts/TeXmacs-chinese-fonts.tar.gz";
  };

  extraFontsSrc = fetchurl {
    sha256 = "sha256-ZxobwAjIuZpxF7v3QsLa4UTA5+Sq0rWg8smX1Kp81EM=";
    url = "https://www.texmacs.org/Download/ftp/fonts/TeXmacs-extra-fonts-1.0-noarch.tar.gz";
  };

  fullFontsSrc = fetchurl {
    sha256 = "sha256-Tui4RR7Hd7MxQTvYFcEKBGro6L+uyuIp6HueevGVv/s=";
    url = "https://www.texmacs.org/Download/ftp/fonts/TeXmacs-windows-fonts-1.0-noarch.tar.gz";
  };

  japaneseFontsSrc = fetchurl {
    sha256 = "sha256-VgbBe+wwVrgCLzcj8qepeSx11bqcxR5MS2W+o/T+xrY=";
    url = "https://www.texmacs.org/Download/ftp/fonts/TeXmacs-japanese-fonts.tar.gz";
  };

  koreanFontsSrc = fetchurl {
    sha256 = "sha256-EBZ3BCOcTufzvfJzptLupkCRBwSdK0qqXXJUXE95XR0=";
    url = "https://www.texmacs.org/Download/ftp/fonts/TeXmacs-korean-fonts.tar.gz";
  };

  meta = {
    description = "WYSIWYW editing platform with special features for scientists";

    longDescription = ''
      GNU TeXmacs is a free wysiwyw (what you see is what you want)
      editing platform with special features for scientists.  The software
      aims to provide a unified and user friendly framework for editing
      structured documents with different types of content (text,
      graphics, mathematics, interactive content, etc.).  The rendering
      engine uses high-quality typesetting algorithms so as to produce
      professionally looking documents, which can either be printed out or
      presented from a laptop.

      The software includes a text editor with support for mathematical
      formulas, a small technical picture editor and a tool for making
      presentations from a laptop.  Moreover, TeXmacs can be used as an
      interface for many external systems for computer algebra, numerical
      analysis, statistics, etc.  New presentation styles can be written
      by the user and new features can be added to the editor using the
      Scheme extension language.  A native spreadsheet and tools for
      collaborative authoring are planned for later.
    '';

    homepage = "http://texmacs.org/";
    license = lib.licenses.gpl2Plus;
  };
}
