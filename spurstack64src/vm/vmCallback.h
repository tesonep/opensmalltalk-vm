/* Automatically generated by
	CCodeGeneratorGlobalStructure * VMMaker-CompatibleUserName.1559896946 uuid: 4ef313c4-63f1-5636-a27f-90526b3217cd
 */

#define VM_CALLBACK_INC 1

typedef struct _VMCallbackContext {
	void *thunkp;
	sqIntptr_t *stackp;
	sqIntptr_t *intregargsp;
	double *floatregargsp;
	void *savedCStackPointer;
	void *savedCFramePointer;
	union {
								sqIntptr_t valword;
								struct { int low, high; } valleint64;
								struct { int high, low; } valbeint64;
								double valflt64;
								struct { void *addr; sqIntptr_t size; } valstruct;
							}	rvs;
	void *savedPrimFunctionPointer;
	jmp_buf	trampoline;
	jmp_buf	savedReenterInterpreter;
 } VMCallbackContext;

/* The callback return type codes */
#define retword 1
#define retword64 2
#define retdouble 3
#define retstruct 4


