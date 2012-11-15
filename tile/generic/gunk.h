/*
 * gunk.h
 *
 * Portability gunk.
 *
 * Tk doesn't seem provide a consistent API across different 
 * platforms, at least not in the public interface.
 * This file is a dumping ground for any #ifdeffery needed
 * to get stuff to compile on multiple platforms.
 */


/*
 * ... Tk also doesn't provide a consistent set of #defines
 * to determine what platform we're on ...
 */

#if defined(__WIN32__)
#	define WIN_TK 1
#endif

#if !defined(WIN_TK) && !defined(MAC_TK) && !defined(MAC_OSX_TK)
#	define X11_TK 1
#endif

#if X11_TK
#define TkPutImage(colors, ncolors, display, pixels, gc, image, destx, desty, srcx, srcy, width, height) \
	XPutImage(display, pixels, gc, image, destx, desty, srcx, \
	srcy, width, height);
#endif

