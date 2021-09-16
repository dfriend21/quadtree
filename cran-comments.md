## Resubmission

* The initial submission failed `R CMD check` on CRAN. I believe the problem was because of a missing `#include` in one of my C++ files. I have added the missing `#include`.
* I also cleaned up the C++ code and comments.

## Test environments

* local OS X install, R 4.1.1
* R-hub: Windows Server 2008 R2 SP1, R-devel, 32/64 bit
* R-hub: Ubuntu Linux 20.04.1 LTS, R-release, GCC
* R-hub: Fedora Linux, R-devel, clang, gfortran
* R-hub: Debian Linux, R-devel, GCC ASAN/UBSAN
* R-hub: Oracle Solaris 10, x86, 32 bit, R-release
* win-builder (devel, release, oldrelease)

## R CMD check results

R CMD check on all platforms ran with 0 ERRORS and 0 WARNINGS.

Debian Linux (R-hub) and Oracle Solaris (R-hub) had 0 NOTES.

OS X, Debian Linux (R-hub), and win-builder (devel, release, and oldrelease) had 1 NOTE: `new submission`. In addition, it identified 'quadtree' as a potentially misspelled word, but it is spelled correctly.

Windows Server (R-hub), Ubuntu Linux (R-hub), Fedora Linux (R-hub) all had the following additional NOTE (although the size of 'libs' varied from 2.9Mb to 13.3Mb):

```
checking installed package size ... NOTE
  installed size is 10.2Mb
  sub-directories of 1Mb or more:
    doc    1.6Mb
    libs   7.8Mb
```

Based on some searching that I've done, it is my understanding that the large size of 'libs' is not a significant issue (for example, see Dirk Eddelbuettel's comment on this StackOverflow question: https://stackoverflow.com/questions/53819970/r-package-libs-directory-too-large-after-compilation-to-submit-on-cran)

The 'doc' folder is large because the vignettes contain quite a few images, which I believe are important in explaining the package's functionality. In addition, the 'CRAN Repository Policy' states that "neither data nor documentation should exceed 5MB", and the folder is significantly smaller than 5MB.
