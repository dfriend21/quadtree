## Resubmission

This is a re-submission after a failed initial submission. On Debian Linux the build failed because data included in the 'data' folder contained objects from a package that was listed in 'Suggests' but not 'Includes'. I have removed that folder entirely since the data is available in a different form via 'inst/extdata'.

## Test environments

* local OS X install, R 4.3.1
* R-hub: Debian Linux, R-devel, GCC ASAN/UBSAN
* R-hub: Fedora Linux, R-devel, clang, gfortran
* R-hub: Ubuntu Linux 20.04.1 LTS, R-release, GCC
* R-hub: Windows Server 2022, R-devel, 64 bit
* win-builder (devel, release, oldrelease)

## R CMD check results

The local OS X install, had 0 errors, 0 warnings, and 0 notes.

The other platforms had the following note:

```
Maintainer: ‘Derek Friend <dafriend.R@gmail.com>’

New submission

Package was archived on CRAN

Possibly misspelled words in DESCRIPTION:
  quadtree (30:54, 35:18, 37:44)
  quadtree's (34:37)
  quadtrees (28:66, 29:26, 33:29, 33:66, 36:15, 36:50)
  Quadtrees (3:15)

CRAN repository db overrides:
  X-CRAN-Comment: Archived on 2023-07-18 as issues were not corrected
    in time.
```

The possible misspellings are correctly spelled.

Fedora Linux, Ubuntu Linux and Debian Linux had the following note:

```
* checking installed package size ... NOTE
  installed size is 10.7Mb
  sub-directories of 1Mb or more:
    doc    1.7Mb
    libs   8.0Mb
```

It is my understanding that this is not a significant issue (for example, see Dirk Eddelbuettel's comment on this StackOverflow question: https://stackoverflow.com/questions/53819970/r-package-libs-directory-too-large-after-compilation-to-submit-on-cran)

Windows Server had the following note:

```
checking for detritus in the temp directory ... NOTE
Found the following files/directories:
  'lastMiKTeXException'
```

The maintainer of the `rhub` package has said that this is a R-hub bug. See this Github issue: https://github.com/r-hub/rhub/issues/503