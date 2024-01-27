# flake.nix
#
# This file packages pythoneda-tools-artifact/new-domain as a Nix flake.
#
# Copyright (C) 2024-today rydnr's https://github.com/pythoneda-tools-artifact-def/new-domain
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
{
  description = "Tool to create new PythonEDA domains";
  inputs = rec {
    flake-utils.url = "github:numtide/flake-utils/v1.0.0";
    nixos.url = "github:NixOS/nixpkgs/23.11";
    pythoneda-shared-application = {
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixos.follows = "nixos";
      inputs.pythoneda-shared-banner.follows = "pythoneda-shared-banner";
      inputs.pythoneda-shared-domain.follows = "pythoneda-shared-domain";
      url = "github:pythoneda-shared-def/application/0.0.49";
    };
    pythoneda-shared-banner = {
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixos.follows = "nixos";
      url = "github:pythoneda-shared-def/banner/0.0.47";
    };
    pythoneda-shared-domain = {
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixos.follows = "nixos";
      inputs.pythoneda-shared-banner.follows = "pythoneda-shared-banner";
      url = "github:pythoneda-shared-def/domain/0.0.30";
    };
    pythoneda-shared-git-github = {
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixos.follows = "nixos";
      inputs.pythoneda-shared-banner.follows = "pythoneda-shared-banner";
      inputs.pythoneda-shared-domain.follows = "pythoneda-shared-domain";
      url = "github:pythoneda-shared-git-def/github/0.0.1";
    };
    pythoneda-shared-infrastructure = {
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixos.follows = "nixos";
      inputs.pythoneda-shared-banner.follows = "pythoneda-shared-banner";
      inputs.pythoneda-shared-domain.follows = "pythoneda-shared-domain";
      url = "github:pythoneda-shared-def/infrastructure/0.0.26";
    };
    stringtemplate3 = {
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixos.follows = "nixos";
      url = "github:rydnr/nix-flakes/stringtemplate3-3.1?dir=stringtemplate3";
    };
  };
  outputs = inputs:
    with inputs;
    let
      defaultSystems = flake-utils.lib.defaultSystems;
      supportedSystems = if builtins.elem "armv6l-linux" defaultSystems then
        defaultSystems
      else
        defaultSystems ++ [ "armv6l-linux" ];
    in flake-utils.lib.eachSystem supportedSystems (system:
      let
        org = "pythoneda-tools-artifact";
        repo = "new-domain";
        version = "0.0.3";
        sha256 = "0ci8rivdg1585kphamzk240yjfg864ly2haam3n8lhg2cggk1yzr";
        pname = "${org}-${repo}";
        pythonpackage = "pythoneda.tools.artifact.new_domain";
        package = builtins.replaceStrings [ "." ] [ "/" ] pythonpackage;
        entrypoint = "new_domain_app";
        description = "Tool to create new PythonEDA domains";
        license = pkgs.lib.licenses.gpl3;
        homepage = "https://github.com/pythoneda-tools-artifact/new-domain";
        maintainers = [ "rydnr <github@acm-sl.org>" ];
        archRole = "B";
        space = "A";
        layer = "D";
        nixosVersion = builtins.readFile "${nixos}/.version";
        nixpkgsRelease =
          builtins.replaceStrings [ "\n" ] [ "" ] "nixos-${nixosVersion}";
        shared = import "${pythoneda-shared-banner}/nix/shared.nix";
        pkgs = import nixos { inherit system; };
        pythoneda-tools-artifact-new-domain-for = { python
          , pythoneda-shared-application, pythoneda-shared-banner
          , pythoneda-shared-domain, pythoneda-shared-infrastructure
          , pythoneda-shared-git-github, stringtemplate3 }:
          let
            pnameWithUnderscores =
              builtins.replaceStrings [ "-" ] [ "_" ] pname;
            pythonVersionParts = builtins.splitVersion python.version;
            pythonMajorVersion = builtins.head pythonVersionParts;
            pythonMajorMinorVersion =
              "${pythonMajorVersion}.${builtins.elemAt pythonVersionParts 1}";
            wheelName =
              "${pnameWithUnderscores}-${version}-py${pythonMajorVersion}-none-any.whl";
            banner_file = "${package}/new_domain_banner.py";
            banner_class = "NewDomainBanner";
          in python.pkgs.buildPythonPackage rec {
            inherit pname version;
            projectDir = ./.;
            pyprojectTemplateFile = ./pyprojecttoml.template;
            pyprojectTemplate = pkgs.substituteAll {
              authors = builtins.concatStringsSep ","
                (map (item: ''"${item}"'') maintainers);
              desc = description;
              inherit homepage pname pythonMajorMinorVersion pythonpackage
                version;
              pythonedaSharedApplication = pythoneda-shared-application.version;
              pythonedaSharedDomain = pythoneda-shared-domain.version;
              pythonedaSharedGitGithub = pythoneda-shared-git-github.version;
              pythonedaSharedInfrastructure =
                pythoneda-shared-infrastructure.version;
              package = builtins.replaceStrings [ "." ] [ "/" ] pythonpackage;
              src = pyprojectTemplateFile;
              stringtemplate3 = stringtemplate3.version;
            };
            bannerTemplateFile =
              "${pythoneda-shared-banner}/templates/banner.py.template";
            bannerTemplate = pkgs.substituteAll {
              project_name = pname;
              file_path = banner_file;
              inherit banner_class org repo;
              tag = version;
              pescio_space = space;
              arch_role = archRole;
              hexagonal_layer = layer;
              python_version = pythonMajorMinorVersion;
              nixpkgs_release = nixpkgsRelease;
              src = bannerTemplateFile;
            };

            entrypointTemplateFile =
              "${pythoneda-shared-banner}/templates/entrypoint.sh.template";
            entrypointTemplate = pkgs.substituteAll {
              arch_role = archRole;
              hexagonal_layer = layer;
              nixpkgs_release = nixpkgsRelease;
              inherit homepage maintainers org python repo version;
              pescio_space = space;
              python_version = pythonMajorMinorVersion;
              pythoneda_shared_banner = pythoneda-shared-banner;
              pythoneda_shared_domain = pythoneda-shared-domain;
              src = entrypointTemplateFile;
            };
            src = pkgs.fetchFromGitHub {
              owner = org;
              rev = version;
              inherit repo sha256;
            };

            format = "pyproject";

            nativeBuildInputs = with python.pkgs; [ pip poetry-core ];
            propagatedBuildInputs = with python.pkgs; [
              pythoneda-shared-application
              pythoneda-shared-domain
              pythoneda-shared-git-github
              pythoneda-shared-infrastructure
              stringtemplate3
            ];

            pythonImportsCheck = [ pythonpackage ];

            unpackPhase = ''
              cp -r ${src} .
              sourceRoot=$(ls | grep -v env-vars)
              find $sourceRoot -type d -exec chmod 777 {} \;
              cp ${pyprojectTemplate} $sourceRoot/pyproject.toml
              cp ${bannerTemplate} $sourceRoot/${banner_file}
              cp ${entrypointTemplate} $sourceRoot/entrypoint.sh
            '';

            postPatch = ''
              substituteInPlace /build/$sourceRoot/entrypoint.sh \
                --replace "@SOURCE@" "$out/bin/${entrypoint}.sh" \
                --replace "@PYTHONPATH@" "$PYTHONPATH:$out/lib/python${pythonMajorMinorVersion}/site-packages" \
                --replace "@CUSTOM_CONTENT@" "" \
                --replace "@ENTRYPOINT@" "$out/lib/python${pythonMajorMinorVersion}/site-packages/${package}/application/${entrypoint}.py" \
                --replace "@BANNER@" "$out/bin/banner.sh"
            '';

            postInstall = ''
              pushd /build/$sourceRoot
              for f in $(find . -name '__init__.py'); do
                if [[ ! -e $out/lib/python${pythonMajorMinorVersion}/site-packages/$f ]]; then
                  cp $f $out/lib/python${pythonMajorMinorVersion}/site-packages/$f;
                fi
              done
              popd
              mkdir $out/dist $out/bin
              cp dist/${wheelName} $out/dist
              cp /build/$sourceRoot/entrypoint.sh $out/bin/${entrypoint}.sh
              chmod +x $out/bin/${entrypoint}.sh
              echo '#!/usr/bin/env sh' > $out/bin/banner.sh
              echo "export PYTHONPATH=$PYTHONPATH" >> $out/bin/banner.sh
              echo "${python}/bin/python $out/lib/python${pythonMajorMinorVersion}/site-packages/${banner_file} \$@" >> $out/bin/banner.sh
              chmod +x $out/bin/banner.sh
            '';

            meta = with pkgs.lib; {
              inherit description homepage license maintainers;
            };
          };
      in rec {
        apps = rec {
          default = pythoneda-tools-artifact-new-domain-default;
          pythoneda-tools-artifact-new-domain-default =
            pythoneda-tools-artifact-new-domain-python311;
          pythoneda-tools-artifact-new-domain-python38 = shared.app-for {
            package =
              self.packages.${system}.pythoneda-tools-artifact-new-domain-python38;
            inherit entrypoint;
          };
          pythoneda-tools-artifact-new-domain-python39 = shared.app-for {
            package =
              self.packages.${system}.pythoneda-tools-artifact-new-domain-python39;
            inherit entrypoint;
          };
          pythoneda-tools-artifact-new-domain-python310 = shared.app-for {
            package =
              self.packages.${system}.pythoneda-tools-artifact-new-domain-python310;
            inherit entrypoint;
          };
          pythoneda-tools-artifact-new-domain-python311 = shared.app-for {
            package =
              self.packages.${system}.pythoneda-tools-artifact-new-domain-python311;
            inherit entrypoint;
          };
        };
        defaultApp = apps.default;
        defaultPackage = packages.default;
        devShells = rec {
          default = pythoneda-tools-artifact-new-domain-default;
          pythoneda-tools-artifact-new-domain-default =
            pythoneda-tools-artifact-new-domain-python311;
          pythoneda-tools-artifact-new-domain-python38 = shared.devShell-for {
            banner = "${
                pythoneda-shared-banner.packages.${system}.pythoneda-shared-banner-python38
              }/bin/banner.sh";
            extra-namespaces = "";
            nixpkgs-release = nixpkgsRelease;
            package = packages.pythoneda-tools-artifact-new-domain-python38;
            python = pkgs.python38;
            pythoneda-shared-banner =
              pythoneda-shared-banner.packages.${system}.pythoneda-shared-banner-python38;
            pythoneda-shared-domain =
              pythoneda-shared-domain.packages.${system}.pythoneda-shared-domain-python38;
            inherit archRole layer org pkgs repo space;
          };
          pythoneda-tools-artifact-new-domain-python39 = shared.devShell-for {
            banner = "${
                pythoneda-shared-banner.packages.${system}.pythoneda-shared-banner-python39
              }/bin/banner.sh";
            extra-namespaces = "";
            nixpkgs-release = nixpkgsRelease;
            package = packages.pythoneda-tools-artifact-new-domain-python39;
            python = pkgs.python39;
            pythoneda-shared-banner =
              pythoneda-shared-banner.packages.${system}.pythoneda-shared-banner-python39;
            pythoneda-shared-domain =
              pythoneda-shared-domain.packages.${system}.pythoneda-shared-domain-python39;
            inherit archRole layer org pkgs repo space;
          };
          pythoneda-tools-artifact-new-domain-python310 = shared.devShell-for {
            banner = "${
                pythoneda-shared-banner.packages.${system}.pythoneda-shared-banner-python310
              }/bin/banner.sh";
            extra-namespaces = "";
            nixpkgs-release = nixpkgsRelease;
            package = packages.pythoneda-tools-artifact-new-domain-python310;
            python = pkgs.python310;
            pythoneda-shared-banner =
              pythoneda-shared-banner.packages.${system}.pythoneda-shared-banner-python310;
            pythoneda-shared-domain =
              pythoneda-shared-domain.packages.${system}.pythoneda-shared-domain-python310;
            inherit archRole layer org pkgs repo space;
          };
          pythoneda-tools-artifact-new-domain-python311 = shared.devShell-for {
            banner = "${
                pythoneda-shared-banner.packages.${system}.pythoneda-shared-banner-python311
              }/bin/banner.sh";
            extra-namespaces = "";
            nixpkgs-release = nixpkgsRelease;
            package = packages.pythoneda-tools-artifact-new-domain-python311;
            python = pkgs.python311;
            pythoneda-shared-banner =
              pythoneda-shared-banner.packages.${system}.pythoneda-shared-banner-python311;
            pythoneda-shared-domain =
              pythoneda-shared-domain.packages.${system}.pythoneda-shared-domain-python311;
            inherit archRole layer org pkgs repo space;
          };
        };
        packages = rec {
          default = pythoneda-tools-artifact-new-domain-default;
          pythoneda-tools-artifact-new-domain-default =
            pythoneda-tools-artifact-new-domain-python311;
          pythoneda-tools-artifact-new-domain-python38 =
            pythoneda-tools-artifact-new-domain-for {
              python = pkgs.python38;
              pythoneda-shared-application =
                pythoneda-shared-application.packages.${system}.pythoneda-shared-application-python38;
              pythoneda-shared-banner =
                pythoneda-shared-banner.packages.${system}.pythoneda-shared-banner-python38;
              pythoneda-shared-domain =
                pythoneda-shared-domain.packages.${system}.pythoneda-shared-domain-python38;
              pythoneda-shared-git-github =
                pythoneda-shared-git-github.packages.${system}.pythoneda-shared-git-github-python38;
              pythoneda-shared-infrastructure =
                pythoneda-shared-infrastructure.packages.${system}.pythoneda-shared-infrastructure-python38;
              stringtemplate3 =
                stringtemplate3.packages.${system}.stringtemplate3-python38;
            };
          pythoneda-tools-artifact-new-domain-python39 =
            pythoneda-tools-artifact-new-domain-for {
              python = pkgs.python39;
              pythoneda-shared-application =
                pythoneda-shared-application.packages.${system}.pythoneda-shared-application-python39;
              pythoneda-shared-banner =
                pythoneda-shared-banner.packages.${system}.pythoneda-shared-banner-python39;
              pythoneda-shared-domain =
                pythoneda-shared-domain.packages.${system}.pythoneda-shared-domain-python39;
              pythoneda-shared-git-github =
                pythoneda-shared-git-github.packages.${system}.pythoneda-shared-git-github-python39;
              pythoneda-shared-infrastructure =
                pythoneda-shared-infrastructure.packages.${system}.pythoneda-shared-infrastructure-python39;
              stringtemplate3 =
                stringtemplate3.packages.${system}.stringtemplate3-python39;
            };
          pythoneda-tools-artifact-new-domain-python310 =
            pythoneda-tools-artifact-new-domain-for {
              python = pkgs.python310;
              pythoneda-shared-application =
                pythoneda-shared-application.packages.${system}.pythoneda-shared-application-python310;
              pythoneda-shared-banner =
                pythoneda-shared-banner.packages.${system}.pythoneda-shared-banner-python310;
              pythoneda-shared-domain =
                pythoneda-shared-domain.packages.${system}.pythoneda-shared-domain-python310;
              pythoneda-shared-git-github =
                pythoneda-shared-git-github.packages.${system}.pythoneda-shared-git-github-python310;
              pythoneda-shared-infrastructure =
                pythoneda-shared-infrastructure.packages.${system}.pythoneda-shared-infrastructure-python310;
              stringtemplate3 =
                stringtemplate3.packages.${system}.stringtemplate3-python310;
            };
          pythoneda-tools-artifact-new-domain-python311 =
            pythoneda-tools-artifact-new-domain-for {
              python = pkgs.python311;
              pythoneda-shared-application =
                pythoneda-shared-application.packages.${system}.pythoneda-shared-application-python311;
              pythoneda-shared-banner =
                pythoneda-shared-banner.packages.${system}.pythoneda-shared-banner-python311;
              pythoneda-shared-domain =
                pythoneda-shared-domain.packages.${system}.pythoneda-shared-domain-python311;
              pythoneda-shared-git-github =
                pythoneda-shared-git-github.packages.${system}.pythoneda-shared-git-github-python311;
              pythoneda-shared-infrastructure =
                pythoneda-shared-infrastructure.packages.${system}.pythoneda-shared-infrastructure-python311;
              stringtemplate3 =
                stringtemplate3.packages.${system}.stringtemplate3-python311;
            };
        };
      });
}
