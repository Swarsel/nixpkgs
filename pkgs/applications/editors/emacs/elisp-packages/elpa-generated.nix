{ callPackage }:
{
  a68-mode = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "a68-mode";
      version = "1.3";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/a68-mode-1.3.tar";
        sha256 = "0x5jj95bk07wnl9aqf35hcm9ajdwbrg74xm90i5kfn6nrxmnjmyp";
      };

      ename = "a68-mode";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/a68-mode.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  ace-window = callPackage (
    {
      lib,
      fetchurl,
      avy,
      elpaBuild,
    }:
    elpaBuild {
      pname = "ace-window";
      version = "0.10.0";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/ace-window-0.10.0.tar";
        sha256 = "1sdzk1hgi3axqqbxf6aq1v5j3d8bybkz40dk8zqn49xxxfmzbdv4";
      };

      ename = "ace-window";
      packageRequires = [ avy ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/ace-window.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  ack = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "ack";
      version = "1.11";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/ack-1.11.tar";
        sha256 = "1ji02v3qis5sx7hpaaxksgh2jqxzzilagz6z33kjb1lds1sq4z2c";
      };

      ename = "ack";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/ack.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  activities = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      persist,
    }:
    elpaBuild {
      pname = "activities";
      version = "0.7.2";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/activities-0.7.2.tar";
        sha256 = "1b6d77b5h2vikfxqjlb1jx5pnij5bif788nysvvn3wlzpwdi88s0";
      };

      ename = "activities";
      packageRequires = [ persist ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/activities.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  ada-mode = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      gnat-compiler,
      uniquify-files,
      wisi,
    }:
    elpaBuild {
      pname = "ada-mode";
      version = "8.1.0";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/ada-mode-8.1.0.tar";
        sha256 = "10k514al716qjx3qg1m4k1rnf70fa73vrmmx3pp75zrw1d0db9y6";
      };

      ename = "ada-mode";

      packageRequires = [
        gnat-compiler
        uniquify-files
        wisi
      ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/ada-mode.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  ada-ref-man = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "ada-ref-man";
      version = "2020.1";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/ada-ref-man-2020.1.tar";
        sha256 = "0ijgl9lnmn8n3pllgh3apl2shbl38f3fxn8z5yy4q6pqqx0vr3fn";
      };

      ename = "ada-ref-man";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/ada-ref-man.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  adaptive-wrap = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "adaptive-wrap";
      version = "0.9";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/adaptive-wrap-0.9.tar";
        sha256 = "1i1g14h6yyq6fswyb3wf0y9zna0icp64484x7qd6wdqj438r87va";
      };

      ename = "adaptive-wrap";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/adaptive-wrap.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  adjust-parens = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "adjust-parens";
      version = "3.2";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/adjust-parens-3.2.tar";
        sha256 = "1gdlykg7ix3833s40152p1ji4r1ycp18niqjr1f994y4ydqxq8yl";
      };

      ename = "adjust-parens";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/adjust-parens.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  advice-patch = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "advice-patch";
      version = "0.1";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/advice-patch-0.1.tar";
        sha256 = "0km891648k257k4d6hbrv6jyz9663kww8gfarvzf9lv8i4qa5scp";
      };

      ename = "advice-patch";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/advice-patch.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  aggressive-completion = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "aggressive-completion";
      version = "1.8";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/aggressive-completion-1.8.tar";
        sha256 = "07dqw6mvb1vp4fmii1y7wc074xxi9wfwalflszjpzcjbalklcqdq";
      };

      ename = "aggressive-completion";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/aggressive-completion.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  aggressive-indent = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "aggressive-indent";
      version = "1.10.0";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/aggressive-indent-1.10.0.tar";
        sha256 = "1c27g9qhqc4bh96bkxdcjbrhiwi7kzki1l4yhxvyvwwarisl6c7b";
      };

      ename = "aggressive-indent";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/aggressive-indent.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  ahungry-theme = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "ahungry-theme";
      version = "1.10.0";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/ahungry-theme-1.10.0.tar";
        sha256 = "16k6wm1qss5bk45askhq5vswrqsjic5dijpkgnmwgvm8xsdlvni6";
      };

      ename = "ahungry-theme";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/ahungry-theme.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  aircon-theme = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "aircon-theme";
      version = "0.0.6";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/aircon-theme-0.0.6.tar";
        sha256 = "0dcnlk3q95bcghlwj8ii40xxhspnfbqcr9mvj1v3adl1s623fyp0";
      };

      ename = "aircon-theme";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/aircon-theme.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  all = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "all";
      version = "1.1";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/all-1.1.tar";
        sha256 = "067c5ynklw1inbjwd1l6dkbpx3vw487qv39y7mdl55a6nqx7hgk4";
      };

      ename = "all";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/all.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  altcaps = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "altcaps";
      version = "1.3.0";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/altcaps-1.3.0.tar";
        sha256 = "1q75hnx9pc65r069dg1m0r88b40q58p509m13v0mykbpfsinncag";
      };

      ename = "altcaps";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/altcaps.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  ampc = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "ampc";
      version = "0.2";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/ampc-0.2.tar";
        sha256 = "17l2c5hr7cq0vf4qc8s2adwlhqp74glc4v909h0jcavrnbn8yn80";
      };

      ename = "ampc";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/ampc.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  arbitools = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      cl-lib ? null,
    }:
    elpaBuild {
      pname = "arbitools";
      version = "0.977";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/arbitools-0.977.tar";
        sha256 = "0s5dpprx24fxm0qk8nzm39c16ydiq97wzz3l7zi69r3l9wf31rb3";
      };

      ename = "arbitools";
      packageRequires = [ cl-lib ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/arbitools.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  ascii-art-to-unicode = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "ascii-art-to-unicode";
      version = "1.13";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/ascii-art-to-unicode-1.13.tar";
        sha256 = "0qlh8zi691gz7s1ayp1x5ga3sj3rfy79y21r6hqf696mrkgpz1d8";
      };

      ename = "ascii-art-to-unicode";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/ascii-art-to-unicode.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  assess = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      m-buffer,
    }:
    elpaBuild {
      pname = "assess";
      version = "0.7";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/assess-0.7.tar";
        sha256 = "1wka2idr63bn8fgh0cz4lf21jvlhkr895y0xnh3syp9vrss5hzsp";
      };

      ename = "assess";
      packageRequires = [ m-buffer ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/assess.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  async = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "async";
      version = "1.9.9";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/async-1.9.9.tar";
        sha256 = "00slbyzjjn2v90lkaa9kc3wvlibs0rldh9crzjgp43y31xrzgpsg";
      };

      ename = "async";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/async.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  auctex = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "auctex";
      version = "14.1.2";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/auctex-14.1.2.tar";
        sha256 = "0dp95siam576ji9ccznd7abclrxv14xbcmbkqaawf73q2rmfjwip";
      };

      ename = "auctex";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/auctex.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  auctex-cont-latexmk = callPackage (
    {
      lib,
      fetchurl,
      auctex,
      elpaBuild,
    }:
    elpaBuild {
      pname = "auctex-cont-latexmk";
      version = "0.3";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/auctex-cont-latexmk-0.3.tar";
        sha256 = "1s1fp8cajwcsvrnvbhnlzfsphpflsv6fzmc624578sz2m0p1wg6n";
      };

      ename = "auctex-cont-latexmk";
      packageRequires = [ auctex ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/auctex-cont-latexmk.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  auctex-label-numbers = callPackage (
    {
      lib,
      fetchurl,
      auctex,
      elpaBuild,
    }:
    elpaBuild {
      pname = "auctex-label-numbers";
      version = "0.2";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/auctex-label-numbers-0.2.tar";
        sha256 = "1cd68yvpm061r9k4x6rvy3g2wdynv5gbjg2dyp06nkrgvakdb00x";
      };

      ename = "auctex-label-numbers";
      packageRequires = [ auctex ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/auctex-label-numbers.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  aumix-mode = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "aumix-mode";
      version = "7";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/aumix-mode-7.tar";
        sha256 = "08baz31hm0nhikqg5h294kg5m4qkiayjhirhb57v57g5722jfk3m";
      };

      ename = "aumix-mode";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/aumix-mode.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  auth-source-xoauth2-plugin = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      oauth2,
    }:
    elpaBuild {
      pname = "auth-source-xoauth2-plugin";
      version = "0.4.1";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/auth-source-xoauth2-plugin-0.4.1.tar";
        sha256 = "038wikkg4lmgjjnwkliwwx8iif55vlc6720qz55lkr7pkrzp5vas";
      };

      ename = "auth-source-xoauth2-plugin";
      packageRequires = [ oauth2 ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/auth-source-xoauth2-plugin.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  auto-correct = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "auto-correct";
      version = "1.1.4";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/auto-correct-1.1.4.tar";
        sha256 = "05ky3qxbvxrkywpqj6syl7ll6za74fhjzrcia6wdmxsnjya5qbf1";
      };

      ename = "auto-correct";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/auto-correct.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  auto-overlays = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      cl-lib ? null,
    }:
    elpaBuild {
      pname = "auto-overlays";
      version = "0.10.10";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/auto-overlays-0.10.10.tar";
        sha256 = "0jn7lk8vzdrf0flxwwx295z0mrghd3lyspfadwz35c6kygvy8078";
      };

      ename = "auto-overlays";
      packageRequires = [ cl-lib ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/auto-overlays.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  autocrypt = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "autocrypt";
      version = "0.4.2";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/autocrypt-0.4.2.tar";
        sha256 = "0mc4vb6x7qzn29dg9m05zgli6mwh9cj4vc5n6hvarzkn9lxl6mr3";
      };

      ename = "autocrypt";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/autocrypt.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  autorevert-tail-truncate = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "autorevert-tail-truncate";
      version = "1.0.1";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/autorevert-tail-truncate-1.0.1.tar";
        sha256 = "1g7bqd617vmanjf3s1c4adsj5zhvsxrzib2pkj508fs5hbyyi1wi";
      };

      ename = "autorevert-tail-truncate";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/autorevert-tail-truncate.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  avy = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      cl-lib ? null,
    }:
    elpaBuild {
      pname = "avy";
      version = "0.5.0";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/avy-0.5.0.tar";
        sha256 = "1xfcml38qmrwdd0rkhwrvv2s7dbznwhk3vy9pjd6ljpg22wkb80d";
      };

      ename = "avy";
      packageRequires = [ cl-lib ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/avy.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  bbdb = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      cl-lib ? null,
    }:
    elpaBuild {
      pname = "bbdb";
      version = "3.2.2.4";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/bbdb-3.2.2.4.tar";
        sha256 = "1ymjydf54z3rbkxk4irvan5s8lc8wdhk01691741vfznx0nsc4a2";
      };

      ename = "bbdb";
      packageRequires = [ cl-lib ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/bbdb.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  beacon = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "beacon";
      version = "1.3.4";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/beacon-1.3.4.tar";
        sha256 = "1hxb6vyvpppj7yzphknmh8m4a1h89lg6jr98g4d62k0laxazvdza";
      };

      ename = "beacon";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/beacon.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  beframe = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "beframe";
      version = "1.5.0";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/beframe-1.5.0.tar";
        sha256 = "0cx7jxlfzqaldswnk2wg5z4zb7lv24x5by9h20y4vpf973nclj0r";
      };

      ename = "beframe";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/beframe.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  bicep-ts-mode = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "bicep-ts-mode";
      version = "0.1.4";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/bicep-ts-mode-0.1.4.tar";
        sha256 = "0jf6zbmmwyjrl6wrcc99ahbv0xqbfr9zdzayi7racbflsyflxnb7";
      };

      ename = "bicep-ts-mode";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/bicep-ts-mode.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  bind-key = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "bind-key";
      version = "2.4.1";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/bind-key-2.4.1.tar";
        sha256 = "0jrbm2l6h4r7qjcdcsfczbijmbf3njzzzrymv08zanchmy7lvsv2";
      };

      ename = "bind-key";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/bind-key.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  blist = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      ilist,
    }:
    elpaBuild {
      pname = "blist";
      version = "0.6";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/blist-0.6.tar";
        sha256 = "1r7pnbz4vdwbnga271d03i5dy1hvnxbf17q5bcrn05vwxlf8g83m";
      };

      ename = "blist";
      packageRequires = [ ilist ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/blist.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  bluetooth = callPackage (
    {
      lib,
      fetchurl,
      compat,
      dash,
      elpaBuild,
      transient,
    }:
    elpaBuild {
      pname = "bluetooth";
      version = "0.4.1";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/bluetooth-0.4.1.tar";
        sha256 = "1chi9xjg5zcg6qycn2n442adhhmip1vpvg12szf1raq3zhg7lr01";
      };

      ename = "bluetooth";

      packageRequires = [
        compat
        dash
        transient
      ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/bluetooth.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  bnf-mode = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      cl-lib ? null,
    }:
    elpaBuild {
      pname = "bnf-mode";
      version = "0.4.5";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/bnf-mode-0.4.5.tar";
        sha256 = "1x6km8rhhb5bkas3yfmjfpyxlhyxkqnzviw1pqlq88c95j88h3d4";
      };

      ename = "bnf-mode";
      packageRequires = [ cl-lib ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/bnf-mode.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  boxy = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "boxy";
      version = "2.0.1";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/boxy-2.0.1.tar";
        sha256 = "02hn7n5l74gwj6jqqhr3jpwrcxmky1qc6qgvzbb7mw0v135p6vdj";
      };

      ename = "boxy";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/boxy.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  boxy-headings = callPackage (
    {
      lib,
      fetchurl,
      boxy,
      elpaBuild,
      org,
    }:
    elpaBuild {
      pname = "boxy-headings";
      version = "2.1.11";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/boxy-headings-2.1.11.tar";
        sha256 = "1jxfmpgvk0hw44r3q2c3wapbv0iwjc9s956qhcyw9dxvnjfbqf3d";
      };

      ename = "boxy-headings";

      packageRequires = [
        boxy
        org
      ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/boxy-headings.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  breadcrumb = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      project,
    }:
    elpaBuild {
      pname = "breadcrumb";
      version = "1.0.1";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/breadcrumb-1.0.1.tar";
        sha256 = "1s69a2z183mla4d4b5pcsswbwa3hjvsg1xj7r3hdw6j841b0l9dw";
      };

      ename = "breadcrumb";
      packageRequires = [ project ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/breadcrumb.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  brief = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      nadvice,
      cl-lib ? null,
    }:
    elpaBuild {
      pname = "brief";
      version = "5.92";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/brief-5.92.tar";
        sha256 = "0nfnk5aag5w7170njdl9gq2kf48gzmbmdpz209y1vzdxw91jrwql";
      };

      ename = "brief";

      packageRequires = [
        cl-lib
        nadvice
      ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/brief.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  buffer-env = callPackage (
    {
      lib,
      fetchurl,
      compat,
      elpaBuild,
    }:
    elpaBuild {
      pname = "buffer-env";
      version = "0.6";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/buffer-env-0.6.tar";
        sha256 = "08qaw4y1sszhh97ih13vfrm0r1nn1k410f2wwvffvncxhqgxz5lv";
      };

      ename = "buffer-env";
      packageRequires = [ compat ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/buffer-env.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  buffer-expose = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      cl-lib ? null,
    }:
    elpaBuild {
      pname = "buffer-expose";
      version = "0.4.3";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/buffer-expose-0.4.3.tar";
        sha256 = "1ymjjjrbknp3hdfwd8zyzfrsn5n267245ffmplm7yk2s34kgxr0n";
      };

      ename = "buffer-expose";
      packageRequires = [ cl-lib ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/buffer-expose.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  bufferlo = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "bufferlo";
      version = "1.2";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/bufferlo-1.2.tar";
        sha256 = "0144bvgi63cvh7fcqdiz3zy0nncj8jslxd3x9jaw7m4pwadvaqvq";
      };

      ename = "bufferlo";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/bufferlo.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  buframe = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      timeout,
    }:
    elpaBuild {
      pname = "buframe";
      version = "0.3";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/buframe-0.3.tar";
        sha256 = "1lhbs13f1kky4f7ylfl4ki7gqi51x2rgmipmwx3w9b8hx8d8s6h1";
      };

      ename = "buframe";
      packageRequires = [ timeout ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/buframe.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  bug-hunter = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      seq,
      cl-lib ? null,
    }:
    elpaBuild {
      pname = "bug-hunter";
      version = "1.3.1";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/bug-hunter-1.3.1.tar";
        sha256 = "0cgwq8b6jglbg9ydvf80ijgbbccrks3yb9af46sdd6aqdmvdlx21";
      };

      ename = "bug-hunter";

      packageRequires = [
        cl-lib
        seq
      ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/bug-hunter.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  buildbot = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "buildbot";
      version = "0.0.1";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/buildbot-0.0.1.tar";
        sha256 = "056jakpyslizsp8sik5f7m90dpcga8y38hb5rh1yfa7k1xwcrrk2";
      };

      ename = "buildbot";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/buildbot.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  calibre = callPackage (
    {
      lib,
      fetchurl,
      compat,
      elpaBuild,
    }:
    elpaBuild {
      pname = "calibre";
      version = "1.5.2";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/calibre-1.5.2.tar";
        sha256 = "0iqgd44wca54l5rn8g6c9qak2c1wblbnrx5a0118hkgckimp8c3k";
      };

      ename = "calibre";
      packageRequires = [ compat ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/calibre.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  cape = callPackage (
    {
      lib,
      fetchurl,
      compat,
      elpaBuild,
    }:
    elpaBuild {
      pname = "cape";
      version = "2.7";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/cape-2.7.tar";
        sha256 = "0543x1j4pakdqm8vba0450yl9b30z527dx8x84mzjqkhksn40pzv";
      };

      ename = "cape";
      packageRequires = [ compat ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/cape.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  capf-autosuggest = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "capf-autosuggest";
      version = "0.3";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/capf-autosuggest-0.3.tar";
        sha256 = "18cwiv227m8y1xqvsnjrzgd6f6kvvih742h8y38pphljssl109fk";
      };

      ename = "capf-autosuggest";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/capf-autosuggest.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  caps-lock = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "caps-lock";
      version = "1.0";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/caps-lock-1.0.tar";
        sha256 = "1yy4kjc1zlpzkam0jj8h3v5h23wyv1yfvwj2drknn59d8amc1h4y";
      };

      ename = "caps-lock";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/caps-lock.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  captain = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "captain";
      version = "1.0.3";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/captain-1.0.3.tar";
        sha256 = "0l8z8bqk705jdl7gvd2x7nhs0z6gn3swk5yzp3mnhjcfda6whz8l";
      };

      ename = "captain";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/captain.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  chess = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      cl-lib ? null,
    }:
    elpaBuild {
      pname = "chess";
      version = "2.0.5";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/chess-2.0.5.tar";
        sha256 = "0dgmp7ymjyb5pa93n05s0d4ql7wk98r9s4f9w35yahgqk9xvqclj";
      };

      ename = "chess";
      packageRequires = [ cl-lib ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/chess.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  cl-generic = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "cl-generic";
      version = "0.3";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/cl-generic-0.3.tar";
        sha256 = "0dqn484xb25ifiqd9hqdrs954c74akrf95llx23b2kzf051pqh1k";
      };

      ename = "cl-generic";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/cl-generic.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  cl-lib = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "cl-lib";
      version = "0.7.1";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/cl-lib-0.7.1.tar";
        sha256 = "1wpdg2zwhzxv4bkx9ldiwd16l6244wakv8yphrws4mnymkxvf2q1";
      };

      ename = "cl-lib";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/cl-lib.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  clipboard-collector = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "clipboard-collector";
      version = "0.3";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/clipboard-collector-0.3.tar";
        sha256 = "0v70f9pljq3jar3d1vpaj48nhrg90jzsvqcbzgv54989w8rvvcd6";
      };

      ename = "clipboard-collector";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/clipboard-collector.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  cm-mode = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      cl-lib ? null,
    }:
    elpaBuild {
      pname = "cm-mode";
      version = "1.10";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/cm-mode-1.10.tar";
        sha256 = "1lg9rzv9hk89qi43msrbmi1hyy8zgr75740h7kj7rbl41v808bd7";
      };

      ename = "cm-mode";
      packageRequires = [ cl-lib ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/cm-mode.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  cobol-mode = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      cl-lib ? null,
    }:
    elpaBuild {
      pname = "cobol-mode";
      version = "1.1";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/cobol-mode-1.1.tar";
        sha256 = "0aicx6vvhgn0fvikbq74vnvvwh228pxdqf52sbiffhzgb7pkbvcj";
      };

      ename = "cobol-mode";
      packageRequires = [ cl-lib ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/cobol-mode.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  code-cells = callPackage (
    {
      lib,
      fetchurl,
      compat,
      elpaBuild,
    }:
    elpaBuild {
      pname = "code-cells";
      version = "0.5";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/code-cells-0.5.tar";
        sha256 = "04fvn0lwvnvf907k13822jpxyyi6cf55v543i9iqy57dav6sn2jx";
      };

      ename = "code-cells";
      packageRequires = [ compat ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/code-cells.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  colorful-mode = callPackage (
    {
      lib,
      fetchurl,
      compat,
      elpaBuild,
    }:
    elpaBuild {
      pname = "colorful-mode";
      version = "1.2.5";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/colorful-mode-1.2.5.tar";
        sha256 = "1vz4mr76y9j5z8zg4nkm8ll38ka46yfhvv7c5r9v70gvnr1glg2g";
      };

      ename = "colorful-mode";
      packageRequires = [ compat ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/colorful-mode.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  comint-mime = callPackage (
    {
      lib,
      fetchurl,
      compat,
      elpaBuild,
      mathjax,
    }:
    elpaBuild {
      pname = "comint-mime";
      version = "0.7";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/comint-mime-0.7.tar";
        sha256 = "1scf7b72kzqcf51svww3rbamdnm607pvzg04rdcglc2cna1n2apa";
      };

      ename = "comint-mime";

      packageRequires = [
        compat
        mathjax
      ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/comint-mime.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  compact-docstrings = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "compact-docstrings";
      version = "0.2";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/compact-docstrings-0.2.tar";
        sha256 = "00fjhfysjyqigkg0icxlqw6imzhjk5xhlxmxxs1jiafhn55dbcpj";
      };

      ename = "compact-docstrings";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/compact-docstrings.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  company = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "company";
      version = "1.0.2";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/company-1.0.2.tar";
        sha256 = "00vmqra0fav0w4q13ngwpyqpxqah0ahfg7kp5l2nd0h2l8sp79qr";
      };

      ename = "company";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/company.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  company-ebdb = callPackage (
    {
      lib,
      fetchurl,
      company,
      ebdb,
      elpaBuild,
    }:
    elpaBuild {
      pname = "company-ebdb";
      version = "1.1";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/company-ebdb-1.1.tar";
        sha256 = "1ym0r7y90n4d6grd4l02rxk096gsjmw9j81slig0pq1ky33rb6ks";
      };

      ename = "company-ebdb";

      packageRequires = [
        company
        ebdb
      ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/company-ebdb.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  company-math = callPackage (
    {
      lib,
      fetchurl,
      company,
      elpaBuild,
      math-symbol-lists,
    }:
    elpaBuild {
      pname = "company-math";
      version = "1.5.1";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/company-math-1.5.1.tar";
        sha256 = "16ya3yscxxmz9agi0nc5pi43wkfv45lh1zd89yqfc7zcw02nsnld";
      };

      ename = "company-math";

      packageRequires = [
        company
        math-symbol-lists
      ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/company-math.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  company-statistics = callPackage (
    {
      lib,
      fetchurl,
      company,
      elpaBuild,
    }:
    elpaBuild {
      pname = "company-statistics";
      version = "0.2.3";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/company-statistics-0.2.3.tar";
        sha256 = "1gfwhgv7q9d3xjgaim25diyd6jfl9w3j07qrssphcrdxv0q24d14";
      };

      ename = "company-statistics";
      packageRequires = [ company ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/company-statistics.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  compat = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "compat";
      version = "31.0.0.1";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/compat-31.0.0.1.tar";
        sha256 = "1lraq5i8jk0wsrnkv66q6lxv314fm8c09hrfvm0gj2lpn8126f20";
      };

      ename = "compat";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/compat.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  cond-star = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "cond-star";
      version = "1.0";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/cond-star-1.0.tar";
        sha256 = "1r8wfb7g6dknpnqvsszrcdpc695srk0f8s85zi0d93k1iyl3yi2q";
      };

      ename = "cond-star";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/cond-star.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  constants = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "constants";
      version = "2.11.1";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/constants-2.11.1.tar";
        sha256 = "0n1wa9hr0841733s6w30x1n5mmis8fpjfzl5mn7s9q12djpp20fy";
      };

      ename = "constants";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/constants.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  consult = callPackage (
    {
      lib,
      fetchurl,
      compat,
      elpaBuild,
    }:
    elpaBuild {
      pname = "consult";
      version = "3.6";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/consult-3.6.tar";
        sha256 = "0c8pp537qv2zxkzk0nlrvzbn1v72v9ddhwf1nks3hwvwrff58db8";
      };

      ename = "consult";
      packageRequires = [ compat ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/consult.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  consult-denote = callPackage (
    {
      lib,
      fetchurl,
      consult,
      denote,
      elpaBuild,
    }:
    elpaBuild {
      pname = "consult-denote";
      version = "0.5.0";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/consult-denote-0.5.0.tar";
        sha256 = "1qmfwmm4hi0z2lqn6ryfwckrivrlvy16y42w729q6pk0nd21j48k";
      };

      ename = "consult-denote";

      packageRequires = [
        consult
        denote
      ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/consult-denote.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  consult-hoogle = callPackage (
    {
      lib,
      fetchurl,
      consult,
      elpaBuild,
    }:
    elpaBuild {
      pname = "consult-hoogle";
      version = "0.7.0";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/consult-hoogle-0.7.0.tar";
        sha256 = "17slksxs1vx19djf5q772hwq1fpaqsd0xpbh6zrrvvgv18h2ac8l";
      };

      ename = "consult-hoogle";
      packageRequires = [ consult ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/consult-hoogle.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  consult-recoll = callPackage (
    {
      lib,
      fetchurl,
      consult,
      elpaBuild,
    }:
    elpaBuild {
      pname = "consult-recoll";
      version = "1.0.0";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/consult-recoll-1.0.0.tar";
        sha256 = "1fjc5s1xn15vglmaqywnrpqnjb46w15xysk7n18ifqapcya5g0x0";
      };

      ename = "consult-recoll";
      packageRequires = [ consult ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/consult-recoll.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  context-coloring = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "context-coloring";
      version = "8.1.0";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/context-coloring-8.1.0.tar";
        sha256 = "0mqdl34g493pps85ckin5i3iz8kwlqkcwjvsf2sj4nldjvvfk1ng";
      };

      ename = "context-coloring";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/context-coloring.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  corfu = callPackage (
    {
      lib,
      fetchurl,
      compat,
      elpaBuild,
    }:
    elpaBuild {
      pname = "corfu";
      version = "2.10";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/corfu-2.10.tar";
        sha256 = "0wp9jr1l81si8p1rxa5dkkwbx6k77rs0629q2lxk1l8lnb0j7h6n";
      };

      ename = "corfu";
      packageRequires = [ compat ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/corfu.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  coterm = callPackage (
    {
      lib,
      fetchurl,
      compat,
      elpaBuild,
    }:
    elpaBuild {
      pname = "coterm";
      version = "1.6";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/coterm-1.6.tar";
        sha256 = "0kgsg99dggirz6asyppwx1ydc0jh62xd1bfhnm2hyby5qkqz1yvk";
      };

      ename = "coterm";
      packageRequires = [ compat ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/coterm.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  counsel = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      ivy,
      swiper,
    }:
    elpaBuild {
      pname = "counsel";
      version = "0.15.1";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/counsel-0.15.1.tar";
        sha256 = "1sgaph2wb4mkxlfq6448i1kymaxhs7h37nrn7vzbp9fhik634rhc";
      };

      ename = "counsel";

      packageRequires = [
        ivy
        swiper
      ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/counsel.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  cpio-mode = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "cpio-mode";
      version = "0.17";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/cpio-mode-0.17.tar";
        sha256 = "13jay5c36svq2r78gwp7d1slpkkzrx749q28554mxd855fr6pvaj";
      };

      ename = "cpio-mode";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/cpio-mode.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  cpupower = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "cpupower";
      version = "1.0.5";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/cpupower-1.0.5.tar";
        sha256 = "155fhf38p95a5ws6jzpczw0z03zwbsqzdwj50v3grjivyp74pddz";
      };

      ename = "cpupower";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/cpupower.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  crdt = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "crdt";
      version = "0.3.5";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/crdt-0.3.5.tar";
        sha256 = "038qivbw02h1i98ym0fwx72x05gm0j4h93a54v1l7g25drm5zm83";
      };

      ename = "crdt";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/crdt.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  crisp = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "crisp";
      version = "1.3.6";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/crisp-1.3.6.tar";
        sha256 = "0am7gwadjp0nwlvf7y4sp9brbm0234k55bnxfv44lkwdf502mq8y";
      };

      ename = "crisp";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/crisp.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  csharp-mode = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "csharp-mode";
      version = "2.0.0";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/csharp-mode-2.0.0.tar";
        sha256 = "1jjxq5vkqq2v8rkcm2ygggpg355aqmrl2hdhh1xma3jlnj5carnf";
      };

      ename = "csharp-mode";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/csharp-mode.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  csv-mode = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      cl-lib ? null,
    }:
    elpaBuild {
      pname = "csv-mode";
      version = "1.27";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/csv-mode-1.27.tar";
        sha256 = "0jxf4id5c9696nh666x0xbzqx3vskyv810km61y9nkg7sp4ln2qf";
      };

      ename = "csv-mode";
      packageRequires = [ cl-lib ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/csv-mode.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  cursor-undo = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "cursor-undo";
      version = "1.1.5";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/cursor-undo-1.1.5.tar";
        sha256 = "1zbn4wfirnwjhy4q0lz8s0zffp84v6zs1x6wjxlcr0la7xn2sx4v";
      };

      ename = "cursor-undo";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/cursor-undo.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  cursory = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "cursory";
      version = "1.2.0";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/cursory-1.2.0.tar";
        sha256 = "0019syaj02lxm4c4bdfqfq6g5izkgwwfgz82fj1grxk904kdi4fs";
      };

      ename = "cursory";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/cursory.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  cycle-quotes = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "cycle-quotes";
      version = "0.1";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/cycle-quotes-0.1.tar";
        sha256 = "1glf8sd3gqp9qbd238vxd3aprdz93f887893xji3ybqli36i2xs1";
      };

      ename = "cycle-quotes";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/cycle-quotes.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  dape = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      jsonrpc,
    }:
    elpaBuild {
      pname = "dape";
      version = "0.27.1";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/dape-0.27.1.tar";
        sha256 = "1na3080gaygw4fsaymjjx9jgh9ai5k7gb0jmlrkbqnmdypag3mb7";
      };

      ename = "dape";
      packageRequires = [ jsonrpc ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/dape.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  darkroom = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      cl-lib ? null,
    }:
    elpaBuild {
      pname = "darkroom";
      version = "0.3";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/darkroom-0.3.tar";
        sha256 = "0gxixkai8awc77vzckwljmyapdnxw5j9ajxmlr8rq42994gjr4fm";
      };

      ename = "darkroom";
      packageRequires = [ cl-lib ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/darkroom.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  dash = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "dash";
      version = "2.20.0";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/dash-2.20.0.tar";
        sha256 = "1ckcsfksvwcknbp39v5p4yyl5h6a8xz0iljx7wb20igq0l4lpy18";
      };

      ename = "dash";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/dash.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  dbus-codegen = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      cl-lib ? null,
    }:
    elpaBuild {
      pname = "dbus-codegen";
      version = "0.1";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/dbus-codegen-0.1.tar";
        sha256 = "0d3sbqs5r8578629inx8nhqvx0kshf41d00c8dpc75v4b2vx0h6w";
      };

      ename = "dbus-codegen";
      packageRequires = [ cl-lib ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/dbus-codegen.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  debbugs = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      soap-client,
    }:
    elpaBuild {
      pname = "debbugs";
      version = "0.46";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/debbugs-0.46.tar";
        sha256 = "100yshwnbk70yxah1hy0cqhva8qqh5i2pbqxi5a5j6cja2awdi38";
      };

      ename = "debbugs";
      packageRequires = [ soap-client ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/debbugs.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  delight = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      nadvice,
      cl-lib ? null,
    }:
    elpaBuild {
      pname = "delight";
      version = "1.7";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/delight-1.7.tar";
        sha256 = "1j7srr0i7s9hcny45m8zmj33nl9g6zi55cbkdzzlbx6si2rqwwlj";
      };

      ename = "delight";

      packageRequires = [
        cl-lib
        nadvice
      ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/delight.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  denote = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "denote";
      version = "4.2.3";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/denote-4.2.3.tar";
        sha256 = "0r5p2iy7wssm6hl4dal1sav5x4vvijq54lyzqabg49v6lsbszf74";
      };

      ename = "denote";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/denote.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  denote-journal = callPackage (
    {
      lib,
      fetchurl,
      denote,
      elpaBuild,
    }:
    elpaBuild {
      pname = "denote-journal";
      version = "0.3.0";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/denote-journal-0.3.0.tar";
        sha256 = "1l2zrr5nczxyqsmr73m93jqphp6s79f55grpahig0xj2kji8d6gk";
      };

      ename = "denote-journal";
      packageRequires = [ denote ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/denote-journal.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  denote-markdown = callPackage (
    {
      lib,
      fetchurl,
      denote,
      elpaBuild,
    }:
    elpaBuild {
      pname = "denote-markdown";
      version = "0.3.0";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/denote-markdown-0.3.0.tar";
        sha256 = "0adg2nr8s8rjynrpj0b37ni4jcm1igvls3zyyr313xifnrbiznym";
      };

      ename = "denote-markdown";
      packageRequires = [ denote ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/denote-markdown.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  denote-menu = callPackage (
    {
      lib,
      fetchurl,
      denote,
      elpaBuild,
    }:
    elpaBuild {
      pname = "denote-menu";
      version = "1.4.0";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/denote-menu-1.4.0.tar";
        sha256 = "1lw8fyf749wmkrcn8ixvrias1a84wcgy9snlmlk0w2h02dqapazi";
      };

      ename = "denote-menu";
      packageRequires = [ denote ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/denote-menu.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  denote-org = callPackage (
    {
      lib,
      fetchurl,
      denote,
      elpaBuild,
    }:
    elpaBuild {
      pname = "denote-org";
      version = "0.3.0";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/denote-org-0.3.0.tar";
        sha256 = "0r3idn17875hzmidi1xjb9hddifzby9i23j35ywzn88h9a33845k";
      };

      ename = "denote-org";
      packageRequires = [ denote ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/denote-org.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  denote-review = callPackage (
    {
      lib,
      fetchurl,
      denote,
      elpaBuild,
    }:
    elpaBuild {
      pname = "denote-review";
      version = "1.0.7";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/denote-review-1.0.7.tar";
        sha256 = "0b305k3a1cg7wqhqwaifgyyqz80h8avgx24ikp491amjm6xga51a";
      };

      ename = "denote-review";
      packageRequires = [ denote ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/denote-review.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  denote-search = callPackage (
    {
      lib,
      fetchurl,
      denote,
      elpaBuild,
    }:
    elpaBuild {
      pname = "denote-search";
      version = "1.0.3";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/denote-search-1.0.3.tar";
        sha256 = "1537c5xr7gvsvwn7khjs03z4g6js03mwwz9i5rwnmksajhkyfiv7";
      };

      ename = "denote-search";
      packageRequires = [ denote ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/denote-search.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  denote-sequence = callPackage (
    {
      lib,
      fetchurl,
      denote,
      elpaBuild,
    }:
    elpaBuild {
      pname = "denote-sequence";
      version = "0.3.3";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/denote-sequence-0.3.3.tar";
        sha256 = "017h9bwaqv9lxv8ibbl739a9vkcknsv8ch2sqrbaybhri74a3mqk";
      };

      ename = "denote-sequence";
      packageRequires = [ denote ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/denote-sequence.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  denote-silo = callPackage (
    {
      lib,
      fetchurl,
      denote,
      elpaBuild,
    }:
    elpaBuild {
      pname = "denote-silo";
      version = "0.3.0";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/denote-silo-0.3.0.tar";
        sha256 = "1pwhn1k8cdb4n6v1l6d6ld5zm4gfzb5vl9fp1myqlfkjx756lglj";
      };

      ename = "denote-silo";
      packageRequires = [ denote ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/denote-silo.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  detached = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "detached";
      version = "0.10.1";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/detached-0.10.1.tar";
        sha256 = "0w6xgidi0g1pc13xfm8hcgmc7i2h5brj443cykwgvr5wkqnpmp9m";
      };

      ename = "detached";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/detached.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  devdocs = callPackage (
    {
      lib,
      fetchurl,
      compat,
      elpaBuild,
    }:
    elpaBuild {
      pname = "devdocs";
      version = "0.7";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/devdocs-0.7.tar";
        sha256 = "0jwhfmllfbmv2xhkpicyg7mmj7vl9x5pld4vmv66rrl0ha47ahgr";
      };

      ename = "devdocs";
      packageRequires = [ compat ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/devdocs.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  devicetree-ts-mode = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "devicetree-ts-mode";
      version = "0.3";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/devicetree-ts-mode-0.3.tar";
        sha256 = "06j385pvlhd7hp9isqp5gcf378m8p6578q6nz81r8dx93ymaak79";
      };

      ename = "devicetree-ts-mode";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/devicetree-ts-mode.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  dicom = callPackage (
    {
      lib,
      fetchurl,
      compat,
      elpaBuild,
    }:
    elpaBuild {
      pname = "dicom";
      version = "1.5";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/dicom-1.5.tar";
        sha256 = "02i90769952g80f8fjj9phwwm7ln8q6w65pc065r5vln1knjm7gd";
      };

      ename = "dicom";
      packageRequires = [ compat ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/dicom.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  dict-tree = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      heap,
      tNFA,
      trie,
    }:
    elpaBuild {
      pname = "dict-tree";
      version = "0.17";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/dict-tree-0.17.tar";
        sha256 = "0p4j0m3b9i38l4rcgzdps95wqk27zz156d4q73vq054kpcphrfpp";
      };

      ename = "dict-tree";

      packageRequires = [
        heap
        tNFA
        trie
      ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/dict-tree.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  diff-hl = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      cl-lib ? null,
    }:
    elpaBuild {
      pname = "diff-hl";
      version = "1.10.0";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/diff-hl-1.10.0.tar";
        sha256 = "0v8nm2sx3v405fj6i5v7nnar47j6na0q5cm5za9y33n6xaw3v2yh";
      };

      ename = "diff-hl";
      packageRequires = [ cl-lib ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/diff-hl.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  diffview = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "diffview";
      version = "1.0";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/diffview-1.0.el";
        sha256 = "1gkdmzmgjixz9nak7dxvqy28kz0g7i672gavamwgnc1jl37wkcwi";
      };

      ename = "diffview";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/diffview.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  diminish = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "diminish";
      version = "0.46";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/diminish-0.46.tar";
        sha256 = "1xqd6ldxl93l281ncddik1lfxjngi2drq61mv7v18r756c7bqr5r";
      };

      ename = "diminish";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/diminish.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  dired-du = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      cl-lib ? null,
    }:
    elpaBuild {
      pname = "dired-du";
      version = "0.5.2";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/dired-du-0.5.2.tar";
        sha256 = "066yjy9vdbf20adcqdcknk5b0ml18fy2bm9gkgcp0qfg37yy1yjg";
      };

      ename = "dired-du";
      packageRequires = [ cl-lib ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/dired-du.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  dired-duplicates = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "dired-duplicates";
      version = "0.4";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/dired-duplicates-0.4.tar";
        sha256 = "1srih47bq7szg6n3qlz4yzzcijg79p8xpwmi5c4v9xscl94nnc4z";
      };

      ename = "dired-duplicates";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/dired-duplicates.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  dired-git-info = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "dired-git-info";
      version = "0.3.1";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/dired-git-info-0.3.1.tar";
        sha256 = "0rryvlbqx1j48wafja15yc39jd0fzgz9i6bzmq9jpql3w9445772";
      };

      ename = "dired-git-info";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/dired-git-info.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  dired-preview = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "dired-preview";
      version = "0.6.1";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/dired-preview-0.6.1.tar";
        sha256 = "115cassm68rga9q8z7qr1ghi4f9j0immc8ccqwa21vnyvjj02q7a";
      };

      ename = "dired-preview";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/dired-preview.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  disk-usage = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "disk-usage";
      version = "1.3.3";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/disk-usage-1.3.3.tar";
        sha256 = "02i7i7mrn6ky3lzhcadvq7wlznd0b2ay107h2b3yh4wwwxjxymyg";
      };

      ename = "disk-usage";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/disk-usage.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  dismal = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      cl-lib ? null,
    }:
    elpaBuild {
      pname = "dismal";
      version = "1.5.2";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/dismal-1.5.2.tar";
        sha256 = "1706m5ya6q0jf8mzfkqn47aqd7ygm88fm7pvzbd4cry30mjs5vki";
      };

      ename = "dismal";
      packageRequires = [ cl-lib ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/dismal.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  djvu = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "djvu";
      version = "1.1.2";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/djvu-1.1.2.tar";
        sha256 = "0z74aicvy680m1d6v5zk5pcpkd310jqqdxadpjcbnjcybzp1zisq";
      };

      ename = "djvu";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/djvu.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  dmsg = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "dmsg";
      version = "0.3";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/dmsg-0.3.tar";
        sha256 = "18r81rdpw0jnhxca3fr7bxpalabicbj2y55z5gb2llqrh9plarq6";
      };

      ename = "dmsg";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/dmsg.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  do-at-point = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "do-at-point";
      version = "0.2.0";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/do-at-point-0.2.0.tar";
        sha256 = "028vpz6xss6k5wh3p6pigd47r5vrpl8fgai0spmz22ldawy61dfg";
      };

      ename = "do-at-point";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/do-at-point.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  doc-toc = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "doc-toc";
      version = "1.2";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/doc-toc-1.2.tar";
        sha256 = "09xwa0xgnzlaff0j5zy3kam6spcnw0npppc3gf6ka5bizbk4dq99";
      };

      ename = "doc-toc";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/doc-toc.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  doc-view-follow = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "doc-view-follow";
      version = "0.3.2";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/doc-view-follow-0.3.2.tar";
        sha256 = "1lwzcmxsqcbwf42s8yisw3wraka3yphhwf51pznlvdwhwax4h4ph";
      };

      ename = "doc-view-follow";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/doc-view-follow.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  docbook = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "docbook";
      version = "0.1";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/docbook-0.1.tar";
        sha256 = "1kn71kpyb1maww414zgpc1ccgb02mmaiaix06jyqhf75hfxms2lv";
      };

      ename = "docbook";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/docbook.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  doric-themes = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "doric-themes";
      version = "1.1.0";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/doric-themes-1.1.0.tar";
        sha256 = "12rm5swbhn52yh4nvngqqbaiy8j97bi86a0k7swdb08vxmgp5kzh";
      };

      ename = "doric-themes";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/doric-themes.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  drepl = callPackage (
    {
      lib,
      fetchurl,
      comint-mime,
      elpaBuild,
    }:
    elpaBuild {
      pname = "drepl";
      version = "0.4";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/drepl-0.4.tar";
        sha256 = "161aga6jviba7h8iaid8dkrgli0wikm2zl9dfkzmj4xms3czgl24";
      };

      ename = "drepl";
      packageRequires = [ comint-mime ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/drepl.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  dts-mode = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "dts-mode";
      version = "1.0";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/dts-mode-1.0.tar";
        sha256 = "16ads9xjbqgmgwzj63anhc6yb1j79qpcnxjafqrzdih1p5j7hrr9";
      };

      ename = "dts-mode";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/dts-mode.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  easy-escape = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "easy-escape";
      version = "0.2.1";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/easy-escape-0.2.1.tar";
        sha256 = "0mwam1a7sl90aqgz6mj3zm0w1dq15b5jpxmwxv21xs1imyv696ci";
      };

      ename = "easy-escape";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/easy-escape.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  easy-kill = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      cl-lib ? null,
    }:
    elpaBuild {
      pname = "easy-kill";
      version = "0.9.5";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/easy-kill-0.9.5.tar";
        sha256 = "1nwhqidy5zq6j867b21zng5ppb7n56drnhn3wjs7hjmkf23r63qy";
      };

      ename = "easy-kill";
      packageRequires = [ cl-lib ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/easy-kill.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  ebdb = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      seq,
    }:
    elpaBuild {
      pname = "ebdb";
      version = "0.8.22";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/ebdb-0.8.22.tar";
        sha256 = "0nmrhjk2ddml115ibsy8j4crw5hzq9fa94v8y41iyj9h3gf8irzc";
      };

      ename = "ebdb";
      packageRequires = [ seq ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/ebdb.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  ebdb-gnorb = callPackage (
    {
      lib,
      fetchurl,
      ebdb,
      elpaBuild,
      gnorb,
    }:
    elpaBuild {
      pname = "ebdb-gnorb";
      version = "1.0.2";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/ebdb-gnorb-1.0.2.tar";
        sha256 = "1kwcrg268vmskls9p4ccs6ybdip30cb4fw3xzq11gqjch1nssh18";
      };

      ename = "ebdb-gnorb";

      packageRequires = [
        ebdb
        gnorb
      ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/ebdb-gnorb.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  ebdb-i18n-chn = callPackage (
    {
      lib,
      fetchurl,
      ebdb,
      elpaBuild,
      pyim,
    }:
    elpaBuild {
      pname = "ebdb-i18n-chn";
      version = "1.3.2";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/ebdb-i18n-chn-1.3.2.tar";
        sha256 = "1qyia40z6ssvnlpra116avakyf81vqn42860ny21g0zsl99a58j2";
      };

      ename = "ebdb-i18n-chn";

      packageRequires = [
        ebdb
        pyim
      ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/ebdb-i18n-chn.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  ediprolog = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "ediprolog";
      version = "2.3";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/ediprolog-2.3.tar";
        sha256 = "02ynwqhkpv4wcz87zkr9188kjmhd8s9zkfiawn7gywb5jkki6nd0";
      };

      ename = "ediprolog";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/ediprolog.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  eev = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "eev";
      version = "20260126";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/eev-20260126.tar";
        sha256 = "10n8fs61casjx7p64jvghwc15b09mmwp06af9s32z9bj73r4hyfk";
      };

      ename = "eev";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/eev.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  ef-themes = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      modus-themes,
    }:
    elpaBuild {
      pname = "ef-themes";
      version = "2.2.0";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/ef-themes-2.2.0.tar";
        sha256 = "0jm3hqg53cq0dfvmszmwzwrfi9n2mgdbz176qzxhjqm16rw2bwds";
      };

      ename = "ef-themes";
      packageRequires = [ modus-themes ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/ef-themes.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  eglot = callPackage (
    {
      lib,
      fetchurl,
      eldoc,
      elpaBuild,
      external-completion,
      jsonrpc,
      project,
      seq,
      xref,
      flymake ? null,
    }:
    elpaBuild {
      pname = "eglot";
      version = "1.23";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/eglot-1.23.tar";
        sha256 = "1l83c90rdamlk576bd859jkg6406hgxi7w4c6ixlw509c66qr3s6";
      };

      ename = "eglot";

      packageRequires = [
        eldoc
        external-completion
        flymake
        jsonrpc
        project
        seq
        xref
      ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/eglot.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  el-job = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "el-job";
      version = "2.7.4";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/el-job-2.7.4.tar";
        sha256 = "0j5dlgl57k4iy0limdw65ks68pbb4q1cc55192wf6crrv7vvls0z";
      };

      ename = "el-job";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/el-job.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  el-search = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      stream,
      cl-print ? null,
    }:
    elpaBuild {
      pname = "el-search";
      version = "1.12.6.1";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/el-search-1.12.6.1.tar";
        sha256 = "1vq8cp2icpl8vkc9r8brzbn0mpaj03mnvdz1bdqn8nqrzc3w0h24";
      };

      ename = "el-search";

      packageRequires = [
        cl-print
        stream
      ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/el-search.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  eldoc = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "eldoc";
      version = "1.16.0";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/eldoc-1.16.0.tar";
        sha256 = "08dnvfyz6qkjx3fcggp628qacbxvac1agl7kgbkg6kiq4axwmifb";
      };

      ename = "eldoc";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/eldoc.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  electric-spacing = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "electric-spacing";
      version = "5.0";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/electric-spacing-5.0.tar";
        sha256 = "1gr35nri25ycxr0wwkypky8zv43nnfrilx4jaj66mb9jsyix6smi";
      };

      ename = "electric-spacing";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/electric-spacing.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  elisa = callPackage (
    {
      lib,
      fetchurl,
      async,
      ellama,
      elpaBuild,
      llm,
      plz,
    }:
    elpaBuild {
      pname = "elisa";
      version = "1.1.7";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/elisa-1.1.7.tar";
        sha256 = "042bdbaxz521xs4ra89mn408vaqax0f0dn6xl6823f4vv1spq6k7";
      };

      ename = "elisa";

      packageRequires = [
        async
        ellama
        llm
        plz
      ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/elisa.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  elisp-benchmarks = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "elisp-benchmarks";
      version = "1.16";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/elisp-benchmarks-1.16.tar";
        sha256 = "0v5db89z6hirvixgjwyz3a9dkx6xf486hy51sprvslki706m08p2";
      };

      ename = "elisp-benchmarks";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/elisp-benchmarks.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  ellama = callPackage (
    {
      lib,
      fetchurl,
      compat,
      elpaBuild,
      llm,
      plz,
      transient,
      yaml,
    }:
    elpaBuild {
      pname = "ellama";
      version = "1.27.2";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/ellama-1.27.2.tar";
        sha256 = "09l22c29vv8bd70vq681ashvlyqcq3ajk37nmdkcj7j4ik53l4bh";
      };

      ename = "ellama";

      packageRequires = [
        compat
        llm
        plz
        transient
        yaml
      ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/ellama.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  emacs-gc-stats = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "emacs-gc-stats";
      version = "1.4.2";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/emacs-gc-stats-1.4.2.tar";
        sha256 = "055ma32r92ksjnqy8xbzv0a79r7aap12h61dj860781fapfnifa3";
      };

      ename = "emacs-gc-stats";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/emacs-gc-stats.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  emacs-lisp-intro-es = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "emacs-lisp-intro-es";
      version = "1.0.1";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/emacs-lisp-intro-es-1.0.1.tar";
        sha256 = "1p3k6wd94zxdmmnbiiwa2hynd2p2vpdrg0nsy86qm0gxqx3pgjf1";
      };

      ename = "emacs-lisp-intro-es";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/emacs-lisp-intro-es.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  embark = callPackage (
    {
      lib,
      fetchurl,
      compat,
      elpaBuild,
    }:
    elpaBuild {
      pname = "embark";
      version = "1.2";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/embark-1.2.tar";
        sha256 = "1skqcsscawfa3043n6v0fl633pcacigl6p33d80ik5lsf0z5br35";
      };

      ename = "embark";
      packageRequires = [ compat ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/embark.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  embark-consult = callPackage (
    {
      lib,
      fetchurl,
      compat,
      consult,
      elpaBuild,
      embark,
    }:
    elpaBuild {
      pname = "embark-consult";
      version = "1.2";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/embark-consult-1.2.tar";
        sha256 = "1m6i8f49qmzfvqz0mq3ga0gcdi364pqsdph6arpwl4rr59r6sfwn";
      };

      ename = "embark-consult";

      packageRequires = [
        compat
        consult
        embark
      ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/embark-consult.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  ement = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      map,
      persist,
      plz,
      svg-lib,
      taxy,
      taxy-magit-section,
      transient,
    }:
    elpaBuild {
      pname = "ement";
      version = "0.17";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/ement-0.17.tar";
        sha256 = "1qihmk6f2chb8kfv9gr6kmxsayf7p161dihvfy5x176pc0l4capk";
      };

      ename = "ement";

      packageRequires = [
        map
        persist
        plz
        svg-lib
        taxy
        taxy-magit-section
        transient
      ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/ement.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  emms = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      nadvice,
      seq,
      cl-lib ? null,
    }:
    elpaBuild {
      pname = "emms";
      version = "26";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/emms-26.tar";
        sha256 = "0qcdhml0y69xjaa9l7jb1dsvqij1ksgw2x44zhxfn4f3fwkfxhd5";
      };

      ename = "emms";

      packageRequires = [
        cl-lib
        nadvice
        seq
      ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/emms.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  engrave-faces = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "engrave-faces";
      version = "0.3.1";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/engrave-faces-0.3.1.tar";
        sha256 = "0nl5wx61192dqd0191dvaszgjc7b2adrxsyc75f529fcyrfwgqfa";
      };

      ename = "engrave-faces";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/engrave-faces.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  enwc = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "enwc";
      version = "2.0";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/enwc-2.0.tar";
        sha256 = "0y8154ykrashgg0bina5ambdrxw2qpimycvjldrk9d67hrccfh3m";
      };

      ename = "enwc";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/enwc.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  epoch-view = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "epoch-view";
      version = "0.0.1";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/epoch-view-0.0.1.el";
        sha256 = "1wy25ryyg9f4v83qjym2pwip6g9mszhqkf5a080z0yl47p71avfx";
      };

      ename = "epoch-view";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/epoch-view.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  erc = callPackage (
    {
      lib,
      fetchurl,
      compat,
      elpaBuild,
    }:
    elpaBuild {
      pname = "erc";
      version = "5.6.2";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/erc-5.6.2.tar";
        sha256 = "0rm7aw6p8736ssp4z7vmfmwff93h4dwcv9pz3b83f9060i2svvvn";
      };

      ename = "erc";
      packageRequires = [ compat ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/erc.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  ergoemacs-mode = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      undo-tree,
      cl-lib ? null,
    }:
    elpaBuild {
      pname = "ergoemacs-mode";
      version = "5.16.10.12";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/ergoemacs-mode-5.16.10.12.tar";
        sha256 = "0s4lwb76c67npbcnvbxdawnj02zkc85sbm392lym1qccjmj9d02f";
      };

      ename = "ergoemacs-mode";

      packageRequires = [
        cl-lib
        undo-tree
      ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/ergoemacs-mode.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  ess = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "ess";
      version = "26.5.0";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/ess-26.5.0.tar";
        sha256 = "07mfjhcnq3wn6q0dxc4yn5aqnvb9sfnwgi581b5283pfbszhxd29";
      };

      ename = "ess";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/ess.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  excorporate = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      fsm,
      soap-client,
      url-http-ntlm,
      url-http-oauth,
    }:
    elpaBuild {
      pname = "excorporate";
      version = "1.1.3";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/excorporate-1.1.3.tar";
        sha256 = "09szsql8qyca6hn7fib832fzi9fmcsf9wiacgqdw32lfjqv5fjwk";
      };

      ename = "excorporate";

      packageRequires = [
        fsm
        soap-client
        url-http-ntlm
        url-http-oauth
      ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/excorporate.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  expand-region = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "expand-region";
      version = "1.0.0";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/expand-region-1.0.0.tar";
        sha256 = "1rjx7w4gss8sbsjaljraa6cjpb57kdpx9zxmr30kbifb5lp511rd";
      };

      ename = "expand-region";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/expand-region.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  expreg = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "expreg";
      version = "1.4.1";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/expreg-1.4.1.tar";
        sha256 = "1m30d8yp46al7g1hakq95icmgjz0crcvj1h1yd6bj887v1nrnvkk";
      };

      ename = "expreg";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/expreg.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  external-completion = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "external-completion";
      version = "0.1";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/external-completion-0.1.tar";
        sha256 = "1bw2kvz7zf1s60d37j31krakryc1kpyial2idjy6ac6w7n1h0jzc";
      };

      ename = "external-completion";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/external-completion.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  exwm = callPackage (
    {
      lib,
      fetchurl,
      compat,
      elpaBuild,
      xelb,
    }:
    elpaBuild {
      pname = "exwm";
      version = "0.34";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/exwm-0.34.tar";
        sha256 = "1hp2ni9c6bn627275x37n6zhcismvni6vqp7cpdn3cx292n7sx6z";
      };

      ename = "exwm";

      packageRequires = [
        compat
        xelb
      ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/exwm.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  f90-interface-browser = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "f90-interface-browser";
      version = "1.1";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/f90-interface-browser-1.1.el";
        sha256 = "0mf32w2bgc6b43k0r4a11bywprj7y3rvl21i0ry74v425r6hc3is";
      };

      ename = "f90-interface-browser";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/f90-interface-browser.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  ffs = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "ffs";
      version = "0.2.2";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/ffs-0.2.2.tar";
        sha256 = "1mwjk877qfccdrp046j431pawr9g489gdz803wg55j0r12whh94a";
      };

      ename = "ffs";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/ffs.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  filechooser = callPackage (
    {
      lib,
      fetchurl,
      compat,
      elpaBuild,
    }:
    elpaBuild {
      pname = "filechooser";
      version = "0.2.4";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/filechooser-0.2.4.tar";
        sha256 = "0bw1yvypm2vk6bh81h88505fd1538rrga9y40gmy7w144spfi6sb";
      };

      ename = "filechooser";
      packageRequires = [ compat ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/filechooser.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  filladapt = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "filladapt";
      version = "2.12.2";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/filladapt-2.12.2.tar";
        sha256 = "0nmgw6v2krxn5palddqj1jzqxrajhpyq9v2x9lw12cdcldm9ab4k";
      };

      ename = "filladapt";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/filladapt.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  firefox-javascript-repl = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "firefox-javascript-repl";
      version = "0.9.5";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/firefox-javascript-repl-0.9.5.tar";
        sha256 = "07qmp6hfzgljrl9gkwy673xk67b3bgxq4kkw2kzr8ma4a7lx7a8l";
      };

      ename = "firefox-javascript-repl";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/firefox-javascript-repl.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  flylisp = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "flylisp";
      version = "0.2";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/flylisp-0.2.tar";
        sha256 = "1agny4hc75xc8a9f339bynsazmxw8ccvyb03qx1d6nvwh9d7v1b9";
      };

      ename = "flylisp";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/flylisp.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  flymake = callPackage (
    {
      lib,
      fetchurl,
      eldoc,
      elpaBuild,
      project,
    }:
    elpaBuild {
      pname = "flymake";
      version = "1.4.5";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/flymake-1.4.5.tar";
        sha256 = "0jga23hdjl0kllxsdjwlqm488fscjlyipf98w5379qiajkhqxlzz";
      };

      ename = "flymake";

      packageRequires = [
        eldoc
        project
      ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/flymake.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  flymake-clippy = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "flymake-clippy";
      version = "1.1.0";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/flymake-clippy-1.1.0.tar";
        sha256 = "1sij8qn7q9jvjnnnqqm152hnvkw079m66pwjyhvsqdqivqjvlnrd";
      };

      ename = "flymake-clippy";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/flymake-clippy.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  flymake-codespell = callPackage (
    {
      lib,
      fetchurl,
      compat,
      elpaBuild,
    }:
    elpaBuild {
      pname = "flymake-codespell";
      version = "0.1";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/flymake-codespell-0.1.tar";
        sha256 = "1x1bmdjmdaciknd702z54002bi1a5n51vvn9g7j6rnzjc1dxw97f";
      };

      ename = "flymake-codespell";
      packageRequires = [ compat ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/flymake-codespell.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  flymake-proselint = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "flymake-proselint";
      version = "0.3.0";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/flymake-proselint-0.3.0.tar";
        sha256 = "0bq7nc1qiqwxi848xy7wg1ig8k38nmq1w13xws10scjvndlbcjpl";
      };

      ename = "flymake-proselint";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/flymake-proselint.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  fontaine = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "fontaine";
      version = "3.0.1";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/fontaine-3.0.1.tar";
        sha256 = "0bgfg6pkw724id1d3igiw4g0204wnjwsbnabfy2rq6nrf99z1qwr";
      };

      ename = "fontaine";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/fontaine.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  forgejo = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      keymap-popup,
    }:
    elpaBuild {
      pname = "forgejo";
      version = "0.2.3";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/forgejo-0.2.3.tar";
        sha256 = "0q4y474acb759vx3d0xcqgikbq666nckka4hfashi1jwnas98qcg";
      };

      ename = "forgejo";
      packageRequires = [ keymap-popup ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/forgejo.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  frame-tabs = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "frame-tabs";
      version = "1.1";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/frame-tabs-1.1.tar";
        sha256 = "1a7hklir19inai68azgyfiw1bzq5z57kkp33lj6qbxxvfcqvw62w";
      };

      ename = "frame-tabs";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/frame-tabs.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  frog-menu = callPackage (
    {
      lib,
      fetchurl,
      avy,
      elpaBuild,
      posframe,
    }:
    elpaBuild {
      pname = "frog-menu";
      version = "0.2.11";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/frog-menu-0.2.11.tar";
        sha256 = "1iwyg9z8i03p9kkz6vhv00bzsqrsgl4xqqh08icial29c80q939l";
      };

      ename = "frog-menu";

      packageRequires = [
        avy
        posframe
      ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/frog-menu.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  fsm = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      cl-lib ? null,
    }:
    elpaBuild {
      pname = "fsm";
      version = "0.2.1";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/fsm-0.2.1.tar";
        sha256 = "0kvm16077bn6bpbyw3k5935fhiq86ry2j1zcx9sj7dvb9w737qz4";
      };

      ename = "fsm";
      packageRequires = [ cl-lib ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/fsm.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  ftable = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "ftable";
      version = "1.1";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/ftable-1.1.tar";
        sha256 = "052vqw8892wv8lh5slm90gcvfk7ws5sgl1mzbdi4d3sy4kc4q48h";
      };

      ename = "ftable";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/ftable.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  futur = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "futur";
      version = "1.7";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/futur-1.7.tar";
        sha256 = "1zb533jkhsi6p0ikx9jc7igz4yfq7b35apz9b8w7g0yrvq5jcl4i";
      };

      ename = "futur";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/futur.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  gcmh = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "gcmh";
      version = "0.2.1";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/gcmh-0.2.1.tar";
        sha256 = "030w493ilmc7w13jizwqsc33a424qjgicy1yxvlmy08yipnw3587";
      };

      ename = "gcmh";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/gcmh.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  ggtags = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "ggtags";
      version = "0.9.0";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/ggtags-0.9.0.tar";
        sha256 = "02gj8ghkk35clyscbvp1p1nlhmgm5h9g2cy4mavnfmx7jikmr4m3";
      };

      ename = "ggtags";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/ggtags.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  gited = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      cl-lib ? null,
    }:
    elpaBuild {
      pname = "gited";
      version = "0.6.0";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/gited-0.6.0.tar";
        sha256 = "1s2h6y1adh28pvm3h5bivfja2nqnzm8w9sfza894pxf96kwk3pg2";
      };

      ename = "gited";
      packageRequires = [ cl-lib ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/gited.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  gle-mode = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      cl-lib ? null,
    }:
    elpaBuild {
      pname = "gle-mode";
      version = "1.1";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/gle-mode-1.1.tar";
        sha256 = "12vbif4b4j87z7fg18dlcmzmbs2fp1g8bgsk5rch9h6dblg72prq";
      };

      ename = "gle-mode";
      packageRequires = [ cl-lib ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/gle-mode.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  gnat-compiler = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      wisi,
    }:
    elpaBuild {
      pname = "gnat-compiler";
      version = "1.0.3";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/gnat-compiler-1.0.3.tar";
        sha256 = "1chydgswab2m81m3kbd31b1akyw4v1c9468wlfxpg2yydy8fc7vs";
      };

      ename = "gnat-compiler";
      packageRequires = [ wisi ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/gnat-compiler.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  gnome-c-style = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "gnome-c-style";
      version = "0.1";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/gnome-c-style-0.1.tar";
        sha256 = "09w68jbpzyyhcaqw335qpr840j7xx0j81zxxkxq4ahqv6ck27v4x";
      };

      ename = "gnome-c-style";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/gnome-c-style.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  gnome-dark-style = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "gnome-dark-style";
      version = "0.2.4";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/gnome-dark-style-0.2.4.tar";
        sha256 = "0smdgd68ha155lc4mmv1ix8y8mk1il081cx4gap49kny5ybx3538";
      };

      ename = "gnome-dark-style";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/gnome-dark-style.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  gnorb = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      cl-lib ? null,
    }:
    elpaBuild {
      pname = "gnorb";
      version = "1.6.11";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/gnorb-1.6.11.tar";
        sha256 = "1y0xpbifb8dm8hd5i9g8jph4jm76wviphszl5x3zi6w053jpss9b";
      };

      ename = "gnorb";
      packageRequires = [ cl-lib ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/gnorb.html";
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
      keymap-popup,
    }:
    elpaBuild {
      pname = "gnosis";
      version = "0.10.6";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/gnosis-0.10.6.tar";
        sha256 = "1g8zbvid2l7wfyagqynjd1jcjnd0m3zkh9ww0dadppj24n37k57n";
      };

      ename = "gnosis";

      packageRequires = [
        compat
        keymap-popup
      ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/gnosis.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  gnu-elpa = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "gnu-elpa";
      version = "1.1";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/gnu-elpa-1.1.tar";
        sha256 = "01cw1r5y86q1aardpvcwvwq161invrzxd0kv4qqi5agaff2nbp26";
      };

      ename = "gnu-elpa";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/gnu-elpa.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  gnu-elpa-keyring-update = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "gnu-elpa-keyring-update";
      version = "2025.10.1";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/gnu-elpa-keyring-update-2025.10.1.tar";
        sha256 = "0p3125llm6hiasxx1rxl5anwfa317w2m8ybj9zl8133m5sjzzvsf";
      };

      ename = "gnu-elpa-keyring-update";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/gnu-elpa-keyring-update.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  gnugo = callPackage (
    {
      lib,
      fetchurl,
      ascii-art-to-unicode,
      elpaBuild,
      xpm,
      cl-lib ? null,
    }:
    elpaBuild {
      pname = "gnugo";
      version = "3.1.2";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/gnugo-3.1.2.tar";
        sha256 = "0wingn5v4wa1xgsgmqqls28cifnff8mvm098kn8clw42mxr40257";
      };

      ename = "gnugo";

      packageRequires = [
        ascii-art-to-unicode
        cl-lib
        xpm
      ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/gnugo.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  gnus-mock = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "gnus-mock";
      version = "0.5";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/gnus-mock-0.5.tar";
        sha256 = "1yl624wzs4kw45zpnxh04dxn1kkpb6c2jl3i0sm1bijyhm303l4h";
      };

      ename = "gnus-mock";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/gnus-mock.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  gpastel = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "gpastel";
      version = "0.5.0";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/gpastel-0.5.0.tar";
        sha256 = "12y1ysgnqjvsdp5gal90mp2wplif7rq1cj61393l6gf3pgv6jkzc";
      };

      ename = "gpastel";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/gpastel.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  gpr-mode = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      gnat-compiler,
      wisi,
    }:
    elpaBuild {
      pname = "gpr-mode";
      version = "1.0.5";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/gpr-mode-1.0.5.tar";
        sha256 = "1qdk2pkdxggfhj8gm39jb2b29g0gbw50vgil6rv3z0q7nlhpm2fp";
      };

      ename = "gpr-mode";

      packageRequires = [
        gnat-compiler
        wisi
      ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/gpr-mode.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  gpr-query = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      gnat-compiler,
      wisi,
    }:
    elpaBuild {
      pname = "gpr-query";
      version = "1.0.4";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/gpr-query-1.0.4.tar";
        sha256 = "1y283x549w544x37lmh25n19agyah2iz0b052hx8br4rnjdd9ii3";
      };

      ename = "gpr-query";

      packageRequires = [
        gnat-compiler
        wisi
      ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/gpr-query.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  graphql = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "graphql";
      version = "0.1.2";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/graphql-0.1.2.tar";
        sha256 = "1blpsj6sav3z9gj733cccdhpdnyvnvxp48z1hnjh0f0fl5avvkix";
      };

      ename = "graphql";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/graphql.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  greader = callPackage (
    {
      lib,
      fetchurl,
      compat,
      elpaBuild,
      seq,
    }:
    elpaBuild {
      pname = "greader";
      version = "0.19.4";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/greader-0.19.4.tar";
        sha256 = "1wg25481rdzfjshsjhaf2747hsy964gn1zc5gbmqak8y1vmsjb6h";
      };

      ename = "greader";

      packageRequires = [
        compat
        seq
      ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/greader.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  greenbar = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "greenbar";
      version = "1.2.260317";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/greenbar-1.2.260317.tar";
        sha256 = "0gflgrc60xf6vkj2r7k5889l6a2ky9vbss1f19x1ci4v6dx6y3hz";
      };

      ename = "greenbar";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/greenbar.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  gtags-mode = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "gtags-mode";
      version = "1.9.5";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/gtags-mode-1.9.5.tar";
        sha256 = "1qb1wcim2abjprmn2bsc6d7vmad217fkc450dgwgxxx5spjgz40d";
      };

      ename = "gtags-mode";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/gtags-mode.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  guess-language = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      nadvice,
      cl-lib ? null,
    }:
    elpaBuild {
      pname = "guess-language";
      version = "0.0.1";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/guess-language-0.0.1.el";
        sha256 = "11a6m2337j4ncppaf59yr2vavvvsph2qh51d12zmq58g9wh3d7wz";
      };

      ename = "guess-language";

      packageRequires = [
        cl-lib
        nadvice
      ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/guess-language.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  hcel = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "hcel";
      version = "1.0.0";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/hcel-1.0.0.tar";
        sha256 = "1pm3d0nz2mpf667jkjlmlidh203i4d4gk0n8xd3r66bzwc4l042b";
      };

      ename = "hcel";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/hcel.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  heap = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "heap";
      version = "0.5";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/heap-0.5.tar";
        sha256 = "1q42v9mzmlhl4pr3wr94nsis7a9977f35w0qsyx2r982kwgmbndw";
      };

      ename = "heap";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/heap.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  hiddenquote = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "hiddenquote";
      version = "1.2";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/hiddenquote-1.2.tar";
        sha256 = "051aqiq77n487lnsxxwa8q0vyzk6m2fwi3l7xwvrl49p5xpia6zr";
      };

      ename = "hiddenquote";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/hiddenquote.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  highlight-escape-sequences = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "highlight-escape-sequences";
      version = "0.4";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/highlight-escape-sequences-0.4.tar";
        sha256 = "1gs662vvvzrqdlb1z73jf6wykjzs1jskcdksk8akqmply4sjvbpr";
      };

      ename = "highlight-escape-sequences";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/highlight-escape-sequences.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  hook-helpers = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "hook-helpers";
      version = "1.1.1";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/hook-helpers-1.1.1.tar";
        sha256 = "05nqlshdqh32smav58hzqg8wp04h7w9sxr239qrz4wqxwlxlv9im";
      };

      ename = "hook-helpers";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/hook-helpers.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  html5-schema = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "html5-schema";
      version = "0.1";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/html5-schema-0.1.tar";
        sha256 = "018zvdjhdrkcy8yrsqqqikhl6drmqm1fs0y50m8q8vx42p0cyi1p";
      };

      ename = "html5-schema";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/html5-schema.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  hugoista = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      seq,
    }:
    elpaBuild {
      pname = "hugoista";
      version = "0.2.1";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/hugoista-0.2.1.tar";
        sha256 = "02rv1r2xr6dhkfqwgbrrsdajxv6inbny5biimkb0qcf3i8b43dih";
      };

      ename = "hugoista";
      packageRequires = [ seq ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/hugoista.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  hydra = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      lv,
      cl-lib ? null,
    }:
    elpaBuild {
      pname = "hydra";
      version = "0.15.0";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/hydra-0.15.0.tar";
        sha256 = "082wdr2nsfz8jhh7ic4nq4labz0pq8lcdwnxdmw79ppm20p2jipk";
      };

      ename = "hydra";

      packageRequires = [
        cl-lib
        lv
      ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/hydra.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  hyperbole = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "hyperbole";
      version = "9.0.1";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/hyperbole-9.0.1.tar";
        sha256 = "0gjscqa0zagbymm6wfilvc8g68f8myv90ryd8kqfcpy81fh4dhiz";
      };

      ename = "hyperbole";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/hyperbole.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  idlwave = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "idlwave";
      version = "6.5.1";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/idlwave-6.5.1.tar";
        sha256 = "0dd0dm92qyin8k4kgavrg82zwjhv6wsjq6gk55rzcspx0s8y2c24";
      };

      ename = "idlwave";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/idlwave.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  ilist = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "ilist";
      version = "0.4";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/ilist-0.4.tar";
        sha256 = "1hsja208yaszviv8p3mzi04j0jz8ij02nbl1y6shk3b965sflhyp";
      };

      ename = "ilist";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/ilist.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  indent-bars = callPackage (
    {
      lib,
      fetchurl,
      compat,
      elpaBuild,
    }:
    elpaBuild {
      pname = "indent-bars";
      version = "1.0.0";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/indent-bars-1.0.0.tar";
        sha256 = "0iifmipmbry7r2xsq4i2q1k2awcy4z7v3bd509r50i3mc5002ssf";
      };

      ename = "indent-bars";
      packageRequires = [ compat ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/indent-bars.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  inspector = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "inspector";
      version = "0.39";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/inspector-0.39.tar";
        sha256 = "0rapxw79zj9kwianji46nnbsgnsf67mfcxahwqlycn3kjkh5fqqa";
      };

      ename = "inspector";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/inspector.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  ioccur = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      cl-lib ? null,
    }:
    elpaBuild {
      pname = "ioccur";
      version = "2.6";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/ioccur-2.6.tar";
        sha256 = "0xyx5xd46n5x078k7pv022h84xmxv7fkh31ddib872bmnirhk6ln";
      };

      ename = "ioccur";
      packageRequires = [ cl-lib ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/ioccur.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  isearch-mb = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "isearch-mb";
      version = "0.8";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/isearch-mb-0.8.tar";
        sha256 = "1b4929vr5gib406p51zcvq1ysmzvnz6bs1lqwjp517kzp6r4gc5y";
      };

      ename = "isearch-mb";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/isearch-mb.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  iso-date = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "iso-date";
      version = "1.2.0";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/iso-date-1.2.0.tar";
        sha256 = "132v583glz0faxyizysbsg7bm3hhhwav2769xqq3x86y0k5399c5";
      };

      ename = "iso-date";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/iso-date.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  iterators = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "iterators";
      version = "0.1.1";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/iterators-0.1.1.tar";
        sha256 = "1xcqvj9dail1irvj2nbfx9x106mcav104pp89jz2diamrky6ja49";
      };

      ename = "iterators";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/iterators.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  ivy = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "ivy";
      version = "0.15.1";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/ivy-0.15.1.tar";
        sha256 = "12ni3n8h7316hv4nrx4kbjah58n8zdxkf1v8fi0w39da1aqn3r0p";
      };

      ename = "ivy";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/ivy.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  ivy-avy = callPackage (
    {
      lib,
      fetchurl,
      avy,
      elpaBuild,
      ivy,
    }:
    elpaBuild {
      pname = "ivy-avy";
      version = "0.15.1";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/ivy-avy-0.15.1.tar";
        sha256 = "0csysx22sf3bbfh000c2m48rzfn274km0zxbfbcx2871haskwva1";
      };

      ename = "ivy-avy";

      packageRequires = [
        avy
        ivy
      ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/ivy-avy.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  ivy-explorer = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      ivy,
    }:
    elpaBuild {
      pname = "ivy-explorer";
      version = "0.3.2";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/ivy-explorer-0.3.2.tar";
        sha256 = "0wv7gp2kznc6f6g9ky1gvq72i78ihp582kyks82h13w25rvh6f0a";
      };

      ename = "ivy-explorer";
      packageRequires = [ ivy ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/ivy-explorer.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  ivy-hydra = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      hydra,
      ivy,
    }:
    elpaBuild {
      pname = "ivy-hydra";
      version = "0.15.1";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/ivy-hydra-0.15.1.tar";
        sha256 = "16z3ic50zbx9iaw0w6fv04cxpl6qz81424jdian1br1942pz3kdy";
      };

      ename = "ivy-hydra";

      packageRequires = [
        hydra
        ivy
      ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/ivy-hydra.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  ivy-posframe = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      ivy,
      posframe,
    }:
    elpaBuild {
      pname = "ivy-posframe";
      version = "0.6.4";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/ivy-posframe-0.6.4.tar";
        sha256 = "1lpfbr4baxha66g0pwgh3x0sgil2mrhify896raj4zal4zmbp0fk";
      };

      ename = "ivy-posframe";

      packageRequires = [
        ivy
        posframe
      ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/ivy-posframe.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  jami-bot = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "jami-bot";
      version = "0.0.4";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/jami-bot-0.0.4.tar";
        sha256 = "1dp4k5y7qy793m3fyxvkk57bfy42kac2w5wvy7zqzd4lckm0a93z";
      };

      ename = "jami-bot";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/jami-bot.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  jarchive = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "jarchive";
      version = "0.12.0";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/jarchive-0.12.0.tar";
        sha256 = "04r47jj42crpvix55gfkbc15q0fnps2n1jsgf3z82734qwp9dxmi";
      };

      ename = "jarchive";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/jarchive.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  javaimp = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "javaimp";
      version = "0.9.2";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/javaimp-0.9.2.tar";
        sha256 = "0y756psqlb2rn0bbrdndddsy6d22arv5f4qzaxgzp5p323vzjp7w";
      };

      ename = "javaimp";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/javaimp.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  jgraph-mode = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      cl-lib ? null,
    }:
    elpaBuild {
      pname = "jgraph-mode";
      version = "1.1";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/jgraph-mode-1.1.tar";
        sha256 = "1ryxbszp15dy2chch2irqy7rmcspfjw717w4rd0vxjpwvgkjgiql";
      };

      ename = "jgraph-mode";
      packageRequires = [ cl-lib ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/jgraph-mode.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  jinx = callPackage (
    {
      lib,
      fetchurl,
      compat,
      elpaBuild,
    }:
    elpaBuild {
      pname = "jinx";
      version = "2.8";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/jinx-2.8.tar";
        sha256 = "0cxgj390zylr4lqjmfd7f8898z4zsjy1ln783fcjlhcpf94jjjmx";
      };

      ename = "jinx";
      packageRequires = [ compat ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/jinx.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  jit-spell = callPackage (
    {
      lib,
      fetchurl,
      compat,
      elpaBuild,
    }:
    elpaBuild {
      pname = "jit-spell";
      version = "0.5";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/jit-spell-0.5.tar";
        sha256 = "0xdn4hm4d26vmqh75i2ghyissm2s2szgynwynpgmlvhr4q5nkswf";
      };

      ename = "jit-spell";
      packageRequires = [ compat ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/jit-spell.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  js2-mode = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      cl-lib ? null,
    }:
    elpaBuild {
      pname = "js2-mode";
      version = "20231224";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/js2-mode-20231224.tar";
        sha256 = "023z76zxh5q6g26x7qlgf9476lj95sj84d5s3aqhy6xyskkyyg6c";
      };

      ename = "js2-mode";
      packageRequires = [ cl-lib ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/js2-mode.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  json-mode = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "json-mode";
      version = "0.3.1";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/json-mode-0.3.1.tar";
        sha256 = "1wh7gdim3i9l6jh2pnh933828d735j0bihcykg7zdjiwl5df5qxw";
      };

      ename = "json-mode";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/json-mode.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  jsonrpc = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "jsonrpc";
      version = "1.0.28";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/jsonrpc-1.0.28.tar";
        sha256 = "13zdm9ss1sfpw55lwr8nrv1ha30qcj7v10m1ql8r9cbdxxkzxp8f";
      };

      ename = "jsonrpc";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/jsonrpc.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  jumpc = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "jumpc";
      version = "3.1";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/jumpc-3.1.tar";
        sha256 = "1c6wzwrr1ydpn5ah5xnk159xcn4v1gv5rjm4iyfj83dss2ygirzp";
      };

      ename = "jumpc";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/jumpc.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  keymap-popup = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "keymap-popup";
      version = "0.3.1";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/keymap-popup-0.3.1.tar";
        sha256 = "0m44s8618n7g5pajxiv4k1dfx6l58gr01a3ga26fxc51j1d05q8b";
      };

      ename = "keymap-popup";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/keymap-popup.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  kind-icon = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      svg-lib,
    }:
    elpaBuild {
      pname = "kind-icon";
      version = "0.2.2";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/kind-icon-0.2.2.tar";
        sha256 = "1zafx7rvfyahb7zzl2n9gpb2lc8x3k0bkcap2fl0n54aw4j98i69";
      };

      ename = "kind-icon";
      packageRequires = [ svg-lib ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/kind-icon.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  kiwix = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      request,
    }:
    elpaBuild {
      pname = "kiwix";
      version = "1.1.5";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/kiwix-1.1.5.tar";
        sha256 = "1krmlyfjs8b7ibixbmv41vhg1gm7prck6lpp61v17fgig92a9k2s";
      };

      ename = "kiwix";
      packageRequires = [ request ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/kiwix.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  kmb = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "kmb";
      version = "0.1";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/kmb-0.1.tar";
        sha256 = "12klfmdjjlyjvrzz3rx8dmamnag1fwljhs05jqwd0dv4a2q11gg5";
      };

      ename = "kmb";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/kmb.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  kubed = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "kubed";
      version = "0.7.1";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/kubed-0.7.1.tar";
        sha256 = "1c8jr0wi52waa1yrz1y16gpyqabpqpyymmdf8c4apsja0i6345fk";
      };

      ename = "kubed";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/kubed.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  landmark = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "landmark";
      version = "1.0";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/landmark-1.0.tar";
        sha256 = "1nnmnvyfjmkk5ddw4q24py1bqzykr29klip61n16bqpr39v56gpg";
      };

      ename = "landmark";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/landmark.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  latex-table-wizard = callPackage (
    {
      lib,
      fetchurl,
      auctex,
      elpaBuild,
      transient,
    }:
    elpaBuild {
      pname = "latex-table-wizard";
      version = "1.6.0";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/latex-table-wizard-1.6.0.tar";
        sha256 = "1zpf3x62ldqy12npypjk1x8dw7adfmqqhqj30cl2s659vq7gs4nb";
      };

      ename = "latex-table-wizard";

      packageRequires = [
        auctex
        transient
      ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/latex-table-wizard.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  leaf = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "leaf";
      version = "4.5.5";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/leaf-4.5.5.tar";
        sha256 = "1nvpl9ffma0ybbr7vlpcj7q33ja17zrswvl91bqljlmb4lb5121m";
      };

      ename = "leaf";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/leaf.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  lentic = callPackage (
    {
      lib,
      fetchurl,
      dash,
      elpaBuild,
      m-buffer,
    }:
    elpaBuild {
      pname = "lentic";
      version = "0.12";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/lentic-0.12.tar";
        sha256 = "0pszjhgy9dlk3h5gc8wnlklgl30ha3ig9bpmw2j1ps713vklfms7";
      };

      ename = "lentic";

      packageRequires = [
        dash
        m-buffer
      ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/lentic.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  lentic-server = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      lentic,
      web-server,
    }:
    elpaBuild {
      pname = "lentic-server";
      version = "0.2";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/lentic-server-0.2.tar";
        sha256 = "1r0jcfylvhlihwm6pm4f8pzvsmnlspfkph1hgi5qjkv311045244";
      };

      ename = "lentic-server";

      packageRequires = [
        lentic
        web-server
      ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/lentic-server.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  let-alist = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "let-alist";
      version = "1.0.6";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/let-alist-1.0.6.tar";
        sha256 = "1fk1yl2cg4gxcn02n2gki289dgi3lv56n0akkm2h7dhhbgfr6gqm";
      };

      ename = "let-alist";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/let-alist.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  lex = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "lex";
      version = "1.3";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/lex-1.3.tar";
        sha256 = "162y483d1gczjfcbds50y7iqbxmx7sfxi5mbdxyrhc2my6nq40lx";
      };

      ename = "lex";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/lex.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  lin = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "lin";
      version = "2.0.0";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/lin-2.0.0.tar";
        sha256 = "1ga1wb0fqv2abm95ymz1ki4dy0qlbi3cliz6mbkbk6gbdd1vhmaw";
      };

      ename = "lin";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/lin.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  listen = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      persist,
      taxy,
      taxy-magit-section,
      transient,
    }:
    elpaBuild {
      pname = "listen";
      version = "0.10.1";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/listen-0.10.1.tar";
        sha256 = "1ypiv56cj5qiwf3bzipb7ahc3j1adx0fczv0kxfa0j2xc5ndn7z1";
      };

      ename = "listen";

      packageRequires = [
        persist
        taxy
        taxy-magit-section
        transient
      ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/listen.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  literate-scratch = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "literate-scratch";
      version = "2.2";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/literate-scratch-2.2.tar";
        sha256 = "01n27aps7dkydqda89xblmhc82g8y6dkmbhxgfav13vw2ns2r7sc";
      };

      ename = "literate-scratch";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/literate-scratch.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  llm = callPackage (
    {
      lib,
      fetchurl,
      compat,
      elpaBuild,
      plz,
      plz-event-source,
      plz-media-type,
    }:
    elpaBuild {
      pname = "llm";
      version = "0.31.1";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/llm-0.31.1.tar";
        sha256 = "1395rh5jk3c0hfszzvn9xp3qyyi48nvz1x1v3vljgx4qzzcakgh3";
      };

      ename = "llm";

      packageRequires = [
        compat
        plz
        plz-event-source
        plz-media-type
      ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/llm.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  lmc = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "lmc";
      version = "1.4";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/lmc-1.4.tar";
        sha256 = "0c8sd741a7imn1im4j17m99bs6zmppndsxpn23k33lmcqj1rfhsk";
      };

      ename = "lmc";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/lmc.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  load-dir = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "load-dir";
      version = "0.0.5";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/load-dir-0.0.5.tar";
        sha256 = "1yxnckd7s4alkaddfs672g0jnsxir7c70crnm6rsc5vhmw6310nx";
      };

      ename = "load-dir";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/load-dir.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  load-relative = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "load-relative";
      version = "1.3.2";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/load-relative-1.3.2.tar";
        sha256 = "04ppqfzlqz7156aqm56yccizv0n71qir7yyp7xfiqq6vgj322rqv";
      };

      ename = "load-relative";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/load-relative.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  loc-changes = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "loc-changes";
      version = "1.2";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/loc-changes-1.2.el";
        sha256 = "1x8fn8vqasayf1rb8a6nma9n6nbvkx60krmiahyb05vl5rrsw6r3";
      };

      ename = "loc-changes";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/loc-changes.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  loccur = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "loccur";
      version = "1.2.5";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/loccur-1.2.5.tar";
        sha256 = "0dp7nhafx5x0aw4svd826bqsrn6qk46w12p04w7khpk7d9768a8x";
      };

      ename = "loccur";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/loccur.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  logos = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "logos";
      version = "1.2.0";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/logos-1.2.0.tar";
        sha256 = "0a609jfgfwq71ksxw4h2q25qbix75yrf7vm0dfpyzjvgcmqiviab";
      };

      ename = "logos";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/logos.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  luwak = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "luwak";
      version = "1.0.0";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/luwak-1.0.0.tar";
        sha256 = "0z6h1cg7nshv87zl4fia6l5gwf9ax6f4wgxijf2smi8cpwmv6j79";
      };

      ename = "luwak";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/luwak.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  lv = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "lv";
      version = "0.15.0";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/lv-0.15.0.tar";
        sha256 = "1wb8whyj8zpsd7nm7r0yjvkfkr2ml80di7alcafpadzli808j2l4";
      };

      ename = "lv";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/lv.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  m-buffer = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      seq,
    }:
    elpaBuild {
      pname = "m-buffer";
      version = "0.16.1";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/m-buffer-0.16.1.tar";
        sha256 = "1iq7nld1i8v0da1ajhvfdarx4bx3wnwgz5lhb78fcnsq8zb6cp5y";
      };

      ename = "m-buffer";
      packageRequires = [ seq ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/m-buffer.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  map = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "map";
      version = "3.3.1";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/map-3.3.1.tar";
        sha256 = "1za8wjdvyxsxvmzla823f7z0s4wbl22l8k08v8b4h4m6i7w356lp";
      };

      ename = "map";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/map.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  marginalia = callPackage (
    {
      lib,
      fetchurl,
      compat,
      elpaBuild,
    }:
    elpaBuild {
      pname = "marginalia";
      version = "2.11";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/marginalia-2.11.tar";
        sha256 = "0h7jqgx95f5km90qc4g06ib3mi4acwggvx9yiwwirxj2mqwivifk";
      };

      ename = "marginalia";
      packageRequires = [ compat ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/marginalia.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  markchars = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "markchars";
      version = "0.2.2";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/markchars-0.2.2.tar";
        sha256 = "0jagp5s2kk8ijwxbg5ccq31bjlcxkqpqhsg7a1hbyp3p5z3j73m0";
      };

      ename = "markchars";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/markchars.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  math-symbol-lists = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "math-symbol-lists";
      version = "1.3";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/math-symbol-lists-1.3.tar";
        sha256 = "1r2acaf79kwwvndqn9xbvq9dc12vr3lryc25yp0w0gksp86p8cfa";
      };

      ename = "math-symbol-lists";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/math-symbol-lists.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  mathjax = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "mathjax";
      version = "0.1";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/mathjax-0.1.tar";
        sha256 = "16023kbzkc2v455bx7l4pfy3j7z1iba7rpv0ykzk2rz21i4jan7w";
      };

      ename = "mathjax";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/mathjax.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  mathsheet = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      peg,
    }:
    elpaBuild {
      pname = "mathsheet";
      version = "1.3";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/mathsheet-1.3.tar";
        sha256 = "1gyn47fzpa866i5xmdj6yq934xr9dsaq8za2r5z7hda660rh4wqi";
      };

      ename = "mathsheet";
      packageRequires = [ peg ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/mathsheet.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  matlab-mode = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "matlab-mode";
      version = "8.2.0";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/matlab-mode-8.2.0.tar";
        sha256 = "1dk39r9nkm77gllm4xln0am1b73pirds5ss7m55n7hz2w1sas20s";
      };

      ename = "matlab-mode";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/matlab-mode.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  mct = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "mct";
      version = "1.1.0";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/mct-1.1.0.tar";
        sha256 = "0kv0j37bdsmc2jv7adpx5m48cp4h0kvjq2jfwv7d8nzpk5kk2d2p";
      };

      ename = "mct";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/mct.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  memory-usage = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "memory-usage";
      version = "0.2";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/memory-usage-0.2.tar";
        sha256 = "04bylvy86x8w96g7zil3jzyac0fijvb5lz4830ja5yabpvsnk3vq";
      };

      ename = "memory-usage";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/memory-usage.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  metar = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      cl-lib ? null,
    }:
    elpaBuild {
      pname = "metar";
      version = "0.3";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/metar-0.3.tar";
        sha256 = "07nf14zm5y6ma6wqnyw5bf7cvk3ybw7hvlrwcnri10s8vh3rqd0r";
      };

      ename = "metar";
      packageRequires = [ cl-lib ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/metar.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  midi-kbd = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "midi-kbd";
      version = "0.2";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/midi-kbd-0.2.tar";
        sha256 = "0jd92rainjd1nx72z7mrvsxs3az6axxiw1v9sbpsj03x8qq0129q";
      };

      ename = "midi-kbd";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/midi-kbd.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  mines = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      cl-lib ? null,
    }:
    elpaBuild {
      pname = "mines";
      version = "1.6";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/mines-1.6.tar";
        sha256 = "0j52n43mv963hpgdh5kk1k9wi821r6w3diwdp47rfwsijdd0wnhs";
      };

      ename = "mines";
      packageRequires = [ cl-lib ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/mines.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  minibuffer-header = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "minibuffer-header";
      version = "0.5";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/minibuffer-header-0.5.tar";
        sha256 = "1qic33wsdba5xw3qxigq18nibwhj45ggk0ragy4zj9cfy1l2ni44";
      };

      ename = "minibuffer-header";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/minibuffer-header.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  minibuffer-line = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "minibuffer-line";
      version = "0.1";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/minibuffer-line-0.1.tar";
        sha256 = "0sg9vhv7bi82a90ziiwsabnfvw8zp544v0l93hbl42cj432bpwfx";
      };

      ename = "minibuffer-line";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/minibuffer-line.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  minimail = callPackage (
    {
      lib,
      fetchurl,
      compat,
      elpaBuild,
      transient,
    }:
    elpaBuild {
      pname = "minimail";
      version = "0.5";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/minimail-0.5.tar";
        sha256 = "1m1yn8f9mn3zqf7zc0691qaya5l504ry3afz2nmjycavzh8hzk5h";
      };

      ename = "minimail";

      packageRequires = [
        compat
        transient
      ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/minimail.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  minimap = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "minimap";
      version = "1.4";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/minimap-1.4.tar";
        sha256 = "0n27wp65x5n21qy6x5dhzms8inf0248kzninp56kfx1bbf9w4x66";
      };

      ename = "minimap";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/minimap.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  minuet = callPackage (
    {
      lib,
      fetchurl,
      dash,
      elpaBuild,
      plz,
    }:
    elpaBuild {
      pname = "minuet";
      version = "0.8.0";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/minuet-0.8.0.tar";
        sha256 = "0vk118qd7g2b7vsaygj0lwnzj818p5nlsm36s1c7cm5inz1h6mfc";
      };

      ename = "minuet";

      packageRequires = [
        dash
        plz
      ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/minuet.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  mmm-mode = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      cl-lib ? null,
    }:
    elpaBuild {
      pname = "mmm-mode";
      version = "0.5.11";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/mmm-mode-0.5.11.tar";
        sha256 = "0dh76lk0am07j2zi7hhbmr6cnnss7l0b9rhi9is0w0n5i7j4i0p2";
      };

      ename = "mmm-mode";
      packageRequires = [ cl-lib ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/mmm-mode.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  modus-themes = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "modus-themes";
      version = "5.3.0";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/modus-themes-5.3.0.tar";
        sha256 = "04561ndfxq2y17drklkb3wl9kl6hdc05d4b6rrlqs3fdxcs6q6mx";
      };

      ename = "modus-themes";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/modus-themes.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  mpdired = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "mpdired";
      version = "3";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/mpdired-3.tar";
        sha256 = "19qkg7cjh037l4cw3q0b52hpp3fwmly6alc7z683baiz5fklcjc8";
      };

      ename = "mpdired";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/mpdired.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  multi-mode = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "multi-mode";
      version = "1.14";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/multi-mode-1.14.tar";
        sha256 = "0i2l50lcsj3mm9k38kfmh2hnb437pjbk2yxv26p6na1g1n44lkil";
      };

      ename = "multi-mode";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/multi-mode.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  multishell = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      cl-lib ? null,
    }:
    elpaBuild {
      pname = "multishell";
      version = "1.1.10";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/multishell-1.1.10.tar";
        sha256 = "1khqc7a04ynl63lpv898361sv37jgpd1fzvl0ryphprv9shnhw10";
      };

      ename = "multishell";
      packageRequires = [ cl-lib ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/multishell.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  muse = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "muse";
      version = "3.20.2";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/muse-3.20.2.tar";
        sha256 = "0g2ff6x45x2k5dnkp31sk3bjj92jyhhnar7l5hzn8vp22l0rv8wn";
      };

      ename = "muse";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/muse.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  myers = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "myers";
      version = "0.1";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/myers-0.1.tar";
        sha256 = "0a053w7nj0qfryvsh1ss854wxwbk5mhkl8a5nprcfgsh4qh2m487";
      };

      ename = "myers";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/myers.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  nadvice = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "nadvice";
      version = "0.4";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/nadvice-0.4.tar";
        sha256 = "19dx07v4z2lyyp18v45c5hgp65akw58bdqg5lcrzyb9mrlji8js6";
      };

      ename = "nadvice";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/nadvice.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  nameless = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "nameless";
      version = "1.0.2";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/nameless-1.0.2.tar";
        sha256 = "0m3z701j2i13zmr4g0wjd3ms6ajr6w371n5kx95n9ssxyjwjppcm";
      };

      ename = "nameless";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/nameless.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  names = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      cl-lib ? null,
    }:
    elpaBuild {
      pname = "names";
      version = "20151201.0";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/names-20151201.0.tar";
        sha256 = "0nf6n8hk58a7r56d899s5dsva3jjvh3qx9g2d1hra403fwlds74k";
      };

      ename = "names";
      packageRequires = [ cl-lib ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/names.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  nano-agenda = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "nano-agenda";
      version = "0.3";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/nano-agenda-0.3.tar";
        sha256 = "12sh6wqqd13sv966wj4k4djidn238fdb6l4wg3z9ib0dx36nygcr";
      };

      ename = "nano-agenda";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/nano-agenda.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  nano-modeline = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "nano-modeline";
      version = "1.1.0";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/nano-modeline-1.1.0.tar";
        sha256 = "1x4b4j82vzbi1mhbs9bwgw41hcagnfk56kswjk928i179pnkr0cx";
      };

      ename = "nano-modeline";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/nano-modeline.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  nano-theme = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "nano-theme";
      version = "0.3.4";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/nano-theme-0.3.4.tar";
        sha256 = "0x49lk0kx8mz72a81li6gwg3kivn7bn4ld0mml28smzqqfr3873a";
      };

      ename = "nano-theme";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/nano-theme.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  nftables-mode = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "nftables-mode";
      version = "1.1";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/nftables-mode-1.1.tar";
        sha256 = "1wjw6n60kj84j8gj62mr6s97xd0aqvr4v7npyxwmhckw9z13xcqv";
      };

      ename = "nftables-mode";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/nftables-mode.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  nhexl-mode = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      cl-lib ? null,
    }:
    elpaBuild {
      pname = "nhexl-mode";
      version = "1.5";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/nhexl-mode-1.5.tar";
        sha256 = "1i1by5bp5dby2r2jhzr0jvnchrybgnzmc5ln84w66180shk2s3yk";
      };

      ename = "nhexl-mode";
      packageRequires = [ cl-lib ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/nhexl-mode.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  nlinum = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "nlinum";
      version = "1.9";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/nlinum-1.9.tar";
        sha256 = "1cpyg6cxaaaaq6hc066l759dlas5mhn1fi398myfglnwrglia3lm";
      };

      ename = "nlinum";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/nlinum.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  notes-mode = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "notes-mode";
      version = "1.31";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/notes-mode-1.31.tar";
        sha256 = "0lwja53cknd1w432mcbfrcshmxmk23dqrbr9k2101pqfzbw8nri2";
      };

      ename = "notes-mode";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/notes-mode.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  notmuch-indicator = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "notmuch-indicator";
      version = "1.3.0";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/notmuch-indicator-1.3.0.tar";
        sha256 = "00497l8gz6vpf7yciq4bd2spyil9bf73vn7s8as2sr8l0izr3psd";
      };

      ename = "notmuch-indicator";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/notmuch-indicator.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  ntlm = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "ntlm";
      version = "2.1.0";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/ntlm-2.1.0.tar";
        sha256 = "0kivmb6b57qjrwd41zwlfdq7l9nisbh4mgd96rplrkxpzw6dq0j7";
      };

      ename = "ntlm";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/ntlm.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  num3-mode = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "num3-mode";
      version = "1.5";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/num3-mode-1.5.tar";
        sha256 = "1a7w2qd210zp199c1js639xbv2kmqmgvcqi5dn1vsazasp2dwlj2";
      };

      ename = "num3-mode";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/num3-mode.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  oauth2 = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "oauth2";
      version = "0.19";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/oauth2-0.19.tar";
        sha256 = "0fjs2wk2ayhzh9ba8fa8pki4c5cyavcw0vqsscj93894s7xv9xgz";
      };

      ename = "oauth2";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/oauth2.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  ob-asymptote = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "ob-asymptote";
      version = "1.0.2";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/ob-asymptote-1.0.2.tar";
        sha256 = "0b9glzj3aq39rksb0bg4qvsnqknwjk7lbixapw9695hfr2l4hv02";
      };

      ename = "ob-asymptote";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/ob-asymptote.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  ob-haxe = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "ob-haxe";
      version = "1.0";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/ob-haxe-1.0.tar";
        sha256 = "095qcvxpanw6fh96dfkdydn10xikbrjwih7i05iiyvazpk4x6nbz";
      };

      ename = "ob-haxe";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/ob-haxe.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  objed = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      cl-lib ? null,
    }:
    elpaBuild {
      pname = "objed";
      version = "0.8.3";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/objed-0.8.3.tar";
        sha256 = "1shgpha6f1pql95v86whsw6w6j7v35cas98fyygwrpkcrxx9a56r";
      };

      ename = "objed";
      packageRequires = [ cl-lib ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/objed.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  omn-mode = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "omn-mode";
      version = "1.3";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/omn-mode-1.3.tar";
        sha256 = "01yg4ifbz7jfhvq6r6naf50vx00wpjsr44mmlj580bylfrmdc839";
      };

      ename = "omn-mode";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/omn-mode.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  on-screen = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      cl-lib ? null,
    }:
    elpaBuild {
      pname = "on-screen";
      version = "1.3.3";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/on-screen-1.3.3.tar";
        sha256 = "0w5cv3bhb6cyjhvglp5y6cy51ppsh2xd1x53i4w0gm44g5n8l6bd";
      };

      ename = "on-screen";
      packageRequires = [ cl-lib ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/on-screen.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  orderless = callPackage (
    {
      lib,
      fetchurl,
      compat,
      elpaBuild,
    }:
    elpaBuild {
      pname = "orderless";
      version = "1.7";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/orderless-1.7.tar";
        sha256 = "0g1klijlvv44fd7xjvlh6v97zjvca37710bxlgk629v6k4kl2rbz";
      };

      ename = "orderless";
      packageRequires = [ compat ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/orderless.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  org = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "org";
      version = "9.8.6";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/org-9.8.6.tar";
        sha256 = "0qc9c49k8fcaa8c947wb7knn5lbm2bigvzxkbx8cdbyrj15pra4j";
      };

      ename = "org";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/org.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  org-contacts = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      org,
    }:
    elpaBuild {
      pname = "org-contacts";
      version = "1.3";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/org-contacts-1.3.tar";
        sha256 = "052j0d81fw6ppw7l8h0dj4jiar45skmwr3li058alxrqpgkxhxfh";
      };

      ename = "org-contacts";
      packageRequires = [ org ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/org-contacts.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  org-edna = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      org,
      seq,
    }:
    elpaBuild {
      pname = "org-edna";
      version = "1.1.2";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/org-edna-1.1.2.tar";
        sha256 = "1pifs5mbcjab21ylclck4kjdcds1xkvym27ncn9wwr8fl3fff2yl";
      };

      ename = "org-edna";

      packageRequires = [
        org
        seq
      ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/org-edna.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  org-gnosis = callPackage (
    {
      lib,
      fetchurl,
      compat,
      elpaBuild,
      emacsql,
    }:
    elpaBuild {
      pname = "org-gnosis";
      version = "0.2.2";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/org-gnosis-0.2.2.tar";
        sha256 = "1cdksxwq7wswmgdjdi3akdiljryxk3vw4yqfpjl1a2xzjqmvjxq7";
      };

      ename = "org-gnosis";

      packageRequires = [
        compat
        emacsql
      ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/org-gnosis.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  org-jami-bot = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      jami-bot,
    }:
    elpaBuild {
      pname = "org-jami-bot";
      version = "0.0.5";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/org-jami-bot-0.0.5.tar";
        sha256 = "1fiv0a7k6alvfvb7c6av0kbkwbw58plw05hhcf1vnkr9gda3s13y";
      };

      ename = "org-jami-bot";
      packageRequires = [ jami-bot ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/org-jami-bot.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  org-mem = callPackage (
    {
      lib,
      fetchurl,
      el-job,
      elpaBuild,
      llama,
      truename-cache,
    }:
    elpaBuild {
      pname = "org-mem";
      version = "0.34.1";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/org-mem-0.34.1.tar";
        sha256 = "0h8bwfq9dq0xihnssysv66miv8wqyakngqkjr8clhqd3kk716jx8";
      };

      ename = "org-mem";

      packageRequires = [
        el-job
        llama
        truename-cache
      ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/org-mem.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  org-modern = callPackage (
    {
      lib,
      fetchurl,
      compat,
      elpaBuild,
      org,
    }:
    elpaBuild {
      pname = "org-modern";
      version = "1.14";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/org-modern-1.14.tar";
        sha256 = "08rvxrr67ypvncrg7znl3in8c314l7x1a18m6hr458wqc1xb57zx";
      };

      ename = "org-modern";

      packageRequires = [
        compat
        org
      ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/org-modern.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  org-notify = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "org-notify";
      version = "0.1.2";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/org-notify-0.1.2.tar";
        sha256 = "02ndims0d0rbzjql6riadnhxn7d8br4s9fybm70j5hknli7x0azc";
      };

      ename = "org-notify";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/org-notify.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  org-real = callPackage (
    {
      lib,
      fetchurl,
      boxy,
      elpaBuild,
      org,
    }:
    elpaBuild {
      pname = "org-real";
      version = "1.0.12";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/org-real-1.0.12.tar";
        sha256 = "05x00z8iqfx9bpbzldzfnv7mvjamdf8djvxr83sfkw6r0sqlfgj9";
      };

      ename = "org-real";

      packageRequires = [
        boxy
        org
      ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/org-real.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  org-remark = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      org,
    }:
    elpaBuild {
      pname = "org-remark";
      version = "1.3.0";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/org-remark-1.3.0.tar";
        sha256 = "0i4srqhxl2rslzf3fy3rk231hsvwkn46yghy7x40kmc2jgnvs1gf";
      };

      ename = "org-remark";
      packageRequires = [ org ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/org-remark.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  org-transclusion = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      org,
    }:
    elpaBuild {
      pname = "org-transclusion";
      version = "1.4.0";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/org-transclusion-1.4.0.tar";
        sha256 = "0ci6xja3jkj1a9f76sf3780gcjrdpbds2y2bwba3b55fjmr1fscl";
      };

      ename = "org-transclusion";
      packageRequires = [ org ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/org-transclusion.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  org-translate = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      org,
    }:
    elpaBuild {
      pname = "org-translate";
      version = "0.1.4";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/org-translate-0.1.4.tar";
        sha256 = "0s0vqpncb6rvhpxdir5ghanjyhpw7bplqfh3bpgri5ay2b46kj4f";
      };

      ename = "org-translate";
      packageRequires = [ org ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/org-translate.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  orgalist = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "orgalist";
      version = "1.16";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/orgalist-1.16.tar";
        sha256 = "0j78g12q66piclraa2nvd1h4ri8d6cnw5jahw6k5zi4xfjag6yx3";
      };

      ename = "orgalist";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/orgalist.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  osc = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "osc";
      version = "0.4";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/osc-0.4.tar";
        sha256 = "1ls6v0mkh7z90amrlczrvv6mgpv6hzzjw0zlxjlzsj2vr1gz3vca";
      };

      ename = "osc";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/osc.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  osm = callPackage (
    {
      lib,
      fetchurl,
      compat,
      elpaBuild,
    }:
    elpaBuild {
      pname = "osm";
      version = "2.3";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/osm-2.3.tar";
        sha256 = "0x08qbdk7y05cm8kc35f2i6k5xnd9iyyhr0f0fyi489kbvd3n1nh";
      };

      ename = "osm";
      packageRequires = [ compat ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/osm.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  other-frame-window = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "other-frame-window";
      version = "1.0.6";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/other-frame-window-1.0.6.tar";
        sha256 = "1x8i6hbl48vmp5h43drr35lwaiwhcyr3vnk7rcyim5jl2ijw8yc0";
      };

      ename = "other-frame-window";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/other-frame-window.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  pabbrev = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "pabbrev";
      version = "4.3.0";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/pabbrev-4.3.0.tar";
        sha256 = "1fplbmzqz066gsmvmf2indg4n348vdgs2m34dm32gnrjghfrxxhs";
      };

      ename = "pabbrev";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/pabbrev.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  paced = callPackage (
    {
      lib,
      fetchurl,
      async,
      elpaBuild,
    }:
    elpaBuild {
      pname = "paced";
      version = "1.1.3";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/paced-1.1.3.tar";
        sha256 = "0j2362zq22j6qma6bb6jh6qpd12zrc161pgl9cfhnq5m3s9i1sz4";
      };

      ename = "paced";
      packageRequires = [ async ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/paced.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  package-x = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "package-x";
      version = "1.0";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/package-x-1.0.tar";
        sha256 = "1wzwpqy992qv4jizx6fv6r1aw46gjzk49f4vv178bmshz03vndrx";
      };

      ename = "package-x";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/package-x.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  parsec = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      cl-lib ? null,
    }:
    elpaBuild {
      pname = "parsec";
      version = "0.1.3";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/parsec-0.1.3.tar";
        sha256 = "032m9iks5a05vbc4159dfs9b7shmqm6mk05jgbs9ndvy400drwd6";
      };

      ename = "parsec";
      packageRequires = [ cl-lib ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/parsec.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  parser-generator = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "parser-generator";
      version = "0.2.9";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/parser-generator-0.2.9.tar";
        sha256 = "1nbj18bb66garf59gq18gslnb8ngxa04d3567z0d9gp245nxr9w4";
      };

      ename = "parser-generator";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/parser-generator.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  path-iterator = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "path-iterator";
      version = "1.0";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/path-iterator-1.0.tar";
        sha256 = "0v9gasc0wlqd7pks6k3695md7mdfnaknh6xinmp4pkvvalfh7shv";
      };

      ename = "path-iterator";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/path-iterator.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  peg = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "peg";
      version = "1.0.2";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/peg-1.0.2.tar";
        sha256 = "133ngzl4chk63a8d3wh5k9zkmbfj9ag639yrk9i5zq1xa2aihcxb";
      };

      ename = "peg";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/peg.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  perl-doc = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "perl-doc";
      version = "0.82";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/perl-doc-0.82.tar";
        sha256 = "1fj13361a9pgmlda8yix0p805r2gwzv1gxf43pq6y79a8hxbm8yn";
      };

      ename = "perl-doc";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/perl-doc.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  persist = callPackage (
    {
      lib,
      fetchurl,
      compat,
      elpaBuild,
    }:
    elpaBuild {
      pname = "persist";
      version = "0.8";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/persist-0.8.tar";
        sha256 = "0lx4phndjr6x2bwlak0z232968vnzhnivq25531ykv4c4f45qyhj";
      };

      ename = "persist";
      packageRequires = [ compat ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/persist.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  php-fill = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "php-fill";
      version = "1.1.2";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/php-fill-1.1.2.tar";
        sha256 = "0r1zmin3wv8sqzgw6zbvbb7wix7d6h6s798f9r05w6g9m1vf0r5r";
      };

      ename = "php-fill";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/php-fill.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  phpinspect = callPackage (
    {
      lib,
      fetchurl,
      compat,
      elpaBuild,
    }:
    elpaBuild {
      pname = "phpinspect";
      version = "3.0.1";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/phpinspect-3.0.1.tar";
        sha256 = "138ipsmhhycm50a37kcx780j995xm0l2icrn2cjiw955fjf96rv7";
      };

      ename = "phpinspect";
      packageRequires = [ compat ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/phpinspect.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  phps-mode = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "phps-mode";
      version = "0.4.52";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/phps-mode-0.4.52.tar";
        sha256 = "00cspfmy6c5vkcbaj7dw5w068f1849wvzw5hdp0yxyqgw7wrfdfp";
      };

      ename = "phps-mode";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/phps-mode.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  pinentry = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "pinentry";
      version = "0.1";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/pinentry-0.1.tar";
        sha256 = "0i5g4yj2qva3rp8ay2fl9gcmp7q42caqryjyni8r5h4f3misviwq";
      };

      ename = "pinentry";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/pinentry.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  plz = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "plz";
      version = "0.9.1";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/plz-0.9.1.tar";
        sha256 = "0kx8zjqczsqhxd95bdy9b0kkpgkva4zq549d2hcfrkqhrqivm6qd";
      };

      ename = "plz";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/plz.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  plz-event-source = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      plz-media-type,
    }:
    elpaBuild {
      pname = "plz-event-source";
      version = "0.1.3";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/plz-event-source-0.1.3.tar";
        sha256 = "1ayi272pvbblynrxhh51adq34jdjp6j2wfzwry7ysq0fz8vxs7nj";
      };

      ename = "plz-event-source";
      packageRequires = [ plz-media-type ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/plz-event-source.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  plz-media-type = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      plz,
    }:
    elpaBuild {
      pname = "plz-media-type";
      version = "0.2.4";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/plz-media-type-0.2.4.tar";
        sha256 = "1gsq86zb3bsasryafhgxbln2sy1w722iz61pd6fi4j6xszb5pb32";
      };

      ename = "plz-media-type";
      packageRequires = [ plz ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/plz-media-type.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  plz-see = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      plz,
    }:
    elpaBuild {
      pname = "plz-see";
      version = "0.1";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/plz-see-0.1.tar";
        sha256 = "1mi35d9b26d425v1kkmmbh477klcxf76fnyg154ddjm0nkgqq90d";
      };

      ename = "plz-see";
      packageRequires = [ plz ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/plz-see.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  po-mode = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "po-mode";
      version = "2.32";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/po-mode-2.32.tar";
        sha256 = "0s83gjzmjqn3b80wrha7g9jp329df9qrzs66h2v6dv2inkdasn42";
      };

      ename = "po-mode";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/po-mode.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  poke = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "poke";
      version = "3.2";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/poke-3.2.tar";
        sha256 = "15j4g5y427d9mja2irv3ak6x60ik4kpnscnwl9pqym7qly7sa3v9";
      };

      ename = "poke";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/poke.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  poke-mode = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "poke-mode";
      version = "3.1";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/poke-mode-3.1.tar";
        sha256 = "0g4vd26ahkmjxlcvqwd0mbk60qaf6c9zba9x7bb9pqabka9438y1";
      };

      ename = "poke-mode";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/poke-mode.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  poker = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "poker";
      version = "0.2";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/poker-0.2.tar";
        sha256 = "10lfc6i4f08ydxanidwiq9404h4nxfa0vh4av5rrj6snqzqvd1bw";
      };

      ename = "poker";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/poker.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  popper = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "popper";
      version = "0.4.8";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/popper-0.4.8.tar";
        sha256 = "1i667qablblr8s614j1p6zfyqkwci56fpycb8hbxap6fpirgmv9x";
      };

      ename = "popper";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/popper.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  posframe = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "posframe";
      version = "1.5.2";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/posframe-1.5.2.tar";
        sha256 = "0ywbcwm3sh01vc4nc2ra3b09gri2lgz838gjxgsflv9g3si1918x";
      };

      ename = "posframe";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/posframe.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  pq = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "pq";
      version = "0.2";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/pq-0.2.tar";
        sha256 = "0d8ylsbmypaj29w674a4k445zr6hnggic8rsv7wx7jml6p2zph2n";
      };

      ename = "pq";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/pq.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  preview-auto = callPackage (
    {
      lib,
      fetchurl,
      auctex,
      elpaBuild,
    }:
    elpaBuild {
      pname = "preview-auto";
      version = "0.4.2";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/preview-auto-0.4.2.tar";
        sha256 = "1fg4nxzqjk13q9yvhrjmm9qqrszf9xd2n9jfji2v31f0rphlkc3p";
      };

      ename = "preview-auto";
      packageRequires = [ auctex ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/preview-auto.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  preview-tailor = callPackage (
    {
      lib,
      fetchurl,
      auctex,
      elpaBuild,
    }:
    elpaBuild {
      pname = "preview-tailor";
      version = "0.2.1";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/preview-tailor-0.2.1.tar";
        sha256 = "1bgvfgzr3d072yyi69y03080cb1hy82ryg56wvl29gw70bdg1y50";
      };

      ename = "preview-tailor";
      packageRequires = [ auctex ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/preview-tailor.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  project = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      xref,
    }:
    elpaBuild {
      pname = "project";
      version = "0.11.2";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/project-0.11.2.tar";
        sha256 = "0gyjdqxsblsmh2higkr2a6vfl051hpqzm0pxrzwsg2766xmldgqk";
      };

      ename = "project";
      packageRequires = [ xref ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/project.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  psgml = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "psgml";
      version = "1.3.5";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/psgml-1.3.5.tar";
        sha256 = "1lfk95kr43az6ykfyhj7ygccw3ms2ifyyp43w9lwm5fcawgc8952";
      };

      ename = "psgml";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/psgml.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  pspp-mode = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "pspp-mode";
      version = "1.1";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/pspp-mode-1.1.el";
        sha256 = "1qnwj7r367qs0ykw71c6s96ximgg2wb3hxg5fwsl9q2vfhbh35ca";
      };

      ename = "pspp-mode";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/pspp-mode.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  pulsar = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "pulsar";
      version = "1.3.4";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/pulsar-1.3.4.tar";
        sha256 = "09hxk1l8aaidiwlml4dl20ylwzdclghs0614wc4nglf3a6nvadjk";
      };

      ename = "pulsar";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/pulsar.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  pyim = callPackage (
    {
      lib,
      fetchurl,
      async,
      elpaBuild,
      xr,
    }:
    elpaBuild {
      pname = "pyim";
      version = "5.3.6";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/pyim-5.3.6.tar";
        sha256 = "00szld154fgbrrpn0p8lxbjg73kc9kx49x6lz2y5y2jm0yxn58gm";
      };

      ename = "pyim";

      packageRequires = [
        async
        xr
      ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/pyim.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  pyim-basedict = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      pyim,
    }:
    elpaBuild {
      pname = "pyim-basedict";
      version = "0.5.5";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/pyim-basedict-0.5.5.tar";
        sha256 = "04sfiywyrvilymg013gk81ya0ax6p24d4zyrjg8limjw0fn1b347";
      };

      ename = "pyim-basedict";
      packageRequires = [ pyim ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/pyim-basedict.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  python = callPackage (
    {
      lib,
      fetchurl,
      compat,
      elpaBuild,
      project,
      seq,
      flymake ? null,
    }:
    elpaBuild {
      pname = "python";
      version = "0.30";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/python-0.30.tar";
        sha256 = "1m8jmjkf5cgw0jr5j4ca525kllaf1ailx5mg2z4xzvqwxkzwhwxd";
      };

      ename = "python";

      packageRequires = [
        compat
        flymake
        project
        seq
      ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/python.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  quarter-plane = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "quarter-plane";
      version = "0.1";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/quarter-plane-0.1.tar";
        sha256 = "06syayqdmh4nb7ys52g1mw01wnz5hjv710dari106fk8fm9cy18c";
      };

      ename = "quarter-plane";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/quarter-plane.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  queue = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "queue";
      version = "0.2";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/queue-0.2.tar";
        sha256 = "117g6sl5dh7ssp6m18npvrqik5rs2mnr16129cfpnbi3crsw23c8";
      };

      ename = "queue";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/queue.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  rainbow-mode = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "rainbow-mode";
      version = "1.0.6";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/rainbow-mode-1.0.6.tar";
        sha256 = "0xv39jix1gbwq6f8laj93sqkf2j5hwda3l7mjqc7vsqjw1lkhmjv";
      };

      ename = "rainbow-mode";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/rainbow-mode.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  rbit = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "rbit";
      version = "0.1";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/rbit-0.1.tar";
        sha256 = "1xfl3m53bdi25h8mp7s0zp1yy7436cfydxrgkfc31fsxkh009l9h";
      };

      ename = "rbit";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/rbit.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  rcirc-color = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "rcirc-color";
      version = "0.4.5";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/rcirc-color-0.4.5.tar";
        sha256 = "0sfwmi0sspj7sx1psij4fzq1knwva8706w0204mbjxsq2nh5s9f3";
      };

      ename = "rcirc-color";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/rcirc-color.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  rcirc-mentions = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "rcirc-mentions";
      version = "1.0.5";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/rcirc-mentions-1.0.5.tar";
        sha256 = "1qf3zsqjryqsx31y1dmmqdvny5w4f4z96mxb2ibj39ah9j2vgixb";
      };

      ename = "rcirc-mentions";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/rcirc-mentions.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  rcirc-menu = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "rcirc-menu";
      version = "1.1";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/rcirc-menu-1.1.el";
        sha256 = "0w77qlwlmx59v5894i96fldn6x4lliv4ddv8967vq1kfchn4w5mc";
      };

      ename = "rcirc-menu";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/rcirc-menu.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  rcirc-sqlite = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "rcirc-sqlite";
      version = "1.0.4";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/rcirc-sqlite-1.0.4.tar";
        sha256 = "0bxih4m3rn76lq5q2hbq04fb0yqfy848cqfzl7gii1qsrfplqcal";
      };

      ename = "rcirc-sqlite";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/rcirc-sqlite.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  realgud = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      load-relative,
      loc-changes,
      test-simple,
    }:
    elpaBuild {
      pname = "realgud";
      version = "1.6.0";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/realgud-1.6.0.tar";
        sha256 = "1z0dn55wgrqsql19psas4p2492hvnddfzsb5z6nha5268p0ax9i8";
      };

      ename = "realgud";

      packageRequires = [
        load-relative
        loc-changes
        test-simple
      ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/realgud.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  realgud-ipdb = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      realgud,
    }:
    elpaBuild {
      pname = "realgud-ipdb";
      version = "1.0.0";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/realgud-ipdb-1.0.0.tar";
        sha256 = "0zmgsrb15rmgszidx4arjazb6fz523q5w516z5k5cn92wfzfyncr";
      };

      ename = "realgud-ipdb";
      packageRequires = [ realgud ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/realgud-ipdb.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  realgud-jdb = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      load-relative,
      realgud,
      cl-lib ? null,
    }:
    elpaBuild {
      pname = "realgud-jdb";
      version = "1.0.0";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/realgud-jdb-1.0.0.tar";
        sha256 = "081lqsxbg6cxv8hz8s0z2gbdif9drp5b0crbixmwf164i4h8l4gc";
      };

      ename = "realgud-jdb";

      packageRequires = [
        cl-lib
        load-relative
        realgud
      ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/realgud-jdb.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  realgud-lldb = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      load-relative,
      realgud,
    }:
    elpaBuild {
      pname = "realgud-lldb";
      version = "1.0.2";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/realgud-lldb-1.0.2.tar";
        sha256 = "1g4spjrldyi9rrh5dwrcqpz5qm37fq2qpvmirxvdqgfbwl6gapzj";
      };

      ename = "realgud-lldb";

      packageRequires = [
        load-relative
        realgud
      ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/realgud-lldb.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  realgud-node-debug = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      load-relative,
      realgud,
      cl-lib ? null,
    }:
    elpaBuild {
      pname = "realgud-node-debug";
      version = "1.0.0";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/realgud-node-debug-1.0.0.tar";
        sha256 = "1wyh6apy289a3qa1bnwv68x8pjkpqy4m18ygqnr4x759hjkq3nir";
      };

      ename = "realgud-node-debug";

      packageRequires = [
        cl-lib
        load-relative
        realgud
      ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/realgud-node-debug.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  realgud-node-inspect = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      load-relative,
      realgud,
      cl-lib ? null,
    }:
    elpaBuild {
      pname = "realgud-node-inspect";
      version = "1.0.0";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/realgud-node-inspect-1.0.0.tar";
        sha256 = "16cx0rq4zx5k0y75j044dbqzrzs1df3r95rissmhfgsi5m2qf1h2";
      };

      ename = "realgud-node-inspect";

      packageRequires = [
        cl-lib
        load-relative
        realgud
      ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/realgud-node-inspect.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  realgud-trepan-ni = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      load-relative,
      realgud,
      cl-lib ? null,
    }:
    elpaBuild {
      pname = "realgud-trepan-ni";
      version = "1.0.1";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/realgud-trepan-ni-1.0.1.tar";
        sha256 = "09vllklpfc0q28ankp2s1v10kwnxab4g6hb9zn63d1rfa92qy44k";
      };

      ename = "realgud-trepan-ni";

      packageRequires = [
        cl-lib
        load-relative
        realgud
      ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/realgud-trepan-ni.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  realgud-trepan-xpy = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      load-relative,
      realgud,
    }:
    elpaBuild {
      pname = "realgud-trepan-xpy";
      version = "1.0.1";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/realgud-trepan-xpy-1.0.1.tar";
        sha256 = "13fll0c6p2idg56q0czgv6s00vvb585b40dn3b14hdpy0givrc0x";
      };

      ename = "realgud-trepan-xpy";

      packageRequires = [
        load-relative
        realgud
      ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/realgud-trepan-xpy.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  rec-mode = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "rec-mode";
      version = "1.9.4";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/rec-mode-1.9.4.tar";
        sha256 = "0pi483g5qgz6gvyi13a4ldfbkaad3xkad08aqfcnmsdylvc9zzma";
      };

      ename = "rec-mode";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/rec-mode.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  register-list = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "register-list";
      version = "0.1";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/register-list-0.1.tar";
        sha256 = "01w2yyvbmnkjrmx5f0dk0327c0k7fvmgi928j6hbvlrp5wk6s394";
      };

      ename = "register-list";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/register-list.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  relint = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      xr,
    }:
    elpaBuild {
      pname = "relint";
      version = "2.2";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/relint-2.2.tar";
        sha256 = "01x0134f3z7vh7b730lfrsnpwqqjj65z291gpm8qyai9fimljsn3";
      };

      ename = "relint";
      packageRequires = [ xr ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/relint.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  repology = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "repology";
      version = "1.2.4";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/repology-1.2.4.tar";
        sha256 = "0nj4dih9mv8crqq8rd4k8dzgq7l0195syfxsf2gyikmqz9sjbr85";
      };

      ename = "repology";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/repology.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  rich-minority = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      cl-lib ? null,
    }:
    elpaBuild {
      pname = "rich-minority";
      version = "1.0.3";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/rich-minority-1.0.3.tar";
        sha256 = "0npk6gnr2m4mfv40y2m265lxk1dyn8fd6d90vs3j2xrhpybgbln2";
      };

      ename = "rich-minority";
      packageRequires = [ cl-lib ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/rich-minority.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  rnc-mode = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "rnc-mode";
      version = "0.4";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/rnc-mode-0.4.tar";
        sha256 = "1igg829mm6n35mpfp254276ib3x7x7wxdg9zm38yf5n3bmjq7cxf";
      };

      ename = "rnc-mode";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/rnc-mode.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  rt-liberation = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "rt-liberation";
      version = "7";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/rt-liberation-7.tar";
        sha256 = "0bi1qyc4n4ar0rblnddmlrlrkdvdrvv54wg4ii39hhxij4p6niif";
      };

      ename = "rt-liberation";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/rt-liberation.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  ruby-end = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "ruby-end";
      version = "0.4.3";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/ruby-end-0.4.3.tar";
        sha256 = "07175v9fy96lmkfa0007lhx7v3fkk77iwca3rjl94dgdp4b8lbk5";
      };

      ename = "ruby-end";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/ruby-end.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  rudel = callPackage (
    {
      lib,
      fetchurl,
      cl-generic,
      elpaBuild,
      cl-lib ? null,
      cl-print ? null,
    }:
    elpaBuild {
      pname = "rudel";
      version = "0.3.2";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/rudel-0.3.2.tar";
        sha256 = "00rs2fy64ybam26szpc93miwajq42acyh0dkg0ixr95mg49sc46j";
      };

      ename = "rudel";

      packageRequires = [
        cl-generic
        cl-lib
        cl-print
      ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/rudel.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  satchel = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      project,
    }:
    elpaBuild {
      pname = "satchel";
      version = "0.2";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/satchel-0.2.tar";
        sha256 = "115rkq2ygawsg8ph44zfqwsd9ykm4370v0whgjwhc1wx2iyn5ir9";
      };

      ename = "satchel";
      packageRequires = [ project ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/satchel.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  scanner = callPackage (
    {
      lib,
      fetchurl,
      dash,
      elpaBuild,
    }:
    elpaBuild {
      pname = "scanner";
      version = "0.3";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/scanner-0.3.tar";
        sha256 = "07cqbphpgcqz2bb204c26mh3pc4h4z792dz9pxh1fjwh4d0iasqy";
      };

      ename = "scanner";
      packageRequires = [ dash ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/scanner.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  scroll-restore = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "scroll-restore";
      version = "1.0";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/scroll-restore-1.0.tar";
        sha256 = "1i9ld1l5h2cpzf8bzk7nlk2bcln48gya8zrq79v6rawbrwdlz2z4";
      };

      ename = "scroll-restore";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/scroll-restore.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  sed-mode = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "sed-mode";
      version = "1.1";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/sed-mode-1.1.tar";
        sha256 = "0zhga0xsffdcinh10di046n6wbx35gi1zknnqzgm9wvnm2iqxlyn";
      };

      ename = "sed-mode";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/sed-mode.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  seq = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "seq";
      version = "2.24";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/seq-2.24.tar";
        sha256 = "13x8l1m5if6jpc8sbrbx9r64fyhh450ml6vfm92p6i5wv6gl74w6";
      };

      ename = "seq";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/seq.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  setup = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "setup";
      version = "1.5.0";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/setup-1.5.0.tar";
        sha256 = "184g3kd9caxyhwq41w94spkjs1j45vblg4sqfb5h5pqb5h9p95n5";
      };

      ename = "setup";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/setup.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  shelisp = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "shelisp";
      version = "1.0.0";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/shelisp-1.0.0.tar";
        sha256 = "0zhkk04nj25lmpdlqblfhx3rb415w2f58f7wb19k1s2ry4k7m15g";
      };

      ename = "shelisp";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/shelisp.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  shell-command-plus = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "shell-command-plus";
      version = "2.5.0";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/shell-command+-2.5.0.tar";
        sha256 = "0svmrar0blgq3ffg9sll6b5vnqi1nw7snkbl04x2s9qln2i88dzx";
      };

      ename = "shell-command+";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/shell-command+.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  shen-mode = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "shen-mode";
      version = "0.1";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/shen-mode-0.1.tar";
        sha256 = "0xskyd0d3krwgrpca10m7l7c0l60qq7jjn2q207n61yw5yx71pqn";
      };

      ename = "shen-mode";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/shen-mode.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  shift-number = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "shift-number";
      version = "0.3";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/shift-number-0.3.tar";
        sha256 = "0vqwy0ai4f1ga4j2inl2s1ly0v9i3fmqyd0p28fgyx3f23c83jqn";
      };

      ename = "shift-number";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/shift-number.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  show-font = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "show-font";
      version = "1.0.0";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/show-font-1.0.0.tar";
        sha256 = "1caga09ypj6vb4vziw6slvhkjbzj6a3vss9lbgbigzb4m6q8caqf";
      };

      ename = "show-font";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/show-font.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  sisu-mode = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "sisu-mode";
      version = "7.1.8";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/sisu-mode-7.1.8.tar";
        sha256 = "02cfyrjynwvf2rlnkfy8285ga9kzbg1b614sch0xnxqw81mp7drp";
      };

      ename = "sisu-mode";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/sisu-mode.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  site-lisp = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "site-lisp";
      version = "0.3.0";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/site-lisp-0.3.0.tar";
        sha256 = "0wbxx6n42sqd0857nq0fd3dz04d27vj00vyi75g9k5hr2fa6racc";
      };

      ename = "site-lisp";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/site-lisp.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  sketch-mode = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "sketch-mode";
      version = "1.0.4";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/sketch-mode-1.0.4.tar";
        sha256 = "1vrbmyhf9bffy2fkz91apzxla6v8nbv2wb25vxcr9x3smbag9kal";
      };

      ename = "sketch-mode";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/sketch-mode.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  slime-volleyball = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      cl-lib ? null,
    }:
    elpaBuild {
      pname = "slime-volleyball";
      version = "1.2.0";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/slime-volleyball-1.2.0.tar";
        sha256 = "1qlmsxnhja8p873rvb1qj4xsf938bs3hl8qqqsmrm0csvlb9737p";
      };

      ename = "slime-volleyball";
      packageRequires = [ cl-lib ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/slime-volleyball.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  sm-c-mode = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "sm-c-mode";
      version = "1.2";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/sm-c-mode-1.2.tar";
        sha256 = "0xykl8wkbw5y7ah79zlfzz1k0di9ghfsv2xjxwx7rrb37wny5184";
      };

      ename = "sm-c-mode";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/sm-c-mode.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  smalltalk-mode = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "smalltalk-mode";
      version = "4.0";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/smalltalk-mode-4.0.tar";
        sha256 = "0ly2qmsbmzd5nd7iaighws10y0yj7p2356fw32pkp0cmzzvc3d54";
      };

      ename = "smalltalk-mode";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/smalltalk-mode.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  smart-yank = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "smart-yank";
      version = "0.1.1";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/smart-yank-0.1.1.tar";
        sha256 = "08dc4c60jcjyiixyzckxk5qk6s2pl1jmrp4h1bj53ssd1kn4208m";
      };

      ename = "smart-yank";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/smart-yank.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  sml-mode = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      cl-lib ? null,
    }:
    elpaBuild {
      pname = "sml-mode";
      version = "6.12";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/sml-mode-6.12.tar";
        sha256 = "10zp0gi5rbjjxjzn9k6klvdms9k3yxx0qry0wa75a68sj5x2rdzh";
      };

      ename = "sml-mode";
      packageRequires = [ cl-lib ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/sml-mode.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  so-long = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "so-long";
      version = "1.1.2";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/so-long-1.1.2.tar";
        sha256 = "01qdxlsllpj5ajixkqf7v9p95zn9qnvjdnp30v54ymj2pd0d9a32";
      };

      ename = "so-long";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/so-long.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  soap-client = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      cl-lib ? null,
    }:
    elpaBuild {
      pname = "soap-client";
      version = "3.2.3";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/soap-client-3.2.3.tar";
        sha256 = "1yhs661g0vqxpxqcxgsxvljmrpcqzl0y52lz6jvfilmshw7r6k2s";
      };

      ename = "soap-client";
      packageRequires = [ cl-lib ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/soap-client.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  sokoban = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      cl-lib ? null,
    }:
    elpaBuild {
      pname = "sokoban";
      version = "1.4.9";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/sokoban-1.4.9.tar";
        sha256 = "1l3d4al96252kdhyn4dr88ir67kay57n985w0qy8p930ncrs846v";
      };

      ename = "sokoban";
      packageRequires = [ cl-lib ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/sokoban.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  sotlisp = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "sotlisp";
      version = "1.6.2";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/sotlisp-1.6.2.tar";
        sha256 = "0q65iwr89cwwqnc1kndf2agq5wp48a7k02qsksgaj0n6zv7i4dfn";
      };

      ename = "sotlisp";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/sotlisp.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  spacious-padding = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "spacious-padding";
      version = "0.8.0";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/spacious-padding-0.8.0.tar";
        sha256 = "17nxgal6972m07l0h48c73s2da4zyycl5gpyjn0j5jb2qxs2qxnp";
      };

      ename = "spacious-padding";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/spacious-padding.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  speedrect = callPackage (
    {
      lib,
      fetchurl,
      compat,
      elpaBuild,
    }:
    elpaBuild {
      pname = "speedrect";
      version = "0.7";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/speedrect-0.7.tar";
        sha256 = "0nxwwd12qqyxq1fg8n6miyx63fp29cvpfp8w33zmf9dhkcjwyfd1";
      };

      ename = "speedrect";
      packageRequires = [ compat ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/speedrect.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  spinner = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "spinner";
      version = "1.7.4";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/spinner-1.7.4.tar";
        sha256 = "0lq8q62q5an8199p8pyafg5l6hdnnqi6i6sybnk60sdcqy62pa6r";
      };

      ename = "spinner";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/spinner.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  sql-beeline = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "sql-beeline";
      version = "0.2";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/sql-beeline-0.2.tar";
        sha256 = "0ngvvfhs1fj3ca5g563bssaz9ac5fiqkqzv09s4ramalp2q6axq9";
      };

      ename = "sql-beeline";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/sql-beeline.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  sql-cassandra = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "sql-cassandra";
      version = "0.2.2";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/sql-cassandra-0.2.2.tar";
        sha256 = "154rymq0k6869cw7sc7nhx3di5qv1ffgf8shkxc22gvkrj2s7p9b";
      };

      ename = "sql-cassandra";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/sql-cassandra.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  sql-indent = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      cl-lib ? null,
    }:
    elpaBuild {
      pname = "sql-indent";
      version = "1.7";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/sql-indent-1.7.tar";
        sha256 = "1yfb01wh5drgvrwbn0hgzyi0rc4zlr1w23d065x4qrld31jbka8i";
      };

      ename = "sql-indent";
      packageRequires = [ cl-lib ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/sql-indent.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  srht = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      plz,
      transient,
    }:
    elpaBuild {
      pname = "srht";
      version = "0.4";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/srht-0.4.tar";
        sha256 = "0ps49syzlaf4lxvji61y6y7r383r65v96d57hj75xkn6hvyrz74n";
      };

      ename = "srht";

      packageRequires = [
        plz
        transient
      ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/srht.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  ssh-deploy = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "ssh-deploy";
      version = "3.1.16";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/ssh-deploy-3.1.16.tar";
        sha256 = "0fb88l3270d7l808q8x16zcvjgsjbyhgifgv17syfsj0ja63x28p";
      };

      ename = "ssh-deploy";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/ssh-deploy.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  standard-themes = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      modus-themes,
    }:
    elpaBuild {
      pname = "standard-themes";
      version = "3.0.2";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/standard-themes-3.0.2.tar";
        sha256 = "071k6cxfb5ccipvb0059wcs9fq4pzywyahqwjrl4cbidv6dnvzcm";
      };

      ename = "standard-themes";
      packageRequires = [ modus-themes ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/standard-themes.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  stream = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "stream";
      version = "2.4.0";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/stream-2.4.0.tar";
        sha256 = "16wl1q7wikk0wyzfwjz16azq025dx4wdh1j9q0nadi68ygxi172b";
      };

      ename = "stream";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/stream.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  substitute = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "substitute";
      version = "0.5.0";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/substitute-0.5.0.tar";
        sha256 = "1l8jaqmmxsv10c7giy9paxq4jdsnikwgyhnkj2vnk9s9panjngbw";
      };

      ename = "substitute";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/substitute.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  svg = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "svg";
      version = "1.1";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/svg-1.1.tar";
        sha256 = "10x2rry349ibzd9awy4rg18cd376yvkzqsyq0fm4i05kq4dzqp4a";
      };

      ename = "svg";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/svg.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  svg-clock = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      svg,
    }:
    elpaBuild {
      pname = "svg-clock";
      version = "1.2";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/svg-clock-1.2.tar";
        sha256 = "0r0wayb1q0dd2yi1nqa0m4jfy36lydxxa6xvvd6amgh9sy499qs8";
      };

      ename = "svg-clock";
      packageRequires = [ svg ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/svg-clock.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  svg-lib = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "svg-lib";
      version = "0.3";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/svg-lib-0.3.tar";
        sha256 = "1s7n3j1yzprs9frb554c66pcrv3zss1y26y6qgndii4bbzpa7jh8";
      };

      ename = "svg-lib";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/svg-lib.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  svg-tag-mode = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      svg-lib,
    }:
    elpaBuild {
      pname = "svg-tag-mode";
      version = "0.3.3";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/svg-tag-mode-0.3.3.tar";
        sha256 = "14vkjy3dvvvkhxi3m8d56m0dpvg9gpbwmmb0dchz8ap8wjbvc85j";
      };

      ename = "svg-tag-mode";
      packageRequires = [ svg-lib ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/svg-tag-mode.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  swiper = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      ivy,
    }:
    elpaBuild {
      pname = "swiper";
      version = "0.15.1";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/swiper-0.15.1.tar";
        sha256 = "0m70jgcdsbrj6i5b1srrdgzkwavzi098532fv6vi2051nl42snvz";
      };

      ename = "swiper";
      packageRequires = [ ivy ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/swiper.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  switchy-window = callPackage (
    {
      lib,
      fetchurl,
      compat,
      elpaBuild,
    }:
    elpaBuild {
      pname = "switchy-window";
      version = "1.4";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/switchy-window-1.4.tar";
        sha256 = "1y8a791d1qmmvsjj39fs4rr3zx77xbxc7z21fchwqr5hjhs5gxc9";
      };

      ename = "switchy-window";
      packageRequires = [ compat ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/switchy-window.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  sxhkdrc-mode = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "sxhkdrc-mode";
      version = "1.2.0";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/sxhkdrc-mode-1.2.0.tar";
        sha256 = "0a4r06cxgqkvx2vv94icy096kg5v1qf637gmgwrgg0i4w49hk5jk";
      };

      ename = "sxhkdrc-mode";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/sxhkdrc-mode.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  system-packages = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "system-packages";
      version = "1.1.2";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/system-packages-1.1.2.tar";
        sha256 = "0zjblm8jsyi2vkgnclkap5f9j2iakaf1lpajqi3s4qryrfq7rf68";
      };

      ename = "system-packages";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/system-packages.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  tNFA = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      queue,
    }:
    elpaBuild {
      pname = "tNFA";
      version = "0.1.1";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/tNFA-0.1.1.el";
        sha256 = "01n4p8lg8f2k55l2z77razb2sl202qisjqm5lff96a2kxnxinsds";
      };

      ename = "tNFA";
      packageRequires = [ queue ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/tNFA.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  tam = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      queue,
    }:
    elpaBuild {
      pname = "tam";
      version = "0.1";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/tam-0.1.tar";
        sha256 = "16ms55cwm2cwixl03a3bbsqs159c3r3dv5kaazvsghby6c511bx8";
      };

      ename = "tam";
      packageRequires = [ queue ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/tam.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  taxy = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "taxy";
      version = "0.10.2";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/taxy-0.10.2.tar";
        sha256 = "1nmlx2rvlgzvmz1h3s5yn3qnad12pn2a83gjzxf3ln79p8rv1mj6";
      };

      ename = "taxy";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/taxy.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  taxy-magit-section = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      magit-section,
      taxy,
    }:
    elpaBuild {
      pname = "taxy-magit-section";
      version = "0.14.3";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/taxy-magit-section-0.14.3.tar";
        sha256 = "16j1a2vx9awr5vk1x3i1m526ym6836zxlypx1f50fcwjy0w8q8a3";
      };

      ename = "taxy-magit-section";

      packageRequires = [
        magit-section
        taxy
      ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/taxy-magit-section.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  temp-buffer-browse = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "temp-buffer-browse";
      version = "1.5";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/temp-buffer-browse-1.5.tar";
        sha256 = "00hbh25fj5fm9dsp8fpdk8lap3gi5jlva6f0m6kvjqnmvc06q36r";
      };

      ename = "temp-buffer-browse";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/temp-buffer-browse.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  tempel = callPackage (
    {
      lib,
      fetchurl,
      compat,
      elpaBuild,
    }:
    elpaBuild {
      pname = "tempel";
      version = "1.13";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/tempel-1.13.tar";
        sha256 = "1sxyxz799nw56wqrm7hsr0dq2yaxckr9a1rynw2jsrfhbzcxpbfp";
      };

      ename = "tempel";
      packageRequires = [ compat ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/tempel.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  termint = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "termint";
      version = "0.2.3";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/termint-0.2.3.tar";
        sha256 = "1yir074lihlr2y78a58jm233a6s807j8d8fvlvv6b62wm0036frk";
      };

      ename = "termint";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/termint.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  test-simple = callPackage (
    {
      lib,
      fetchurl,
      compat,
      elpaBuild,
    }:
    elpaBuild {
      pname = "test-simple";
      version = "1.3.2";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/test-simple-1.3.2.tar";
        sha256 = "1pw60mpjncapgzgsgml8xsy2bkpmw1p082q427vl9g8lxiq555qb";
      };

      ename = "test-simple";
      packageRequires = [ compat ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/test-simple.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  tex-item = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "tex-item";
      version = "0.1";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/tex-item-0.1.tar";
        sha256 = "0ggbn3lk64cv6pnw97ww7vn250jchj80zx3hvkcqlccyw34x6ziy";
      };

      ename = "tex-item";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/tex-item.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  tex-parens = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "tex-parens";
      version = "0.7";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/tex-parens-0.7.tar";
        sha256 = "1h3l4kn154mmzxgz6s7y2qrkpqk4ava3j1iwx07gsgnr5pcpgvfr";
      };

      ename = "tex-parens";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/tex-parens.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  theme-buffet = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "theme-buffet";
      version = "0.1.2";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/theme-buffet-0.1.2.tar";
        sha256 = "1cfrrl41rlxdbybvxs8glkgmgkznwgpq70h58rkvwm6b5jfs8wv0";
      };

      ename = "theme-buffet";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/theme-buffet.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  timeout = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "timeout";
      version = "2.1.6";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/timeout-2.1.6.tar";
        sha256 = "08lijbbbx2wx64jn6l5820phkmi6cagym1239zj1hx25h28b2h0r";
      };

      ename = "timeout";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/timeout.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  timerfunctions = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      cl-lib ? null,
    }:
    elpaBuild {
      pname = "timerfunctions";
      version = "1.4.2";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/timerfunctions-1.4.2.el";
        sha256 = "122q8nv08pz1mkgilvi9qfrs7rsnc5picr7jyz2jpnvpd9qw6jw5";
      };

      ename = "timerfunctions";
      packageRequires = [ cl-lib ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/timerfunctions.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  tiny = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "tiny";
      version = "0.2.1";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/tiny-0.2.1.tar";
        sha256 = "1cr73a8gba549ja55x0c2s554f3zywf69zbnd7v82jz5q1k9wd2v";
      };

      ename = "tiny";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/tiny.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  tmr = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "tmr";
      version = "1.3.0";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/tmr-1.3.0.tar";
        sha256 = "0sv0kaz8z0lldkcplyzh7k99s4jqj3bzr9gb5mqjwpp747hj0qlq";
      };

      ename = "tmr";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/tmr.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  tomelr = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      map,
      seq,
    }:
    elpaBuild {
      pname = "tomelr";
      version = "0.4.3";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/tomelr-0.4.3.tar";
        sha256 = "0r2f4dl10fl75ygvbmb4vkqixy24k0z2wpr431ljzp5m29bn74kh";
      };

      ename = "tomelr";

      packageRequires = [
        map
        seq
      ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/tomelr.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  topspace = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "topspace";
      version = "0.3.1";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/topspace-0.3.1.tar";
        sha256 = "0m8z2q1gdi0zfh1df5xb2v0sg1v5fysrl00fv2qqgnd61c2n0hhz";
      };

      ename = "topspace";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/topspace.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  track-changes = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "track-changes";
      version = "1.5";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/track-changes-1.5.tar";
        sha256 = "0ylvxd5iijihqa5l9w6k6hmwaf09hw98k4f9g2hxfbn8sifvgb53";
      };

      ename = "track-changes";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/track-changes.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  tramp = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "tramp";
      version = "2.8.1.5";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/tramp-2.8.1.5.tar";
        sha256 = "04rhm5ijx3qs386ffxvp2117a4xn7zw6z5cqci77f6q07i5921zw";
      };

      ename = "tramp";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/tramp.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  tramp-hlo = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      tramp,
    }:
    elpaBuild {
      pname = "tramp-hlo";
      version = "0.0.2";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/tramp-hlo-0.0.2.tar";
        sha256 = "1bs3wz644ibc332nxzf880zklmwsfwhlimdvamas3568ns21xqn0";
      };

      ename = "tramp-hlo";
      packageRequires = [ tramp ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/tramp-hlo.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  tramp-nspawn = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "tramp-nspawn";
      version = "1.0.2";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/tramp-nspawn-1.0.2.tar";
        sha256 = "1n1bb56zzzy4rw2510pnp0k6ax48jwdzqrx6cfrw1pjgclrn1xn9";
      };

      ename = "tramp-nspawn";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/tramp-nspawn.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  tramp-theme = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "tramp-theme";
      version = "0.3";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/tramp-theme-0.3.tar";
        sha256 = "1v9265cnk858jl522zcnqf2cv3f3g93f0mk52plz3n4a8k5nlfa7";
      };

      ename = "tramp-theme";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/tramp-theme.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  transcribe = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "transcribe";
      version = "1.5.2";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/transcribe-1.5.2.tar";
        sha256 = "1v1bvcv3zqrj073l3vw7gz20rpa9p86rf1yv219n47kmh27c80hq";
      };

      ename = "transcribe";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/transcribe.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  transient = callPackage (
    {
      lib,
      fetchurl,
      compat,
      cond-let,
      elpaBuild,
      seq,
    }:
    elpaBuild {
      pname = "transient";
      version = "0.13.4";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/transient-0.13.4.tar";
        sha256 = "02142xcxv50bycshbl6qj47q6s9gi6sbagrnyjqi5ma74509zq6h";
      };

      ename = "transient";

      packageRequires = [
        compat
        cond-let
        seq
      ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/transient.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  transient-cycles = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "transient-cycles";
      version = "2.0";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/transient-cycles-2.0.tar";
        sha256 = "0cq2k77rgbw3fx84a2d33nbb75wqxynrc1mx4gb32a9ysm0sa4s3";
      };

      ename = "transient-cycles";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/transient-cycles.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  tree-inspector = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      treeview,
    }:
    elpaBuild {
      pname = "tree-inspector";
      version = "0.4";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/tree-inspector-0.4.tar";
        sha256 = "0v59kp1didml9k245m1v0s0ahh2r79cc0hp5ika93iamrdxkxaiz";
      };

      ename = "tree-inspector";
      packageRequires = [ treeview ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/tree-inspector.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  trie = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      heap,
      tNFA,
    }:
    elpaBuild {
      pname = "trie";
      version = "0.6";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/trie-0.6.tar";
        sha256 = "1jvhvvxkxbbpy93x9kpznvp2hqkkbdbbjaj27fd0wkbijg0k03ln";
      };

      ename = "trie";

      packageRequires = [
        heap
        tNFA
      ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/trie.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  triples = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      seq,
    }:
    elpaBuild {
      pname = "triples";
      version = "0.6.2";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/triples-0.6.2.tar";
        sha256 = "1yis6q14m8pkhpllgldq6pw366cgw5wsnh7d1484gs3grcq4mgsr";
      };

      ename = "triples";
      packageRequires = [ seq ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/triples.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  truename-cache = callPackage (
    {
      lib,
      fetchurl,
      compat,
      elpaBuild,
    }:
    elpaBuild {
      pname = "truename-cache";
      version = "0.3.7";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/truename-cache-0.3.7.tar";
        sha256 = "03gxa6wvjdq91nqq1vy28951d0qc1yrnhnzk2lw2qk6h9njp4sl8";
      };

      ename = "truename-cache";
      packageRequires = [ compat ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/truename-cache.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  trust-manager = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "trust-manager";
      version = "0.4.1";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/trust-manager-0.4.1.tar";
        sha256 = "1azp3kzkw76xbwsn6j94liy33d3swajc1v2h8ghczvxv8sw8khgj";
      };

      ename = "trust-manager";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/trust-manager.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  ulisp-repl = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "ulisp-repl";
      version = "1.0.3";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/ulisp-repl-1.0.3.tar";
        sha256 = "1c23d66vydfp29px2dlvgl5xg91a0rh4w4b79q8ach533nfag3ia";
      };

      ename = "ulisp-repl";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/ulisp-repl.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  undo-tree = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      queue,
    }:
    elpaBuild {
      pname = "undo-tree";
      version = "0.8.2";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/undo-tree-0.8.2.tar";
        sha256 = "0ad1zhkjdf73j3b2i8nd7f10jlqqvcaa852yycms4jr636xw6ms6";
      };

      ename = "undo-tree";
      packageRequires = [ queue ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/undo-tree.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  uni-confusables = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "uni-confusables";
      version = "0.3";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/uni-confusables-0.3.tar";
        sha256 = "08150kgqsbcpykvf8m2b25y386h2b4pj08vffm6wh4f000wr72k3";
      };

      ename = "uni-confusables";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/uni-confusables.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  uniquify-files = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "uniquify-files";
      version = "1.0.4";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/uniquify-files-1.0.4.tar";
        sha256 = "0xw2l49xhdy5qgwja8bkiq2ibdppl45xzqlr17z92l1vfq4akpzp";
      };

      ename = "uniquify-files";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/uniquify-files.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  urgrep = callPackage (
    {
      lib,
      fetchurl,
      compat,
      elpaBuild,
      project,
    }:
    elpaBuild {
      pname = "urgrep";
      version = "0.6.0";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/urgrep-0.6.0.tar";
        sha256 = "0mgl3rzpc5lpk2fx7w0n9i72mwj636x31jfnp3dyfgr7srpf1ms6";
      };

      ename = "urgrep";

      packageRequires = [
        compat
        project
      ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/urgrep.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  url-http-ntlm = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      ntlm ? null,
    }:
    elpaBuild {
      pname = "url-http-ntlm";
      version = "2.0.6";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/url-http-ntlm-2.0.6.tar";
        sha256 = "06bfw1w128gg9b60pb3wcpcib33jf13y1niyhs6grhm7yq11waz2";
      };

      ename = "url-http-ntlm";
      packageRequires = [ ntlm ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/url-http-ntlm.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  url-http-oauth = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "url-http-oauth";
      version = "0.8.5";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/url-http-oauth-0.8.5.tar";
        sha256 = "17j1bzvg9a6k1fqkwphlkrqyihpgp5zia3hgbnjkz7j76adbxmgv";
      };

      ename = "url-http-oauth";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/url-http-oauth.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  url-scgi = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "url-scgi";
      version = "0.9";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/url-scgi-0.9.tar";
        sha256 = "19lvr4d2y9rd5gibaavp7ghkxmdh5zad9ynarbi2w4rjgmz5y981";
      };

      ename = "url-scgi";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/url-scgi.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  use-package = callPackage (
    {
      lib,
      fetchurl,
      bind-key,
      elpaBuild,
    }:
    elpaBuild {
      pname = "use-package";
      version = "2.4.6";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/use-package-2.4.6.tar";
        sha256 = "0idy78mpg9zikjqfg431q7fd34mwz18blvp6yq1bf29q582a9jyf";
      };

      ename = "use-package";
      packageRequires = [ bind-key ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/use-package.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  validate = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      seq,
      cl-lib ? null,
    }:
    elpaBuild {
      pname = "validate";
      version = "1.0.4";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/validate-1.0.4.tar";
        sha256 = "1bn25l62zcabg2ppxwr4049m1qd0yj095cflqrak0n50acgjs6w5";
      };

      ename = "validate";

      packageRequires = [
        cl-lib
        seq
      ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/validate.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  valign = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "valign";
      version = "3.1.1";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/valign-3.1.1.tar";
        sha256 = "16v2mmrih0ykk4z6qmy29gajjb3v83q978gzn3y6pg8y48b2wxpb";
      };

      ename = "valign";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/valign.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  vc-backup = callPackage (
    {
      lib,
      fetchurl,
      compat,
      elpaBuild,
    }:
    elpaBuild {
      pname = "vc-backup";
      version = "1.1.1";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/vc-backup-1.1.1.tar";
        sha256 = "0lalz700s7cppayjyv7bvmgzcfl9hk1w84i2q00k1ns84h4qzji1";
      };

      ename = "vc-backup";
      packageRequires = [ compat ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/vc-backup.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  vc-got = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "vc-got";
      version = "1.2";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/vc-got-1.2.tar";
        sha256 = "04m1frrnla4zc8db728280r9fbk50bgjkk4k7dizb0hawghk4r3p";
      };

      ename = "vc-got";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/vc-got.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  vc-hgcmd = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "vc-hgcmd";
      version = "1.14.1";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/vc-hgcmd-1.14.1.tar";
        sha256 = "0a8a4d9difrp2r6ac8micxn8ij96inba390324w087yxwqzkgk1g";
      };

      ename = "vc-hgcmd";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/vc-hgcmd.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  vc-jj = callPackage (
    {
      lib,
      fetchurl,
      compat,
      elpaBuild,
    }:
    elpaBuild {
      pname = "vc-jj";
      version = "0.5";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/vc-jj-0.5.tar";
        sha256 = "1xrv0m15ayx06hxw29k1migl0lq7cmmq2z1inygpwq81g7v3kp6d";
      };

      ename = "vc-jj";
      packageRequires = [ compat ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/vc-jj.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  vcard = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "vcard";
      version = "0.2.2";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/vcard-0.2.2.tar";
        sha256 = "0r56y3q2gigm8rxifly50m5h1k948y987541cqd8w207wf1b56bh";
      };

      ename = "vcard";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/vcard.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  vcl-mode = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "vcl-mode";
      version = "1.1";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/vcl-mode-1.1.tar";
        sha256 = "0zz664c263x24xzs7hk2mqchzplmx2dlba98d5fpy8ybdnziqfkj";
      };

      ename = "vcl-mode";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/vcl-mode.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  vdiff = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      hydra,
    }:
    elpaBuild {
      pname = "vdiff";
      version = "0.2.4";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/vdiff-0.2.4.tar";
        sha256 = "0crgb32dk0yzcgvjai0b67wcbcfppc3h0ppfqgdrim1nincbwc1m";
      };

      ename = "vdiff";
      packageRequires = [ hydra ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/vdiff.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  vecdb = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      pg,
      plz,
    }:
    elpaBuild {
      pname = "vecdb";
      version = "0.2.2";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/vecdb-0.2.2.tar";
        sha256 = "0nzaga79yls0x7hcrfvk6zic4a4pm5h10sav0f1pxccx1scsrzfn";
      };

      ename = "vecdb";

      packageRequires = [
        pg
        plz
      ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/vecdb.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  verilog-mode = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "verilog-mode";
      version = "2026.4.14.10117132";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/verilog-mode-2026.4.14.10117132.tar";
        sha256 = "0n699kpqhh1b023wswm938f7kxc983faw0bv4x70kq12y7h3slj1";
      };

      ename = "verilog-mode";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/verilog-mode.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  vertico = callPackage (
    {
      lib,
      fetchurl,
      compat,
      elpaBuild,
    }:
    elpaBuild {
      pname = "vertico";
      version = "2.10";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/vertico-2.10.tar";
        sha256 = "1kwmlpfxjnjkv05hfqhxmxw5d1vlhqvdmyc3p34qhp3bj2xafwm0";
      };

      ename = "vertico";
      packageRequires = [ compat ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/vertico.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  vertico-posframe = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      posframe,
      vertico,
    }:
    elpaBuild {
      pname = "vertico-posframe";
      version = "0.9.2";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/vertico-posframe-0.9.2.tar";
        sha256 = "1xq30aj2jkk1g4gnniixg0rzh03irf7vci551fwd6gg50sphaqj4";
      };

      ename = "vertico-posframe";

      packageRequires = [
        posframe
        vertico
      ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/vertico-posframe.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  vigenere = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "vigenere";
      version = "1.0";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/vigenere-1.0.tar";
        sha256 = "1zlni6amznzi9w96kj7lnhfrr049crva2l8kwl5jsvyaj5fc6nq5";
      };

      ename = "vigenere";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/vigenere.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  visual-filename-abbrev = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "visual-filename-abbrev";
      version = "1.3";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/visual-filename-abbrev-1.3.tar";
        sha256 = "0aly8lkiykcxq3yyyd3lwyc7fmjpcxjdgny0iw0mzl8nhshrqrs0";
      };

      ename = "visual-filename-abbrev";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/visual-filename-abbrev.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  visual-fill = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "visual-fill";
      version = "0.2";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/visual-fill-0.2.tar";
        sha256 = "00r3cclhrdx5y0h1p1rrx5psvc8d95dayzpjdsy9xj44i8pcnvja";
      };

      ename = "visual-fill";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/visual-fill.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  vlf = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "vlf";
      version = "1.7.2";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/vlf-1.7.2.tar";
        sha256 = "1napxdavsrwb5dq2i4ka06rhmmfk6qixc8mm2a6ab68iavprrqkv";
      };

      ename = "vlf";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/vlf.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  vundo = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "vundo";
      version = "2.4.0";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/vundo-2.4.0.tar";
        sha256 = "1aj2l6iivgv6mh3rvrj8w8jhznx7cywn5f2b2ivl4hmrxlfbgsjr";
      };

      ename = "vundo";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/vundo.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  wcheck-mode = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "wcheck-mode";
      version = "2026.5";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/wcheck-mode-2026.5.tar";
        sha256 = "0yxg6s4s5103zfa8m82gaxc46d9gjpiknmvgm2lcb21dckdsay13";
      };

      ename = "wcheck-mode";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/wcheck-mode.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  wconf = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "wconf";
      version = "0.2.1";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/wconf-0.2.1.tar";
        sha256 = "1ci5ysn2w9hjzcsv698b6mh14qbrmvlzn4spaq4wzwl9p8672n08";
      };

      ename = "wconf";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/wconf.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  web-server = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "web-server";
      version = "0.1.2";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/web-server-0.1.2.tar";
        sha256 = "0wikajm4pbffcy8clwwb5bnz67isqmcsbf9kca8rzx4svzi5j2gc";
      };

      ename = "web-server";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/web-server.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  webfeeder = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "webfeeder";
      version = "1.1.2";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/webfeeder-1.1.2.tar";
        sha256 = "0418fpw2ra12n77560gh9j9ymv28d895bdhpr7x9xakvijjh705m";
      };

      ename = "webfeeder";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/webfeeder.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  websocket = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      cl-lib ? null,
    }:
    elpaBuild {
      pname = "websocket";
      version = "1.16";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/websocket-1.16.tar";
        sha256 = "0an37jb4zalfl27gg731yg33cpic34g3fqsc0b8987dcn0szf7xi";
      };

      ename = "websocket";
      packageRequires = [ cl-lib ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/websocket.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  which-key = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "which-key";
      version = "3.6.1";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/which-key-3.6.1.tar";
        sha256 = "0p1vl7dnd7nsvzgsff19px9yzcw4w07qb5sb8g9r8a8slgvf3vqh";
      };

      ename = "which-key";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/which-key.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  window-commander = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "window-commander";
      version = "3.0.2";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/window-commander-3.0.2.tar";
        sha256 = "15345sgdmgz0vv9bk2cmffjp66i0msqj0xn2cxl7wny3bkfx8amv";
      };

      ename = "window-commander";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/window-commander.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  window-tool-bar = callPackage (
    {
      lib,
      fetchurl,
      compat,
      elpaBuild,
    }:
    elpaBuild {
      pname = "window-tool-bar";
      version = "0.3";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/window-tool-bar-0.3.tar";
        sha256 = "00kggfpfi1nj05mzy5zig0fs4as7qh99wqgvya3xj2kw8141cvd6";
      };

      ename = "window-tool-bar";
      packageRequires = [ compat ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/window-tool-bar.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  windower = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "windower";
      version = "0.0.1";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/windower-0.0.1.el";
        sha256 = "19xizbfbnzhhmhlqy20ir1a1y87bjwrq67bcawxy6nxpkwbizsv7";
      };

      ename = "windower";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/windower.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  windresize = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "windresize";
      version = "0.1";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/windresize-0.1.tar";
        sha256 = "1wjqrwrfql5c67yv59hc95ga0mkvrqz74gy46aawhn8r3xr65qai";
      };

      ename = "windresize";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/windresize.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  wisi = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      seq,
    }:
    elpaBuild {
      pname = "wisi";
      version = "4.3.2";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/wisi-4.3.2.tar";
        sha256 = "0qa6nig33igv4sqk3fxzrmx889pswq10smj9c9l3phz2acqx8q92";
      };

      ename = "wisi";
      packageRequires = [ seq ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/wisi.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  wisitoken-grammar-mode = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      mmm-mode,
      wisi,
    }:
    elpaBuild {
      pname = "wisitoken-grammar-mode";
      version = "1.3.0";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/wisitoken-grammar-mode-1.3.0.tar";
        sha256 = "0i0vy751ycbfp8l8ynzj6iqgvc3scllwysdchpjv4lyj0m7m3s20";
      };

      ename = "wisitoken-grammar-mode";

      packageRequires = [
        mmm-mode
        wisi
      ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/wisitoken-grammar-mode.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  wpuzzle = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "wpuzzle";
      version = "1.1";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/wpuzzle-1.1.tar";
        sha256 = "05dgvr1miqp870nl7c8dw7j1kv4mgwm8scynjfwbs9wjz4xmzc6c";
      };

      ename = "wpuzzle";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/wpuzzle.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  wrap-search = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "wrap-search";
      version = "4.17.6";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/wrap-search-4.17.6.tar";
        sha256 = "0wq0fw5ry5fnp96q9bffawc1vdl4p6kknwhlyf4xypmja011afys";
      };

      ename = "wrap-search";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/wrap-search.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  xclip = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "xclip";
      version = "1.11.1";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/xclip-1.11.1.tar";
        sha256 = "0raqlpskjrkxv7a0q5ikq8dqf2h21g0vcxdw03vqcah2v43zxflx";
      };

      ename = "xclip";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/xclip.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  xeft = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "xeft";
      version = "3.6";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/xeft-3.6.tar";
        sha256 = "0vdnl0rp9bkl5gyyacqczbl41vl8hrvah51jbfx4szf4qldmfhsm";
      };

      ename = "xeft";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/xeft.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  xelb = callPackage (
    {
      lib,
      fetchurl,
      compat,
      elpaBuild,
    }:
    elpaBuild {
      pname = "xelb";
      version = "0.22";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/xelb-0.22.tar";
        sha256 = "0vd0dsigr2lvwvvm32kf20dyg5bvafinb2xhz491f8wj2w99fjx4";
      };

      ename = "xelb";
      packageRequires = [ compat ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/xelb.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  xpm = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      queue,
      cl-lib ? null,
    }:
    elpaBuild {
      pname = "xpm";
      version = "1.0.5";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/xpm-1.0.5.tar";
        sha256 = "12a12rmbc1c0j60nv1s8fgg3r2lcjw8hs7qpyscm7ggwanylxn6q";
      };

      ename = "xpm";

      packageRequires = [
        cl-lib
        queue
      ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/xpm.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  xr = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "xr";
      version = "2.2";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/xr-2.2.tar";
        sha256 = "0d2hwn73g51gzm8ank41sfcyk87ys2s1cl9zk0h763yjd48r6jqf";
      };

      ename = "xr";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/xr.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  xref = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "xref";
      version = "1.7.0";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/xref-1.7.0.tar";
        sha256 = "0jy49zrkqiqg9131k24y6nyjnq2am4dwwdrqmginrrwzvi3y9d24";
      };

      ename = "xref";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/xref.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  xref-union = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "xref-union";
      version = "0.2.0";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/xref-union-0.2.0.tar";
        sha256 = "0ghhasqs0xq2i576fp97qx6x3h940kgyp76a49gj5cdmig8kyfi8";
      };

      ename = "xref-union";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/xref-union.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  yaml = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "yaml";
      version = "1.2.4";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/yaml-1.2.4.tar";
        sha256 = "12ji680hjm1isc5k3yapvnp2m7pk23syfxwhi95bizhka02n0qly";
      };

      ename = "yaml";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/yaml.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  yasnippet = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      cl-lib ? null,
    }:
    elpaBuild {
      pname = "yasnippet";
      version = "0.14.3";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/yasnippet-0.14.3.tar";
        sha256 = "1c0zhdcqz0jrx2swbqwschnwb07wy4s2gld3x6b4b892psxc2cg8";
      };

      ename = "yasnippet";
      packageRequires = [ cl-lib ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/yasnippet.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  yasnippet-classic-snippets = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      yasnippet,
    }:
    elpaBuild {
      pname = "yasnippet-classic-snippets";
      version = "1.0.2";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/yasnippet-classic-snippets-1.0.2.tar";
        sha256 = "1qiw5592mj8gmq1lhdcpxfza7iqn4cmhn36vdskfa7zpd1lq26y1";
      };

      ename = "yasnippet-classic-snippets";
      packageRequires = [ yasnippet ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/yasnippet-classic-snippets.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  zones = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
    }:
    elpaBuild {
      pname = "zones";
      version = "2023.6.11";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/zones-2023.6.11.tar";
        sha256 = "1z3kq0lfc4fbr9dnk9kj2hqcv60bnjp0x4kbxaxy77vv02a62rzc";
      };

      ename = "zones";
      packageRequires = [ ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/zones.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  ztree = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      cl-lib ? null,
    }:
    elpaBuild {
      pname = "ztree";
      version = "1.0.6";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/ztree-1.0.6.tar";
        sha256 = "1yyh09jff31j5w6mqsnibig3wizv7acsw39pjjfv1rmngni2b8zi";
      };

      ename = "ztree";
      packageRequires = [ cl-lib ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/ztree.html";
        license = lib.licenses.free;
      };
    }
  ) { };

  zuul = callPackage (
    {
      lib,
      fetchurl,
      elpaBuild,
      project,
    }:
    elpaBuild {
      pname = "zuul";
      version = "0.4.0";

      src = fetchurl {
        url = "https://elpa.gnu.org/packages/zuul-0.4.0.tar";
        sha256 = "1mj54hm4cqidrmbxyqdjfsc3qcmjhbl0wii79bydx637dvpfvqgf";
      };

      ename = "zuul";
      packageRequires = [ project ];

      meta = {
        homepage = "https://elpa.gnu.org/packages/zuul.html";
        license = lib.licenses.free;
      };
    }
  ) { };
}
