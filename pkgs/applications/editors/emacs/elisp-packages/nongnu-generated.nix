{ callPackage }:
{
  adoc-mode = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "adoc-mode";
      version = "0.9.0";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/adoc-mode-0.9.0.tar";
        sha256 = "11anl5b9ka9aww2w2jv0clrvq98f2vsa9ri3n1xxdll5z77rvw56";
      };

      ename = "adoc-mode";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/adoc-mode.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  afternoon-theme = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "afternoon-theme";
      version = "0.1";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/afternoon-theme-0.1.tar";
        sha256 = "0xxvr3njpbdlm8iyyklwijjaysyknwpw51hq2443wq37bsxciils";
      };

      ename = "afternoon-theme";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/afternoon-theme.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  age = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "age";
      version = "0.1.9";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/age-0.1.9.tar";
        sha256 = "0y8vlr8w4xfapixdr35acmcsll06kci04rsz5pzi20amkhrj9i50";
      };

      ename = "age";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/age.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  aidermacs = callPackage (
    {
      lib,
      fetchurl,
      compat,
      elpaBuild,
      markdown-mode,
      transient,
    }:
    elpaBuild {
      pname = "aidermacs";
      version = "1.7";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/aidermacs-1.7.tar";
        sha256 = "17l7dlg218j63zwzi51wdczamvxlv54l0ivkip3h3kll386lkcm6";
      };

      ename = "aidermacs";

      packageRequires = [
        compat
        markdown-mode
        transient
      ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/aidermacs.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  alect-themes = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "alect-themes";
      version = "0.11";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/alect-themes-0.11.tar";
        sha256 = "1ij0c321gi3vqcw0pzzsi02b3370l2ynijq0999j1jxrillc9h2l";
      };

      ename = "alect-themes";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/alect-themes.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  ample-theme = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "ample-theme";
      version = "0.3.0";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/ample-theme-0.3.0.tar";
        sha256 = "12z8z6da1xfc642w2wc82sjlfj3ymlz3jwrg3ydc2fapis2d3ibi";
      };

      ename = "ample-theme";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/ample-theme.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  annotate = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "annotate";
      version = "2.5.0";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/annotate-2.5.0.tar";
        sha256 = "0nydnnjx1p4fkiix70zg0apxxd0sprlzxk111lvgnamp3c4hxf93";
      };

      ename = "annotate";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/annotate.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  anti-zenburn-theme = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "anti-zenburn-theme";
      version = "2.5.1";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/anti-zenburn-theme-2.5.1.tar";
        sha256 = "121038d6mjdfis1c5v9277bd6kz656n0c25daxq85mfswvjlar0i";
      };

      ename = "anti-zenburn-theme";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/anti-zenburn-theme.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  anzu = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "anzu";
      version = "0.66";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/anzu-0.66.tar";
        sha256 = "17pyi02mydv59g5qwdzmf1rymkvvg52kx4b8n45pkwkhrwdmj2g3";
      };

      ename = "anzu";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/anzu.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  apache-mode = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "apache-mode";
      version = "2.2.0";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/apache-mode-2.2.0.tar";
        sha256 = "10fgbgww7j60dik7b7mvnm1zwgv9y8p5wzggkrdk50dv3gjfxg8f";
      };

      ename = "apache-mode";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/apache-mode.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  apropospriate-theme = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "apropospriate-theme";
      version = "0.2.0";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/apropospriate-theme-0.2.0.tar";
        sha256 = "1hsv26iqr0g6c3gy1df2qkd3ilwq6xaa89ch7pqh64737qrlw9db";
      };

      ename = "apropospriate-theme";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/apropospriate-theme.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  arduino-mode = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      spinner,
    }:
    elpaBuild {
      pname = "arduino-mode";
      version = "1.3.1";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/arduino-mode-1.3.1.tar";
        sha256 = "1k42qx7kgm8svv70czzlkmm3c7cddf93bqvf6267hbkaihhyd21y";
      };

      ename = "arduino-mode";
      packageRequires = [ spinner ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/arduino-mode.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  auto-dim-other-buffers = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "auto-dim-other-buffers";
      version = "2.2.1";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/auto-dim-other-buffers-2.2.1.tar";
        sha256 = "00x0niv1zd47b2xl19k3fi0xxskdndiabns107cxzwb7pnkp4f0m";
      };

      ename = "auto-dim-other-buffers";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/auto-dim-other-buffers.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  autothemer = callPackage (
    {
      lib,
      fetchurl,
      dash,
      elpaBuild,
    }:
    elpaBuild {
      pname = "autothemer";
      version = "0.2.18";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/autothemer-0.2.18.tar";
        sha256 = "1v6si9fh3rbka72r5jfd35bbvfbfaxr2kfi7jmsgj07fhx4bgl2d";
      };

      ename = "autothemer";
      packageRequires = [ dash ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/autothemer.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  base32 = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "base32";
      version = "1.0";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/base32-1.0.tar";
        sha256 = "1k1n0zlks9dammpmr0875xh5vw5prmc7rr5kwd262xidscj19k6w";
      };

      ename = "base32";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/base32.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  bash-completion = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "bash-completion";
      version = "3.2";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/bash-completion-3.2.tar";
        sha256 = "19xpv87nb1gskfsfqj8hmhbzlhxk0m6dflizsnrq94bh7rbw3s12";
      };

      ename = "bash-completion";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/bash-completion.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  beancount = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "beancount";
      version = "0.9.0";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/beancount-0.9.0.tar";
        sha256 = "0pr86vw8qkdbwvzvqs9pyhq6vabg6jik79cs0j3xrsjjpaz324zi";
      };

      ename = "beancount";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/beancount.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  better-jumper = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "better-jumper";
      version = "1.0.1";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/better-jumper-1.0.1.tar";
        sha256 = "1jdmbp1jjip8vmmc66z2wgx95lzp1b92m66p160mdm4g3skl64c2";
      };

      ename = "better-jumper";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/better-jumper.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  bind-map = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "bind-map";
      version = "1.1.2";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/bind-map-1.1.2.tar";
        sha256 = "037xk912hx00ia62h6kdfa56g44dhd0628va22znxg251izvnqxq";
      };

      ename = "bind-map";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/bind-map.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  bison-mode = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "bison-mode";
      version = "0.4";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/bison-mode-0.4.tar";
        sha256 = "0k0h96bpcndi3m9fdk74j0ynm50n6by508mv3ds9ala26dpdr7qa";
      };

      ename = "bison-mode";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/bison-mode.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  blow = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "blow";
      version = "1.0";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/blow-1.0.tar";
        sha256 = "009x0y86692ccj2v0cizr40ly6xdp72bnwj5pjayg3y0ph4iz0cj";
      };

      ename = "blow";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/blow.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  blueprint-ts-mode = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "blueprint-ts-mode";
      version = "0.0.3";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/blueprint-ts-mode-0.0.3.tar";
        sha256 = "0v1sk80dka2gdkwcbria12ih3jrna3866ngdswcskyqcnkxm7b7n";
      };

      ename = "blueprint-ts-mode";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/blueprint-ts-mode.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  boxquote = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "boxquote";
      version = "2.4.1";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/boxquote-2.4.1.tar";
        sha256 = "18gwx8dh2xbr90m1mvmp5jb8ssyn5cmq833sd4nsa76i021yh1l6";
      };

      ename = "boxquote";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/boxquote.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  buttercup = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "buttercup";
      version = "1.40";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/buttercup-1.40.tar";
        sha256 = "09r1yp05m7p6906isz1x6dhc7mrxsdisxa19a8py73gqsm1ymf1c";
      };

      ename = "buttercup";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/buttercup.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  camera = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "camera";
      version = "0.3";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/camera-0.3.tar";
        sha256 = "0r9b20li82qcc141p4blyaj0xng5f4xrghhl09wc15ffi0cmbq7d";
      };

      ename = "camera";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/camera.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  caml = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "caml";
      version = "4.9";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/caml-4.9.tar";
        sha256 = "1xzk83bds4d23rk170n975mijlmin5dh7crfc5swwvzh8w88qxmk";
      };

      ename = "caml";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/caml.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  casual = callPackage (
    {
      lib,
      fetchurl,
      csv-mode,
      elpaBuild,
      transient,
    }:
    elpaBuild {
      pname = "casual";
      version = "2.16.2";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/casual-2.16.2.tar";
        sha256 = "0aqkxxds4paicn1r4hy13f71cl4qllf9dfijpl4mp5zizyx8a8a2";
      };

      ename = "casual";

      packageRequires = [
        csv-mode
        transient
      ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/casual.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  cdlatex = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "cdlatex";
      version = "4.18.5";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/cdlatex-4.18.5.tar";
        sha256 = "0d7ivpxkn7a4cam0cmgar9s0r943ni046dfn6z9k50zhzhaxcw6y";
      };

      ename = "cdlatex";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/cdlatex.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  cider = callPackage (
    {
      lib,
      fetchurl,
      clojure-mode,
      compat,
      elpaBuild,
      parseedn,
      queue,
      seq,
      sesman,
      spinner,
      transient,
    }:
    elpaBuild {
      pname = "cider";
      version = "1.22.2";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/cider-1.22.2.tar";
        sha256 = "0a7mcg1lazn1xyl3sxy0qpwd4qipf0ix56891ydjcv7i9yhggnpc";
      };

      ename = "cider";

      packageRequires = [
        clojure-mode
        compat
        parseedn
        queue
        seq
        sesman
        spinner
        transient
      ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/cider.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  clojure-mode = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "clojure-mode";
      version = "5.23.0";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/clojure-mode-5.23.0.tar";
        sha256 = "1l4nxsp1lsbq1c0zg1bisc3fjmjjrjs1ahw17fajl0kblp96b0xg";
      };

      ename = "clojure-mode";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/clojure-mode.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  clojure-ts-mode = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "clojure-ts-mode";
      version = "0.6.0";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/clojure-ts-mode-0.6.0.tar";
        sha256 = "0jvza581i0npj22jpzd1x08dsssdsw53xmfnq61widi6bs24bi92";
      };

      ename = "clojure-ts-mode";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/clojure-ts-mode.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  coffee-mode = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      cl-lib ? null,
    }:
    elpaBuild {
      pname = "coffee-mode";
      version = "0.6.3";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/coffee-mode-0.6.3.tar";
        sha256 = "1anywqp2b99dmilfnajxgf4msc0viw6ndl0lxpgaa7d2b3mzx9nq";
      };

      ename = "coffee-mode";
      packageRequires = [ cl-lib ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/coffee-mode.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  color-theme-tangotango = callPackage (
    {
      lib,
      fetchurl,
      color-theme,
      elpaBuild,
    }:
    elpaBuild {
      pname = "color-theme-tangotango";
      version = "0.0.6";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/color-theme-tangotango-0.0.6.tar";
        sha256 = "0lfr3xg9xvfjb12kcw80d35a1ayn4f5w1dkd2b0kx0wxkq0bykim";
      };

      ename = "color-theme-tangotango";
      packageRequires = [ color-theme ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/color-theme-tangotango.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  cond-let = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "cond-let";
      version = "1.1.2";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/cond-let-1.1.2.tar";
        sha256 = "04p2jf8nm1q00439r26vvg9549hld4spcabghwsgmf89gqjiv8mm";
      };

      ename = "cond-let";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/cond-let.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  consult-flycheck = callPackage (
    {
      lib,
      fetchurl,
      consult,
      elpaBuild,
      flycheck,
    }:
    elpaBuild {
      pname = "consult-flycheck";
      version = "1.2";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/consult-flycheck-1.2.tar";
        sha256 = "0g5lb3p4g91ax0c4zkkyvi2l4hkq5b9r2bciddgg1h4bsmrs6vhx";
      };

      ename = "consult-flycheck";

      packageRequires = [
        consult
        flycheck
      ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/consult-flycheck.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  corfu-terminal = callPackage (
    {
      lib,
      fetchurl,
      corfu,
      elpaBuild,
      popon,
    }:
    elpaBuild {
      pname = "corfu-terminal";
      version = "0.7";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/corfu-terminal-0.7.tar";
        sha256 = "0a41hfma4iiinq2cgvwqqwxhrwjn5c7igl5sgvgx0mbjki2n6sll";
      };

      ename = "corfu-terminal";

      packageRequires = [
        corfu
        popon
      ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/corfu-terminal.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  crux = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "crux";
      version = "0.5.0";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/crux-0.5.0.tar";
        sha256 = "0cykjwwhl6r02fsyam4vnmlxiyq8b8qsgncb1hjnz4gj7mxc9gg4";
      };

      ename = "crux";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/crux.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  csv2ledger = callPackage (
    {
      lib,
      fetchurl,
      csv-mode,
      elpaBuild,
    }:
    elpaBuild {
      pname = "csv2ledger";
      version = "1.5.5";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/csv2ledger-1.5.5.tar";
        sha256 = "09k7q33jxwrcf52csgf25kd9wqcs9bicl8azmkbrmm8d9jqgg3md";
      };

      ename = "csv2ledger";
      packageRequires = [ csv-mode ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/csv2ledger.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  cyberpunk-theme = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "cyberpunk-theme";
      version = "1.22";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/cyberpunk-theme-1.22.tar";
        sha256 = "1kgkgpb07d4kh2rf88pfgyji42qv80443i67nzha2fx01zbd5swb";
      };

      ename = "cyberpunk-theme";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/cyberpunk-theme.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  cycle-at-point = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      recomplete,
    }:
    elpaBuild {
      pname = "cycle-at-point";
      version = "0.2";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/cycle-at-point-0.2.tar";
        sha256 = "1q3gylksr754s0pl8x1hdk0q4p0vz6lnasswgsqpx44nmnbsrw6z";
      };

      ename = "cycle-at-point";
      packageRequires = [ recomplete ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/cycle-at-point.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  d-mode = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "d-mode";
      version = "202408131340";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/d-mode-202408131340.tar";
        sha256 = "19dgc0yd2fmc9xbrajc1l98p7p2wiwg43ajq4gssxdshb5vi5mn9";
      };

      ename = "d-mode";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/d-mode.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  dart-mode = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "dart-mode";
      version = "1.0.7";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/dart-mode-1.0.7.tar";
        sha256 = "1k9pn7nqskz39m3zwi9jhd1a2q440jgrla1a37qip73mwrdril1i";
      };

      ename = "dart-mode";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/dart-mode.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  datetime = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      extmap,
    }:
    elpaBuild {
      pname = "datetime";
      version = "0.10.2";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/datetime-0.10.2.tar";
        sha256 = "1mpsk5zrl7kja0pk6fw1qw2drq3laphmnnj8ppr0ahinyrqy05kw";
      };

      ename = "datetime";
      packageRequires = [ extmap ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/datetime.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  denote-refs = callPackage (
    {
      lib,
      fetchurl,
      denote,
      elpaBuild,
    }:
    elpaBuild {
      pname = "denote-refs";
      version = "0.1.2";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/denote-refs-0.1.2.tar";
        sha256 = "0jq14adxpx9bxddkj3a4bahyr3yarjn85iplhhy9yk7k9wy7wis0";
      };

      ename = "denote-refs";
      packageRequires = [ denote ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/denote-refs.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  devhelp = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "devhelp";
      version = "1.0";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/devhelp-1.0.tar";
        sha256 = "14x1990yr3qqzv9dqn7xg69hqgpmgjsi68f2fg07v670lk7hs8xb";
      };

      ename = "devhelp";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/devhelp.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  devil = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "devil";
      version = "0.6.0";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/devil-0.6.0.tar";
        sha256 = "01n552pvr598igmd2q6w9kgjrwgzrgrb4w59mxpsylcv6wy2v2h5";
      };

      ename = "devil";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/devil.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  diff-ansi = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "diff-ansi";
      version = "0.2";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/diff-ansi-0.2.tar";
        sha256 = "0i1216mw0zgy3jdhhxsn5wpjqgxv5als1lljb1ddqjl21y6z74nw";
      };

      ename = "diff-ansi";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/diff-ansi.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  dirvish = callPackage (
    {
      lib,
      fetchurl,
      compat,
      elpaBuild,
    }:
    elpaBuild {
      pname = "dirvish";
      version = "2.3.0";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/dirvish-2.3.0.tar";
        sha256 = "0am64p4h08isz8al70zz3dchx43szgnl5qa6i81s3mf3bmw8vpn6";
      };

      ename = "dirvish";
      packageRequires = [ compat ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/dirvish.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  doc-show-inline = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "doc-show-inline";
      version = "0.1";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/doc-show-inline-0.1.tar";
        sha256 = "13y7k4zp8x8fcyidw0jy6zf92af660zwb7qpps91l2dh7zwjsl2v";
      };

      ename = "doc-show-inline";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/doc-show-inline.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  dockerfile-mode = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "dockerfile-mode";
      version = "1.9";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/dockerfile-mode-1.9.tar";
        sha256 = "11cdwb3l0fkzx8xgcf9xi6mi7q86jf9vfhagpc076qxwwjz0vgp7";
      };

      ename = "dockerfile-mode";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/dockerfile-mode.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  dracula-theme = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "dracula-theme";
      version = "1.8.3";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/dracula-theme-1.8.3.tar";
        sha256 = "03md51d5ibfynnw9kavxi5wk353spivvpbg7bndiy9mdl1cqc1cg";
      };

      ename = "dracula-theme";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/dracula-theme.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  drupal-mode = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      php-mode,
    }:
    elpaBuild {
      pname = "drupal-mode";
      version = "0.8.1";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/drupal-mode-0.8.1.tar";
        sha256 = "0f3dd2647g964grzq95d73iznhpmrr9w7fmkifjk3ivz0rgdgjsq";
      };

      ename = "drupal-mode";
      packageRequires = [ php-mode ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/drupal-mode.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  dslide = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "dslide";
      version = "0.6.2";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/dslide-0.6.2.tar";
        sha256 = "02lny7c7v6345nlprmpi39pyk7m9lpr85g8xkd70ivkpc122qdy2";
      };

      ename = "dslide";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/dslide.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  eat = callPackage (
    {
      lib,
      fetchurl,
      compat,
      elpaBuild,
    }:
    elpaBuild {
      pname = "eat";
      version = "0.9.4";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/eat-0.9.4.tar";
        sha256 = "0jn5rzyg1abjsb18brr1ha4vmhvxpkp8pxvaxfa0g0phcb2iz5ql";
      };

      ename = "eat";
      packageRequires = [ compat ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/eat.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  edit-indirect = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "edit-indirect";
      version = "0.1.13";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/edit-indirect-0.1.13.tar";
        sha256 = "10zshywbp0f00k2d4f5bc44ynvw3f0626vl35lbah1kwmgzrrjdd";
      };

      ename = "edit-indirect";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/edit-indirect.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  editorconfig = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      nadvice,
    }:
    elpaBuild {
      pname = "editorconfig";
      version = "0.11.0";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/editorconfig-0.11.0.tar";
        sha256 = "0adzm6fhx5vgg20qy9f7cqpnx938mp1ls91y5cw71pjm9ihs2cyv";
      };

      ename = "editorconfig";
      packageRequires = [ nadvice ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/editorconfig.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  eglot-inactive-regions = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "eglot-inactive-regions";
      version = "0.6.5";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/eglot-inactive-regions-0.6.5.tar";
        sha256 = "133wbmmzxfhzkjlm3sjllg3wl5r2dyprs2rmwi8r7nq3p831ak0n";
      };

      ename = "eglot-inactive-regions";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/eglot-inactive-regions.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  eldoc-diffstat = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "eldoc-diffstat";
      version = "1.0";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/eldoc-diffstat-1.0.tar";
        sha256 = "0cxmhi1whzh4z62vv1pyvl2v6wr0jbq560m6zib8zicvdfxqlpgk";
      };

      ename = "eldoc-diffstat";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/eldoc-diffstat.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  eldoc-mouse = callPackage (
    {
      lib,
      fetchurl,
      eglot,
      elpaBuild,
      posframe,
    }:
    elpaBuild {
      pname = "eldoc-mouse";
      version = "3.0.8";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/eldoc-mouse-3.0.8.tar";
        sha256 = "1snacbxjqp8ykic5z1nzhg0fnd5fnafsgwxmfd9vy4rsm0ag9mrl";
      };

      ename = "eldoc-mouse";

      packageRequires = [
        eglot
        posframe
      ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/eldoc-mouse.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  eldoc-mouse-nov = callPackage (
    {
      lib,
      fetchurl,
      eldoc-mouse,
      elpaBuild,
      nov,
    }:
    elpaBuild {
      pname = "eldoc-mouse-nov";
      version = "0.1.1";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/eldoc-mouse-nov-0.1.1.tar";
        sha256 = "1jg1s0v255jm6gzvvl2r0dqrjb95z2lgc0yy1pc1avf4ynsrk5d9";
      };

      ename = "eldoc-mouse-nov";

      packageRequires = [
        eldoc-mouse
        nov
      ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/eldoc-mouse-nov.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  elfeed = callPackage (
    {
      lib,
      fetchurl,
      compat,
      elpaBuild,
    }:
    elpaBuild {
      pname = "elfeed";
      version = "4.0.1";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/elfeed-4.0.1.tar";
        sha256 = "1az6lj58j1kkxzpa7ik8irl3z2b9f7yxsm92pfqlcwplsnm2q8q2";
      };

      ename = "elfeed";
      packageRequires = [ compat ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/elfeed.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  elfeed-web = callPackage (
    {
      lib,
      fetchurl,
      compat,
      elfeed,
      elpaBuild,
      simple-httpd,
    }:
    elpaBuild {
      pname = "elfeed-web";
      version = "4.0.0";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/elfeed-web-4.0.0.tar";
        sha256 = "0ah6zjcihxfra34zglqrj6pnxqnakgc58dlkgjzgrxdamx4dxfwg";
      };

      ename = "elfeed-web";

      packageRequires = [
        compat
        elfeed
        simple-httpd
      ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/elfeed-web.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  elixir-mode = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "elixir-mode";
      version = "2.5.0";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/elixir-mode-2.5.0.tar";
        sha256 = "1x6aral441mv9443h21lnaymbpazwii22wcqvk2jfqjmyl1xj1yz";
      };

      ename = "elixir-mode";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/elixir-mode.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  elpher = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "elpher";
      version = "3.7.0";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/elpher-3.7.0.tar";
        sha256 = "1z12nb9a9gbksfnirnqv5fi6b7ygkjgyvrd7glp3ymbp765pjb2p";
      };

      ename = "elpher";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/elpher.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  emacsql = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "emacsql";
      version = "4.4.1";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/emacsql-4.4.1.tar";
        sha256 = "1gja15jyalzrlcs85ng98p6g7b0id4rayj4shwf7x1ic30sv12p3";
      };

      ename = "emacsql";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/emacsql.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  engine-mode = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      cl-lib ? null,
    }:
    elpaBuild {
      pname = "engine-mode";
      version = "2.2.4";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/engine-mode-2.2.4.tar";
        sha256 = "0gp1mnf0yaq4w91pj989dzlxpbpcqqj0yls23wf2ly53kbaarzv9";
      };

      ename = "engine-mode";
      packageRequires = [ cl-lib ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/engine-mode.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  eprolog = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "eprolog";
      version = "0.3.2";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/eprolog-0.3.2.tar";
        sha256 = "1vbnbdpmxvqgay5m01bcm1wlsyz16nn4fydv7ipd8kzr4lw59qyg";
      };

      ename = "eprolog";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/eprolog.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  esxml = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      cl-lib ? null,
    }:
    elpaBuild {
      pname = "esxml";
      version = "0.3.8";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/esxml-0.3.8.tar";
        sha256 = "1r3hjjidqafr1drc0v0v7blglhf5mp544s6i4hc6xwkhg0amhd92";
      };

      ename = "esxml";
      packageRequires = [ cl-lib ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/esxml.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  evil = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "evil";
      version = "1.15.0";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/evil-1.15.0.tar";
        sha256 = "0ciglddlq0z91jyggp86d9g3gwfzjp55xhldqpxpq39a2xkwqh0q";
      };

      ename = "evil";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/evil.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  evil-anzu = callPackage (
    {
      lib,
      fetchurl,
      anzu,
      elpaBuild,
      evil,
    }:
    elpaBuild {
      pname = "evil-anzu";
      version = "0.2";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/evil-anzu-0.2.tar";
        sha256 = "1vn61aj0bnvkj2l3cd8m8q3n7kn09hdp6d13wc58w9pw8nrg0vq5";
      };

      ename = "evil-anzu";

      packageRequires = [
        anzu
        evil
      ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/evil-anzu.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  evil-args = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      evil,
    }:
    elpaBuild {
      pname = "evil-args";
      version = "1.1";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/evil-args-1.1.tar";
        sha256 = "0fv30wny2f4mg8l9jrjgxisz6nbmn84980yszbrcbkqi81dzzlyi";
      };

      ename = "evil-args";
      packageRequires = [ evil ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/evil-args.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  evil-emacs-cursor-model-mode = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      evil,
    }:
    elpaBuild {
      pname = "evil-emacs-cursor-model-mode";
      version = "0.1.3";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/evil-emacs-cursor-model-mode-0.1.3.tar";
        sha256 = "03mn90kpn5lj1yxg5pl69wa01ms2xi9bj1w5dix5ac153iqlddjm";
      };

      ename = "evil-emacs-cursor-model-mode";
      packageRequires = [ evil ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/evil-emacs-cursor-model-mode.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  evil-escape = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      evil,
      cl-lib ? null,
    }:
    elpaBuild {
      pname = "evil-escape";
      version = "3.16";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/evil-escape-3.16.tar";
        sha256 = "0vv6k3zaaw4ckk6qjiw1n41815w1g4qgy2hfgsj1vm7xc9i9zjzp";
      };

      ename = "evil-escape";

      packageRequires = [
        cl-lib
        evil
      ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/evil-escape.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  evil-exchange = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      evil,
      cl-lib ? null,
    }:
    elpaBuild {
      pname = "evil-exchange";
      version = "0.41";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/evil-exchange-0.41.tar";
        sha256 = "1yk7zdxl7c8c2ic37l0rsaynnpcrhdbblk2frl5m8phf54g82d8i";
      };

      ename = "evil-exchange";

      packageRequires = [
        cl-lib
        evil
      ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/evil-exchange.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  evil-goggles = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      evil,
    }:
    elpaBuild {
      pname = "evil-goggles";
      version = "0.0.2";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/evil-goggles-0.0.2.tar";
        sha256 = "0nipk8r7l5c50n9zry5264cfilx730l68ssldw3hyj14ybdf6dch";
      };

      ename = "evil-goggles";
      packageRequires = [ evil ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/evil-goggles.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  evil-iedit-state = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      evil,
      iedit,
    }:
    elpaBuild {
      pname = "evil-iedit-state";
      version = "1.3";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/evil-iedit-state-1.3.tar";
        sha256 = "1955bci018rpbdvixlw0gxay10g0vgg2xwsfmfyxcblk5glrv5cp";
      };

      ename = "evil-iedit-state";

      packageRequires = [
        evil
        iedit
      ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/evil-iedit-state.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  evil-indent-plus = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      evil,
      cl-lib ? null,
    }:
    elpaBuild {
      pname = "evil-indent-plus";
      version = "1.0.1";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/evil-indent-plus-1.0.1.tar";
        sha256 = "1kzlvi8xgfxy26w1m31nyh6vrq787vchkmk4r1xaphk9wn9bw1pq";
      };

      ename = "evil-indent-plus";

      packageRequires = [
        cl-lib
        evil
      ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/evil-indent-plus.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  evil-lisp-state = callPackage (
    {
      lib,
      fetchurl,
      bind-map,
      elpaBuild,
      evil,
      smartparens,
    }:
    elpaBuild {
      pname = "evil-lisp-state";
      version = "8.2";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/evil-lisp-state-8.2.tar";
        sha256 = "14v1nv797b4rxxxnvzwy6pp10g3mmvifb919iv7nx96sbn919w0p";
      };

      ename = "evil-lisp-state";

      packageRequires = [
        bind-map
        evil
        smartparens
      ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/evil-lisp-state.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  evil-matchit = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "evil-matchit";
      version = "4.1.0";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/evil-matchit-4.1.0.tar";
        sha256 = "10wdnk5mwfzyn78qaaf0via30bs3nf2r6hq41ml6dq6xvmkfbp4a";
      };

      ename = "evil-matchit";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/evil-matchit.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  evil-nerd-commenter = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "evil-nerd-commenter";
      version = "3.6.1";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/evil-nerd-commenter-3.6.1.tar";
        sha256 = "1nzqwqp2gq3wka2x782yqz5d8bw3wglra42907kylkqwqbxryh0w";
      };

      ename = "evil-nerd-commenter";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/evil-nerd-commenter.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  evil-numbers = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      evil,
      shift-number,
    }:
    elpaBuild {
      pname = "evil-numbers";
      version = "0.8";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/evil-numbers-0.8.tar";
        sha256 = "0l1ik0fz1bzpxnz9rnn0817j8ghpwhf3qv3lidzb3vpbynkas5a1";
      };

      ename = "evil-numbers";

      packageRequires = [
        evil
        shift-number
      ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/evil-numbers.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  evil-surround = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      evil,
    }:
    elpaBuild {
      pname = "evil-surround";
      version = "1.0.4";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/evil-surround-1.0.4.tar";
        sha256 = "1fzhqg2zrfl1yvhf96s5m0b9793cysciqbxiihxzrnnf2rnrlls2";
      };

      ename = "evil-surround";
      packageRequires = [ evil ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/evil-surround.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  evil-visual-mark-mode = callPackage (
    {
      lib,
      fetchurl,
      dash,
      elpaBuild,
      evil,
    }:
    elpaBuild {
      pname = "evil-visual-mark-mode";
      version = "0.0.5";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/evil-visual-mark-mode-0.0.5.tar";
        sha256 = "0hjg9jmyhhc6a6zzjicwy62m9bh7wlw6hc4cf2g6g416c0ri2d18";
      };

      ename = "evil-visual-mark-mode";

      packageRequires = [
        dash
        evil
      ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/evil-visual-mark-mode.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  evil-visualstar = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      evil,
    }:
    elpaBuild {
      pname = "evil-visualstar";
      version = "0.2.0";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/evil-visualstar-0.2.0.tar";
        sha256 = "03liavxxpawvlgwdsihzz3z08yv227zjjqyll1cbmbk0678kbl7m";
      };

      ename = "evil-visualstar";
      packageRequires = [ evil ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/evil-visualstar.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  exec-path-from-shell = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "exec-path-from-shell";
      version = "2.2";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/exec-path-from-shell-2.2.tar";
        sha256 = "14nzk04aypqminpqs181nh3di23nnw64z0ir940ajs9bx5pv9s1w";
      };

      ename = "exec-path-from-shell";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/exec-path-from-shell.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  extmap = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "extmap";
      version = "1.3";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/extmap-1.3.tar";
        sha256 = "0k4xh101wi3jby74a44mlqsqinsfsjdrv2k19aanp6xvl60smb04";
      };

      ename = "extmap";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/extmap.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  fedi = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      markdown-mode,
    }:
    elpaBuild {
      pname = "fedi";
      version = "0.4";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/fedi-0.4.tar";
        sha256 = "0zh2rkkj1wyj7csg72gg54mxlrd5kav54z3qhk6lp6j8h3zxkdvd";
      };

      ename = "fedi";
      packageRequires = [ markdown-mode ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/fedi.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  fj = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      fedi,
      magit,
      tp,
      transient,
    }:
    elpaBuild {
      pname = "fj";
      version = "0.37";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/fj-0.37.tar";
        sha256 = "1kya5xif5ffiqv9fk4mxwx6x6gqshkpji21z0q84q438hfbxpwl9";
      };

      ename = "fj";

      packageRequires = [
        fedi
        magit
        tp
        transient
      ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/fj.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  flamegraph = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "flamegraph";
      version = "0.2";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/flamegraph-0.2.tar";
        sha256 = "0zlji7iq7zrxix4mzw6z25rqgrmlnxnrc7skflkj0nv90z5w3fsh";
      };

      ename = "flamegraph";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/flamegraph.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  flx = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      cl-lib ? null,
    }:
    elpaBuild {
      pname = "flx";
      version = "0.6.2";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/flx-0.6.2.tar";
        sha256 = "00d3q238grxcvnx6pshb7ajbz559gfp00pqaq56r2n5xqrvrxfnc";
      };

      ename = "flx";
      packageRequires = [ cl-lib ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/flx.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  flx-ido = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      flx,
      cl-lib ? null,
    }:
    elpaBuild {
      pname = "flx-ido";
      version = "0.6.2";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/flx-ido-0.6.2.tar";
        sha256 = "1933d3dcwynzs5qnv3pl4xdybj5gg0sa8zb58j0ld9hyiacm6zn5";
      };

      ename = "flx-ido";

      packageRequires = [
        cl-lib
        flx
      ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/flx-ido.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  flycheck = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      seq,
    }:
    elpaBuild {
      pname = "flycheck";
      version = "36.0";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/flycheck-36.0.tar";
        sha256 = "0172y6qzkys77cbvdla1iiiznpxpscjzmsdr66m66s8g4bf7f1p2";
      };

      ename = "flycheck";
      packageRequires = [ seq ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/flycheck.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  flymake-guile = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      flymake ? null,
    }:
    elpaBuild {
      pname = "flymake-guile";
      version = "0.5";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/flymake-guile-0.5.tar";
        sha256 = "0gfblb49l52j7iq3y6fxx1jpr72z61pwxsxfknvfi4y05znxnf0k";
      };

      ename = "flymake-guile";
      packageRequires = [ flymake ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/flymake-guile.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  flymake-kondor = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "flymake-kondor";
      version = "0.1.3";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/flymake-kondor-0.1.3.tar";
        sha256 = "0y5qnlk3q0fjch12d4vwni7v6rk0h5056s5lzjgns71x36xd1i21";
      };

      ename = "flymake-kondor";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/flymake-kondor.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  flymake-popon = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      popon,
      posframe,
      flymake ? null,
    }:
    elpaBuild {
      pname = "flymake-popon";
      version = "0.5.1";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/flymake-popon-0.5.1.tar";
        sha256 = "0a9p0mnp1n4znb9xgi5ldjv8x1khhdr5idb8vcd444nd03q0lj6s";
      };

      ename = "flymake-popon";

      packageRequires = [
        flymake
        popon
        posframe
      ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/flymake-popon.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  flymake-pyrefly = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "flymake-pyrefly";
      version = "0.1.8";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/flymake-pyrefly-0.1.8.tar";
        sha256 = "19h8lmwk4p3lq985d0sqv1b9s6g04dazl31bc0n0y90ksl6ab5f5";
      };

      ename = "flymake-pyrefly";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/flymake-pyrefly.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  focus = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      cl-lib ? null,
    }:
    elpaBuild {
      pname = "focus";
      version = "1.0.1";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/focus-1.0.1.tar";
        sha256 = "164xlxc5x2i955rfjdhlxp5ch55bh79gr7mzfychkjx0x088hcaa";
      };

      ename = "focus";
      packageRequires = [ cl-lib ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/focus.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  forth-mode = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      cl-lib ? null,
    }:
    elpaBuild {
      pname = "forth-mode";
      version = "0.3";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/forth-mode-0.3.tar";
        sha256 = "1xhx5dcna0r6b9l9svqlvhqrhnd4678ifzbn5mzf34y09kq7djl2";
      };

      ename = "forth-mode";
      packageRequires = [ cl-lib ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/forth-mode.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  free-keys = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      cl-lib ? null,
    }:
    elpaBuild {
      pname = "free-keys";
      version = "1.0";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/free-keys-1.0.tar";
        sha256 = "04x4hmia5rx6bd8pkp5b9g4mn081r14vyk1jbdygdzr5w5rhifx3";
      };

      ename = "free-keys";
      packageRequires = [ cl-lib ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/free-keys.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  gc-buffers = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "gc-buffers";
      version = "1.0";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/gc-buffers-1.0.tar";
        sha256 = "00204vanfabyf6cgbn64xgqhqz8mlppizsgi31xg6id1qgrj37p3";
      };

      ename = "gc-buffers";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/gc-buffers.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  geiser = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      project,
    }:
    elpaBuild {
      pname = "geiser";
      version = "0.33.1";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/geiser-0.33.1.tar";
        sha256 = "0mh701hp587ahiqf0znnc4jm46i49z85nwac4bxn7sxxjid3xffl";
      };

      ename = "geiser";
      packageRequires = [ project ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/geiser.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  geiser-chez = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      geiser,
    }:
    elpaBuild {
      pname = "geiser-chez";
      version = "0.18";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/geiser-chez-0.18.tar";
        sha256 = "14l2a7njx3bzxj1qpc1m5mx4prm3ixgsiii3k484brbn4vim4j58";
      };

      ename = "geiser-chez";
      packageRequires = [ geiser ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/geiser-chez.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  geiser-chibi = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      geiser,
    }:
    elpaBuild {
      pname = "geiser-chibi";
      version = "0.17";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/geiser-chibi-0.17.tar";
        sha256 = "17kkgs0z2xwbbwn7s49lnha6pmri1h7jnnhh5qvxif5xyvyy8bih";
      };

      ename = "geiser-chibi";
      packageRequires = [ geiser ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/geiser-chibi.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  geiser-chicken = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      geiser,
    }:
    elpaBuild {
      pname = "geiser-chicken";
      version = "0.17";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/geiser-chicken-0.17.tar";
        sha256 = "1l0x0b5gcmc6v2gd2jhrz4zz2630rggq8w7ffzhsf8b8hr4d1ixy";
      };

      ename = "geiser-chicken";
      packageRequires = [ geiser ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/geiser-chicken.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  geiser-gambit = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      geiser,
    }:
    elpaBuild {
      pname = "geiser-gambit";
      version = "0.18.1";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/geiser-gambit-0.18.1.tar";
        sha256 = "1pqify8vqxzpm202zz9q92hp65yhs624z6qc2hgp9c1zms56jkqs";
      };

      ename = "geiser-gambit";
      packageRequires = [ geiser ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/geiser-gambit.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  geiser-gauche = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      geiser,
    }:
    elpaBuild {
      pname = "geiser-gauche";
      version = "0.0.2";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/geiser-gauche-0.0.2.tar";
        sha256 = "189addy5xvx62j91ihi23i8dh5msm0wlwxyi8n07f4m2garrn14l";
      };

      ename = "geiser-gauche";
      packageRequires = [ geiser ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/geiser-gauche.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  geiser-guile = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      geiser,
      transient,
    }:
    elpaBuild {
      pname = "geiser-guile";
      version = "0.28.5";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/geiser-guile-0.28.5.tar";
        sha256 = "078hmmqg6m428bg2sf640bwylrh4y64qanbz00prvjhgkrp1awnn";
      };

      ename = "geiser-guile";

      packageRequires = [
        geiser
        transient
      ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/geiser-guile.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  geiser-kawa = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      geiser,
    }:
    elpaBuild {
      pname = "geiser-kawa";
      version = "0.0.1";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/geiser-kawa-0.0.1.tar";
        sha256 = "1qh4qr406ahk4k8g46nzkiic1fidhni0a5zv4i84cdypv1c4473p";
      };

      ename = "geiser-kawa";
      packageRequires = [ geiser ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/geiser-kawa.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  geiser-mit = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      geiser,
    }:
    elpaBuild {
      pname = "geiser-mit";
      version = "0.15";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/geiser-mit-0.15.tar";
        sha256 = "12wimv5x2k64ww9x147dlx2gfygmgz96hqcdhkbidi1smhfz11gk";
      };

      ename = "geiser-mit";
      packageRequires = [ geiser ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/geiser-mit.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  geiser-racket = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      geiser,
    }:
    elpaBuild {
      pname = "geiser-racket";
      version = "0.16";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/geiser-racket-0.16.tar";
        sha256 = "08sn32ams88ism6k24kq7s54vrdblkn15x9lldyqg4zapbllr1ny";
      };

      ename = "geiser-racket";
      packageRequires = [ geiser ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/geiser-racket.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  geiser-stklos = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      geiser,
    }:
    elpaBuild {
      pname = "geiser-stklos";
      version = "1.8";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/geiser-stklos-1.8.tar";
        sha256 = "1525n49igcnwr2wsjv4a74yk1gbjvv1l9rmkcpafyxyykvi94j6s";
      };

      ename = "geiser-stklos";
      packageRequires = [ geiser ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/geiser-stklos.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  git-commit = callPackage (
    {
      lib,
      fetchurl,
      compat,
      elpaBuild,
      seq,
      transient,
      with-editor,
    }:
    elpaBuild {
      pname = "git-commit";
      version = "4.0.0";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/git-commit-4.0.0.tar";
        sha256 = "10fh8i3l07qxsfw23q2mkb7rxgc7n2chirzdjd9bnlqrxybrayli";
      };

      ename = "git-commit";

      packageRequires = [
        compat
        seq
        transient
        with-editor
      ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/git-commit.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  git-modes = callPackage (
    {
      lib,
      fetchurl,
      compat,
      elpaBuild,
    }:
    elpaBuild {
      pname = "git-modes";
      version = "1.5.0";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/git-modes-1.5.0.tar";
        sha256 = "0fxvv451pf8izn5q16ly21dxjax43l2p7qav11hi7qmygrrhxsc6";
      };

      ename = "git-modes";
      packageRequires = [ compat ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/git-modes.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  gnosis = callPackage (
    {
      lib,
      fetchurl,
      compat,
      elpaBuild,
      emacsql,
      org-gnosis,
      transient,
    }:
    elpaBuild {
      pname = "gnosis";
      version = "0.7.0";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/gnosis-0.7.0.tar";
        sha256 = "0r8mblfdqzjbvcis1387yvgrcg2b47zld179dax9n4smbzvzc3gb";
      };

      ename = "gnosis";

      packageRequires = [
        compat
        emacsql
        org-gnosis
        transient
      ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/gnosis.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  gnu-apl-mode = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "gnu-apl-mode";
      version = "1.5.1";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/gnu-apl-mode-1.5.1.tar";
        sha256 = "0hzdmrhrcnq49cklpmbx1sq7d9qd2q6pprgshhhjx45mnn1q24v0";
      };

      ename = "gnu-apl-mode";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/gnu-apl-mode.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  gnu-indent = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "gnu-indent";
      version = "1.0";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/gnu-indent-1.0.tar";
        sha256 = "1aj8si93ig1qbdqgq3f4jwnsws63drkfwfzxlq0i3qqfhsni0a15";
      };

      ename = "gnu-indent";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/gnu-indent.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  gnuplot = callPackage (
    {
      lib,
      fetchurl,
      compat,
      elpaBuild,
    }:
    elpaBuild {
      pname = "gnuplot";
      version = "0.12";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/gnuplot-0.12.tar";
        sha256 = "13pbnlwg9z7yc8s1hr1fq031cl9swld2jgxdd74jra49vvh6a3ar";
      };

      ename = "gnuplot";
      packageRequires = [ compat ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/gnuplot.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  go-mode = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "go-mode";
      version = "1.6.0";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/go-mode-1.6.0.tar";
        sha256 = "0ilvkl7iv47v0xyha07gfyv1a4c50ifw57bp7rx8ai77v30f3a2a";
      };

      ename = "go-mode";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/go-mode.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  golden-ratio = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "golden-ratio";
      version = "1.0.1";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/golden-ratio-1.0.1.tar";
        sha256 = "169jl82906k03vifks0zs4sk5gcxax5jii6nysh6y6ns2h656cqx";
      };

      ename = "golden-ratio";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/golden-ratio.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  gotham-theme = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "gotham-theme";
      version = "1.1.9";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/gotham-theme-1.1.9.tar";
        sha256 = "195r8idq2ak6wpmgifpgvx52hljb8i7p9wx6ii1kh0baaqk31qq2";
      };

      ename = "gotham-theme";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/gotham-theme.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  goto-chg = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "goto-chg";
      version = "1.7.5";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/goto-chg-1.7.5.tar";
        sha256 = "1j5vk8vc1v865fc8gdy0p5lpp2kkl0yn9f75npiva3ay6mwvnvay";
      };

      ename = "goto-chg";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/goto-chg.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  gptel = callPackage (
    {
      lib,
      fetchurl,
      compat,
      elpaBuild,
      transient,
    }:
    elpaBuild {
      pname = "gptel";
      version = "0.9.9.5";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/gptel-0.9.9.5.tar";
        sha256 = "1x1sd8g5fbgidj40ri9xg0rvyxdyjpxxnr45i0dj8d333nvssdq0";
      };

      ename = "gptel";

      packageRequires = [
        compat
        transient
      ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/gptel.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  graphql-mode = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "graphql-mode";
      version = "1.0.0";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/graphql-mode-1.0.0.tar";
        sha256 = "0pfyznfndc8g2g3a3pxzcjsh3cah3amhz5124flrja5fqdgdmpjz";
      };

      ename = "graphql-mode";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/graphql-mode.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  gruber-darker-theme = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "gruber-darker-theme";
      version = "0.7";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/gruber-darker-theme-0.7.tar";
        sha256 = "1ib9ad120g39fbkj41am6khglv1p6g3a9hk2jj2kl0c6czr1il2r";
      };

      ename = "gruber-darker-theme";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/gruber-darker-theme.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  gruvbox-theme = callPackage (
    {
      lib,
      fetchurl,
      autothemer,
      elpaBuild,
    }:
    elpaBuild {
      pname = "gruvbox-theme";
      version = "1.30.1";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/gruvbox-theme-1.30.1.tar";
        sha256 = "1y30aahdxzdfmj021vbrz4zmdq6lr9k08hna9i1a8g4cywgbz8ri";
      };

      ename = "gruvbox-theme";
      packageRequires = [ autothemer ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/gruvbox-theme.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  guru-mode = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "guru-mode";
      version = "1.0";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/guru-mode-1.0.tar";
        sha256 = "0kmbllzvp8qzj8ck2azq2wfw66ywc80zicncja62bi6zsh2l622z";
      };

      ename = "guru-mode";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/guru-mode.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  haml-mode = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      cl-lib ? null,
    }:
    elpaBuild {
      pname = "haml-mode";
      version = "3.2.1";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/haml-mode-3.2.1.tar";
        sha256 = "0hhra7bryk3n649s3byzq6vv5ywd4bqkfppya7bswqkj3bakiyil";
      };

      ename = "haml-mode";
      packageRequires = [ cl-lib ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/haml-mode.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  haskell-mode = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "haskell-mode";
      version = "17.5";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/haskell-mode-17.5.tar";
        sha256 = "1yjy0cvgs5cnq5d9sv24p1p66z83r9rhbgn0nsccc12rn2gm3hyn";
      };

      ename = "haskell-mode";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/haskell-mode.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  haskell-tng-mode = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "haskell-tng-mode";
      version = "0.0.1";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/haskell-tng-mode-0.0.1.tar";
        sha256 = "0l6rs93322la2fn8wyvxshl6f967ngamw2m1hnm2j6hvmqph5cpj";
      };

      ename = "haskell-tng-mode";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/haskell-tng-mode.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  haskell-ts-mode = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "haskell-ts-mode";
      version = "1.3.5";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/haskell-ts-mode-1.3.5.tar";
        sha256 = "19cy20wh2al1akgyx24jkks1hmfrhdrbw4h7a9g1nxsn7bw88lqy";
      };

      ename = "haskell-ts-mode";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/haskell-ts-mode.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  helm = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      helm-core,
      wfnames,
    }:
    elpaBuild {
      pname = "helm";
      version = "4.0.7";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/helm-4.0.7.tar";
        sha256 = "1x1wg3z6y5rb4r17ifwvz79pa3m6w9kkvxlfivznqh4ajgafrnn5";
      };

      ename = "helm";

      packageRequires = [
        helm-core
        wfnames
      ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/helm.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  helm-core = callPackage (
    {
      lib,
      fetchurl,
      async,
      elpaBuild,
    }:
    elpaBuild {
      pname = "helm-core";
      version = "4.0.7";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/helm-core-4.0.7.tar";
        sha256 = "1d7a61rbc7rlr144v9qm6c89dnchn7xwcv05gl6kdapb7gir9l8f";
      };

      ename = "helm-core";
      packageRequires = [ async ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/helm-core.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  hideshowvis = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "hideshowvis";
      version = "0.9";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/hideshowvis-0.9.tar";
        sha256 = "0yi9qcbacn97gl9y3zmvzr1b48hhx6h1yjcwllficahiq39fs0h8";
      };

      ename = "hideshowvis";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/hideshowvis.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  highlight-parentheses = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "highlight-parentheses";
      version = "2.2.2";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/highlight-parentheses-2.2.2.tar";
        sha256 = "13686dkgpn30di3kkc60l3dhrrjdknqkmvgjnl97mrbikxfma7w2";
      };

      ename = "highlight-parentheses";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/highlight-parentheses.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  hl-block-mode = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "hl-block-mode";
      version = "0.2";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/hl-block-mode-0.2.tar";
        sha256 = "0anv7bvrwylp504l3g42jcbcfmibv9jzs2kbkny46xd9vfb3kyrl";
      };

      ename = "hl-block-mode";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/hl-block-mode.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  hl-column = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "hl-column";
      version = "1.0";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/hl-column-1.0.tar";
        sha256 = "11d7xplpjx0b6ppcjv4giazrla1qcaaf2i6s5g0j5zxb1m60kkfz";
      };

      ename = "hl-column";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/hl-column.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  htmlize = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "htmlize";
      version = "1.59";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/htmlize-1.59.tar";
        sha256 = "0ng3gngv4y67ncr7a0zl7mj22c4772mkqf3dazspmp3jfqdyq9sr";
      };

      ename = "htmlize";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/htmlize.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  hyperdrive = callPackage (
    {
      lib,
      fetchurl,
      compat,
      elpaBuild,
      map,
      org,
      persist,
      plz,
      taxy-magit-section,
      transient,
    }:
    elpaBuild {
      pname = "hyperdrive";
      version = "0.5.2";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/hyperdrive-0.5.2.tar";
        sha256 = "1gn6kdxvds27bjfsamzihqg8bddwsyfmc2g36p50km2qfa8fgpvz";
      };

      ename = "hyperdrive";

      packageRequires = [
        compat
        map
        org
        persist
        plz
        taxy-magit-section
        transient
      ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/hyperdrive.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  hyperdrive-org-transclusion = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      hyperdrive,
      org-transclusion,
    }:
    elpaBuild {
      pname = "hyperdrive-org-transclusion";
      version = "0.3.1";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/hyperdrive-org-transclusion-0.3.1.tar";
        sha256 = "074ylcblg6wg2yg8jv1i6cn8vig56br0bqp5xwmhkslwrkqj05cj";
      };

      ename = "hyperdrive-org-transclusion";

      packageRequires = [
        hyperdrive
        org-transclusion
      ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/hyperdrive-org-transclusion.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  idle-highlight-mode = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "idle-highlight-mode";
      version = "1.1.5";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/idle-highlight-mode-1.1.5.tar";
        sha256 = "0wr7xakvvdykj4gwmi88w6jbwgiyj85fq1y7k0f50i0631xbwvpq";
      };

      ename = "idle-highlight-mode";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/idle-highlight-mode.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  idris-mode = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      prop-menu,
      cl-lib ? null,
    }:
    elpaBuild {
      pname = "idris-mode";
      version = "1.1.0";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/idris-mode-1.1.0.tar";
        sha256 = "1vlm7gshrkwp9lfm5jcp1rnsjxwzqknrjhl3q5ifwmicyvqkqwsv";
      };

      ename = "idris-mode";

      packageRequires = [
        cl-lib
        prop-menu
      ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/idris-mode.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  iedit = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "iedit";
      version = "0.9.9.9.9";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/iedit-0.9.9.9.9.tar";
        sha256 = "12s71yj8ycrls2fl97qs3igk5y06ksbmfq2idz0a2zrdggndg0b6";
      };

      ename = "iedit";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/iedit.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  inf-clojure = callPackage (
    {
      lib,
      fetchurl,
      clojure-mode,
      elpaBuild,
    }:
    elpaBuild {
      pname = "inf-clojure";
      version = "3.4.0";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/inf-clojure-3.4.0.tar";
        sha256 = "0j79fi1993mwy66nrqgks5b0v84yy5g7h2ddzfhl4r0kigm8ag6p";
      };

      ename = "inf-clojure";
      packageRequires = [ clojure-mode ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/inf-clojure.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  inf-ruby = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "inf-ruby";
      version = "2.9.0";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/inf-ruby-2.9.0.tar";
        sha256 = "0q6vfll2s1wc1fkmjdqsfws51j6x13knr96k94z2mjnjclv4qgcj";
      };

      ename = "inf-ruby";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/inf-ruby.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  inkpot-theme = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "inkpot-theme";
      version = "0.1";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/inkpot-theme-0.1.tar";
        sha256 = "0ik7vkwqlsgxmdckd154kh82zg8jr41vwc0a200x9920l5mnfjq2";
      };

      ename = "inkpot-theme";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/inkpot-theme.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  isl = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "isl";
      version = "1.7";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/isl-1.7.tar";
        sha256 = "1nksczxv2bq6l8wg855a0ahzp1w3dhai4vwni8hyrp5fk2z0gcan";
      };

      ename = "isl";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/isl.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  iwindow = callPackage (
    {
      lib,
      fetchurl,
      compat,
      elpaBuild,
      seq,
    }:
    elpaBuild {
      pname = "iwindow";
      version = "1.1";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/iwindow-1.1.tar";
        sha256 = "04d5dxqazxfx8ap9vmhj643x7lmpa0wmzcm9w9mlvsk2kaz0j19i";
      };

      ename = "iwindow";

      packageRequires = [
        compat
        seq
      ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/iwindow.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  j-mode = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "j-mode";
      version = "2.0.2";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/j-mode-2.0.2.tar";
        sha256 = "109fy5r3hfz15qdsrmdr6iik4w1kzn2pz7077xrd4mbi7gw5ggdx";
      };

      ename = "j-mode";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/j-mode.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  jabber = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      fsm,
      keymap-popup,
    }:
    elpaBuild {
      pname = "jabber";
      version = "0.11.0";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/jabber-0.11.0.tar";
        sha256 = "1wikfd8iqj9r1qrh6cd593vgbkjndfpm9f12ilsdwxwh0nx3cpd7";
      };

      ename = "jabber";

      packageRequires = [
        fsm
        keymap-popup
      ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/jabber.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  jade-mode = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "jade-mode";
      version = "1.0.1";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/jade-mode-1.0.1.tar";
        sha256 = "0pv0n9vharda92avggd91q8i98yjim9ccnz5m5c5xw12hxcsfj17";
      };

      ename = "jade-mode";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/jade-mode.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  javelin = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "javelin";
      version = "0.2.3";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/javelin-0.2.3.tar";
        sha256 = "1abk4sb3vp04qkzdil54bfph4xdpgq5nz41ay8dz4gnipwfdwdwg";
      };

      ename = "javelin";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/javelin.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  jinja2-mode = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "jinja2-mode";
      version = "0.3";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/jinja2-mode-0.3.tar";
        sha256 = "0dg1zn7mghclnxsmcl5nq5jqibm18sja23058q9lk6nph4fvz5dq";
      };

      ename = "jinja2-mode";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/jinja2-mode.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  julia-mode = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "julia-mode";
      version = "1.1.0";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/julia-mode-1.1.0.tar";
        sha256 = "1r8xsn5j1gdr2izy6q1xs13v7wcabgdrn7f6x608406kbhd01rrv";
      };

      ename = "julia-mode";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/julia-mode.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  keycast = callPackage (
    {
      lib,
      fetchurl,
      compat,
      cond-let,
      elpaBuild,
    }:
    elpaBuild {
      pname = "keycast";
      version = "1.4.8";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/keycast-1.4.8.tar";
        sha256 = "0rgaqc2d7n8a498n8jb14890gp6z49nqnpzk1h0xw03hnh8smz90";
      };

      ename = "keycast";

      packageRequires = [
        compat
        cond-let
      ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/keycast.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  kotlin-mode = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "kotlin-mode";
      version = "2.0.0";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/kotlin-mode-2.0.0.tar";
        sha256 = "0d247kxbrhkbmgldmalywmx6fqiz35ifvjbv20lyrmnbyhx1zr97";
      };

      ename = "kotlin-mode";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/kotlin-mode.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  lem = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      fedi,
      markdown-mode,
    }:
    elpaBuild {
      pname = "lem";
      version = "0.25";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/lem-0.25.tar";
        sha256 = "1hrnq46bmz10a3w89flhw85rqs58wpnywslx3p8g16196ln348sd";
      };

      ename = "lem";

      packageRequires = [
        fedi
        markdown-mode
      ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/lem.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  llama = callPackage (
    {
      lib,
      fetchurl,
      compat,
      elpaBuild,
    }:
    elpaBuild {
      pname = "llama";
      version = "1.0.5";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/llama-1.0.5.tar";
        sha256 = "10ysi2a7aifp9ixrhygfcas7zn9dfqy1zpiycwz3gamlzkvjzw2l";
      };

      ename = "llama";
      packageRequires = [ compat ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/llama.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  logview = callPackage (
    {
      lib,
      fetchurl,
      compat,
      datetime,
      elpaBuild,
      extmap,
    }:
    elpaBuild {
      pname = "logview";
      version = "0.19.3";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/logview-0.19.3.tar";
        sha256 = "1ldcjf0p8m0qnhqc98f5hi5kk05adl3j21b7nkc0b879v9bc9in9";
      };

      ename = "logview";

      packageRequires = [
        compat
        datetime
        extmap
      ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/logview.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  loopy = callPackage (
    {
      lib,
      fetchurl,
      compat,
      elpaBuild,
      map,
      seq,
      stream,
    }:
    elpaBuild {
      pname = "loopy";
      version = "0.16.0";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/loopy-0.16.0.tar";
        sha256 = "0bav318gimpv42y0ww9c0gm90pkma3ri0xp9mfimz9yriw2bjzyv";
      };

      ename = "loopy";

      packageRequires = [
        compat
        map
        seq
        stream
      ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/loopy.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  loopy-dash = callPackage (
    {
      lib,
      fetchurl,
      dash,
      elpaBuild,
      loopy,
    }:
    elpaBuild {
      pname = "loopy-dash";
      version = "0.13.0";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/loopy-dash-0.13.0.tar";
        sha256 = "1hylniv839x8cl4nbdl64s4h1cnmbwfl47138z32bgdmcv1kbxqi";
      };

      ename = "loopy-dash";

      packageRequires = [
        dash
        loopy
      ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/loopy-dash.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  lorem-ipsum = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "lorem-ipsum";
      version = "0.4";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/lorem-ipsum-0.4.tar";
        sha256 = "0d1c6zalnqhyn88dbbi8wqzvp0ppswhqv656hbj129jwp4iida4x";
      };

      ename = "lorem-ipsum";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/lorem-ipsum.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  lua-mode = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "lua-mode";
      version = "20221027";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/lua-mode-20221027.tar";
        sha256 = "0mg4fjprrcwqfrzxh6wpl92r3ywpj3586444c6yvq1rs56z5wvj5";
      };

      ename = "lua-mode";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/lua-mode.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  macrostep = callPackage (
    {
      lib,
      fetchurl,
      compat,
      elpaBuild,
      cl-lib ? null,
    }:
    elpaBuild {
      pname = "macrostep";
      version = "0.9.5";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/macrostep-0.9.5.tar";
        sha256 = "16nl81hsbkiwwsy7gcg150xpf8k1899afcsnr1h25z2z6qz3bp9l";
      };

      ename = "macrostep";

      packageRequires = [
        cl-lib
        compat
      ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/macrostep.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  magit = callPackage (
    {
      lib,
      fetchurl,
      compat,
      cond-let,
      elpaBuild,
      llama,
      magit-section,
      seq,
      transient,
      with-editor,
    }:
    elpaBuild {
      pname = "magit";
      version = "4.5.0";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/magit-4.5.0.tar";
        sha256 = "080hc0y9pah86g7nw1x1gh2issap54r8dg9vzpm2l923cxy9jnbp";
      };

      ename = "magit";

      packageRequires = [
        compat
        cond-let
        llama
        magit-section
        seq
        transient
        with-editor
      ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/magit.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  magit-section = callPackage (
    {
      lib,
      fetchurl,
      compat,
      cond-let,
      elpaBuild,
      llama,
      seq,
    }:
    elpaBuild {
      pname = "magit-section";
      version = "4.5.0";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/magit-section-4.5.0.tar";
        sha256 = "1k63g8ayvg152r16ml5ph8q07qs5a424vs4i5q32icvl78v6cn2z";
      };

      ename = "magit-section";

      packageRequires = [
        compat
        cond-let
        llama
        seq
      ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/magit-section.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  markdown-mode = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "markdown-mode";
      version = "2.8";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/markdown-mode-2.8.tar";
        sha256 = "1868sy5ywlad21ldb6ly1r62vdnc533rdr88s9jmn3r3dcnfwrf2";
      };

      ename = "markdown-mode";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/markdown-mode.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  mastodon = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      persist,
      tp,
    }:
    elpaBuild {
      pname = "mastodon";
      version = "2.0.17";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/mastodon-2.0.17.tar";
        sha256 = "1yg1fylz1dp7my8zfnscnvd1sdhjhi45xw10sqn3rmqmmrwd87d9";
      };

      ename = "mastodon";

      packageRequires = [
        persist
        tp
      ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/mastodon.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  material-theme = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "material-theme";
      version = "2015";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/material-theme-2015.tar";
        sha256 = "117ismd3p577cr59b6995byyq90zn4nd81dlf4pm8p0iiziryyji";
      };

      ename = "material-theme";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/material-theme.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  mentor = callPackage (
    {
      lib,
      fetchurl,
      async,
      elpaBuild,
      seq,
      url-scgi,
      xml-rpc,
    }:
    elpaBuild {
      pname = "mentor";
      version = "0.5";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/mentor-0.5.tar";
        sha256 = "1sqdwdbanrdvrr8qqn23ylcyc98jcjc7yq1g1d963v8d9wfbailv";
      };

      ename = "mentor";

      packageRequires = [
        async
        seq
        url-scgi
        xml-rpc
      ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/mentor.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  meow = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "meow";
      version = "1.5.0";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/meow-1.5.0.tar";
        sha256 = "1fwd6lwaci23scgv65fxrxg51w334pw92l4c51ci9s0qgh1vjb01";
      };

      ename = "meow";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/meow.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  minibar = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "minibar";
      version = "0.3";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/minibar-0.3.tar";
        sha256 = "0vxjw485bja8h3gmqmvg9541f21ricwcw6ydlhv9174as5cmwx5j";
      };

      ename = "minibar";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/minibar.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  moe-theme = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "moe-theme";
      version = "1.1.0";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/moe-theme-1.1.0.tar";
        sha256 = "103xs821rvq3dq886jy53rc3lycv7xzyr69x1a4yn4lbyf5q4bp6";
      };

      ename = "moe-theme";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/moe-theme.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  monokai-theme = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "monokai-theme";
      version = "3.5.3";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/monokai-theme-3.5.3.tar";
        sha256 = "14ylizbhfj2hlc52gi2fs70avz39s46wnr96dbbq4l8vmhxs7il5";
      };

      ename = "monokai-theme";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/monokai-theme.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  mpv = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      org,
      cl-lib ? null,
      json ? null,
    }:
    elpaBuild {
      pname = "mpv";
      version = "0.2.0";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/mpv-0.2.0.tar";
        sha256 = "183alhd5fvmlhhfm0wl7b50axs01pgiwv735c43bfzdi2ny4szcm";
      };

      ename = "mpv";

      packageRequires = [
        cl-lib
        json
        org
      ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/mpv.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  multiple-cursors = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      cl-lib ? null,
    }:
    elpaBuild {
      pname = "multiple-cursors";
      version = "1.5.0";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/multiple-cursors-1.5.0.tar";
        sha256 = "05nvanam57mwa1rajnjrp9j9j23bmr5za90yp56jb6rsi8mphzbx";
      };

      ename = "multiple-cursors";
      packageRequires = [ cl-lib ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/multiple-cursors.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  nasm-mode = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "nasm-mode";
      version = "1.1.1";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/nasm-mode-1.1.1.tar";
        sha256 = "19k0gwwx2fz779yli6pcl0a7grhsbhwyisq76lmnnclw0gkf686l";
      };

      ename = "nasm-mode";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/nasm-mode.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  nginx-mode = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "nginx-mode";
      version = "1.1.10";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/nginx-mode-1.1.10.tar";
        sha256 = "0c6biqxbwpkrbqi639ifgv8jkfadssyznjkq6hxvqgjh3nnyrlx3";
      };

      ename = "nginx-mode";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/nginx-mode.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  nix-mode = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      magit-section,
      transient,
    }:
    elpaBuild {
      pname = "nix-mode";
      version = "1.5.0";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/nix-mode-1.5.0.tar";
        sha256 = "0hansrsyzx8j31rk45y8zs9hbfjgbv9sf3r37s2a2adz48n9k86g";
      };

      ename = "nix-mode";

      packageRequires = [
        magit-section
        transient
      ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/nix-mode.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  nov = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      esxml,
    }:
    elpaBuild {
      pname = "nov";
      version = "0.5.0";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/nov-0.5.0.tar";
        sha256 = "1isr91a4wkpy81nn620r10gwi6v1z6phb4wmf2zf1g3i0czzpz4x";
      };

      ename = "nov";
      packageRequires = [ esxml ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/nov.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  oblivion-theme = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "oblivion-theme";
      version = "0.1";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/oblivion-theme-0.1.tar";
        sha256 = "0njm7znh84drqwkp4jjsr8by6q9xd65r8l7xaqahzhk78167q6s4";
      };

      ename = "oblivion-theme";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/oblivion-theme.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  opam-switch-mode = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "opam-switch-mode";
      version = "1.7";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/opam-switch-mode-1.7.tar";
        sha256 = "1gpc1syb51am2gkb3cgfb28rhh6ik41c1gx9gjf1h8m6zxb75433";
      };

      ename = "opam-switch-mode";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/opam-switch-mode.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  org-auto-tangle = callPackage (
    {
      lib,
      fetchurl,
      async,
      elpaBuild,
    }:
    elpaBuild {
      pname = "org-auto-tangle";
      version = "0.6.0";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/org-auto-tangle-0.6.0.tar";
        sha256 = "1vh3k283h90v3qilyx1n30k4ny5rkry6x9s6778s0sm6f6hwdggd";
      };

      ename = "org-auto-tangle";
      packageRequires = [ async ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/org-auto-tangle.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  org-contrib = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      org,
    }:
    elpaBuild {
      pname = "org-contrib";
      version = "0.8";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/org-contrib-0.8.tar";
        sha256 = "0bw6wrnkbx26k0zxgglyps2nnmgwr6yvkizxqnknds3y5r643j34";
      };

      ename = "org-contrib";
      packageRequires = [ org ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/org-contrib.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  org-drill = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      org,
      persist,
      seq,
    }:
    elpaBuild {
      pname = "org-drill";
      version = "2.7.0";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/org-drill-2.7.0.tar";
        sha256 = "0118vdd0gv2ipgfljkda4388gdly45c5vg0yfn3z4p0p8mjd15lg";
      };

      ename = "org-drill";

      packageRequires = [
        org
        persist
        seq
      ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/org-drill.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  org-journal = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      org,
    }:
    elpaBuild {
      pname = "org-journal";
      version = "2.2.0";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/org-journal-2.2.0.tar";
        sha256 = "12mvi8x8rsm93s55z8ns1an00l2p545swc0gzmx38ff57m7jb1mj";
      };

      ename = "org-journal";
      packageRequires = [ org ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/org-journal.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  org-mime = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "org-mime";
      version = "0.3.4";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/org-mime-0.3.4.tar";
        sha256 = "06ard0fndp1iffd8lqqrf4dahbxkh76blava9s6xzxf75zzmlsyj";
      };

      ename = "org-mime";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/org-mime.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  org-present = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      org,
    }:
    elpaBuild {
      pname = "org-present";
      version = "0.1";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/org-present-0.1.tar";
        sha256 = "18zrvrd9aih57gj14qmxv9rf5j859vkvxcni3fkdbj84y5pq2fpy";
      };

      ename = "org-present";
      packageRequires = [ org ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/org-present.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  org-superstar = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      org,
    }:
    elpaBuild {
      pname = "org-superstar";
      version = "1.7.0";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/org-superstar-1.7.0.tar";
        sha256 = "1c52kpsj52zswjyv35b6pdd41y4a8hkm1rww3zmrdm80h05sifz0";
      };

      ename = "org-superstar";
      packageRequires = [ org ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/org-superstar.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  org-transclusion-http = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      org-transclusion,
      plz,
    }:
    elpaBuild {
      pname = "org-transclusion-http";
      version = "0.4";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/org-transclusion-http-0.4.tar";
        sha256 = "1k57672w0dcw63dp1a6m5fc0pkm8p5la9811m16r440i7wqq0kmr";
      };

      ename = "org-transclusion-http";

      packageRequires = [
        org-transclusion
        plz
      ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/org-transclusion-http.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  org-tree-slide = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "org-tree-slide";
      version = "2.8.22";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/org-tree-slide-2.8.22.tar";
        sha256 = "1wqc5d2nxs4s6p2ap6sdalxnyigpxini8ck6jikaarmfqcghnx2m";
      };

      ename = "org-tree-slide";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/org-tree-slide.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  orgit = callPackage (
    {
      lib,
      fetchurl,
      compat,
      cond-let,
      elpaBuild,
      magit,
      org,
    }:
    elpaBuild {
      pname = "orgit";
      version = "2.1.3";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/orgit-2.1.3.tar";
        sha256 = "1brwy6jx7jxb8jlkr8jq8hsdzmizqs41hkb3p14rmqqd0m5ddapl";
      };

      ename = "orgit";

      packageRequires = [
        compat
        cond-let
        magit
        org
      ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/orgit.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  p4-16-mode = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "p4-16-mode";
      version = "0.3";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/p4-16-mode-0.3.tar";
        sha256 = "1kwfqs7ikfjkkpv3m440ak40mjyf493gqygmc4hac8phlf9ns6dv";
      };

      ename = "p4-16-mode";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/p4-16-mode.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  package-lint = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      let-alist,
    }:
    elpaBuild {
      pname = "package-lint";
      version = "0.26";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/package-lint-0.26.tar";
        sha256 = "0sgqq19zvnlvf64ash2cig3n2avjrsjn107wfvm222sk2bm0ld1j";
      };

      ename = "package-lint";
      packageRequires = [ let-alist ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/package-lint.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  pacmacs = callPackage (
    {
      lib,
      fetchurl,
      dash,
      elpaBuild,
    }:
    elpaBuild {
      pname = "pacmacs";
      version = "0.1.1";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/pacmacs-0.1.1.tar";
        sha256 = "02ahl0608xmmlkb014gqvv6f45l5lrkm3s4l6m5p5r98rwmlj3q9";
      };

      ename = "pacmacs";
      packageRequires = [ dash ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/pacmacs.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  page-break-lines = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "page-break-lines";
      version = "0.15";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/page-break-lines-0.15.tar";
        sha256 = "018mn6h6nmkkgv1hsk0k8fjyg38wpg2f0cvqlv9p392sapca59ay";
      };

      ename = "page-break-lines";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/page-break-lines.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  paredit = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "paredit";
      version = "26";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/paredit-26.tar";
        sha256 = "1sk8nhsysa3y8fvds67cbwwzivzxlyw8d81y7f7pqc5lflidjrpc";
      };

      ename = "paredit";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/paredit.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  parseclj = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "parseclj";
      version = "1.1.1";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/parseclj-1.1.1.tar";
        sha256 = "0kkg5fdjbf2dm8jmirm86sjbqnzyhy72iml4qwwnshxjfhz1f0yi";
      };

      ename = "parseclj";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/parseclj.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  parseedn = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      map,
      parseclj,
    }:
    elpaBuild {
      pname = "parseedn";
      version = "1.2.1";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/parseedn-1.2.1.tar";
        sha256 = "0q6wkcjxwqf81pvrcjbga91lr4ml6adbhmc7j71f53awrpc980ak";
      };

      ename = "parseedn";

      packageRequires = [
        map
        parseclj
      ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/parseedn.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  pcmpl-args = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "pcmpl-args";
      version = "0.1.3";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/pcmpl-args-0.1.3.tar";
        sha256 = "1lycckmwhp9l0pcrzx6c11iqwaw94h00334pzagkcfay7lz3hcgd";
      };

      ename = "pcmpl-args";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/pcmpl-args.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  pcre2el = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "pcre2el";
      version = "1.12";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/pcre2el-1.12.tar";
        sha256 = "1p0fgqm5342698gadnvziwbvv2kxj953975sp92cx7ddcyv2xr3c";
      };

      ename = "pcre2el";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/pcre2el.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  pdf-tools = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      let-alist,
      tablist,
    }:
    elpaBuild {
      pname = "pdf-tools";
      version = "1.3.0";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/pdf-tools-1.3.0.tar";
        sha256 = "0kxv31jh8spndkf0lm2z6ibh9mna055ck4dmzbvws7rfk208rxip";
      };

      ename = "pdf-tools";

      packageRequires = [
        let-alist
        tablist
      ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/pdf-tools.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  pg = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      peg,
    }:
    elpaBuild {
      pname = "pg";
      version = "0.67";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/pg-0.67.tar";
        sha256 = "01q06yk011pn9pg9srilwy0k9nn8x5pl32k1mn9i54mbikf7ac5b";
      };

      ename = "pg";
      packageRequires = [ peg ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/pg.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  php-mode = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "php-mode";
      version = "1.26.1";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/php-mode-1.26.1.tar";
        sha256 = "151hk9kmwlaq243qfwh2s1vqk5xsyikl9gj5b65ywhhf326dirz1";
      };

      ename = "php-mode";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/php-mode.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  popon = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "popon";
      version = "0.13";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/popon-0.13.tar";
        sha256 = "0z0m7j30pdfw58cxxkmw5pkfpy8y1ax00wm4820rkqxz1f5sbkdb";
      };

      ename = "popon";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/popon.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  popup = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "popup";
      version = "0.5.9";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/popup-0.5.9.tar";
        sha256 = "06q31bv6nsdkdgyg6x0zzjnlq007zhqw2ssjmj44izl6h6fkr26m";
      };

      ename = "popup";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/popup.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  powershell = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "powershell";
      version = "0.4";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/powershell-0.4.tar";
        sha256 = "13f7rfjcip64if7mxd12pnrw409xdmxblddri49laacvi1qhlj9k";
      };

      ename = "powershell";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/powershell.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  projectile = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "projectile";
      version = "2.9.1";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/projectile-2.9.1.tar";
        sha256 = "07icp9baa7jkyqnz4b1sxl1dg88y5vzzhiwyfb12q349flbkkkb1";
      };

      ename = "projectile";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/projectile.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  proof-general = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "proof-general";
      version = "4.5";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/proof-general-4.5.tar";
        sha256 = "0mlmh7z93f7ypjlh6mxrxgcn47ysvi8qg8869qfxjgmskbfdvx2w";
      };

      ename = "proof-general";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/proof-general.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  prop-menu = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      cl-lib ? null,
    }:
    elpaBuild {
      pname = "prop-menu";
      version = "0.1.2";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/prop-menu-0.1.2.tar";
        sha256 = "1cbps617k2nfi5jcv7y1zip4v64mi17r3rhw9w3n4r5hbl4sjwmw";
      };

      ename = "prop-menu";
      packageRequires = [ cl-lib ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/prop-menu.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  racket-mode = callPackage (
    {
      lib,
      fetchurl,
      compat,
      elpaBuild,
    }:
    elpaBuild {
      pname = "racket-mode";
      version = "1.0.20260303.123213";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/racket-mode-1.0.20260303.123213.tar";
        sha256 = "1wxhdrwm2fr3rnv7ghziibnpbx99z9qdaa54zd11jzjpkjgf2jxs";
      };

      ename = "racket-mode";
      packageRequires = [ compat ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/racket-mode.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  radio = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "radio";
      version = "0.4.3";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/radio-0.4.3.tar";
        sha256 = "1xr10zhm8fk75h0i07jry5c05cds4xbb012wa943cbibxj0cma68";
      };

      ename = "radio";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/radio.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  rainbow-delimiters = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "rainbow-delimiters";
      version = "2.1.5";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/rainbow-delimiters-2.1.5.tar";
        sha256 = "0f4zhz92z5qk3p9ips2d76qi64xv6y8jrxh5nvbq46ivj5c0hnw2";
      };

      ename = "rainbow-delimiters";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/rainbow-delimiters.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  raku-mode = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "raku-mode";
      version = "0.2.1";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/raku-mode-0.2.1.tar";
        sha256 = "00iwkp4hwjdiymzbwm41m27avrn3n63hnwd9amyx0nsa0kdhrfyx";
      };

      ename = "raku-mode";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/raku-mode.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  recomplete = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "recomplete";
      version = "0.2";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/recomplete-0.2.tar";
        sha256 = "1jhyqgww8wawrxxd2zjb7scpamkbcp98hak9qmbn6ckgzdadks64";
      };

      ename = "recomplete";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/recomplete.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  reformatter = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "reformatter";
      version = "0.8";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/reformatter-0.8.tar";
        sha256 = "0bv0fbw3ach6jgnv67xjzxdzaghqa1rhgkmfsmkkbyz8ncbybj87";
      };

      ename = "reformatter";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/reformatter.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  request = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "request";
      version = "0.3.3";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/request-0.3.3.tar";
        sha256 = "02j24v8jdjsvi3v3asydb1zfiarzaxrpsshvgf62nhgk6x08845z";
      };

      ename = "request";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/request.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  rfc-mode = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "rfc-mode";
      version = "1.4.2";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/rfc-mode-1.4.2.tar";
        sha256 = "0lhs8wa4sr387xyibqqskkqgyhhhy48qp5wbjs8r5p68j1s1q86m";
      };

      ename = "rfc-mode";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/rfc-mode.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  rpm-spec-mode = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "rpm-spec-mode";
      version = "0.16";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/rpm-spec-mode-0.16.tar";
        sha256 = "0gc50kn1wmvz6k9afra7zcnsk7z76cc50vkvw3q8i7p911z55rfj";
      };

      ename = "rpm-spec-mode";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/rpm-spec-mode.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  rubocop = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "rubocop";
      version = "0.6.0";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/rubocop-0.6.0.tar";
        sha256 = "026cna402hg9lsrf88kmb2as667fgaianj2qd3ik9y89ps4xyzxf";
      };

      ename = "rubocop";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/rubocop.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  rust-mode = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "rust-mode";
      version = "1.0.6";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/rust-mode-1.0.6.tar";
        sha256 = "1x2hj5rhdcm9hdnr78430jh1ycwjiva5vv7xqm7758vcxw7x0nag";
      };

      ename = "rust-mode";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/rust-mode.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  sass-mode = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      haml-mode,
    }:
    elpaBuild {
      pname = "sass-mode";
      version = "3.0.16";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/sass-mode-3.0.16.tar";
        sha256 = "0ag7qi9dq4j23ywbwni7pblp6l1ik95vjhclxm82s1911a8m7pj2";
      };

      ename = "sass-mode";
      packageRequires = [ haml-mode ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/sass-mode.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  scad-mode = callPackage (
    {
      lib,
      fetchurl,
      compat,
      elpaBuild,
    }:
    elpaBuild {
      pname = "scad-mode";
      version = "99.0";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/scad-mode-99.0.tar";
        sha256 = "1wdb7ri2716r4m22asj370c3mnjchcsnxjwbw3m13rgvkj2ax6j4";
      };

      ename = "scad-mode";
      packageRequires = [ compat ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/scad-mode.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  scala-mode = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "scala-mode";
      version = "1.1.1";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/scala-mode-1.1.1.tar";
        sha256 = "1dmaq00432smrwqx6ybw855vdwp7s8h358c135ji5d581mkhpai5";
      };

      ename = "scala-mode";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/scala-mode.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  scroll-on-drag = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "scroll-on-drag";
      version = "0.1";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/scroll-on-drag-0.1.tar";
        sha256 = "0ga8w9px2x9a2ams0lm7ganbixylgpx8g2m3jrwfih0ib3z26kqc";
      };

      ename = "scroll-on-drag";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/scroll-on-drag.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  scroll-on-jump = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "scroll-on-jump";
      version = "0.3";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/scroll-on-jump-0.3.tar";
        sha256 = "02vksmab2bmasv1n8hawapzhnyfk3w0b0gbxbznp5zj6kzb8yr1q";
      };

      ename = "scroll-on-jump";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/scroll-on-jump.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  selected-window-contrast = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "selected-window-contrast";
      version = "0.4.1";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/selected-window-contrast-0.4.1.tar";
        sha256 = "0qpqw2nv91ki8n1rq33vlggbb8967sq34z1apqr4x3v4cjm4ym7a";
      };

      ename = "selected-window-contrast";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/selected-window-contrast.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  sesman = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "sesman";
      version = "0.3.2";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/sesman-0.3.2.tar";
        sha256 = "1mrv32cp87dhzpcv55v4zv4nq37lrsprsdhhjb2q0msqab3b0r31";
      };

      ename = "sesman";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/sesman.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  shellcop = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "shellcop";
      version = "0.1.0";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/shellcop-0.1.0.tar";
        sha256 = "1gj178fm0jj8dbfy0crwcjidih4r6g9dl9lprzpxzgswvma32g0w";
      };

      ename = "shellcop";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/shellcop.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  simple-httpd = callPackage (
    {
      lib,
      fetchurl,
      compat,
      elpaBuild,
    }:
    elpaBuild {
      pname = "simple-httpd";
      version = "1.6";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/simple-httpd-1.6.tar";
        sha256 = "08rkqid2c11dl0sm8795jzkiilj02kbq6xy56b3bh83pc09wfmay";
      };

      ename = "simple-httpd";
      packageRequires = [ compat ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/simple-httpd.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  slime = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      macrostep,
    }:
    elpaBuild {
      pname = "slime";
      version = "2.32";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/slime-2.32.tar";
        sha256 = "0j2f98l5pmzn2k947alsb2h0idywxwdg02gl6rinrrabyazhjnim";
      };

      ename = "slime";
      packageRequires = [ macrostep ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/slime.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  sly = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "sly";
      version = "1.0.43";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/sly-1.0.43.tar";
        sha256 = "1c7kzbpcrij4z09bxfa1rq5w23jw9h8v4s6fa6ihr13x67gsif84";
      };

      ename = "sly";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/sly.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  smartparens = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "smartparens";
      version = "1.11.0";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/smartparens-1.11.0.tar";
        sha256 = "0kvlyx2bhw4q6k79wf5cm4srlmfncsbii4spdgafwmv8j7vw6ya3";
      };

      ename = "smartparens";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/smartparens.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  solarized-theme = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "solarized-theme";
      version = "2.1.0";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/solarized-theme-2.1.0.tar";
        sha256 = "16nwwf1s54r0ni1wvch4jjz3ij7s8ns09hp0bszs9mp89cnh4b5j";
      };

      ename = "solarized-theme";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/solarized-theme.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  spacemacs-theme = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "spacemacs-theme";
      version = "0.2";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/spacemacs-theme-0.2.tar";
        sha256 = "07lkaj6gm5iz503p5l6sm1y62mc5wk13nrwzv81f899jw99jcgml";
      };

      ename = "spacemacs-theme";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/spacemacs-theme.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  spell-fu = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "spell-fu";
      version = "0.3";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/spell-fu-0.3.tar";
        sha256 = "11a5361xjap02s0mm2sylhxqqrv64v72d70cg1vzch7iwfi18l9c";
      };

      ename = "spell-fu";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/spell-fu.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  sqlite3 = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "sqlite3";
      version = "0.17";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/sqlite3-0.17.tar";
        sha256 = "17fx2bnzajqjzd9jgwvn6pjwshgirign975rrsc1m47cwniz0bnq";
      };

      ename = "sqlite3";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/sqlite3.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  standard-keys-mode = callPackage (
    {
      lib,
      fetchurl,
      compat,
      elpaBuild,
    }:
    elpaBuild {
      pname = "standard-keys-mode";
      version = "1.0.0";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/standard-keys-mode-1.0.0.tar";
        sha256 = "1c673y9xaw3i09ihhx7qbixm7rvyynxkv304wafrv7aflrzqranj";
      };

      ename = "standard-keys-mode";
      packageRequires = [ compat ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/standard-keys-mode.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  stylus-mode = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "stylus-mode";
      version = "1.0.1";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/stylus-mode-1.0.1.tar";
        sha256 = "0vihp241msg8f0ph8w3w9fkad9b12pmpwg0q5la8nbw7gfy41mz5";
      };

      ename = "stylus-mode";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/stylus-mode.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  subatomic-theme = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "subatomic-theme";
      version = "1.8.2";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/subatomic-theme-1.8.2.tar";
        sha256 = "0vpaswm5mdyb8cir160mb8ffgzaz7kbq3gvc2zrnh531zb994mqg";
      };

      ename = "subatomic-theme";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/subatomic-theme.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  subed = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "subed";
      version = "1.5.1";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/subed-1.5.1.tar";
        sha256 = "0gk9r2dvmrxpz4gpypnnzjgph6xasn5f9i51cx1hnd9r5zim2qy3";
      };

      ename = "subed";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/subed.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  sweeprolog = callPackage (
    {
      lib,
      fetchurl,
      compat,
      elpaBuild,
    }:
    elpaBuild {
      pname = "sweeprolog";
      version = "0.27.6";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/sweeprolog-0.27.6.tar";
        sha256 = "063bindr1rfbpa59nf0zrjq3axj3siiskaxd7d37pada411j654i";
      };

      ename = "sweeprolog";
      packageRequires = [ compat ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/sweeprolog.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  swift-mode = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "swift-mode";
      version = "10.0.0";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/swift-mode-10.0.0.tar";
        sha256 = "07wydsy8ihfmr1i4hya270f9v5dy9mfn6kzbmyj3kf9kx5grhybl";
      };

      ename = "swift-mode";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/swift-mode.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  swsw = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      emacs,
    }:
    elpaBuild {
      pname = "swsw";
      version = "2.3";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/swsw-2.3.tar";
        sha256 = "0qwdv174bh9k1bpd5szzmhk7hw89xf7rz2i2hzdrmlpvcs3ps653";
      };

      ename = "swsw";
      packageRequires = [ emacs ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/swsw.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  symbol-overlay = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      seq,
    }:
    elpaBuild {
      pname = "symbol-overlay";
      version = "4.3";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/symbol-overlay-4.3.tar";
        sha256 = "0f27axzjbrh4nx6ixpjbb8vx7s2y6l074cdqzia1c87a8b6301c6";
      };

      ename = "symbol-overlay";
      packageRequires = [ seq ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/symbol-overlay.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  systemd = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "systemd";
      version = "1.6.1";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/systemd-1.6.1.tar";
        sha256 = "0b0l70271kalicaix4p1ipr5vrj401cj8zvsi3243q1hp04k1m2g";
      };

      ename = "systemd";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/systemd.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  tablist = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "tablist";
      version = "1.0";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/tablist-1.0.tar";
        sha256 = "0z05va5fq054xysvhnpblxk5x0v6k4ian0hby6vryfxg9828gy57";
      };

      ename = "tablist";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/tablist.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  tangotango-theme = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "tangotango-theme";
      version = "0.0.7";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/tangotango-theme-0.0.7.tar";
        sha256 = "1w287p8lpmkm80qy1di2xmd71k051qmg89cn7s21kgi4br3hbbph";
      };

      ename = "tangotango-theme";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/tangotango-theme.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  teco = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "teco";
      version = "9";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/teco-9.tar";
        sha256 = "1c794lb22pbqc3dsaadjp0jn50j1c6wrx1b2xq1pp39yja49qvpp";
      };

      ename = "teco";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/teco.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  telephone-line = callPackage (
    {
      lib,
      fetchurl,
      cl-generic,
      elpaBuild,
      seq,
      cl-lib ? null,
    }:
    elpaBuild {
      pname = "telephone-line";
      version = "0.5";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/telephone-line-0.5.tar";
        sha256 = "0pmn1r2g639c8g3rw5q2d5cgdz79d4ipr3r4dzwx2mgff3ri1ylm";
      };

      ename = "telephone-line";

      packageRequires = [
        cl-generic
        cl-lib
        seq
      ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/telephone-line.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  testcover-mark-line = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "testcover-mark-line";
      version = "0.3";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/testcover-mark-line-0.3.tar";
        sha256 = "1p1dmxqdyk82qbcmggmzn15nz4jm98j5bjivy56vimgncqfbaf4h";
      };

      ename = "testcover-mark-line";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/testcover-mark-line.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  textile-mode = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "textile-mode";
      version = "1.0.0";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/textile-mode-1.0.0.tar";
        sha256 = "02nc3wijsb626631m09f2ygpmimkbl46x5hi8yk0wl18y66yq972";
      };

      ename = "textile-mode";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/textile-mode.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  toc-org = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "toc-org";
      version = "1.1";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/toc-org-1.1.tar";
        sha256 = "0qhkn1a4j1q5gflqlyha2534sms8xsx03i7dizrckhl368yznwan";
      };

      ename = "toc-org";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/toc-org.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  totp-auth = callPackage (
    {
      lib,
      fetchurl,
      base32,
      elpaBuild,
    }:
    elpaBuild {
      pname = "totp-auth";
      version = "1.0";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/totp-auth-1.0.tar";
        sha256 = "0hzj0p1r18q8vkhkbxbfakvmgld9y8n5hzza5zir0cpalv5590r5";
      };

      ename = "totp-auth";
      packageRequires = [ base32 ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/totp-auth.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  tp = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      transient,
    }:
    elpaBuild {
      pname = "tp";
      version = "0.9";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/tp-0.9.tar";
        sha256 = "0xaqynvw65l5dm3hxba6v8jrh2pvn6b2q0npsf9sdwryjg2zlk41";
      };

      ename = "tp";
      packageRequires = [ transient ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/tp.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  treepy = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "treepy";
      version = "0.1.3";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/treepy-0.1.3.tar";
        sha256 = "07xwqvqhnx3nkrj0pb9fgbg3agcrxdzxl3c8isi3pxwqnchykk0z";
      };

      ename = "treepy";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/treepy.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  treesit-fold = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "treesit-fold";
      version = "0.2.1";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/treesit-fold-0.2.1.tar";
        sha256 = "1dxrp6rd6bp90h7yhkr61jf83w7ivryk2ln6hdyl6lirfk7d4h43";
      };

      ename = "treesit-fold";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/treesit-fold.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  treeview = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "treeview";
      version = "1.3.1";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/treeview-1.3.1.tar";
        sha256 = "02xac8kfh5j6vz0k44wif5v9h9xzs7srwxk0jff21qw32wy4accl";
      };

      ename = "treeview";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/treeview.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  tuareg = callPackage (
    {
      lib,
      fetchurl,
      caml,
      elpaBuild,
    }:
    elpaBuild {
      pname = "tuareg";
      version = "3.0.1";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/tuareg-3.0.1.tar";
        sha256 = "04lb71cafg4bqicx3q3rb9jpxbq6hmdrzw88f52sjqxq5c4cqdkj";
      };

      ename = "tuareg";
      packageRequires = [ caml ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/tuareg.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  typescript-mode = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "typescript-mode";
      version = "0.4";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/typescript-mode-0.4.tar";
        sha256 = "1fs369h8ysrx1d8qzvz75izmlx4gzl619g7yjp9ck2wjv50wx95q";
      };

      ename = "typescript-mode";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/typescript-mode.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  typst-ts-mode = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "typst-ts-mode";
      version = "0.12.2";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/typst-ts-mode-0.12.2.tar";
        sha256 = "170q09ma08cksyg9bapfhid28f0xi46ssdv7bzdyiy3gc4x61i4b";
      };

      ename = "typst-ts-mode";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/typst-ts-mode.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  ujelly-theme = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "ujelly-theme";
      version = "1.3.6";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/ujelly-theme-1.3.6.tar";
        sha256 = "19z3nf8avsipyywwlr77sy1bmf6gx5kk3fyph6nn4sn5vhcmgg0p";
      };

      ename = "ujelly-theme";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/ujelly-theme.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  undo-fu = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "undo-fu";
      version = "0.5";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/undo-fu-0.5.tar";
        sha256 = "00pgvmks1nvdimsac534qny5vpq8sgcfgybiz3ck3mgfklj4kshj";
      };

      ename = "undo-fu";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/undo-fu.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  undo-fu-session = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "undo-fu-session";
      version = "0.8";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/undo-fu-session-0.8.tar";
        sha256 = "1l69q4g5f9dza0npw9sp2y398q142xzpfgrmhl3aa2fjq49d4bcf";
      };

      ename = "undo-fu-session";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/undo-fu-session.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  vc-fossil = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "vc-fossil";
      version = "20230504";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/vc-fossil-20230504.tar";
        sha256 = "1q78xcfzpvvrlr9b9yh57asrlks2n0nhxhxl8dyfwad6gm0yr948";
      };

      ename = "vc-fossil";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/vc-fossil.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  vcomplete = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "vcomplete";
      version = "2.0";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/vcomplete-2.0.tar";
        sha256 = "03f60ncrf994pc4q15m0p2admmy4gpg5c51nbr3xycqp16pq8dz1";
      };

      ename = "vcomplete";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/vcomplete.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  visual-fill-column = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "visual-fill-column";
      version = "2.7.1";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/visual-fill-column-2.7.1.tar";
        sha256 = "0c5vammsvj0cx343s9nncdmcrpbaqiwk276clqkib594g74rjnmd";
      };

      ename = "visual-fill-column";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/visual-fill-column.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  vm = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      vcard,
    }:
    elpaBuild {
      pname = "vm";
      version = "8.3.2";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/vm-8.3.2.tar";
        sha256 = "0s2l4sjzgq4mm82dq6856wncsdvwsgk569i2rybbcsbw6v4hyvwv";
      };

      ename = "vm";
      packageRequires = [ vcard ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/vm.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  web-mode = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "web-mode";
      version = "17.3.24";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/web-mode-17.3.24.tar";
        sha256 = "129hz6h2ygmqhn3bbjxx2gpdnvh0gifc4xaipsjz0716rj1s0k81";
      };

      ename = "web-mode";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/web-mode.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  webpaste = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      request,
      cl-lib ? null,
    }:
    elpaBuild {
      pname = "webpaste";
      version = "3.2.2";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/webpaste-3.2.2.tar";
        sha256 = "04156iwgbc49l3b6s5vzbffw1xrkansvczi6q29d5waxwi6a2nfc";
      };

      ename = "webpaste";

      packageRequires = [
        cl-lib
        request
      ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/webpaste.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  wfnames = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "wfnames";
      version = "1.2";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/wfnames-1.2.tar";
        sha256 = "1yy034fx86wn6yv4671fybc4zn5g619zcnnfvryq6zpwibj6fikz";
      };

      ename = "wfnames";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/wfnames.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  wgrep = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "wgrep";
      version = "3.0.0";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/wgrep-3.0.0.tar";
        sha256 = "18j94y6xrjdmy5sk83mh5zaz4vqpi97pcjila387c0d84j1v2wzz";
      };

      ename = "wgrep";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/wgrep.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  why-this = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "why-this";
      version = "2.0.4";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/why-this-2.0.4.tar";
        sha256 = "1swidi6z6rhhy2zvas84vmkj41zaqpdxfssg6x6lvzzq34cgq0ph";
      };

      ename = "why-this";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/why-this.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  with-editor = callPackage (
    {
      lib,
      fetchurl,
      compat,
      cond-let,
      elpaBuild,
    }:
    elpaBuild {
      pname = "with-editor";
      version = "3.5.1";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/with-editor-3.5.1.tar";
        sha256 = "0p19n8kx9gkj87pr8rlac8b9vlrb57w7k5b62fx9dwx2m54dixh9";
      };

      ename = "with-editor";

      packageRequires = [
        compat
        cond-let
      ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/with-editor.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  with-simulated-input = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "with-simulated-input";
      version = "3.0";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/with-simulated-input-3.0.tar";
        sha256 = "0a2kqrv3q399n1y21v7m4c9ivm56j28kasb466rq704jccvzblfr";
      };

      ename = "with-simulated-input";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/with-simulated-input.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  workroom = callPackage (
    {
      lib,
      fetchurl,
      compat,
      elpaBuild,
      project,
    }:
    elpaBuild {
      pname = "workroom";
      version = "2.3.1";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/workroom-2.3.1.tar";
        sha256 = "0k0npmcs3cdkfds0r8p0gm8xa42bzdjiciilh65jka15fqknx486";
      };

      ename = "workroom";

      packageRequires = [
        compat
        project
      ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/workroom.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  writegood-mode = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "writegood-mode";
      version = "2.2.0";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/writegood-mode-2.2.0.tar";
        sha256 = "00phrzbd03gzc5y2ybizyp9smd6ybmmx2j7jf6hg5cmfyjmq8ahw";
      };

      ename = "writegood-mode";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/writegood-mode.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  ws-butler = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "ws-butler";
      version = "1.3";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/ws-butler-1.3.tar";
        sha256 = "14q19rvps5jcshyls3aa55pxmqbbkhhbdlchnl7ybxwkvvmig9zh";
      };

      ename = "ws-butler";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/ws-butler.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  xah-fly-keys = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "xah-fly-keys";
      version = "28.11.20260416140940";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/xah-fly-keys-28.11.20260416140940.tar";
        sha256 = "0zzdwrd4h12bqlxzpj7xs4m5cdgx9nbljrnyld6qs5b19352izyl";
      };

      ename = "xah-fly-keys";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/xah-fly-keys.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  xkcd = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      json ? null,
    }:
    elpaBuild {
      pname = "xkcd";
      version = "1.1";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/xkcd-1.1.tar";
        sha256 = "1qs4jv6h2i8g7s214xr4s6jgykdbac4lfc5hd0gmylkwlvs3pzcp";
      };

      ename = "xkcd";
      packageRequires = [ json ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/xkcd.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  xml-rpc = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "xml-rpc";
      version = "1.6.17";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/xml-rpc-1.6.17.tar";
        sha256 = "1r8j87xddv80dx6lxzr2kq6czwk2l22bfxmplnma9fc2bsf1k2wy";
      };

      ename = "xml-rpc";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/xml-rpc.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  yaml-mode = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "yaml-mode";
      version = "0.0.16";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/yaml-mode-0.0.16.tar";
        sha256 = "0bhflv50z379p6ysdq89bdszkxp8zdmlb8plj1bm2nqsgc39hdm7";
      };

      ename = "yaml-mode";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/yaml-mode.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  yasnippet-snippets = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      yasnippet,
    }:
    elpaBuild {
      pname = "yasnippet-snippets";
      version = "1.0";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/yasnippet-snippets-1.0.tar";
        sha256 = "0si61d0niabh18vbgdz6w5zirpxpp7c4mrcn5x1n3r5vnhv3n7m2";
      };

      ename = "yasnippet-snippets";
      packageRequires = [ yasnippet ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/yasnippet-snippets.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  zenburn-theme = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "zenburn-theme";
      version = "2.10.0";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/zenburn-theme-2.10.0.tar";
        sha256 = "0h1qd1xay2ci51y3vdq480afbx6hq40ywplsh76m85mr199pf751";
      };

      ename = "zenburn-theme";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/zenburn-theme.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  zig-mode = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      reformatter,
    }:
    elpaBuild {
      pname = "zig-mode";
      version = "0.0.8";

      src = fetchurl {
        url = "https://elpa.nongnu.org/nongnu/zig-mode-0.0.8.tar";
        sha256 = "1085lxm6k7b91c0q8jmmir59hzaqi8jgspbs89bvia2vq5x9xd87";
      };

      ename = "zig-mode";
      packageRequires = [ reformatter ];

      meta = {
        homepage = "https://elpa.nongnu.org/nongnu/zig-mode.html";
        license = lib.licenses.free;
      };
    }
  ) { };
}
