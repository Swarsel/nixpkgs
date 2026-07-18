/*
  pkgs/development/lua-modules/generated-packages.nix is an auto-generated file -- DO NOT EDIT!
  Regenerate it with: nix run nixpkgs#luarocks-packages-updater
  You can customize the generated packages in pkgs/development/lua-modules/overrides.nix
*/

{
  lib,
  stdenv,
  fetchurl,
  callPackage,
  fetchgit,
  ...
}:
final: prev: {
  alt-getopt = callPackage (
    {
      fetchurl,
      fetchFromGitHub,
      buildLuarocksPackage,
      luaOlder,
    }:
    buildLuarocksPackage {
      pname = "alt-getopt";
      version = "0.8.0-2";

      src = fetchFromGitHub {
        owner = "cheusov";
        repo = "lua-alt-getopt";
        tag = "0.8.0";
        hash = "sha256-OxtMNB8++cVQ/gQjntLUt3WYopGhYb1VbIUAZEzJB88=";
      };

      disabled = luaOlder "5.1";

      knownRockspec =
        (fetchurl {
          sha256 = "1x1wb351n8c9aghgrlwkjg4crriwby18drzrz3280mw9cildg11v";
          url = "mirror://luarocks/alt-getopt-0.8.0-2.rockspec";
        }).outPath;

      meta = {
        description = "Process application arguments the same way as getopt_long";

        longDescription = ''
          alt-getopt is a module for Lua programming language for processing
          application's arguments the same way BSD/GNU getopt_long(3) functions do.
          The main goal is compatibility with SUS "Utility Syntax Guidelines"
          guidelines 3-13.
        '';

        homepage = "https://github.com/cheusov/lua-alt-getopt";

        license = lib.licenses.AND [
          lib.licenses.mit
          lib.licenses.x11
        ];

        maintainers = with lib.maintainers; [ arobyn ];
      };
    }
  ) { };

  ansicolors = callPackage (
    {
      fetchurl,
      buildLuarocksPackage,
      luaOlder,
    }:
    buildLuarocksPackage {
      pname = "ansicolors";
      version = "1.0.2-3";

      src = fetchurl {
        url = "https://github.com/kikito/ansicolors.lua/archive/v1.0.2.tar.gz";
        sha256 = "0r4xi57njldmar9pn77l0vr5701rpmilrm51spv45lz0q9js8xps";
      };

      disabled = luaOlder "5.1";

      knownRockspec =
        (fetchurl {
          sha256 = "19y962xdx5ldl3596ywdl7n825dffz9al6j6rx6pbgmhb7pi8s5v";
          url = "mirror://luarocks/ansicolors-1.0.2-3.rockspec";
        }).outPath;

      meta = {
        description = "Library for color Manipulation.";

        longDescription = ''
          Ansicolors is a simple Lua function for printing to the console in color.
        '';

        homepage = "https://github.com/kikito/ansicolors.lua";
        license = lib.licenses.mit;
        maintainers = with lib.maintainers; [ Freed-Wu ];
      };
    }
  ) { };

  argparse = callPackage (
    {
      fetchurl,
      buildLuarocksPackage,
      fetchzip,
      luaAtLeast,
      luaOlder,
    }:
    buildLuarocksPackage {
      pname = "argparse";
      version = "0.7.2-1";

      src = fetchzip {
        url = "https://github.com/luarocks/argparse/archive/0.7.2.zip";
        sha256 = "0ji3hh0s2g2i5sribiib2vpy30xzfkv61m4mzwawfpgraqg03r6y";
      };

      disabled = luaOlder "5.1" || luaAtLeast "5.6";

      knownRockspec =
        (fetchurl {
          sha256 = "1az7ikzll699sbz2qxq9wkm0ncmic33dhg85zqlznbnz28vy6jza";
          url = "mirror://luarocks/argparse-0.7.2-1.rockspec";
        }).outPath;

      meta = {
        description = "A feature-rich command-line argument parser";
        longDescription = "Argparse supports positional arguments, options, flags, optional arguments, subcommands and more. Argparse automatically generates usage, help, and error messages, and can generate shell completion scripts.";
        homepage = "https://github.com/luarocks/argparse";
        license = lib.licenses.mit;
      };
    }
  ) { };

  basexx = callPackage (
    {
      fetchurl,
      buildLuarocksPackage,
      luaOlder,
    }:
    buildLuarocksPackage {
      pname = "basexx";
      version = "0.4.1-1";

      src = fetchurl {
        url = "https://github.com/aiq/basexx/archive/v0.4.1.tar.gz";
        sha256 = "1rnz6xixxqwy0q6y2hi14rfid4w47h69gfi0rnlq24fz8q2b0qpz";
      };

      disabled = luaOlder "5.1";

      knownRockspec =
        (fetchurl {
          sha256 = "0kmydxm2wywl18cgj303apsx7hnfd68a9hx9yhq10fj7yfcxzv5f";
          url = "mirror://luarocks/basexx-0.4.1-1.rockspec";
        }).outPath;

      meta = {
        description = "A base2, base16, base32, base64 and base85 library for Lua";
        longDescription = "A Lua library which provides base2(bitfield), base16(hex), base32(crockford/rfc), base64(rfc/url), base85(z85) decoding and encoding.";
        homepage = "https://github.com/aiq/basexx";
        license = lib.licenses.mit;
      };
    }
  ) { };

  bcrypt = callPackage (
    {
      fetchurl,
      fetchFromGitHub,
      buildLuarocksPackage,
      luaOlder,
    }:
    buildLuarocksPackage {
      pname = "bcrypt";
      version = "2.3-1";

      src = fetchFromGitHub {
        owner = "mikejsavage";
        repo = "lua-bcrypt";
        tag = "v2.3-1";
        hash = "sha256-wd9AbzfD3j9fyTq3toscitPsTEE49YoeSstwfO+3QGo=";
      };

      disabled = luaOlder "5.1";

      knownRockspec =
        (fetchurl {
          sha256 = "1zjy7sflyd50jvp603hmw0sg3rw5xyray0spzv5x5ky9hxivcdrf";
          url = "mirror://luarocks/bcrypt-2.3-1.rockspec";
        }).outPath;

      meta = {
        description = "A Lua wrapper for bcrypt";
        homepage = "http://github.com/mikejsavage/lua-bcrypt";
        license = lib.licenses.isc;
        maintainers = with lib.maintainers; [ ulysseszhan ];
      };
    }
  ) { };

  binaryheap = callPackage (
    {
      fetchurl,
      buildLuarocksPackage,
      luaOlder,
    }:
    buildLuarocksPackage {
      pname = "binaryheap";
      version = "0.4-1";

      src = fetchurl {
        url = "https://github.com/Tieske/binaryheap.lua/archive/version_0v4.tar.gz";
        sha256 = "0f5l4nb5s7dycbkgh3rrl7pf0npcf9k6m2gr2bsn09fjyb3bdc8h";
      };

      disabled = luaOlder "5.1";

      knownRockspec =
        (fetchurl {
          sha256 = "1ah37lhskmrb26by5ygs7jblx7qnf6mphgw8kwhw0yacvmkcbql4";
          url = "mirror://luarocks/binaryheap-0.4-1.rockspec";
        }).outPath;

      meta = {
        description = "Binary heap implementation in pure Lua";

        longDescription = ''
          Binary heaps are an efficient sorting algorithm. This module
                implements a plain binary heap (without reverse lookup) and a
                'unique' binary heap (with unique payloads and reverse lookup).
        '';

        homepage = "https://github.com/Tieske/binaryheap.lua";

        license = lib.licenses.AND [
          lib.licenses.mit
          lib.licenses.x11
        ];

        maintainers = with lib.maintainers; [ vcunat ];
      };
    }
  ) { };

  bit32 = callPackage (
    {
      fetchurl,
      buildLuarocksPackage,
      fetchzip,
      luaAtLeast,
      luaOlder,
    }:
    buildLuarocksPackage {
      pname = "bit32";
      version = "5.3.5.1-1";

      src = fetchzip {
        url = "https://github.com/keplerproject/lua-compat-5.3/archive/v0.10.zip";
        sha256 = "1caxn228gx48g6kymp9w7kczgxcg0v0cd5ixsx8viybzkd60dcn4";
      };

      disabled = luaOlder "5.1" || luaAtLeast "5.5";

      knownRockspec =
        (fetchurl {
          sha256 = "11mg0hmmil92hkwamm91ghih6ys9pqsakx0z9jgnqxymnl887j51";
          url = "mirror://luarocks/bit32-5.3.5.1-1.rockspec";
        }).outPath;

      meta = {
        description = "Lua 5.2 bit manipulation library";

        longDescription = ''
          bit32 is the native Lua 5.2 bit manipulation library, in the version
                from Lua 5.3; it is compatible with Lua 5.1, 5.2, 5.3 and 5.4.
        '';

        homepage = "http://www.lua.org/manual/5.2/manual.html#6.7";
        license = lib.licenses.mit;
        maintainers = with lib.maintainers; [ lblasc ];
      };
    }
  ) { };

  busted = callPackage (
    {
      fetchurl,
      fetchFromGitHub,
      buildLuarocksPackage,
      dkjson,
      lua-term,
      luaOlder,
      lua_cliargs,
      luassert,
      luasystem,
      mediator_lua,
      penlight,
      say,
    }:
    buildLuarocksPackage {
      pname = "busted";
      version = "2.3.0-1";

      src = fetchFromGitHub {
        owner = "lunarmodules";
        repo = "busted";
        tag = "v2.3.0";
        hash = "sha256-ZSfnbsDiaIo/abVpwb/LV5Ktp5wFSZQNO0OdbnjqVSs=";
      };

      propagatedBuildInputs = [
        dkjson
        lua-term
        lua_cliargs
        luassert
        luasystem
        mediator_lua
        penlight
        say
      ];

      disabled = luaOlder "5.1";

      knownRockspec =
        (fetchurl {
          sha256 = "1df41k03r0fy8l62dqywqjlxwmjhifk2krqq675w1cra28z8hb14";
          url = "mirror://luarocks/busted-2.3.0-1.rockspec";
        }).outPath;

      meta = {
        description = "Elegant Lua unit testing";

        longDescription = ''
          An elegant, extensible, testing framework.
              Ships with a large amount of useful asserts,
              plus the ability to write your own. Output
              in pretty or plain terminal format, JSON,
              or TAP for CI integration. Great for TDD
              and unit, integration, and functional tests.
        '';

        homepage = "https://lunarmodules.github.io/busted/";
        license = lib.licenses.mit;
      };
    }
  ) { };

  busted-htest = callPackage (
    {
      fetchurl,
      fetchFromGitHub,
      buildLuarocksPackage,
    }:
    buildLuarocksPackage {
      pname = "busted-htest";
      version = "1.0.0-2";

      src = fetchFromGitHub {
        owner = "hishamhm";
        repo = "busted-htest";
        tag = "1.0.0";
        hash = "sha256-tGAQUSeDt+OV/TBAJo/JFdyeBRRZaIQEJG+SKcCaQhs=";
      };

      knownRockspec =
        (fetchurl {
          sha256 = "10d2pbh2rfy4ygp40h8br4w5j1z5syq5pn6knd4bbnacmswnmcdl";
          url = "mirror://luarocks/busted-htest-1.0.0-2.rockspec";
        }).outPath;

      meta = {
        description = "A pretty output handler for Busted";

        longDescription = ''
          This is an alternative output handler for Busted,
                a unit testing framework for Lua.
                It is based on the gtest output handler that
                is bundled with Busted.
        '';

        homepage = "https://github.com/hishamhm/busted-htest";
        license = lib.licenses.mit;
        maintainers = with lib.maintainers; [ mrcjkb ];
      };
    }
  ) { };

  cassowary = callPackage (
    {
      fetchurl,
      fetchFromGitHub,
      buildLuarocksPackage,
      luaOlder,
      penlight,
    }:
    buildLuarocksPackage {
      pname = "cassowary";
      version = "2.3.2-1";

      src = fetchFromGitHub {
        owner = "sile-typesetter";
        repo = "cassowary.lua";
        tag = "v2.3.2";
        hash = "sha256-wIVuf1L3g2BCM+zW4Nt1IyU6xaP4yYuzxHjVDxsgdNM=";
      };

      propagatedBuildInputs = [ penlight ];
      disabled = luaOlder "5.1";

      knownRockspec =
        (fetchurl {
          sha256 = "0c6sflm8zpgbcdj47s3rd34h69h3nqcciaaqd1wdx5m0lwc3mii0";
          url = "mirror://luarocks/cassowary-2.3.2-1.rockspec";
        }).outPath;

      meta = {
        description = "The cassowary constraint solver";

        longDescription = ''
          This is a Lua port of the Cassowary constraint solving toolkit.
                It allows you to use Lua to solve algebraic equations and inequalities
                and find the values of unknown variables which satisfy those
                inequalities.'';

        homepage = "https://github.com/sile-typesetter/cassowary.lua";
        license = lib.licenses.asl20;
        maintainers = with lib.maintainers; [ alerque ];
      };
    }
  ) { };

  cldr = callPackage (
    {
      fetchurl,
      fetchFromGitHub,
      buildLuarocksPackage,
      luaOlder,
      penlight,
    }:
    buildLuarocksPackage {
      pname = "cldr";
      version = "0.3.0-0";

      src = fetchFromGitHub {
        owner = "alerque";
        repo = "cldr-lua";
        tag = "v0.3.0";
        hash = "sha256-5LY0YxHACtreP38biDZD97bkPuuT7an/Z1VBXEJYjkI=";
      };

      propagatedBuildInputs = [ penlight ];
      disabled = luaOlder "5.1";

      knownRockspec =
        (fetchurl {
          sha256 = "1fnr8k713w21v7hc64s4w5lgcgnbphq3gm69pisc2s4wq2fkija1";
          url = "mirror://luarocks/cldr-0.3.0-0.rockspec";
        }).outPath;

      meta = {
        description = "Lua interface to Unicode CLDR data";
        longDescription = "Unicode CLDR (Common Locale Data Repository) data and Lua interface.";
        homepage = "https://github.com/alerque/cldr-lua";

        license = lib.licenses.AND [
          lib.licenses.mit
          lib.licenses.unicode-30
        ];

        maintainers = with lib.maintainers; [ alerque ];
      };
    }
  ) { };

  commons-nvim = callPackage (
    {
      fetchurl,
      buildLuarocksPackage,
      fetchzip,
      luaOlder,
    }:
    buildLuarocksPackage {
      pname = "commons.nvim";
      version = "27.0.0-1";

      src = fetchzip {
        url = "https://github.com/linrongbin16/commons.nvim/archive/ac18006fe9e47cf6e53c79e333465d5a75455357.zip";
        sha256 = "10qlgly499lyhvmhj5lqv4jqzyrlx6h7h7gjbyrgzpjqyjr99m1l";
      };

      disabled = luaOlder "5.1";

      knownRockspec =
        (fetchurl {
          sha256 = "0gz1943nrlpi7pq4izip6fb0pkfk13h5322qhynx27m82nm129mq";
          url = "mirror://luarocks/commons.nvim-27.0.0-1.rockspec";
        }).outPath;

      meta = {
        description = "The commons lua library for Neovim plugin project.";
        homepage = "https://linrongbin16.github.io/commons.nvim/";
        license = lib.licenses.mit;
        maintainers = with lib.maintainers; [ mrcjkb ];
      };
    }
  ) { };

  compat53 = callPackage (
    {
      fetchurl,
      buildLuarocksPackage,
      fetchzip,
      luaAtLeast,
      luaOlder,
    }:
    buildLuarocksPackage {
      pname = "compat53";
      version = "0.15.0-1";

      src = fetchzip {
        url = "https://github.com/lunarmodules/lua-compat-5.3/archive/v0.15.0.zip";
        sha256 = "164hcigjz7my1zlgccdbvsld89bvz6y16v82rjc8n2qa8ah5j45d";
      };

      disabled = luaOlder "5.1" || luaAtLeast "5.6";

      knownRockspec =
        (fetchurl {
          sha256 = "0389ghggjdbfxxa6nrb7364z55dmb832qyb8v4474nzcws0b0aqf";
          url = "mirror://luarocks/compat53-0.15.0-1.rockspec";
        }).outPath;

      meta = {
        description = "Compatibility module providing Lua-5.3-style APIs for Lua 5.2 and 5.1";

        longDescription = ''
          This is a small module that aims to make it easier to write Lua
                code in a Lua-5.3-style that runs on Lua 5.1+.
                It does *not* make Lua 5.2 (or even 5.1) entirely compatible
                with Lua 5.3, but it brings the API closer to that of Lua 5.3.
        '';

        homepage = "https://github.com/lunarmodules/lua-compat-5.3";
        license = lib.licenses.mit;
        maintainers = with lib.maintainers; [ vcunat ];
      };
    }
  ) { };

  coop-nvim = callPackage (
    {
      fetchurl,
      fetchFromGitHub,
      buildLuarocksPackage,
      luaOlder,
    }:
    buildLuarocksPackage {
      pname = "coop.nvim";
      version = "1.2.0-0";

      src = fetchFromGitHub {
        owner = "gregorias";
        repo = "coop.nvim";
        rev = "b156e541316aee14be4ae64c93ed8bddb6d03bc1";
        hash = "sha256-S6iGmdakI714Im0tetgfASbe0K4/olYsjj26+WP+rSU=";
      };

      disabled = luaOlder "5.1";

      knownRockspec =
        (fetchurl {
          sha256 = "1fkpdddk2c2wibk0khgmvr03in2hz8wd3gdmmfbfbpb6jybhcckg";
          url = "mirror://luarocks/coop.nvim-1.2.0-0.rockspec";
        }).outPath;

      meta = {
        description = "A Neovim plugin for structured concurrency with coroutines.";
        homepage = "https://github.com/gregorias/coop.nvim";
        license = lib.licenses.gpl3Only;
      };
    }
  ) { };

  cosmo = callPackage (
    {
      fetchurl,
      fetchFromGitHub,
      buildLuarocksPackage,
      lpeg,
    }:
    buildLuarocksPackage {
      pname = "cosmo";
      version = "16.06.04-1";

      src = fetchFromGitHub {
        owner = "mascarenhas";
        repo = "cosmo";
        tag = "v16.06.04";
        hash = "sha256-mJE5GkDnfZ3qAQyyyKj+aXOtlITeYs8lerGJSTzU/Tk=";
      };

      propagatedBuildInputs = [ lpeg ];

      knownRockspec =
        (fetchurl {
          sha256 = "0ipv1hrlhvaz1myz6qxabq7b7kb3bz456cya3r292487a3g9h9pb";
          url = "mirror://luarocks/cosmo-16.06.04-1.rockspec";
        }).outPath;

      meta = {
        description = "Safe templates for Lua";

        longDescription = ''
          Cosmo is a "safe templates" engine. It allows you to fill nested templates,
          providing many of the advantages of Turing-complete template engines,
          without without the downside of allowing arbitrary code in the templates.
        '';

        homepage = "http://cosmo.luaforge.net";

        license = lib.licenses.AND [
          lib.licenses.mit
          lib.licenses.x11
        ];
      };
    }
  ) { };

  coxpcall = callPackage (
    {
      fetchurl,
      fetchFromGitHub,
      buildLuarocksPackage,
    }:
    buildLuarocksPackage {
      pname = "coxpcall";
      version = "1.17.0-1";

      src = fetchFromGitHub {
        owner = "keplerproject";
        repo = "coxpcall";
        tag = "v1_17_0";
        hash = "sha256-EW8pGI9jiGutNVNmyiCP5sIVYZe2rJQc03OrKXIOeMw=";
      };

      knownRockspec =
        (fetchurl {
          sha256 = "0mf0nggg4ajahy5y1q5zh2zx9rmgzw06572bxx6k8b736b8j7gca";
          url = "mirror://luarocks/coxpcall-1.17.0-1.rockspec";
        }).outPath;

      meta = {
        description = "Coroutine safe xpcall and pcall";

        longDescription = ''
          Encapsulates the protected calls with a coroutine based loop, so errors can
           be handled without the usual Lua 5.x pcall/xpcall issues with coroutines
           yielding inside the call to pcall or xpcall.
        '';

        homepage = "http://keplerproject.github.io/coxpcall";

        license = lib.licenses.AND [
          lib.licenses.mit
          lib.licenses.x11
        ];
      };
    }
  ) { };

  cqueues = callPackage (
    {
      fetchurl,
      buildLuarocksPackage,
      lua,
    }:
    buildLuarocksPackage {
      pname = "cqueues";
      version = "20200726.52-0";

      src = fetchurl {
        url = "https://github.com/wahern/cqueues/archive/rel-20200726.tar.gz";
        sha256 = "0lhd02ag3r1sxr2hx847rdjkddm04l1vf5234v5cz9bd4kfjw4cy";
      };

      disabled = lua.luaversion != "5.2";

      knownRockspec =
        (fetchurl {
          sha256 = "0w2kq9w0wda56k02rjmvmzccz6bc3mn70s9v7npjadh85i5zlhhp";
          url = "mirror://luarocks/cqueues-20200726.52-0.rockspec";
        }).outPath;

      meta = {
        description = "Continuation Queues: Embeddable asynchronous networking, threading, and notification framework for Lua on Unix.";
        homepage = "http://25thandclement.com/~william/projects/cqueues.html";

        license = lib.licenses.AND [
          lib.licenses.mit
          lib.licenses.x11
        ];

        maintainers = with lib.maintainers; [ vcunat ];
      };
    }
  ) { };

  cyan = callPackage (
    {
      fetchurl,
      fetchFromGitHub,
      argparse,
      buildLuarocksPackage,
      luafilesystem,
      luasystem,
      tl,
    }:
    buildLuarocksPackage {
      pname = "cyan";
      version = "0.4.1-1";

      src = fetchFromGitHub {
        owner = "teal-language";
        repo = "cyan";
        tag = "v0.4.1";
        hash = "sha256-jvBmOC1SMnuwgwtK6sPCDma+S5RyhItc6YjzMPULzSw=";
      };

      propagatedBuildInputs = [
        argparse
        luafilesystem
        luasystem
        tl
      ];

      knownRockspec =
        (fetchurl {
          sha256 = "0m0br7fvczkaqx6zqj7ykmivw7fnizvi34cqp2mvzxn30hsa4hyw";
          url = "mirror://luarocks/cyan-0.4.1-1.rockspec";
        }).outPath;

      meta = {
        description = "A build system for the Teal language";
        longDescription = "A build system for the Teal language along with an api for external tooling to work with Teal";
        homepage = "https://github.com/teal-language/cyan";
        license = lib.licenses.mit;
      };
    }
  ) { };

  datafile = callPackage (
    {
      fetchurl,
      fetchFromGitHub,
      buildLuarocksPackage,
      luaOlder,
    }:
    buildLuarocksPackage {
      pname = "datafile";
      version = "0.11-1";

      src = fetchFromGitHub {
        owner = "hishamhm";
        repo = "datafile";
        tag = "v0.11";
        hash = "sha256-aHdxFJ2IB9v9UMK7vqk7tUA0rLmfvRd0nzhc9JO8AlQ=";
      };

      disabled = luaOlder "5.1";

      knownRockspec =
        (fetchurl {
          sha256 = "09i0yqakzc342f2qqa0yxkdyz55y9s5v036x3xjwpfjry8yywc6q";
          url = "mirror://luarocks/datafile-0.11-1.rockspec";
        }).outPath;

      meta = {
        description = "A library for handling paths when loading data files";

        longDescription = ''
          datafile is a library for avoiding hardcoded paths
                when loading resource files in Lua modules.
        '';

        homepage = "http://github.com/hishamhm/datafile";

        license = lib.licenses.AND [
          lib.licenses.mit
          lib.licenses.x11
        ];
      };
    }
  ) { };

  digestif = callPackage (
    {
      fetchurl,
      fetchFromGitHub,
      buildLuarocksPackage,
      lpeg,
      luaOlder,
      luafilesystem,
    }:
    buildLuarocksPackage {
      pname = "digestif";
      version = "0.6-1";

      src = fetchFromGitHub {
        owner = "astoff";
        repo = "digestif";
        tag = "v0.6";
        hash = "sha256-sGwKt9suRVNrbRJlhNMHzc5r4sK/fvUc7smxmxmrn8Y=";
      };

      propagatedBuildInputs = [
        lpeg
        luafilesystem
      ];

      disabled = luaOlder "5.3";

      knownRockspec =
        (fetchurl {
          sha256 = "0hp7r97b6ivywaxb02cbnm23gjz71mak5ag6m3hi7f3mjqxxxh8k";
          url = "mirror://luarocks/digestif-0.6-1.rockspec";
        }).outPath;

      meta = {
        description = "A code analyzer for TeX";

        longDescription = ''
          A code analyzer for TeX documents, including LaTeX and BibTeX.  It
              comes with a Language Server Protocol implementation, so it can
              run as a plug-in to many different text editors.
        '';

        homepage = "https://github.com/astoff/digestif/";

        license = lib.licenses.AND [
          lib.licenses.gpl3Plus
          lib.licenses.free
        ];
      };
    }
  ) { };

  dkjson = callPackage (
    {
      fetchurl,
      buildLuarocksPackage,
      luaAtLeast,
      luaOlder,
    }:
    buildLuarocksPackage {
      pname = "dkjson";
      version = "2.10-1";

      src = fetchurl {
        url = "https://dkolf.de/dkjson-lua/dkjson-2.10.tar.gz";
        sha256 = "092v9m13h7zl89qfgywbs22wdvniwr2lr3shjqrn91f4nl39xiz8";
      };

      disabled = luaOlder "5.1" || luaAtLeast "5.6";

      knownRockspec =
        (fetchurl {
          sha256 = "0h49fv93h6n32xwwgwvrhb6w5rzvgjzyls6m9xhmcd94pbkih8v2";
          url = "mirror://luarocks/dkjson-2.10-1.rockspec";
        }).outPath;

      meta = {
        description = "David Kolf's JSON module for Lua";

        longDescription = ''
          dkjson is a module for encoding and decoding JSON data. It supports UTF-8.

          JSON (JavaScript Object Notation) is a format for serializing data based
          on the syntax for JavaScript data structures.

          dkjson is written in Lua without any dependencies, but
          when LPeg is available dkjson can use it to speed up decoding.
        '';

        homepage = "https://dkolf.de/dkjson-lua/";

        license = lib.licenses.AND [
          lib.licenses.mit
          lib.licenses.x11
        ];
      };
    }
  ) { };

  enet = callPackage (
    {
      fetchurl,
      fetchFromGitHub,
      buildLuarocksPackage,
      luaOlder,
    }:
    buildLuarocksPackage {
      pname = "enet";
      version = "1.2-1";

      src = fetchFromGitHub {
        owner = "leafo";
        repo = "lua-enet";
        tag = "v1.2";
        hash = "sha256-GomfJAPbR+y469LuaNPrkab0Wd3xAsAhT4uqbDo8BUA=";
      };

      disabled = luaOlder "5.1";

      knownRockspec =
        (fetchurl {
          sha256 = "0jf0qxf3lsrmc1dww7b7i6srqp2cy8caqv9f1rbva7f6rnppxzra";
          url = "mirror://luarocks/enet-1.2-1.rockspec";
        }).outPath;

      meta = {
        description = "A library for doing network communication in Lua";

        longDescription = ''
          Binding to ENet, network communication layer on top of UDP.
        '';

        homepage = "http://leafo.net/lua-enet";
        license = lib.licenses.mit;
        maintainers = with lib.maintainers; [ ulysseszhan ];
      };
    }
  ) { };

  etlua = callPackage (
    {
      fetchurl,
      fetchFromGitHub,
      buildLuarocksPackage,
      luaOlder,
    }:
    buildLuarocksPackage {
      pname = "etlua";
      version = "1.3.0-1";

      src = fetchFromGitHub {
        owner = "leafo";
        repo = "etlua";
        tag = "v1.3.0";
        hash = "sha256-CVCNeivP6tefUMseoZjiO5wMYBEPNWMy2+0KnmEIuT0=";
      };

      disabled = luaOlder "5.1";

      knownRockspec =
        (fetchurl {
          sha256 = "1g98ibp7n2p4js39din2balncjnxxdbaq6msw92z072s2cccx9cf";
          url = "mirror://luarocks/etlua-1.3.0-1.rockspec";
        }).outPath;

      meta = {
        description = "Embedded templates for Lua";

        longDescription = ''
          Allows you to render ERB style templates but with Lua. Supports <% %>, <%=
              %> and <%- %> tags (with optional newline slurping) for embedding code.
        '';

        homepage = "https://github.com/leafo/etlua";
        license = lib.licenses.mit;
        maintainers = with lib.maintainers; [ ulysseszhan ];
      };
    }
  ) { };

  fennel = callPackage (
    {
      fetchurl,
      fetchFromGitHub,
      buildLuarocksPackage,
      luaOlder,
    }:
    buildLuarocksPackage {
      pname = "fennel";
      version = "1.6.1-1";

      src = fetchFromGitHub {
        owner = "bakpakin";
        repo = "Fennel";
        tag = "1.6.1";
        hash = "sha256-MLXLkRKlxqvEOogM5I4uHxnlRLjK8Pbeq9b1+kAgqFg=";
      };

      disabled = luaOlder "5.1";

      knownRockspec =
        (fetchurl {
          sha256 = "1r6sn77f321k7i4ch4n02k0l1q0dlpdgifchpxzknwknir1bvmnk";
          url = "mirror://luarocks/fennel-1.6.1-1.rockspec";
        }).outPath;

      meta = {
        description = "A lisp that compiles to Lua";
        longDescription = "Get your parens on--write macros and homoiconic code on the Lua runtime!";
        homepage = "https://fennel-lang.org";
        license = lib.licenses.mit;
        maintainers = with lib.maintainers; [ misterio77 ];
      };
    }
  ) { };

  fidget-nvim = callPackage (
    {
      fetchurl,
      buildLuarocksPackage,
      fetchzip,
      luaOlder,
    }:
    buildLuarocksPackage {
      pname = "fidget.nvim";
      version = "1.6.0-1";

      src = fetchzip {
        url = "https://github.com/j-hui/fidget.nvim/archive/v1.6.0.zip";
        sha256 = "120q3dzq142xda1bzw8chf02k86dw21n8qjznlaxxpqlpk9sl6hr";
      };

      disabled = luaOlder "5.1";

      knownRockspec =
        (fetchurl {
          sha256 = "1jra7xv2ifsy5p3zwbiv70ynligjh8wx48ykmbi2cagd2vz9arwz";
          url = "mirror://luarocks/fidget.nvim-1.6.0-1.rockspec";
        }).outPath;

      meta = {
        description = "Extensible UI for Neovim notifications and LSP progress messages.";

        longDescription = ''
          Fidget is an unintrusive window in the corner of your editor that manages its own lifetime.
          Its goals are:
          - to provide a UI for Neovim's $/progress handler
          - to provide a configurable vim.notify() backend
          - to support basic ASCII animations (Fidget spinners!) to indicate signs of life
          - to be easy to configure, sane to maintain, and fun to hack on
          There's only so much information one can stash into the status line.
          Besides, who doesn't love a little bit of terminal eye candy, as a treat?'';

        homepage = "https://github.com/j-hui/fidget.nvim";
        license = lib.licenses.mit;
        maintainers = with lib.maintainers; [ mrcjkb ];
      };
    }
  ) { };

  fifo = callPackage (
    {
      fetchurl,
      buildLuarocksPackage,
      fetchzip,
    }:
    buildLuarocksPackage {
      pname = "fifo";
      version = "0.2-0";

      src = fetchzip {
        url = "https://github.com/daurnimator/fifo.lua/archive/0.2.zip";
        sha256 = "1800k7h5hxsvm05bjdr65djjml678lwb0661cll78z1ys2037nzn";
      };

      knownRockspec =
        (fetchurl {
          sha256 = "0vr9apmai2cyra2n573nr3dyk929gzcs4nm1096jdxcixmvh2ymq";
          url = "mirror://luarocks/fifo-0.2-0.rockspec";
        }).outPath;

      meta = {
        description = "A lua library/'class' that implements a FIFO";
        homepage = "https://github.com/daurnimator/fifo.lua";

        license = lib.licenses.AND [
          lib.licenses.mit
          lib.licenses.x11
        ];
      };
    }
  ) { };

  fluent = callPackage (
    {
      fetchurl,
      fetchFromGitHub,
      buildLuarocksPackage,
      cldr,
      luaOlder,
      luaepnf,
      penlight,
    }:
    buildLuarocksPackage {
      pname = "fluent";
      version = "0.2.0-0";

      src = fetchFromGitHub {
        owner = "alerque";
        repo = "fluent-lua";
        tag = "v0.2.0";
        hash = "sha256-uDJWhQ/fDD9ZbYOgPk1FDlU3A3DAZw3Ujx92BglFWoo=";
      };

      propagatedBuildInputs = [
        cldr
        luaepnf
        penlight
      ];

      disabled = luaOlder "5.1";

      knownRockspec =
        (fetchurl {
          sha256 = "1x3nk8xdf923rvdijr0jx8v6w3wxxfch7ri3kxca0pw80b5bc2fa";
          url = "mirror://luarocks/fluent-0.2.0-0.rockspec";
        }).outPath;

      meta = {
        description = "Lua implementation of Project Fluent";

        longDescription = ''
          A Lua port of Project Fluent, a localization paradigm designed to unleash
                the entire expressive power of natural language translations.'';

        homepage = "https://github.com/alerque/fluent-lua";
        license = lib.licenses.mit;
        maintainers = with lib.maintainers; [ alerque ];
      };
    }
  ) { };

  funnyfiles-nvim = callPackage (
    {
      fetchurl,
      buildLuarocksPackage,
      fetchzip,
      luaOlder,
    }:
    buildLuarocksPackage {
      pname = "funnyfiles.nvim";
      version = "1.0.1-1";

      src = fetchzip {
        url = "https://github.com/aikooo7/funnyfiles.nvim/archive/v1.0.1.zip";
        sha256 = "00p026r05gldbf18mmv8da9ap09di8dhy0rrd586pr2s2s36nzpd";
      };

      disabled = luaOlder "5.1";

      knownRockspec =
        (fetchurl {
          sha256 = "1r3cgx8wvc1c4syk167m94ws513g0cdmmxnymf3zyidlszdwamy5";
          url = "mirror://luarocks/funnyfiles.nvim-1.0.1-1.rockspec";
        }).outPath;

      meta = {
        description = "This plugin is a way of creating/deleting files/folders without needing to open a file explorer.";
        homepage = "https://github.com/aikooo7/funnyfiles.nvim";
        license = lib.licenses.mit;
        maintainers = with lib.maintainers; [ mrcjkb ];
      };
    }
  ) { };

  fzf-lua = callPackage (
    {
      fetchurl,
      buildLuarocksPackage,
      fetchzip,
      luaOlder,
    }:
    buildLuarocksPackage {
      pname = "fzf-lua";
      version = "0.0.2682-1";

      src = fetchzip {
        url = "https://github.com/ibhagwan/fzf-lua/archive/532d463f5c83595192fe740572d8fd6902b2217a.zip";
        sha256 = "1wy69gn4fx34jn5l7f8a9x4plbl1axv2aj7dw5q944ni71bwl8h1";
      };

      disabled = luaOlder "5.1";

      knownRockspec =
        (fetchurl {
          sha256 = "1kqpacp8ycywvdazcychl18xzdiw1bd1ga0780hffig3wgh190ys";
          url = "mirror://luarocks/fzf-lua-0.0.2682-1.rockspec";
        }).outPath;

      meta = {
        description = "Improved fzf.vim written in lua";
        homepage = "https://github.com/ibhagwan/fzf-lua";
        license = lib.licenses.agpl3Only;
        maintainers = with lib.maintainers; [ mrcjkb ];
      };
    }
  ) { };

  fzy = callPackage (
    {
      fetchurl,
      buildLuarocksPackage,
      fetchzip,
      luaOlder,
    }:
    buildLuarocksPackage {
      pname = "fzy";
      version = "1.0.3-1";

      src = fetchzip {
        url = "https://github.com/swarn/fzy-lua/archive/v1.0.3.zip";
        sha256 = "0w3alddhn0jd19vmminbi1b79mzlagyl1lygmfpxhzzccdv4vapm";
      };

      disabled = luaOlder "5.1";

      knownRockspec =
        (fetchurl {
          sha256 = "07d07afjs73bl5krfbaqx4pw2wpfrkyw2iksamkfa8dlqn9ajn1a";
          url = "mirror://luarocks/fzy-1.0.3-1.rockspec";
        }).outPath;

      meta = {
        description = "A lua implementation of the fzy fuzzy matching algorithm";

        longDescription = ''
          A Lua port of fzy's fuzzy string matching algorithm.
          This includes both a pure Lua implementation and a compiled C implementation with a Lua wrapper.
          fzy tries to find the result the user wants by favoring consecutive
          matches, and matches at the beginnings of words.'';

        homepage = "https://github.com/swarn/fzy-lua";
        license = lib.licenses.mit;
        maintainers = with lib.maintainers; [ mrcjkb ];
      };
    }
  ) { };

  gitsigns-nvim = callPackage (
    {
      fetchurl,
      buildLuarocksPackage,
      fetchzip,
      luaOlder,
    }:
    buildLuarocksPackage {
      pname = "gitsigns.nvim";
      version = "2.1.0-1";

      src = fetchzip {
        url = "https://github.com/lewis6991/gitsigns.nvim/archive/a462f416e2ce4744531c6256252dee99a7d34a83.zip";
        sha256 = "06d7pl9h1y8v7pmlyhlxs21z17pb7ikg4yipjag2i60panp6cd8i";
      };

      disabled = luaOlder "5.1";

      knownRockspec =
        (fetchurl {
          sha256 = "13w10vblahrqn3cahcj6f9wz1kcna93825zy01dspl3s058920yj";
          url = "mirror://luarocks/gitsigns.nvim-2.1.0-1.rockspec";
        }).outPath;

      meta = {
        description = "Git integration for buffers";
        homepage = "https://github.com/lewis6991/gitsigns.nvim";
        license = lib.licenses.mit;
      };
    }
  ) { };

  grug-far-nvim = callPackage (
    {
      fetchurl,
      buildLuarocksPackage,
      fetchzip,
      luaOlder,
    }:
    buildLuarocksPackage {
      pname = "grug-far.nvim";
      version = "1.6.74-1";

      src = fetchzip {
        url = "https://github.com/MagicDuck/grug-far.nvim/archive/1cc080f55706b38aabfa97d40acb6adf59ac4a5a.zip";
        sha256 = "0aybgj5h8d6ydm304ybgw506rrrvmcdis3pclyjv9adi4z61a9fn";
      };

      disabled = luaOlder "5.1";

      knownRockspec =
        (fetchurl {
          sha256 = "0g8nb4w6l6bwnpy54xy5qncwn3hp0dcay1gfqrjfsf9j5pm3ysmg";
          url = "mirror://luarocks/grug-far.nvim-1.6.74-1.rockspec";
        }).outPath;

      meta = {
        description = "Find And Replace plugin for neovim";
        homepage = "https://github.com/MagicDuck/grug-far.nvim";
        license = lib.licenses.mit;
        maintainers = with lib.maintainers; [ teto ];
      };
    }
  ) { };

  haskell-tools-nvim = callPackage (
    {
      fetchurl,
      buildLuarocksPackage,
      fetchzip,
      luaOlder,
    }:
    buildLuarocksPackage {
      pname = "haskell-tools.nvim";
      version = "10.0.1-1";

      src = fetchzip {
        url = "https://github.com/mrcjkb/haskell-tools.nvim/archive/v10.0.1.zip";
        sha256 = "1sdqkayvhwaj5aasnzzfx7gp8mrnqyfp7k6infkaqyp6r69qp8xg";
      };

      disabled = luaOlder "5.1";

      knownRockspec =
        (fetchurl {
          sha256 = "1rxcz077s19w61z8kcxg3zf68ng8gm8h66229jj6ypmd6vi35143";
          url = "mirror://luarocks/haskell-tools.nvim-10.0.1-1.rockspec";
        }).outPath;

      meta = {
        description = " 🦥 Supercharge your Haskell experience in neovim!";

        longDescription = ''
          This plugin automatically configures the haskell-language-server builtin LSP client
          and integrates with other Haskell tools. See the README's #features section
          for more info.'';

        homepage = "https://github.com/mrcjkb/haskell-tools.nvim";
        license = lib.licenses.gpl2Only;
        maintainers = with lib.maintainers; [ mrcjkb ];
      };
    }
  ) { };

  http = callPackage (
    {
      fetchurl,
      basexx,
      binaryheap,
      bit32,
      buildLuarocksPackage,
      compat53,
      cqueues,
      fetchzip,
      fifo,
      lpeg,
      lpeg_patterns,
      luaOlder,
      luaossl,
    }:
    buildLuarocksPackage {
      pname = "http";
      version = "0.4-0";

      src = fetchzip {
        url = "https://github.com/daurnimator/lua-http/archive/v0.4.zip";
        sha256 = "0252mc3mns1ni98hhcgnb3pmb53lk6nzr0jgqin0ggcavyxycqb2";
      };

      propagatedBuildInputs = [
        basexx
        binaryheap
        bit32
        compat53
        cqueues
        fifo
        lpeg
        lpeg_patterns
        luaossl
      ];

      disabled = luaOlder "5.1";

      knownRockspec =
        (fetchurl {
          sha256 = "0kbf7ybjyj6408sdrmh1jb0ig5klfc8mqcwz6gv6rd6ywn47qifq";
          url = "mirror://luarocks/http-0.4-0.rockspec";
        }).outPath;

      meta = {
        description = "HTTP library for Lua";
        homepage = "https://github.com/daurnimator/lua-http";
        license = lib.licenses.mit;
        maintainers = with lib.maintainers; [ vcunat ];
      };
    }
  ) { };

  inspect = callPackage (
    {
      fetchurl,
      buildLuarocksPackage,
      luaOlder,
    }:
    buildLuarocksPackage {
      pname = "inspect";
      version = "3.1.3-0";

      src = fetchurl {
        url = "https://github.com/kikito/inspect.lua/archive/v3.1.3.tar.gz";
        sha256 = "1sqylz5hmj5sbv4gi9988j6av3cb5lwkd7wiyim1h5lr7xhnlf23";
      };

      disabled = luaOlder "5.1";

      knownRockspec =
        (fetchurl {
          sha256 = "1iivb2jmz0pacmac2msyqwvjjx8q6py4h959m8fkigia6srg5ins";
          url = "mirror://luarocks/inspect-3.1.3-0.rockspec";
        }).outPath;

      meta = {
        description = "Lua table visualizer, ideal for debugging";

        longDescription = ''
          inspect will print out your lua tables nicely so you can debug your programs quickly. It sorts keys by type and name and handles recursive tables properly.
        '';

        homepage = "https://github.com/kikito/inspect.lua";
        license = lib.licenses.mit;
      };
    }
  ) { };

  jsregexp = callPackage (
    {
      fetchurl,
      fetchFromGitHub,
      buildLuarocksPackage,
      luaOlder,
    }:
    buildLuarocksPackage {
      pname = "jsregexp";
      version = "0.0.7-2";

      src = fetchFromGitHub {
        owner = "kmarius";
        repo = "jsregexp";
        tag = "v0.0.7";
        hash = "sha256-aXRGmo6w7jgKlR2BwKhbFGHC0mOTwHfYsh+lvqNuFtQ=";
      };

      disabled = luaOlder "5.1";

      knownRockspec =
        (fetchurl {
          sha256 = "048gaxgm45hvqz8x2sp3bjii2fgimwafccnwvf92crlj3r6cys6k";
          url = "mirror://luarocks/jsregexp-0.0.7-2.rockspec";
        }).outPath;

      meta = {
        description = "javascript (ECMA19) regular expressions for lua";

        longDescription = ''
          Provides ECMAScript regular expressions for Lua 5.1, 5.2, 5.3, 5.4 and LuaJit. Uses libregexp from Fabrice Bellard's QuickJS.
          	'';

        homepage = "https://github.com/kmarius/jsregexp";
        license = lib.licenses.mit;
      };
    }
  ) { };

  kulala-nvim = callPackage (
    {
      fetchurl,
      buildLuarocksPackage,
      fetchzip,
      luaOlder,
      tree-sitter-kulala_http,
    }:
    buildLuarocksPackage {
      pname = "kulala.nvim";
      version = "6.21.0-1";

      src = fetchzip {
        url = "https://github.com/mistweaverco/kulala.nvim/archive/v6.21.0.zip";
        sha256 = "0zglgmxz1lcfzk7x4p6c78drpa60b9rf9bvsnmnbg2w0rypg91wm";
      };

      propagatedBuildInputs = [ tree-sitter-kulala_http ];
      disabled = luaOlder "5.1";

      knownRockspec =
        (fetchurl {
          sha256 = "11g9k9gi1cl9bmrcd70p6gy874nql6z0l3wfhiskjwac8385lqj3";
          url = "mirror://luarocks/kulala.nvim-6.21.0-1.rockspec";
        }).outPath;

      meta = {
        description = "A fully-featured 🤏 HTTP/GraphQL/gRPC/Websocket-client 🐼 interface 🖥️ for Neovim ❤️, that supports the Jetbrains .http spec (with full scripting support).";
        homepage = "https://kulala.app";
        license = lib.licenses.mit;
      };
    }
  ) { };

  ldbus = callPackage (
    {
      fetchurl,
      fetchFromGitHub,
      buildLuarocksPackage,
      luaAtLeast,
      luaOlder,
    }:
    buildLuarocksPackage {
      pname = "ldbus";
      version = "scm-0";

      src = fetchFromGitHub {
        owner = "daurnimator";
        repo = "ldbus";
        rev = "5cc933bfad2b73674bc005ebcce771555a614792";
        hash = "sha256-MyldeKaqe7axZ423cKDE7+P2w26uRcjs0huuqlaVxQs=";
      };

      disabled = luaOlder "5.1" || luaAtLeast "5.5";

      knownRockspec =
        (fetchurl {
          sha256 = "1c0h6fx7avzh89hl17v6simy1p4mjg8bimlsbjybks0zxznd8rbm";
          url = "mirror://luarocks/ldbus-scm-0.rockspec";
        }).outPath;

      meta = {
        description = "A Lua library to access dbus.";
        homepage = "https://github.com/daurnimator/ldbus";

        license = lib.licenses.AND [
          lib.licenses.mit
          lib.licenses.x11
        ];
      };
    }
  ) { };

  ldoc = callPackage (
    {
      fetchurl,
      fetchFromGitHub,
      buildLuarocksPackage,
      markdown,
      penlight,
    }:
    buildLuarocksPackage {
      pname = "ldoc";
      version = "1.5.0-1";

      src = fetchFromGitHub {
        owner = "lunarmodules";
        repo = "ldoc";
        tag = "v1.5.0";
        hash = "sha256-Me2LT+UzO8G2vHqG7DjjoCRAtLmhiJHlSEYQGkprxTw=";
      };

      propagatedBuildInputs = [
        markdown
        penlight
      ];

      knownRockspec =
        (fetchurl {
          sha256 = "1c0yx9j3yqlzxpmspz7n7l1nvh2sww84zhkb1fsbg042sr8h9bxp";
          url = "mirror://luarocks/ldoc-1.5.0-1.rockspec";
        }).outPath;

      meta = {
        description = "A Lua Documentation Tool";

        longDescription = ''
          LDoc is a LuaDoc-compatible documentation generator which can also
                process C extension source. Markdown may be optionally used to
                render comments, as well as integrated readme documentation and
                pretty-printed example files
        '';

        homepage = "http://lunarmodules.github.io/ldoc";
        license = lib.licenses.mit;
      };
    }
  ) { };

  lgi = callPackage (
    {
      fetchurl,
      fetchFromGitHub,
      buildLuarocksPackage,
      luaOlder,
    }:
    buildLuarocksPackage {
      pname = "lgi";
      version = "0.9.2-1";

      src = fetchFromGitHub {
        owner = "pavouk";
        repo = "lgi";
        tag = "0.9.2";
        hash = "sha256-UpamUbvqzF0JKV3J0wIiJlV6iedwe823vD0EIm3zKw8=";
      };

      disabled = luaOlder "5.1";

      knownRockspec =
        (fetchurl {
          sha256 = "1gqi07m4bs7xibsy4vx8qgyp3yb1wnh0gdq1cpwqzv35y6hn5ds3";
          url = "mirror://luarocks/lgi-0.9.2-1.rockspec";
        }).outPath;

      meta = {
        description = "Lua bindings to GObject libraries";

        longDescription = ''
          Dynamic Lua binding to any library which is introspectable
          	 using gobject-introspection.  Allows using GObject-based libraries
          	 directly from Lua.
        '';

        homepage = "http://github.com/pavouk/lgi";

        license = lib.licenses.AND [
          lib.licenses.mit
          lib.licenses.x11
        ];
      };
    }
  ) { };

  linenoise = callPackage (
    {
      fetchurl,
      buildLuarocksPackage,
      luaOlder,
    }:
    buildLuarocksPackage {
      pname = "linenoise";
      version = "0.9-1";

      src = fetchurl {
        url = "https://github.com/hoelzro/lua-linenoise/archive/0.9.tar.gz";
        sha256 = "177h6gbq89arwiwxah9943i8hl5gvd9wivnd1nhmdl7d8x0dn76c";
      };

      disabled = luaOlder "5.1";

      meta = {
        description = "A binding for the linenoise command line library";
        homepage = "https://github.com/hoelzro/lua-linenoise";

        license = lib.licenses.AND [
          lib.licenses.mit
          lib.licenses.x11
        ];
      };
    }
  ) { };

  ljsyscall = callPackage (
    {
      fetchurl,
      buildLuarocksPackage,
      lua,
    }:
    buildLuarocksPackage {
      pname = "ljsyscall";
      version = "0.12-1";

      src = fetchurl {
        url = "https://github.com/justincormack/ljsyscall/archive/v0.12.tar.gz";
        sha256 = "1w9g36nhxv92cypjia7igg1xpfrn3dbs3hfy6gnnz5mx14v50abf";
      };

      disabled = lua.luaversion != "5.1";

      knownRockspec =
        (fetchurl {
          sha256 = "0zna5s852vn7q414z56kkyqwpighaghyq7h7in3myap4d9vcgm01";
          url = "mirror://luarocks/ljsyscall-0.12-1.rockspec";
        }).outPath;

      meta = {
        description = "LuaJIT Linux syscall FFI";
        homepage = "http://www.myriabit.com/ljsyscall/";
        license = lib.licenses.mit;
        maintainers = with lib.maintainers; [ lblasc ];
      };
    }
  ) { };

  llscheck = callPackage (
    {
      fetchurl,
      fetchFromGitHub,
      ansicolors,
      argparse,
      buildLuarocksPackage,
      lua-cjson,
      luaOlder,
      luafilesystem,
      penlight,
    }:
    buildLuarocksPackage {
      pname = "llscheck";
      version = "0.8.0-1";

      src = fetchFromGitHub {
        owner = "jeffzi";
        repo = "llscheck";
        tag = "v0.8.0";
        hash = "sha256-edUS6EQLiU4Slob2PagmPE5h7Co+XNRYb3fNeC4COsI=";
      };

      propagatedBuildInputs = [
        ansicolors
        argparse
        lua-cjson
        luafilesystem
        penlight
      ];

      disabled = luaOlder "5.1";

      knownRockspec =
        (fetchurl {
          sha256 = "15x22g2l5sih07yrcrapmcmmanrpq0ljdm34y928p8p6hg1034ab";
          url = "mirror://luarocks/llscheck-0.8.0-1.rockspec";
        }).outPath;

      meta = {
        description = "Human-friendly Lua code analysis powered by Lua Language Server";

        longDescription = ''
          LLSCheck runs Lua Language Server diagnostics and formats results for humans.
                Returns non-zero on errors for CI integration. Also usable as a Lua module.
        '';

        homepage = "https://github.com/jeffzi/llscheck";
        license = lib.licenses.mit;
        maintainers = with lib.maintainers; [ mrcjkb ];
      };
    }
  ) { };

  lmathx = callPackage (
    { fetchurl, buildLuarocksPackage }:
    buildLuarocksPackage {
      pname = "lmathx";
      version = "20150624-1";

      src = fetchurl {
        url = "http://www.tecgraf.puc-rio.br/~lhf/ftp/lua/5.3/lmathx.tar.gz";
        sha256 = "1r0ax3lq4xx6469aqc6qlfl3jynlghzhl5j65mpdj0kyzv4nknzf";
      };

      knownRockspec =
        (fetchurl {
          sha256 = "181wzsj1mxjyia43y8zwaydxahnl7a70qzcgc8jhhgic7jyi9pgv";
          url = "mirror://luarocks/lmathx-20150624-1.rockspec";
        }).outPath;

      meta = {
        description = "C99 extensions for the math library";

        longDescription = ''
          An extension of the Lua math library with the functions
                available in C99.
        '';

        homepage = "http://www.tecgraf.puc-rio.br/~lhf/ftp/lua/#lmathx";
        license = lib.licenses.publicDomain;
        maintainers = with lib.maintainers; [ alexshpilkin ];
      };
    }
  ) { };

  lmpfrlib = callPackage (
    {
      fetchurl,
      buildLuarocksPackage,
      luaAtLeast,
      luaOlder,
    }:
    buildLuarocksPackage {
      pname = "lmpfrlib";
      version = "20170112-2";

      src = fetchurl {
        url = "http://www.circuitwizard.de/lmpfrlib/lmpfrlib.c";
        sha256 = "1bkfwdacj1drzqsfxf352fjppqqwi5d4j084jr9vj9dvjb31rbc1";
      };

      disabled = luaOlder "5.3" || luaAtLeast "5.5";

      knownRockspec =
        (fetchurl {
          sha256 = "1x7qiwmk5b9fi87fn7yvivdsis8h9fk9r3ipqiry5ahx72vzdm7d";
          url = "mirror://luarocks/lmpfrlib-20170112-2.rockspec";
        }).outPath;

      meta = {
        description = "Lua API for the GNU MPFR library";
        longDescription = "The MPFR library is a C library for multi-precision floating-point computations with correct rounding. This extension allows the use of the MPFR library from within Lua.";
        homepage = "http://www.circuitwizard.de/lmpfrlib/lmpfrlib.html";
        license = lib.licenses.free;
        maintainers = with lib.maintainers; [ alexshpilkin ];
      };
    }
  ) { };

  loadkit = callPackage (
    {
      fetchurl,
      fetchFromGitHub,
      buildLuarocksPackage,
      luaOlder,
    }:
    buildLuarocksPackage {
      pname = "loadkit";
      version = "1.1.0-1";

      src = fetchFromGitHub {
        owner = "leafo";
        repo = "loadkit";
        tag = "v1.1.0";
        hash = "sha256-fw+aoP9+yDpme4qXupE07cV1QGZjb2aU7IOHapG+ihU=";
      };

      disabled = luaOlder "5.1";

      knownRockspec =
        (fetchurl {
          sha256 = "08fx0xh90r2zvjlfjkyrnw2p95xk1a0qgvlnq4siwdb2mm6fq12l";
          url = "mirror://luarocks/loadkit-1.1.0-1.rockspec";
        }).outPath;

      meta = {
        description = "Loadkit allows you to load arbitrary files within the Lua package path";

        longDescription = ''
          Loadkit lets you register new file extension handlers that can be opened
          		with require, or you can just search for files of any extension using the
          		current search path.
        '';

        homepage = "https://github.com/leafo/loadkit";
        license = lib.licenses.mit;
        maintainers = with lib.maintainers; [ alerque ];
      };
    }
  ) { };

  lpeg = callPackage (
    {
      fetchurl,
      buildLuarocksPackage,
      luaOlder,
    }:
    buildLuarocksPackage {
      pname = "lpeg";
      version = "1.1.0-2";

      src = fetchurl {
        url = "https://www.inf.puc-rio.br/~roberto/lpeg/lpeg-1.1.0.tar.gz";
        sha256 = "0aimsjpcpkh3kk65f0pg1z2bp6d83rn4dg6pgbx1yv14s9kms5ab";
      };

      disabled = luaOlder "5.1";

      knownRockspec =
        (fetchurl {
          sha256 = "0g8bnsx1qkl8s1fglbdai9mznzyzf9mv5lcxjab47069b3d8caa4";
          url = "mirror://luarocks/lpeg-1.1.0-2.rockspec";
        }).outPath;

      meta = {
        description = "Parsing Expression Grammars For Lua";

        longDescription = ''
          LPeg is a new pattern-matching library for Lua, based on Parsing
                Expression Grammars (PEGs). The nice thing about PEGs is that it
                has a formal basis (instead of being an ad-hoc set of features),
                allows an efficient and simple implementation, and does most things
                we expect from a pattern-matching library (and more, as we can
                define entire grammars).
        '';

        homepage = "https://www.inf.puc-rio.br/~roberto/lpeg.html";

        license = lib.licenses.AND [
          lib.licenses.mit
          lib.licenses.x11
        ];
      };
    }
  ) { };

  lpeg_patterns = callPackage (
    {
      fetchurl,
      buildLuarocksPackage,
      fetchzip,
      lpeg,
    }:
    buildLuarocksPackage {
      pname = "lpeg_patterns";
      version = "0.5-0";

      src = fetchzip {
        url = "https://github.com/daurnimator/lpeg_patterns/archive/v0.5.zip";
        sha256 = "1s3c179a64r45ffkawv9dnxw4mzwkzj00nr9z2gs5haajgpjivw6";
      };

      propagatedBuildInputs = [ lpeg ];

      knownRockspec =
        (fetchurl {
          sha256 = "1vzl3ryryc624mchclzsfl3hsrprb9q214zbi1xsjcc4ckq5qfh7";
          url = "mirror://luarocks/lpeg_patterns-0.5-0.rockspec";
        }).outPath;

      meta = {
        description = "a collection of LPEG patterns";
        homepage = "https://github.com/daurnimator/lpeg_patterns/archive/v0.5.zip";
        license = lib.licenses.mit;
      };
    }
  ) { };

  lpeglabel = callPackage (
    {
      fetchurl,
      buildLuarocksPackage,
      luaOlder,
    }:
    buildLuarocksPackage {
      pname = "lpeglabel";
      version = "1.6.0-1";

      src = fetchurl {
        url = "https://github.com/sqmedeiros/lpeglabel/archive/v1.6.0-1.tar.gz";
        sha256 = "1i02lsxj20iygqm8fy6dih1gh21lqk5qj1mv14wlrkaywnv35wcv";
      };

      disabled = luaOlder "5.1";

      knownRockspec =
        (fetchurl {
          sha256 = "13gc32pggng6f95xx5zw9n9ian518wlgb26mna9kh4q2xa1k42pm";
          url = "mirror://luarocks/lpeglabel-1.6.0-1.rockspec";
        }).outPath;

      meta = {
        description = "Parsing Expression Grammars For Lua with Labeled Failures";

        longDescription = ''
          LPegLabel is a conservative extension of the LPeg library that provides
               an implementation of Parsing Expression Grammars (PEGs) with labeled failures.
               By using labeled failures we can properly report syntactical errors.
               We can also recover from such errors by describing a grammar rule with
               the same name of a given label.
               LPegLabel also reports the farthest failure position in case of an ordinary failure.
        '';

        homepage = "https://github.com/sqmedeiros/lpeglabel/";

        license = lib.licenses.AND [
          lib.licenses.mit
          lib.licenses.x11
        ];
      };
    }
  ) { };

  lrexlib-gnu = callPackage (
    {
      fetchurl,
      fetchFromGitHub,
      buildLuarocksPackage,
      luaOlder,
    }:
    buildLuarocksPackage {
      pname = "lrexlib-gnu";
      version = "2.9.3-1";

      src = fetchFromGitHub {
        owner = "rrthomas";
        repo = "lrexlib";
        tag = "rel-2-9-3";
        hash = "sha256-7lybrMvNk2YhXish01PQlMpRVW+qlFj03RO33zmgGp4=";
      };

      disabled = luaOlder "5.1";

      knownRockspec =
        (fetchurl {
          sha256 = "1wn69qi1qfd3d13zrgw6xq7dwqks6kwj7s398kbgacq79ibv6js3";
          url = "mirror://luarocks/lrexlib-gnu-2.9.3-1.rockspec";
        }).outPath;

      meta = {
        description = "Regular expression library binding (GNU flavour).";

        longDescription = ''
          Lrexlib is a regular expression library for Lua 5.1-5.4, which
          provides bindings for several regular expression libraries.
          This rock provides the GNU bindings.'';

        homepage = "https://github.com/rrthomas/lrexlib";

        license = lib.licenses.AND [
          lib.licenses.mit
          lib.licenses.x11
        ];
      };
    }
  ) { };

  lrexlib-oniguruma = callPackage (
    {
      fetchurl,
      fetchFromGitHub,
      buildLuarocksPackage,
      luaOlder,
    }:
    buildLuarocksPackage {
      pname = "lrexlib-oniguruma";
      version = "2.9.3-1";

      src = fetchFromGitHub {
        owner = "rrthomas";
        repo = "lrexlib";
        tag = "rel-2-9-3";
        hash = "sha256-7lybrMvNk2YhXish01PQlMpRVW+qlFj03RO33zmgGp4=";
      };

      disabled = luaOlder "5.1";

      knownRockspec =
        (fetchurl {
          sha256 = "0zgpfnb7l018kh16xn836gwydhy0hpqzjchlbk0jhnjlzcvynidm";
          url = "mirror://luarocks/lrexlib-oniguruma-2.9.3-1.rockspec";
        }).outPath;

      meta = {
        description = "Regular expression library binding (oniguruma flavour).";

        longDescription = ''
          Lrexlib is a regular expression library for Lua 5.1-5.4, which
          provides bindings for several regular expression libraries.
          This rock provides the oniguruma bindings.'';

        homepage = "https://github.com/rrthomas/lrexlib";

        license = lib.licenses.AND [
          lib.licenses.mit
          lib.licenses.x11
        ];

        maintainers = with lib.maintainers; [ junestepp ];
      };
    }
  ) { };

  lrexlib-pcre = callPackage (
    {
      fetchurl,
      fetchFromGitHub,
      buildLuarocksPackage,
      luaOlder,
    }:
    buildLuarocksPackage {
      pname = "lrexlib-pcre";
      version = "2.9.3-1";

      src = fetchFromGitHub {
        owner = "rrthomas";
        repo = "lrexlib";
        tag = "rel-2-9-3";
        hash = "sha256-7lybrMvNk2YhXish01PQlMpRVW+qlFj03RO33zmgGp4=";
      };

      disabled = luaOlder "5.1";

      knownRockspec =
        (fetchurl {
          sha256 = "1pwwzc12a6dl5i4i8gl5i0r8aabqfpmdfrlj0fkvj5v56v9bkw09";
          url = "mirror://luarocks/lrexlib-pcre-2.9.3-1.rockspec";
        }).outPath;

      meta = {
        description = "Regular expression library binding (PCRE flavour).";

        longDescription = ''
          Lrexlib is a regular expression library for Lua 5.1-5.4, which
          provides bindings for several regular expression libraries.
          This rock provides the PCRE bindings.'';

        homepage = "https://github.com/rrthomas/lrexlib";

        license = lib.licenses.AND [
          lib.licenses.mit
          lib.licenses.x11
        ];
      };
    }
  ) { };

  lrexlib-pcre2 = callPackage (
    {
      fetchurl,
      fetchFromGitHub,
      buildLuarocksPackage,
      luaOlder,
    }:
    buildLuarocksPackage {
      pname = "lrexlib-pcre2";
      version = "2.9.3-1";

      src = fetchFromGitHub {
        owner = "rrthomas";
        repo = "lrexlib";
        tag = "rel-2-9-3";
        hash = "sha256-7lybrMvNk2YhXish01PQlMpRVW+qlFj03RO33zmgGp4=";
      };

      disabled = luaOlder "5.1";

      knownRockspec =
        (fetchurl {
          sha256 = "17y1zhjb5h1bdd4rdaycrnp3xwzm06y1179ga0wpcwvg0ybwmvfn";
          url = "mirror://luarocks/lrexlib-pcre2-2.9.3-1.rockspec";
        }).outPath;

      meta = {
        description = "Regular expression library binding (PCRE2 flavour).";

        longDescription = ''
          Lrexlib is a regular expression library for Lua 5.1-5.4, which
          provides bindings for several regular expression libraries.
          This rock provides the PCRE2 bindings.'';

        homepage = "https://github.com/rrthomas/lrexlib";

        license = lib.licenses.AND [
          lib.licenses.mit
          lib.licenses.x11
        ];

        maintainers = with lib.maintainers; [ wishstudio ];
      };
    }
  ) { };

  lrexlib-posix = callPackage (
    {
      fetchurl,
      fetchFromGitHub,
      buildLuarocksPackage,
      luaOlder,
    }:
    buildLuarocksPackage {
      pname = "lrexlib-posix";
      version = "2.9.3-1";

      src = fetchFromGitHub {
        owner = "rrthomas";
        repo = "lrexlib";
        tag = "rel-2-9-3";
        hash = "sha256-7lybrMvNk2YhXish01PQlMpRVW+qlFj03RO33zmgGp4=";
      };

      disabled = luaOlder "5.1";

      knownRockspec =
        (fetchurl {
          sha256 = "0s8w35x3jvhjn4znram93dj4kck95sv4zrlqcs6mqa4q70d5rl27";
          url = "mirror://luarocks/lrexlib-posix-2.9.3-1.rockspec";
        }).outPath;

      meta = {
        description = "Regular expression library binding (POSIX flavour).";

        longDescription = ''
          Lrexlib is a regular expression library for Lua 5.1-5.4, which
          provides bindings for several regular expression libraries.
          This rock provides the POSIX bindings.'';

        homepage = "https://github.com/rrthomas/lrexlib";

        license = lib.licenses.AND [
          lib.licenses.mit
          lib.licenses.x11
        ];
      };
    }
  ) { };

  lsp-progress-nvim = callPackage (
    {
      fetchurl,
      buildLuarocksPackage,
      fetchzip,
      luaOlder,
    }:
    buildLuarocksPackage {
      pname = "lsp-progress.nvim";
      version = "2.0.0-1";

      src = fetchzip {
        url = "https://github.com/linrongbin16/lsp-progress.nvim/archive/f6d5af10563b895ff846346f57cbd4451439f4c1.zip";
        sha256 = "0jrxlk1q6r687dnq958r7s5x4djl6qcm139s8za998m8sgda397a";
      };

      disabled = luaOlder "5.1";

      knownRockspec =
        (fetchurl {
          sha256 = "0ik0nambf3q76icmlcap3py30g84g1lpyysdd0f250g3gsyb993z";
          url = "mirror://luarocks/lsp-progress.nvim-2.0.0-1.rockspec";
        }).outPath;

      meta = {
        description = "A performant lsp progress status for Neovim.";
        homepage = "https://linrongbin16.github.io/lsp-progress.nvim/";
        license = lib.licenses.mit;
        maintainers = with lib.maintainers; [ gepbird ];
      };
    }
  ) { };

  lsqlite3 = callPackage (
    {
      fetchurl,
      buildLuarocksPackage,
      fetchzip,
      luaAtLeast,
      luaOlder,
    }:
    buildLuarocksPackage {
      pname = "lsqlite3";
      version = "0.9.6-1";

      src = fetchzip {
        url = "https://lua.sqlite.org/home/zip/lsqlite3_v096.zip?uuid=v0.9.6";
        sha256 = "0p24g17y6s0x1951y9pyndggp71drh4zrzb2a05nb9sk5s3z9dnm";
      };

      disabled = luaOlder "5.1" || luaAtLeast "5.5";

      knownRockspec =
        (fetchurl {
          sha256 = "1wb51lsfllmbzrjfl0dzxpg597nd54nn06c9plpvqwwjz4l9lrjf";
          url = "mirror://luarocks/lsqlite3-0.9.6-1.rockspec";
        }).outPath;

      meta = {
        description = "A binding for Lua to the SQLite3 database library";

        longDescription = ''
          lsqlite3 is a thin wrapper around the public domain SQLite3 database engine. SQLite3 is
                  dynamically linked to lsqlite3. The statically linked alternative is lsqlite3complete.
                  The lsqlite3 module supports the creation and manipulation of SQLite3 databases.
                  Most sqlite3 functions are called via an object-oriented interface to either
                  database or SQL statement objects.
        '';

        homepage = "http://lua.sqlite.org/";
        license = lib.licenses.mit;
      };
    }
  ) { };

  ltreesitter = callPackage (
    {
      fetchurl,
      fetchFromGitHub,
      buildLuarocksPackage,
    }:
    buildLuarocksPackage {
      pname = "ltreesitter";
      version = "0.3.0-1";

      src = fetchFromGitHub {
        owner = "euclidianAce";
        repo = "ltreesitter";
        tag = "v0.3.0";
        hash = "sha256-tiNcc/1hnY8GWgpdlBfOTA7400916tqiAXeXJLfgtNE=";
      };

      knownRockspec =
        (fetchurl {
          sha256 = "1vb8jbdl36syqmd4sjqswsqy42rq59kchxk4sx0ns9va4c0kim4v";
          url = "mirror://luarocks/ltreesitter-0.3.0-1.rockspec";
        }).outPath;

      meta = {
        description = "Treesitter bindings to Lua";
        longDescription = "Standalone Lua bindings to the Treesitter api (with full type definitions for Teal).";
        homepage = "https://github.com/euclidianAce/ltreesitter";
        license = lib.licenses.mit;
      };
    }
  ) { };

  ltreesitter-ts = callPackage (
    {
      fetchurl,
      fetchFromGitHub,
      buildLuarocksPackage,
    }:
    buildLuarocksPackage {
      pname = "ltreesitter-ts";
      version = "0.0.1-1";

      src = fetchFromGitHub {
        owner = "FourierTransformer";
        repo = "ltreesitter-ts";
        tag = "0.0.1";
        hash = "sha256-HFBOYFadw+lwQYk39vrFtAn/HGjfXzCxjN1RLBp4yKA=";
      };

      knownRockspec =
        (fetchurl {
          sha256 = "064nn3h6wi8z5ply35ig78jjkpy527nc5qxisbkvv8s3s345h82r";
          url = "mirror://luarocks/ltreesitter-ts-0.0.1-1.rockspec";
        }).outPath;

      meta = {
        description = "Treesitter parsing library bindings for Lua";
        longDescription = "This combines [ltreesitter](https://github.com/EuclidianAce/ltreesitter) and the [tree-sitter](https://github.com/tree-sitter/tree-sitter) library together to have an easy LuaRocks based install for tree sitter parsing. There are no other enhancements to either library. It can be imported as just `ltreesitter`.";
        homepage = "https://github.com/FourierTransformer/ltreesitter-ts";
        license = lib.licenses.mit;
      };
    }
  ) { };

  lua-cjson = callPackage (
    {
      fetchurl,
      fetchFromGitHub,
      buildLuarocksPackage,
      luaOlder,
    }:
    buildLuarocksPackage {
      pname = "lua-cjson";
      version = "2.1.0.10-1";

      src = fetchFromGitHub {
        owner = "openresty";
        repo = "lua-cjson";
        tag = "2.1.0.10";
        hash = "sha256-/SeQro0FaJn91bAGjsVIin+mJF89VUm/G0KyJkV9Qps=";
      };

      disabled = luaOlder "5.1";

      knownRockspec =
        (fetchurl {
          sha256 = "05sp7rq72x4kdkyid1ch0yyscwsi5wk85d2hj6xwssz3h8n8drdg";
          url = "mirror://luarocks/lua-cjson-2.1.0.10-1.rockspec";
        }).outPath;

      meta = {
        description = "A fast JSON encoding/parsing module";

        longDescription = ''
          The Lua CJSON module provides JSON support for Lua. It features:
                  - Fast, standards compliant encoding/parsing routines
                  - Full support for JSON with UTF-8, including decoding surrogate pairs
                  - Optional run-time support for common exceptions to the JSON specification
                    (infinity, NaN,..)
                  - No dependencies on other libraries
        '';

        homepage = "http://www.kyne.com.au/~mark/software/lua-cjson.php";
        license = lib.licenses.mit;
      };
    }
  ) { };

  lua-cmsgpack = callPackage (
    {
      fetchurl,
      fetchFromGitHub,
      buildLuarocksPackage,
      luaOlder,
    }:
    buildLuarocksPackage {
      pname = "lua-cmsgpack";
      version = "0.4.0-0";

      src = fetchFromGitHub {
        owner = "antirez";
        repo = "lua-cmsgpack";
        tag = "0.4.0";
        hash = "sha256-oGKX5G3uNGCJOaZpjLmIJYuq5HtdLd9xM/TlmxODCkg=";
      };

      disabled = luaOlder "5.1";

      knownRockspec =
        (fetchurl {
          sha256 = "10cvr6knx3qvjcw1q9v05f2qy607mai7lbq321nx682aa0n1fzin";
          url = "mirror://luarocks/lua-cmsgpack-0.4.0-0.rockspec";
        }).outPath;

      meta = {
        description = "MessagePack C implementation and bindings for Lua 5.1/5.2/5.3";
        homepage = "http://github.com/antirez/lua-cmsgpack";
        license = lib.licenses.bsd2;
      };
    }
  ) { };

  lua-curl = callPackage (
    {
      fetchurl,
      buildLuarocksPackage,
      fetchzip,
      luaAtLeast,
      luaOlder,
    }:
    buildLuarocksPackage {
      pname = "lua-curl";
      version = "0.3.13-1";

      src = fetchzip {
        url = "https://github.com/Lua-cURL/Lua-cURLv3/archive/v0.3.13.zip";
        sha256 = "0gn59bwrnb2mvl8i0ycr6m3jmlgx86xlr9mwnc85zfhj7zhi5anp";
      };

      disabled = luaOlder "5.1" || luaAtLeast "5.5";

      knownRockspec =
        (fetchurl {
          sha256 = "0lz534sm35hxazf1w71hagiyfplhsvzr94i6qyv5chjfabrgbhjn";
          url = "mirror://luarocks/lua-curl-0.3.13-1.rockspec";
        }).outPath;

      meta = {
        description = "Lua binding to libcurl";
        longDescription = "";
        homepage = "https://github.com/Lua-cURL";

        license = lib.licenses.AND [
          lib.licenses.mit
          lib.licenses.x11
        ];
      };
    }
  ) { };

  lua-ffi-zlib = callPackage (
    {
      fetchurl,
      fetchFromGitHub,
      buildLuarocksPackage,
      luaOlder,
    }:
    buildLuarocksPackage {
      pname = "lua-ffi-zlib";
      version = "0.6-0";

      src = fetchFromGitHub {
        owner = "hamishforbes";
        repo = "lua-ffi-zlib";
        tag = "v0.6";
        hash = "sha256-l3zN6amZ6uUbOl7vt5XF+Uyz0nbDrYgcaQCWRFSN22Q=";
      };

      disabled = luaOlder "5.1";

      knownRockspec =
        (fetchurl {
          sha256 = "060sac715f1ris13fjv6gwqm0lk6by0a2zhldxd8hdrc0jss8p34";
          url = "mirror://luarocks/lua-ffi-zlib-0.6-0.rockspec";
        }).outPath;

      meta = {
        description = "A Lua module using LuaJIT's FFI feature to access zlib.";
        homepage = "https://github.com/hamishforbes/lua-ffi-zlib";
      };
    }
  ) { };

  lua-iconv = callPackage (
    {
      fetchurl,
      buildLuarocksPackage,
      luaOlder,
    }:
    buildLuarocksPackage {
      pname = "lua-iconv";
      version = "7.0.0-4";

      src = fetchurl {
        url = "https://github.com/lunarmodules/lua-iconv/archive/v7.0.0/lua-iconv-7.0.0.tar.gz";
        sha256 = "0arp0h342hpp4kfdxc69yxspziky4v7c13jbf12yrs8f1lnjzr0x";
      };

      disabled = luaOlder "5.1";

      knownRockspec =
        (fetchurl {
          sha256 = "0j34zf98wdr6ks6snsrqi00vwm3ngsa5f74kadsn178iw7hd8c3q";
          url = "mirror://luarocks/lua-iconv-7.0.0-4.rockspec";
        }).outPath;

      meta = {
        description = "Lua binding to the iconv";

        longDescription = ''
          Lua binding to the POSIX 'iconv' library, which converts a sequence of
               characters from one codeset into a sequence of corresponding characters
               in another codeset.
        '';

        homepage = "https://github.com/lunarmodules/lua-iconv/";

        license = lib.licenses.AND [
          lib.licenses.mit
          lib.licenses.x11
        ];
      };
    }
  ) { };

  lua-lsp = callPackage (
    {
      fetchurl,
      fetchFromGitHub,
      buildLuarocksPackage,
      dkjson,
      inspect,
      lpeglabel,
      luaAtLeast,
      luaOlder,
    }:
    buildLuarocksPackage {
      pname = "lua-lsp";
      version = "0.1.0-2";

      src = fetchFromGitHub {
        owner = "Alloyed";
        repo = "lua-lsp";
        tag = "v0.1.0";
        hash = "sha256-Fy9d6ZS0R48dUpKpgJ9jRujQna5wsE3+StJ8GQyWY54=";
      };

      propagatedBuildInputs = [
        dkjson
        inspect
        lpeglabel
      ];

      disabled = luaOlder "5.1" || luaAtLeast "5.4";

      knownRockspec =
        (fetchurl {
          sha256 = "19jsz00qlgbyims6cg8i40la7v8kr7zsxrrr3dg0kdg0i36xqs6c";
          url = "mirror://luarocks/lua-lsp-0.1.0-2.rockspec";
        }).outPath;

      meta = {
        description = "A Language Server implementation for lua, the language";

        longDescription = ''
          A Language Server for Lua code, written in Lua.
          It's still a work in progress, but it's usable for day-to-day. It currently
          supports:

          * Limited autocompletion
          * Goto definition
          * As you type linting and syntax checking
          * Code formatting
          * Supports Lua 5.1-5.3 and Luajit
        '';

        homepage = "https://github.com/Alloyed/lua-lsp";
        license = lib.licenses.mit;
      };
    }
  ) { };

  lua-messagepack = callPackage (
    {
      fetchurl,
      buildLuarocksPackage,
      luaOlder,
    }:
    buildLuarocksPackage {
      pname = "lua-messagepack";
      version = "0.5.4-1";

      src = fetchurl {
        url = "https://framagit.org/fperrad/lua-MessagePack/raw/releases/lua-messagepack-0.5.4.tar.gz";
        sha256 = "0kk1n9kf6wip8k2xx4wjlv7647biji2p86v4jf0h6d6wkaypq0kz";
      };

      disabled = luaOlder "5.1";

      knownRockspec =
        (fetchurl {
          sha256 = "1jygn6f8ab69z0nn1gib45wvjp075gzxp54vdmgxb3qfar0q70kr";
          url = "mirror://luarocks/lua-messagepack-0.5.4-1.rockspec";
        }).outPath;

      meta = {
        description = "a pure Lua implementation of the MessagePack serialization format";

        longDescription = ''
          MessagePack is an efficient binary serialization format.

                  It lets you exchange data among multiple languages like JSON but it's faster and smaller.
        '';

        homepage = "https://fperrad.frama.io/lua-MessagePack/";

        license = lib.licenses.AND [
          lib.licenses.mit
          lib.licenses.x11
        ];
      };
    }
  ) { };

  lua-protobuf = callPackage (
    {
      fetchurl,
      fetchFromGitHub,
      buildLuarocksPackage,
      luaOlder,
    }:
    buildLuarocksPackage {
      pname = "lua-protobuf";
      version = "0.5.3-1";

      src = fetchFromGitHub {
        owner = "starwing";
        repo = "lua-protobuf";
        tag = "0.5.3";
        hash = "sha256-9vAv/Rhf9xrQnbd0nkaxGrcTRKkUSlpYRAJe2zpdIiY=";
      };

      disabled = luaOlder "5.1";

      knownRockspec =
        (fetchurl {
          sha256 = "0jz3yxdf9n1zfnkywqjghn6nlfvkkv9li003kkzh7z0wzidqaljh";
          url = "mirror://luarocks/lua-protobuf-0.5.3-1.rockspec";
        }).outPath;

      meta = {
        description = "protobuf data support for Lua";

        longDescription = ''
          This project offers a simple C library for basic protobuf wire format encode/decode.
        '';

        homepage = "https://github.com/starwing/lua-protobuf";
        license = lib.licenses.mit;
        maintainers = with lib.maintainers; [ lockejan ];
      };
    }
  ) { };

  lua-resty-http = callPackage (
    {
      fetchurl,
      fetchFromGitHub,
      buildLuarocksPackage,
      luaOlder,
    }:
    buildLuarocksPackage {
      pname = "lua-resty-http";
      version = "0.18.0-0";

      src = fetchFromGitHub {
        owner = "ledgetech";
        repo = "lua-resty-http";
        tag = "v0.18.0";
        hash = "sha256-3rHm44vLIT9cHIQa5EHbwdmB/KVaLl/RbvLgNsnYwc4=";
      };

      disabled = luaOlder "5.1";

      knownRockspec =
        (fetchurl {
          sha256 = "1zdhf22zbkb61k8vpkzmd33mn6nhl53splklv2aaj40066hlbhzs";
          url = "mirror://luarocks/lua-resty-http-0.18.0-0.rockspec";
        }).outPath;

      meta = {
        description = "Lua HTTP client cosocket driver for OpenResty / ngx_lua.";
        homepage = "https://github.com/ledgetech/lua-resty-http";
        license = lib.licenses.bsd2;
      };
    }
  ) { };

  lua-resty-jwt = callPackage (
    {
      fetchurl,
      fetchFromGitHub,
      buildLuarocksPackage,
      lua-resty-openssl,
      luaOlder,
    }:
    buildLuarocksPackage {
      pname = "lua-resty-jwt";
      version = "0.3.2-1";

      src = fetchFromGitHub {
        owner = "cdbattags";
        repo = "lua-resty-jwt";
        rev = "3973e402d835631de292c6e4cca52e728f02c24a";
        hash = "sha256-KJvHwN8R2t8aJS/wMdVDJh5Mld1fF3FhYAOPk2njTu8=";
      };

      propagatedBuildInputs = [ lua-resty-openssl ];
      disabled = luaOlder "5.1";

      knownRockspec =
        (fetchurl {
          sha256 = "0r870630jzpdr41gyc1myn6zn1qpid4whx2abn0v8qaqyg0j825y";
          url = "mirror://luarocks/lua-resty-jwt-0.3.2-1.rockspec";
        }).outPath;

      meta = {
        description = "JWT for ngx_lua and LuaJIT.";

        longDescription = ''
          This library requires an nginx build
              with OpenSSL, the ngx_lua module,
              the LuaJIT 2.0, the lua-resty-hmac,
              and the lua-resty-string,
        '';

        homepage = "https://github.com/cdbattags/lua-resty-jwt";
        license = lib.licenses.asl20;
      };
    }
  ) { };

  lua-resty-openidc = callPackage (
    {
      fetchurl,
      fetchFromGitHub,
      buildLuarocksPackage,
      lua-resty-http,
      lua-resty-jwt,
      lua-resty-openssl,
      lua-resty-session,
      luaOlder,
    }:
    buildLuarocksPackage {
      pname = "lua-resty-openidc";
      version = "1.9.0-1";

      src = fetchFromGitHub {
        owner = "zmartzone";
        repo = "lua-resty-openidc";
        tag = "v1.9.0";
        hash = "sha256-3dkHUN3Twe1g+oRXD7asMG28GxKzRAEF1SfZ4iuWhwA=";
      };

      propagatedBuildInputs = [
        lua-resty-http
        lua-resty-jwt
        lua-resty-openssl
        lua-resty-session
      ];

      disabled = luaOlder "5.1";

      knownRockspec =
        (fetchurl {
          sha256 = "0s4717scx37crqbnvq752j4n2f773hp0ndd8z0x2iyiwdnw8jjwf";
          url = "mirror://luarocks/lua-resty-openidc-1.9.0-1.rockspec";
        }).outPath;

      meta = {
        description = "A library for NGINX implementing the OpenID Connect Relying Party (RP) and the OAuth 2.0 Resource Server (RS) functionality";

        longDescription = ''
          lua-resty-openidc is a library for NGINX implementing the OpenID Connect Relying Party (RP) and the OAuth 2.0 Resource Server (RS) functionality.

                  When used as an OpenID Connect Relying Party it authenticates users against an OpenID Connect Provider using OpenID Connect Discovery and the Basic Client Profile (i.e. the Authorization Code flow). When used as an OAuth 2.0 Resource Server it can validate OAuth 2.0 Bearer Access Tokens against an Authorization Server or, in case a JSON Web Token is used for an Access Token, verification can happen against a pre-configured secret/key .

                  It maintains sessions for authenticated users by leveraging lua-resty-session thus offering a configurable choice between storing the session state in a client-side browser cookie or use in of the server-side storage mechanisms shared-memory|memcache|redis.

                  It supports server-wide caching of resolved Discovery documents and validated Access Tokens.

                  It can be used as a reverse proxy terminating OAuth/OpenID Connect in front of an origin server so that the origin server/services can be protected with the relevant standards without implementing those on the server itself.
        '';

        homepage = "https://github.com/zmartzone/lua-resty-openidc";
        license = lib.licenses.asl20;
      };
    }
  ) { };

  lua-resty-openssl = callPackage (
    {
      fetchurl,
      fetchFromGitHub,
      buildLuarocksPackage,
    }:
    buildLuarocksPackage {
      pname = "lua-resty-openssl";
      version = "1.8.0-1";

      src = fetchFromGitHub {
        owner = "fffonion";
        repo = "lua-resty-openssl";
        tag = "1.8.0";
        hash = "sha256-oafU+pwTxbPHrci0pEWdZNHu0eqEluEDF5M6ojx7Xeg=";
      };

      knownRockspec =
        (fetchurl {
          sha256 = "1x6hbk8xcwaaa11wcs48fjpj1bipz2a3h8lswnzl3l25llv1gsib";
          url = "mirror://luarocks/lua-resty-openssl-1.8.0-1.rockspec";
        }).outPath;

      meta = {
        description = "No summary";
        longDescription = "FFI-based OpenSSL binding for LuaJIT.";
        homepage = "https://github.com/fffonion/lua-resty-openssl";
        license = lib.licenses.free;
      };
    }
  ) { };

  lua-resty-session = callPackage (
    {
      fetchurl,
      fetchFromGitHub,
      buildLuarocksPackage,
      lua-ffi-zlib,
      lua-resty-openssl,
      luaOlder,
    }:
    buildLuarocksPackage {
      pname = "lua-resty-session";
      version = "4.1.5-1";

      src = fetchFromGitHub {
        owner = "bungle";
        repo = "lua-resty-session";
        tag = "v4.1.5";
        hash = "sha256-qwXNEWU0i3PUJK5cUChkcH43HnBCz4EEVPDQQ10Je+Q=";
      };

      propagatedBuildInputs = [
        lua-ffi-zlib
        lua-resty-openssl
      ];

      disabled = luaOlder "5.1";

      knownRockspec =
        (fetchurl {
          sha256 = "1mapndwa260pk18v4nwnmz4bncqizfn1zc8k8aj1557pc1fj5ii6";
          url = "mirror://luarocks/lua-resty-session-4.1.5-1.rockspec";
        }).outPath;

      meta = {
        description = "Session Library for OpenResty - Flexible and Secure";
        longDescription = "lua-resty-session is a secure, and flexible session library for OpenResty.";
        homepage = "https://github.com/bungle/lua-resty-session";
        license = lib.licenses.free;
      };
    }
  ) { };

  lua-rtoml = callPackage (
    {
      fetchFromGitHub,
      buildLuarocksPackage,
      luaOlder,
      luarocks-build-rust-mlua,
    }:
    buildLuarocksPackage {
      pname = "lua-rtoml";
      version = "0.3-0";

      src = fetchFromGitHub {
        owner = "lblasc";
        repo = "lua-rtoml";
        rev = "aedc4030912e1c86a1490428dc547f35a1a99be6";
        hash = "sha256-Ge2Acy1XuAQENhoJpuRudazY2D8HSiVv1Ab+jqMjo0U=";
      };

      nativeBuildInputs = [ luarocks-build-rust-mlua ];
      propagatedBuildInputs = [ luarocks-build-rust-mlua ];
      disabled = luaOlder "5.1";

      meta = {
        description = "Lua bindings for the Rust toml crate.";
        homepage = "https://github.com/lblasc/lua-rtoml";
        license = lib.licenses.mit;
        maintainers = with lib.maintainers; [ lblasc ];
      };
    }
  ) { };

  lua-subprocess = callPackage (
    {
      fetchFromGitHub,
      buildLuarocksPackage,
      luaOlder,
    }:
    buildLuarocksPackage {
      pname = "subprocess";
      version = "scm-1";

      src = fetchFromGitHub {
        owner = "0x0ade";
        repo = "lua-subprocess";
        rev = "bfa8e97da774141f301cfd1106dca53a30a4de54";
        hash = "sha256-4LiYWB3PAQ/s33Yj/gwC+Ef1vGe5FedWexeCBVSDIV0=";
      };

      disabled = luaOlder "5.1";

      meta = {
        description = "A Lua module written in C that allows you to create child processes and communicate with them.";
        longDescription = "A Lua module written in C that allows you to create child processes and communicate with them. The API is based on the Python subprocess module, but is not yet as complete.";
        homepage = "https://github.com/xlq/lua-subprocess";
        license = lib.licenses.mit;
        maintainers = with lib.maintainers; [ scoder12 ];
      };
    }
  ) { };

  lua-term = callPackage (
    { fetchurl, buildLuarocksPackage }:
    buildLuarocksPackage {
      pname = "lua-term";
      version = "0.8-1";

      src = fetchurl {
        url = "https://github.com/hoelzro/lua-term/archive/0.08.tar.gz";
        sha256 = "1vfdg5dzqdi3gn6wpc9a3djhsl6fn2ikqdwr8rrqrnd91qwlzycg";
      };

      knownRockspec =
        (fetchurl {
          sha256 = "1728lj3x8shc5m1yczrl75szq15rnfpzk36n0m49181ly9wxn7s0";
          url = "mirror://luarocks/lua-term-0.8-1.rockspec";
        }).outPath;

      meta = {
        description = "Terminal functions for Lua";
        homepage = "https://github.com/hoelzro/lua-term";

        license = lib.licenses.AND [
          lib.licenses.mit
          lib.licenses.x11
        ];
      };
    }
  ) { };

  lua-toml = callPackage (
    {
      fetchurl,
      fetchFromGitHub,
      buildLuarocksPackage,
      luaOlder,
    }:
    buildLuarocksPackage {
      pname = "lua-toml";
      version = "2.0-1";

      src = fetchFromGitHub {
        owner = "jonstoler";
        repo = "lua-toml";
        tag = "v2.0.1";
        hash = "sha256-6wCo06Ulmx6HVN2bTrklPqgGiEhDZ1fUfusdS/SDdFI=";
      };

      disabled = luaOlder "5.1";

      knownRockspec =
        (fetchurl {
          sha256 = "0zd3hrj1ifq89rjby3yn9y96vk20ablljvqdap981navzlbb7zvq";
          url = "mirror://luarocks/lua-toml-2.0-1.rockspec";
        }).outPath;

      meta = {
        description = "toml decoder/encoder for Lua";
        longDescription = "TOML 0.4.0 compliant Lua library with tests. Serializes TOML into a Lua table, and serlaizes Lua tables into TOML.";
        homepage = "https://github.com/jonstoler/lua-toml";
        license = lib.licenses.mit;
      };
    }
  ) { };

  lua-utils-nvim = callPackage (
    {
      fetchurl,
      buildLuarocksPackage,
      fetchzip,
      luaOlder,
    }:
    buildLuarocksPackage {
      pname = "lua-utils.nvim";
      version = "1.0.2-1";

      src = fetchzip {
        url = "https://github.com/nvim-neorg/lua-utils.nvim/archive/v1.0.2.zip";
        sha256 = "0bnl2kvxs55l8cjhfpa834bm010n8r4gmsmivjcp548c076msagn";
      };

      disabled = luaOlder "5.1";

      knownRockspec =
        (fetchurl {
          sha256 = "0s11j4vd26haz72rb0c5m5h953292rh8r62mvlxbss6i69v2dkr9";
          url = "mirror://luarocks/lua-utils.nvim-1.0.2-1.rockspec";
        }).outPath;

      meta = {
        description = "A set of utility functions for Neovim plugins.";

        longDescription = ''
          This repository contains a small set of nicities for performing repetitive tasks within Neovim.
          This set may shrink further as the features are included in other, larger "utility kits".
          The code you see in this repository is primarily used within Neorg.
          All functions are annotated using LuaCATS.'';

        homepage = "https://github.com/nvim-neorg/lua-utils.nvim";
        license = lib.licenses.mit;
        maintainers = with lib.maintainers; [ mrcjkb ];
      };
    }
  ) { };

  lua-yajl = callPackage (
    {
      fetchurl,
      fetchFromGitHub,
      buildLuarocksPackage,
      luaOlder,
    }:
    buildLuarocksPackage {
      pname = "lua-yajl";
      version = "2.1-0";

      src = fetchFromGitHub {
        owner = "brimworks";
        repo = "lua-yajl";
        tag = "v2.1";
        hash = "sha256-zHBNedJkGEm47HpbeJvcm6JNUUfA1OunLHPJulR8rF8=";
      };

      disabled = luaOlder "5.1";

      knownRockspec =
        (fetchurl {
          sha256 = "02jlgd4583p3q4w6hjgmdfkasxhamaj58byyrbmnch0qii61in9r";
          url = "mirror://luarocks/lua-yajl-2.1-0.rockspec";
        }).outPath;

      meta = {
        description = "Integrate the yajl JSON library with Lua.";
        homepage = "http://github.com/brimworks/lua-yajl";

        license = lib.licenses.AND [
          lib.licenses.mit
          lib.licenses.x11
        ];

        maintainers = with lib.maintainers; [ pstn ];
      };
    }
  ) { };

  lua-zlib = callPackage (
    {
      fetchurl,
      fetchFromGitHub,
      buildLuarocksPackage,
      luaOlder,
    }:
    buildLuarocksPackage {
      pname = "lua-zlib";
      version = "1.4-0";

      src = fetchFromGitHub {
        owner = "brimworks";
        repo = "lua-zlib";
        tag = "v1.4";
        hash = "sha256-z25OtHroEVUFraeFwajbmIiyD3hlZ12FnWs5uUBLm2Y=";
      };

      disabled = luaOlder "5.1";

      knownRockspec =
        (fetchurl {
          sha256 = "1cfxph2cski4nn7vnqcpywm89lcf8vwnvykdva53ck3b3dmsj204";
          url = "mirror://luarocks/lua-zlib-1.4-0.rockspec";
        }).outPath;

      meta = {
        description = "Simple streaming interface to zlib for Lua.";

        longDescription = ''
          Simple streaming interface to zlib for Lua.
                Consists of two functions: inflate and deflate.
                Both functions return "stream functions" (takes a buffer of input and returns a buffer of output).
                This project is hosted on github.
        '';

        homepage = "https://github.com/brimworks/lua-zlib";
        license = lib.licenses.mit;
        maintainers = with lib.maintainers; [ koral ];
      };
    }
  ) { };

  lua_cliargs = callPackage (
    {
      fetchurl,
      fetchFromGitHub,
      buildLuarocksPackage,
      luaOlder,
    }:
    buildLuarocksPackage {
      pname = "lua_cliargs";
      version = "3.0.2-1";

      src = fetchFromGitHub {
        owner = "lunarmodules";
        repo = "lua_cliargs";
        tag = "v3.0.2";
        hash = "sha256-wL3qBQ8Lu3q8DK2Kaeo1dgzIHd8evaxFYJg47CcQiSg=";
      };

      disabled = luaOlder "5.1";

      knownRockspec =
        (fetchurl {
          sha256 = "1gp3n9ipaqdk59ilqx1ci5faxmx4dh9sgg3279jb8yfa7wg5b8pf";
          url = "mirror://luarocks/lua_cliargs-3.0.2-1.rockspec";
        }).outPath;

      meta = {
        description = "A command-line argument parsing module for Lua";

        longDescription = ''
          This module adds support for accepting CLI arguments easily using multiple
                notations and argument types.

                cliargs allows you to define required, optional, and flag arguments.
        '';

        homepage = "https://github.com/lunarmodules/lua_cliargs.git";
        license = lib.licenses.mit;
      };
    }
  ) { };

  luabitop = callPackage (
    {
      fetchFromGitHub,
      buildLuarocksPackage,
      luaAtLeast,
      luaOlder,
    }:
    buildLuarocksPackage {
      pname = "luabitop";
      version = "1.0.2-3";

      src = fetchFromGitHub {
        owner = "teto";
        repo = "luabitop";
        rev = "96f0a3d73ae5183d0a81bc2f29326eaa06becbfd";
        hash = "sha256-PrM8ncb3TaqgVhFdRa+rUsJ5WuIzS4/DRqVqj8tCaeg=";
      };

      disabled = luaOlder "5.1" || luaAtLeast "5.3";

      meta = {
        description = "Lua Bit Operations Module";

        longDescription = ''
          Lua BitOp is a C extension module for Lua 5.1 which adds bitwise operations on numbers. 
          Lua BitOp is Copyright © 2008 Mike Pall. Lua BitOp is free software, released under the MIT/X license (same license as the Lua core).
        '';

        homepage = "http://bitop.luajit.org/";

        license = lib.licenses.AND [
          lib.licenses.mit
          lib.licenses.x11
        ];
      };
    }
  ) { };

  luacheck = callPackage (
    {
      fetchurl,
      fetchFromGitHub,
      argparse,
      buildLuarocksPackage,
      luaOlder,
      luafilesystem,
    }:
    buildLuarocksPackage {
      pname = "luacheck";
      version = "1.2.0-1";

      src = fetchFromGitHub {
        owner = "lunarmodules";
        repo = "luacheck";
        tag = "v1.2.0";
        hash = "sha256-6aDXZRLq2c36dbasyVzcecQKoMvY81RIGYasdF211UY=";
      };

      propagatedBuildInputs = [
        argparse
        luafilesystem
      ];

      disabled = luaOlder "5.1";

      knownRockspec =
        (fetchurl {
          sha256 = "0jnmrppq5hp8cwiw1daa33cdn8y2n5lsjk8vzn7ixb20ddz01m6c";
          url = "mirror://luarocks/luacheck-1.2.0-1.rockspec";
        }).outPath;

      meta = {
        description = "A static analyzer and a linter for Lua";

        longDescription = ''
          Luacheck is a command-line tool for linting and static analysis of Lua
                code. It is able to spot usage of undefined global variables, unused
                local variables and a few other typical problems within Lua programs.
        '';

        homepage = "https://github.com/lunarmodules/luacheck";
        license = lib.licenses.mit;
      };
    }
  ) { };

  luacov = callPackage (
    {
      fetchurl,
      fetchFromGitHub,
      buildLuarocksPackage,
      datafile,
      luaOlder,
    }:
    buildLuarocksPackage {
      pname = "luacov";
      version = "0.17.0-1";

      src = fetchFromGitHub {
        owner = "lunarmodules";
        repo = "luacov";
        tag = "v0.17.0";
        hash = "sha256-UI+6+0g3ldbKUsXCAgYll8v25gwEUn5A102Pn/H0c60=";
      };

      propagatedBuildInputs = [ datafile ];
      disabled = luaOlder "5.1";

      knownRockspec =
        (fetchurl {
          sha256 = "042jp0nfy3hcnbywlfp4jkrm9xpxrkggs57q616p4win9ibxcqjy";
          url = "mirror://luarocks/luacov-0.17.0-1.rockspec";
        }).outPath;

      meta = {
        description = "Coverage analysis tool for Lua scripts";

        longDescription = ''
          LuaCov is a simple coverage analysis tool for Lua scripts.
                When a Lua script is run with the luacov module, it
                generates a stats file. The luacov command-line script then
                processes this file generating a report indicating which code
                paths were not traversed, which is useful for verifying the
                effectiveness of a test suite.
        '';

        homepage = "https://lunarmodules.github.ioluacov/";
        license = lib.licenses.mit;
      };
    }
  ) { };

  luacov-reporter-lcov = callPackage (
    {
      fetchurl,
      buildLuarocksPackage,
      fetchzip,
      luaOlder,
      luacov,
    }:
    buildLuarocksPackage {
      pname = "luacov-reporter-lcov";
      version = "0.2-0";

      src = fetchzip {
        url = "https://github.com/daurnimator/luacov-reporter-lcov/archive/v0.2.zip";
        sha256 = "0bw0wyq9zqpcjbqpnlkpxs5g1i015n2rsh0iic4vapmcy7sxlx7w";
      };

      propagatedBuildInputs = [ luacov ];
      disabled = luaOlder "5.1";

      knownRockspec =
        (fetchurl {
          sha256 = "16w0vsv9q69zr0rw61x0p3cly755nzi83c83jk579qhxk16ja6c2";
          url = "mirror://luarocks/luacov-reporter-lcov-0.2-0.rockspec";
        }).outPath;

      meta = {
        description = "A luacov reporter for use with lcov";
        homepage = "https://github.com/daurnimator/luacov-reporter-lcov";
        license = lib.licenses.mit;
        maintainers = with lib.maintainers; [ ulysseszhan ];
      };
    }
  ) { };

  luadbi = callPackage (
    {
      fetchurl,
      fetchFromGitHub,
      buildLuarocksPackage,
      luaAtLeast,
      luaOlder,
    }:
    buildLuarocksPackage {
      pname = "luadbi";
      version = "0.7.5-1";

      src = fetchFromGitHub {
        owner = "mwild1";
        repo = "luadbi";
        tag = "v0.7.5";
        hash = "sha256-KShn2FLRYf7oc0+jce2JIUePx+eRFeCq+K9EFXz5tU8=";
      };

      disabled = luaOlder "5.1" || luaAtLeast "5.5";

      knownRockspec =
        (fetchurl {
          sha256 = "1xd4jkqd74zqcpql4kyqlv2n1q4k4bvj2l59nz0fmqbmmlmfk0fw";
          url = "mirror://luarocks/luadbi-0.7.5-1.rockspec";
        }).outPath;

      meta = {
        description = "Database abstraction layer";

        longDescription = ''
          LuaDBI is a database interface library for Lua. It is designed 
          		to provide a RDBMS agnostic API for handling database 
          		operations. LuaDBI also provides support for prepared statement 
          		handles, placeholders and bind parameters for all database 
          		operations.
          		
          		This rock is the front end DBI module. You will need one or 
          		more backend DBD drivers to use this software.
          	'';

        homepage = "https://github.com/mwild1/luadbi";

        license = lib.licenses.AND [
          lib.licenses.mit
          lib.licenses.x11
        ];
      };
    }
  ) { };

  luadbi-mysql = callPackage (
    {
      fetchurl,
      fetchFromGitHub,
      buildLuarocksPackage,
      luaAtLeast,
      luaOlder,
      luadbi,
    }:
    buildLuarocksPackage {
      pname = "luadbi-mysql";
      version = "0.7.5-1";

      src = fetchFromGitHub {
        owner = "mwild1";
        repo = "luadbi";
        tag = "v0.7.5";
        hash = "sha256-KShn2FLRYf7oc0+jce2JIUePx+eRFeCq+K9EFXz5tU8=";
      };

      propagatedBuildInputs = [ luadbi ];
      disabled = luaOlder "5.1" || luaAtLeast "5.5";

      knownRockspec =
        (fetchurl {
          sha256 = "1bb89d56aplz7m58g6cmscd2xgpxm38f2m72yabq5n0vg1bm2ypn";
          url = "mirror://luarocks/luadbi-mysql-0.7.5-1.rockspec";
        }).outPath;

      meta = {
        description = "Database abstraction layer";

        longDescription = ''
          LuaDBI is a database interface library for Lua. It is designed 
          		to provide a RDBMS agnostic API for handling database 
          		operations. LuaDBI also provides support for prepared statement 
          		handles, placeholders and bind parameters for all database 
          		operations.
          		
          		This rock is the MySQL DBD module. You will also need the
          		base DBI module to use this software.
          	'';

        homepage = "https://github.com/mwild1/luadbi";

        license = lib.licenses.AND [
          lib.licenses.mit
          lib.licenses.x11
        ];
      };
    }
  ) { };

  luadbi-postgresql = callPackage (
    {
      fetchurl,
      fetchFromGitHub,
      buildLuarocksPackage,
      luaAtLeast,
      luaOlder,
      luadbi,
    }:
    buildLuarocksPackage {
      pname = "luadbi-postgresql";
      version = "0.7.5-1";

      src = fetchFromGitHub {
        owner = "mwild1";
        repo = "luadbi";
        tag = "v0.7.5";
        hash = "sha256-KShn2FLRYf7oc0+jce2JIUePx+eRFeCq+K9EFXz5tU8=";
      };

      propagatedBuildInputs = [ luadbi ];
      disabled = luaOlder "5.1" || luaAtLeast "5.5";

      knownRockspec =
        (fetchurl {
          sha256 = "077nlwxh0dxrp0d0ysjcv3cwz77yn7phvzfn06wdd4vg591cnzg1";
          url = "mirror://luarocks/luadbi-postgresql-0.7.5-1.rockspec";
        }).outPath;

      meta = {
        description = "Database abstraction layer";

        longDescription = ''
          LuaDBI is a database interface library for Lua. It is designed 
          		to provide a RDBMS agnostic API for handling database 
          		operations. LuaDBI also provides support for prepared statement 
          		handles, placeholders and bind parameters for all database 
          		operations.
          		
          		This rock is the PostgreSQL DBD module. You will also need the
          		base DBI module to use this software.
          	'';

        homepage = "https://github.com/mwild1/luadbi";

        license = lib.licenses.AND [
          lib.licenses.mit
          lib.licenses.x11
        ];
      };
    }
  ) { };

  luadbi-sqlite3 = callPackage (
    {
      fetchurl,
      fetchFromGitHub,
      buildLuarocksPackage,
      luaAtLeast,
      luaOlder,
      luadbi,
    }:
    buildLuarocksPackage {
      pname = "luadbi-sqlite3";
      version = "0.7.5-1";

      src = fetchFromGitHub {
        owner = "mwild1";
        repo = "luadbi";
        tag = "v0.7.5";
        hash = "sha256-KShn2FLRYf7oc0+jce2JIUePx+eRFeCq+K9EFXz5tU8=";
      };

      propagatedBuildInputs = [ luadbi ];
      disabled = luaOlder "5.1" || luaAtLeast "5.5";

      knownRockspec =
        (fetchurl {
          sha256 = "0gvc6p8cpkr500dc5kq6k38q3wc09z0aw3w3ialdvjv9jcq7dqlr";
          url = "mirror://luarocks/luadbi-sqlite3-0.7.5-1.rockspec";
        }).outPath;

      meta = {
        description = "Database abstraction layer";

        longDescription = ''
          LuaDBI is a database interface library for Lua. It is designed 
          		to provide a RDBMS agnostic API for handling database 
          		operations. LuaDBI also provides support for prepared statement 
          		handles, placeholders and bind parameters for all database 
          		operations.
          		
          		This rock is the Sqlite3 DBD module. You will also need the
          		base DBI module to use this software.
          	'';

        homepage = "https://github.com/mwild1/luadbi";

        license = lib.licenses.AND [
          lib.licenses.mit
          lib.licenses.x11
        ];
      };
    }
  ) { };

  luaepnf = callPackage (
    {
      fetchurl,
      fetchFromGitHub,
      buildLuarocksPackage,
      lpeg,
      luaAtLeast,
      luaOlder,
    }:
    buildLuarocksPackage {
      pname = "luaepnf";
      version = "0.3-2";

      src = fetchFromGitHub {
        owner = "siffiejoe";
        repo = "lua-luaepnf";
        tag = "v0.3";
        hash = "sha256-iZksr6Ljy94D0VO4xSRO9s/VgcURvCfDMX9DOt2IetM=";
      };

      propagatedBuildInputs = [ lpeg ];
      disabled = luaOlder "5.1" || luaAtLeast "5.5";

      knownRockspec =
        (fetchurl {
          sha256 = "0kqmnj11wmfpc9mz04zzq8ab4mnbkrhcgc525wrq6pgl3p5li8aa";
          url = "mirror://luarocks/luaepnf-0.3-2.rockspec";
        }).outPath;

      meta = {
        description = "Extended PEG Notation Format (easy grammars for LPeg)";

        longDescription = ''
          This Lua module provides sugar for writing grammars/parsers using
              the LPeg library. It simplifies error reporting and AST building.
        '';

        homepage = "http://siffiejoe.github.io/lua-luaepnf/";
        license = lib.licenses.mit;
      };
    }
  ) { };

  luaevent = callPackage (
    {
      fetchurl,
      buildLuarocksPackage,
      luaOlder,
    }:
    buildLuarocksPackage {
      pname = "luaevent";
      version = "0.4.6-1";

      src = fetchurl {
        url = "https://github.com/harningt/luaevent/archive/v0.4.6.tar.gz";
        sha256 = "0pbh315d3p7hxgzmbhphkcldxv2dadbka96131b8j5914nxvl4nx";
      };

      disabled = luaOlder "5.1";

      knownRockspec =
        (fetchurl {
          sha256 = "03zixadhx4a7nh67n0sm6sy97c8i9va1a78hibhrl7cfbqc2zc7f";
          url = "mirror://luarocks/luaevent-0.4.6-1.rockspec";
        }).outPath;

      meta = {
        description = "libevent binding for Lua";

        longDescription = ''
          This is a binding of libevent to Lua
        '';

        homepage = "https://github.com/harningt/luaevent";
        license = lib.licenses.mit;
      };
    }
  ) { };

  luaexpat = callPackage (
    {
      fetchurl,
      fetchFromGitHub,
      buildLuarocksPackage,
      luaOlder,
    }:
    buildLuarocksPackage {
      pname = "luaexpat";
      version = "1.5.2-1";

      src = fetchFromGitHub {
        owner = "lunarmodules";
        repo = "luaexpat";
        tag = "1.5.2";
        hash = "sha256-PudxKlN4WKUUK/h6ekVNSa/C453CnLh3TxCncXIOiw8=";
      };

      disabled = luaOlder "5.1";

      knownRockspec =
        (fetchurl {
          sha256 = "0wdbph2c92zmvvyp3q669rbjy1xjm7jy1i13lin8b636vswykw6p";
          url = "mirror://luarocks/luaexpat-1.5.2-1.rockspec";
        }).outPath;

      meta = {
        description = "XML Expat parsing";

        longDescription = ''
          LuaExpat is a SAX (Simple API for XML) XML parser based on the
          		Expat library.
          	'';

        homepage = "https://lunarmodules.github.io/luaexpat";

        license = lib.licenses.AND [
          lib.licenses.mit
          lib.licenses.x11
        ];

        maintainers = with lib.maintainers; [
          arobyn
          flosse
        ];
      };
    }
  ) { };

  luaffi = callPackage (
    {
      fetchurl,
      fetchFromGitHub,
      buildLuarocksPackage,
      luaOlder,
    }:
    buildLuarocksPackage {
      pname = "luaffi";
      version = "scm-1";

      src = fetchFromGitHub {
        owner = "facebook";
        repo = "luaffifb";
        rev = "a1cb731b08c91643b0665935eb5622b3d621211b";
        hash = "sha256-wRjAtEEy8KSlIoi/IIutL73Vbm1r+zKs26dEP7gzR1o=";
      };

      disabled = luaOlder "5.1";

      knownRockspec =
        (fetchurl {
          sha256 = "1nia0g4n1yv1sbv5np572y8yfai56a8bnscir807s5kj5bs0xhxm";
          url = "mirror://luarocks/luaffi-scm-1.rockspec";
        }).outPath;

      meta = {
        description = "FFI library for calling C functions from lua";
        longDescription = "";
        homepage = "https://github.com/facebook/luaffifb";
        license = lib.licenses.free;
      };
    }
  ) { };

  luafilesystem = callPackage (
    {
      fetchurl,
      fetchFromGitHub,
      buildLuarocksPackage,
      luaOlder,
    }:
    buildLuarocksPackage {
      pname = "luafilesystem";
      version = "1.9.0-1";

      src = fetchFromGitHub {
        owner = "lunarmodules";
        repo = "luafilesystem";
        tag = "v1_9_0";
        hash = "sha256-xoNJra/yqxRG11TePcUKrAUU6cwypGnXIoLKZXNaoW0=";
      };

      disabled = luaOlder "5.1";

      knownRockspec =
        (fetchurl {
          sha256 = "1jg1w8c22hpv1jfcv6qyl3j354h1ar2qfarkiwx0c41sl90gpfrj";
          url = "mirror://luarocks/luafilesystem-1.9.0-1.rockspec";
        }).outPath;

      meta = {
        description = "File System Library for the Lua Programming Language";

        longDescription = ''
          LuaFileSystem is a Lua library developed to complement the set of
                functions related to file systems offered by the standard Lua
                distribution. LuaFileSystem offers a portable way to access the
                underlying directory structure and file attributes.
        '';

        homepage = "https://github.com/lunarmodules/luafilesystem";

        license = lib.licenses.AND [
          lib.licenses.mit
          lib.licenses.x11
        ];

        maintainers = with lib.maintainers; [ flosse ];
      };
    }
  ) { };

  lualdap = callPackage (
    {
      fetchurl,
      fetchFromGitHub,
      buildLuarocksPackage,
      luaOlder,
    }:
    buildLuarocksPackage {
      pname = "lualdap";
      version = "1.4.0-1";

      src = fetchFromGitHub {
        owner = "lualdap";
        repo = "lualdap";
        tag = "v1.4.0";
        hash = "sha256-u91T7RlRa87CbYXZLhrzcpVvZWsCnQObmbS86kfsAHc=";
      };

      disabled = luaOlder "5.1";

      knownRockspec =
        (fetchurl {
          sha256 = "0n924gxm6ccr9hjk4bi5z70vgh7g75dl7293pab41a2qcrlsj9nk";
          url = "mirror://luarocks/lualdap-1.4.0-1.rockspec";
        }).outPath;

      meta = {
        description = "A Lua interface to the OpenLDAP library";

        longDescription = ''
          LuaLDAP is a simple interface from Lua to an LDAP client, in
                 fact it is a bind to OpenLDAP. It enables a Lua program to
                 connect to an LDAP server; execute any operation (search, add,
                 compare, delete, modify and rename); retrieve entries and
                 references of the search result.
        '';

        homepage = "https://lualdap.github.io/lualdap/";
        license = lib.licenses.mit;
        maintainers = with lib.maintainers; [ aanderse ];
      };
    }
  ) { };

  lualine-nvim = callPackage (
    {
      fetchurl,
      fetchFromGitHub,
      buildLuarocksPackage,
      luaOlder,
    }:
    buildLuarocksPackage {
      pname = "lualine.nvim";
      version = "scm-5";

      src = fetchFromGitHub {
        owner = "nvim-lualine";
        repo = "lualine.nvim";
        rev = "221ce6b2d999187044529f49da6554a92f740a96";
        hash = "sha256-6PjGu30Ed4/e/HQ3mIFQuUOxcCiti/71jjlMsjN7EoA=";
      };

      disabled = luaOlder "5.1";

      knownRockspec =
        (fetchurl {
          sha256 = "02sll9l2j03h5wv5mlm1wwqijhs9a8sgn5k4mi21f58si1s7ycda";
          url = "mirror://luarocks/lualine.nvim-scm-5.rockspec";
        }).outPath;

      meta = {
        description = "A blazing fast and easy to configure neovim statusline plugin written in pure lua.";
        homepage = "https://github.com/nvim-lualine/lualine.nvim";
        license = lib.licenses.mit;
      };
    }
  ) { };

  lualogging = callPackage (
    {
      fetchurl,
      fetchFromGitHub,
      buildLuarocksPackage,
      luasocket,
    }:
    buildLuarocksPackage {
      pname = "lualogging";
      version = "1.8.2-1";

      src = fetchFromGitHub {
        owner = "lunarmodules";
        repo = "lualogging";
        tag = "v1.8.2";
        hash = "sha256-RIblf2C9H6Iajzc9aqnvrK4xq8FAHq9InTO6m3aM5dc=";
      };

      propagatedBuildInputs = [ luasocket ];

      knownRockspec =
        (fetchurl {
          sha256 = "164c4xgwkv2ya8fbb22wm48ywc4gx939b574r6bgl8zqayffdqmx";
          url = "mirror://luarocks/lualogging-1.8.2-1.rockspec";
        }).outPath;

      meta = {
        description = "A simple API to use logging features";

        longDescription = ''
          LuaLogging provides a simple API to use logging features in Lua. Its design was
              based on log4j. LuaLogging currently supports, through the use of appenders,
              console, file, rolling file, email, socket and SQL outputs.
        '';

        homepage = "https://github.com/lunarmodules/lualogging";

        license = lib.licenses.AND [
          lib.licenses.mit
          lib.licenses.x11
        ];
      };
    }
  ) { };

  luaossl = callPackage (
    {
      fetchurl,
      buildLuarocksPackage,
      fetchzip,
    }:
    buildLuarocksPackage {
      pname = "luaossl";
      version = "20250929-0";

      src = fetchzip {
        url = "https://github.com/wahern/luaossl/archive/rel-20250929.zip";
        sha256 = "115a5r0n7qc9lnjxld551ag6l9rq1wawcbrfjqhz2l6krb3pbv3d";
      };

      knownRockspec =
        (fetchurl {
          sha256 = "11m823vd8cwc3s5420lv042ny1d7hrimzx05ldy8f6rlh6m2d9xl";
          url = "mirror://luarocks/luaossl-20250929-0.rockspec";
        }).outPath;

      meta = {
        description = "Most comprehensive OpenSSL module in the Lua universe.";
        homepage = "http://25thandclement.com/~william/projects/luaossl.html";

        license = lib.licenses.AND [
          lib.licenses.mit
          lib.licenses.x11
        ];
      };
    }
  ) { };

  luaposix = callPackage (
    {
      fetchurl,
      buildLuarocksPackage,
      fetchzip,
      luaAtLeast,
      luaOlder,
    }:
    buildLuarocksPackage {
      pname = "luaposix";
      version = "36.3-1";

      src = fetchzip {
        url = "http://github.com/luaposix/luaposix/archive/v36.3.zip";
        sha256 = "0k05mpscsqx1yd5vy126brzc35xk55nck0g7m91vrbvvq3bcg824";
      };

      disabled = luaOlder "5.1" || luaAtLeast "5.5";

      knownRockspec =
        (fetchurl {
          sha256 = "0jwah6b1bxzck29zxbg479zm1sqmg7vafh7rrkfpibdbwnq01yzb";
          url = "mirror://luarocks/luaposix-36.3-1.rockspec";
        }).outPath;

      meta = {
        description = "Lua bindings for POSIX";

        longDescription = ''
          A library binding various POSIX APIs. POSIX is the IEEE Portable
                Operating System Interface standard. luaposix is based on lposix.
        '';

        homepage = "http://github.com/luaposix/luaposix/";

        license = lib.licenses.AND [
          lib.licenses.mit
          lib.licenses.x11
        ];

        maintainers = with lib.maintainers; [ lblasc ];
      };
    }
  ) { };

  luaprompt = callPackage (
    {
      fetchurl,
      fetchFromGitHub,
      argparse,
      buildLuarocksPackage,
      luaOlder,
    }:
    buildLuarocksPackage {
      pname = "luaprompt";
      version = "0.9-1";

      src = fetchFromGitHub {
        owner = "dpapavas";
        repo = "luaprompt";
        tag = "v0.9";
        hash = "sha256-S6bzlIY1KlMK3wy01wGuRujGFgPxcNWmCaISQ87EBGs=";
      };

      propagatedBuildInputs = [ argparse ];
      disabled = luaOlder "5.1";

      knownRockspec =
        (fetchurl {
          sha256 = "0bh4fpfrqbg9bappnrfr6blvl3lzc99plq7jac67mhph1bjki7rk";
          url = "mirror://luarocks/luaprompt-0.9-1.rockspec";
        }).outPath;

      meta = {
        description = "A Lua command prompt with pretty-printing and auto-completion";

        longDescription = ''
          luaprompt is both an interactive Lua prompt that can be used instead
          of the official interpreter, as well as module that provides a Lua
          command prompt that can be embedded in a host application.  As a
          standalone interpreter it provides many conveniences that are missing
          from the official Lua interpreter.  As an embedded prompt, it's meant
          for applications that use Lua as a configuration or interface language
          and can therefore benefit from an interactive prompt for debugging or
          regular use.

          luaprompt features:

          * Readline-based input with history and completion: In particular all
            keywords, global variables and table accesses (with string or
            integer keys) can be completed in addition to readline's standard
            file completion.  Module names are also completed, for modules
            installed in the standard directories, and completed modules can
            optionally be loaded.

          * Persistent command history (retained across sessions), as well as
            recording of command results for future reference.

          * Proper value pretty-printing for interactive use: When an expression
            is entered at the prompt, all returned values are printed
            (prepending with an equal sign is not required).  Values are printed
            in a descriptive way that tries to be as readable as possible.  The
            formatting tries to mimic Lua code (this is done to minimize
            ambiguities and no guarantees are made that it is valid code).
            Additionally, each value is stored in a table for future reference.

          * Color highlighting of error messages and variable printouts.
        '';

        homepage = "https://github.com/dpapavas/luaprompt";

        license = lib.licenses.AND [
          lib.licenses.mit
          lib.licenses.x11
        ];

        maintainers = with lib.maintainers; [ Freed-Wu ];
      };
    }
  ) { };

  luarepl = callPackage (
    {
      fetchurl,
      buildLuarocksPackage,
      luaOlder,
    }:
    buildLuarocksPackage {
      pname = "luarepl";
      version = "0.10-1";

      src = fetchurl {
        url = "https://github.com/hoelzro/lua-repl/archive/0.10.tar.gz";
        sha256 = "0wv37h9w6y5pgr39m7yxbf8imkwvaila6rnwjcp0xsxl5c1rzfjm";
      };

      disabled = luaOlder "5.1";

      knownRockspec =
        (fetchurl {
          sha256 = "12zdljfs4wg55mj7a38iwg7p5i1pmc934v9qlpi61sw4brp6x8d3";
          url = "mirror://luarocks/luarepl-0.10-1.rockspec";
        }).outPath;

      meta = {
        description = "A reusable REPL component for Lua, written in Lua";
        homepage = "https://github.com/hoelzro/lua-repl";

        license = lib.licenses.AND [
          lib.licenses.mit
          lib.licenses.x11
        ];
      };
    }
  ) { };

  luarocks = callPackage (
    {
      fetchurl,
      fetchFromGitHub,
      buildLuarocksPackage,
    }:
    buildLuarocksPackage {
      pname = "luarocks";
      version = "3.13.0-1";

      src = fetchFromGitHub {
        owner = "luarocks";
        repo = "luarocks";
        tag = "v3.13.0";
        hash = "sha256-ETVoDpeFSsW7ld2z31Vog3RKsMquoxd7c8m9y7Fb1wk=";
      };

      knownRockspec =
        (fetchurl {
          sha256 = "1kphpdvqjr47safz3w4q8xy3pwvrpgvkq4vzypfb5wg36p75jx5l";
          url = "mirror://luarocks/luarocks-3.13.0-1.rockspec";
        }).outPath;

      meta = {
        description = "A package manager for Lua modules.";

        longDescription = ''
          LuaRocks allows you to install Lua modules as self-contained
                packages called "rocks", which also contain version dependency
                information. This information is used both during installation,
                so that when one rock is requested all rocks it depends on are
                installed as well, and at run time, so that when a module is
                required, the correct version is loaded. LuaRocks supports both
                local and remote repositories, and multiple local rocks trees.
        '';

        homepage = "http://www.luarocks.org";
        license = lib.licenses.mit;

        maintainers = with lib.maintainers; [
          mrcjkb
          teto
        ];
      };
    }
  ) { };

  luarocks-build-rust-mlua = callPackage (
    {
      fetchurl,
      fetchFromGitHub,
      buildLuarocksPackage,
    }:
    buildLuarocksPackage {
      pname = "luarocks-build-rust-mlua";
      version = "0.2.7-1";

      src = fetchFromGitHub {
        owner = "mlua-rs";
        repo = "luarocks-build-rust-mlua";
        tag = "0.2.7";
        hash = "sha256-Zf/Ey5utsgzXqR8zlDse7KsyWA0RGx3hyvnJ36qhKG8=";
      };

      knownRockspec =
        (fetchurl {
          sha256 = "0wh1n7rg0fdllxi1vyvbqkrcl3jcqnjr3fwhwx9hc52xba850bna";
          url = "mirror://luarocks/luarocks-build-rust-mlua-0.2.7-1.rockspec";
        }).outPath;

      meta = {
        description = "A LuaRocks build backend for Lua modules written in Rust using mlua";
        homepage = "https://github.com/mlua-rs/luarocks-build-rust-mlua";
        license = lib.licenses.mit;
        maintainers = with lib.maintainers; [ mrcjkb ];
      };
    }
  ) { };

  luarocks-build-tree-sitter-cli = callPackage (
    {
      fetchurl,
      fetchFromGitHub,
      buildLuarocksPackage,
      luaOlder,
    }:
    buildLuarocksPackage {
      pname = "luarocks-build-tree-sitter-cli";
      version = "0.0.3-1";

      src = fetchFromGitHub {
        owner = "FourierTransformer";
        repo = "luarocks-build-tree-sitter-cli";
        tag = "0.0.3";
        hash = "sha256-Chc0eKvKyL9JM6MNX5GcRes1YA2+W842NDrX1nNMQ+E=";
      };

      disabled = luaOlder "5.1";

      knownRockspec =
        (fetchurl {
          sha256 = "0yy04svrll85zn334mhhnzzdqymsbiqymnr6iaj23h436v3gcq38";
          url = "mirror://luarocks/luarocks-build-tree-sitter-cli-0.0.3-1.rockspec";
        }).outPath;

      meta = {
        description = "A LuaRocks build backend to install the tree-sitter CLI";
        longDescription = "luarocks-build-tree-sitter-cli is a LuaRocks build.type that allows installing tree-sitter CLI binaries via LuaRocks directly. It works similarly to the npm install option for tree-sitter, but uses LuaRocks instead.";
        homepage = "https://github.com/FourierTransformer/luarocks-build-tree-sitter-cli";
        license = lib.licenses.mit;
      };
    }
  ) { };

  luarocks-build-treesitter-parser = callPackage (
    {
      fetchurl,
      buildLuarocksPackage,
      fetchzip,
      luaOlder,
      luafilesystem,
    }:
    buildLuarocksPackage {
      pname = "luarocks-build-treesitter-parser";
      version = "6.0.2-1";

      src = fetchzip {
        url = "https://github.com/lumen-oss/luarocks-build-treesitter-parser/archive/v6.0.2.zip";
        sha256 = "17877av310icqrv961ffhq852xx90wnpcxvqnylm476pndi1bf0f";
      };

      propagatedBuildInputs = [ luafilesystem ];
      disabled = luaOlder "5.1";

      knownRockspec =
        (fetchurl {
          sha256 = "0lwz15983gp29smykm3z6blhfd3ah3yi96j0g6di74nkz2kmfqk7";
          url = "mirror://luarocks/luarocks-build-treesitter-parser-6.0.2-1.rockspec";
        }).outPath;

      meta = {
        description = "A luarocks build backend for tree-sitter parsers.";
        homepage = "https://github.com/lumen-oss/luarocks-build-treesitter-parser";
        license = lib.licenses.mit;
        maintainers = with lib.maintainers; [ mrcjkb ];
      };
    }
  ) { };

  luarocks-build-treesitter-parser-cpp = callPackage (
    {
      fetchurl,
      buildLuarocksPackage,
      fetchzip,
      luaOlder,
      luafilesystem,
    }:
    buildLuarocksPackage {
      pname = "luarocks-build-treesitter-parser-cpp";
      version = "2.0.6-1";

      src = fetchzip {
        url = "https://github.com/lumen-oss/luarocks-build-treesitter-parser-cpp/archive/v2.0.6.zip";
        sha256 = "1kr56cvxryxxkwvd69ywplw80hyaasyzmx842zzsncac3191vwpl";
      };

      propagatedBuildInputs = [ luafilesystem ];
      disabled = luaOlder "5.1";

      knownRockspec =
        (fetchurl {
          sha256 = "10js4km023lc3876jr1j6gyzyni8v3dizzmc352sxhz9gz9kinia";
          url = "mirror://luarocks/luarocks-build-treesitter-parser-cpp-2.0.6-1.rockspec";
        }).outPath;

      meta = {
        description = "A luarocks build backend for tree-sitter parsers written in C++.";
        homepage = "https://github.com/lumen-oss/luarocks-build-treesitter-parser-cpp";
        license = lib.licenses.mit;
        maintainers = with lib.maintainers; [ mrcjkb ];
      };
    }
  ) { };

  luasec = callPackage (
    {
      fetchurl,
      fetchFromGitHub,
      buildLuarocksPackage,
      luaOlder,
      luasocket,
    }:
    buildLuarocksPackage {
      pname = "luasec";
      version = "1.3.2-1";

      src = fetchFromGitHub {
        owner = "brunoos";
        repo = "luasec";
        tag = "v1.3.2";
        hash = "sha256-o3uiZQnn/ID1qAgpZAqA4R3fWWk+Ajcgx++iNu1yLWc=";
      };

      propagatedBuildInputs = [ luasocket ];
      disabled = luaOlder "5.1";

      knownRockspec =
        (fetchurl {
          sha256 = "09nqs60cmbq1bi70cdh7v5xjnlsm2mrxv9pmbbvczijvz184jh33";
          url = "mirror://luarocks/luasec-1.3.2-1.rockspec";
        }).outPath;

      meta = {
        description = "A binding for OpenSSL library to provide TLS/SSL communication over LuaSocket.";
        longDescription = "This version delegates to LuaSocket the TCP connection establishment between the client and server. Then LuaSec uses this connection to start a secure TLS/SSL session.";
        homepage = "https://github.com/brunoos/luasec/wiki";
        license = lib.licenses.mit;
        maintainers = with lib.maintainers; [ flosse ];
      };
    }
  ) { };

  luasnip = callPackage (
    {
      fetchurl,
      buildLuarocksPackage,
      fetchzip,
      jsregexp,
      luaOlder,
    }:
    buildLuarocksPackage {
      pname = "luasnip";
      version = "2.5.0-1";

      src = fetchzip {
        url = "https://github.com/L3MON4D3/LuaSnip/archive/v2.5.0.zip";
        sha256 = "16cirbi0zjg874858yqd36p3kbrmlpfii3bvx6lm9bpli7b4w9kn";
      };

      propagatedBuildInputs = [ jsregexp ];
      disabled = luaOlder "5.1";

      knownRockspec =
        (fetchurl {
          sha256 = "1qgd4536yglz0v21bpia3q2xbjcakxh4jhphhficm7nqb82xfsap";
          url = "mirror://luarocks/luasnip-2.5.0-1.rockspec";
        }).outPath;

      meta = {
        description = "Snippet Engine for Neovim written in Lua.";
        homepage = "https://github.com/L3MON4D3/LuaSnip";
        license = lib.licenses.asl20;
      };
    }
  ) { };

  luasocket = callPackage (
    {
      fetchurl,
      fetchFromGitHub,
      buildLuarocksPackage,
      luaOlder,
    }:
    buildLuarocksPackage {
      pname = "luasocket";
      version = "3.1.0-1";

      src = fetchFromGitHub {
        owner = "lunarmodules";
        repo = "luasocket";
        tag = "v3.1.0";
        hash = "sha256-sKSzCrQpS+9reN9IZ4wkh4dB50wiIfA87xN4u1lyHo4=";
      };

      disabled = luaOlder "5.1";

      knownRockspec =
        (fetchurl {
          sha256 = "0wg9735cyz2gj7r9za8yi83w765g0f4pahnny7h0pdpx58pgfx4r";
          url = "mirror://luarocks/luasocket-3.1.0-1.rockspec";
        }).outPath;

      meta = {
        description = "Network support for the Lua language";

        longDescription = ''
          LuaSocket is a Lua extension library composed of two parts: a set of C
                modules that provide support for the TCP and UDP transport layers, and a
                set of Lua modules that provide functions commonly needed by applications
                that deal with the Internet.
        '';

        homepage = "https://github.com/lunarmodules/luasocket";
        license = lib.licenses.mit;
      };
    }
  ) { };

  luasql-sqlite3 = callPackage (
    {
      fetchurl,
      fetchFromGitHub,
      buildLuarocksPackage,
      luaOlder,
    }:
    buildLuarocksPackage {
      pname = "luasql-sqlite3";
      version = "2.8.0-1";

      src = fetchFromGitHub {
        owner = "lunarmodules";
        repo = "luasql";
        tag = "2.8.0";
        hash = "sha256-7FQa62eGe+bGkDF9+yte0JMcONPjoy5Zn5nohJG1KLA=";
      };

      disabled = luaOlder "5.1";

      knownRockspec =
        (fetchurl {
          sha256 = "1zqcs211idnji4fzyh5g6yn4ca13z690fx0i84gmbibvi5w9rqnl";
          url = "mirror://luarocks/luasql-sqlite3-2.8.0-1.rockspec";
        }).outPath;

      meta = {
        description = "Database connectivity for Lua (SQLite3 driver)";

        longDescription = ''
          LuaSQL is a simple interface from Lua to a DBMS. It enables a
                Lua program to connect to databases, execute arbitrary SQL statements
                and retrieve results in a row-by-row cursor fashion.
        '';

        homepage = "https://lunarmodules.github.io/luasql/";

        license = lib.licenses.AND [
          lib.licenses.mit
          lib.licenses.x11
        ];
      };
    }
  ) { };

  luassert = callPackage (
    {
      fetchurl,
      fetchFromGitHub,
      buildLuarocksPackage,
      luaOlder,
      say,
    }:
    buildLuarocksPackage {
      pname = "luassert";
      version = "1.9.0-1";

      src = fetchFromGitHub {
        owner = "lunarmodules";
        repo = "luassert";
        tag = "v1.9.0";
        hash = "sha256-jjdB95Vr5iVsh5T7E84WwZMW6/5H2k2R/ny2VBs2l3I=";
      };

      propagatedBuildInputs = [ say ];
      disabled = luaOlder "5.1";

      knownRockspec =
        (fetchurl {
          sha256 = "1bkzr03190p33lprgy51nl84aq082fyc3f7s3wkk7zlay4byycxd";
          url = "mirror://luarocks/luassert-1.9.0-1.rockspec";
        }).outPath;

      meta = {
        description = "Lua assertions extension";

        longDescription = ''
          Adds a framework that allows registering new assertions
              without compromising builtin assertion functionality.
        '';

        homepage = "https://lunarmodules.github.io/busted/";
        license = lib.licenses.mit;
      };
    }
  ) { };

  luasystem = callPackage (
    {
      fetchurl,
      fetchFromGitHub,
      buildLuarocksPackage,
      luaOlder,
    }:
    buildLuarocksPackage {
      pname = "luasystem";
      version = "0.7.1-1";

      src = fetchFromGitHub {
        owner = "lunarmodules";
        repo = "luasystem";
        tag = "v0.7.1";
        hash = "sha256-HxOtwWyAYOxTQXm0KyJVvSNTxWOJnn4pnX0FFu4HYh4=";
      };

      disabled = luaOlder "5.1";

      knownRockspec =
        (fetchurl {
          sha256 = "10hnakzkyjqh6plks2wz2844l7rw619vfc5b3idqw9pndpw6fylz";
          url = "mirror://luarocks/luasystem-0.7.1-1.rockspec";
        }).outPath;

      meta = {
        description = "Platform independent system calls for Lua.";

        longDescription = ''
          Adds a Lua API for making platform independent system calls.
        '';

        homepage = "https://github.com/lunarmodules/luasystem";
        license = lib.licenses.mit;
      };
    }
  ) { };

  luatext = callPackage (
    {
      fetchurl,
      fetchFromGitHub,
      buildLuarocksPackage,
      luaOlder,
    }:
    buildLuarocksPackage {
      pname = "luatext";
      version = "1.2.1-0";

      src = fetchFromGitHub {
        owner = "f4z3r";
        repo = "luatext";
        tag = "v1.2.1";
        hash = "sha256-StxCmjSSy3ok0hNkKTQyq4yS1LfX980R5pULCUjLPek=";
      };

      disabled = luaOlder "5.1";

      knownRockspec =
        (fetchurl {
          sha256 = "12ia4ibihd537mjmvdasnwgkinaygqwk03bsj3s0qrfhy6yz84ka";
          url = "mirror://luarocks/luatext-1.2.1-0.rockspec";
        }).outPath;

      meta = {
        description = "A small library to print colored text";

        longDescription = ''
          A libary providing an abstaction over ANSI escape codes
                that allow to print text to terminals in different colors
                and with various modifiers.
        '';

        homepage = "https://github.com/f4z3r/luatext/tree/main";
        license = lib.licenses.mit;
      };
    }
  ) { };

  luaunbound = callPackage (
    {
      fetchurl,
      buildLuarocksPackage,
      luaAtLeast,
      luaOlder,
    }:
    buildLuarocksPackage {
      pname = "luaunbound";
      version = "1.1.0-1";

      src = fetchurl {
        url = "https://code.zash.se/dl/luaunbound/luaunbound-1.1.0.tar.gz";
        sha256 = "0i02m7ivbjgj3271yvpac5pvm01nrynsff1pgp6d8qfc3r35jq93";
      };

      disabled = luaOlder "5.1" || luaAtLeast "5.6";

      knownRockspec =
        (fetchurl {
          sha256 = "0d0qybfl309yqnl8h35m6xynj4wnwmvm1cxl31jqrnahym30w5d8";
          url = "mirror://luarocks/luaunbound-1.1.0-1.rockspec";
        }).outPath;

      meta = {
        description = "A binding to libunbound";
        homepage = "https://www.zash.se/luaunbound.html";
        license = lib.licenses.mit;
      };
    }
  ) { };

  luaunit = callPackage (
    {
      fetchurl,
      buildLuarocksPackage,
      fetchzip,
      luaAtLeast,
      luaOlder,
    }:
    buildLuarocksPackage {
      pname = "luaunit";
      version = "3.5-1";

      src = fetchzip {
        url = "https://github.com/bluebird75/luaunit/releases/download/LUAUNIT_V3_5/rock-luaunit-3.5.zip";
        sha256 = "0qxk89c14s8gmzm7ka5caxn2qr3y4bxs1jqcni1hwfzkjh5jmyzk";
      };

      disabled = luaOlder "5.1" || luaAtLeast "5.6";

      knownRockspec =
        (fetchurl {
          sha256 = "0rn0d9ng91rhrhvzq965przpxz5xx9vfyyakscfggf8xhg9g8s9p";
          url = "mirror://luarocks/luaunit-3.5-1.rockspec";
        }).outPath;

      meta = {
        description = "A unit testing framework for Lua";

        longDescription = ''
          LuaUnit is a popular unit-testing framework for Lua, with an interface typical
          		of xUnit libraries (Python unittest, Junit, NUnit, ...). It supports 
          		several output formats (Text, TAP, JUnit, ...) to be used directly or work with Continuous Integration platforms
          		(Jenkins, Hudson, ...).

          		For simplicity, LuaUnit is contained into a single-file and has no external dependency. 

          		Tutorial and reference documentation is available on
          		[read-the-docs](http://luaunit.readthedocs.org/en/latest/)

          		LuaUnit may also be used as an assertion library, to validate assertions inside a running program. In addition, it provides
          		a pretty stringifier which converts any type into a nicely formatted string (including complex nested or recursive tables).

          		To install LuaUnit from LuaRocks, you need at least LuaRocks version 2.4.4 (due to old versions of wget being incompatible
          		with GitHub https downloading)

          	'';

        homepage = "http://github.com/bluebird75/luaunit";
        license = lib.licenses.free;
        maintainers = with lib.maintainers; [ lockejan ];
      };
    }
  ) { };

  luautf8 = callPackage (
    {
      fetchurl,
      buildLuarocksPackage,
      luaOlder,
    }:
    buildLuarocksPackage {
      pname = "luautf8";
      version = "0.2.1-1";

      src = fetchurl {
        url = "https://github.com/starwing/luautf8/archive/refs/tags/0.2.1.tar.gz";
        sha256 = "15455lyvjh5f6fgx41458nk7gak6q76k3aqjfp1xibk0v5f0flpa";
      };

      disabled = luaOlder "5.1";

      knownRockspec =
        (fetchurl {
          sha256 = "0g4xkcikxd2n9scrlbjbdk9a1bbli6s5yw9l4n4b0ss49wgnmc2y";
          url = "mirror://luarocks/luautf8-0.2.1-1.rockspec";
        }).outPath;

      meta = {
        description = "A UTF-8 support module for Lua";

        longDescription = ''
          This module adds UTF-8 support to Lua. It's compatible with Lua "string" module.
        '';

        homepage = "http://github.com/starwing/luautf8";
        license = lib.licenses.mit;
        maintainers = with lib.maintainers; [ pstn ];
      };
    }
  ) { };

  luazip = callPackage (
    {
      fetchurl,
      fetchFromGitHub,
      buildLuarocksPackage,
      luaAtLeast,
      luaOlder,
    }:
    buildLuarocksPackage {
      pname = "luazip";
      version = "1.2.7-1";

      src = fetchFromGitHub {
        owner = "mpeterv";
        repo = "luazip";
        tag = "1.2.7";
        hash = "sha256-pAuXdvF2hM3ApvOg5nn9EHTGlajujHMtHEoN3Sj+mMo=";
      };

      disabled = luaOlder "5.1" || luaAtLeast "5.4";

      knownRockspec =
        (fetchurl {
          sha256 = "1wxy3p2ksaq4s8lg925mi9cvbh875gsapgkzm323dr8qaxxg7mba";
          url = "mirror://luarocks/luazip-1.2.7-1.rockspec";
        }).outPath;

      meta = {
        description = "Library for reading files inside zip files";

        longDescription = ''
          LuaZip is a lightweight Lua extension library used to read files
          stored inside zip files. The API is very similar to the standard
          Lua I/O library API.
        '';

        homepage = "https://github.com/mpeterv/luazip";
        license = lib.licenses.mit;
      };
    }
  ) { };

  lusc_luv = callPackage (
    {
      fetchurl,
      fetchFromGitHub,
      buildLuarocksPackage,
      luaOlder,
      luv,
    }:
    buildLuarocksPackage {
      pname = "lusc_luv";
      version = "4.0.1-1";

      src = fetchFromGitHub {
        owner = "svermeulen";
        repo = "lusc_luv";
        tag = "main";
        hash = "sha256-xT3so0QHtzzLRNRb7yqfaRMwkl2bt1MP1xh8BkHKqqo=";
      };

      propagatedBuildInputs = [ luv ];
      disabled = luaOlder "5.1";

      knownRockspec =
        (fetchurl {
          sha256 = "1bgk481ljfy8q7r3w9z1x5ix0dm6v444c7mf9nahlpyrz9skxakp";
          url = "mirror://luarocks/lusc_luv-4.0.1-1.rockspec";
        }).outPath;

      meta = {
        description = "Structured Async/Concurrency for Lua using Luv";
        longDescription = "Structured Async/Concurrency for Lua using Luv";
        homepage = "https://github.com/svermeulen/lusc_luv";
        license = lib.licenses.mit;
      };
    }
  ) { };

  lush-nvim = callPackage (
    {
      fetchurl,
      fetchFromGitHub,
      buildLuarocksPackage,
      luaAtLeast,
      luaOlder,
    }:
    buildLuarocksPackage {
      pname = "lush.nvim";
      version = "scm-1";

      src = fetchFromGitHub {
        owner = "rktjmp";
        repo = "lush.nvim";
        rev = "9c60ec2279d62487d942ce095e49006af28eed6e";
        hash = "sha256-ZDC2oirfDe/GqNx6+hivvNqdLutAxlBnSk51lf1yKqM=";
      };

      disabled = luaOlder "5.1" || luaAtLeast "5.4";

      knownRockspec =
        (fetchurl {
          sha256 = "0ivir5p3mmv051pyya2hj1yrnflrv8bp38dx033i3kzfbpyg23ca";
          url = "mirror://luarocks/lush.nvim-scm-1.rockspec";
        }).outPath;

      meta = {
        description = "Define Neovim themes as a DSL in lua, with real-time feedback.";

        longDescription = ''
          Lush is a colorscheme creation aid, written in Lua, for Neovim.
          	'';

        homepage = "https://github.com/rktjmp/lush.nvim";

        license = lib.licenses.AND [
          lib.licenses.mit
          lib.licenses.x11
        ];

        maintainers = with lib.maintainers; [ teto ];
      };
    }
  ) { };

  luuid = callPackage (
    {
      fetchurl,
      buildLuarocksPackage,
      luaAtLeast,
      luaOlder,
    }:
    buildLuarocksPackage {
      pname = "luuid";
      version = "20120509-2";

      src = fetchurl {
        url = "http://www.tecgraf.puc-rio.br/~lhf/ftp/lua/5.2/luuid.tar.gz";
        sha256 = "1bfkj613d05yps3fivmz0j1bxf2zkg9g1yl0ifffgw0vy00hpnvm";
      };

      disabled = luaOlder "5.2" || luaAtLeast "5.4";

      knownRockspec =
        (fetchurl {
          sha256 = "1q2fv25wfbiqn49mqv26gs4pyllch311akcf7jjn27l5ik8ji5b6";
          url = "mirror://luarocks/luuid-20120509-2.rockspec";
        }).outPath;

      meta = {
        description = "A library for UUID generation";

        longDescription = ''
          A library for generating universally unique identifiers based on
                libuuid, which is part of e2fsprogs.
        '';

        homepage = "http://www.tecgraf.puc-rio.br/~lhf/ftp/lua/#luuid";
        license = lib.licenses.publicDomain;
      };
    }
  ) { };

  lyaml = callPackage (
    {
      fetchurl,
      buildLuarocksPackage,
      fetchzip,
      luaAtLeast,
      luaOlder,
    }:
    buildLuarocksPackage {
      pname = "lyaml";
      version = "6.2.8-1";

      src = fetchzip {
        url = "http://github.com/gvvaughan/lyaml/archive/v6.2.8.zip";
        sha256 = "0r3jjsd8x2fs1aanki0s1mvpznl16f32c1qfgmicy0icgy5xfch0";
      };

      disabled = luaOlder "5.1" || luaAtLeast "5.5";

      knownRockspec =
        (fetchurl {
          sha256 = "0d0h70kjl5fkq589y1sx8qy8as002dhcf88pf60pghvch002ryi1";
          url = "mirror://luarocks/lyaml-6.2.8-1.rockspec";
        }).outPath;

      meta = {
        description = "libYAML binding for Lua";
        longDescription = "Read and write YAML format files with Lua.";
        homepage = "http://github.com/gvvaughan/lyaml";

        license = lib.licenses.AND [
          lib.licenses.mit
          lib.licenses.x11
        ];

        maintainers = with lib.maintainers; [ lblasc ];
      };
    }
  ) { };

  lz-n = callPackage (
    {
      fetchurl,
      buildLuarocksPackage,
      fetchzip,
      luaOlder,
    }:
    buildLuarocksPackage {
      pname = "lz.n";
      version = "2.11.3-1";

      src = fetchzip {
        url = "https://github.com/nvim-neorocks/lz.n/archive/v2.11.3.zip";
        sha256 = "0vnr1iiq4z3q7s3qylfmvcclmspydg8ll4p75jilcx9d114v7wwc";
      };

      disabled = luaOlder "5.1";

      knownRockspec =
        (fetchurl {
          sha256 = "0fg256gwa7444fh7wivasi77x7qgxx4r3hjqw90qa1kav10np88n";
          url = "mirror://luarocks/lz.n-2.11.3-1.rockspec";
        }).outPath;

      meta = {
        description = "🦥 A dead simple lazy-loading Lua library for Neovim plugins.";

        longDescription = ''
          It is intended to be used
          - by users or plugin managers that don't provide a convenient API for lazy-loading.
          - by plugin managers, to provide a convenient API for lazy-loading.'';

        homepage = "https://github.com/nvim-neorocks/lz.n";
        license = lib.licenses.gpl2Plus;
        maintainers = with lib.maintainers; [ mrcjkb ];
      };
    }
  ) { };

  lze = callPackage (
    {
      fetchurl,
      buildLuarocksPackage,
      fetchzip,
      luaOlder,
    }:
    buildLuarocksPackage {
      pname = "lze";
      version = "0.13.0-1";

      src = fetchzip {
        url = "https://github.com/BirdeeHub/lze/archive/v0.13.0.zip";
        sha256 = "012ay0kcbwz3wyh9nqhnb2rnadnz7bxkbi47zbzvfnshz6m7z3z6";
      };

      disabled = luaOlder "5.1";

      knownRockspec =
        (fetchurl {
          sha256 = "03l1855f97xm7hwjqrwwy85zyfjk9rgpmbm9v2lx7npbi118xmgp";
          url = "mirror://luarocks/lze-0.13.0-1.rockspec";
        }).outPath;

      meta = {
        description = "A lazy-loading library for neovim, inspired by, but different from, nvim-neorocks/lz.n";

        longDescription = ''
          It is intended to be used
          - by users of plugin managers that don't provide a convenient API for lazy-loading.
          - by plugin managers, to provide a convenient API for lazy-loading.'';

        homepage = "https://github.com/BirdeeHub/lze";
        license = lib.licenses.gpl2Plus;
        maintainers = with lib.maintainers; [ birdee ];
      };
    }
  ) { };

  lzextras = callPackage (
    {
      fetchurl,
      buildLuarocksPackage,
      fetchzip,
      luaOlder,
    }:
    buildLuarocksPackage {
      pname = "lzextras";
      version = "0.7.3-1";

      src = fetchzip {
        url = "https://github.com/BirdeeHub/lzextras/archive/v0.7.3.zip";
        sha256 = "0rkspxm6gdxvr7agk8yyfdp8qhj4s3c9k3qaqyy2p9c31gzhsql5";
      };

      disabled = luaOlder "5.1";

      knownRockspec =
        (fetchurl {
          sha256 = "03zz29rbbdrk518hflmmjb7sz7nczy11h3fs88v1cng08w4qfgd4";
          url = "mirror://luarocks/lzextras-0.7.3-1.rockspec";
        }).outPath;

      meta = {
        description = "A collection of utilities and handlers for BirdeeHub/lze";
        longDescription = "A collection of extensions for BirdeeHub/lze";
        homepage = "https://github.com/BirdeeHub/lzextras";
        license = lib.licenses.gpl2Plus;
        maintainers = with lib.maintainers; [ birdee ];
      };
    }
  ) { };

  lzn-auto-require = callPackage (
    {
      fetchurl,
      buildLuarocksPackage,
      fetchzip,
      luaOlder,
      lz-n,
    }:
    buildLuarocksPackage {
      pname = "lzn-auto-require";
      version = "0.2.0-1";

      src = fetchzip {
        url = "https://github.com/horriblename/lzn-auto-require/archive/v0.2.0.zip";
        sha256 = "1mgka1mmvpd2gfya898qdbbwrp5rpqds8manjs1s7g5x63xp6b98";
      };

      propagatedBuildInputs = [ lz-n ];
      disabled = luaOlder "5.1";

      knownRockspec =
        (fetchurl {
          sha256 = "02w8pvyhnlbsz56rhgjql13qkh7fk05ai1qkqvk90a8ni8w48hh3";
          url = "mirror://luarocks/lzn-auto-require-0.2.0-1.rockspec";
        }).outPath;

      meta = {
        description = "Auto load optional plugins via lua modules with lz.n";
        homepage = "https://github.com/horriblename/lzn-auto-require";
        license = lib.licenses.gpl2Only;
        maintainers = with lib.maintainers; [ mrcjkb ];
      };
    }
  ) { };

  magick = callPackage (
    {
      fetchurl,
      fetchFromGitHub,
      buildLuarocksPackage,
      lua,
    }:
    buildLuarocksPackage {
      pname = "magick";
      version = "1.6.0-1";

      src = fetchFromGitHub {
        owner = "leafo";
        repo = "magick";
        tag = "v1.6.0";
        hash = "sha256-gda+vLrWyMQ553jVCIRl1qYTS/rXsGhxrBsrJyI8EN4=";
      };

      disabled = lua.luaversion != "5.1";

      knownRockspec =
        (fetchurl {
          sha256 = "1pg150xsxnqvlhxpiy17s9hm4dkc84v46mlwi9rhriynqz8qks9w";
          url = "mirror://luarocks/magick-1.6.0-1.rockspec";
        }).outPath;

      meta = {
        description = "Lua bindings to ImageMagick & GraphicsMagick for LuaJIT using FFI";
        homepage = "https://github.com/leafo/magick.git";
        license = lib.licenses.mit;
        maintainers = with lib.maintainers; [ donovanglover ];
      };
    }
  ) { };

  markdown = callPackage (
    {
      fetchurl,
      fetchFromGitHub,
      buildLuarocksPackage,
      luaAtLeast,
      luaOlder,
    }:
    buildLuarocksPackage {
      pname = "markdown";
      version = "0.33-1";

      src = fetchFromGitHub {
        owner = "mpeterv";
        repo = "markdown";
        tag = "0.33";
        hash = "sha256-PgRGiSwDODSyNSgeN7kNOCZwjLbGf1Qts/jrfLGYKwU=";
      };

      disabled = luaOlder "5.1" || luaAtLeast "5.4";

      knownRockspec =
        (fetchurl {
          sha256 = "02sixijfi6av8h59kx3ngrhygjn2sx1c85c0qfy20gxiz72wi1pl";
          url = "mirror://luarocks/markdown-0.33-1.rockspec";
        }).outPath;

      meta = {
        description = "Markdown text-to-html markup system.";
        longDescription = "A pure-lua implementation of the Markdown text-to-html markup system.";
        homepage = "https://github.com/mpeterv/markdown";

        license = lib.licenses.AND [
          lib.licenses.mit
          lib.licenses.x11
        ];
      };
    }
  ) { };

  md5 = callPackage (
    {
      fetchurl,
      buildLuarocksPackage,
      luaOlder,
    }:
    buildLuarocksPackage {
      pname = "md5";
      version = "1.3-1";

      src = fetchurl {
        url = "https://github.com/keplerproject/md5/archive/1.3.tar.gz";
        sha256 = "193dsjgnzrnykpmx68njkv72fxh2gb3llqgx2lgbgnf5i66shiq7";
      };

      disabled = luaOlder "5.0";

      knownRockspec =
        (fetchurl {
          sha256 = "08kx00ik1hly4p1a1bvvw3bvbddc64vdhpr21jy3asrj9nz86bnr";
          url = "mirror://luarocks/md5-1.3-1.rockspec";
        }).outPath;

      meta = {
        description = "Checksum library";
        longDescription = "MD5 offers checksum facilities for Lua 5.X: a hash (digest) function, a pair crypt/decrypt based on MD5 and CFB, and a pair crypt/decrypt based on DES with 56-bit keys.";
        homepage = "http://keplerproject.github.io/md5/";

        license = lib.licenses.AND [
          lib.licenses.mit
          lib.licenses.x11
        ];
      };
    }
  ) { };

  mediator_lua = callPackage (
    {
      fetchurl,
      buildLuarocksPackage,
      luaOlder,
    }:
    buildLuarocksPackage {
      pname = "mediator_lua";
      version = "1.1.2-0";

      src = fetchurl {
        url = "https://github.com/Olivine-Labs/mediator_lua/archive/v1.1.2-0.tar.gz";
        sha256 = "16zzzhiy3y35v8advmlkzpryzxv5vji7727vwkly86q8sagqbxgs";
      };

      disabled = luaOlder "5.1";

      knownRockspec =
        (fetchurl {
          sha256 = "0frzvf7i256260a1s8xh92crwa2m42972qxfq29zl05aw3pyn7bm";
          url = "mirror://luarocks/mediator_lua-1.1.2-0.rockspec";
        }).outPath;

      meta = {
        description = "Event handling through channels";

        longDescription = ''
          mediator_lua allows you to subscribe and publish to a central object so
              you can decouple function calls in your application. It's as simple as
              mediator:subscribe("channel", function). Supports namespacing, predicates,
              and more.
        '';

        homepage = "http://olivinelabs.com/mediator_lua/";
        license = lib.licenses.mit;
      };
    }
  ) { };

  mega-cmdparse = callPackage (
    {
      fetchurl,
      buildLuarocksPackage,
      fetchzip,
      mega-logging,
    }:
    buildLuarocksPackage {
      pname = "mega.cmdparse";
      version = "1.2.1-1";

      src = fetchzip {
        url = "https://github.com/ColinKennedy/mega.cmdparse/archive/v1.2.1.zip";
        sha256 = "1bf3rf80m65jc51dlv3vcs2jhzk5ni2kr7v5rsmb31k7wk3002qb";
      };

      propagatedBuildInputs = [ mega-logging ];

      knownRockspec =
        (fetchurl {
          sha256 = "1766pqazkr3zfwaaj541m53y90n5zr0r7068hd67d9hgvd7za6sb";
          url = "mirror://luarocks/mega.cmdparse-1.2.1-1.rockspec";
        }).outPath;

      meta = {
        description = "A Neovim command-mode parser. Similar to Python's argparse module";
        homepage = "https://github.com/ColinKennedy/mega.cmdparse";
        license = lib.licenses.mit;
      };
    }
  ) { };

  mega-logging = callPackage (
    {
      fetchurl,
      buildLuarocksPackage,
      fetchzip,
    }:
    buildLuarocksPackage {
      pname = "mega.logging";
      version = "1.1.6-1";

      src = fetchzip {
        url = "https://github.com/ColinKennedy/mega.logging/archive/v1.1.6.zip";
        sha256 = "0sy7f42rbdanz9bi0kq6vzllykqcrp04bp7b5k3cqpml5ckywpl5";
      };

      knownRockspec =
        (fetchurl {
          sha256 = "1va6vl4iqnc3ip2ws1ff65xavw1m6wgdrsal1gvqnjn0gh20vxbg";
          url = "mirror://luarocks/mega.logging-1.1.6-1.rockspec";
        }).outPath;

      meta = {
        description = "A Neovim plugin for logging to Neovim or to disk";
        homepage = "https://github.com/ColinKennedy/mega.logging";
        license = lib.licenses.mit;
      };
    }
  ) { };

  middleclass = callPackage (
    {
      fetchurl,
      buildLuarocksPackage,
      luaOlder,
    }:
    buildLuarocksPackage {
      pname = "middleclass";
      version = "4.1.1-0";

      src = fetchurl {
        url = "https://github.com/kikito/middleclass/archive/v4.1.1.tar.gz";
        sha256 = "11ahv0b9wgqfnabv57rb7ilsvn2vcvxb1czq6faqrsqylvr5l7nh";
      };

      disabled = luaOlder "5.1";

      knownRockspec =
        (fetchurl {
          sha256 = "10xzs48lr1dy7cx99581r956gl16px0a9gbdlfar41n19r96mhb1";
          url = "mirror://luarocks/middleclass-4.1.1-0.rockspec";
        }).outPath;

      meta = {
        description = "A simple OOP library for Lua";
        longDescription = "It has inheritance, metamethods (operators), class variables and weak mixin support";
        homepage = "https://github.com/kikito/middleclass";
        license = lib.licenses.mit;
      };
    }
  ) { };

  mimetypes = callPackage (
    {
      fetchurl,
      fetchFromGitHub,
      buildLuarocksPackage,
      luaOlder,
    }:
    buildLuarocksPackage {
      pname = "mimetypes";
      version = "1.1.0-2";

      src = fetchFromGitHub {
        owner = "lunarmodules";
        repo = "lua-mimetypes";
        tag = "v1.1.0";
        hash = "sha256-9uuhMerMqE/AtFFGNIWxGBN0BQ+FE+NgZa3g041lesE=";
      };

      disabled = luaOlder "5.1";

      knownRockspec =
        (fetchurl {
          sha256 = "1asi5dlkqml9rjh2k2iq0fy2khdlc7mq4kxp4j42c8507w9dijww";
          url = "mirror://luarocks/mimetypes-1.1.0-2.rockspec";
        }).outPath;

      meta = {
        description = "A simple library for looking up the MIME types of files.";

        longDescription = ''
          This is a simple library for guessing a file's MIME type. It includes
              a (hopefully) comprehensive database of MIME types, but it allows you
              to create your own should you have specific requirements. It can
              guess types both by extension and by the complete filename.
        '';

        homepage = "https://github.com/lunarmodules/lua-mimetypes";

        license = lib.licenses.AND [
          lib.licenses.mit
          lib.licenses.x11
        ];
      };
    }
  ) { };

  mini-test = callPackage (
    {
      fetchurl,
      buildLuarocksPackage,
      fetchzip,
      luaOlder,
    }:
    buildLuarocksPackage {
      pname = "mini.test";
      version = "0.18.0-1";

      src = fetchzip {
        url = "https://github.com/nvim-mini/mini.test/archive/v0.18.0.zip";
        sha256 = "1q1qy3f0mxrqx96gq4q3h4w2qip40lqkyd9vs65zc76wj9wx37hw";
      };

      disabled = luaOlder "5.1";

      knownRockspec =
        (fetchurl {
          sha256 = "0k0pdp5qalfhcmdaqi0mz3s0p7rwq88bjcs6b7s5z80rqrhji67k";
          url = "mirror://luarocks/mini.test-0.18.0-1.rockspec";
        }).outPath;

      meta = {
        description = "Test neovim plugins. Part of the mini.nvim suite.";
        homepage = "https://github.com/nvim-mini/mini.test";
        license = lib.licenses.mit;
      };
    }
  ) { };

  moonscript = callPackage (
    {
      fetchFromGitHub,
      argparse,
      buildLuarocksPackage,
      lpeg,
      luaOlder,
      luafilesystem,
    }:
    buildLuarocksPackage {
      pname = "moonscript";
      version = "dev-1";

      src = fetchFromGitHub {
        owner = "leafo";
        repo = "moonscript";
        rev = "402be8a6df8ff57c4183db44e0c130d14d69bf87";
        hash = "sha256-rIkq6rk5A9yYbRcFLJ9wE+PQKGvpOB+7iTDbq9T/1OM=";
      };

      propagatedBuildInputs = [
        argparse
        lpeg
        luafilesystem
      ];

      disabled = luaOlder "5.1";

      meta = {
        description = "A programmer friendly language that compiles to Lua";
        longDescription = "A programmer friendly language that compiles to Lua";
        homepage = "http://moonscript.org";
        license = lib.licenses.mit;
        maintainers = with lib.maintainers; [ arobyn ];
      };
    }
  ) { };

  mpack = callPackage (
    { fetchurl, buildLuarocksPackage }:
    buildLuarocksPackage {
      pname = "mpack";
      version = "1.0.13-0";

      src = fetchurl {
        url = "https://github.com/libmpack/libmpack-lua/releases/download/1.0.13/libmpack-lua-1.0.13.tar.gz";
        sha256 = "1mwk54jnayw5wjclijyha24xq4sj0lyidb04zyndd9i0yr4anlnx";
      };

      knownRockspec =
        (fetchurl {
          sha256 = "1lyjbmyj6yfv0bhyj50rpz2qm993zsbyw494j9kz4bcvxx0gqac5";
          url = "mirror://luarocks/mpack-1.0.13-0.rockspec";
        }).outPath;

      meta = {
        description = "Lua binding to libmpack";
        homepage = "https://github.com/libmpack/libmpack-lua";
        license = lib.licenses.mit;
      };
    }
  ) { };

  neorg = callPackage (
    {
      fetchurl,
      buildLuarocksPackage,
      fetchzip,
      lua-utils-nvim,
      luaOlder,
      nui-nvim,
      nvim-nio,
      pathlib-nvim,
      tree-sitter-norg,
      tree-sitter-norg-meta,
    }:
    buildLuarocksPackage {
      pname = "neorg";
      version = "9.6.4-1";

      src = fetchzip {
        url = "https://github.com/nvim-neorg/neorg/archive/1f14d72aad7165eac307a2a2f6be0fb97a04b3c2.zip";
        sha256 = "0l7hc1w4j00csv8i6dgbdhx0jcf0017b7hhs8gcldvsyka50xkx5";
      };

      propagatedBuildInputs = [
        lua-utils-nvim
        nui-nvim
        nvim-nio
        pathlib-nvim
        tree-sitter-norg
        tree-sitter-norg-meta
      ];

      disabled = luaOlder "5.1";

      knownRockspec =
        (fetchurl {
          sha256 = "11k7qwr7430wk3j5kf7isn3d9i4y0drmq6d0dwdx62s4cy9c3pvm";
          url = "mirror://luarocks/neorg-9.6.4-1.rockspec";
        }).outPath;

      meta = {
        description = "Modernity meets insane extensibility. The future of organizing your life in Neovim.";
        homepage = "https://github.com/nvim-neorg/neorg";
        license = lib.licenses.gpl3Only;
        maintainers = with lib.maintainers; [ GaetanLepage ];
      };
    }
  ) { };

  neorg-interim-ls = callPackage (
    {
      fetchurl,
      buildLuarocksPackage,
      fetchzip,
      luaOlder,
      neorg,
    }:
    buildLuarocksPackage {
      pname = "neorg-interim-ls";
      version = "2.1.4-1";

      src = fetchzip {
        url = "https://github.com/benlubas/neorg-interim-ls/archive/v2.1.4.zip";
        sha256 = "0fpzfjpamb4amlnqf89zy9hdg95qh0mzdfrzh7qw13yvh4273z27";
      };

      propagatedBuildInputs = [ neorg ];
      disabled = luaOlder "5.1";

      knownRockspec =
        (fetchurl {
          sha256 = "16c6b4in826fnv2wgxl1b7qsxvj62qq2xjnbik7z0hiij2vwc52x";
          url = "mirror://luarocks/neorg-interim-ls-2.1.4-1.rockspec";
        }).outPath;

      meta = {
        description = "Temporarily providing a limited set of LSP features to neorg";
        homepage = "https://github.com/benlubas/neorg-interim-ls";
        license = lib.licenses.mit;
      };
    }
  ) { };

  neotest = callPackage (
    {
      fetchurl,
      buildLuarocksPackage,
      fetchzip,
      luaOlder,
      nvim-nio,
    }:
    buildLuarocksPackage {
      pname = "neotest";
      version = "5.19.0-1";

      src = fetchzip {
        url = "https://github.com/nvim-neotest/neotest/archive/e37147bca240d5b790bb61dc7d13cea214897079.zip";
        sha256 = "1pbk3x8yi5hvb275gzz0c8gjykzpam1pcxxlb2l6qr1pzz0kvj7r";
      };

      propagatedBuildInputs = [ nvim-nio ];
      disabled = luaOlder "5.1";

      knownRockspec =
        (fetchurl {
          sha256 = "1gfxf6v9q19xfn8kyklg2k4mj2fh4w03vyhq0drcmm4901vcvcz1";
          url = "mirror://luarocks/neotest-5.19.0-1.rockspec";
        }).outPath;

      meta = {
        description = "An extensible framework for interacting with tests within NeoVim.";
        homepage = "https://github.com/nvim-neotest/neotest";
        license = lib.licenses.mit;
        maintainers = with lib.maintainers; [ mrcjkb ];
      };
    }
  ) { };

  neotest-nix = callPackage (
    {
      fetchurl,
      buildLuarocksPackage,
      fetchzip,
      luaOlder,
      neotest,
      nvim-nio,
    }:
    buildLuarocksPackage {
      pname = "neotest-nix";
      version = "2.3.0-1";

      src = fetchzip {
        url = "https://github.com/khaneliman/neotest-nix/archive/b61774dcb3e0d93af07c55de608775b8eb013fc7.zip";
        sha256 = "1ynq7ywqn9l8dyzf4nzjvywrirjg6nrkijrv1mhasa7cikar567v";
      };

      propagatedBuildInputs = [
        neotest
        nvim-nio
      ];

      disabled = luaOlder "5.1";

      knownRockspec =
        (fetchurl {
          sha256 = "0p5vc6nblxc5vqpxwr5a2fy8l14gdbqhvkkdx1zbkba01qph7rll";
          url = "mirror://luarocks/neotest-nix-2.3.0-1.rockspec";
        }).outPath;

      meta = {
        description = "A Neotest adapter for Nix tests.";
        homepage = "https://github.com/khaneliman/neotest-nix";
        license = lib.licenses.mit;
        maintainers = with lib.maintainers; [ khaneliman ];
      };
    }
  ) { };

  nginx-lua-prometheus = callPackage (
    {
      fetchurl,
      fetchFromGitHub,
      buildLuarocksPackage,
      luaOlder,
    }:
    buildLuarocksPackage {
      pname = "nginx-lua-prometheus";
      version = "0.20240525-1";

      src = fetchFromGitHub {
        owner = "knyar";
        repo = "nginx-lua-prometheus";
        tag = "0.20240525";
        hash = "sha256-ovLpOQKgTfrrgCxCF/OtdPUuAQ9J4RtT9F68Bbzu1XQ=";
      };

      disabled = luaOlder "5.1";

      knownRockspec =
        (fetchurl {
          sha256 = "0xw21h7bl7l8kijbmw98v0lc7910r5pwnx7h3w894dv63d413ixr";
          url = "mirror://luarocks/nginx-lua-prometheus-0.20240525-1.rockspec";
        }).outPath;

      meta = {
        description = "Prometheus metric library for Nginx";
        homepage = "https://github.com/knyar/nginx-lua-prometheus";
        license = lib.licenses.mit;
        maintainers = with lib.maintainers; [ ulysseszhan ];
      };
    }
  ) { };

  nlua = callPackage (
    {
      fetchurl,
      buildLuarocksPackage,
      fetchzip,
      luaOlder,
    }:
    buildLuarocksPackage {
      pname = "nlua";
      version = "0.3.1-1";

      src = fetchzip {
        url = "https://github.com/mfussenegger/nlua/archive/v0.3.1.zip";
        sha256 = "1m19ap9ipcdj16rbllxiqlww8hz98l63cdb8mhll37756nr773hn";
      };

      disabled = luaOlder "5.1";

      knownRockspec =
        (fetchurl {
          sha256 = "1238vnwk14pdcq533a8ndmmkc0b9ndc4kh0aja7ypmsjvk2y5v3s";
          url = "mirror://luarocks/nlua-0.3.1-1.rockspec";
        }).outPath;

      meta = {
        description = "Neovim as Lua interpreter";

        longDescription = ''
          Neovim embeds a Lua interpreter, but it doesn't expose the same command line interface as plain lua.
              nlua is a script which emulates Lua's command line interface, using Neovim's -l option under the hood.
        '';

        homepage = "https://github.com/mfussenegger/nlua";
        license = lib.licenses.gpl3Only;
        maintainers = with lib.maintainers; [ teto ];
      };
    }
  ) { };

  nui-nvim = callPackage (
    {
      fetchurl,
      fetchFromGitHub,
      buildLuarocksPackage,
    }:
    buildLuarocksPackage {
      pname = "nui.nvim";
      version = "0.4.0-1";

      src = fetchFromGitHub {
        owner = "MunifTanjim";
        repo = "nui.nvim";
        tag = "0.4.0";
        hash = "sha256-SJc9nfV6cnBKYwRWsv0iHy+RbET8frNV85reICf+pt8=";
      };

      knownRockspec =
        (fetchurl {
          sha256 = "0bs87acbr7ih5ln9c5a394fsmg32afw9g3w5l9ji5hmxfbvj6prf";
          url = "mirror://luarocks/nui.nvim-0.4.0-1.rockspec";
        }).outPath;

      meta = {
        description = "UI Component Library for Neovim.";

        longDescription = ''
          UI Component Library for Neovim.
        '';

        homepage = "https://github.com/MunifTanjim/nui.nvim";
        license = lib.licenses.mit;
        maintainers = with lib.maintainers; [ mrcjkb ];
      };
    }
  ) { };

  nvim-cmp = callPackage (
    {
      fetchFromGitHub,
      buildLuarocksPackage,
      luaAtLeast,
      luaOlder,
    }:
    buildLuarocksPackage {
      pname = "nvim-cmp";
      version = "scm-1";

      src = fetchFromGitHub {
        owner = "hrsh7th";
        repo = "nvim-cmp";
        rev = "2ffe79f1f021def8dd1fcd81deb16f1bb0d989f3";
        hash = "sha256-YN8KAXVv1AFc3DajWVIl+EppOx/s3vdxiKMlb/lj5qc=";
      };

      disabled = luaOlder "5.1" || luaAtLeast "5.4";

      meta = {
        description = "A completion plugin for neovim";

        longDescription = ''
          A completion engine plugin for neovim written in Lua. Completion sources are installed from external repositories and "sourced".
        '';

        homepage = "https://github.com/hrsh7th/nvim-cmp";
        license = lib.licenses.mit;
      };
    }
  ) { };

  nvim-nio = callPackage (
    {
      fetchurl,
      buildLuarocksPackage,
      fetchzip,
      luaOlder,
    }:
    buildLuarocksPackage {
      pname = "nvim-nio";
      version = "1.10.1-1";

      src = fetchzip {
        url = "https://github.com/nvim-neotest/nvim-nio/archive/21f5324bfac14e22ba26553caf69ec76ae8a7662.zip";
        sha256 = "1bz5msxwk232zkkhfxcmr7a665la8pgkdx70q99ihl4x04jg6dkq";
      };

      disabled = luaOlder "5.1";

      knownRockspec =
        (fetchurl {
          sha256 = "1bkxvhk5bml6q5g4ycv3ggrqd24kkhhswa6if5g2q6j1j44lxgj0";
          url = "mirror://luarocks/nvim-nio-1.10.1-1.rockspec";
        }).outPath;

      meta = {
        description = "A library for asynchronous IO in Neovim";
        homepage = "https://github.com/nvim-neotest/nvim-nio";
        license = lib.licenses.mit;
        maintainers = with lib.maintainers; [ mrcjkb ];
      };
    }
  ) { };

  nvim-web-devicons = callPackage (
    {
      fetchurl,
      buildLuarocksPackage,
      fetchzip,
      luaOlder,
    }:
    buildLuarocksPackage {
      pname = "nvim-web-devicons";
      version = "0.100-1";

      src = fetchzip {
        url = "https://github.com/nvim-tree/nvim-web-devicons/archive/v0.100.zip";
        sha256 = "0d7gzk06f6z9wq496frbaavx90mcxvdhrswqd3pcayj2872i698d";
      };

      disabled = luaOlder "5.1";

      knownRockspec =
        (fetchurl {
          sha256 = "0i87kr2q1s97q4kw85k36xhryigbv4bgy3ig56qg6z5jgkxgldza";
          url = "mirror://luarocks/nvim-web-devicons-0.100-1.rockspec";
        }).outPath;

      meta = {
        description = "Nerd Font icons for neovim";

        longDescription = ''
          Coloured Nerd Font file icons for neovim.
          Dark and light background variants.
          https://www.nerdfonts.com/'';

        homepage = "https://github.com/nvim-tree/nvim-web-devicons";
        license = lib.licenses.mit;
      };
    }
  ) { };

  oil-nvim = callPackage (
    {
      fetchurl,
      buildLuarocksPackage,
      fetchzip,
      luaOlder,
    }:
    buildLuarocksPackage {
      pname = "oil.nvim";
      version = "2.16.0-1";

      src = fetchzip {
        url = "https://github.com/stevearc/oil.nvim/archive/v2.16.0.zip";
        sha256 = "0pipdvaxrkdyfbp66sgrc3ppy260m95am9zhi3m8n7lm1ivp6fzb";
      };

      disabled = luaOlder "5.1";

      knownRockspec =
        (fetchurl {
          sha256 = "0gsdvzysvvb72z2bd5vcxpssgnb0q91y2z5nrzzafq7670xz49dp";
          url = "mirror://luarocks/oil.nvim-2.16.0-1.rockspec";
        }).outPath;

      meta = {
        description = "Neovim file explorer: edit your filesystem like a buffer";
        homepage = "https://github.com/stevearc/oil.nvim";
        license = lib.licenses.mit;
      };
    }
  ) { };

  orgmode = callPackage (
    {
      fetchurl,
      buildLuarocksPackage,
      fetchzip,
      luaOlder,
      tree-sitter-orgmode,
    }:
    buildLuarocksPackage {
      pname = "orgmode";
      version = "0.7.5-1";

      src = fetchzip {
        url = "https://github.com/nvim-orgmode/orgmode/archive/0.7.5.zip";
        sha256 = "00x1spp077bgm180pr0pnwa6hk34isjizf2zxcmlaq06rk548i7i";
      };

      propagatedBuildInputs = [ tree-sitter-orgmode ];
      disabled = luaOlder "5.1";

      knownRockspec =
        (fetchurl {
          sha256 = "03spnsdpl34qkh14gniac15k4rncai2239wnv90p7z9wvkr2y0s1";
          url = "mirror://luarocks/orgmode-0.7.5-1.rockspec";
        }).outPath;

      meta = {
        description = "Orgmode clone written in Lua for Neovim 0.11.0+.";
        homepage = "https://nvim-orgmode.github.io";
        license = lib.licenses.mit;
      };
    }
  ) { };

  papis-nvim = callPackage (
    {
      fetchurl,
      buildLuarocksPackage,
      fetchzip,
      luaOlder,
      nui-nvim,
      sqlite,
    }:
    buildLuarocksPackage {
      pname = "papis.nvim";
      version = "0.9.1-1";

      src = fetchzip {
        url = "https://github.com/jghauser/papis.nvim/archive/v0.9.1.zip";
        sha256 = "1hicipx893p8y8sapn0kyqjinn8nhrrkc0a1cwl16z0mmh0jgk81";
      };

      propagatedBuildInputs = [
        nui-nvim
        sqlite
      ];

      disabled = luaOlder "5.1";

      knownRockspec =
        (fetchurl {
          sha256 = "1ykcnzz2rpcn3v5aw4lhwc2vcc9gzrskkzir136i1szgnvrhhzg0";
          url = "mirror://luarocks/papis.nvim-0.9.1-1.rockspec";
        }).outPath;

      meta = {
        description = "Manage your bibliography from within your favourite editor";

        longDescription = ''
          Papis.nvim is a neovim companion plugin for the bibliography manager papis. 
          It's meant for all those who do academic and other writing in neovim and who 
          want quick access to their bibliography from within the comfort of their editor.'';

        homepage = "https://github.com/jghauser/papis.nvim";
        license = lib.licenses.gpl3Only;
        maintainers = with lib.maintainers; [ GaetanLepage ];
      };
    }
  ) { };

  pathlib-nvim = callPackage (
    {
      fetchurl,
      buildLuarocksPackage,
      fetchzip,
      luaOlder,
      nvim-nio,
    }:
    buildLuarocksPackage {
      pname = "pathlib.nvim";
      version = "2.2.3-1";

      src = fetchzip {
        url = "https://github.com/pysan3/pathlib.nvim/archive/v2.2.3.zip";
        sha256 = "1z3nwy83r3zbll9wc2wyvg60z0dqc5hm2xdfvqh3hwm5s9w8j432";
      };

      propagatedBuildInputs = [ nvim-nio ];
      disabled = luaOlder "5.1";

      knownRockspec =
        (fetchurl {
          sha256 = "0qwsjcsl6760d8d5k1lxlykh78g6v7xcr9caq3yh75yn76mwrl4i";
          url = "mirror://luarocks/pathlib.nvim-2.2.3-1.rockspec";
        }).outPath;

      meta = {
        description = "OS Independent, ultimate solution to path handling in neovim.";

        longDescription = ''
          This plugin aims to decrease the difficulties of path management across mutliple OSs in neovim.
          The plugin API is heavily inspired by Python's `pathlib.Path` with tweaks to fit neovim usage.'';

        homepage = "https://pysan3.github.io/pathlib.nvim/";
        license = lib.licenses.mpl20;
      };
    }
  ) { };

  penlight = callPackage (
    {
      fetchurl,
      fetchFromGitHub,
      buildLuarocksPackage,
      luafilesystem,
    }:
    buildLuarocksPackage {
      pname = "penlight";
      version = "1.15.0-1";

      src = fetchFromGitHub {
        owner = "lunarmodules";
        repo = "penlight";
        tag = "1.15.0";
        hash = "sha256-yEkzr4v8avygFxp+NUvffg2fRxQJWTpRdIvluh/QBpY=";
      };

      propagatedBuildInputs = [ luafilesystem ];

      knownRockspec =
        (fetchurl {
          sha256 = "0m4m20vpvzkr2h9xs8q2a3wkib0jxzbkwb8hy6abxyvkm6r7fnvf";
          url = "mirror://luarocks/penlight-1.15.0-1.rockspec";
        }).outPath;

      meta = {
        description = "Lua utility libraries loosely based on the Python standard libraries";

        longDescription = ''
          Penlight is a set of pure Lua libraries for making it easier to work with common tasks like
          iterating over directories, reading configuration files and the like. Provides functional operations
          on tables and sequences.
        '';

        homepage = "https://lunarmodules.github.io/penlight";

        license = lib.licenses.AND [
          lib.licenses.mit
          lib.licenses.x11
        ];

        maintainers = with lib.maintainers; [ alerque ];
      };
    }
  ) { };

  plenary-nvim = callPackage (
    {
      fetchFromGitHub,
      buildLuarocksPackage,
      luaAtLeast,
      luaOlder,
      luassert,
    }:
    buildLuarocksPackage {
      pname = "plenary.nvim";
      version = "scm-1";

      src = fetchFromGitHub {
        owner = "nvim-lua";
        repo = "plenary.nvim";
        rev = "74b06c6c75e4eeb3108ec01852001636d85a932b";
        hash = "sha256-nkfETDkPiE+Kd2BWYZijgUp9bP8RgFwRmvqJz2BMuq4=";
      };

      propagatedBuildInputs = [ luassert ];
      disabled = luaOlder "5.1" || luaAtLeast "5.4";

      meta = {
        description = "lua functions you don't want to write ";

        longDescription = ''
          plenary: full; complete; entire; absolute; unqualified. All the lua functions I don't want to write twice.
        '';

        homepage = "http://github.com/nvim-lua/plenary.nvim";

        license = lib.licenses.AND [
          lib.licenses.mit
          lib.licenses.x11
        ];
      };
    }
  ) { };

  psl = callPackage (
    {
      fetchurl,
      buildLuarocksPackage,
      fetchzip,
    }:
    buildLuarocksPackage {
      pname = "psl";
      version = "0.3-0";

      src = fetchzip {
        url = "https://github.com/daurnimator/lua-psl/archive/v0.3.zip";
        sha256 = "1x9zskjn6fp9343w9314104128ik4lbk98pg6zfhl1v35107m1jx";
      };

      knownRockspec =
        (fetchurl {
          sha256 = "1x7sc8n780k67v31bvqqxhh6ihy0k91zmp6xcxmkifr0gd008x9z";
          url = "mirror://luarocks/psl-0.3-0.rockspec";
        }).outPath;

      meta = {
        description = "Bindings to libpsl, a C library that handles the Public Suffix List (PSL)";

        longDescription = ''
          Bindings to libpsl, a C library that handles the Public Suffix List (PSL).

          The PSL is a list of domains where there may be sub-domains outside of the administrator's control.
          e.g. the administrator of '.com' does not manage 'github.com'.

          This list has found use in many internet technologies including:

            - preventing cross-domain cookie leakage
            - allowance of issuing wildcard TLS certificates

          More information can be found at https://publicsuffix.org/'';

        homepage = "https://github.com/daurnimator/lua-psl";
        license = lib.licenses.mit;
      };
    }
  ) { };

  rapidjson = callPackage (
    {
      fetchurl,
      fetchFromGitHub,
      buildLuarocksPackage,
      cmake,
      luaOlder,
    }:
    buildLuarocksPackage {
      pname = "rapidjson";
      version = "0.7.2-1";

      src = fetchFromGitHub {
        owner = "xpol";
        repo = "lua-rapidjson";
        tag = "v0.7.2";
        hash = "sha256-WdfGIgbwlMMItsasN+ZITd/iqSeHC0EVeYoUcolb1MU=";
      };

      nativeBuildInputs = [ cmake ];
      disabled = luaOlder "5.1";

      knownRockspec =
        (fetchurl {
          sha256 = "1g3gw1rr54jvylq7afzkqdpid3h7nlmk76hmfva8xzhcdvbcl88h";
          url = "mirror://luarocks/rapidjson-0.7.2-1.rockspec";
        }).outPath;

      meta = {
        description = "Json module based on the very fast RapidJSON.";
        longDescription = "A json module for Lua 5.1/5.2/5.3 and LuaJIT based on the very fast RapidJSON.";
        homepage = "https://github.com/xpol/lua-rapidjson";
        license = lib.licenses.mit;
      };
    }
  ) { };

  rest-nvim = callPackage (
    {
      fetchurl,
      buildLuarocksPackage,
      fetchzip,
      fidget-nvim,
      luaOlder,
      mimetypes,
      nvim-nio,
      tree-sitter-http,
      xml2lua,
    }:
    buildLuarocksPackage {
      pname = "rest.nvim";
      version = "3.13.0-1";

      src = fetchzip {
        url = "https://github.com/rest-nvim/rest.nvim/archive/v3.13.0.zip";
        sha256 = "18mmif73l13hbzhfvnvdky78jlv2j059cqyvxkb6bcqwcyqx7jaj";
      };

      propagatedBuildInputs = [
        fidget-nvim
        mimetypes
        nvim-nio
        tree-sitter-http
        xml2lua
      ];

      disabled = luaOlder "5.1";

      knownRockspec =
        (fetchurl {
          sha256 = "1ig9589pb0y59jvlw97nxgcmij9kcjbc7l1aag99m40v823kncil";
          url = "mirror://luarocks/rest.nvim-3.13.0-1.rockspec";
        }).outPath;

      meta = {
        description = "A very fast, powerful, extensible and asynchronous Neovim HTTP client written in Lua.";

        longDescription = ''
          A very fast, powerful, extensible and asynchronous Neovim HTTP client written in Lua.
          rest.nvim by default makes use of its own `curl` wrapper to make requests and a tree-sitter parser to parse http files.'';

        homepage = "https://github.com/rest-nvim/rest.nvim";
        license = lib.licenses.gpl3Only;
        maintainers = with lib.maintainers; [ teto ];
      };
    }
  ) { };

  rocks-config-nvim = callPackage (
    {
      fetchurl,
      buildLuarocksPackage,
      fetchzip,
      lua,
      rocks-nvim,
    }:
    buildLuarocksPackage {
      pname = "rocks-config.nvim";
      version = "3.2.0-1";

      src = fetchzip {
        url = "https://github.com/lumen-oss/rocks-config.nvim/archive/v3.2.0.zip";
        sha256 = "1w688m50g2q742yq9dp7w6g7rcp71pq6mybz2hw8g9af9q95js81";
      };

      propagatedBuildInputs = [ rocks-nvim ];
      disabled = lua.luaversion != "5.1";

      knownRockspec =
        (fetchurl {
          sha256 = "07sznkw2qkbgibqg4sjpmrirvig17adhww7wmgb2h3kny7vaipxq";
          url = "mirror://luarocks/rocks-config.nvim-3.2.0-1.rockspec";
        }).outPath;

      meta = {
        description = "Allow rocks.nvim to help configure your plugins.";

        longDescription = ''
          rocks-config.nvim is a rocks.nvim utility module for helping to configure
          your Neovim setup.
          Features:
          - Execute a specific Lua file per plugin
          - Automatically invoke the setup() function for every installed plugin
          - Statically configure a plugin using TOML syntax directly from within your rocks.toml'';

        homepage = "https://github.com/lumen-oss/rocks-config.nvim";
        license = lib.licenses.gpl3Only;
        maintainers = with lib.maintainers; [ mrcjkb ];
      };
    }
  ) { };

  rocks-dev-nvim = callPackage (
    {
      fetchurl,
      buildLuarocksPackage,
      fetchzip,
      lua,
      nvim-nio,
      rocks-nvim,
      rtp-nvim,
    }:
    buildLuarocksPackage {
      pname = "rocks-dev.nvim";
      version = "1.8.1-1";

      src = fetchzip {
        url = "https://github.com/nvim-neorocks/rocks-dev.nvim/archive/v1.8.1.zip";
        sha256 = "0zsy4pqh4rnw9awvw9wlq4v2hhksfh716qhh43bhsnr30d0bfi5x";
      };

      propagatedBuildInputs = [
        nvim-nio
        rocks-nvim
        rtp-nvim
      ];

      disabled = lua.luaversion != "5.1";

      knownRockspec =
        (fetchurl {
          sha256 = "1rbyjxla58vy6qsbdgyi5y9rr73nswcshhkl4qmlnq4hg5nz1kkj";
          url = "mirror://luarocks/rocks-dev.nvim-1.8.1-1.rockspec";
        }).outPath;

      meta = {
        description = "A swiss-army knife for testing and developing rocks.nvim modules.";

        longDescription = ''
          rocks-dev.nvim is a rocks.nvim utility module, serving as a swiss army knife
          for developing and testing new rocks.nvim extensions.
          Features:
          - Install plugins from the local filesystem'';

        homepage = "https://github.com/nvim-neorocks/rocks-dev.nvim";
        license = lib.licenses.gpl3Only;
        maintainers = with lib.maintainers; [ mrcjkb ];
      };
    }
  ) { };

  rocks-git-nvim = callPackage (
    {
      fetchurl,
      buildLuarocksPackage,
      fetchzip,
      lua,
      nvim-nio,
      rocks-nvim,
    }:
    buildLuarocksPackage {
      pname = "rocks-git.nvim";
      version = "2.5.10-1";

      src = fetchzip {
        url = "https://github.com/lumen-oss/rocks-git.nvim/archive/v2.5.10.zip";
        sha256 = "1hh0zrpdp4nc19wli6pm8bgjf6qzzjz4ydhshm4m2d22dmnh6ngz";
      };

      propagatedBuildInputs = [
        nvim-nio
        rocks-nvim
      ];

      disabled = lua.luaversion != "5.1";

      knownRockspec =
        (fetchurl {
          sha256 = "0a01xh847gnpy844hdlmn8l6iwqhxj604mirqkhsqhr1l4rv715a";
          url = "mirror://luarocks/rocks-git.nvim-2.5.10-1.rockspec";
        }).outPath;

      meta = {
        description = "Use rocks.nvim to install plugins from git!";
        homepage = "https://github.com/lumen-oss/rocks-git.nvim";
        license = lib.licenses.gpl3Only;
        maintainers = with lib.maintainers; [ mrcjkb ];
      };
    }
  ) { };

  rocks-nvim = callPackage (
    {
      fetchurl,
      buildLuarocksPackage,
      fetchzip,
      fidget-nvim,
      fzy,
      lua,
      luarocks,
      nvim-nio,
      rtp-nvim,
      toml-edit,
    }:
    buildLuarocksPackage {
      pname = "rocks.nvim";
      version = "2.49.0-1";

      src = fetchzip {
        url = "https://github.com/lumen-oss/rocks.nvim/archive/v2.49.0.zip";
        sha256 = "13sr1alra4dlh22p6b53y6695zdv4vih3gdkvjfd7q3057ni7l20";
      };

      propagatedBuildInputs = [
        fidget-nvim
        fzy
        luarocks
        nvim-nio
        rtp-nvim
        toml-edit
      ];

      disabled = lua.luaversion != "5.1";

      knownRockspec =
        (fetchurl {
          sha256 = "1krbnmx90avna2bzxvdv5zs7iakgkcm9w0dniingbhifkrkmiazr";
          url = "mirror://luarocks/rocks.nvim-2.49.0-1.rockspec";
        }).outPath;

      meta = {
        description = "🌒 Neovim plugin management inspired by Cargo, powered by luarocks";

        longDescription = ''
          rocks.nvim is an all in one solution for installing and managing
          Neovim plugins through the luarocks package manager.
          It supports dependency management, build scripts,
          all defined from a single rocks.toml file.
          Features:
          - Cargo-like rocks.toml file for declaring all your plugins.
          - Name-based installation ("nvim-neorg/neorg" becomes :Rocks install neorg instead).
          - Automatic dependency and build script management.
          - True semver versioning!
          - Minimal, non-intrusive UI.
          - Async execution.
          - Extensible, with a Lua API.
          - Command completions for plugins on luarocks.org.'';

        homepage = "https://github.com/lumen-oss/rocks.nvim";
        license = lib.licenses.gpl3Only;
        maintainers = with lib.maintainers; [ mrcjkb ];
      };
    }
  ) { };

  rtp-nvim = callPackage (
    {
      fetchurl,
      buildLuarocksPackage,
      fetchzip,
      luaOlder,
    }:
    buildLuarocksPackage {
      pname = "rtp.nvim";
      version = "1.2.0-1";

      src = fetchzip {
        url = "https://github.com/nvim-neorocks/rtp.nvim/archive/v1.2.0.zip";
        sha256 = "1b6hx50nr2s2mnhsx9zy54pjdq7f78mi394v2b2c9v687s45nqln";
      };

      disabled = luaOlder "5.1";

      knownRockspec =
        (fetchurl {
          sha256 = "0is9ssi3pwvshm88lnp4hkig4f0ckgl2f3a1axwci89y8lla50iv";
          url = "mirror://luarocks/rtp.nvim-1.2.0-1.rockspec";
        }).outPath;

      meta = {
        description = "Source plugin and ftdetect directories on the Neovim runtimepath.";
        homepage = "https://github.com/nvim-neorocks/rtp.nvim";
        license = lib.licenses.gpl3Only;
        maintainers = with lib.maintainers; [ mrcjkb ];
      };
    }
  ) { };

  rustaceanvim = callPackage (
    {
      fetchurl,
      buildLuarocksPackage,
      fetchzip,
      lua,
    }:
    buildLuarocksPackage {
      pname = "rustaceanvim";
      version = "9.0.5-2";

      src = fetchzip {
        url = "https://github.com/mrcjkb/rustaceanvim/archive/refs/tags/v9.0.5.zip";
        sha256 = "14396a3m4px4zcnpmfwkj3csxsmrbgx0v7yx6w8zni94zaixdacx";
      };

      disabled = lua.luaversion != "5.1";

      knownRockspec =
        (fetchurl {
          sha256 = "1wqs1nri1q4j91l7myn57667sxznisa1sgwhx4cakgancnl5m8s1";
          url = "mirror://luarocks/rustaceanvim-9.0.5-2.rockspec";
        }).outPath;

      meta = {
        description = "🦀 Supercharge your Rust experience in Neovim! A heavily modified fork of rust-tools.nvim";
        homepage = "https://github.com/mrcjkb/rustaceanvim/archive/refs/tags/v9.0.5.zip";
        license = lib.licenses.gpl2Only;
        maintainers = with lib.maintainers; [ mrcjkb ];
      };
    }
  ) { };

  say = callPackage (
    {
      fetchurl,
      fetchFromGitHub,
      buildLuarocksPackage,
      luaOlder,
    }:
    buildLuarocksPackage {
      pname = "say";
      version = "1.4.1-3";

      src = fetchFromGitHub {
        owner = "lunarmodules";
        repo = "say";
        tag = "v1.4.1";
        hash = "sha256-IjNkK1leVtYgbEjUqguVMjbdW+0BHAOCE0pazrVuF50=";
      };

      disabled = luaOlder "5.1";

      knownRockspec =
        (fetchurl {
          sha256 = "0iibmq5m5092y168banckgs15ngj2yjx11n40fyk7jly4pbasljq";
          url = "mirror://luarocks/say-1.4.1-3.rockspec";
        }).outPath;

      meta = {
        description = "Lua string hashing/indexing library";

        longDescription = ''
          Useful for internationalization.
        '';

        homepage = "https://lunarmodules.github.io/say";
        license = lib.licenses.mit;
      };
    }
  ) { };

  serpent = callPackage (
    {
      fetchurl,
      fetchFromGitHub,
      buildLuarocksPackage,
      luaAtLeast,
      luaOlder,
    }:
    buildLuarocksPackage {
      pname = "serpent";
      version = "0.30-2";

      src = fetchFromGitHub {
        owner = "pkulchenko";
        repo = "serpent";
        tag = "0.30";
        hash = "sha256-aCP/Lk11wdnqXzntgNlyZz1LkLgZApcvDiA//LLzAGE=";
      };

      disabled = luaOlder "5.1" || luaAtLeast "5.5";

      knownRockspec =
        (fetchurl {
          sha256 = "0v83lr9ars1n0djbh7np8jjqdhhaw0pdy2nkcqzqrhv27rzv494n";
          url = "mirror://luarocks/serpent-0.30-2.rockspec";
        }).outPath;

      meta = {
        description = "Lua serializer and pretty printer";
        homepage = "https://github.com/pkulchenko/serpent";
        license = lib.licenses.mit;
        maintainers = with lib.maintainers; [ lockejan ];
      };
    }
  ) { };

  sofa = callPackage (
    {
      fetchurl,
      fetchFromGitHub,
      argparse,
      buildLuarocksPackage,
      compat53,
      luaAtLeast,
      luaOlder,
      luatext,
      lyaml,
    }:
    buildLuarocksPackage {
      pname = "sofa";
      version = "0.8.0-0";

      src = fetchFromGitHub {
        owner = "f4z3r";
        repo = "sofa";
        tag = "v0.8.0";
        hash = "sha256-MWGp0kbLaXQV3ElSgPTFoVuWk4+ujktG0xh20kQPex4=";
      };

      propagatedBuildInputs = [
        argparse
        compat53
        luatext
        lyaml
      ];

      disabled = luaOlder "5.1" || luaAtLeast "5.5";

      knownRockspec =
        (fetchurl {
          sha256 = "09mjnygy8xpcp892mfqmcirjjndndvynl7bs7j4vp4r4svh17b05";
          url = "mirror://luarocks/sofa-0.8.0-0.rockspec";
        }).outPath;

      meta = {
        description = "A command execution engine powered by rofi.";

        longDescription = ''
          A tool to organise and execute your commands, so convenient you can
              run it from your sofa.
        '';

        homepage = "https://github.com/f4z3r/sofa";
        license = lib.licenses.mit;
        maintainers = with lib.maintainers; [ f4z3r ];
      };
    }
  ) { };

  sqlite = callPackage (
    {
      fetchurl,
      fetchFromGitHub,
      buildLuarocksPackage,
      luv,
    }:
    buildLuarocksPackage {
      pname = "sqlite";
      version = "v1.2.2-0";

      src = fetchFromGitHub {
        owner = "tami5";
        repo = "sqlite.lua";
        tag = "v1.2.2";
        hash = "sha256-NUjZkFawhUD0oI3pDh/XmVwtcYyPqa+TtVbl3k13cTI=";
      };

      propagatedBuildInputs = [ luv ];

      knownRockspec =
        (fetchurl {
          sha256 = "0jxsl9lpxsbzc6s5bwmh27mglkqz1299lz68vfxayvailwl3xbxm";
          url = "mirror://luarocks/sqlite-v1.2.2-0.rockspec";
        }).outPath;

      meta = {
        description = "SQLite/LuaJIT binding and a highly opinionated wrapper for storing, retrieving, caching, and persisting [SQLite] databases";
        homepage = "https://github.com/tami5/sqlite.lua";
        license = lib.licenses.mit;
      };
    }
  ) { };

  std-_debug = callPackage (
    {
      fetchurl,
      buildLuarocksPackage,
      fetchzip,
      luaAtLeast,
      luaOlder,
    }:
    buildLuarocksPackage {
      pname = "std._debug";
      version = "1.0.1-1";

      src = fetchzip {
        url = "http://github.com/lua-stdlib/_debug/archive/v1.0.1.zip";
        sha256 = "19vfpv389q79vgxwhhr09l6l6hf6h2yjp09zvnp0l07ar4v660pv";
      };

      disabled = luaOlder "5.1" || luaAtLeast "5.5";

      knownRockspec =
        (fetchurl {
          sha256 = "0mr9hgzfr9v37da9rfys2wjq48hi3lv27i3g38433dlgbxipsbc4";
          url = "mirror://luarocks/std._debug-1.0.1-1.rockspec";
        }).outPath;

      meta = {
        description = "Debug Hints Library";

        longDescription = ''
          Manage an overall debug state, and associated hint substates.
        '';

        homepage = "http://lua-stdlib.github.io/_debug";

        license = lib.licenses.AND [
          lib.licenses.mit
          lib.licenses.x11
        ];
      };
    }
  ) { };

  std-normalize = callPackage (
    {
      fetchurl,
      buildLuarocksPackage,
      fetchzip,
      luaAtLeast,
      luaOlder,
      std-_debug,
    }:
    buildLuarocksPackage {
      pname = "std.normalize";
      version = "2.0.3-1";

      src = fetchzip {
        url = "http://github.com/lua-stdlib/normalize/archive/v2.0.3.zip";
        sha256 = "1gyywglxd2y7ck3hk8ap73w0x7hf9irpg6vgs8yc6k9k4c5g3fgi";
      };

      propagatedBuildInputs = [ std-_debug ];
      disabled = luaOlder "5.1" || luaAtLeast "5.5";

      knownRockspec =
        (fetchurl {
          sha256 = "1l83ikiaw4dch2r69cxpl93b9d4wf54vbjb6fcggnkxxgm0amj3a";
          url = "mirror://luarocks/std.normalize-2.0.3-1.rockspec";
        }).outPath;

      meta = {
        description = "Normalized Lua Functions";

        longDescription = ''
          This module can inject deterministic versions of core Lua
                functions that do not behave identically across all supported Lua
                implementations into your module's lexical environment.   Each
                function is as thin and fast a version as is possible in each Lua
                implementation, evaluating to the Lua C implementation with no
                overhead when semantics allow.
        '';

        homepage = "https://lua-stdlib.github.io/normalize";

        license = lib.licenses.AND [
          lib.licenses.mit
          lib.licenses.x11
        ];
      };
    }
  ) { };

  stdlib = callPackage (
    {
      fetchurl,
      buildLuarocksPackage,
      fetchzip,
      luaAtLeast,
      luaOlder,
    }:
    buildLuarocksPackage {
      pname = "stdlib";
      version = "41.2.2-1";

      src = fetchzip {
        url = "http://github.com/lua-stdlib/lua-stdlib/archive/release-v41.2.2.zip";
        sha256 = "0ry6k0wh4vyar1z68s0qmqzkdkfn9lcznsl8av7x78qz6l16wfw4";
      };

      disabled = luaOlder "5.1" || luaAtLeast "5.5";

      knownRockspec =
        (fetchurl {
          sha256 = "0rscb4cm8s8bb8fk8rknc269y7bjqpslspsaxgs91i8bvabja6f6";
          url = "mirror://luarocks/stdlib-41.2.2-1.rockspec";
        }).outPath;

      meta = {
        description = "General Lua Libraries";
        longDescription = "stdlib is a library of modules for common programming tasks, including list, table and functional operations, objects, pickling, pretty-printing and command-line option parsing.";
        homepage = "http://lua-stdlib.github.io/lua-stdlib";

        license = lib.licenses.AND [
          lib.licenses.mit
          lib.licenses.x11
        ];
      };
    }
  ) { };

  teal-language-server = callPackage (
    {
      fetchurl,
      fetchFromGitHub,
      argparse,
      buildLuarocksPackage,
      ltreesitter,
      lua-cjson,
      luafilesystem,
      lusc_luv,
      luv,
      tl,
    }:
    buildLuarocksPackage {
      pname = "teal-language-server";
      version = "0.2.1-1";

      src = fetchFromGitHub {
        owner = "teal-language";
        repo = "teal-language-server";
        tag = "0.2.1";
        hash = "sha256-nrgop5L9RARx64ZbyIWzW3/8n9Vm4YSugLHgOnznVSs=";
      };

      propagatedBuildInputs = [
        argparse
        ltreesitter
        lua-cjson
        luafilesystem
        lusc_luv
        luv
        tl
      ];

      knownRockspec =
        (fetchurl {
          sha256 = "0dfqalvzsmvspmxp54pp9z4icx6k7ah6xz99lrnkhx01f798kf8z";
          url = "mirror://luarocks/teal-language-server-0.2.1-1.rockspec";
        }).outPath;

      meta = {
        description = "A language server for the Teal language";
        longDescription = "A language server for the Teal language";
        homepage = "https://github.com/teal-language/teal-language-server";
        license = lib.licenses.mit;
      };
    }
  ) { };

  telescope-manix = callPackage (
    {
      fetchurl,
      buildLuarocksPackage,
      fetchzip,
      luaOlder,
      telescope-nvim,
    }:
    buildLuarocksPackage {
      pname = "telescope-manix";
      version = "1.0.3-1";

      src = fetchzip {
        url = "https://github.com/mrcjkb/telescope-manix/archive/1.0.3.zip";
        sha256 = "186rbdddpv8q0zcz18lnkarp0grdzxp80189n4zj2mqyzqnw0svj";
      };

      propagatedBuildInputs = [ telescope-nvim ];
      disabled = luaOlder "5.1";

      knownRockspec =
        (fetchurl {
          sha256 = "0avqlglmki244q3ffnlc358z3pn36ibcqysxrxw7h6qy1zcwm8sr";
          url = "mirror://luarocks/telescope-manix-1.0.3-1.rockspec";
        }).outPath;

      meta = {
        description = "A telescope.nvim extension for Manix - A fast documentation searcher for Nix";

        longDescription = ''
          Manix is a fast documentation searcher for nix.
          This plugin provides a telescope.nvim extension for manix.'';

        homepage = "https://github.com/mrcjkb/telescope-manix";
        license = lib.licenses.gpl2Only;
      };
    }
  ) { };

  telescope-nvim = callPackage (
    {
      fetchurl,
      fetchFromGitHub,
      buildLuarocksPackage,
      lua,
      plenary-nvim,
    }:
    buildLuarocksPackage {
      pname = "telescope.nvim";
      version = "scm-1";

      src = fetchFromGitHub {
        owner = "nvim-telescope";
        repo = "telescope.nvim";
        rev = "427b576c16792edad01a92b89721d923c19ad60f";
        hash = "sha256-/GycCrepwDer0UvBN/f84pJUSvNp+ZfTIUPv0psl+IQ=";
      };

      propagatedBuildInputs = [ plenary-nvim ];
      disabled = lua.luaversion != "5.1";

      knownRockspec =
        (fetchurl {
          sha256 = "11dy6rkgkhc7zdrrvn361rwyf702yvvkhd0wz52pr757z534fk8s";
          url = "mirror://luarocks/telescope.nvim-scm-1.rockspec";
        }).outPath;

      meta = {
        description = "Find, Filter, Preview, Pick. All lua, all the time.";

        longDescription = ''
          A highly extendable fuzzy finder over lists.
            Built on the latest awesome features from neovim core.
            Telescope is centered around modularity, allowing for easy customization.
        '';

        homepage = "https://github.com/nvim-telescope/telescope.nvim";
        license = lib.licenses.mit;
      };
    }
  ) { };

  tiktoken_core = callPackage (
    {
      fetchurl,
      fetchFromGitHub,
      buildLuarocksPackage,
      luaOlder,
      luarocks-build-rust-mlua,
    }:
    buildLuarocksPackage {
      pname = "tiktoken_core";
      version = "0.2.5-1";

      src = fetchFromGitHub {
        owner = "gptlang";
        repo = "lua-tiktoken";
        tag = "v0.2.5";
        hash = "sha256-V3dpFS590QkJQRIAeEgxakvoOGrilolWHutKn9zlOsg=";
      };

      nativeBuildInputs = [ luarocks-build-rust-mlua ];
      propagatedBuildInputs = [ luarocks-build-rust-mlua ];
      disabled = luaOlder "5.1";

      knownRockspec =
        (fetchurl {
          sha256 = "17bii1zxxkff0wwsgap4ni1k6ypbrbq5vfs7l34m0n78imx7c2l1";
          url = "mirror://luarocks/tiktoken_core-0.2.5-1.rockspec";
        }).outPath;

      meta = {
        description = "An experimental port of OpenAI's Tokenizer to lua";

        longDescription = ''
          The Lua module written in Rust that provides Tiktoken support for Lua.
        '';

        homepage = "https://github.com/gptlang/lua-tiktoken";
        license = lib.licenses.mit;
        maintainers = with lib.maintainers; [ natsukium ];
      };
    }
  ) { };

  tl = callPackage (
    {
      fetchurl,
      fetchFromGitHub,
      argparse,
      buildLuarocksPackage,
      compat53,
    }:
    buildLuarocksPackage {
      pname = "tl";
      version = "0.24.8-1";

      src = fetchFromGitHub {
        owner = "teal-language";
        repo = "tl";
        tag = "v0.24.8";
        hash = "sha256-bjk/e+FuW0pSaVkRXIiYWhaNGU08Mgyvb7U7lc+8k2w=";
      };

      propagatedBuildInputs = [
        argparse
        compat53
      ];

      knownRockspec =
        (fetchurl {
          sha256 = "1m60ydmp6mn6iczg2an20ivvgn5rrz6sn0mhpnld9img3khvj7sf";
          url = "mirror://luarocks/tl-0.24.8-1.rockspec";
        }).outPath;

      meta = {
        description = "Teal, a typed dialect of Lua";
        homepage = "https://github.com/teal-language/tl";
        license = lib.licenses.mit;
        maintainers = with lib.maintainers; [ mephistophiles ];
      };
    }
  ) { };

  toml-edit = callPackage (
    {
      fetchurl,
      buildLuarocksPackage,
      fetchzip,
      luaOlder,
      luarocks-build-rust-mlua,
    }:
    buildLuarocksPackage {
      pname = "toml-edit";
      version = "0.7.0-1";

      src = fetchzip {
        url = "https://github.com/lumen-oss/toml-edit.lua/archive/v0.7.0.zip";
        sha256 = "03wg6mwmj802a5iv4fklz0zwd9slpw9hjzwj5068gf2lihkkwjzh";
      };

      nativeBuildInputs = [ luarocks-build-rust-mlua ];
      disabled = luaOlder "5.1";

      knownRockspec =
        (fetchurl {
          sha256 = "174kjw3j6p1q5wxd34929wlm4hsv5s7ma44nccy3l0b52g453afg";
          url = "mirror://luarocks/toml-edit-0.7.0-1.rockspec";
        }).outPath;

      meta = {
        description = "TOML Parser + Formatting and Comment-Preserving Editor";

        longDescription = ''
          `toml-edit` is a library to parse and edit `.toml` files as if they were lua tables, all while preserving formatting and comments.
          Based on rust's `toml-edit`.'';

        homepage = "https://github.com/lumen-oss/toml-edit.lua";
        license = lib.licenses.mit;
        maintainers = with lib.maintainers; [ mrcjkb ];
      };
    }
  ) { };

  tomlua = callPackage (
    {
      fetchurl,
      buildLuarocksPackage,
      fetchzip,
      luaOlder,
    }:
    buildLuarocksPackage {
      pname = "tomlua";
      version = "1.2.3-1";

      src = fetchzip {
        url = "https://github.com/BirdeeHub/tomlua/archive/v1.2.3.zip";
        sha256 = "04mg0m3qkr89la733rpzd8xrjq8ysrmjm7v8fid1r80cp1kbg9vf";
      };

      disabled = luaOlder "5.1";

      knownRockspec =
        (fetchurl {
          sha256 = "0aqagzxnz58nzwx7h3igycvcraxs1h7hyl47d7sbb01kcclp5jr6";
          url = "mirror://luarocks/tomlua-1.2.3-1.rockspec";
        }).outPath;

      meta = {
        description = "Speedy toml parsing for lua, implemented in C";

        longDescription = ''
          Speedy toml parsing for lua, implemented in C 
          for use in hot-path or startup-time parsing of toml files.'';

        homepage = "https://github.com/BirdeeHub/tomlua";
        license = lib.licenses.mit;
        maintainers = with lib.maintainers; [ birdee ];
      };
    }
  ) { };

  tree-sitter-cli = callPackage (
    {
      fetchurl,
      fetchFromGitHub,
      buildLuarocksPackage,
      luarocks-build-tree-sitter-cli,
    }:
    buildLuarocksPackage {
      pname = "tree-sitter-cli";
      version = "0.26.8-1";

      src = fetchFromGitHub {
        owner = "FourierTransformer";
        repo = "tree-sitter-cli";
        rev = "20947767690a1e81141c8ae4618cee80280861de";
        hash = "sha256-Dqhf7qfDyddaxuenPDpZsAuY3e5X9eXNISUslI5KDs4=";
      };

      nativeBuildInputs = [ luarocks-build-tree-sitter-cli ];

      knownRockspec =
        (fetchurl {
          sha256 = "01gkqv1nlp8sjlljb7hkj2rq41dc9dfdbamzsg80n6855ynhj8nx";
          url = "mirror://luarocks/tree-sitter-cli-0.26.8-1.rockspec";
        }).outPath;

      meta = {
        description = "Install tree-sitter CLI binaries";
        longDescription = "An option to install the tree-sitter CLI via LuaRocks";
        homepage = "https://github.com/FourierTransformer/tree-sitter-cli";
        license = lib.licenses.mit;
      };
    }
  ) { };

  tree-sitter-http = callPackage (
    {
      fetchurl,
      buildLuarocksPackage,
      fetchzip,
      luaOlder,
      luarocks-build-treesitter-parser,
    }:
    buildLuarocksPackage {
      pname = "tree-sitter-http";
      version = "0.0.33-1";

      src = fetchzip {
        url = "https://github.com/rest-nvim/tree-sitter-http/archive/d2e4e4c7d03f70e0465d436f2b5f67497cd544ca.zip";
        sha256 = "1wjycyvrahbpamdi6x74l8q1q8jrnk0y8nrwdwqdc7lm8hqjb5s2";
      };

      nativeBuildInputs = [ luarocks-build-treesitter-parser ];
      disabled = luaOlder "5.1";

      knownRockspec =
        (fetchurl {
          sha256 = "1x6avlk3bdz406ywmxpq0sdi31fpfrbpqlbdz1ygh9gpknah5617";
          url = "mirror://luarocks/tree-sitter-http-0.0.33-1.rockspec";
        }).outPath;

      meta = {
        description = "tree-sitter parser for http";
        homepage = "https://github.com/rest-nvim/tree-sitter-http";
        license = lib.licenses.unfree;
      };
    }
  ) { };

  tree-sitter-kulala_http = callPackage (
    {
      fetchurl,
      buildLuarocksPackage,
      fetchzip,
      luarocks-build-treesitter-parser,
    }:
    buildLuarocksPackage {
      pname = "tree-sitter-kulala_http";
      version = "0.3.0-1";

      src = fetchzip {
        url = "https://github.com/mistweaverco/tree-sitter-kulala-http/archive/v0.3.0.zip";
        sha256 = "08f9hx939xpnz772yc5zywkksgp9v0hhbj3xd2bb6xwf52avnfmm";
      };

      nativeBuildInputs = [ luarocks-build-treesitter-parser ];

      knownRockspec =
        (fetchurl {
          sha256 = "15wvlzf7ggr1bli32zi865y4gfsdwiqmrl2kz7vga9c58gqb05pz";
          url = "mirror://luarocks/tree-sitter-kulala_http-0.3.0-1.rockspec";
        }).outPath;

      meta = {
        description = "Tree-sitter grammar for http (kulala-flavour).";
        homepage = "https://kulala.app";
        license = lib.licenses.mit;
      };
    }
  ) { };

  tree-sitter-norg = callPackage (
    {
      fetchurl,
      buildLuarocksPackage,
      fetchzip,
      luarocks-build-treesitter-parser-cpp,
    }:
    buildLuarocksPackage {
      pname = "tree-sitter-norg";
      version = "0.2.6-1";

      src = fetchzip {
        url = "https://github.com/nvim-neorg/tree-sitter-norg/archive/v0.2.6.zip";
        sha256 = "077rds0rq10wjywpj4hmmq9dd6qp6sfwbdjyh587laldrfl7jy6g";
      };

      nativeBuildInputs = [ luarocks-build-treesitter-parser-cpp ];

      knownRockspec =
        (fetchurl {
          sha256 = "1s0wj59v4zjgimws742ybzy7nhnnkz8nas4y5k96c2z5z54ynxmq";
          url = "mirror://luarocks/tree-sitter-norg-0.2.6-1.rockspec";
        }).outPath;

      meta = {
        description = "The official tree-sitter parser for Norg documents.";
        homepage = "https://github.com/nvim-neorg/tree-sitter-norg";
        license = lib.licenses.mit;
        maintainers = with lib.maintainers; [ mrcjkb ];
      };
    }
  ) { };

  tree-sitter-norg-meta = callPackage (
    {
      fetchurl,
      buildLuarocksPackage,
      fetchzip,
      luarocks-build-treesitter-parser,
    }:
    buildLuarocksPackage {
      pname = "tree-sitter-norg-meta";
      version = "0.1.0-1";

      src = fetchzip {
        url = "https://github.com/nvim-neorg/tree-sitter-norg-meta/archive/v0.1.0.zip";
        sha256 = "1vz74wc5yy5fykl9c3b16k6fsvskxp93acsy81p337jzg709v97j";
      };

      nativeBuildInputs = [ luarocks-build-treesitter-parser ];

      knownRockspec =
        (fetchurl {
          sha256 = "0vngnyvdad6n36r37sc96asl7h5mph691a0638523mffbg8zdfvr";
          url = "mirror://luarocks/tree-sitter-norg-meta-0.1.0-1.rockspec";
        }).outPath;

      meta = {
        description = "Treesitter parser for Norg's `@document.meta` blocks.";
        homepage = "https://github.com/nvim-neorg/tree-sitter-norg-meta";
        license = lib.licenses.mit;
      };
    }
  ) { };

  tree-sitter-orgmode = callPackage (
    {
      fetchurl,
      buildLuarocksPackage,
      fetchzip,
      luarocks-build-treesitter-parser,
    }:
    buildLuarocksPackage {
      pname = "tree-sitter-orgmode";
      version = "2.0.4-1";

      src = fetchzip {
        url = "https://github.com/nvim-orgmode/tree-sitter-org/archive/2.0.4.zip";
        sha256 = "1c0j9h1nxgh0r8h9l9xd75hqqbsjy9x01gkg520fqnwcq45jd8pg";
      };

      nativeBuildInputs = [ luarocks-build-treesitter-parser ];

      knownRockspec =
        (fetchurl {
          sha256 = "0f8h1f5r7n32qplkk6w48ngj700105wn9xm7jqlvm26d6qpiihg9";
          url = "mirror://luarocks/tree-sitter-orgmode-2.0.4-1.rockspec";
        }).outPath;

      meta = {
        description = "A fork of tree-sitter-org, for use with the orgmode Neovim plugin";
        homepage = "https://github.com/nvim-orgmode/tree-sitter-org";
        license = lib.licenses.mit;
      };
    }
  ) { };

  tree-sitter-teal = callPackage (
    {
      fetchurl,
      buildLuarocksPackage,
      fetchzip,
      luaOlder,
      luarocks-build-treesitter-parser,
    }:
    buildLuarocksPackage {
      pname = "tree-sitter-teal";
      version = "0.0.35-1";

      src = fetchzip {
        url = "https://github.com/euclidianAce/tree-sitter-teal/archive/05d276e737055e6f77a21335b7573c9d3c091e2f.zip";
        sha256 = "1g1zk47a8jcwac0j60mlfv56mhlhbf6f77vjkx4vsfbrryprcfi4";
      };

      nativeBuildInputs = [ luarocks-build-treesitter-parser ];
      disabled = luaOlder "5.1";

      knownRockspec =
        (fetchurl {
          sha256 = "06g2i3y3gmyz17v9gxwswa9db544nyhd5mx4zq3lihrshbbf6r10";
          url = "mirror://luarocks/tree-sitter-teal-0.0.35-1.rockspec";
        }).outPath;

      meta = {
        description = "tree-sitter parser for teal";
        homepage = "https://github.com/euclidianAce/tree-sitter-teal";
        license = lib.licenses.unfree;
      };
    }
  ) { };

  utf8 = callPackage (
    {
      fetchurl,
      fetchFromGitHub,
      buildLuarocksPackage,
      luaOlder,
    }:
    buildLuarocksPackage {
      pname = "utf8";
      version = "1.3-0";

      src = fetchFromGitHub {
        owner = "dannote";
        repo = "luautf8";
        rev = "f36cc914ae9015cd3045987abadd83bbcfae98f0";
        hash = "sha256-xLWqglAzqcxY+R8GOC+D3uzL2+9ZriEx8Kj41LkI5vU=";
      };

      disabled = luaOlder "5.1";

      knownRockspec =
        (fetchurl {
          sha256 = "1szsrwb15yyvrqwyqrr7g5ivihc0kl4pc7qq439q235f3x8jv2jp";
          url = "mirror://luarocks/utf8-1.3-0.rockspec";
        }).outPath;

      meta = {
        description = "A UTF-8 support module for Lua";

        longDescription = ''
          This module adds UTF-8 support to Lua. It's compatible with Lua "string" module.
        '';

        homepage = "http://github.com/starwing/luautf8";
        license = lib.licenses.mit;
      };
    }
  ) { };

  vicious = callPackage (
    {
      fetchurl,
      buildLuarocksPackage,
      fetchzip,
      luaOlder,
    }:
    buildLuarocksPackage {
      pname = "vicious";
      version = "2.7.1-4";

      src = fetchzip {
        url = "https://github.com/vicious-widgets/vicious/archive/refs/tags/v2.7.1.zip";
        sha256 = "0bfj3bc1gmbwwvpwkmqp658iwrwdifc78hzwwy1qpn7rbmarg2qv";
      };

      disabled = luaOlder "5.1";

      knownRockspec =
        (fetchurl {
          sha256 = "1yvc9mbalsyrqysxkc1lf92ki5gzizn79y2azyavmgjwljif6lfi";
          url = "mirror://luarocks/vicious-2.7.1-4.rockspec";
        }).outPath;

      meta = {
        description = "Modular widget library for the \"awesome\" window manager";
        homepage = "https://vicious.rtfd.io";
        license = lib.licenses.gpl2Plus;
      };
    }
  ) { };

  vstruct = callPackage (
    {
      fetchurl,
      fetchFromGitHub,
      buildLuarocksPackage,
      luaOlder,
    }:
    buildLuarocksPackage {
      pname = "vstruct";
      version = "2.1.1-1";

      src = fetchFromGitHub {
        owner = "ToxicFrog";
        repo = "vstruct";
        tag = "v2.1.1";
        hash = "sha256-p9yRJ3Kr6WQ4vBSTOVLoX6peNCJW6b6kgXCySg7aiWo=";
      };

      disabled = luaOlder "5.1";

      knownRockspec =
        (fetchurl {
          sha256 = "111ff5207hspda9fpj9dqdd699rax0df3abdnfbmdbdy3j07dd04";
          url = "mirror://luarocks/vstruct-2.1.1-1.rockspec";
        }).outPath;

      meta = {
        description = "Lua library to manipulate binary data";
        homepage = "https://github.com/ToxicFrog/vstruct";
      };
    }
  ) { };

  vusted = callPackage (
    {
      fetchurl,
      fetchFromGitHub,
      buildLuarocksPackage,
      busted,
      luasystem,
    }:
    buildLuarocksPackage {
      pname = "vusted";
      version = "2.5.3-1";

      src = fetchFromGitHub {
        owner = "notomo";
        repo = "vusted";
        tag = "v2.5.3";
        hash = "sha256-b07aSgDgSNpALs5en8ZXLEd/ThLEWX/dTME8Rg1K15I=";
      };

      propagatedBuildInputs = [
        busted
        luasystem
      ];

      knownRockspec =
        (fetchurl {
          sha256 = "1n0fpr3kw0dp9qiik8k9nh3jbckl4zs7kv7mjfffs9kms85jrq3d";
          url = "mirror://luarocks/vusted-2.5.3-1.rockspec";
        }).outPath;

      meta = {
        description = "`busted` wrapper for testing neovim plugin";
        homepage = "https://github.com/notomo/vusted";
        license = lib.licenses.mit;
      };
    }
  ) { };

  xml2lua = callPackage (
    {
      fetchurl,
      fetchFromGitHub,
      buildLuarocksPackage,
      luaOlder,
    }:
    buildLuarocksPackage {
      pname = "xml2lua";
      version = "1.6-2";

      src = fetchFromGitHub {
        owner = "manoelcampos";
        repo = "xml2lua";
        tag = "v1.6-2";
        hash = "sha256-4il5mmRLtuyCJ2Nm1tKv2hXk7rmiq7Fppx9LMbjkne0=";
      };

      disabled = luaOlder "5.1";

      knownRockspec =
        (fetchurl {
          sha256 = "1fh57kv95a18q4869hmr4fbzbnlmq5z83mkkixvwzg3szf9kvfcn";
          url = "mirror://luarocks/xml2lua-1.6-2.rockspec";
        }).outPath;

      meta = {
        description = "An XML Parser written entirely in Lua that works for Lua 5.1+";

        longDescription = ''
          Enables parsing a XML string into a Lua Table and
             converting a Lua Table to an XML string.
        '';

        homepage = "http://manoelcampos.github.io/xml2lua/";
        license = lib.licenses.mit;
        maintainers = with lib.maintainers; [ teto ];
      };
    }
  ) { };

}
# GENERATED - do not edit this file
