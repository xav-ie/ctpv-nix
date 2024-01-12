{
  description = "A flake for the ctpv application";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachSystem [ "x86_64-linux" "aarch64-darwin" ] (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            file
            openssl
            makeWrapper
            atool
            bat
            chafa
            delta
            ffmpeg
            ffmpegthumbnailer
            fontforge
            glow
            imagemagick
            jq
            ueberzug
          ];
        };

        packages.default = pkgs.stdenv.mkDerivation rec {
          pname = "ctpv";
          version = "1.1";

          src = pkgs.fetchFromGitHub {
            owner = "NikitaIvanovV";
            repo = pname;
            rev = "v${version}";
            hash = "sha256-3BQi4m44hBmPkJBFNCg6d9YKRbDZwLxdzBb/NDWTQP4=";
          };

          nativeBuildInputs = [ pkgs.makeWrapper ];

          buildInputs = [
            pkgs.file # libmagic
            pkgs.openssl
          ];

          makeFlags = [ "PREFIX=$(out)" ];

          preFixup = ''
            wrapProgram $out/bin/ctpv \
              --prefix PATH ":" "${pkgs.lib.makeBinPath [
                pkgs.atool # for archive files
                pkgs.bat
                pkgs.chafa # for image files on Wayland
                pkgs.delta # for diff files
                pkgs.ffmpeg
                pkgs.ffmpegthumbnailer
                pkgs.fontforge
                pkgs.glow # for markdown files
                pkgs.imagemagick
                pkgs.jq # for json files
                pkgs.ueberzug # for image files on X11
              ]}";
          '';

          meta = with pkgs.lib; {
            description = "File previewer for a terminal";
            homepage = "https://github.com/NikitaIvanovV/ctpv";
            license = licenses.mit;
            platforms = platforms.linux;
            maintainers = [ maintainers.wesleyjrz ];
          };
        };
      }
    );
}

