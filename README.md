# pythoneda-tools-artifact/new-domain

Definition of <https://github.com/pythoneda-tools-artifact/new-domain>.

## How to run it

``` sh
nix run 'https://github.com/pythoneda-tools-artifact-def/new-domain/[version]'
```

## Usage

To run this tool, check the latest tag of this repository, and use it instead of the `[version]` placeholder below:

``` sh
nix run https://github.com/pythoneda-tools-artifact-def/new-domain/[version] [-h|--help] [-n|--namespace namespace] [-t|--github-token githubToken] [-g|--gpg-key-id gpgKeyId]
```
- `-h|--help`: Prints the usage.
- `-n|--namespace`: The Python namespace, for example `pythoneda.my_domain`
- `-t|--github-token`: The github token.
- `-g|--gpg-key-id`: The GnuPG key id.

