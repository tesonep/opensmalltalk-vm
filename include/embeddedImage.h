#include "winResources.h"

#ifndef __embeddedImage_h__
#define __embeddedImage_h__

#undef  sqImageFile
#undef  sqImageFileClose
#undef  sqImageFileOpen
#undef  sqImageFilePosition
#undef  sqImageFileRead
#undef  sqImageFileSeek
#undef  sqImageFileSeekEnd
#undef  sqImageFileWrite
#undef  sqImageFileStartLocation

typedef struct {

	HGLOBAL handler;

	void* data;

	size_t pos;
	size_t size;

} __sqImageFile;

#define sqImageFile __sqImageFile *

EXPORT(sqInt) sqImageFileClose(sqImageFile f);

EXPORT(sqImageFile) sqImageFileOpen(char* fileName, char *mode);
EXPORT(long int) sqImageFilePosition(sqImageFile f);
EXPORT(size_t) sqImageFileRead(void * ptr, size_t sz, size_t count, sqImageFile f);

EXPORT(int) sqImageFileSeek(sqImageFile f, size_t pos);
EXPORT(int) sqImageFileSeekEnd(sqImageFile f, size_t pos);
EXPORT(size_t) sqImageFileWrite(void* ptr, size_t sz, size_t count, sqImageFile f);

#define sqImageFileStartLocation(fileRef, fileName, size)  0

#endif
