/* Automatically generated by
	SmartSyntaxPluginCodeGenerator VMMaker.oscog-eem.1886 uuid: d413db9f-37cc-4c5d-bfc6-87b11203ee96
   from
	GeniePlugin VMMaker.oscog-eem.1886 uuid: d413db9f-37cc-4c5d-bfc6-87b11203ee96
 */
static char __buildInfo[] = "GeniePlugin VMMaker.oscog-eem.1886 uuid: d413db9f-37cc-4c5d-bfc6-87b11203ee96 " __DATE__ ;



#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

/* Default EXPORT macro that does nothing (see comment in sq.h): */
#define EXPORT(returnType) returnType

/* Do not include the entire sq.h file but just those parts needed. */
#include "sqConfig.h"			/* Configuration options */
#include "sqVirtualMachine.h"	/*  The virtual machine proxy definition */
#include "sqPlatformSpecific.h"	/* Platform specific definitions */

#define true 1
#define false 0
#define null 0  /* using 'null' because nil is predefined in Think C */
#ifdef SQUEAK_BUILTIN_PLUGIN
# undef EXPORT
# define EXPORT(returnType) static returnType
#endif

#include "sqMemoryAccess.h"


/*** Function Prototypes ***/
static sqInt cSquaredDistanceFromto(int *aPoint, int *bPoint);
static sqInt cSubstAngleFactorFromto(sqInt startDegreeNumber, sqInt endDegreeNumber);
EXPORT(const char*) getModuleName(void);
static sqInt majorNO(void);
static sqInt minorNO(void);
static sqInt msg(char *s);
EXPORT(sqInt) primSameClassAbsoluteStrokeDistanceMyPoints_otherPoints_myVectors_otherVectors_mySquaredLengths_otherSquaredLengths_myAngles_otherAngles_maxSizeAndReferenceFlag_rowBase_rowInsertRemove_rowInsertRemoveCount(void);
EXPORT(sqInt) primVersionNO(void);
EXPORT(sqInt) setInterpreter(struct VirtualMachine*anInterpreter);
static sqInt sqAssert(sqInt aBool);


/*** Variables ***/

#if !defined(SQUEAK_BUILTIN_PLUGIN)
static sqInt (*failed)(void);
static void * (*firstIndexableField)(sqInt oop);
static sqInt (*integerObjectOf)(sqInt value);
static sqInt (*isMemberOf)(sqInt oop, char *aString);
static sqInt (*isWords)(sqInt oop);
static sqInt (*popthenPush)(sqInt nItems, sqInt oop);
static sqInt (*primitiveFail)(void);
static sqInt (*stSizeOf)(sqInt oop);
static sqInt (*stackIntegerValue)(sqInt offset);
static sqInt (*stackValue)(sqInt offset);
static sqInt (*success)(sqInt aBoolean);
#else /* !defined(SQUEAK_BUILTIN_PLUGIN) */
extern sqInt failed(void);
extern void * firstIndexableField(sqInt oop);
extern sqInt integerObjectOf(sqInt value);
extern sqInt isMemberOf(sqInt oop, char *aString);
extern sqInt isWords(sqInt oop);
extern sqInt popthenPush(sqInt nItems, sqInt oop);
extern sqInt primitiveFail(void);
extern sqInt stSizeOf(sqInt oop);
extern sqInt stackIntegerValue(sqInt offset);
extern sqInt stackValue(sqInt offset);
extern sqInt success(sqInt aBoolean);
extern
#endif
struct VirtualMachine* interpreterProxy;
static const char *moduleName =
#ifdef SQUEAK_BUILTIN_PLUGIN
	"GeniePlugin v2.0 8 June 2016 VMMaker.oscog-eem.1886 (i)"
#else
	"GeniePlugin v2.0 8 June 2016 VMMaker.oscog-eem.1886 (e)"
#endif
;



/*	arguments are pointer to ints paired as x,y coordinates of points */

	/* GeniePlugin>>#cSquaredDistanceFrom:to: */
static sqInt
cSquaredDistanceFromto(int *aPoint, int *bPoint)
{
	int aPointX;
	int aPointY;
	int bPointX;
	int bPointY;
	int xDiff;
	int yDiff;

	aPointX = aPoint[0];
	aPointY = aPoint[1];
	bPointX = bPoint[0];
	bPointY = bPoint[1];
	xDiff = bPointX - aPointX;
	yDiff = bPointY - aPointY;
	return (xDiff * xDiff) + (yDiff * yDiff);
}

	/* GeniePlugin>>#cSubstAngleFactorFrom:to: */
static sqInt
cSubstAngleFactorFromto(sqInt startDegreeNumber, sqInt endDegreeNumber)
{
	sqInt absDiff;

	absDiff = SQABS((endDegreeNumber - startDegreeNumber));
	if (absDiff > 180) {
		absDiff = 360 - absDiff;
	}
	return ((usqInt) (absDiff * absDiff) >> 6);
}


/*	Note: This is hardcoded so it can be run from Squeak.
	The module name is used for validating a module *after*
	it is loaded to check if it does really contain the module
	we're thinking it contains. This is important! */

	/* InterpreterPlugin>>#getModuleName */
EXPORT(const char*)
getModuleName(void)
{
	return moduleName;
}

	/* GeniePlugin>>#majorNO */
static sqInt
majorNO(void)
{
	return 2;
}

	/* GeniePlugin>>#minorNO */
static sqInt
minorNO(void)
{
	return 0;
}

	/* InterpreterPlugin>>#msg: */
static sqInt
msg(char *s)
{
	fprintf(stderr, "\n%s: %s", moduleName, s);
	return 0;
}

	/* GeniePlugin>>#primSameClassAbsoluteStrokeDistanceMyPoints:otherPoints:myVectors:otherVectors:mySquaredLengths:otherSquaredLengths:myAngles:otherAngles:maxSizeAndReferenceFlag:rowBase:rowInsertRemove:rowInsertRemoveCount: */
EXPORT(sqInt)
primSameClassAbsoluteStrokeDistanceMyPoints_otherPoints_myVectors_otherVectors_mySquaredLengths_otherSquaredLengths_myAngles_otherAngles_maxSizeAndReferenceFlag_rowBase_rowInsertRemove_rowInsertRemoveCount(void)
{
	sqInt additionalMultiInsertRemoveCost;
	sqInt base;
	sqInt forReference;
	sqInt i;
	sqInt iM1;
	sqInt iM1T2;
	sqInt insert;
	sqInt insertBase;
	sqInt insertRemove;
	sqInt insertRemoveCount;
	sqInt j;
	sqInt jLimiT;
	sqInt jM1;
	sqInt jM1T2;
	sqInt maxDist;
	sqInt maxSize;
	sqInt maxSizeAndRefFlag;
	int *myAngles;
	sqInt myAnglesOop;
	int *myPoints;
	sqInt myPointsOop;
	int *mySquaredLengths;
	sqInt mySquaredLengthsOop;
	int *myVectors;
	sqInt myVectorsOop;
	sqInt myVectorsSize;
	int *otherAngles;
	sqInt otherAnglesOop;
	int *otherPoints;
	sqInt otherPointsOop;
	sqInt otherPointsSize;
	int *otherSquaredLengths;
	sqInt otherSquaredLengthsOop;
	sqInt otherSquaredLengthsSize;
	int *otherVectors;
	sqInt otherVectorsOop;
	sqInt otherVectorsSize;
	sqInt remove;
	sqInt removeBase;
	int *rowBase;
	sqInt rowBaseOop;
	sqInt rowBaseSize;
	int *rowInsertRemove;
	int *rowInsertRemoveCount;
	sqInt rowInsertRemoveCountOop;
	sqInt rowInsertRemoveOop;
	sqInt subst;
	int substBase;
	sqInt _return_value;

	myPointsOop = stackValue(11);
	otherPointsOop = stackValue(10);
	myVectorsOop = stackValue(9);
	otherVectorsOop = stackValue(8);
	mySquaredLengthsOop = stackValue(7);
	otherSquaredLengthsOop = stackValue(6);
	myAnglesOop = stackValue(5);
	otherAnglesOop = stackValue(4);
	maxSizeAndRefFlag = stackIntegerValue(3);
	rowBaseOop = stackValue(2);
	rowInsertRemoveOop = stackValue(1);
	rowInsertRemoveCountOop = stackValue(0);
	if (failed()) {
		return null;
	}
	if (failed()) {
		msg("failed 1");
		return null;
	}
	success(((((((((((isWords(myPointsOop)) && (isWords(otherPointsOop))) && (isWords(myVectorsOop))) && (isWords(otherVectorsOop))) && (isWords(mySquaredLengthsOop))) && (isWords(otherSquaredLengthsOop))) && (isWords(myAnglesOop))) && (isWords(otherAnglesOop))) && (isWords(rowBaseOop))) && (isWords(rowInsertRemoveOop))) && (isWords(rowInsertRemoveCountOop)));
	if (failed()) {
		msg("failed 2");
		return null;
	}
	success((isMemberOf(myPointsOop, "PointArray")) && (isMemberOf(otherPointsOop, "PointArray")));
	if (failed()) {
		msg("failed 3");
		return null;
	}
	myPoints = firstIndexableField(myPointsOop);
	otherPoints = firstIndexableField(otherPointsOop);
	myVectors = firstIndexableField(myVectorsOop);
	otherVectors = firstIndexableField(otherVectorsOop);
	mySquaredLengths = firstIndexableField(mySquaredLengthsOop);
	otherSquaredLengths = firstIndexableField(otherSquaredLengthsOop);
	myAngles = firstIndexableField(myAnglesOop);
	otherAngles = firstIndexableField(otherAnglesOop);
	rowBase = firstIndexableField(rowBaseOop);
	rowInsertRemove = firstIndexableField(rowInsertRemoveOop);

	/* Note: myPointsSize and mySquaredLengthsSize variables eliminated to reduce
	   method temporary variable count for closure-enabled images */
	/* PointArrays */
	/* myPointsSize := (interpreterProxy stSizeOf: myPointsOop) bitShift: -1. */
	rowInsertRemoveCount = firstIndexableField(rowInsertRemoveCountOop);
	otherPointsSize = ((usqInt) (stSizeOf(otherPointsOop)) >> 1);
	myVectorsSize = ((usqInt) (stSizeOf(myVectorsOop)) >> 1);

	/* IntegerArrays */
	/* mySquaredLengthsSize := interpreterProxy stSizeOf: mySquaredLengthsOop. */
	otherVectorsSize = ((usqInt) (stSizeOf(otherVectorsOop)) >> 1);
	otherSquaredLengthsSize = stSizeOf(otherSquaredLengthsOop);
	rowBaseSize = stSizeOf(rowBaseOop);
	success(((rowBaseSize == (stSizeOf(rowInsertRemoveOop))) && (rowBaseSize == (stSizeOf(rowInsertRemoveCountOop)))) && (rowBaseSize > otherVectorsSize));
	if (failed()) {
		msg("failed 4");
		return null;
	}
	success(((((((stSizeOf(mySquaredLengthsOop)) >= (myVectorsSize - 1)) && ((((usqInt) (stSizeOf(myPointsOop)) >> 1)) >= myVectorsSize)) && (otherSquaredLengthsSize >= (otherVectorsSize - 1))) && (otherPointsSize >= otherVectorsSize)) && ((stSizeOf(myAnglesOop)) >= (myVectorsSize - 1))) && ((stSizeOf(otherAnglesOop)) >= (otherVectorsSize - 1)));
	if (failed()) {
		msg("failed 5");
		return null;
	}
	forReference = maxSizeAndRefFlag & 1;
	maxSize = ((usqInt) maxSizeAndRefFlag >> 1);
	maxDist = ((usqInt) 1 << 29);
	if (forReference) {
		additionalMultiInsertRemoveCost = 0;
	}
	else {
		additionalMultiInsertRemoveCost = ((usqInt) (maxSize * maxSize) >> 10);
	}
	rowBase[0] = 0;
	rowInsertRemove[0] = 0;
	rowInsertRemoveCount[0] = 2;
	insertRemove = 0 - additionalMultiInsertRemoveCost;
	jLimiT = otherVectorsSize;
	if (!((otherPointsSize >= (jLimiT - 1)) && (otherSquaredLengthsSize >= (jLimiT - 1)))) {
		primitiveFail();
		return null;
	}
	for (j = 1; j <= jLimiT; j += 1) {
		jM1 = j - 1;
		insertRemove = (insertRemove + (((usqInt) ((otherSquaredLengths[jM1]) + (cSquaredDistanceFromto(otherPoints + (((usqInt) jM1 << 1)), myPoints))) >> 7))) + additionalMultiInsertRemoveCost;
		rowInsertRemove[j] = insertRemove;
		rowBase[j] = (insertRemove * j);
		rowInsertRemoveCount[j] = (j + 1);
	}
	insertRemove = (rowInsertRemove[0]) - additionalMultiInsertRemoveCost;
	for (i = 1; i <= myVectorsSize; i += 1) {
		iM1 = i - 1;
		iM1T2 = ((usqInt) iM1 << 1);
		substBase = rowBase[0];
		insertRemove = (insertRemove + (((usqInt) ((mySquaredLengths[iM1]) + (cSquaredDistanceFromto(myPoints + iM1T2, otherPoints))) >> 7))) + additionalMultiInsertRemoveCost;
		rowInsertRemove[0] = insertRemove;
		rowBase[0] = (insertRemove * i);
		rowInsertRemoveCount[0] = (i + 1);
		jLimiT = otherVectorsSize;
		for (j = 1; j <= jLimiT; j += 1) {
			jM1 = j - 1;
			jM1T2 = ((usqInt) jM1 << 1);
			removeBase = rowBase[j];
			insertBase = rowBase[jM1];
			remove = ((usqInt) ((mySquaredLengths[iM1]) + (cSquaredDistanceFromto(myPoints + iM1T2, otherPoints + (((usqInt) j << 1))))) >> 7);
			if (((insertRemove = rowInsertRemove[j])) == 0) {
				removeBase += remove;
			}
			else {
				removeBase = (removeBase + insertRemove) + (remove * (rowInsertRemoveCount[j]));
				remove += insertRemove;
			}
			insert = ((usqInt) ((otherSquaredLengths[jM1]) + (cSquaredDistanceFromto(otherPoints + jM1T2, myPoints + (((usqInt) i << 1))))) >> 7);
			if (((insertRemove = rowInsertRemove[jM1])) == 0) {
				insertBase += insert;
			}
			else {
				insertBase = (insertBase + insertRemove) + (insert * (rowInsertRemoveCount[jM1]));
				insert += insertRemove;
			}
			if (forReference) {
				substBase = maxDist;
			}
			else {
				subst = ((usqInt) (((cSquaredDistanceFromto(otherVectors + jM1T2, myVectors + iM1T2)) + (cSquaredDistanceFromto(otherPoints + jM1T2, myPoints + iM1T2))) * (16 + (cSubstAngleFactorFromto(otherAngles[jM1], myAngles[iM1])))) >> 11);
				substBase += subst;
			}
			if ((substBase <= removeBase)
			 && (substBase <= insertBase)) {
				base = substBase;
				insertRemove = 0;
				insertRemoveCount = 1;
			}
			else {
				if (removeBase <= insertBase) {
					base = removeBase;
					insertRemove = remove + additionalMultiInsertRemoveCost;
					insertRemoveCount = (rowInsertRemoveCount[j]) + 1;
				}
				else {
					base = insertBase;
					insertRemove = insert + additionalMultiInsertRemoveCost;
					insertRemoveCount = (rowInsertRemoveCount[jM1]) + 1;
				}
			}
			substBase = rowBase[j];
			rowBase[j] = (((base < maxDist) ? base : maxDist));
			rowInsertRemove[j] = (((insertRemove < maxDist) ? insertRemove : maxDist));
			rowInsertRemoveCount[j] = insertRemoveCount;
		}
		insertRemove = rowInsertRemove[0];
	}
	if (failed()) {
		return null;
	}
	_return_value = integerObjectOf(base);
	if (failed()) {
		return null;
	}
	popthenPush(13, _return_value);
	return null;
}


/*	majorNO * 1000 + minorNO */

	/* GeniePlugin>>#primVersionNO */
EXPORT(sqInt)
primVersionNO(void)
{
	sqInt _return_value;

	if (failed()) {
		return null;
	}
	_return_value = integerObjectOf(((2 * 1000)));
	if (failed()) {
		return null;
	}
	popthenPush(1, _return_value);
	return null;
}


/*	Note: This is coded so that it can be run in Squeak. */

	/* InterpreterPlugin>>#setInterpreter: */
EXPORT(sqInt)
setInterpreter(struct VirtualMachine*anInterpreter)
{
	sqInt ok;

	interpreterProxy = anInterpreter;
	ok = ((interpreterProxy->majorVersion()) == (VM_PROXY_MAJOR))
	 && ((interpreterProxy->minorVersion()) >= (VM_PROXY_MINOR));
	if (ok) {
		
#if !defined(SQUEAK_BUILTIN_PLUGIN)
		failed = interpreterProxy->failed;
		firstIndexableField = interpreterProxy->firstIndexableField;
		integerObjectOf = interpreterProxy->integerObjectOf;
		isMemberOf = interpreterProxy->isMemberOf;
		isWords = interpreterProxy->isWords;
		popthenPush = interpreterProxy->popthenPush;
		primitiveFail = interpreterProxy->primitiveFail;
		stSizeOf = interpreterProxy->stSizeOf;
		stackIntegerValue = interpreterProxy->stackIntegerValue;
		stackValue = interpreterProxy->stackValue;
		success = interpreterProxy->success;
#endif /* !defined(SQUEAK_BUILTIN_PLUGIN) */
	}
	return ok;
}

	/* SmartSyntaxInterpreterPlugin>>#sqAssert: */
static sqInt
sqAssert(sqInt aBool)
{
	/* missing DebugCode */;
	return aBool;
}


#ifdef SQUEAK_BUILTIN_PLUGIN

static char _m[] = "GeniePlugin";
void* GeniePlugin_exports[][3] = {
	{(void*)_m, "getModuleName", (void*)getModuleName},
	{(void*)_m, "primSameClassAbsoluteStrokeDistanceMyPoints_otherPoints_myVectors_otherVectors_mySquaredLengths_otherSquaredLengths_myAngles_otherAngles_maxSizeAndReferenceFlag_rowBase_rowInsertRemove_rowInsertRemoveCount\000\001", (void*)primSameClassAbsoluteStrokeDistanceMyPoints_otherPoints_myVectors_otherVectors_mySquaredLengths_otherSquaredLengths_myAngles_otherAngles_maxSizeAndReferenceFlag_rowBase_rowInsertRemove_rowInsertRemoveCount},
	{(void*)_m, "primVersionNO\000\377", (void*)primVersionNO},
	{(void*)_m, "setInterpreter", (void*)setInterpreter},
	{NULL, NULL, NULL}
};

#else /* ifdef SQ_BUILTIN_PLUGIN */

signed char primSameClassAbsoluteStrokeDistanceMyPoints_otherPoints_myVectors_otherVectors_mySquaredLengths_otherSquaredLengths_myAngles_otherAngles_maxSizeAndReferenceFlag_rowBase_rowInsertRemove_rowInsertRemoveCountAccessorDepth = 1;

#endif /* ifdef SQ_BUILTIN_PLUGIN */
