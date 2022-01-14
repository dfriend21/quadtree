## Test environments

* local OS X install, R 4.1.2
* R-hub: Debian Linux, R-devel, GCC ASAN/UBSAN
* R-hub: Fedora Linux, R-devel, clang, gfortran
* R-hub: Ubuntu Linux 20.04.1 LTS, R-release, GCC
* R-hub: Oracle Solaris 10, x86, 32 bit, R-release
* R-hub: Windows Server 2022, R-devel, 64 bit
* win-builder (devel, release, oldrelease)

## R CMD check results

The build fails on Debian Linux (R-hub). However, I believe this is unrelated to my package - the log shows that `Rcpp` fails to install, which subsequently causes both `terra` and `quadtree` to fail, since they both depend on `Rcpp`.

win-builder devel and my local OS X install had the following WARNING:

```
* checking whether package 'quadtree' can be installed ... WARNING
Found the following significant warnings:
  Warning: multiple methods tables found for 'direction'
  Warning: multiple methods tables found for ‘gridDistance’
```

This appears to be an issue with the 'raster' package. Both of the functions mentioned are in 'raster' and are not used in 'quadtree'. Others have also run into this issue:

https://stackoverflow.com/questions/70674136/r-package-warning-multiple-methods-tables-found-for-direction

Fedora Linux and Ubuntu Linux had the following NOTE:

```
* checking installed package size ... NOTE
  installed size is 10.7Mb
  sub-directories of 1Mb or more:
    doc    1.6Mb
    libs   8.0Mb
```

It is my understanding that this is not a significant issue (for example, see Dirk Eddelbuettel's comment on this StackOverflow question: https://stackoverflow.com/questions/53819970/r-package-libs-directory-too-large-after-compilation-to-submit-on-cran)

Windows Server had the following NOTE:

```
* checking for detritus in the temp directory ... NOTE
Found the following files/directories:
  'lastMiKTeXException'
```

I am unsure why this note is happening - I'm hoping it's insignificant since it is only occurring on one platform.
