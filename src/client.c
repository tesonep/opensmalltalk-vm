#include "pharo.h"
#include "pharoClient.h"

#if defined(__GNUC__) && ( defined(i386) || defined(__i386) || defined(__i386__)  \
			|| defined(i486) || defined(__i486) || defined (__i486__) \
			|| defined(intel) || defined(x86) || defined(i86pc) )
static void fldcw(unsigned int cw)
{
    __asm__("fldcw %0" :: "m"(cw));
}
#else
#   define fldcw(cw)
#endif

#if defined(__GNUC__) && ( defined(ppc) || defined(__ppc) || defined(__ppc__)  \
			|| defined(POWERPC) || defined(__POWERPC) || defined (__POWERPC__) )
void mtfsfi(unsigned long long fpscr)
{
    __asm__("lfd   f0, %0" :: "m"(fpscr));
    __asm__("mtfsf 0xff, f0");
}
#else
#   define mtfsfi(fpscr)
#endif

int loadPharoImage(char* fileName);

EXPORT(int) initPharoVM(char* image, char** vmParams, int vmParamCount, char** imageParams, int imageParamCount){
	initGlobalStructure();

	//Unix Initialization specific
	fldcw(0x12bf);	/* signed infinity, round to nearest, REAL8, disable intrs, disable signals */
    mtfsfi(0);		/* disable signals, IEEE mode, round to nearest */


    ioInitTime();

    ioVMThread = ioCurrentOSThread();
	ioInitExternalSemaphores();

	aioInit();

	setPharoCommandLineParameters(vmParams, vmParamCount, imageParams, imageParamCount);

	return loadPharoImage(image);
}

EXPORT(void) runInterpreter(){
	interpret();
}

int loadPharoImage(char* fileName){
    size_t imageSize = 0;
    sqImageFile imageFile = NULL;

    /* Open the image file. */
    imageFile = sqImageFileOpen(fileName, "rb");
    if(!imageFile){
    	perror("Opening Image");
        return false;
    }

    /* Get the size of the image file*/
    sqImageFileSeekEnd(imageFile, 0);
    imageSize = sqImageFilePosition(imageFile);
    sqImageFileSeek(imageFile, 0);

    readImageFromFileHeapSizeStartingAt(imageFile, 0, 0);
    sqImageFileClose(imageFile);

    char* fullImageName = alloca(FILENAME_MAX);
	fullImageName = getFullPath(fileName, fullImageName, FILENAME_MAX);

    setImageName(fullImageName);

    return true;
}
