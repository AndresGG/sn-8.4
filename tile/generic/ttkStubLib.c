/*
 * ttkStubLib.c,v 1.5 2010/02/05 21:34:32 jenglish Exp
 * SOURCE: tk/generic/tkStubLib.c, version 1.9 2004/03/17
 */

#include "tk.h"

#define USE_TTK_STUBS 1
#include "tkTheme.h"

const TtkStubs *ttkStubsPtr;

/*
 *----------------------------------------------------------------------
 *
 * TtkInitializeStubs --
 *	Load the tile package, initialize stub table pointer.
 *	Do not call this function directly, use Ttk_InitStubs() macro instead.
 *
 * Results:
 *	The actual version of the package that satisfies the request, or
 *	NULL to indicate that an error occurred.
 *
 * Side effects:
 *	Sets the stub table pointer.
 *
 */
const char *
TtkInitializeStubs(
    Tcl_Interp *interp, const char *version, int epoch, int revision)
{
    int exact = 0;
    const char *packageName = "tile";
    const char *errMsg = NULL;
    ClientData pkgClientData = NULL;
    const char *actualVersion = Tcl_PkgRequireEx(
	interp, packageName, version, exact, &pkgClientData);
    const TtkStubs *stubsPtr = pkgClientData;

    if (!actualVersion) {
	return NULL;
    }

    if (!stubsPtr) {
	errMsg = "missing stub table pointer";
	goto error;
    }
    if (stubsPtr->epoch != epoch) {
	errMsg = "epoch number mismatch";
	goto error;
    }
    if (stubsPtr->revision < revision) {
	errMsg = "require later revision";
	goto error;
    }

    ttkStubsPtr = stubsPtr;
    return actualVersion;

error:
    Tcl_ResetResult(interp);
    Tcl_AppendResult(interp,
	"Error loading ", packageName, " package",
	" (requested version '", version,
	"', loaded version '", actualVersion, "'): ",
	errMsg, 
	NULL);
    return NULL;
}

