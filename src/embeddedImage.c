#include "pharo.h"

EXPORT(sqInt) sqImageFileClose(sqImageFile f){
	if(f == NULL)
		return EOF;

	free(f);

	return 0;
}

EXPORT(sqImageFile) sqImageFileOpen(char* fileName, char *mode){
	HGLOBAL res_handle = NULL;
	HRSRC res;
	void * res_data;
	DWORD res_size;
	sqImageFile fileHandler;

	// NOTE: providing g_hInstance is important, NULL might not work
	res = FindResource(NULL, MAKEINTRESOURCE(EMBEDDED_IMAGE), RT_RCDATA);

	if (!res)
		return NULL;

	res_handle = LoadResource(NULL, res);
	if (!res_handle)
		return NULL;

	res_data = LockResource(res_handle);
	res_size = SizeofResource(NULL, res);

	fileHandler = (sqImageFile) malloc(sizeof(__sqImageFile));
	if(fileHandler == NULL)
		return NULL;

	fileHandler->handler = res_handle;
	fileHandler->data = res_data;
	fileHandler->pos = 0;
	fileHandler->size=res_size;

	return fileHandler;
}

EXPORT(long int) sqImageFilePosition(sqImageFile f){
	return f->pos;
}

EXPORT(size_t) sqImageFileRead(void * ptr, size_t sz, size_t count, sqImageFile fileHandler){

	size_t toRead;
	size_t remaining;

	if(fileHandler == NULL || sz == 0 || count == 0)
		return 0;

	if(fileHandler->pos == fileHandler->size){
		return 0;
	}

	remaining = fileHandler->size - fileHandler->pos;
	toRead = count * sz;
	toRead = toRead > remaining ? remaining : toRead;

	if(toRead == 0)
		return 0;

	memcpy(ptr, (void*)(fileHandler->data + fileHandler->pos), toRead);

	fileHandler->pos += toRead;

	return toRead;
}

EXPORT(int) sqImageFileSeek(sqImageFile fileHandler, size_t pos){
	fileHandler->pos = pos;
}

EXPORT(int) sqImageFileSeekEnd(sqImageFile fileHandler, size_t offset){
	fileHandler->pos = offset + fileHandler->size;
}

EXPORT(size_t) sqImageFileWrite(void* ptr, size_t sz, size_t count, sqImageFile fileHandler){
	//Sorry I can't write I am reading a resource
	return 0;
}
